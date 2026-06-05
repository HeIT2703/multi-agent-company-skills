---
name: decision-gates
description: >
  Quản lý human-checkpoint tại các điểm quyết định sống còn (GĐ2 lấy yêu cầu, GĐ4 chọn
  platform/kiến trúc/tech/ưu tiên, GĐ16 duyệt release). Agent sinh phương án có đề xuất
  mặc định dạng menu, trình người dùng chọn, rồi ghi quyết định thành ADR phê duyệt.
  Hỗ trợ 2 chế độ: interactive (dừng chờ người) và autonomous (tự chọn default + ghi lý do).
  Dùng khi cần hỏi người dùng về platform, kiến trúc, tech stack, độ ưu tiên feature, hoặc
  khi cần go/no-go trước release.
---

# Decision Gates — Human-Checkpoint

Skill quản lý các điểm bắt buộc dừng-chờ-người (hoặc tự chọn nếu autonomous).

## 3 điểm human-checkpoint trong pipeline

| GĐ | Tên | Hỏi gì |
|----|-----|--------|
| **2** | Thu thập Yêu cầu | Phỏng vấn người dùng: mục tiêu, pain points, kỳ vọng, ràng buộc |
| **4** | Định hình & Quyết định | Chọn platform, kiến trúc, tech stack, độ ưu tiên feature |
| **16** | Sẵn sàng Ra mắt | UAT pass? Go/no-go? Rollout strategy? |

## Cơ chế hoạt động

### 1. Agent SINH PHƯƠNG ÁN (Diverge — GĐ3)

Ghi vào `options/`:
- `options/platform-options.md` — các nền tảng khả thi + tradeoff.
- `options/architecture-options.md` — 2–3 kiến trúc + ưu/nhược/chi phí.
- `options/tech-stack-options.md` — ngôn ngữ, framework, DB, hosting.
- `options/priority-matrix.md` — feature xếp theo MoSCoW hoặc RICE.

Mỗi phương án theo format:
```
## Phương án A: <tên>    ← ✅ KHUYẾN NGHỊ (nếu là default)
- Ưu: ...
- Nhược: ...
- Chi phí/thời gian: ...
- Phù hợp khi: ...
```

### 2. Trình người dùng CHỌN (Decide — GĐ4)

- `decision_mode: interactive` → agent dừng, đợi người chọn.
- `decision_mode: autonomous` → agent chọn phương án ✅ KHUYẾN NGHỊ, ghi `decided_by: agent`.

### 3. Ghi quyết định thành ADR

Mỗi quyết định → 1 ADR trong `decisions/`:
```yaml
---
decided_by: human          # human | agent
approved: true
---
```

Đồng thời cập nhật `project-profile.yaml` (vd `platform: [web-ssr]`).

### 4. Kiểm tra HỘI TỤ

Sau GĐ4, orchestrator kiểm:
- Mọi nhóm quyết định (platform, arch, tech, priority) đã có ADR `approved: true`?
- Còn unknowns nào mở? → chưa hội tụ → lặp lại DISCOVER (GĐ1–3) với câu hỏi mới.
- `state.yaml.convergence = true` → sang GĐ5.

### 5. Giới hạn lặp

`max_discover_decide_loops` (mặc định 3). Chạm trần → buộc chốt hoặc escalate.

## GĐ2 — Thu thập Yêu cầu (phỏng vấn)

Agent Product hỏi người dùng theo kịch bản:
1. Mục tiêu chính của sản phẩm?
2. Ai là người dùng (persona)?
3. Pain points hiện tại?
4. Kỳ vọng kết quả (metric)?
5. Ràng buộc (thời gian, ngân sách, kỹ thuật)?
6. Tính năng must-have vs nice-to-have?

Đầu ra → `project/requirements.md` + `scope.md` + cập nhật `glossary.md`.

## GĐ16 — Sẵn sàng Ra mắt

Agent Release Manager trình:
- UAT report (pass/fail).
- Checklist release-readiness.
- Rollout plan (phased? canary? big-bang?).
- Rollback plan.
→ Người dùng chốt GO / NO-GO / DELAY.

## Tài nguyên

- Template phương án: `templates/option.md`
- Template quyết định: `templates/decision-adr.md`
