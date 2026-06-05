# 06 — LUẬT DEVOPS, CI/CD & INFRASTRUCTURE (Bắt buộc)

> ĐÂY LÀ LUẬT. Vi phạm = finding GĐ14 Part A/B.

---

## NGUYÊN TẮC BẤT BIẾN

1. **Infrastructure as Code.** Mọi infra PHẢI reproducible từ code. KHÔNG click-ops.
2. **CI/CD là citizen hạng nhất.** Mọi thay đổi qua pipeline. KHÔNG deploy thủ công production.
3. **Environment parity.** Dev ≈ staging ≈ production (same stack, chỉ khác scale).
4. **Secrets KHÔNG trong code.** Environment variables / secret manager.
5. **Rollback < 5 phút.** Nếu deploy fail, quay lại version cũ ngay.

---

## LUẬT CI/CD PIPELINE

### Pipeline bắt buộc (mọi dự án)

```yaml
# Minimum viable pipeline (personal → super-large đều phải có)
stages:
  - lint          # format + lint check
  - test          # unit + integration
  - build         # compile / bundle
  - deploy-staging # auto (small+) hoặc manual (personal)
  - deploy-prod   # manual trigger / approval gate
```

### Quy tắc cứng

```
1. Pipeline chạy trên MỌII PR/MR. Merge blocked nếu pipeline fail.
2. Lint + format: auto-fix KHÔNG được; PHẢI fail nếu vi phạm (dev tự fix).
3. Test: fail threshold = 0 test fail. Coverage không giảm.
4. Build: artifact versioned (git SHA hoặc semver tag).
5. Deploy staging: TỰ ĐỘNG sau merge vào main/develop.
6. Deploy production: MANUAL approval (hoặc auto nếu canary pass — super-large).
7. Pipeline time budget: < 10 phút (personal), < 20 phút (small), < 30 phút (super-large).
8. Cache dependencies (node_modules, .gradle, pip cache) để giảm thời gian.
```

### Thêm cho super-large

```
- Security scan (SAST: Semgrep/CodeQL, dependency: Snyk/Trivy)
- Contract test
- Performance test (k6 baseline)
- Canary deploy → auto promote/rollback based on metrics
- Deploy approval: 2 reviewers minimum
```

---

## LUẬT DOCKER

```
1. Dockerfile BẮT BUỘC cho mọi service. Dev run = docker compose up.
2. Multi-stage build: build stage (heavy) → runtime stage (minimal).
3. Base image: official + specific version tag. KHÔNG :latest.
4. .dockerignore: node_modules, .git, .env, build artifacts.
5. Non-root user: USER app (KHÔNG chạy container với root).
6. Health check trong Dockerfile: HEALTHCHECK CMD curl -f http://localhost:$PORT/health
7. Image size budget: < 100MB (Go/Rust), < 300MB (Node), < 500MB (Java).
8. Layer ordering: ít thay đổi trước (dependencies) → hay thay đổi sau (code).
```

**Khuôn mẫu Dockerfile (Node.js):**
```dockerfile
# Build stage
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Runtime stage
FROM node:22-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER app
EXPOSE 3000
HEALTHCHECK CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/main.js"]
```

---

## LUẬT ENVIRONMENT

| Environment | Mục đích | Deploy trigger | Data |
|-------------|----------|---------------|------|
| **local/dev** | Phát triển | Tự động (docker compose) | Seed/mock |
| **staging** | Test integration, UAT | Auto sau merge main | Copy sanitized từ prod hoặc seed |
| **production** | User thật | Manual approval | Real |

```
LUẬT:
1. Mọi env config qua ENV VARS. KHÔNG hardcode URL/credentials.
2. .env.example PHẢI tồn tại (mẫu biến cần, KHÔNG chứa giá trị thật).
3. Staging dùng CÙNG Docker image với production (khác config, same binary).
4. Feature flags: dùng cho feature chưa sẵn sàng. KHÔNG deploy code chưa test lên prod.
```

---

## LUẬT INFRASTRUCTURE AS CODE

| Tool | Khi dùng |
|------|----------|
| **Terraform** | Multi-cloud, mature, HCL declarative |
| **Pulumi** | Team thích TypeScript/Python, programmatic IaC |
| **CDK (AWS)** | AWS-only, team TypeScript |
| **Docker Compose** | Local dev, personal deploy |
| **Kubernetes (Helm/Kustomize)** | super-large, microservices |

```
LUẬT:
1. IaC trong repo (cùng repo hoặc infra repo riêng). Version controlled.
2. Plan/preview trước apply. KHÔNG apply blind.
3. State file (Terraform): remote backend (S3 + DynamoDB lock). KHÔNG local.
4. Secrets: KHÔNG trong IaC code. Dùng secret manager reference.
5. Module hóa: mỗi resource group = 1 module reusable.
```

---

## LUẬT MONITORING & ALERTING (runtime)

### Stack bắt buộc theo size

| Size | Metrics | Logs | Tracing | Alerting |
|------|---------|------|---------|----------|
| personal | Managed (Vercel/Railway analytics) | stdout | — | Email/Slack basic |
| small | Prometheus/Datadog | Structured JSON + aggregator | Optional | PagerDuty/Slack |
| super-large | Prometheus + Grafana | ELK/Loki | OpenTelemetry + Jaeger | PagerDuty + escalation |

### Golden Signals Dashboard (BẮT BUỘC small+)

```
1. Traffic: requests/sec per endpoint
2. Errors: error rate (4xx, 5xx) per endpoint
3. Latency: p50, p95, p99 per endpoint
4. Saturation: CPU%, memory%, disk%, DB connections
```

### Alert rules bắt buộc

```
- Error rate > 5% trong 5 min → CRITICAL → page on-call
- p99 latency > 2s trong 5 min → WARNING
- CPU > 80% sustained 10 min → WARNING
- Disk > 85% → WARNING; > 95% → CRITICAL
- Health check fail 3 consecutive → CRITICAL
- Certificate expiry < 14 days → WARNING
- Mọi alert PHẢI có runbook link.
```

---

## LUẬT DEPLOY STRATEGY

| Strategy | Khi dùng | Rollback |
|----------|----------|----------|
| **Rolling** | Default cho stateless | Stop rolling |
| **Blue-Green** | Zero-downtime, quick rollback | Switch traffic back |
| **Canary** | super-large, validate with real traffic | Kill canary |
| **Feature Flag** | Decouple deploy from release | Disable flag |

```
LUẬT:
1. Production deploy LUÔN có rollback plan. Test rollback trước.
2. Database migration PHẢI backward-compatible (deploy code trước, migrate sau).
3. Smoke test sau deploy: automated health + critical path.
4. Deploy window: KHÔNG deploy Friday afternoon / trước holiday (trừ hotfix).
5. Changelog / release notes: auto-generate từ commit (conventional commits).
```

---

## LUẬT DOMAIN & SSL

```
1. HTTPS everywhere. Auto-renew certificate (Let's Encrypt / managed).
2. HSTS header BẮT BUỘC.
3. DNS: managed (Cloudflare / Route53). TTL production: 300s (5 min).
4. www redirect: chọn 1 (www hoặc non-www), 301 redirect the other.
5. Staging: subdomain riêng (staging.example.com). KHÔNG share domain production.
```

---

## LUẬT COST MANAGEMENT

```
1. Tag mọi cloud resource: team, env, project.
2. Budget alert: 80% → warn; 100% → stop non-critical.
3. Destroy staging resources ngoài giờ làm (personal/small — tiết kiệm).
4. Right-size: review instance size monthly. Downgrade nếu utilization < 30%.
5. Reserved instances / spot cho workload predictable (super-large).
```
