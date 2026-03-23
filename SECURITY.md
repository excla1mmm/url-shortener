# Security Policy

## Assets (what we protect)
- User URLs stored in PostgreSQL (AWS RDS)
- AWS infrastructure (EC2, RDS, VPC)
- Application credentials and secrets
- SSL certificates

## Threat Actors
- Script kiddies scanning for open ports
- Automated bots looking for exposed databases
- Accidental secret leaks from developers

## STRIDE Analysis

| Threat | Risk | Mitigation |
|--------|------|-----------|
| **Spoofing** | Fake requests to API | Input validation via Pydantic, URL scheme validation |
| **Tampering** | Modifying URLs in DB | RDS in private subnet, no direct access |
| **Repudiation** | Deny creating malicious URLs | CloudWatch logs, Prometheus metrics |
| **Info Disclosure** | Exposed secrets in code | Gitleaks blocks secrets in commits, all secrets in GitHub Secrets |
| **DoS** | Flood of requests | Rate limiting (planned) |
| **Elevation** | Access to AWS root | IAM minimal permissions, no root keys used |

## Implemented Mitigations

- **Network**: RDS in private subnet — no direct internet access, only reachable from EC2
- **IAM**: Terraform user has only required permissions (no AdministratorAccess)
- **SSH**: Key-based auth only, no passwords (ed25519 key)
- **HTTPS**: SSL via Let's Encrypt, auto-renewing certificate, HTTP redirects to HTTPS
- **Nginx**: Reverse proxy — app not exposed directly, sits behind Nginx
- **CI/CD**: Trivy scans Docker images on every push, fails on CRITICAL/HIGH CVE
- **SAST**: Semgrep scans Python and Terraform code on every push
- **Secrets**: Gitleaks blocks credentials in commits via pre-commit hooks and CI
- **Encryption**: RDS storage encrypted at rest
- **IMDSv2**: EC2 metadata service requires token — prevents SSRF attacks
- **Input validation**: Non-HTTP URLs rejected (mailto:, ftp:, etc.)
- **Monitoring**: Prometheus + Grafana monitors app health, Telegram alert on downtime

## Known Risks

- SSH port 22 open to 0.0.0.0/0 (required for GitHub Actions CD pipeline)
- No rate limiting yet (planned: slowapi middleware)
- Grafana accessible over HTTP on port 3000 (not exposed via HTTPS)
- Monitoring stack (Prometheus, Grafana) runs without authentication
