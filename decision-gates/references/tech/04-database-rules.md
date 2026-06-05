# 04 — LUẬT DATABASE & DATA (Bắt buộc)

> ĐÂY LÀ LUẬT. Vi phạm = finding GĐ14 Part A/B.

---

## NGUYÊN TẮC BẤT BIẾN

1. **Database là TRÁI TIM. Chọn sai = chết toàn dự án.** Mất data = mất khách hàng.
2. **Schema thiết kế TRƯỚC khi code.** Không "tạo bảng khi cần".
3. **Migration là code. PHẢI version, PHẢI review, PHẢI reversible.**
4. **Backup là BẮT BUỘC, không phải "sẽ làm sau".**
5. **KHÔNG bao giờ query trực tiếp từ UI/Controller.** Qua Repository/DAO layer.

---

## BẢNG BẮT BUỘC: Bài toán → Loại Database

| Bài toán | Database BẮT BUỘC | CẤM dùng |
|----------|-------------------|----------|
| Structured data + complex join + ACID | PostgreSQL / MySQL | MongoDB, Redis |
| User session, cache, leaderboard | Redis / Memcached | PostgreSQL |
| Document flexible schema, rapid prototype | MongoDB / Firestore | — |
| Full-text search, log analytics | Elasticsearch / Meilisearch | PostgreSQL LIKE query |
| Time-series (metrics, IoT) | TimescaleDB / InfluxDB / ClickHouse | MongoDB |
| Graph (social, recommendation) | Neo4j / ArangoDB | Relational JOIN hell |
| AI embedding / similarity search | pgvector / Pinecone / Qdrant | Full-text search engine |
| Key-value extreme scale | DynamoDB / Redis | PostgreSQL cho hot key |
| Event store / audit log | Kafka + PostgreSQL / EventStoreDB | Mutable tables |

### MẶC ĐỊNH: PostgreSQL. Chỉ đổi khi có lý do cụ thể (bắt buộc ADR).

---

## LUẬT SCHEMA DESIGN (Relational)

### Naming

| Đối tượng | Quy tắc | Ví dụ đúng | Ví dụ sai |
|-----------|---------|------------|-----------|
| Table | snake_case, plural | `users`, `order_items` | `User`, `tbl_users` |
| Column | snake_case, rõ nghĩa | `created_at`, `total_amount` | `ca`, `amt` |
| Primary Key | `id` (UUID/BIGINT) | `id` | `user_id` cho PK |
| Foreign Key | `<singular>_id` | `user_id`, `order_id` | `fk_user`, `uid` |
| Index | `idx_<table>_<columns>` | `idx_users_email` | `index1` |
| Boolean | is_/has_ prefix | `is_active`, `has_verified` | `active` |
| Timestamp | `_at` suffix | `created_at`, `deleted_at` | `creation_date` |

### Bắt buộc mọi bảng

```sql
id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
-- Soft delete (nếu cần): deleted_at TIMESTAMPTZ NULL
```

### Quan hệ

- FK PHẢI có constraint (ON DELETE CASCADE/SET NULL/RESTRICT — chọn rõ).
- Many-to-many: bảng join riêng. KHÔNG array column cho relational data.
- JSON column CHỈ cho metadata linh hoạt. KHÔNG cho data cần query thường xuyên.

### Index

- PHẢI index mọi FK column.
- PHẢI index column trong WHERE/ORDER BY/JOIN thường xuyên.
- Composite index: selectivity cao → thấp.
- UNIQUE constraint cho business unique (email, slug).
- KHÔNG index mọi thứ (write overhead).

---

## LUẬT MIGRATION

- Mỗi thay đổi = 1 file migration có timestamp.
- PHẢI có UP + DOWN (reversible).
- Destructive change (DROP/RENAME): dùng expand-contract pattern.
- Migration PHẢI idempotent (IF NOT EXISTS).
- KHÔNG business logic trong migration.
- Large migration (>1M rows): batch + background job.

---

## LUẬT QUERY

- KHÔNG N+1. BẮT BUỘC eager load / join / batch.
- PHẢI pagination. KHÔNG unlimited SELECT.
- KHÔNG SELECT *. Chỉ column cần.
- Parameterized query ONLY. CẤM string concat.
- Slow query > 100ms = WARN, > 1s = PHẢI optimize.
- Connection pool bắt buộc.

---

## LUẬT BACKUP

| Quy mô | Backup | RPO | RTO |
|--------|--------|-----|-----|
| personal | Daily auto | < 24h | < 4h |
| small | Daily + PITR | < 1h | < 1h |
| super-large | Continuous + cross-region | < 5min | < 15min |

- Test restore MỖI THÁNG.
- Backup encrypted + region khác primary.

---

## LUẬT MULTI-TENANCY (SaaS)

| Strategy | Isolation | Cost | Khi dùng |
|----------|-----------|------|----------|
| Shared DB + tenant_id + RLS | Thấp | Thấp | personal, small |
| Schema per tenant | Trung bình | Trung bình | small → super-large |
| DB per tenant | Cao nhất | Cao | super-large enterprise |

- Mọi query PHẢI filter tenant_id (Row-Level Security ở DB, KHÔNG chỉ app).
- Tenant A KHÔNG BAO GIỜ đọc data tenant B.
- 1 tenant nặng KHÔNG ảnh hưởng tenant khác.

---

## LUẬT CACHE (Redis)

- KHÔNG dùng Redis làm primary store.
- Key format: `<app>:<entity>:<id>`.
- TTL bắt buộc mọi key. KHÔNG sống vĩnh viễn.
- Cache stampede protection (mutex / early expiration).
- Flush cache khi deploy schema change.

---

## LUẬT VALIDATION

- Validate ở boundary (API input). Reject sớm.
- DB constraint là last defense.
- NOT NULL cho mọi column không thể null.
- CHECK constraint cho business rule đơn giản.
