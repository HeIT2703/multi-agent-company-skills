# Blueprint: Quy trình "Công ty AI" Multi-Agent — 18 Giai đoạn

> Tài liệu thiết kế tổng hợp cho hệ thống nhiều Agent / nhiều harness vận hành như một
> công ty phần mềm thật. Mục tiêu: mọi giai đoạn trơn tru, **context luôn đồng bộ**,
> pha thiết kế là viên ngọc **chặt chẽ nhất, rộng nhất, sâu nhất, bao quát nhất** — và
> sản phẩm đạt 10/10 có bằng chứng.

- **Phiên bản:** 2.0
- **Cập nhật:** 2026-06-05
- **Phạm vi:** 3 quy mô × 4 loại × 2 chế độ (interactive / autonomous)
- **Thay đổi v2.0:** nâng từ 13 → 18 giai đoạn; thêm Discover⇄Decide lặp; pha BLUEPRINT
  (GĐ7–9) là viên ngọc chặt chẽ nhất; thêm Threat Model, Prototype/Spike, Scaffolding,
  Release-readiness; cơ chế human-checkpoint; decision_mode interactive/autonomous.

---

## Mục lục

0. [Triết lý nền tảng](#0-triết-lý-nền-tảng)
1. [Pipeline 18 giai đoạn (6 pha × 3)](#1-pipeline-18-giai-đoạn)
2. [Vòng lặp Discover ⇄ Decide](#2-vòng-lặp-discover--decide)
3. [Pha BLUEPRINT — viên ngọc của pipeline](#3-pha-blueprint--viên-ngọc-của-pipeline)
4. [Ma trận co giãn: quy mô × loại](#4-ma-trận-co-giãn)
5. [Kiến trúc đồng bộ Context](#5-kiến-trúc-đồng-bộ-context)
6. [Mô hình điều phối Multi-Agent](#6-mô-hình-điều-phối-multi-agent)
7. [Cổng chất lượng & Human-Checkpoint](#7-cổng-chất-lượng--human-checkpoint)
8. [GĐ14 — Audit sâu 3 phần](#8-gđ14--audit-sâu-3-phần)
9. [GĐ15 — Khắc phục & vòng lặp 10/10](#9-gđ15--khắc-phục--vòng-lặp-1010)
10. [Cấu trúc SSOT `.context/`](#10-cấu-trúc-ssot-context)
11. [Lớp tích hợp Harness/IDE](#11-lớp-tích-hợp-harnesside)
12. [Sổ rủi ro nền tảng (ADR)](#12-sổ-rủi-ro-nền-tảng)
13. [Các schema máy đọc](#13-các-schema-máy-đọc)
14. [Checklist khởi động](#14-checklist-khởi-động)

---

## 0. Triết lý nền tảng

1. **SSOT** — "Nếu nó không nằm trong `.context/`, nó không tồn tại."
2. **Quality Gate + Human-Checkpoint** — không qua cổng thì không đi tiếp; quyết định sống còn phải có người duyệt.
3. **Handoff Contract** — agent sau chỉ cần đọc artifact.
4. **Discover ⇄ Decide là vòng lặp** — AI nghiên cứu + hỏi người dùng *song song*, quyết định xong lại mở câu hỏi mới → lặp đến khi hội tụ.
5. **Pha BLUEPRINT là viên ngọc** — kiến trúc, rule, khái niệm, bản vẽ phải chặt/rộng/sâu/bao quát/đúng ý người dùng NHẤT trước khi code.

---

## 1. Pipeline 18 giai đoạn

6 pha × 3 giai đoạn. Mô hình dễ nhớ: **DISCOVER → DECIDE → BLUEPRINT → BUILD → VERIFY → LAUNCH**.

| # | Giai đoạn | Pha | Agent chủ trì | Loại cổng |
|---|-----------|-----|---------------|-----------|
| 1 | Ý tưởng & Nghiên cứu thị trường | **DISCOVER** | Research + Product | quality-gate |
| 2 | Thu thập Yêu cầu người dùng | DISCOVER | Product 🧑 | **human-checkpoint** (phỏng vấn) |
| 3 | Phân tích Khả thi & Sinh phương án | DISCOVER | Architect | quality-gate |
| 4 | **Định hình & Quyết định** (platform, arch, tech, priority) | **DECIDE** | Orchestrator 🧑 | **human-checkpoint** |
| 5 | Mô hình hóa Rủi ro & Mối đe dọa | DECIDE | Security | quality-gate |
| 6 | Prototype & Spike (validate giả định) | DECIDE | Engineering | quality-gate |
| 7 | Thiết kế Kiến trúc & Dữ liệu | **BLUEPRINT** ⭐ | Architect | quality-gate (nghiêm nhất) |
| 8 | Thiết kế UX/UI & Design System | BLUEPRINT ⭐ | Design | quality-gate (nghiêm nhất) |
| 9 | Lập kế hoạch, Phân rã & Quy tắc | BLUEPRINT ⭐ | PM + Tech Lead | quality-gate (nghiêm nhất) |
| 10 | Môi trường & Scaffolding | **BUILD** | DevOps | quality-gate |
| 11 | Phát triển / Code | BUILD | Engineering (FE/BE/DB) | quality-gate |
| 12 | Kiểm thử & QA | BUILD | QA | quality-gate |
| 13 | Tích hợp & Staging | **VERIFY & HARDEN** | DevOps | quality-gate |
| 14 | 🔍 Audit sâu (3 phần) | VERIFY & HARDEN | Auditor (độc lập) | quality-gate |
| 15 | 🔧 Khắc phục & Nâng cấp ⟲ | VERIFY & HARDEN | Engineering + Architect | quality-gate |
| 16 | Sẵn sàng Ra mắt (UAT, go/no-go) | **LAUNCH & EVOLVE** | Release Manager 🧑 | **human-checkpoint** |
| 17 | Production & Vận hành | LAUNCH & EVOLVE | SRE | quality-gate |
| 18 | Retrospective, 10/10 & Cải tiến | LAUNCH & EVOLVE | Orchestrator | quality-gate → ↩ GĐ1 |

**3 điểm dừng-chờ-người (🧑):** GĐ2 (lấy yêu cầu), GĐ4 (chọn hướng), GĐ16 (duyệt ra mắt).

---

## 2. Vòng lặp Discover ⇄ Decide

Pha DISCOVER (GĐ1–3) và DECIDE (GĐ4–6) **KHÔNG tuyến tính thuần**. Chúng tạo thành một
vòng lặp hội tụ (convergence loop):

```
                    ┌─────────────────────────────────────────────┐
                    │                                             │
    GĐ1 Nghiên cứu ──► GĐ2 Hỏi người dùng ──► GĐ3 Sinh phương án
                    │         🧑                       │
                    │                                  ▼
                    │         GĐ4 Quyết định 🧑 ◄──────┘
                    │              │
                    │         ┌────┴────┐
                    │    HỘI TỤ?    CHƯA HỘI TỤ
                    │         │         │
                    │         ▼         └──────► Quay lại GĐ1–3 (câu hỏi mới)
                    │    GĐ5 Threat Model
                    │         ▼
                    │    GĐ6 Prototype/Spike
                    │         │
                    │    ┌────┴────┐
                    │  ĐẠT?    KHÔNG ĐẠT (giả định sai)
                    │    │         └──────► Quay lại GĐ3–4 (phương án khác)
                    │    ▼
                    └─► sang pha BLUEPRINT (GĐ7)
```

**"Hội tụ" nghĩa là:**
- Người dùng đã confirm quyết định (platform, arch, tech, priority) — GĐ4 PASS.
- Spike validate thành công giả định rủi ro cao nhất — GĐ6 PASS.
- Mọi unknowns đã trở thành knowns (hoặc accepted-risk kèm ADR).

**Cách triển khai trong `state.yaml`:**
```yaml
current_stage: 04-shaping-decisions
discover_decide_iteration: 2    # đang lặp lần 2
convergence: false              # chưa hội tụ
```

**Giới hạn lặp (chống infinite loop):**
- `max_discover_decide_loops: 3` (trong `project-profile.yaml`).
- Chạm trần → `escalate_to_human` (bắt buộc người quyết).

---

## 3. Pha BLUEPRINT — viên ngọc của pipeline

> **"Đo 7 lần, cắt 1 lần."** Pha BLUEPRINT (GĐ7–9) phải tạo ra bộ tài liệu thiết kế
> **chặt chẽ nhất, rộng nhất, sâu nhất, bao quát nhất, đúng ý người dùng nhất, và
> nghiêm túc nhất** trong toàn bộ vòng đời. Không một dòng code nào được viết trước khi
> pha này PASS với tiêu chuẩn CAO NHẤT.

### Tại sao pha BLUEPRINT phải là viên ngọc

- Sửa lỗi *thiết kế* ở pha BUILD tốn **10×** sửa ở pha BLUEPRINT.
- Agent viết code **chỉ tốt bằng bản vẽ chúng nhận được**. Bản vẽ mơ hồ = code rác.
- BLUEPRINT là **hợp đồng** giữa tất cả phòng ban (BE, FE, DB, QA, Security, UX) — ai cũng đọc cùng một sự thật.

### GĐ7 — Thiết kế Kiến trúc & Dữ liệu

**Agent:** Architect (+ review bởi Security từ GĐ5)
**Đầu ra (canonical, SSOT):**

| Artifact | Nội dung | Yêu cầu chất lượng |
|----------|----------|---------------------|
| `project/architecture.md` | Kiến trúc tổng: component, boundary, communication, deployment | Phải cover MỌI requirement từ GĐ2; phải bám quyết định GĐ4 (platform/arch) |
| `project/data-model.md` | Thực thể logic + quan hệ + ràng buộc | Phải ánh xạ 1:1 với domain trong `glossary.md` |
| `project/api-contract.md` | Endpoint, shape, version, auth, error contract | Spec đủ để FE/BE code **độc lập** mà không cần hỏi nhau |
| `docs/*/main-design.md` | Thiết kế chi tiết từng phòng ban (BE/FE/DB) | Cách **hiện thực** quyết định kiến trúc |
| `decisions/ADR-*` | Quyết định kiến trúc lớn (vì sao, đánh đổi, hệ quả) | Mọi "vì sao" phải có ADR |
| `project/glossary.md` | Cập nhật thuật ngữ (đảm bảo mọi concept có tên chính xác) | Mỗi thuật ngữ = 1 định nghĩa, không mập mờ |

### GĐ8 — Thiết kế UX/UI & Design System

**Agent:** Design
**Đầu ra:**

| Artifact | Nội dung | Yêu cầu chất lượng |
|----------|----------|---------------------|
| `project/design-system.md` | Màu, typography, spacing, component, accessibility standard | Bao quát mọi screen; tuân thủ WCAG 2.1 AA |
| `ux-flows.md` | User flow toàn bộ | Mỗi requirement phải map tới ≥1 flow |
| `wireframes/` | Wireframe/prototype | |

### GĐ9 — Lập kế hoạch, Phân rã & Quy tắc

**Agent:** PM + Tech Lead
**Đây là giai đoạn "đóng gói bản vẽ thành kế hoạch chiến đấu":**

| Artifact | Nội dung | Yêu cầu chất lượng |
|----------|----------|---------------------|
| `stages/11-development/tasks.md` | Task phân rã, mỗi task có tiêu chí nghiệm thu + owner | Không task nào > 1 phiên agent |
| `milestones.md` | Cột mốc + deadline | |
| `dependencies.md` | Phụ thuộc giữa task/phòng ban | Đã xử lý circular dependencies |
| `global/coding-standards.md` | Cập nhật chuẩn code, lint, format (bám tech đã chọn) | |
| `global/conventions.md` | Naming, git flow, branch, commit | |
| `project/risks.md` | Sổ rủi ro đầy đủ (kế thừa GĐ5 + bổ sung rủi ro kế hoạch) | Mỗi risk có owner + mitigation |

### Cổng BLUEPRINT (nghiêm nhất trong pipeline)

Gate GĐ9 → GĐ10 là **cổng khắt khe nhất**. Tiêu chí:

- ✅ `architecture.md` cover 100% requirements.
- ✅ `api-contract.md` đủ chi tiết để FE/BE code **không cần hỏi** nhau.
- ✅ `data-model.md` không mâu thuẫn `api-contract.md`.
- ✅ `glossary.md` thống nhất — `reconciliation` agent đối soát cross-reference.
- ✅ `design-system.md` cover mọi flow.
- ✅ Mọi task có tiêu chí nghiệm thu rõ ràng.
- ✅ `risks.md` không còn risk "unowned".
- ✅ Mọi quyết định lớn có ADR.

> Nếu không đạt → **QUAY LẠI** pha BLUEPRINT. Không bao giờ "cho qua vì deadline".

---

## 4. Ma trận co giãn

| Quy mô | Số GĐ thực chạy | Co thế nào |
|--------|-----------------|------------|
| **super-large** | **18 (full)** | Mọi GĐ, mọi human-checkpoint, vòng lặp Discover⇄Decide đầy đủ |
| **small** | ~12–13 | Bỏ/gọn GĐ5 (threat nhẹ), GĐ6 (spike nếu rủi ro thấp); gộp GĐ7–9 |
| **personal** + fast-track | ~6–7 | Gộp DISCOVER+DECIDE thành 1–2 phiên; BLUEPRINT gọn; giữ BUILD+VERIFY+LAUNCH |

```yaml
# project-profile.yaml
stages:
  total: 18
  human_checkpoints: [2, 4, 16]
  skip_if_low_risk: [5, 6]
  merge_for_personal: { "1-6": "discover-decide-combined", "7-9": "blueprint-lite" }
  max_discover_decide_loops: 3
```

---

## 5. Kiến trúc đồng bộ Context

*(Giữ nguyên từ v1.1 — 4 lớp L0–L3 + giao thức Hydrate→Write-back + đồng bộ 2 chiều + kỷ luật YAML + single-writer. Xem chi tiết trong skill `ssot-context-sync`.)*

Bổ sung:
- **Lớp DISCOVER⇄DECIDE** tạo artifact `options/` (phương án) + `decisions/` (ADR phê duyệt). Agent có thể tạo nhiều phương án trong `options/`, con người chọn, phương án thắng → ADR.
- **Lớp BLUEPRINT** tạo artifact *chặt nhất* trong SSOT — các file canonical phải pass validation schema TRƯỚC khi được approve.

---

## 6. Mô hình điều phối Multi-Agent

```
                         ┌──────────────────┐
                         │   ORCHESTRATOR    │  ← serial hóa state,
                         │                   │     mở/đóng cổng, escalate
                         └────────┬─────────┘
     ┌─────────┬─────────┬───────┼────────┬──────────┬──────────┐
     ▼         ▼         ▼       ▼        ▼          ▼          ▼
┌────────┐┌────────┐┌──────┐┌────────┐┌──────┐┌─────────┐┌──────────┐
│Research││Product ││Archit││Engineer││Design││   QA    ││ Security │
│        ││  (PM)  ││ -ect ││FE/BE/DB││      ││         ││          │
└────────┘└────────┘└──────┘└────────┘└──────┘└─────────┘└──────────┘
                                                   + Auditor(độc lập)
                                                   + Reconciliation
                                                   + Release Manager
```

11 vai trò agent (thêm `security`, `release-manager` so với v1.1).

---

## 7. Cổng chất lượng & Human-Checkpoint

Hai loại cổng:

| Loại | Ai quyết PASS/BLOCKED | Khi nào |
|------|-----------------------|---------|
| **quality-gate** | Agent (Orchestrator) tự kiểm DoR/DoD bằng artifact | Giữa hầu hết GĐ |
| **human-checkpoint** 🧑 | Agent đề xuất → **CON NGƯỜI chốt** | GĐ2 (yêu cầu), GĐ4 (quyết định), GĐ16 (duyệt release) |

Cơ chế human-checkpoint:
- Agent trình bày dạng **menu có đề xuất mặc định** (vd "Khuyến nghị: Web SSR + Modular monolith + Next.js").
- `decision_mode: interactive` → dừng, chờ người chọn.
- `decision_mode: autonomous` → tự chọn đề xuất mặc định, ghi ADR (`decided_by: agent`), chạy tiếp.

---

## 8. GĐ14 — Audit sâu 3 phần

*(Giữ nguyên v1.1 — Part A/B/C, isolate_parts, scorecard, findings. Xem skill `deep-audit`.)*

---

## 9. GĐ15 — Khắc phục & vòng lặp 10/10

*(Giữ nguyên v1.1 — vòng fix→re-audit, circuit-breaker max_remediation_loops, escalate. Xem skill `deep-audit`.)*

---

## 10. Cấu trúc SSOT `.context/`

```
.context/
├── manifest.yaml
├── README.md
├── global/                      # L0
│   ├── coding-standards.md
│   ├── conventions.md
│   ├── definition-of-ready.md
│   ├── definition-of-done.md
│   ├── context-protocol.md
│   └── tech-radar.md
├── project/                     # L1 canonical
│   ├── project-profile.yaml
│   ├── state.yaml
│   ├── vision.md
│   ├── requirements.md
│   ├── architecture.md
│   ├── data-model.md
│   ├── api-contract.md
│   ├── design-system.md
│   ├── glossary.md
│   ├── risks.md
│   └── threat-model.md         # MỚI (GĐ5)
├── options/                     # MỚI — phương án GĐ3–4 (Discover⇄Decide)
│   ├── platform-options.md
│   ├── architecture-options.md
│   ├── tech-stack-options.md
│   └── priority-matrix.md
├── docs/                        # L1 chi tiết
│   ├── main-design.md
│   ├── backend/ frontend/ database/
├── agents/                      # 11 charter
├── stages/                      # 18 giai đoạn
│   ├── 01-ideation-research/ ... 18-retrospective-final/
├── audits/
├── decisions/
├── sessions/
├── knowledge/
├── templates/
├── schemas/
├── scripts/
├── progress.md
└── changelog.md
```

Thư mục mới: `options/` — nơi agent sinh phương án (Diverge) và con người chọn (Decide); phương án thắng → copy essence vào `decisions/ADR-*` + `project-profile.yaml`.

---

## 11. Lớp tích hợp Harness/IDE

*(Giữ nguyên v1.1 — entry-point, vệ sinh RAG, JSON Schema, tooling CLI. Xem skill `harness-integration`.)*

---

## 12. Sổ rủi ro nền tảng

*(Giữ nguyên: ADR-0002 vòng lặp vô tận, ADR-0003 tràn context auditor, ADR-0004 tranh chấp ghi.)*

**Thêm:**

### 🔴 ADR-0005 — Vòng lặp Discover⇄Decide vô tận
- **Rủi ro:** AI cứ sinh phương án mới → người dùng cứ thay đổi ý kiến → không bao giờ hội tụ.
- **Mitigation:** `max_discover_decide_loops: 3` → chạm trần buộc phải chốt (escalate hoặc chọn default).

---

## 13. Các schema máy đọc

### `project-profile.yaml` (v2.0)

```yaml
project:
  name: "Tên dự án"
  size: super-large
  type: saas
  platform: []                  # chọn ở GĐ4: [web-ssr, mobile-cross, desktop-electron...]
  decision_mode: interactive    # interactive | autonomous

execution:
  allow_fast_track: false
  max_remediation_loops: 3
  max_discover_decide_loops: 3
  escalate_to_human: true
  parallel_agents: true

stages:
  total: 18
  human_checkpoints: [2, 4, 16]
  skip_if_low_risk: [5, 6]
  merge_for_personal: { "1-6": "discover-decide-combined", "7-9": "blueprint-lite" }

audit:
  threshold_composite:
    super-large: 9.5
    small: 8.5
    personal: 8.0
  block_on:
    super-large: [critical, high]
    small: [critical, high]
    personal: [critical]
  parts_required:
    super-large: [A, B, C]
    small: [A, B, C]
    personal: [A, C]
  isolate_parts: true
```

### `state.yaml` (v2.0)

```yaml
current_stage: 04-shaping-decisions
status: in-progress
active_agents: [orchestrator, product]
last_gate_passed: 03-feasibility-options
discover_decide_iteration: 2
convergence: false
remediation_loops: 0
escalated: false
updated: 2026-06-05
```

---

## 14. Checklist khởi động

**Bước 0:** Tạo entry-point harness + `.cursorignore` (xem skill `harness-integration`).

1. `glossary.md` + `project-profile.yaml` (khai báo size/type/platform/decision_mode).
2. `context-protocol.md` (Hydrate→Write-back + kỷ luật YAML).
3. `manifest.yaml` + `agents/` charters.
4. Bắt đầu **vòng lặp Discover⇄Decide** từ GĐ1.

---

### Tóm tắt một dòng

> **18 giai đoạn (6 pha × 3) với vòng lặp Discover⇄Decide hội tụ + pha BLUEPRINT là viên ngọc chặt/rộng/sâu/bao quát nhất + audit 3 phần + circuit-breaker**, chạy trên SSOT `.context/` harness-agnostic với human-checkpoint ở 3 điểm quyết định sống còn — để nhiều agent làm việc như một công ty thật, luôn đúng ý người dùng, và sản phẩm đạt 10/10 có bằng chứng.
