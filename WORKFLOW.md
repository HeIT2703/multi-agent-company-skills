# Workflow — Multi-Agent Company (24 giai đoạn)

> Sơ đồ trực quan cách hệ thống vận hành. GitHub render Mermaid trực tiếp.

---

## 1. Toàn cảnh: 8 pha × 3 giai đoạn

```mermaid
flowchart TD
    Idea([Y tuong]) --> Setup
    Setup[["BUOC 0: Setup<br/>harness-integration + init-context.sh<br/>sinh .context/"]]
    Setup --> P1

    subgraph P1["PHA 1 - DISCOVER - Hieu van de"]
        direction LR
        G1[GD1 Thinking] --> G2[GD2 Research] --> G3[GD3 Personas]
    end

    subgraph P2["PHA 2 - VALIDATE - Chung minh"]
        direction LR
        G4[GD4 Interviews H] --> G5[GD5 Experiments] --> G6{GD6 Demand<br/>+ Waitlist}
    end

    subgraph P3["PHA 3 - DEFINE - Dinh nghia"]
        direction LR
        G7[GD7 Requirements H] --> G8{GD8 MVP<br/>Prioritization} --> G9[GD9 Feasibility]
    end

    subgraph P4["PHA 4 - DECIDE - Chot huong"]
        direction LR
        G10[GD10 Shaping H] --> G11[GD11 Threat Model]
    end

    subgraph P5["PHA 5 - BLUEPRINT - Vien ngoc"]
        direction LR
        G12[GD12 Architecture] --> G13[GD13 UX/UI] --> G14{GD14 Planning<br/>CONG NGHIEM NHAT}
    end

    subgraph P6["PHA 6 - BUILD - Xay"]
        direction LR
        G15[GD15 Scaffolding] --> G16[GD16 Spike] --> G17[GD17 Code] --> G18[GD18 QA]
    end

    subgraph P7["PHA 7 - HARDEN - Toi luyen"]
        direction LR
        G19[GD19 Staging] --> G20[GD20 Audit 3 phan] --> G21{GD21 Khac phuc}
    end

    subgraph P8["PHA 8 - LAUNCH - Ra mat"]
        direction LR
        G22[GD22 Release H] --> G23[GD23 Production] --> G24[GD24 Retro 10/10]
    end

    P1 --> P2
    G6 -->|GO| P3
    G6 -.->|PIVOT| G1
    G6 -.->|KILL| Stop([Dung])
    P3 --> P4 --> P5
    G14 -.->|chua dat| G12
    P5 --> P6 --> P7
    G21 -->|PASS| P8
    G21 -.->|BLOCKED max 3| G21
    G24 -.->|feedback| G1

    classDef gate fill:#ffe6cc,stroke:#d79b00,stroke-width:2px;
    class G6,G8,G14,G21 gate;
```

H = human-checkpoint (GD4, 7, 10, 22) · {} = cong chan (GD6, 8, 14, 21)

---

## 2. Bon cong chan song con

```mermaid
flowchart LR
    A[Validate xong] --> G6{CONG<br/>VALIDATION<br/>GD6}
    G6 -->|demand dat| B[Define MVP]
    G6 -->|khong dat| PIVOT[Pivot/Kill]

    B --> G8{CONG MVP<br/>GD8}
    G8 -->|MVP chot| C[Blueprint]
    G8 -->|chua ro| B

    C --> G14{CONG<br/>BLUEPRINT<br/>GD14}
    G14 -->|cover 100pct| D[Build]
    G14 -->|thieu| C

    D --> G20[Audit GD20] --> G21{CONG<br/>AUDIT}
    G21 -->|score dat| E[Launch]
    G21 -->|chua dat| D

    classDef gate fill:#ffe6cc,stroke:#d79b00,stroke-width:2px;
    class G6,G8,G14,G21 gate;
```

| Cong | Chan gi | Y nghia |
|------|---------|---------|
| **Validation (GD6)** | Khong co nhu cau that -> khong code | Chong "build cai khong ai can" |
| **MVP (GD8)** | Chua chot MVP -> khong thiet ke | Chong "build moi thu cung luc" |
| **Blueprint (GD14)** | Thiet ke chua chat -> khong code | Chong "code tren nen lung lay" |
| **Audit (GD20-21)** | Chua dat diem -> khong ra mat | Chong "ship hang loi" |

---

## 3. Vong doi 1 agent trong 1 phien (Hydrate -> Write-back)

```mermaid
flowchart TD
    Wake([Agent duoc danh thuc]) --> H
    H["1. HYDRATE<br/>doc manifest + state + charter<br/>+ L0-L3 lien quan"] --> V
    V{"2. VALIDATE<br/>khop requirements/<br/>architecture/glossary?<br/>vi pham rule?"}
    V -->|mau thuan| Stop([DUNG - bao orchestrator])
    V -->|OK| E
    E["3. EXECUTE<br/>lam trong quyen GHI (RBAC)<br/>bam rule cung"] --> W
    W["4. WRITE-BACK<br/>sessions/ + progress.md<br/>+ ADR + state.yaml (qua script)<br/>+ changelog"] --> Next
    Next([Phien sau HYDRATE lai<br/>-> context day du])
```

---

## 4. Cach 7 skill phoi hop

```mermaid
flowchart TD
    HUB["multi-agent-company (HUB)<br/>doc state -> quyet GD -> goi skill"]
    HUB --> PD[product-discovery<br/>GD1-8]
    HUB --> DG[decision-gates<br/>GD7,9,10 + tech rules]
    HUB --> SSOT[ssot-context-sync<br/>moi GD]
    HUB --> QG[quality-gates<br/>chuyen GD]
    HUB --> DA[deep-audit<br/>GD20-21]
    HUB --> HI[harness-integration<br/>buoc 0]

    PD --> CTX[(.context/ SSOT)]
    DG --> CTX
    SSOT --> CTX
    QG --> CTX
    DA --> CTX
    HI --> CTX

    CTX -.doc/ghi.-> A1[researcher]
    CTX -.doc/ghi.-> A2[product-validator]
    CTX -.doc/ghi.-> A3[architect]
    CTX -.doc/ghi.-> A4[engineers]
    CTX -.doc/ghi.-> A5[auditor]
```

> Agent KHONG noi chuyen truc tiep. Moi giao tiep qua artifact trong .context/.

---

## 5. Chay thuc te (CLI dieu khien)

Dung `run.sh` de biet "gio phai lam gi":

```bash
# Khoi tao du an
bash run.sh init ./my-project "Ten du an" small saas

# Xem trang thai hien tai + gate + lenh tiep theo
bash run.sh status ./my-project

# Qua cong giai doan hien tai -> sang giai doan ke
bash run.sh advance ./my-project

# Ghi quyet dinh cong validation (GD6)
bash run.sh validate ./my-project go      # hoac pivot / kill

# Xem checklist gate cua giai doan hien tai
bash run.sh gate ./my-project
```

Xem chi tiet: `multi-agent-company/SKILL.md` (HUB) + `multi-agent-company/references/pipeline.md`.
