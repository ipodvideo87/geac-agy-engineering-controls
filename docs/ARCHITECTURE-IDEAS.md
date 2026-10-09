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
