import re
from urllib.parse import urlsplit

from pydantic import BaseModel, field_validator

class URLCreate(BaseModel):
    url: str

    @field_validator("url")
    @classmethod
    def normalize_url(cls, value: str) -> str:
        url = value.strip()
        if not url:
            raise ValueError("URL is required")

        if url.startswith("//"):
            url = url[2:]

        if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", url) and "://" not in url:
            raise ValueError("Only HTTP URLs are supported")

        if "://" in url:
            parsed = urlsplit(url)
            if parsed.scheme not in {"http", "https"}:
                raise ValueError("Only HTTP URLs are supported")
            url = f"{parsed.netloc}{parsed.path}"
            if parsed.query:
                url = f"{url}?{parsed.query}"
            if parsed.fragment:
                url = f"{url}#{parsed.fragment}"

        if not url:
            raise ValueError("Invalid URL")

        if url.startswith("/"):
            raise ValueError("Invalid URL")

        if "://" not in url:
            url = f"https://{url}"

        parsed = urlsplit(url)
        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise ValueError("Invalid URL")

        return url

class URLResponse(BaseModel):
    short_url: str
    code: str
