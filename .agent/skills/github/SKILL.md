---
name: Github
description: "Git and GitHub integration for code management, repository operations, and collaboration. Use when users need to: (1) Push code to GitHub repositories, (2) Clone or interact with repositories, (3) Manage branches, commits, or pull requests, (4) View repository contents or history, (5) Configure git settings, or (6) Work with GitHub-hosted code. Always provide GitHub links when code is pushed."
---

# GitHub Integration

This skill enables comprehensive Git and GitHub operations, from basic version control to advanced repository management.

## Critical Rule: Always Provide GitHub Links

**IMPORTANT:** Whenever code is pushed to GitHub, ALWAYS include a direct link to the code in your response.

### Link Formats

**Repository:** `https://github.com/<username>/<repo>`

**Specific file:** `https://github.com/<username>/<repo>/blob/<branch>/<path-to-file>`

**Commit:** `https://github.com/<username>/<repo>/commit/<commit-hash>`

**Branch:** `https://github.com/<username>/<repo>/tree/<branch-name>`

**Pull request:** `https://github.com/<username>/<repo>/pull/<pr-number>`

### Example Response After Push

```
Successfully pushed your code to GitHub! 

View your code here: <insert the Github commit URL here>
```

## Link Formatting Best Practices

- Use the full GitHub URL, not shortened versions
- Link to the specific branch where code was pushed
- For multi-file pushes, link to the repository root or most important file
- Include the commit hash in links when referencing specific versions
- For pull requests, link to the PR page after creation

