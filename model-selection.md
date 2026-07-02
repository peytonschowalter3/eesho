# Model Selection — OpenRouter Scan

*Prices and context windows change frequently on OpenRouter — verify final numbers at openrouter.ai/models immediately before submission, since this is a hard-gate deliverable.*

LifeAdmin AI's core AI workload is document extraction (OCR'd contracts/emails, often non-English), plain-language explanation, and formal email drafting — not code generation. Selection criteria below are weighted toward multilingual document understanding, long-context handling (contracts can run long), and low hallucination risk on dates/obligations, over raw coding benchmarks.

## Recommended: Claude Sonnet 4.6 (`anthropic/claude-sonnet-4-6`)
<cite index="8-1">Sonnet 4.6 is Anthropic's most capable Sonnet-class model, with frontier performance across coding, agents, and professional work, and it's built for polished document creation.</cite>
- **Why:** best fit for the explanation + formal-drafting steps, where tone control (dry/irreverent in-app, neutral in outbound emails per AGENTS.md) matters as much as raw extraction accuracy.
- **Cost / context:** verify current pricing and context window on the model's OpenRouter page before submitting — not confirmed via this scan.
- **Privacy posture:** Anthropic's standard API terms do not train on customer data by default — good fit for a product handling sensitive personal documents.

## Cheap: DeepSeek V4 Flash (`deepseek/deepseek-v4-flash`)
<cite index="15-1">DeepSeek V4 Flash is a MIT-licensed, ~284B-parameter / ~13B-active Mixture-of-Experts model with a 1M-token context window, scoring 79.0% on SWE-bench Verified — within about 1.6 points of the larger V4 Pro model.</cite> <cite index="15-1">DeepSeek's first-party API prices it at $0.14/$0.28 per million tokens (input/output), dropping further with caching, though DeepSeek retains and trains on submitted data</cite>; no-train Western hosts (Fireworks, Together, DeepInfra) charge roughly double that.
- **Why:** extremely low cost, huge context window (useful for long contracts), strong benchmark scores.
- **Privacy caveat — important for this product:** the first-party endpoint trains on your data by default. Given LifeAdmin AI processes personal contracts and correspondence, this is a real constraint — either route through a no-train Western host on OpenRouter (at ~2x price) or exclude this model from any path that touches real user documents, and say so explicitly in the writeup.

## Trending: GLM 5.2 (`z-ai/glm-5.2`)
<cite index="15-1">GLM is described as the new open-model quality leader as of June 2026</cite>, and separately <cite index="9-1">GLM 5.2 is a large-scale reasoning model from Z.ai supporting a 1M-token context window, suited for long-horizon workflows and complex multi-step automation.</cite>
- **Why:** currently trending on OpenRouter's usage rankings, long context window fits multi-document/long-contract use cases.
- **Cost / privacy posture:** verify directly on OpenRouter — not confirmed via this scan.

## What to do before submitting
1. Pull live pricing + context window for all three from openrouter.ai/models and fill the gaps marked "verify" above.
2. Decide and document DeepSeek's data-training caveat explicitly — this is exactly the kind of privacy-posture judgment call the assignment is checking for, not just a spec sheet.
