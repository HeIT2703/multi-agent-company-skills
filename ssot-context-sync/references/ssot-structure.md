# Cấu trúc SSOT `.context/` đầy đủ

## Quy ước đặt tên (chốt cứng)

- Tất cả file & thư mục: **kebab-case** (chữ thường, gạch ngang). Không underscore, không viết hoa.
- `backend` / `frontend` / `database` (một từ chuẩn ngành).
- File máy đọc: `.yaml`; file người + agent đọc: `.md`.
- ADR đánh số 4 chữ số: `ADR-0001-...`.

## Chuẩn front-matter (mỗi file `.md` mở đầu bằng khối này)

```yaml
---
id: project.api-contract        # định danh duy nhất
layer: L1                       # L0/L1/L2/L3
owner: architect                # ai chịu trách nhiệm
writers: [architect]            # ai ĐƯỢC ghi
readers: [backend, frontend, qa]
status: draft | review | approved | deprecated
version: 1.0.0
updated: 2026-06-05
canonical: true                 # đây có phải bản gốc không?
related: [docs/backend/interface.md]
---
```

## Cây thư mục

```
.context/
├── manifest.yaml                # bản đồ toàn bộ SSOT, agent ĐỌC ĐẦU TIÊN
├── README.md
├── global/                      # L0
│   ├── coding-standards.md
│   ├── conventions.md
│   ├── definition-of-ready.md
│   ├── definition-of-done.md
│   ├── context-protocol.md
│   └── tech-radar.md
├── project/                     # L1 — canonical
│   ├── project-profile.yaml
│   ├── state.yaml
│   ├── vision.md
│   ├── requirements.md
│   ├── architecture.md
│   ├── data-model.md
│   ├── api-contract.md
│   ├── design-system.md
│   ├── glossary.md
│   └── risks.md
├── docs/                        # L1 — chi tiết theo phòng ban
│   ├── main-design.md
│   ├── backend/   { main-design.md, tech-stack.md, interface.md, skills.md }
│   ├── frontend/  { main-design.md, tech-stack.md, interface.md, skills.md }
│   └── database/  { main-design.md, tech-stack.md, interface.md, schema.md, skills.md }
├── agents/                      # charter từng agent (RBAC)
│   ├── orchestrator.md, product.md, architect.md
│   ├── backend-engineer.md, frontend-engineer.md, database-engineer.md
│   ├── qa.md, auditor.md, reconciliation.md
├── stages/                      # L2 — 13 giai đoạn, mỗi cái có gate.md
│   ├── 01-ideation-research/ ... 09-integration-staging/
│   ├── 10-deep-audit/ { gate.md }
│   ├── 11-remediation-upgrade/ { gate.md, tasks.md, upgrade-plan.md }
│   ├── 12-production-operations/, 13-final-release/
├── audits/                      # lịch sử audit-run (scorecard + 3 part + findings)
├── decisions/                   # ADR + README index
├── sessions/                    # L3 — log thô (append-only)
├── knowledge/                   # bộ nhớ dài hạn đã chưng cất
├── templates/                   # mẫu artifact
├── schemas/                     # JSON Schema cho file máy đọc
├── scripts/                     # tooling write-back
├── progress.md
└── changelog.md
```

> File tích hợp harness (`.cursorrules`, `.cursorignore`, `.vscode/settings.json`...) nằm
> ở **gốc repo, ngoài `.context/`** để giữ SSOT harness-agnostic — xem skill `harness-integration`.
