# 01 — LUẬT CHỌN KIẾN TRÚC (Bắt buộc)

> ĐÂY LÀ LUẬT, KHÔNG PHẢI GỢI Ý. Agent PHẢI tuân theo. Vi phạm = bug cần ADR giải trình.

---

## NGUYÊN TẮC TỔNG (KHÔNG ĐƯỢC VI PHẠM)

1. **KHÔNG microservices khi team < 5 người.** Distributed complexity sẽ giết project.
2. **KHÔNG monolith thuần khi team > 15 hoặc > 3 bounded contexts rõ ràng.**
3. **Luôn bắt đầu đơn giản nhất có thể rồi mới nâng.** Monolith → Modular → Micro (nếu CẦN).
4. **Kiến trúc là quyết định của CON NGƯỜI** (GĐ4). Agent chỉ đề xuất + giải thích tradeoff.
5. **Mọi quyết định kiến trúc PHẢI có ADR.** Không ADR = không hợp lệ.

---

## BẢNG BẮT BUỘC: SIZE × TYPE → KIẾN TRÚC CHO PHÉP

| size | type | ĐƯỢC PHÉP | CẤM | MẶC ĐỊNH (nếu autonomous) |
|------|------|-----------|-----|---------------------------|
| personal | tool | Monolith, Single-file | Microservices, CQRS, Event-Sourcing | Monolith |
| personal | web | Monolith, Jamstack (SSG) | Microservices, Micro-frontend | Monolith + SSG |
| personal | application | Monolith (MVVM hoặc MVI) | Microservices, DDD | MVVM Monolith |
| personal | saas | Monolith | Microservices | Monolith |
| small | tool | Monolith, Modular Monolith | — | Monolith |
| small | web | Monolith, Modular Monolith, Serverless | Microservices (trừ khi có ADR) | Modular Monolith |
| small | application | Modular Monolith (Clean Architecture) | — | Clean Arch + MVVM |
| small | saas | Modular Monolith, Event-Driven lite | Microservices full (trừ ADR) | Modular Monolith + Event Bus |
| super-large | tool | Modular Monolith, Microservices | Monolith thuần | Modular Monolith |
| super-large | web | Modular Monolith, Microservices, Micro-frontend | Monolith thuần | Microservices + Micro-FE |
| super-large | application | Clean Architecture, Microservices (backend) | Monolith thuần | Clean Arch + Microservices BE |
| super-large | saas | Microservices, Event-Driven, CQRS | Monolith thuần | Microservices + Event-Driven + CQRS |

---

## KHUÔN MẪU CHO TỪNG KIẾN TRÚC

### A. Monolith

```
LUẬT:
- 1 codebase, 1 repo, 1 deployable unit.
- TỔ CHỨC: feature-based folders (KHÔNG layer-based cho app > 10 screens).
- BẮT BUỘC có: dependency injection, interface cho mọi external service.
- GIỚI HẠN: khi file count > 500 hoặc > 5 developer → PHẢI chuyển sang Modular Monolith.
```

**Cấu trúc bắt buộc (feature-based):**
```
src/
├── features/
│   ├── auth/        { controller, service, repository, model, test }
│   ├── orders/      { controller, service, repository, model, test }
│   └── payments/    { ... }
├── shared/          { utils, middleware, config }
├── infra/           { database, cache, queue adapter }
└── main.ts          { bootstrap }
```

### B. Modular Monolith

```
LUẬT:
- 1 deployable unit NHƯNG chia thành modules có RANH GIỚI CỨNG.
- Modules KHÔNG import trực tiếp internal của nhau. Giao tiếp qua PUBLIC API (interface/contract).
- Mỗi module CÓ THỂ có DB schema riêng (schema isolation) hoặc shared schema (nhưng private tables).
- BẮT BUỘC: module dependency graph PHẢI acyclic (không circular dependency).
- MỖI MODULE là candidate để tách thành microservice sau này (nếu cần).
```

**Cấu trúc bắt buộc:**
```
src/
├── modules/
│   ├── auth/
│   │   ├── public/          { AuthService interface, DTOs — ĐƯỢC import bởi module khác }
│   │   ├── internal/        { implementation — CẤM import từ ngoài }
│   │   ├── infra/           { repository, adapter }
│   │   └── tests/
│   ├── billing/
│   │   ├── public/
│   │   ├── internal/
│   │   └── ...
│   └── ...
├── shared-kernel/           { cross-cutting: logging, errors, base classes }
├── infra/                   { DB connection, message bus, config }
└── main.ts                  { bootstrap, wire modules }
```

### C. Microservices

```
LUẬT:
- CHỈ ĐƯỢC dùng khi: team > 5 VÀ có > 3 bounded contexts rõ ràng VÀ cần deploy/scale độc lập.
- Mỗi service: 1 repo HOẶC 1 folder trong monorepo (phải có clear ownership).
- Mỗi service: OWN data riêng. KHÔNG shared database. CẤM direct DB access cross-service.
- Giao tiếp: sync (REST/gRPC) cho query; async (message queue) cho command/event.
- BẮT BUỘC có: service discovery, distributed tracing, centralized logging, health checks.
- BẮT BUỘC có: API Gateway hoặc BFF (Backend for Frontend).
- BẮT BUỘC: contract testing giữa services (Pact hoặc tương đương).
```

**Cấu trúc bắt buộc (monorepo style):**
```
services/
├── auth-service/       { src/, Dockerfile, tests/, api-contract.yaml }
├── order-service/      { ... }
├── payment-service/    { ... }
├── notification-service/ { ... }
libs/
├── shared-types/       { proto files, shared DTOs }
├── sdk/                { generated client SDK }
infra/
├── api-gateway/        { routing, rate-limit, auth middleware }
├── docker-compose.yaml
├── k8s/                { helm charts / manifests }
└── monitoring/         { prometheus, grafana, jaeger }
```

### D. Event-Driven

```
LUẬT:
- PHẢI có message broker (Kafka, RabbitMQ, SQS, NATS). KHÔNG dùng HTTP webhook thay event bus.
- Event schema PHẢI versioned (Avro, Protobuf, hoặc JSON Schema).
- PHẢI có Dead Letter Queue (DLQ) cho failed events.
- PHẢI idempotent consumer (xử lý trùng event không gây side-effect).
- BẮT BUỘC: event catalog (danh sách event, publisher, subscriber).
```

### E. CQRS (Command Query Responsibility Segregation)

```
LUẬT:
- CHỈ ĐƯỢC dùng khi: read/write ratio > 10:1 HOẶC read model phức tạp (aggregation, search).
- Command side: write to primary DB, publish event.
- Query side: read from optimized read store (denormalized, cached, search index).
- PHẢI chấp nhận eventual consistency. KHÔNG fake strong consistency.
- BẮT BUỘC kèm Event-Driven (command → event → update read model).
```

### F. Serverless (FaaS)

```
LUẬT:
- CHỈ ĐƯỢC dùng khi: traffic unpredictable HOẶC background job HOẶC event-triggered logic.
- KHÔNG DÙNG cho: long-running process (>15 phút), stateful workflow, low-latency (<50ms p99).
- BẮT BUỘC: cold start budget (p99 cold start PHẢI < UX threshold).
- BẮT BUỘC: structured logging (CloudWatch / GCP Logging compatible).
- Function PHẢI stateless. State lưu external (DB, S3, Redis).
```

---

## LUẬT CHUYỂN ĐỔI (khi nào nâng cấp kiến trúc)

| Trigger | Hành động | Cần ADR? |
|---------|-----------|----------|
| File count > 500 + team > 5 | Monolith → Modular Monolith | ✅ |
| > 3 modules cần deploy/scale riêng | Modular → extract Microservice | ✅ |
| Read/write ratio > 10:1 gây bottleneck | Thêm CQRS cho module đó | ✅ |
| Audit GĐ14 phát hiện coupling > threshold | Refactor ranh giới module | ✅ |

---

## ANTI-PATTERNS (CẤM TUYỆT ĐỐI)

| Anti-pattern | Mô tả | Hậu quả |
|-------------|--------|---------|
| **Distributed Monolith** | Microservices nhưng deploy phải cùng lúc | Worst of both worlds |
| **Shared Database** giữa services | 2+ services truy cập cùng DB tables | Coupling ngầm, migration hell |
| **Chatty Services** | Service gọi nhau quá nhiều sync call | Latency tích lũy, cascade failure |
| **God Service** | 1 service làm quá nhiều việc | Đó là monolith giấu mặt |
| **CQRS Everywhere** | Áp CQRS cho mọi thứ kể cả simple CRUD | Over-engineering, phức tạp vô ích |
| **Premature Microservices** | Team 2 người chia 10 services | Chết vì ops overhead |
