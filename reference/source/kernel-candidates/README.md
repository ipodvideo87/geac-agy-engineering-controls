# Recovered `GEMINI.md` kernel candidates

The archives contain several global-kernel revisions. They do not identify a later promoted kernel for the R3 v2 skills-and-hooks setup. These files are preserved as references; the installer does not copy any of them to the global profile.

The former profile's exact 9,544-byte `GEMINI.md` was recovered under [`../historical-setups/X1-R4/GEMINI.md`](../historical-setups/X1-R4/GEMINI.md). Its SHA-256 `96231f08f168d877912e2503b4059026dda34e2fb00512c20c096d34cfa50cdf` matches the X1-R4 receipt's `postSha256`. It identifies itself as an experimental baseline and **NOT A PROMOTION CANDIDATE**. It was present alongside the eight skills and hooks; that does not prove runtime loading or adherence. It is preserved with the exact R4 skills and pre-FG-v1 protocol hook, omitted from default installs, and available only through the installer's explicit trial opt-in.

| Candidate | Source and status | Packaging treatment |
|---|---|---|
| GEAC V1 | `GEAC-2026-08-14-V1.zip`; frozen reference, Contract ID `GEAC-2026-08-14-V1` | Kernel and six normative modules are preserved under [`GEAC-V1-FROZEN/`](GEAC-V1-FROZEN/). |
| X1-R4 historical profile kernel | Exact former-profile file, confirmed by matching the X1-R4 receipt's post-change hash; explicitly experimental and **NOT A PROMOTION CANDIDATE** | Exact kernel, eight skills, and R4 protocol hook are preserved under [`../historical-setups/X1-R4/`](../historical-setups/X1-R4/); kernel excluded by default, explicit trial opt-in only. |
| V1.1 D1 and D2 | Candidate kernels for controlled validation; explicitly not promoted over V1 | D2 is preserved in `../archives/GEAC_V1_1_Candidate_D2.zip`. D1 remains in the local recovery library. |
| E2 previews | Design/testing previews; explicitly not frozen or promoted | Preview archives are preserved under `../archives/`. |
| X1 | Latest recovered kernel by archive timestamp; Contract ID `GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE`; explicitly **NOT A PROMOTION CANDIDATE** | Preserved at [`../x1-original/payload/GEMINI.md`](../x1-original/payload/GEMINI.md). It is not installed. |

R3 v2 provides the latest recovered skill discovery descriptions. X1-R4 later normalized all eight skill identifiers and added a protocol hook; FG-v1 later replaced that hook with full-body forced loading. These chronology facts do not change the R4 kernel's explicit experimental status. The research conversation describes bootstrap ownership as unresolved and a plugin topology as a research hypothesis. The default installer does not activate the kernel; an explicit opt-in supports a controlled trial with the standalone skills and hooks.
