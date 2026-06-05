---
id: decision.ADR-<NNNN>-<slug>
layer: L1
owner: orchestrator
writers: [orchestrator]
readers: [all]
status: accepted
version: 1.0.0
updated: <YYYY-MM-DD>
canonical: true
decided_by: human              # human | agent
approved: true
related: [options/<file>.md]
---

# ADR-<NNNN>: <Tiêu đề quyết định>

## Bối cảnh
<Vấn đề cần quyết định. Tham chiếu GĐ nào, requirement nào.>

## Phương án đã cân nhắc
- A: <tóm tắt> — xem `options/<file>.md`
- B: <tóm tắt>
- C: <tóm tắt>

## Quyết định
Chọn **Phương án <X>** vì: <lý do chính>.

## Hệ quả
- Tích cực: <...>
- Đánh đổi: <...>
- Cần chú ý: <...>

## Cập nhật SSOT
- [ ] `project-profile.yaml` → cập nhật field `platform` / `type`
- [ ] `project/architecture.md` → bám quyết định này
- [ ] `global/tech-radar.md` → đánh dấu tech đã chọn = "adopt"
