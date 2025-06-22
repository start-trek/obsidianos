# 1 Context  *(≤50 words)*

ObsidianOS accelerates bulk note creation & editing for traders and quants by layering a local **Python 3.12 FastAPI** micro‑service and **SvelteKit/Svelte‑Grid** UI over the Obsidian vault, achieving <5 s batch ops and 99.9 % reliability requirements \[§2] \[§10].

# 2 High‑Level Architecture Diagram

```mermaid
graph LR
  UI[SvelteKit Table UI (Svelte‑Grid + shadcn)]
  API[FastAPI (ASGI, asyncio)]
  Vault[(Local Markdown Vault)]
  CSV[pandas CSV Module]
  YAML[Front‑matter YAML Engine]
  Log[JSON Lines Event Logger]

  UI -- HTTP (localhost) --> API
  API -- read / write --> Vault
  API --> CSV
  API --> YAML
  API --> Log
  CSV --- Vault
  YAML --- Vault
  Log --> Vault
```

# 3 Component Responsibilities

| ID | Component        | Key Duties                                                    | Perf / SLIs              |
| -- | ---------------- | ------------------------------------------------------------- | ------------------------ |
| C1 | **UI**           | Render table, inline‑edit YAML, filter/sort \[§5]             | FCP <500 ms for 1 k rows |
| C2 | **API**          | Async CRUD notes, batch writer (asyncio), schema validation   | P99 batch latency <5 s   |
| C3 | **CSV Module**   | Stream import/export ≥1 GB files; embed schema header         | Throughput ≥50 MB/s      |
| C4 | **YAML Engine**  | Parse & patch front‑matter safely                             | 0 error rate in tests    |
| C5 | **Logger**       | Append JSON‑Lines events (note\_loaded, csv\_exported) \[§12] | 0 loss, rotate daily     |
| C6 | **File Watcher** | watchdog monitors vault changes; triggers UI refresh          | Detect <1 s              |

# 4 Data Flow (Happy Path)

1. UI requests `/notes?limit=1000` → API.
2. API lazily scans vault via glob; streams metadata.
3. User edits cell; UI PATCHes `/note/{id}`.
4. API patches YAML, writes file atomically, emits `yaml_edited`.
5. CSV export triggers asynchronous stream to browser; file saved with schema header.
6. watchdog detects external vault edits → API push‑notifies UI via SSE.

# 5 Deployment & Ops

* Runs **locally** on macOS/Linux/Windows with ≤5 ms disk IO \[§8].
* Single‑process FastAPI+uvicorn; UI dev on port 5173 or served statically.
* Health‑check cron ping + on‑disk backups before batch writes (single‑level "undo").
* JSON‑Lines logs rotated daily; log viewer CLI planned.
* No external network calls; all data remains on workstation \[§10].

# 6 NFR Alignment & Scalability

* **Performance**: In‑memory caching and asyncio I/O meet 2 s load & 10 s export targets.
* **Reliability**: Atomic temp‑file writes + Jest/pytest suite (≥90 % coverage).
* **Security**: Process sandbox; allowlist FS paths.
* **Scalability**: Lazy generators enable ≥10 k notes within RAM budget.

# 7 Architecture Decision Record (ADR) Summary

| #       | Decision                                         | Rationale                                                                                              |
| ------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| ADR‑001 | **Async framework: FastAPI**                     | Mature ASGI stack, first‑class asyncio, rich extensions.                                               |
| ADR‑002 | **File‑watch: watchdog**                         | Cross‑platform FS events with <1 s latency; minimizes polling overhead.                                |
| ADR‑003 | **CSV schema versioning**                        | Prepend comment header `# obsidianos_csv_schema: 1.0.0`; semver bump on breaking change; API enforces. |
| ADR‑004 | **Front‑end table lib: Svelte‑Grid + shadcn/UI** | Virtual‑scroll support, lightweight, aligns with existing SvelteKit stack.                             |
| ADR‑005 | **Logging format: JSON Lines**                   | Human‑readable, streamable, easy ingestion by log tools.                                               |

# 8 Open Questions  *(currently none)*

All previously raised questions have been resolved; future items will be tracked in the project board.
