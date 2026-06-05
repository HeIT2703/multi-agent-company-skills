---
name: ssot-context-sync
description: >
  Khởi tạo và duy trì SSOT .context/ làm single-source-of-truth cho dự án multi-agent,
  với 4 lớp context (global/project/stage/session), giao thức Hydrate→Validate→Execute→Write-back,
  quy tắc canonical chống trùng lặp sự thật, chuẩn front-matter, và kỷ luật ghi YAML.
  Dùng khi cần scaffold .context/, khi agent bắt đầu/kết thúc một phiên làm việc, khi
  đồng bộ docs với code, hoặc khi giải quyết mâu thuẫn giữa tài liệu của các phòng ban.
---

# SSOT Context Sync

Skill này quản lý "nguồn sự thật duy nhất" `.context/` và giao thức đồng bộ. Nó là
xương sống chống ảo giác, mất bối cảnh, và dẫm chân giữa các agent.

## Bốn lớp context (đọc từ trên xuống khi HYDRATE)

- **L0 — global/**: chuẩn code, convention, giao thức, tech-radar (dùng chung mọi dự án).
- **L1 — project/ + docs/**: sự thật gốc của dự án (canonical) + thiết kế chi tiết theo phòng ban.
- **L2 — stages/**: trạng thái + cổng từng giai đoạn.
- **L3 — sessions/**: log mỗi lần agent chạy.

Agent **chỉ được ghi vào đúng lớp/quyền** theo front-matter `writers`.

## Giao thức Hydrate → Validate → Execute → Write-back

1. **HYDRATE:** đọc `manifest.yaml` + `project/state.yaml` + L0→L3 liên quan + `progress.md` + ADR liên quan.
2. **VALIDATE:** đối chiếu với `requirements.md` / `architecture.md` / `glossary.md`. Mâu thuẫn → dừng, báo orchestrator.
3. **EXECUTE:** làm task.
4. **WRITE-BACK:** `sessions/` (append), `progress.md`, ADR nếu cần, cập nhật ngược spec nếu lệch, `changelog.md` (append).

## Đồng bộ 2 chiều Spec ↔ Code

- Xuôi: code dựa trên `requirements.md` + `api-contract.md`.
- Ngược: khi code buộc lệch thiết kế → tạo ADR giải thích, cập nhật `architecture.md`/`api-contract.md`, đánh dấu `progress.md`.
- Cưỡng chế: agent `reconciliation` chạy cuối mỗi giai đoạn code để phát hiện lệch → tạo task đồng bộ.

## Quy tắc CANONICAL (chống trùng lặp sự thật)

- File có front-matter `canonical: true` là **bản gốc duy nhất**; nơi khác chỉ tham chiếu, không sao chép.
- `project/` trả lời **"CÁI GÌ"** (logic, hợp đồng); `docs/<phòng ban>/` trả lời **"LÀM THẾ NÀO"** (hiện thực).
- `docs/` mâu thuẫn `project/` = bug → `reconciliation` tạo task sửa.

| Chủ đề | project/ (bản gốc) | docs/<phòng ban>/ |
|--------|--------------------|-------------------|
| API | `api-contract.md` | `interface.md` (BE hiện thực / FE tiêu thụ) |
| Dữ liệu | `data-model.md` (logic) | `database/schema.md` (vật lý) |
| Kiến trúc | `architecture.md` (tổng) | `*/main-design.md` (chi tiết) |

## Kỷ luật ghi file máy đọc (chống vỡ YAML & tranh chấp)

- **Ưu tiên ghi qua tooling**: dùng `scripts/update-state.sh` thay vì sửa text YAML trực tiếp.
- Nếu buộc ghi text: **CẤM** bọc trong code fence markdown; thụt lề **đúng 2 spaces**, không tab.
- **Single-writer** theo `writers`; log (`sessions/`, `changelog.md`) là **append-only**; ghi `state.yaml` serial hóa qua orchestrator.

## Tài nguyên

- Cấu trúc đầy đủ + naming + front-matter: `references/ssot-structure.md`.
- Template: `templates/` (front-matter, adr, session-log, project-profile, state).
- Scaffold: `scripts/init-context.sh`. Cập nhật trạng thái: `scripts/update-state.sh`.
- Validate inline: `schemas/*.schema.json`.

## Cách scaffold nhanh

```bash
bash scripts/init-context.sh /đường/dẫn/repo "Tên dự án" small saas
```

`init-context.sh` tạo đầy đủ: 13 `stages/*/gate.md`, `project/` canonical, `manifest.yaml`,
`global/context-protocol.md`, và **9 charter agent** trong `agents/` (orchestrator, product,
architect, backend/frontend/database-engineer, qa, auditor, reconciliation) với RBAC `writers`.
