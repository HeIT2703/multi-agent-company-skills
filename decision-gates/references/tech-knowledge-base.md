# Tech Knowledge Base — Sổ tay tra cứu cho Agent (GĐ3–4)

> Agent PHẢI tra cứu file này khi sinh phương án ở GĐ3 (Feasibility & Options).
> Mỗi mục có: mô tả, khi nào dùng, khi nào KHÔNG dùng, tradeoff, quy mô phù hợp.
> Agent chọn các option phù hợp rồi trình người dùng ở GĐ4.

---

## 1. NỀN TẢNG / PLATFORM (chọn ở GĐ4)

### 1.1 Web

| Kiểu | Mô tả | Phù hợp | Không phù hợp |
|------|--------|---------|---------------|
| **SPA** (Single Page App) | Client-side rendering, 1 HTML shell + JS framework | Dashboard, internal tools, realtime app | SEO-heavy, content site |
| **SSR** (Server-Side Rendering) | HTML render trên server mỗi request | SEO, content-heavy, e-commerce | Offline-heavy, native experience |
| **SSG** (Static Site Generation) | Pre-render HTML lúc build | Blog, docs, landing page | Dynamic data nhiều |
| **Hybrid (ISR)** | Mix SSR + SSG + Client | Vừa SEO vừa dynamic (Next.js, Nuxt) | Quá đơn giản (overkill) |
| **PWA** (Progressive Web App) | Web + offline + install trên device | Cross-platform lite, budget thấp | Cần native API sâu (NFC, Bluetooth) |

### 1.2 Mobile

| Kiểu | Mô tả | Phù hợp | Không phù hợp |
|------|--------|---------|---------------|
| **Native iOS** (Swift/SwiftUI) | Best UX, full API access | iOS-only, premium UX cần thiết | Budget thấp, cần cả Android |
| **Native Android** (Kotlin/Compose) | Best performance, full API | Android-only | Cần iOS |
| **Cross-platform: Flutter** | 1 codebase → iOS+Android+Web | Startup, MVP, UI phức tạp | Cần native module nặng |
| **Cross-platform: React Native** | JS/TS, tận dụng web dev | Team JS, nhiều logic shared | Animation nặng, game |
| **Cross-platform: Kotlin Multiplatform** | Shared logic, native UI | Team Kotlin, logic phức tạp | Team nhỏ không biết Kotlin |

### 1.3 Desktop

| Kiểu | Mô tả | Phù hợp | Không phù hợp |
|------|--------|---------|---------------|
| **Electron** | Chromium + Node.js (VS Code, Slack) | Cross-platform, team web | Memory-sensitive, nhẹ |
| **Tauri** | Rust backend + Web frontend (nhẹ hơn Electron) | Cross-platform, cần nhẹ | Ecosystem chưa mature bằng Electron |
| **.NET MAUI / WPF** | Native Windows (có thể cross) | Enterprise Windows-heavy | macOS/Linux-only |
| **SwiftUI (macOS)** | Native macOS | macOS-only, tích hợp sâu Apple | Cross-platform |

### 1.4 CLI / Tool

| Kiểu | Mô tả | Phù hợp |
|------|--------|---------|
| **Go CLI** | Binary nhỏ, cross-compile dễ | DevOps tool, fast CLI |
| **Rust CLI** | Performance tối đa | System tool, parser, compiler |
| **Node.js CLI** | Ecosystem npm, dev nhanh | JS/TS tool, script |
| **Python CLI** | Script nhanh, AI/data | Automation, data pipeline |

---

## 2. KIẾN TRÚC HỆ THỐNG (chọn ở GĐ4)

### 2.1 Backend Architecture

| Pattern | Mô tả | Khi nào dùng | Khi nào KHÔNG | Quy mô |
|---------|--------|-------------|---------------|---------|
| **Monolith** | 1 codebase, 1 deploy | MVP, team < 5, product/market fit chưa rõ | >10 team, scale từng phần cần thiết | personal, small |
| **Modular Monolith** | 1 deploy nhưng chia module rõ ràng, boundary cứng | Team 3–10, cần structure mà chưa cần distributed | Team quá lớn deploy xung đột | small → super-large (giai đoạn đầu) |
| **Microservices** | Nhiều service độc lập, deploy riêng | Team >10, domain phức tạp, scale khác nhau | Team nhỏ (distributed complexity giết chết) | super-large |
| **Serverless (FaaS)** | Function chạy on-demand (Lambda, Cloud Functions) | Event-driven, traffic unpredictable, background jobs | Low-latency, long-running process, stateful | personal → small |
| **Event-Driven** | Communicate qua event/message (Kafka, RabbitMQ) | Decouple service, async workflow, audit trail | Simple CRUD, team nhỏ | small → super-large |
| **CQRS** | Tách Command (ghi) và Query (đọc) | Read/write ratio lệch lớn, complex domain | Simple CRUD, team nhỏ | super-large |

### 2.2 Frontend Architecture

| Pattern | Mô tả | Khi nào dùng |
|---------|--------|-------------|
| **Component-Based** (React, Vue, Svelte) | UI = cây component, unidirectional data | Mọi kích thước |
| **Micro-Frontend** | Nhiều team own từng phần UI, deploy độc lập | Super-large, nhiều team FE |
| **Islands Architecture** (Astro) | Static HTML + interactive islands | Content site + interactive widgets |
| **MVC / MVVM / MVI** | Dành cho mobile native | Mobile app cần structure |

### 2.3 Mobile Architecture

| Pattern | Mô tả | Best for |
|---------|--------|----------|
| **MVVM** | ViewModel giữ state, View observe | Đa số app: form, list, CRUD |
| **MVI** (Model-View-Intent) | Unidirectional flow, single state | Complex state, nhiều side-effect |
| **Clean Architecture** (Uncle Bob) | Layer: Domain → Data → Presentation | App lớn, cần testability cao |
| **MVVM + Clean** (hybrid) | Best of both: MVVM presentation + Clean layers | Production app chuẩn 2025–2026 |

---

## 3. CLEAN CODE & DESIGN PRINCIPLES

### 3.1 Nguyên tắc nền tảng

| Nguyên tắc | Tóm tắt | Khi vi phạm |
|------------|---------|-------------|
| **SOLID** | S=single resp, O=open-closed, L=Liskov, I=interface seg, D=dependency inv | Code cứng, khó test, khó mở rộng |
| **DRY** | Don't Repeat Yourself | Trùng lặp logic |
| **KISS** | Keep It Simple | Over-engineering sớm |
| **YAGNI** | You Ain't Gonna Need It | Build feature chưa cần |
| **Separation of Concerns** | Mỗi module 1 việc | Spaghetti code |
| **Composition over Inheritance** | Ưu tiên compose | Deep inheritance hell |

### 3.2 Design Patterns (Gang of Four + modern)

| Nhóm | Pattern | Use case phổ biến |
|------|---------|-------------------|
| Creational | Factory, Builder, Singleton, DI Container | Tạo object phức tạp, manage lifecycle |
| Structural | Adapter, Facade, Proxy, Decorator | Wrap API, simplify interface |
| Behavioral | Strategy, Observer, Command, State Machine | Plugin logic, event system, undo/redo |
| Modern | Repository, Unit of Work, CQRS, Mediator | Data access, decouple handler |

### 3.3 Code Organization

| Pattern | Mô tả | Phù hợp |
|---------|--------|---------|
| **Feature-based** (vertical slice) | Mỗi folder = 1 feature (route, model, service, test) | Đa số app |
| **Layer-based** (horizontal) | Chia controller/ service/ repository/ | Monolith nhỏ, CRUD đơn giản |
| **Domain-Driven Design (DDD)** | Bounded context, aggregate, entity, value object | Domain phức tạp (fintech, logistics) |
| **Hexagonal / Ports & Adapters** | Core domain ở giữa, adapter bọc ngoài | Cần swap infra (DB, API) dễ dàng |

---

## 4. CONCURRENCY & PARALLELISM

### 4.1 Concurrency Patterns

| Pattern | Mô tả | Language/Runtime | Use case |
|---------|--------|-----------------|----------|
| **Async/Await** | Non-blocking I/O | JS/TS, Python, C#, Rust, Kotlin | I/O-bound: HTTP call, DB query |
| **Actor Model** | Mỗi actor = state + mailbox, message passing | Akka (JVM), Elixir/OTP, Swift actors | Distributed state, chat, IoT |
| **CSP (Communicating Sequential Processes)** | Goroutines + channels | Go | High-concurrency server |
| **Thread Pool / Executor** | Pool of threads, submit task | Java, C++, Rust (tokio) | CPU-bound batch processing |
| **Event Loop** (single-threaded) | 1 thread + non-blocking I/O | Node.js, Python asyncio | High I/O concurrency, low CPU |
| **Reactive Streams** | Backpressure-aware stream processing | RxJava, Project Reactor, RxJS | Real-time data pipeline |
| **STM (Software Transactional Memory)** | Transactions trên shared memory | Clojure, Haskell | Complex shared state (hiếm dùng) |

### 4.2 Khi nào cần gì

| Bài toán | Pattern khuyên dùng |
|----------|---------------------|
| Web server cần xử lý 10k+ concurrent connections | Event Loop (Node.js) hoặc CSP (Go) |
| Background job processing | Thread Pool + Message Queue |
| Real-time collaboration (Google Docs-like) | Actor Model + CRDT |
| Data pipeline streaming | Reactive Streams + Backpressure |
| Game server | Actor Model hoặc ECS (Entity Component System) |

---

## 5. LOAD BALANCING & SCALING

### 5.1 Load Balancing Algorithms

| Algorithm | Mô tả | Khi dùng |
|-----------|--------|----------|
| **Round Robin** | Lần lượt | Server đồng đều, stateless |
| **Weighted Round Robin** | Lần lượt có trọng số | Server khác nhau capacity |
| **Least Connections** | Gửi tới server ít kết nối nhất | Long-lived connections |
| **IP Hash** | Hash IP → same server | Session affinity |
| **Random** | Random chọn server | Đơn giản, stateless |
| **Adaptive / AI-based** | Dựa trên health + latency realtime | Dynamic traffic, AI inference |

### 5.2 Scaling Strategies

| Strategy | Mô tả | Khi dùng |
|----------|--------|----------|
| **Vertical (scale up)** | Thêm CPU/RAM cho 1 máy | Quick fix, DB |
| **Horizontal (scale out)** | Thêm máy | Stateless services, web tier |
| **Auto-scaling** | Tự thêm/bớt instance theo metric | Cloud, traffic fluctuates |
| **Database: Read Replica** | Replica cho đọc | Read-heavy workload |
| **Database: Sharding** | Chia data theo key | Data quá lớn cho 1 DB |
| **CDN** | Cache static content ở edge | Global users, static assets |
| **Caching** (Redis, Memcached) | Cache hot data in-memory | Reduce DB load, session |

### 5.3 High Availability Patterns

| Pattern | Mô tả |
|---------|--------|
| **Active-Passive Failover** | 1 active, 1 standby |
| **Active-Active** | Nhiều node cùng active |
| **Circuit Breaker** | Ngắt khi downstream fail liên tục |
| **Bulkhead** | Isolate failure, không lan ra toàn hệ thống |
| **Retry + Exponential Backoff** | Thử lại với delay tăng dần |
| **Health Check + Self-Healing** | Monitor + tự restart |

---

## 6. DATABASE & DATA

### 6.1 Chọn Database

| Loại | Ví dụ | Phù hợp | Không phù hợp |
|------|-------|---------|---------------|
| **Relational (SQL)** | PostgreSQL, MySQL | ACID, structured data, complex query | Unstructured, horizontal scale extreme |
| **Document (NoSQL)** | MongoDB, Firestore | Flexible schema, JSON-like, rapid prototype | Complex joins, strong consistency |
| **Key-Value** | Redis, DynamoDB | Cache, session, high-speed lookup | Complex query, relationships |
| **Column-Family** | Cassandra, ScyllaDB | Time-series, write-heavy, huge scale | Ad-hoc query, small data |
| **Graph** | Neo4j, ArangoDB | Relationships (social, recommendation) | Simple CRUD |
| **Vector** | Pinecone, Qdrant, pgvector | AI/ML embedding search | Traditional CRUD |
| **Search** | Elasticsearch, Meilisearch | Full-text search, logs, analytics | Primary data store |

### 6.2 Data Patterns

| Pattern | Mô tả | Khi dùng |
|---------|--------|----------|
| **Repository Pattern** | Abstract data access behind interface | Clean code, testability |
| **Unit of Work** | Track changes, commit in batch | Complex transactions |
| **Event Sourcing** | Store events, rebuild state | Audit trail, undo, complex domain |
| **Saga** | Distributed transaction qua event | Microservices multi-service transaction |
| **Outbox Pattern** | Ensure event published after DB commit | Event-driven, exactly-once |

---

## 7. SECURITY & AUTH

| Pattern | Mô tả | Khi dùng |
|---------|--------|----------|
| **JWT + Refresh Token** | Stateless auth, short-lived access token | API, SPA, mobile |
| **Session-based** | Server-side session, cookie | SSR web, simple app |
| **OAuth 2.0 / OIDC** | Delegated auth (Google, GitHub login) | Social login, 3rd-party |
| **RBAC** (Role-Based Access Control) | Permission theo role | Multi-user app |
| **ABAC** (Attribute-Based) | Permission theo attribute (owner, department) | Fine-grained access |
| **API Key + Rate Limiting** | Simple auth cho service-to-service | Public API, tool |
| **mTLS** | Mutual TLS certificate | Service mesh, zero-trust |

---

## 8. TECH STACK CATALOG (agent chọn ở GĐ3, trình người dùng GĐ4)

### 8.1 Frontend Frameworks

| Framework | Ngôn ngữ | Strengths | Best for |
|-----------|----------|-----------|----------|
| **React** | JS/TS | Ecosystem lớn nhất, hiring dễ | SPA, dashboard, universal |
| **Next.js** | JS/TS | SSR/SSG/ISR, full-stack | SEO + dynamic, SaaS |
| **Vue 3** | JS/TS | Dễ học, progressive | Startup, internal tool |
| **Nuxt 3** | JS/TS | Vue + SSR/SSG | Vue ecosystem + SEO |
| **Svelte / SvelteKit** | JS/TS | Compile-time, no virtual DOM, fast | Performance-critical web |
| **Angular** | TS | Enterprise, opinionated, full-featured | Large enterprise team |
| **Astro** | Multi | Islands architecture, content-heavy | Blog, docs, marketing |

### 8.2 Backend Frameworks

| Framework | Ngôn ngữ | Strengths | Best for |
|-----------|----------|-----------|----------|
| **Express / Fastify** | Node.js TS | Nhẹ, ecosystem npm | API, microservice |
| **NestJS** | Node.js TS | Enterprise structure, DI, modular | SaaS backend, team lớn |
| **Django** | Python | Batteries-included, admin, ORM | Rapid prototype, data app |
| **FastAPI** | Python | Async, type-safe, OpenAPI auto | AI/ML API, modern Python |
| **Spring Boot** | Java/Kotlin | Enterprise proven, ecosystem khổng lồ | Enterprise, fintech |
| **Go (net/http, Gin, Fiber)** | Go | Fast, simple, concurrent | High-perf API, microservice |
| **Rust (Actix, Axum)** | Rust | Extreme performance, memory-safe | System, infra, crypto |
| **Laravel** | PHP | Full-stack, eloquent ORM, ecosystem | Web app, SaaS (PHP team) |
| **Rails** | Ruby | Convention over config, rapid | MVP, startup |
| **Elixir / Phoenix** | Elixir | Fault-tolerant, realtime (LiveView) | Realtime, chat, IoT |

### 8.3 DevOps & Infra

| Tool/Service | Category | Khi dùng |
|-------------|----------|----------|
| **Docker** | Container | Mọi dự án (dev-env nhất quán) |
| **Kubernetes** | Orchestration | super-large, microservices |
| **Terraform / Pulumi** | IaC | Infra as code, multi-cloud |
| **GitHub Actions / GitLab CI** | CI/CD | Mọi dự án |
| **Vercel / Netlify** | Frontend hosting | Jamstack, SSR/SSG |
| **AWS / GCP / Azure** | Cloud | Mọi quy mô |
| **Fly.io / Railway** | Simple deploy | Small, personal |
| **Cloudflare Workers** | Edge compute | Low-latency, global |

---

## 9. WORKFLOW & NGHIỆP VỤ THEO LOẠI DỰ ÁN

### 9.1 Application (Native/Cross-platform)

**Quy trình đặc thù:**
- GĐ4: chọn platform (iOS/Android/Cross) + architecture (MVVM/MVI/Clean)
- GĐ7: thiết kế offline-first strategy, local DB (SQLite/Realm), sync mechanism
- GĐ10: setup signing, provisioning, app store config
- GĐ12: device testing matrix (screen sizes, OS versions)
- GĐ16: TestFlight/Play Console beta → phased rollout

**Lưu ý:** cần `deep-link strategy`, `push notification architecture`, `app size budget`.

### 9.2 Web (SPA/SSR/SSG)

**Quy trình đặc thù:**
- GĐ4: chọn rendering strategy (SPA vs SSR vs Hybrid)
- GĐ7: API design (REST vs GraphQL), SEO strategy
- GĐ8: responsive design, Core Web Vitals budget
- GĐ10: CDN setup, image optimization pipeline
- GĐ14: Lighthouse audit, accessibility audit (WCAG)

### 9.3 SaaS

**Quy trình đặc thù:**
- GĐ2: multi-tenancy requirement, pricing tiers
- GĐ4: tenant isolation strategy (shared DB vs schema vs DB per tenant)
- GĐ5: data privacy, GDPR/CCPA, SOC2
- GĐ7: billing integration (Stripe), subscription state machine, RBAC
- GĐ14 Part B: penetration testing, compliance checklist
- GĐ17: SLA definition, uptime monitoring, incident response

**Lưu ý:** cần `onboarding flow`, `usage metering`, `feature flags`, `audit log`.

### 9.4 Tool (CLI / Library / Plugin)

**Quy trình đặc thù:**
- GĐ4: distribution (npm/pip/brew/binary), target audience (dev vs end-user)
- GĐ7: CLI UX (flags, help, error messages), plugin architecture
- GĐ9: versioning strategy (semver), changelog automation
- GĐ12: cross-platform testing (macOS/Linux/Windows)
- GĐ16: package registry publish, README quality

---

## 10. TESTING STRATEGY

| Level | Tool ví dụ | Khi nào |
|-------|-----------|---------|
| **Unit** | Jest, Vitest, pytest, JUnit | Logic thuần, utility |
| **Integration** | Supertest, TestContainers | API endpoint, DB query |
| **E2E** | Playwright, Cypress, Detox (mobile) | Critical user flow |
| **Contract** | Pact | Microservices API compatibility |
| **Performance** | k6, Locust, Artillery | Trước release (GĐ14) |
| **Security** | OWASP ZAP, Snyk, Trivy | GĐ5 + GĐ14 Part B |
| **Visual** | Percy, Chromatic | UI regression |

---

## Cách Agent sử dụng file này

1. **GĐ3:** Đọc file này → lọc theo `project.type` và `project.size` → sinh 2–3 phương án cho mỗi nhóm quyết định (platform, architecture, tech-stack) → ghi vào `options/`.
2. **GĐ4:** Trình người dùng menu phương án (có ✅ KHUYẾN NGHỊ dựa trên size+type+constraints) → người chọn → ghi ADR.
3. **GĐ7 (BLUEPRINT):** Tra lại file này để đảm bảo thiết kế bám đúng pattern đã chọn.

> Nguồn tham khảo: tổng hợp từ nghiên cứu 2025–2026 về enterprise architecture patterns,
> mobile architecture, concurrency patterns, và load balancing strategies.
> Content was rephrased for compliance with licensing restrictions.
