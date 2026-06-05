# Multi-Agent Company — Skills

Phương pháp luận vận hành một dự án phần mềm như một **công ty multi-agent**: pipeline
13 giai đoạn, SSOT `.context/` đồng bộ context cứng, audit sâu 3 phần, và lớp tích hợp
đa harness — để nhiều agent (nhiều harness) làm việc như một công ty thật và sản phẩm
đạt 10/10 có bằng chứng.

Họ skill composable theo chuẩn [Agent Skills](https://agentskills.io/specification)
(progressive disclosure: chỉ `name` + `description` được preload; thân `SKILL.md` nạp khi
liên quan; `references/`, `scripts/` nạp khi thực thi).

## Nội dung repo

| Đường dẫn | Mô tả |
|-----------|-------|
| [`multi-agent-company/`](multi-agent-company/) | **HUB** — bản đồ 24 giai đoạn (8 pha), giao thức bắt buộc, validate-trước-build, điều phối sub-skill |
| [`product-discovery/`](product-discovery/) | Playbook pha DISCOVER+VALIDATE (GĐ1-8): thinking, research, personas, interview, validation battery, waitlist, prioritization |
| [`ssot-context-sync/`](ssot-context-sync/) | Khởi tạo & duy trì SSOT `.context/`, Hydrate→Write-back, canonical, scaffold + charter 13 agent |
| [`decision-gates/`](decision-gates/) | Human-checkpoint: sinh phương án → người chọn → ADR + bộ luật tech (6 rule files) |
| [`quality-gates/`](quality-gates/) | Cổng DoR/DoD giữa các giai đoạn |
| [`deep-audit/`](deep-audit/) | Audit 3 phần (kỹ thuật / bảo mật / sản phẩm-đồng bộ) + vòng lặp khắc phục có circuit-breaker |
| [`harness-integration/`](harness-integration/) | Entry-point đa harness, vệ sinh RAG, JSON Schema, tooling CLI |
| [`docs/blueprint.md`](docs/blueprint.md) | Bản sao thiết kế đầy đủ (đồng bộ với blueprint gốc) |
| [`multi-agent-company-blueprint.md`](multi-agent-company-blueprint.md) | Bản thiết kế đầy đủ (v1.1) |
| `multi-agent-company-skills.zip` | Gói tải nhanh toàn bộ họ skill |

## Cài đặt

Chép các thư mục skill vào nơi harness của bạn quét skill:

- **Kiro:** `~/.kiro/skills/` (user-level, mọi dự án) hoặc `.kiro/skills/` (workspace).
- **Claude Code / Superpowers-style:** thư mục skills của plugin.
- **Cursor / harness khác:** trỏ entry-point (xem `harness-integration/`) vào hub.

```bash
cp -r multi-agent-company product-discovery ssot-context-sync quality-gates deep-audit harness-integration decision-gates  ~/.kiro/skills/
```

## Bắt đầu nhanh

```bash
# scaffold SSOT .context/ cho một dự án mới (tự sinh 13 stage + 9 charter agent)
bash ssot-context-sync/scripts/init-context.sh ./my-project "Tên dự án" small saas
```

Sau đó hub `multi-agent-company` điều phối theo giai đoạn:
khởi động → `ssot-context-sync`; chuyển giai đoạn → `quality-gates`;
trước release → `deep-audit` (+ vòng khắc phục); tích hợp IDE → `harness-integration`.

Ví dụ chạy thật GĐ1→GĐ13: [`multi-agent-company/references/example-run.md`](multi-agent-company/references/example-run.md).

## Phụ thuộc

Tất cả script không phụ thuộc thư viện ngoài — chỉ cần `bash` + `python3` (stdlib).
