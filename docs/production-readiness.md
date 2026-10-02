# Production Readiness Note (1 page)

**Service:** SaaS web tier on AWS | **Owner:** Cloud Engineering | **IaC:** Terraform (this repo)

## Ready today
- **Availability:** ALB + ASG across 2 AZs, min 2 instances, ELB-based self-healing. Target: 99.9%.
- **Security:** private compute, least-privilege SGs, TLS at the edge, encrypted EBS, IMDSv2, no SSH or static keys, S3 BPA, secret scanning in CI.
- **Operations:** IaC with remote locked state, PR plan + gated apply, rolling refreshes, SSM Session Manager for access.
- **Observability:** logs, metrics, alarms (CPU, unhealthy hosts, 5xx) to email via SNS; flow logs; ALB logs.
- **Cost:** about $84/month baseline, Graviton, budget alerts at 80% / 100%.

## Known gaps before real customer traffic (prioritized)
1. **Real domain + ACM certificate + Route 53** (replace self-signed cert). *Blocker.*
2. **WAF + CloudFront** for DDoS/OWASP protection and caching.
3. **Data tier:** RDS Multi-AZ in isolated DB subnets, automated backups, tested restores.
4. **NAT single point of failure:** set `single_nat_gateway=false` (about +$33/month).
5. **Alert routing:** move from email to PagerDuty/Slack/Opsgenie with an on-call rotation.
6. **Immutable AMIs** (Packer/Image Builder) instead of user-data installs; patching via SSM Patch Manager.
7. **Account hardening:** CloudTrail, GuardDuty, AWS Config, Security Hub; multi-account (prod/non-prod).
8. **Deletion protection** on ALB and stateful resources; enable Checkov hard-fail in CI.

## Risks and mitigations
| Risk | Mitigation |
|---|---|
| AZ outage | 2-AZ design; add per-AZ NAT |
| Bad deploy | Rolling refresh, ELB health checks, plan review, Git revert + re-apply |
| Cost surprise | Budget alerts, max ASG size 6, tags for cost allocation |
| Credential leak | OIDC and instance roles only, gitleaks in CI |
| State corruption | Versioned, encrypted S3 state with locking |

## Operations
- **Rollback:** revert commit, pipeline re-applies (instance refresh restores previous template).
- **Access:** `aws ssm start-session --target <instance-id>`; no inbound admin ports.
- **Runbook triggers:** unhealthy-host alarm (check `/var/log/nginx/error.log` in CloudWatch, replace instance), CPU alarm (verify scaling, raise `asg_max` if capped).

**Go-live recommendation:** *Conditional GO* for staging/beta now. Full production after items 1-3 are complete.
