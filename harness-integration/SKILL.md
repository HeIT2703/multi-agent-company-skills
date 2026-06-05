---
name: harness-integration
description: >
  Kết nối SSOT .context/ với một IDE/harness cụ thể (Cursor, Windsurf, Cline, Claude Code,
  hoặc harness tự build) qua một lớp adapter mỏng ở gốc repo, giữ .context/ luôn
  harness-agnostic. Dùng khi cần "đánh thức" harness để nó tự đọc .context/, khi chống ô
  nhiễm tìm kiếm RAG (auto-index nuốt log/nháp), khi map JSON Schema để validate inline,
  hoặc khi cài tooling write-back. Làm BƯỚC 0 trước khi chạy pipeline.
---

# Harness Integration

`.context/` cố tình harness-agnostic. Phần "đánh thức" harness nằm ở **gốc repo**, mỗi
harness một adapter mỏng. Đây là bước 0 trước khi chạy pipeline.

## 1. Entry-point (đánh thức harness)

Đặt ở gốc repo một mệnh lệnh tối thượng: *"Bắt đầu MỌI session bằng việc đọc
`.context/manifest.yaml` và `.context/project/state.yaml` trước khi làm bất cứ gì."*

| Harness | File entry-point |
|---------|------------------|
| Cursor | `.cursor/rules/*.mdc` (chuẩn mới) hoặc `.cursorrules` (legacy, đang deprecate) |
| Windsurf | `.windsurf/rules/*.md` hoặc `.windsurfrules` |
| Cline | `.clinerules` |
| Claude Code / Kiro | đặt skill ở thư mục skills + nhồi mệnh lệnh vào system prompt orchestrator |
| Tự build | nhồi mệnh lệnh trên vào system prompt |

> Giữ MỘT nguồn nội dung rule (vd `.context/global/context-protocol.md`); mỗi adapter trỏ về nó, tránh chép nhiều nơi (đúng tinh thần canonical).

## 2. Vệ sinh RAG (chống ô nhiễm tìm kiếm)

Auto-index của IDE nếu nuốt `sessions/` (log thô), `audits/` (báo cáo cũ), `knowledge/`
(nháp) sẽ lôi nhầm chúng vào context khi tìm spec → ảo giác. Chặn auto-index, chỉ cho đọc
thủ công qua tool đọc file:

```
# .cursorignore / .codeiumignore / .clineignore (ở gốc repo)
.context/sessions/
.context/audits/
.context/knowledge/
```

## 3. JSON Schema → validate inline

Map schema để agent ghi thiếu trường là bị gạch đỏ ngay (cần extension `redhat.vscode-yaml`):

```jsonc
// .vscode/settings.json
{
  "yaml.schemas": {
    ".context/schemas/state.schema.json": ".context/project/state.yaml",
    ".context/schemas/project-profile.schema.json": ".context/project/project-profile.yaml",
    ".context/schemas/scorecard.schema.json": ".context/audits/**/scorecard.yaml",
    ".context/schemas/findings.schema.json": ".context/audits/**/findings.yaml"
  }
}
```

(Chép các `*.schema.json` từ skill `ssot-context-sync` và `deep-audit` vào `.context/schemas/`.)

## 4. Tooling write-back

Thay vì để LLM sửa text YAML (rủi ro vỡ format), cung cấp script CLI có sẵn trong các
sub-skill (`init-context.sh`, `update-state.sh`, `add-finding.sh`, `recompute-scorecard.sh`).
Agent chỉ chạy lệnh; script ghi YAML chuẩn 100%.

Chi tiết mẫu nội dung adapter: `references/adapters.md`.
