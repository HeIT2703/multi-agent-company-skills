# Blueprint: Quy trình "Công ty AI" Multi-Agent — 13 Giai đoạn

> Tài liệu thiết kế tổng hợp cho hệ thống nhiều Agent / nhiều harness vận hành như một công ty phần mềm thật.
> Mục tiêu: mọi giai đoạn trơn tru, **context luôn đồng bộ** giữa các phòng ban, giữa các lần chạy, và tài liệu luôn sống cùng code.

- **Phiên bản:** 1.1
- **Cập nhật:** 2026-06-05
- **Phạm vi:** 3 quy mô (siêu lớn / nhỏ / cá nhân) × 4 loại (application / web / saas / tool)
- **Thay đổi v1.1:** thêm Lớp tích hợp Harness/IDE, kỷ luật ghi YAML + tooling CLI, vệ sinh RAG, fast-track, và 3 rủi ro nền tảng (vòng lặp audit, tràn context auditor, tranh chấp ghi).

---

## Mục lục

0. [Triết lý nền tảng](#0-triết-lý-nền-tảng)
1. [Pipeline 13 giai đoạn](#1-pipeline-13-giai-đoạn)
2. [Ma trận co giãn: quy mô × loại](#2-ma-trận-co-giãn-quy-mô--loại)
3. [Kiến trúc đồng bộ Context (trái tim hệ thống)](#3-kiến-trúc-đồng-bộ-context-trái-tim-hệ-thống)
4. [Mô hình điều phối Multi-Agent](#4-mô-hình-điều-phối-multi-agent)
5. [Cổng chất lượng (Quality Gate)](#5-cổng-chất-lượng-quality-gate)
6. [Giai đoạn 10 — Audit sâu 3 phần](#6-giai-đoạn-10--audit-sâu-3-phần)
7. [Giai đoạn 11 — Khắc phục & Nâng cấp + vòng lặp 10/10](#7-giai-đoạn-11--khắc-phục--nâng-cấp--vòng-lặp-1010)
8. [Cấu trúc SSOT (`.context/`)](#8-cấu-trúc-ssot-context)
9. [Các schema máy đọc](#9-các-schema-máy-đọc)
10. [Lớp tích hợp Harness/IDE](#10-lớp-tích-hợp-harnesside)
11. [Sổ rủi ro nền tảng (ADR bắt buộc)](#11-sổ-rủi-ro-nền-tảng-adr-bắt-buộc)
12. [Checklist khởi động](#12-checklist-khởi-động)

---

## 0. Triết lý nền tảng

Một công ty trơn tru không nhờ "người giỏi", mà nhờ **3 thứ bất biến**:

1. **Single Source of Truth (SSOT)** — một nguồn sự thật duy nhất. Mọi agent đọc từ đó, ghi vào đó. Không tồn tại "context trong đầu" của riêng agent nào.
2. **Quality Gate** giữa các giai đoạn — không qua cổng thì không đi tiếp. Đây là thứ làm quy trình suôn sẻ.
3. **Handoff Contract** — mỗi giai đoạn nhận đầu vào chuẩn, trả đầu ra chuẩn. Agent sau không cần "hiểu" agent trước, chỉ cần đọc artifact.

> **Châm ngôn vận hành:** *"Nếu nó không nằm trong SSOT, nó không tồn tại."*

---

## 1. Pipeline 13 giai đoạn

Chia 5 nhóm để agent dễ định vị: **Conceive → Design → Build → Verify & Harden → Launch & Evolve**.

| # | Giai đoạn | Nhóm | Agent chủ trì | Artifact gốc |
|---|-----------|------|---------------|--------------|
| 1 | Ý tưởng & Nghiên cứu | Conceive | Research + Product | `vision.md`, `research.md` |
| 2 | Yêu cầu & Phạm vi | Conceive | Product (PM) | `requirements.md`, `scope.md` |
| 3 | Khả thi & Chiến lược kỹ thuật | Conceive | Architect | `feasibility.md`, `tech-strategy.md`, `risks.md` |
| 4 | Thiết kế hệ thống & Kiến trúc | Design | Architect | `architecture.md`, `data-model.md`, `api-contract.md`, ADR |
| 5 | Thiết kế UX/UI | Design | Design | `design-system.md`, `ux-flows.md` |
| 6 | Lập kế hoạch & Phân rã | Design | PM + Tech Lead | `tasks.md`, `milestones.md`, `dependencies.md` |
| 7 | Phát triển / Code | Build | Engineering (FE/BE/DB) | `code`, ADR, write-back spec, `progress.md` |
| 8 | Kiểm thử & QA | Build | QA | `test-report.md`, `coverage.md`, `bugs.md` |
| 9 | Tích hợp & Staging | Verify & Harden | DevOps | `deploy.md`, môi trường staging |
| **10** | **🔍 AUDIT SÂU (3 phần)** | **Verify & Harden** | **Auditor (độc lập)** | `audits/<run>/...`, `scorecard.yaml`, `findings.yaml` |
| **11** | **🔧 KHẮC PHỤC & NÂNG CẤP** | **Verify & Harden** | **Engineering + Architect** | remediation `tasks.md`, `upgrade-plan.md` |
| 12 | Ra mắt Production & Vận hành | Launch & Evolve | SRE + Product | `release-notes.md`, `monitoring.md`, `runbook.md` |
| 13 | Sản phẩm hoàn chỉnh (10/10) & Cải tiến | Launch & Evolve | CEO / Orchestrator | `retrospective.md`, `backlog-next.md` |

**Hai điểm khóa quan trọng:**

- GĐ 1 là điểm bắt đầu (nạp ý tưởng, nghiên cứu); GĐ 13 là sản phẩm 10/10.
- **GĐ 13 chỉ được tuyên bố "10/10" khi scorecard của GĐ 10 (sau re-audit) đạt ngưỡng.** 10/10 không còn là cảm tính — nó là một con số có bằng chứng.
- GĐ 13 **không phải điểm kết thúc** mà là điểm khép vòng: feedback nuôi lại GĐ 1 cho phiên bản sau.

---

## 2. Ma trận co giãn: quy mô × loại

Cùng **một** pipeline 13 giai đoạn, nhưng "trọng số" và độ nghiêm của cổng thay đổi theo cấu hình. Một file `project-profile.yaml` khai báo `size` + `type`, Orchestrator đọc và tự bật/tắt + đặt độ nghiêm từng cổng.

### Theo quy mô

| Quy mô | Đặc điểm | Cách chạy pipeline |
|--------|----------|--------------------|
| **Siêu lớn** (triệu user, đa quốc gia) | Multi-region, i18n/l10n, compliance | Mọi giai đoạn FULL. Bắt buộc ADR, security audit, load test. Cổng nghiêm ngặt nhất. |
| **Nhỏ** (trăm ngàn user, 1 quốc gia) | Một thị trường | GĐ 1–6 gọn, dồn lực 7–12. Bỏ multi-region, giữ security & monitoring cơ bản. |
| **Cá nhân** (profile/bio, ngàn user) | Nhẹ, nhanh | Gộp GĐ 1–3 thành 1 phiên ngắn; 4–6 nhẹ; dồn lực GĐ 7 + 12. Cổng nhẹ. |

### Theo loại

| Loại | Nhấn mạnh |
|------|-----------|
| **Application** | GĐ 4 (kiến trúc), 7, 8 (test chặt), client/offline state |
| **Web** | GĐ 5 (UX/UI), SEO, performance, responsive |
| **SaaS** | Multi-tenant, billing, auth/RBAC, SLA, GĐ 12 (vận hành) rất nặng |
| **Tool** | Gọn nhẹ, nhấn GĐ 7 + tài liệu sử dụng, ít GĐ 12 |

---

## 3. Kiến trúc đồng bộ Context (trái tim hệ thống)

Đây là phần quyết định thành/bại của một công ty multi-agent.

### 3.1. Bốn lớp context (xếp tầng, kế thừa từ trên xuống)

```
┌─────────────────────────────────────────────────┐
│  L0 — GLOBAL (toàn công ty, mọi dự án)            │
│  Chuẩn code, convention, giao thức, tech-radar     │
├─────────────────────────────────────────────────┤
│  L1 — PROJECT (sự thật gốc của dự án)              │
│  vision, requirements, architecture, glossary +     │
│  docs/ chi tiết theo phòng ban                      │
├─────────────────────────────────────────────────┤
│  L2 — STAGE (trạng thái từng giai đoạn)            │
│  input/output, gate (DoR/DoD)                       │
├─────────────────────────────────────────────────┤
│  L3 — SESSION/TASK (mỗi phiên / mỗi lần chạy)      │
│  việc đang làm, quyết định vừa ra, gì đã đổi        │
└─────────────────────────────────────────────────┘
```

Agent **luôn đọc từ trên xuống** (L0 → L3) khi bắt đầu, và **chỉ được ghi vào đúng lớp/quyền của mình**.
→ Giải bài toán "đồng bộ giữa phòng ban" (cùng đọc L0/L1) và "giữa các lần làm" (L3 lưu trạng thái cho phiên sau).

### 3.2. Giao thức bắt buộc với mọi agent: HYDRATE → VALIDATE → EXECUTE → WRITE-BACK

1. **HYDRATE (nạp context):** Đọc L0 → L1 → L2 → L3 + `progress.md` + ADR liên quan. Không bao giờ bắt đầu "từ trí nhớ".
2. **VALIDATE (đối chiếu):** Kiểm tra việc sắp làm có mâu thuẫn với `requirements.md` / `architecture.md` / `glossary.md` không. Mâu thuẫn → dừng, báo Orchestrator.
3. **EXECUTE (làm việc):** Thực thi task.
4. **WRITE-BACK (ghi lại — quan trọng nhất):**
   - Ghi log phiên vào `sessions/`.
   - Cập nhật `progress.md` (đang ở đâu, làm gì tiếp).
   - Quyết định kiến trúc/đánh đổi → tạo **ADR** mới.
   - Tài liệu sai/thiếu → **cập nhật ngược spec** (xem 3.3).
   - Ghi `changelog.md`.

### 3.3. Đồng bộ 2 chiều Spec ↔ Code (chống "tài liệu chết")

- **Spec → Code (xuôi):** GĐ 7 code dựa trên `requirements.md` + `api-contract.md`.
- **Code → Spec (ngược):** Khi engineer-agent buộc phải lệch khỏi thiết kế:
  1. Tạo `ADR` giải thích *vì sao lệch*.
  2. Cập nhật `architecture.md` / `api-contract.md` cho khớp thực tế.
  3. Đánh dấu `progress.md` để các phòng ban khác (QA, Design) thấy.
- **Cưỡng chế:** `reconciliation` agent chạy cuối mỗi giai đoạn code, so code thực tế với spec, phát hiện lệch → tạo task đồng bộ. Đây là "kiểm toán nội bộ" liên tục.

### 3.4. Kỷ luật ghi file máy đọc (chống vỡ YAML & tranh chấp)

LLM thường làm hỏng file `.yaml` khi write-back (bọc trong ```code fence```, thụt lề sai). Đây là lỗi *gãy parser* khiến mọi phiên sau đọc sai. Quy tắc bắt buộc (đưa vào `global/context-protocol.md`):

- **Ưu tiên ghi qua tooling, không sửa text trực tiếp.** Mọi cập nhật file máy đọc (`state.yaml`, `scorecard.yaml`, `findings.yaml`) phải đi qua script CLI có validation — ví dụ `scripts/update-state.sh 07-development done` — thay vì để LLM tự sửa text. Script đảm bảo YAML chuẩn 100%.
- Khi *buộc* phải ghi text YAML trực tiếp: **NGHIÊM CẤM** bọc nội dung trong code fence markdown; thụt lề **đúng 2 spaces**, không dùng tab.
- File máy đọc phải có **JSON Schema** đi kèm (xem §10.3) để IDE gạch đỏ ngay khi thiếu trường — agent tự thấy tự sửa, không cần Auditor.
- **Single-writer:** mỗi file máy đọc chỉ có **một** `owner` được ghi (theo front-matter `writers`). Log (`sessions/`, `changelog.md`) là **append-only** — agent chỉ nối thêm, không sửa dòng cũ → tránh tranh chấp ghi khi nhiều agent chạy song song. Ghi `state.yaml` được serial hóa qua Orchestrator.

---

## 4. Mô hình điều phối Multi-Agent

```
                    ┌──────────────────┐
                    │   ORCHESTRATOR    │  ← CEO ảo: điều phối,
                    │  (đọc profile,    │     mở/đóng cổng, xử lý
                    │   mở/đóng cổng)   │     xung đột
                    └────────┬─────────┘
        ┌──────────┬─────────┼──────────┬───────────┐
        ▼          ▼         ▼          ▼           ▼
   ┌────────┐ ┌────────┐ ┌──────┐ ┌────────┐ ┌─────────┐
   │Research│ │Product │ │Archit│ │Engineer│ │   QA    │
   │ Agent  │ │ (PM)   │ │ -ect │ │ FE/BE/DB│ │+Security│
   └────────┘ └────────┘ └──────┘ └────────┘ └─────────┘
        └──────────┴─── tất cả đọc/ghi qua SSOT (.context/) ───┘
                 + Auditor (độc lập) + Reconciliation
```

**Nguyên tắc điều phối:**

- Agent **không nói chuyện trực tiếp** với nhau (tránh tam sao thất bản). Mọi giao tiếp qua **artifact trong SSOT**.
- **Orchestrator** giữ vai trò mở/đóng cổng, phân giải xung đột, quyết định lùi giai đoạn.
- Mỗi agent có **vai trò hẹp + quyền ghi hẹp** → giảm va chạm, dễ debug.
- **Auditor là agent độc lập** — không phải agent đã viết code (đảm bảo khách quan).

---

## 5. Cổng chất lượng (Quality Gate)

Giữa mỗi giai đoạn có một `gate.md` với 2 danh sách:

- **Definition of Ready (DoR):** đủ điều kiện để *bắt đầu* giai đoạn.
- **Definition of Done (DoD):** đủ điều kiện để *kết thúc* và đi tiếp.

**Ví dụ cổng GĐ 6 → 7 (trước khi code):**

- ✅ `requirements.md` đã chốt, không còn TODO.
- ✅ `api-contract.md` + `data-model.md` tồn tại.
- ✅ `tasks.md` đã phân rã, mỗi task có tiêu chí nghiệm thu.
- ✅ `glossary.md` thống nhất thuật ngữ.

Không đủ → Orchestrator **không cho qua**, trả về giai đoạn trước. Đây là cách ngăn "code trên nền móng lung lay".

---

## 6. Giai đoạn 10 — Audit sâu 3 phần

**Auditor là agent ĐỘC LẬP** (không phải agent đã viết code). Giống kiểm toán ngoài — khách quan. Mỗi phần chấm điểm 0–10 + liệt kê *findings*.

| Phần | Tên | Câu hỏi cốt lõi | Soi cái gì |
|------|-----|------------------|------------|
| **A** | **Kỹ thuật** (Technical) | *"Nó có vững không?"* | Kiến trúc có khớp `architecture.md`, chất lượng code, nợ kỹ thuật, hiệu năng (p95/p99), test coverage, khả năng mở rộng |
| **B** | **Bảo mật & Tuân thủ** (Security & Compliance) | *"Nó có an toàn không?"* | Lỗ hổng (SAST/DAST), CVE phụ thuộc, secrets lộ, auth/RBAC, mã hóa, quyền riêng tư, GDPR/compliance |
| **C** | **Sản phẩm & Đồng bộ** (Product & Context) | *"Nó có đúng lời hứa & mọi thứ có đồng bộ không?"* | Phủ 100% `requirements.md`, **SSOT có khớp thực tế không** (spec↔code↔docs), UX/accessibility, glossary nhất quán, mục tiêu kinh doanh |

> Phần **C** gắn thẳng vào mục tiêu đồng bộ context: audit kiểm tra `docs/` và `project/` có còn khớp code thật không — lệch là *finding*.

**⚠️ Quy tắc chống tràn context (xem rủi ro §11):** Auditor **KHÔNG** được audit cả 3 phần A/B/C trong cùng một session. Mỗi phần chạy một session riêng (clear/wipe context giữa các phần), vì nhồi `api-contract.md` + `main-design.md` + toàn bộ source vào một context dễ chạm trần token và gây *Lost in the Middle* (quên instruction giữa chừng). Mỗi phần chỉ nạp đúng artifact + vùng code liên quan.

**Cấu trúc lưu kết quả (audit là sự kiện có lịch sử):**

```
audits/
├── README.md
└── 2026-06-10-pre-release/
    ├── scorecard.yaml                  # điểm tổng + 3 phần (máy đọc)
    ├── part-a-technical.md
    ├── part-b-security-compliance.md
    ├── part-c-product-context.md
    └── findings.yaml                   # nguồn của giai đoạn 11
```

---

## 7. Giai đoạn 11 — Khắc phục & Nâng cấp + vòng lặp 10/10

```
   GĐ10 Audit ──► findings.yaml (scorecard BLOCKED)
        │
        ▼
   GĐ11 Khắc phục & Nâng cấp
        ├─ mỗi finding → 1 task trong tasks.md (gắn owner)
        ├─ "cái chưa làm được" → upgrade-plan.md (bổ sung/nâng cấp)
        ├─ quyết định lớn → tạo ADR
        └─ cập nhật ngược docs/ + project/ cho khớp
        │
        ▼
   RE-AUDIT (auditor chạy lại) ──► scorecard mới
        │
        ├─ PASS  ──► sang GĐ12 (Production)
        └─ BLOCKED ──► quay lại GĐ11   ⟲ (lặp đến khi đạt ngưỡng HOẶC chạm trần loop)
```

**🛑 Chặn vòng lặp vô tận (circuit breaker):** vòng `fix → re-audit → fix` có thể hút cạn token/credit cả đêm mà không qua cổng. Bắt buộc:

- Biến `max_remediation_loops` (mặc định **3**) trong `project-profile.yaml`. Mỗi finding đếm số lần bị re-audit trượt.
- Khi một finding trượt quá ngưỡng → tự chuyển `status: blocked`, bật cờ `escalate_to_human: true`, agent **dừng vòng lặp** và chờ người vào xử lý.
- **Tuyệt đối không tự hạ `threshold`** để "qua cổng cho xong" — chất lượng > tiền (xem `ADR-0002`).

**Hai loại finding xử lý khác nhau:**

- **Lỗi/khoảng trống** (chưa làm được, làm sai) → fix trong `tasks.md`.
- **Cơ hội nâng cấp** (làm được nhưng nên tốt hơn) → `upgrade-plan.md`; có thể đẩy sang `backlog-next.md` nếu không chặn release.

Risk không sửa ngay phải ghi `status: accepted-risk` **kèm ADR** — không lờ đi trong im lặng.

---

## 8. Cấu trúc SSOT (`.context/`)

### 8.1. Quy ước đặt tên (chốt cứng)

- **Tất cả file & thư mục: `kebab-case`** (chữ thường, gạch ngang). Không underscore, không viết hoa.
- `backend` / `frontend` / `database` (từ chuẩn ngành, một từ).
- File máy đọc dùng `.yaml`; file người + agent đọc dùng `.md`.
- ADR đánh số 4 chữ số: `ADR-0001-...`.

### 8.2. Chuẩn front-matter (mỗi file `.md` mở đầu bằng khối này)

```yaml
---
id: project.api-contract        # định danh duy nhất
layer: L1                       # L0/L1/L2/L3
owner: architect                # ai chịu trách nhiệm
writers: [architect]            # ai ĐƯỢC ghi
readers: [backend, frontend, qa]
status: draft | review | approved | deprecated
version: 1.2.0
updated: 2026-06-05
canonical: true                 # đây có phải bản gốc không?
related: [docs/backend/interface.md]
---
```

→ Agent biết ngay quyền + độ tươi mới mà không cần đọc hết nội dung.

### 8.3. Cây thư mục đầy đủ

```
.context/
├── manifest.yaml                # bản đồ toàn bộ SSOT, agent ĐỌC ĐẦU TIÊN
├── README.md                    # onboarding cho người & agent
│
├── global/                      # L0 — dùng chung mọi dự án
│   ├── coding-standards.md
│   ├── conventions.md           # naming, git, branch, commit
│   ├── definition-of-ready.md   # điều kiện ĐỦ để bắt đầu 1 giai đoạn
│   ├── definition-of-done.md
│   ├── context-protocol.md      # LUẬT Hydrate→Validate→Execute→Write-back
│   └── tech-radar.md            # công nghệ được duyệt / thử nghiệm / cấm
│
├── project/                     # L1 — SỰ THẬT GỐC, xuyên suốt (canonical)
│   ├── project-profile.yaml     # size + type → điều khiển cổng
│   ├── state.yaml               # máy đọc: đang ở giai đoạn nào, status
│   ├── vision.md
│   ├── requirements.md
│   ├── architecture.md          # kiến trúc tổng, mức hệ thống
│   ├── data-model.md            # thực thể LOGIC (canonical)
│   ├── api-contract.md          # BẢN GỐC DUY NHẤT của hợp đồng API
│   ├── design-system.md
│   ├── glossary.md
│   └── risks.md                 # sổ rủi ro
│
├── docs/                        # L1 — thiết kế CHI TIẾT theo phòng ban (cách làm)
│   ├── main-design.md           # thiết kế lý thuyết tổng, nối các phòng ban
│   ├── backend/
│   │   ├── main-design.md
│   │   ├── tech-stack.md
│   │   ├── interface.md         # BE phục vụ/đáp ứng api-contract ra sao
│   │   └── skills.md            # playbook năng lực cho agent BE
│   ├── frontend/
│   │   ├── main-design.md
│   │   ├── tech-stack.md
│   │   ├── interface.md         # FE tiêu thụ api-contract ra sao
│   │   └── skills.md
│   └── database/
│       ├── main-design.md
│       ├── tech-stack.md
│       ├── interface.md         # kết nối / data-access layer
│       ├── schema.md            # schema VẬT LÝ (khác data-model logic)
│       └── skills.md
│
├── agents/                      # "hồ sơ nhân sự": ai làm gì, ghi được file nào
│   ├── orchestrator.md
│   ├── product.md
│   ├── architect.md
│   ├── backend-engineer.md
│   ├── frontend-engineer.md
│   ├── database-engineer.md
│   ├── qa.md
│   ├── auditor.md               # độc lập, chạy GĐ10
│   └── reconciliation.md        # đối soát code ↔ spec liên tục
│
├── stages/                      # L2 — đầy đủ 13 giai đoạn (mỗi cái có gate.md)
│   ├── 01-ideation-research/
│   ├── 02-requirements-scope/
│   ├── 03-feasibility-tech-strategy/
│   ├── 04-system-design/
│   ├── 05-ux-ui-design/
│   ├── 06-planning-breakdown/
│   ├── 07-development/
│   │   ├── gate.md
│   │   └── tasks.md
│   ├── 08-testing-qa/
│   ├── 09-integration-staging/
│   ├── 10-deep-audit/
│   │   └── gate.md              # trỏ tới audit-run mới nhất
│   ├── 11-remediation-upgrade/
│   │   ├── gate.md
│   │   ├── tasks.md             # map 1-1 tới findings
│   │   └── upgrade-plan.md
│   ├── 12-production-operations/
│   └── 13-final-release/
│
├── audits/                      # lịch sử từng lần audit (scorecard + 3 part + findings)
│   ├── README.md
│   └── 2026-06-10-pre-release/
│       ├── scorecard.yaml
│       ├── part-a-technical.md
│       ├── part-b-security-compliance.md
│       ├── part-c-product-context.md
│       └── findings.yaml
│
├── decisions/                   # ADR — nhật ký quyết định
│   ├── README.md                # mục lục ADR
│   └── ADR-0001-choose-postgres.md
│
├── sessions/                    # L3 — log thô mỗi lần agent chạy
│   └── 2026-06-05-backend-agent.md
│
├── knowledge/                   # bộ nhớ dài hạn ĐÃ CHƯNG CẤT (khác log thô)
│   └── learnings.md
│
├── templates/                   # mẫu để mọi agent tạo artifact đồng nhất
│   ├── adr.md
│   ├── session-log.md
│   ├── gate.md
│   └── task.md
│
├── schemas/                     # JSON Schema cho file máy đọc (validate inline)
│   ├── project-profile.schema.json
│   ├── state.schema.json
│   ├── scorecard.schema.json
│   └── findings.schema.json
│
├── scripts/                     # tooling write-back (ghi YAML chuẩn 100%, có validate)
│   ├── update-state.sh
│   ├── add-finding.sh
│   └── recompute-scorecard.sh
│
├── progress.md                  # "ván cờ hiện tại" (người đọc)
└── changelog.md                 # mọi thay đổi có dấu vết
```

> **Lưu ý lớp tích hợp:** các file "đánh thức" harness (`.cursorrules`, `.clinerules`, `.windsurfrules`, `.cursorignore`, `.vscode/settings.json`...) nằm ở **thư mục gốc của repo (ngoài `.context/`)**, không nằm trong SSOT — xem §10. Điều này giữ `.context/` **harness-agnostic** để dùng được trên nhiều harness khác nhau.

### 8.4. ⚠️ Quy tắc chống trùng lặp — `project/` vs `docs/`

| Câu hỏi | Sống ở `project/` (BẢN GỐC) | Sống ở `docs/<phòng ban>/` (CÁCH LÀM) |
|---------|------------------------------|----------------------------------------|
| Hợp đồng API | `api-contract.md` — endpoint, shape, version | `interface.md` — BE *hiện thực*, FE *tiêu thụ* hợp đồng đó |
| Dữ liệu | `data-model.md` — thực thể **logic** | `database/schema.md` — bảng/index **vật lý** |
| Kiến trúc | `architecture.md` — tổng hệ thống | `*/main-design.md` — chi tiết từng phòng ban |

**Luật vàng:**

- File có `canonical: true` là **bản gốc duy nhất**. File `docs/` chỉ được **tham chiếu**, không sao chép.
- `docs/` mâu thuẫn với `project/` → coi như **bug**, `reconciliation` agent tạo task sửa.
- `project/` trả lời **"CÁI GÌ"**, `docs/` trả lời **"LÀM THẾ NÀO"**.

---

## 9. Các schema máy đọc

### 9.1. `project/project-profile.yaml`

```yaml
project:
  name: "Tên dự án"
  size: super-large            # super-large | small | personal
  type: saas                   # application | web | saas | tool

execution:
  allow_fast_track: false      # personal: true → cho phép gộp GĐ 01–06 thành 1 cổng nếu task nhỏ
  max_remediation_loops: 3     # GĐ11: 1 finding trượt quá số lần này → blocked + escalate
  escalate_to_human: true      # khi chạm trần loop, dừng và chờ người
  parallel_agents: true        # cho nhiều agent chạy song song (kèm single-writer + append-only)

audit:
  threshold_composite:         # điểm tối thiểu để qua cổng GĐ10
    super-large: 9.5
    small:       8.5
    personal:    8.0
  block_on:                    # mức severity chặn release
    super-large: [critical, high]
    small:       [critical, high]
    personal:    [critical]
  parts_required:
    super-large: [A, B, C]
    small:       [A, B, C]
    personal:    [A, C]        # cá nhân: audit bảo mật nhẹ hơn
  isolate_parts: true          # bắt buộc chạy A/B/C ở các session riêng (chống tràn context)
```

### 9.2. `project/state.yaml`

```yaml
current_stage: 07-development
status: in-progress            # not-started | in-progress | blocked | done
active_agents: [backend-engineer, frontend-engineer]
last_gate_passed: 06-planning-breakdown
remediation_loops: 0           # đếm số vòng GĐ11 đã chạy (so với max_remediation_loops)
escalated: false               # true khi chạm trần loop → chờ người
updated: 2026-06-05
```

> File này chỉ được ghi qua `scripts/update-state.sh` (serial hóa bởi Orchestrator), không sửa text trực tiếp.

### 9.3. `audits/<run>/findings.yaml`

```yaml
findings:
  - id: F-0001
    part: A                    # A=kỹ thuật | B=bảo mật | C=sản phẩm/đồng bộ
    severity: high             # critical | high | medium | low
    title: "N+1 query ở /orders"
    evidence: "src/orders/service.ts:42; p95=210ms"
    recommendation: "Eager-load + index"
    status: open               # open | in-progress | fixed | accepted-risk | wont-fix
    owner: backend
    task: null                 # điền TASK-xxx ở giai đoạn 11
    adr: null
```

### 9.4. `audits/<run>/scorecard.yaml`

```yaml
audit_run: 2026-06-10-pre-release
parts:
  technical:       { score: 7.5, weight: 0.35 }
  security:        { score: 6.0, weight: 0.35 }
  product_context: { score: 8.5, weight: 0.30 }
composite: 7.27
threshold: 9.0                 # lấy theo size dự án
open_critical: 1
open_high: 3
gate: BLOCKED                  # PASS khi composite>=threshold & open_critical=0 & open_high=0
```

---

## 10. Lớp tích hợp Harness/IDE

`.context/` cố tình **harness-agnostic** (dùng được trên Cursor, Windsurf, Cline, Antigravity, hoặc harness tự build). Phần "đánh thức" harness nằm ở **gốc repo**, mỗi harness một adapter — đây là cầu nối giúp IDE tự biết SSOT tồn tại.

### 10.1. File entry-point (đánh thức harness — TASK-001)

Đặt ở **gốc repo** một mệnh lệnh tối thượng: *"Bắt đầu MỌI session bằng việc đọc `.context/manifest.yaml` và `.context/project/state.yaml` trước khi làm bất cứ gì."*

| Harness | File | Ghi chú |
|---------|------|---------|
| Cursor | `.cursor/rules/*.mdc` (chuẩn mới) hoặc `.cursorrules` (legacy, đang bị deprecate) | Nên dùng thư mục `.cursor/rules/` |
| Windsurf | `.windsurf/rules/*.md` hoặc `.windsurfrules` | |
| Cline | `.clinerules` | |
| Khác / tự build | nhồi mệnh lệnh trên vào system prompt của Orchestrator | |

> Vì bạn chạy **nhiều harness**, hãy giữ một nguồn nội dung rule duy nhất (vd `.context/global/context-protocol.md`) rồi để mỗi file adapter trỏ về nó, tránh chép nội dung nhiều nơi (đúng tinh thần canonical).

### 10.2. Vệ sinh RAG — chống ô nhiễm tìm kiếm (TASK-002)

IDE tự index toàn workspace. Nếu nó nuốt `sessions/` (log thô), `audits/` (báo cáo cũ), `knowledge/` (bản nháp) thì khi AI tìm spec để code sẽ lôi nhầm log lỗi/nháp ra làm context → **ảo giác**.

→ Chặn auto-index các thư mục này bằng file ignore của harness, chỉ cho đọc **thủ công qua tool đọc file cụ thể**:

```
# .cursorignore / .codeiumignore / .clineignore (ở gốc repo)
.context/sessions/
.context/audits/
.context/knowledge/
```

### 10.3. JSON Schema → validate inline (UPG-003)

Map schema trong `.context/schemas/` vào IDE để khi agent ghi thiếu trường (vd quên `updated`) là bị gạch đỏ ngay, agent tự sửa mà chưa cần Auditor:

```jsonc
// .vscode/settings.json  (cần extension redhat.vscode-yaml)
{
  "yaml.schemas": {
    ".context/schemas/state.schema.json": ".context/project/state.yaml",
    ".context/schemas/project-profile.schema.json": ".context/project/project-profile.yaml",
    ".context/schemas/scorecard.schema.json": ".context/audits/**/scorecard.yaml",
    ".context/schemas/findings.schema.json": ".context/audits/**/findings.yaml"
  }
}
```

### 10.4. Tooling write-back (UPG-001)

Thay vì để LLM sửa text YAML (rủi ro), cung cấp script CLI có validation. AI chỉ chạy lệnh, script lo ghi đúng:

```bash
./scripts/update-state.sh 07-development done      # đổi stage + status, tự set updated
./scripts/add-finding.sh A high "N+1 ở /orders"    # thêm finding, tự cấp ID
./scripts/recompute-scorecard.sh 2026-06-10-pre-release   # tính lại composite + cờ gate
```

→ Đây là cách nâng độ ổn định lên ~100% thay vì lệ thuộc "IQ" của LLM.

---

## 11. Sổ rủi ro nền tảng (ADR bắt buộc)

3 rủi ro thuộc về **giới hạn vật lý của LLM hiện tại** — không fix triệt để được, phải `accepted-risk` kèm cơ chế giảm thiểu.

### 🔴 ADR-0002 — Vòng lặp khắc phục vô tận (token burn)
- **Rủi ro:** GĐ11 `fix → re-audit → trượt → fix...` hút cạn token/credit cả đêm mà không qua cổng.
- **Quyết định:** chấp nhận; **không** được hạ `threshold` (chất lượng > tiền).
- **Giảm thiểu:** `max_remediation_loops: 3` → chạm trần thì `status: blocked` + `escalate_to_human: true`, dừng chờ người (đã đưa vào §7 + `project-profile.yaml`).

### 🔴 ADR-0003 — Tràn context khi Auditor chấm sâu (Lost in the Middle)
- **Rủi ro:** chấm Phần A cần nhồi `api-contract.md` + `main-design.md` + source → chạm trần token, AI quên instruction giữa chừng.
- **Quyết định:** chấp nhận, đánh đổi chi phí lấy audit sâu.
- **Giảm thiểu:** `isolate_parts: true` — chạy A/B/C ở các session riêng, clear context giữa các phần; mỗi phần chỉ nạp artifact + vùng code liên quan (đã đưa vào §6).

### 🔴 ADR-0004 — Tranh chấp ghi khi nhiều agent song song
- **Rủi ro:** nhiều agent cùng ghi `state.yaml`/`progress.md` → đè nhau, mất dữ liệu.
- **Quyết định:** chấp nhận chạy song song vì lợi ích tốc độ.
- **Giảm thiểu:** **single-writer** theo `writers` trong front-matter; log là **append-only**; ghi `state.yaml` serial hóa qua Orchestrator + qua `scripts/` (đã đưa vào §3.4).

---

## 12. Checklist khởi động

**Bước 0 (làm TRƯỚC TIÊN):** tạo file entry-point của harness (`.cursorrules`/`.clinerules`/`.windsurfrules`) ở gốc repo trỏ vào `.context/manifest.yaml` + `state.yaml`, và tạo `.cursorignore` chặn index `sessions/`, `audits/`, `knowledge/`. Không có bước này, harness sẽ không biết SSOT tồn tại.

Ba việc lõi tiếp theo (rẻ nhất, lợi nhất):

1. **`glossary.md` + `project-profile.yaml`** — thuật ngữ thống nhất chống 80% hiểu lầm giữa agent; profile điều khiển toàn bộ độ nghiêm của cổng + các cờ guard.
2. **`context-protocol.md`** — biến giao thức HYDRATE → WRITE-BACK + kỷ luật ghi YAML thành luật bắt buộc; đây là xương sống đồng bộ.
3. **`manifest.yaml` + `agents/` charters** — bản đồ điều hướng + quyền ghi (RBAC) của từng agent; chống dẫm chân nhau.

Sau đó: scaffold đủ 13 `stages/*/gate.md`, JSON Schema trong `schemas/`, script trong `scripts/`, mẫu ADR, mẫu `findings.yaml`/`scorecard.yaml`, và charter cho `auditor` + `reconciliation`.

---

### Tóm tắt một dòng

> **13 giai đoạn + audit 3 phần (kỹ thuật / bảo mật / sản phẩm-đồng bộ) + vòng lặp khắc phục có circuit-breaker**, chạy trên SSOT `.context/` harness-agnostic với giao thức Hydrate→Write-back, quy tắc canonical chống desync, tooling CLI + JSON Schema chống vỡ YAML, vệ sinh RAG chống ảo giác, và 3 ADR chấp nhận giới hạn LLM — để nhiều agent làm việc như một công ty thật và sản phẩm đạt 10/10 có bằng chứng.
