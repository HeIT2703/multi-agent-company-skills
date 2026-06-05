# Mẫu nội dung adapter (đặt ở GỐC REPO, ngoài .context/)

> Đây là mẫu để chép. Giữ nội dung rule ngắn — chi tiết để trong `.context/`.

## Entry-point — nội dung gợi ý (dùng chung cho mọi harness)

```
CRITICAL — Multi-Agent Company protocol:
1. Bắt đầu MỌI session bằng việc đọc .context/manifest.yaml và .context/project/state.yaml.
2. Tuân thủ giao thức trong .context/global/context-protocol.md (Hydrate→Validate→Execute→Write-back).
3. Chỉ ghi file mình có quyền (front-matter `writers`). Log là append-only.
4. Ghi file .yaml qua .context/scripts/*, KHÔNG sửa text YAML trực tiếp.
5. Trước release: chạy skill deep-audit; không hạ threshold để qua cổng.
```

- **Cursor:** lưu vào `.cursor/rules/00-company.mdc` (thêm frontmatter `alwaysApply: true`) hoặc `.cursorrules`.
- **Windsurf:** `.windsurf/rules/00-company.md` hoặc `.windsurfrules`.
- **Cline:** `.clinerules`.

## Ignore — chống ô nhiễm RAG

Tạo file ignore tương ứng ở gốc repo với nội dung:

```
.context/sessions/
.context/audits/
.context/knowledge/
```

- Cursor: `.cursorignore`
- Codeium/Windsurf: `.codeiumignore`
- Cline: `.clineignore`

## VSCode — validate YAML inline

`.vscode/settings.json` (cần extension `redhat.vscode-yaml`):

```jsonc
{
  "yaml.schemas": {
    ".context/schemas/state.schema.json": ".context/project/state.yaml",
    ".context/schemas/project-profile.schema.json": ".context/project/project-profile.yaml",
    ".context/schemas/scorecard.schema.json": ".context/audits/**/scorecard.yaml",
    ".context/schemas/findings.schema.json": ".context/audits/**/findings.yaml"
  }
}
```

## Thứ tự cài (bước 0)

1. `bash ssot-context-sync/scripts/init-context.sh <repo> "<name>" <size> <type>`
2. Chép `*/schemas/*.json` → `<repo>/.context/schemas/`
3. Chép `*/scripts/*.sh` → `<repo>/.context/scripts/` (và `chmod +x`)
4. Tạo entry-point + ignore + `.vscode/settings.json` ở gốc repo theo mẫu trên.
5. Bắt đầu pipeline từ GĐ1 (hub `multi-agent-company`).
