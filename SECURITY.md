# Security Policy

## Assets (what we protect)
- User URLs stored in PostgreSQL
- AWS infrastructure (EC2, RDS)
- Application credentials and secrets

## Threat Actors
- Script kiddies scanning for open ports
- Automated bots looking for exposed databases
- Accidental secret leaks from developers

## STRIDE Analysis

| Threat | Risk | Mitigation |
|--------|------|-----------|
| **Spoofing** | Fake requests to API | Input validation via Pydantic |
| **Tampering** | Modifying URLs in DB | RDS in private subnet, no direct access |
| **Repudiation** | Deny creating malicious URLs | CloudWatch logs all requests |
| **Info Disclosure** | Exposed secrets in code | Gitleaks blocks secrets in commits |
| **DoS** | Flood of requests | Rate limiting (planned) |
| **Elevation** | Access to AWS root | IAM minimal permissions, no root keys |

## Implemented Mitigations

- **Network**: RDS in private subnet — no direct internet access
- **IAM**: Terraform user has only required permissions
- **SSH**: Key-based auth only, no passwords
- **CI/CD**: Trivy scans Docker images, fails on CRITICAL/HIGH CVE
- **SAST**: Semgrep scans code on every push
- **Secrets**: Gitleaks blocks credentials in commits
- **Encryption**: RDS storage encrypted at rest
- **IMDSv2**: EC2 metadata service requires token (prevents SSRF)
- **Logging**: RDS logs sent to CloudWatch

