# GitHub Security Audit Rule

Each time new code is pushed to GitHub, spawn a subagent to run a security audit over the pushed code before treating the push as complete.

The audit should check for private information, secrets, credentials, tokens, personal data, and accidental sensitive project details in the code or supporting files.
