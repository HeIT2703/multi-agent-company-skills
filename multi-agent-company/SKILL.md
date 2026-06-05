---
name: multi-agent-company
description: >
  Vận hành một dự án phần mềm như một công ty multi-agent: pipeline 13 giai đoạn
  (ý tưởng → thiết kế → code → audit sâu 3 phần → khắc phục → release 10/10) chạy
  trên SSOT .context/ với quy tắc đồng bộ context cứng. Dùng skill này khi điều phối
  nhiều agent hoặc phòng ban trên cùng một dự án, khi khởi tạo .context/ làm
  single-source-of-truth, khi áp cổng chất lượng giữa các giai đoạn, khi chạy vòng
  audit/khắc phục, hoặc khi cần đồng bộ docs với code giữa các phiên và harness.
---

# Multi-Agent Company — Hub

Đây là skill **điều phối** (orchestrator). Nó định nghĩa quy trình tổng và gọi các
sub-skill chuyên biệt đúng lúc. Mục tiêu: nhiều agent làm việc như một công ty thật,
context luôn đồng bộ, sản phẩm đạt 10/10 có bằng chứng.

## Nguyên tắc bất biến

1. **SSOT** — "Nếu nó không nằm trong `.context/`, nó không tồn tại." Mọi agent đọc/ghi qua SSOT, không giữ context riêng trong đầu.
2. **Quality Gate** — không qua cổng thì không sang giai đoạn sau.
3. **Handoff Contract** — agent sau chỉ cần đọc artifact, không cần "hiểu" agent trước.

## Giao thức bắt buộc cho MỌI agent (mỗi lần chạy)

`HYDRATE → VALIDATE → EXECUTE → WRITE-BACK`

1. **HYDRATE:** đọc `.context/manifest.yaml` + `project/state.yaml` + L0→L3 liên quan + `progress.md`. Không bắt đầu "từ trí nhớ".
2. **VALIDATE:** đối chiếu việc sắp làm với `requirements.md` / `architecture.md` / `glossary.md`. Mâu thuẫn → dừng, báo orchestrator.
3. **EXECUTE:** làm task.
4. **WRITE-BACK:** ghi `sessions/`, cập nhật `progress.md`, tạo ADR nếu có quyết định lớn, cập nhật ngược spec nếu lệch, ghi `changelog.md`.

## Bản đồ 13 giai đoạn

| # | Giai đoạn | Nhóm | Sub-skill liên quan |
|---|-----------|------|---------------------|
| 1 | Ý tưởng & Nghiên cứu | Conceive | — |
| 2 | Yêu cầu & Phạm vi | Conceive | `quality-gates` |
| 3 | Khả thi & Chiến lược kỹ thuật | Conceive | — |
| 4 | Thiết kế hệ thống & Kiến trúc | Design | `ssot-context-sync` |
| 5 | Thiết kế UX/UI | Design | — |
| 6 | Lập kế hoạch & Phân rã | Design | `quality-gates` |
| 7 | Phát triển / Code | Build | `ssot-context-sync` |
| 8 | Kiểm thử & QA | Build | — |
| 9 | Tích hợp & Staging | Verify & Harden | — |
| 10 | 🔍 Audit sâu (3 phần) | Verify & Harden | `deep-audit` |
| 11 | 🔧 Khắc phục & Nâng cấp | Verify & Harden | `deep-audit` |
| 12 | Ra mắt Production & Vận hành | Launch & Evolve | — |
| 13 | Sản phẩm 10/10 & Cải tiến | Launch & Evolve | — |

> GĐ 13 chỉ được tuyên bố "10/10" khi scorecard của GĐ 10 (sau re-audit) đạt ngưỡng.
> GĐ 13 khép vòng: feedback nuôi lại GĐ 1 cho phiên bản sau.

## Khi nào gọi sub-skill nào

- **Bắt đầu dự án / cần đọc-ghi SSOT** → `ssot-context-sync` (scaffold `.context/`, áp giao thức + canonical rules).
- **Chuyển giữa hai giai đoạn** → `quality-gates` (kiểm DoR/DoD).
- **Trước release (GĐ 10–11)** → `deep-audit` (chấm 3 phần, vòng khắc phục có circuit-breaker).
- **Tích hợp vào IDE/harness cụ thể** → `harness-integration` (entry-point, vệ sinh RAG, schema, tooling).

## Co giãn theo quy mô × loại

Đọc `project/project-profile.yaml` (`size`, `type`) để đặt độ nghiêm của cổng và ngưỡng audit.
Chi tiết: `references/scaling-matrix.md`. Chi tiết từng giai đoạn: `references/pipeline.md`.
Ví dụ chạy thật GĐ1→GĐ13 (dự án personal/tool, có fast-track): `references/example-run.md`.

## Điều phối nhiều agent

- Agent **không** nói chuyện trực tiếp — giao tiếp qua artifact trong SSOT.
- Mỗi agent có vai trò hẹp + quyền ghi hẹp (theo front-matter `writers`).
- **Auditor là agent độc lập**, không phải agent đã viết code.
