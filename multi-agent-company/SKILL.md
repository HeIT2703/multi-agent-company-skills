---
name: multi-agent-company
description: >
  Vận hành một dự án phần mềm như một công ty multi-agent: pipeline 24 giai đoạn (8 pha:
  Discover → Validate → Define → Decide → Blueprint → Build → Harden → Launch) chạy trên
  SSOT .context/ với human-checkpoint, đồng bộ context cứng, validate-trước-khi-build,
  audit sâu 3 phần + circuit-breaker. Dùng khi điều phối nhiều agent/phòng ban, khi khởi
  tạo .context/, khi cần validate ý tưởng, nghiên cứu thị trường, ưu tiên feature, hoặc
  khi áp cổng chất lượng và đồng bộ docs với code.
---

# Multi-Agent Company — Hub (v3.0)

Skill **điều phối** (orchestrator). Định nghĩa quy trình tổng 24 giai đoạn và gọi các
sub-skill chuyên biệt đúng lúc.

## Nguyên tắc bất biến

1. **SSOT** — "Nếu nó không nằm trong `.context/`, nó không tồn tại."
2. **Validate trước khi build** — KHÔNG code trước khi qua cổng validation (GĐ6) + prioritization (GĐ8).
3. **Quality Gate + Human-Checkpoint** — không qua cổng/người duyệt thì không đi tiếp.
4. **Handoff Contract** — agent sau chỉ cần đọc artifact.
5. **Feedback-loop là DNA** — Build-Measure-Learn ở mọi pha.
6. **Pha BLUEPRINT là viên ngọc** — chặt/rộng/sâu/bao quát/đúng ý người dùng nhất trước khi code.

## Giao thức bắt buộc (mỗi lần chạy)

`HYDRATE → VALIDATE → EXECUTE → WRITE-BACK`

## Bản đồ 24 giai đoạn (8 pha × 3)

| # | Giai đoạn | Pha | Sub-skill | Cổng |
|---|-----------|-----|-----------|------|
| 1 | Thinking & Problem Framing | DISCOVER | `product-discovery` | gate |
| 2 | Market & Competitor Research | DISCOVER | `product-discovery` | gate |
| 3 | Audience Segmentation & Personas | DISCOVER | `product-discovery` | gate |
| 4 | User Conversations First | VALIDATE | `product-discovery` | 🧑 human |
| 5 | Idea Validation Battery | VALIDATE | `product-discovery` | gate |
| 6 | Demand Validation & Waitlist | VALIDATE | `product-discovery` | **CỔNG VALIDATION** (GO/PIVOT/KILL) |
| 7 | Requirements & Scope | DEFINE | `decision-gates` | 🧑 human |
| 8 | Feature Prioritization | DEFINE | `product-discovery` | **CỔNG PRIORITIZATION** (MVP) |
| 9 | Feasibility & Solution Options | DEFINE | `decision-gates` | gate |
| 10 | Shaping & Decisions | DECIDE | `decision-gates` | 🧑 human |
| 11 | Threat Modeling | DECIDE | — | gate |
| 12 | Architecture & Data Design | BLUEPRINT ⭐ | `ssot-context-sync` | gate (nghiêm nhất) |
| 13 | UX/UI & Design System | BLUEPRINT ⭐ | — | gate (nghiêm nhất) |
| 14 | Planning, Rules & Breakdown | BLUEPRINT ⭐ | `quality-gates` | gate (nghiêm nhất) |
| 15 | Environment & Scaffolding | BUILD | `harness-integration` | gate |
| 16 | Prototype & Spike | BUILD | — | gate |
| 17 | Development (feedback-loop) | BUILD | `ssot-context-sync` | gate |
| 18 | Testing & QA | BUILD | — | gate |
| 19 | Integration & Staging | HARDEN | — | gate |
| 20 | 🔍 Deep Audit (3 phần) | HARDEN | `deep-audit` | gate |
| 21 | 🔧 Remediation & Upgrade | HARDEN | `deep-audit` | gate |
| 22 | Release Readiness (UAT, go/no-go) | LAUNCH | `decision-gates` | 🧑 human |
| 23 | Production & Operations | LAUNCH | — | gate |
| 24 | Retrospective, 10/10 & Evolve | LAUNCH | — | gate → ↩ GĐ1 |

## Hai cổng sống còn ở nửa đầu

- **CỔNG VALIDATION (GĐ6):** demand signal PHẢI đạt ngưỡng → GO. Không đạt → PIVOT (lặp GĐ1-3, max `max_validation_iterations`) hoặc KILL.
- **CỔNG PRIORITIZATION (GĐ8):** MVP phải được chốt + mọi feature truy vết tới persona JTBD trước khi sang DECIDE/BLUEPRINT.

## Feedback loops (DNA của hệ thống)

| Loop | Ở đâu |
|------|-------|
| Validation (Build-Measure-Learn) | GĐ4-6 |
| Discover⇄Decide | GĐ1-10 |
| Dev increment | GĐ17 |
| Audit | GĐ20-21 |
| Product (ship→measure→learn) | GĐ24 → GĐ1 |

## Pha BLUEPRINT (viên ngọc — cổng nghiêm nhất)

GĐ12-14 tạo bộ tài liệu thiết kế CHẶT/RỘNG/SÂU/BAO QUÁT/ĐÚNG Ý NGƯỜI DÙNG nhất.
Cổng GĐ14→15: architecture cover 100% requirements; api-contract đủ để code ĐỘC LẬP;
glossary thống nhất; mọi task có tiêu chí nghiệm thu; mọi quyết định lớn có ADR.
Không pass → QUAY LẠI BLUEPRINT.

## Khi nào gọi sub-skill nào

- **Discovery + Validation (GĐ1-8)** → `product-discovery`
- **SSOT + scaffold** → `ssot-context-sync`
- **Human-checkpoint / Quyết định / Options** → `decision-gates`
- **Chuyển giai đoạn** → `quality-gates`
- **Audit + Khắc phục** → `deep-audit`
- **Tích hợp IDE** → `harness-integration`

## Co giãn

- super-large: 24 full.
- small: validation nhẹ, gộp GĐ12-14.
- personal + fast-track: gộp GĐ1-3, validation gọn (landing page), gộp BLUEPRINT.

Chi tiết: `references/pipeline.md`, `references/scaling-matrix.md`, `references/example-run.md`.
