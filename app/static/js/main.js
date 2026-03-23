function normalizeUserUrl(value) {
  return value
    .trim()
    .replace(/^\s*https?:\/\//i, '')
    .replace(/^\/\//, '');
}

function isValidUserUrl(value) {
  if (!value || /\s/.test(value) || value.startsWith('/')) {
    return false;
  }

  try {
    const parsed = new URL(`https://${value}`);
    return Boolean(parsed.hostname);
  } catch {
    return false;
  }
}

async function shorten() {
  const input = document.getElementById('urlInput');
  const btn = document.getElementById('shortenBtn');
  const result = document.getElementById('result');
  const errorMsg = document.getElementById('errorMsg');
  const rawUrl = normalizeUserUrl(input.value);

  input.value = rawUrl;

  if (!rawUrl) return;

  if (!isValidUserUrl(rawUrl)) {
    errorMsg.textContent = '// error: enter a valid URL without https://';
    errorMsg.classList.add('visible');
    result.classList.remove('visible');
    return;
  }

  btn.disabled = true;
  btn.textContent = 'WORKING...';
  result.classList.remove('visible');
  errorMsg.classList.remove('visible');

  try {
    const response = await fetch('/shorten', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ url: rawUrl })
    });

    if (!response.ok) {
      const data = await response.json();
      throw new Error(data.detail || 'Something went wrong');
    }

    const data = await response.json();
    const shortUrl = document.getElementById('shortUrl');
    shortUrl.href = data.short_url;
    shortUrl.textContent = data.short_url;
    result.classList.add('visible');
  } catch (err) {
    errorMsg.textContent = '// error: ' + err.message;
    errorMsg.classList.add('visible');
  } finally {
    btn.disabled = false;
    btn.textContent = 'SHORTEN →';
  }
}

function copyUrl() {
  const url = document.getElementById('shortUrl').textContent;
  navigator.clipboard.writeText(url).then(() => {
    const btn = document.getElementById('copyBtn');
    btn.textContent = 'COPIED!';
    btn.classList.add('copied');
    setTimeout(() => {
      btn.textContent = 'COPY';
      btn.classList.remove('copied');
    }, 2000);
  });
}

document.getElementById('urlInput').addEventListener('input', (e) => {
  e.target.value = normalizeUserUrl(e.target.value);
});

document.getElementById('urlInput').addEventListener('paste', (e) => {
  e.preventDefault();
  const pastedText = e.clipboardData.getData('text');
  e.target.value = normalizeUserUrl(pastedText);
});

document.getElementById('urlInput').addEventListener('keydown', (e) => {
  if (e.key === 'Enter') shorten();
});
