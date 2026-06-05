# 03 — LUẬT CONCURRENCY, SCALING & HIGH AVAILABILITY (Bắt buộc)

> ĐÂY LÀ LUẬT. Agent thiết kế hệ thống PHẢI tuân theo. Vi phạm = finding GĐ14 Part A.

---

## PHẦN I — CONCURRENCY

### NGUYÊN TẮC BẤT BIẾN

1. **KHÔNG shared mutable state mà không có cơ chế bảo vệ.** Race condition = bug ngầm, khó debug nhất.
2. **Ưu tiên immutable data.** Nếu data không đổi, không cần lock.
3. **Ưu tiên message passing (share by communicating) thay vì shared memory (communicate by sharing).**
4. **Mọi async operation PHẢI có timeout.** Không timeout = có thể treo vĩnh viễn.
5. **Mọi async operation PHẢI có error handling.** Unhandled promise rejection = crash tiềm ẩn.

### BẢNG BẮT BUỘC: Bài toán → Pattern

| Bài toán | Pattern BẮT BUỘC | CẤM dùng |
|----------|-----------------|----------|
| Web server high-concurrency I/O | Event Loop (Node.js) HOẶC CSP (Go) HOẶC Async runtime (Rust tokio) | Spawn raw thread per request |
| Background job processing | Message Queue + Worker Pool (Redis/BullMQ, Celery, Sidekiq) | Cron job in-process chạy cùng web server |
| Real-time collaboration | CRDT + WebSocket + Actor/Channel | Polling + DB lock |
| CPU-bound computation (image, AI) | Tách worker process/thread pool riêng, KHÔNG block event loop | Chạy trên main thread của web server |
| Rate limiting | Token bucket HOẶC sliding window (ở middleware/gateway) | Chỉ check trong business logic |
| Scheduled task (recurring) | Dedicated scheduler (cron service) với distributed lock | setInterval() trong app process |
| Parallel API calls | Promise.all / async gather + timeout per call + circuit breaker | Sequential await từng cái |
| Database write contention | Optimistic locking (version field) HOẶC queue serialization | Ignore conflicts |

### LUẬT TIMEOUT (không ngoại lệ)

```
MỌI external call PHẢI có timeout:
- HTTP call đến service khác: ≤ 5s (default), configurable.
- Database query: ≤ 10s (statement_timeout).
- Message queue publish: ≤ 3s.
- File upload: timeout = fileSize / minBandwidth + buffer.
- Tổng request timeout (gateway): ≤ 30s cho API; ≤ 60s cho upload/download.

VI PHẠM: call không có timeout = bug CRITICAL ở GĐ14.
```

### LUẬT RETRY

```
1. CHỈ retry khi error là TRANSIENT (network timeout, 503, 429). KHÔNG retry 400, 401, 404.
2. BẮT BUỘC exponential backoff: delay = baseDelay * 2^attempt + jitter.
3. Max retry: ≤ 3 cho sync call; ≤ 5 cho async job.
4. BẮT BUỘC idempotency key cho mọi operation có side-effect mà có thể retry.
5. KHÔNG retry bên trong retry (nested retry = exponential explosion).
```

### LUẬT DISTRIBUTED LOCK

```
1. CHỈ dùng distributed lock khi THẬT SỰ cần mutual exclusion cross-instance.
2. Lock PHẢI có TTL (time-to-live). KHÔNG lock vĩnh viễn.
3. Lock owner PHẢI release khi xong. Dùng try/finally.
4. KHÔNG dùng DB row lock cho distributed lock. Dùng Redis SETNX hoặc DynamoDB conditional write.
```

---

## PHẦN II — SCALING

### NGUYÊN TẮC BẤT BIẾN

1. **Scale ĐÚNG bottleneck.** Đo trước, scale sau. KHÔNG đoán.
2. **Stateless trước, stateful sau.** Stateless service scale bằng thêm instance.
3. **Cache là thuốc, dùng đúng liều.** Cache invalidation sai = data cũ.
4. **Database là bottleneck phổ biến nhất.** Optimize DB trước khi thêm app server.

### BẢNG BẮT BUỘC: Bottleneck → Giải pháp

| Bottleneck | Giải pháp (theo thứ tự) | CẤM |
|------------|--------------------------|-----|
| API server CPU | 1. Optimize code 2. Horizontal scale + LB | Scale DB trước khi fix app |
| Database read | 1. Index 2. Query optimize 3. Cache 4. Read replica | Thêm app server |
| Database write | 1. Batch write 2. Queue + async 3. Sharding | Read replica |
| Network latency (global) | 1. CDN 2. Edge compute 3. Multi-region | Chỉ tăng bandwidth |

### LUẬT CACHE

```
1. PHẢI có invalidation strategy: TTL / event-based / write-through.
2. Cache key format: <entity>:<id>:<version>
3. KHÔNG cache user-specific data trong shared cache (trừ khi key chứa userId).
4. PHẢI có fallback khi cache miss + stampede protection.
5. Monitor hit ratio. < 80% = review.
```

### LUẬT AUTO-SCALING

```
1. Scale-out: CPU > 70% sustained 2 min HOẶC queue depth > threshold.
2. Scale-in: CPU < 30% sustained 5 min (chậm hơn để tránh flap).
3. Min instances >= 2. Max có budget cap.
4. Health check: /health (liveness) + /health/ready (readiness).
5. Graceful shutdown: SIGTERM -> stop accepting -> finish in-flight -> exit.
```

---

## PHẦN III — HIGH AVAILABILITY

### BẢNG BẮT BUỘC PATTERNS

| Pattern | BẮT BUỘC khi | Cấu hình |
|---------|-------------|----------|
| **Circuit Breaker** | Mọi cross-service call | threshold=5 fail/30s -> open 60s -> half-open |
| **Bulkhead** | Gọi > 2 downstream | Pool riêng mỗi downstream |
| **Retry + Backoff** | Mọi external call | Xem LUẬT RETRY |
| **Health Check** | Mọi service | /health + /health/ready |
| **Graceful Degradation** | User-facing | Feature flag disable non-critical |
| **Failover** | Database, broker | Auto-failover < 30s |
| **Redundancy** | Stateless service | >= 2 instances luôn |

### LUẬT DATABASE HA

```
1. Production: automated backup daily + point-in-time recovery.
2. super-large/saas: read replica + auto-failover.
3. KHÔNG chạy DB trên container ephemeral. Dùng managed service.
4. Connection pooling BẮT BUỘC.
5. Migration backward-compatible (expand-contract). KHÔNG drop column cùng deploy.
```

---

## PHẦN IV — MESSAGE QUEUE

```
1. Consumer PHẢI idempotent.
2. PHẢI có DLQ. Fail > max_retry -> DLQ + alert.
3. Schema versioned. Thêm field OK; xóa/đổi = breaking.
4. Monitor: queue depth, consumer lag, processing time.
5. Ordering: chỉ dùng khi thật sự cần (partition key).
```

| Broker | Khi dùng | KHÔNG khi |
|--------|----------|-----------|
| **Redis/BullMQ** | Simple job queue, small-medium | Durable stream, large payload |
| **RabbitMQ** | Complex routing, priority, RPC | Huge throughput >100k/s |
| **Kafka** | Event stream, audit, replay, huge throughput | Simple task queue |
| **SQS/SNS** | Managed, serverless | Need replay |
| **NATS** | Ultra-low-latency, lightweight | Need persistence default |

---

## PHẦN V — SECURITY INFRASTRUCTURE

### BẮT BUỘC MỌI DỰ ÁN

```
1. HTTPS everywhere. HTTP -> redirect.
2. Secrets KHÔNG trong code/repo. Env vars / secret manager.
3. Password: bcrypt/argon2 cost>=10. KHÔNG MD5/SHA thuần.
4. SQL: parameterized query ONLY. KHÔNG string concat.
5. XSS: sanitize output + CSP header.
6. CORS: whitelist origin. KHÔNG wildcard cho authenticated API.
7. Rate limit auth endpoints: <= 5 req/min/IP.
8. Input validation ở boundary. Reject early.
9. Dependency audit weekly. Critical CVE fix 48h.
10. KHÔNG log password, token, credit card, PII.
```

### THÊM CHO SUPER-LARGE / SAAS

```
11. Pen testing trước major release.
12. SOC2/ISO27001 nếu B2B enterprise.
13. Encryption at rest AES-256.
14. Key rotation >= 90 ngày.
15. Audit log: who/what/when immutable.
16. Multi-tenant: enforce ở data layer (RLS/schema). KHÔNG chỉ app code.
```

---

## PHẦN VI — OBSERVABILITY

### MỌI DỰ ÁN

```
1. Structured logging (JSON): level, message, timestamp, requestId, error.
2. Error tracking (Sentry/Bugsnag). Alert khi spike.
3. Health endpoint: GET /health -> 200.
```

### SMALL + SUPER-LARGE

```
4. Metrics: request count, latency p50/p95/p99, error rate (Prometheus/Datadog).
5. Distributed tracing (OpenTelemetry).
6. Alerting: p99 > 2s warn; error > 5% critical; disk > 80% warn.
7. Golden signals dashboard (traffic, error, latency, saturation).
8. Mỗi alert PHẢI có runbook link.
9. Incident response: on-call, escalation, postmortem.
```

---

## TÓM TẮT: AGENT DÙNG FILE NÀY THẾ NÀO

| GĐ | Hành động |
|----|-----------|
| 3 | Tra scaling/queue strategy phù hợp size |
| 5 | Checklist security (PHẦN V) |
| 7 | Thiết kế concurrency + HA vào architecture.md |
| 9 | Đưa PHẦN VI vào coding-standards + monitoring requirement |
| 11 | Code tuân thủ timeout, retry, circuit breaker |
| 14 | Kiểm tra vi phạm = finding |
