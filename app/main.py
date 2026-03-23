from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.responses import RedirectResponse, HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from prometheus_fastapi_instrumentator import Instrumentator
from contextlib import asynccontextmanager
import string, random
from . import models, schemas, database

@asynccontextmanager
async def lifespan(app):
    models.Base.metadata.create_all(bind=database.engine)
    yield

app = FastAPI(title='URL Shortener', description='Secure URL Shortener with CI/CD', lifespan=lifespan)
app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")

Instrumentator().instrument(app).expose(app)

def generate_code(length=6):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choices(chars, k=length))

@app.get("/", response_class=HTMLResponse)
def index(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={},
    )

@app.get('/health')
def health():
    return {'status': 'ok'}

@app.post('/shorten', response_model=schemas.URLResponse)
def shorten_url(payload: schemas.URLCreate,
                db: Session = Depends(database.get_db)):
    code = generate_code()
    while db.query(models.URL).filter_by(code=code).first():
        code = generate_code()
    url = models.URL(original=str(payload.url), code=code)
    db.add(url); db.commit(); db.refresh(url)
    return {'short_url': f'http://url.astpbx.ru/{code}', 'code': code}

@app.get('/{code}')
def redirect(code: str, db: Session = Depends(database.get_db)):
    url = db.query(models.URL).filter_by(code=code).first()
    if not url:
        raise HTTPException(status_code=404, detail='Not found')
    url.clicks += 1; db.commit()
    return RedirectResponse(url=url.original, status_code=301)
