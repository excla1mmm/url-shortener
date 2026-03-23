# 🔗 URL Shortener

A production-grade URL shortening service built with a full DevSecOps pipeline.

![CI](https://github.com/excla1mmm/url-shortener/actions/workflows/ci.yml/badge.svg)
![CD](https://github.com/excla1mmm/url-shortener/actions/workflows/cd.yml/badge.svg)

## 🌐 Live Service
**http://54.179.149.72/docs** — Swagger UI

## 🏗️ Architecture
```
Internet → EC2 (public subnet) → Docker app → RDS PostgreSQL (private subnet)
                                      ↓
                              Prometheus → Grafana
```

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| FastAPI | REST API |
| PostgreSQL | Database |
| Docker | Containerization |
| GitHub Actions | CI/CD |
| Terraform | Infrastructure as Code |
| AWS EC2 + RDS | Cloud hosting |
| Trivy | Container vulnerability scanning |
| Semgrep | Static code analysis |
| Gitleaks | Secrets detection |
| Prometheus + Grafana | Monitoring |

## 🚀 Quick Start (local)
```bash
git clone https://github.com/excla1mmm/url-shortener
cd url-shortener
docker-compose up
# Open http://localhost:8000/docs
```

## 📊 Monitoring

- Prometheus collects metrics every 15 seconds
- Grafana dashboards: requests/sec, p95 latency, total requests
- Telegram alerts when app is down

## 📁 Project Structure
```
├── app/                  # FastAPI application
├── terraform/            # AWS infrastructure (VPC, EC2, RDS)
├── .github/workflows/    # CI/CD pipelines
├── monitoring/           # Prometheus config
├── Dockerfile            # Multi-stage build
└── docker-compose.yml    # Local development
```