from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.sql import func
from .database import Base

class URL(Base):
    __tablename__ = "urls"
    id       = Column(Integer, primary_key=True)
    original = Column(String, nullable=False)
    code     = Column(String(10), unique=True, nullable=False)
    clicks   = Column(Integer, default=0)
    created  = Column(DateTime, server_default=func.now())