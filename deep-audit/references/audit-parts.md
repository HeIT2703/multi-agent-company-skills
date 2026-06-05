# Audit 3 phần — chi tiết & thang điểm

## Thang điểm mỗi phần (0–10)

| Điểm | Ý nghĩa |
|------|---------|
| 9–10 | Xuất sắc; gần như không finding; sẵn sàng production |
| 7–8 | Tốt; vài finding medium/low |
| 5–6 | Trung bình; có finding high cần xử lý |
| 0–4 | Yếu; có finding critical; chặn release |

Trọng số gợi ý: A=0.35, B=0.35, C=0.30 (điều chỉnh theo `type` — vd SaaS tăng B; web tăng C cho UX).

## Phần A — Kỹ thuật
- Code có khớp `architecture.md` / `data-model.md` không (kiến trúc conformance).
- Chất lượng: trùng lặp, coupling, complexity, dead code.
- Nợ kỹ thuật: liệt kê + ước lượng.
- Hiệu năng: p95/p99 các endpoint nóng; N+1; index.
- Test: coverage, chất lượng test (không chỉ con số).
- Khả năng mở rộng theo `size`.

## Phần B — Bảo mật & Tuân thủ
- SAST/DAST; injection, XSS, SSRF, IDOR.
- CVE trong dependency (lockfile).
- Secrets lộ trong repo/log/history.
- Auth/RBAC đúng `api-contract.md`; least-privilege.
- Mã hóa khi truyền & khi lưu; quản lý khóa.
- Quyền riêng tư & compliance theo thị trường (vd GDPR cho đa quốc gia).

## Phần C — Sản phẩm & Đồng bộ
- Phủ 100% `requirements.md`? Liệt kê requirement chưa có code.
- **Đồng bộ SSOT**: `docs/` & `project/` có khớp code thật không? Lệch = finding (gắn `reconciliation`).
- `glossary.md` nhất quán trong code/UI/doc.
- UX/accessibility (a11y) theo `design-system.md`.
- Bám mục tiêu kinh doanh trong `vision.md`.

## 3 ADR rủi ro nền tảng (giới hạn LLM — accepted-risk)

### ADR-0002 — Vòng lặp khắc phục vô tận (token burn)
- Mitigation: `max_remediation_loops` (mặc định 3) → blocked + `escalate_to_human`. Không hạ threshold.

### ADR-0003 — Tràn context khi Auditor chấm sâu (Lost in the Middle)
- Mitigation: `isolate_parts: true` — A/B/C ở các session riêng; mỗi phần chỉ nạp artifact + code liên quan.

### ADR-0004 — Tranh chấp ghi khi nhiều agent song song
- Mitigation: single-writer theo front-matter `writers`; log append-only; ghi `state.yaml` serial qua orchestrator + `scripts/`.
