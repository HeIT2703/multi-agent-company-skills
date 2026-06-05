# Ma trận co giãn: quy mô × loại

Cùng **một** pipeline 13 giai đoạn; "trọng số" và độ nghiêm của cổng thay đổi theo
`project-profile.yaml`. Orchestrator đọc `size` + `type` rồi bật/tắt + đặt độ nghiêm.

## Theo quy mô

| Quy mô | Đặc điểm | Cách chạy pipeline |
|--------|----------|--------------------|
| **super-large** (triệu user, đa quốc gia) | Multi-region, i18n/l10n, compliance | Mọi giai đoạn FULL. Bắt buộc ADR, security audit, load test. Cổng nghiêm nhất. |
| **small** (trăm ngàn user, 1 quốc gia) | Một thị trường | GĐ 1–6 gọn, dồn lực 7–12. Bỏ multi-region, giữ security & monitoring cơ bản. |
| **personal** (profile/bio, ngàn user) | Nhẹ, nhanh | Gộp GĐ 1–3 (fast-track); 4–6 nhẹ; dồn lực GĐ 7 + 12. Cổng nhẹ. |

## Theo loại

| Loại | Nhấn mạnh |
|------|-----------|
| **application** | GĐ 4 (kiến trúc), 7, 8 (test chặt), client/offline state |
| **web** | GĐ 5 (UX/UI), SEO, performance, responsive |
| **saas** | Multi-tenant, billing, auth/RBAC, SLA, GĐ 12 (vận hành) rất nặng |
| **tool** | Gọn nhẹ, nhấn GĐ 7 + tài liệu sử dụng, ít GĐ 12 |

## Cờ điều khiển (trong project-profile.yaml)

- `execution.allow_fast_track`: personal → `true` cho phép gộp GĐ 01–06 nếu task nhỏ.
- `audit.threshold_composite`: ngưỡng điểm theo size (super-large 9.5 / small 8.5 / personal 8.0).
- `audit.block_on`: severity chặn release theo size.
- `audit.parts_required`: phần audit bắt buộc theo size (personal có thể bỏ phần B nặng).
