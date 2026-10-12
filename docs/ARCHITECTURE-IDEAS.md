# Order of Engineering and agent architecture ideas

**Status:** Research capture, not an implementation specification.
**Source:** Full conversation export `Gemini WSL Investigation.md` and the shared conversation [“Gemini WSL Investigation”](https://chatgpt.com/share/6ac91bb8-5b0c-83e8-8d71-d49830065861).

The conversation's later design work expands beyond the standalone skills and hooks. It explores how an engineering-control system might coordinate a bootstrap contract, the eight gates, Order of Engineering (OoE), specialist skills, agents, permissions, lifecycle hooks, and claim admission. The discussion explicitly leaves the architecture and bootstrap owner open.

## Order of Engineering

OoE is described as a dynamic way to derive the order of work from the authoritative objective, current state, and dependencies:

```text
authoritative objective
        ↓
current established state
        ↓
dependencies and blocking gaps
        ↓
derive the justified order of work
        ↓
propose necessary actions
        ↓
verify results and update state
        ↓
admit only supported claims and completion
```

The key ideas are:

- A derived objective or state does not become authoritative merely because the agent produced it.
- OoE should be established before substantive execution.
- A candidate action, a necessary action, and an authorized action are different states.
- Re-entry and context growth should have a reason; each validation pass must justify its trajectory cost.
- Completion cannot exceed the established criteria.

The discussion argues against encoding generalized OoE as a normal relevance-selected skill or a rigid, linear workflow. A small always-present constitution and a pre-invocation composer are candidate homes. The conversation does not choose between a global rule, a primary agent, or a `PreInvocation` kernel, and it does not provide a frozen OoE contract.

## Candidate component responsibilities

| Component | Candidate responsibility | Status in the conversation |
|---|---|---|
| Small bootstrap or constitution | Preserve objective authority, derived-state boundaries, OoE-before-execution, justified re-entry, and criteria-bounded completion | Candidate; bootstrap owner unresolved |
| `PreInvocation` composer | Inject the eight gates, experimental A/B/C mode, and an OoE contract in an intentional order | Strong candidate; token cost and persistence need runtime measurement |
| Required-gate skills | Own focused semantic controls; the recovered FG-v1 hook loads their complete text | Recovered standalone mechanism; model compliance remains unproven |
| Specialist skills | Supply domain expertise | Intended to remain separate from meta-engineering control |
| `PreToolUse` and permissions | Enforce whether a proposed action may execute | Keep authorization distinct from reasoning about necessity |
| `PostToolUse` | Observe tool results and provide telemetry/evidence for state updates | Candidate observer; not established as the main reasoning controller |
| Claim admission | Bound material output claims to evidence and semantic-owner decisions | Exact R2 hook is an advisory `PreInvocation` reminder; stronger output validation remains open |
| `Stop` | Potentially prevent premature closure | Candidate only; continuation costs another model invocation |

The research also favors one ordered composer if several injected parts require a particular sequence. The runtime documentation does not guarantee ordering among separate hooks, so an architecture that depends on such ordering needs a single composition point or direct runtime evidence.

## Agents and subagents

The proposed division is:

```text
PRIMARY / OoE
  decides which proposition needs investigation
        ↓
BOUNDED SUBAGENT
  receives a narrow prompt, tools, and workspace
  investigates that proposition and returns evidence/source relations
        ↓
PRIMARY
  evaluates the returned evidence and updates authoritative task state
```

Subagents are proposed as bounded engineering functions and context-isolated evidence workers. They do not take ownership of the authoritative objective, global work order, permission, readiness, or final root-cause decision. The primary agent retains those responsibilities. The conversation also warns that including an engineering agent in a plugin does not establish that the plugin automatically selects it as the primary agent.

## Experiments and open questions

The conversation proposes three integration variants—direct gates (A), explicit synthesis/re-entry (B), and same-invocation synthesis (C)—and defers changing reinjection strategy until those variants are isolated. It proposes measuring invocations, steps, tool and subagent calls, token use, gate-injection size, answer size, context percentage, checkpoint events, and semantic defects.

Open questions include bootstrap selection, plugin rule activation, primary-agent selection, hook ordering, repeated injection cost, transcript timing for `PostInvocation`, claim validation without an unnecessary extra model pass, `Stop` continuation cost, subagent authority limits, and compaction behavior. The conversation classifies the plugin composition and internal topology as research, not a frozen release design.

These ideas are included so the design trajectory is preserved. The current installer does not create a plugin, add agents/subagents, implement OoE, or claim that claim admission is mechanically enforced.

## Evidence captured in the conversation

The same conversation also records a same-request comparison of an APK-lineage review:

- In the August 16 run, AGY natively read all eight engineering skills through separate file-view operations, then answered.
- In the August 18 FG-v1 run, the `PreInvocation` hook supplied all eight full gate bodies; the run did not need those file-view operations.
- The recorded trajectories were about 20 steps with eight separate file reads versus three steps with none. This is a step/tool-count difference, not a measured wall-clock latency result.
- The exported records show the extracted user request was identical. This was **native eight-skill loading versus forced eight-gate injection**, not “no gates versus gates.”
- FG-v1 was stronger on some lineage inferences and reduced much of an unsupported recommendation to require physical-device testing. It also weakened source attribution in the final summary by compressing “historical records report a successful result” into direct claims that the results occurred. Both runs retained semantic overreach around test, scan, and device-validation requirements.

The conversation explicitly cautions against attributing those differences to FG-v1 alone: the skill names and potentially their contents, `GEMINI.md`, hooks, or other control-plane text may have changed between runs. The defensible historical conclusion is that the same user request produced observably different trajectories and answers under two configurations. It is not a clean activation-only causal test, a timing result, or proof of overall improvement. The conversation also calls for recovery of the full earlier response and a direct comparison of the skill bodies before making stronger claims.

## Later architecture research: state at the end of the conversation

The historical setup being recovered was standalone skills and hooks; it did not require a plugin. Later in the same conversation, after reviewing how the pieces fit together, the user proposed building a plugin in the future and asked to complete research first. The plugin is therefore a later composition hypothesis, not part of the recovered setup or a completed release. The final conversation state is still D1 research; it does not authorize treating the topology below as frozen.

The conversation's end-of-research snapshot was explicitly tied to **Antigravity CLI 1.1.14**. Its statuses below reproduce what that research recorded; re-check current CLI behavior before implementation.

| Area | State recorded in the conversation | Consequence for design |
|---|---|---|
| Plugin composition | CLI plugins can bundle skills, agents, rules, hooks, and MCP configuration; CLI staging path was identified. | Plugin is the strongest candidate as a versioned composition boundary, not a solution to each control problem by itself. |
| Native skills | Progressive/relevance-based loading was observed and documented. | Keep domain-specialist skills native; mandatory meta-engineering gates cannot depend on relevance selection. |
| `PreInvocation` | Runs before model invocations, exposes `invocationNum`, and can inject transient system content. | Strong candidate for one ordered composer containing the gates and selected experiment contract. |
| `PreToolUse` | Supports `allow`, `deny`, `ask`, `force_ask`, and `deny_unless_prior_grant`, plus permission overrides. | Use it for mechanical authorization. Necessity belongs to reasoning/OoE; permission, necessity, and whether to act now remain distinct. |
| `PostToolUse` | Provides executed-tool and result/error telemetry; it cannot itself inject state. | Treat it as an observer, not the primary reasoning controller. |
| `PostInvocation` | Runs after a model invocation but does not directly receive response text. | Do not assume it can perform output-claim validation without a proven transcript-timing mechanism. |
| `Stop` | Can trigger another model loop. | Possible closure control, with an extra-invocation and context cost to measure. |
| Multiple hooks | Cross-hook order was not documented. | If message order matters, prefer one composer or establish runtime ordering experimentally. |
| Plugin rules | A plugin can package rules, but their Always-On activation semantics for this CLI version were unresolved. | Do not make the bootstrap depend on plugin rules until tested. |
| Custom agent | Agents can carry specialized instructions and can be selected as primary; plugin installation automatically selecting one was not established. | Primary-agent packaging remains a runtime question. |
| Subagents | The research found clean context, controllable tools/permissions, and plugin packaging. | Use bounded subagents to return evidence; keep objective ownership, authorization, readiness, and final conclusions with the primary. |
| Context and compaction | Context/token metrics were available; compaction semantics were not sufficiently documented. | Measure context directly and characterize compaction from runtime traces rather than assumption. |

The evolving candidate topology was: an unresolved bootstrap owner (plugin rule, selected primary agent, or `PreInvocation` kernel); a single ordered `PreInvocation` composer for the eight gates, A/B/C mode, and OoE contract; native specialist skills and bounded subagents; `PreToolUse` for authorization; telemetry/state updates after tools; and output/claim admission plus conditional stopping, both with unresolved implementation details. The transcript distinguishes model-behavior controls (rules, skills, reasoning contracts) from mechanical permission enforcement.

### Proposed experiments and sequencing

The conversation defines three integration variants:

| Variant | Intended flow |
|---|---|
| **A — Direct** | Eight gates → Order of Engineering → reason. |
| **B — Explicit synthesis** | Eight gates → separate synthesis/re-entry → Order of Engineering → reason. |
| **C — Same-invocation synthesis** | Eight gates → synthesis and Order of Engineering within the same invocation → reason. |

It cautions that C's internal synthesis may not be observable. `CONTROL_STATE` must remain a derived projection: it cannot replace, weaken, override, or certify compliance with the authoritative user objective, eight gates, established evidence, or actual permissions. The generalized OoE table is a dependency-resolution decision model, not a mandatory fifteen-step workflow or fifteen model calls. The conversation also defers changes to how gates are re-injected until A/B/C are isolated, so that added variables do not compromise the comparison.

The proposed sequence is three design rounds—D1 architecture/semantics, D2 runtime mechanics, D3 adversarial review and freeze—followed by three frozen-configuration tests: T1 the exact APK-lineage fixture, T2 objective/order/authorization drift, and T3 long-context, compaction, and generalization. Proposed measures include steps and model invocations; tool and subagent calls; injected gate hashes and byte size; input, output, and cache-read tokens; context-window percentage; checkpoint events; transcript size; and externally scored semantic defects. Design changes belong between runs, not during a measured run.

The final D1 snapshot leaves these items open for research before a polished plugin is built:

1. Plugin-rule Always-On behavior in the pinned CLI.
2. Custom-agent discovery/selection, and whether a plugin can select its agent as primary.
3. Hook precedence and whether one plugin can own required hooks without undocumented order assumptions.
4. `ephemeralMessage` persistence and context cost on the first and later invocations.
5. Whether `PostInvocation` can inspect a completed answer through the transcript, and when that transcript is written.
6. How `PreToolUse` decisions compose with cached grants, `force_ask`, `deny_unless_prior_grant`, and permission overrides.
7. `Stop` continuation limits and their trajectory/context cost.
8. Checkpoint/compaction behavior and whether authoritative controls survive or must be reconstructed.
9. Whether disabling a plugin cleanly removes all of its runtime effects.
10. What the A/B/C instrumentation can prove directly versus infer from behavior.

These later findings materially inform the future design, but they do not change the recovered standalone payload. They are captured from the shared conversation and were not independently re-verified against a newer AGY release during this recovery.
