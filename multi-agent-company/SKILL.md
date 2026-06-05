---
name: multi-agent-company
description: >
  Vận hành một dự án phần mềm như một công ty multi-agent: pipeline 18 giai đoạn (6 pha:
  Discover⇄Decide lặp → Blueprint viên ngọc → Build → Verify → Launch) chạy trên SSOT
  .context/ với human-checkpoint, đồng bộ context cứng, audit sâu 3 phần + circuit-breaker.
  Dùng khi điều phối nhiều agent/phòng ban, khi khởi tạo .context/, khi cần vòng lặp
  nghiên cứu-hỏi-quyết định, khi áp cổng chất lượng, hoặc khi đồng bộ docs với code.
---

# Multi-Agent Company — Hub (v2.0)

Skill **điều phối** (orchestrator). Định nghĩa quy trình tổng 18 giai đoạn và gọi các
sub-skill chuyên biệt đúng lúc.

## Nguyên tắc bất biến

1. **SSOT** — "Nếu nó không nằm trong `.context/`, nó không tồn tại."
2. **Quality Gate + Human-Checkpoint** — không qua cổng/người duyệt thì không đi tiếp.
3. **Handoff Contract** — agent sau chỉ cần đọc artifact.
4. **Discover⇄Decide là vòng lặp** — AI nghiên cứu + hỏi người dùng song song, lặp đến khi hội tụ.
5. **Pha BLUEPRINT là viên ngọc** — chặt/rộng/sâu/bao quát/đúng ý người dùng nhất trước khi code.

## Giao thức bắt buộc (mỗi lần chạy)

`HYDRATE → VALIDATE → EXECUTE → WRITE-BACK`

## Bản đồ 18 giai đoạn (6 pha × 3)

| # | Giai đoạn | Pha | Sub-skill | Cổng |
|---|-----------|-----|-----------|------|
| 1 | Ý tưởng & Nghiên cứu | DISCOVER | — | gate |
| 2 | Thu thập Yêu cầu người dùng | DISCOVER | `decision-gates` | 🧑 human |
| 3 | Khả thi & Sinh phương án | DISCOVER | — | gate |
| 4 | Định hình & Quyết định | DECIDE | `decision-gates` | 🧑 human |
| 5 | Mô hình hóa Rủi ro & Đe dọa | DECIDE | — | gate |
| 6 | Prototype & Spike | DECIDE | — | gate |
| 7 | Thiết kế Kiến trúc & Dữ liệu | BLUEPRINT ⭐ | `ssot-context-sync` | gate (nghiêm nhất) |
| 8 | Thiết kế UX/UI & Design System | BLUEPRINT ⭐ | — | gate (nghiêm nhất) |
| 9 | Lập kế hoạch, Phân rã & Quy tắc | BLUEPRINT ⭐ | `quality-gates` | gate (nghiêm nhất) |
| 10 | Môi trường & Scaffolding | BUILD | `harness-integration` | gate |
| 11 | Phát triển / Code | BUILD | `ssot-context-sync` | gate |
| 12 | Kiểm thử & QA | BUILD | — | gate |
| 13 | Tích hợp & Staging | VERIFY | — | gate |
| 14 | 🔍 Audit sâu (3 phần) | VERIFY | `deep-audit` | gate |
| 15 | 🔧 Khắc phục & Nâng cấp | VERIFY | `deep-audit` | gate |
| 16 | Sẵn sàng Ra mắt (UAT, go/no-go) | LAUNCH | `decision-gates` | 🧑 human |
| 17 | Production & Vận hành | LAUNCH | — | gate |
| 18 | Retrospective, 10/10 & Cải tiến | LAUNCH | — | gate → ↩ GĐ1 |

## Vòng lặp Discover ⇄ Decide

GĐ1–6 tạo vòng lặp hội tụ:
- AI nghiên cứu (GĐ1) + hỏi người dùng (GĐ2) → sinh phương án (GĐ3) → người chọn (GĐ4).
- Quyết định xong → mở câu hỏi mới? → lặp lại GĐ1–3 (tối đa `max_discover_decide_loops`).
- GĐ4 hội tụ → threat model (GĐ5) → spike validate (GĐ6) → spike pass → sang BLUEPRINT.
- Spike fail → quay lại GĐ3–4 (phương án khác).

## Pha BLUEPRINT (viên ngọc — cổng nghiêm nhất)

GĐ7–9 phải tạo ra bộ tài liệu thiết kế CHẶT/RỘNG/SÂU/BAO QUÁT/ĐÚNG Ý NGƯỜI DÙNG nhất.
Cổng GĐ9→10:
- architecture cover 100% requirements.
- api-contract đủ để FE/BE code ĐỘC LẬP.
- glossary thống nhất (reconciliation kiểm).
- mọi task có tiêu chí nghiệm thu.
- mọi quyết định lớn có ADR.
- Không pass → QUAY LẠI BLUEPRINT. Không "cho qua vì deadline".

## Khi nào gọi sub-skill nào

- **SSOT + scaffold** → `ssot-context-sync`
- **Human-checkpoint / Quyết định** → `decision-gates`
- **Chuyển giai đoạn** → `quality-gates`
- **Audit + Khắc phục** → `deep-audit`
- **Tích hợp IDE** → `harness-integration`

## Co giãn

- super-large: 18 full.
- small: bỏ GĐ5,6; gộp GĐ7–9.
- personal + fast-track: gộp GĐ1–6 thành 1–2 phiên; BLUEPRINT gọn.

Chi tiết: `references/pipeline.md`, `references/scaling-matrix.md`, `references/example-run.md`.
