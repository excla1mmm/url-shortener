from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session
from prometheus_fastapi_instrumentator import Instrumentator
import string, random
from . import models, schemas, database

app = FastAPI(title='URL Shortener')

Instrumentator().instrument(app).expose(app)  # /metrics endpoint

models.Base.metadata.create_all(bind=database.engine)  # создаём таблицы при старте

def generate_code(length=6):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choices(chars, k=length))

@app.post('/shorten', response_model=schemas.URLResponse)
def shorten_url(payload: schemas.URLCreate,
                db: Session = Depends(database.get_db)):
    code = generate_code()
    while db.query(models.URL).filter_by(code=code).first():
        code = generate_code()
    url = models.URL(original=str(payload.url), code=code)
    db.add(url); db.commit(); db.refresh(url)
    return {'short_url': f'https://yourdomain.com/{code}', 'code': code}

@app.get('/health')
def health():
    return {'status': 'ok'}

@app.get('/{code}')
def redirect(code: str, db: Session = Depends(database.get_db)):
    url = db.query(models.URL).filter_by(code=code).first()
    if not url:
        raise HTTPException(status_code=404, detail='Not found')
    url.clicks += 1; db.commit()
    return RedirectResponse(url=url.original, status_code=301)