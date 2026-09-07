# Agents.md

Guidance for using LLM-based coding assistants (Claude Code, Copilot, etc.) on this repository.

## LLM Usage Policy

Using an LLM to help write code is fine. Reviewers just need to know when it happened, so they can weigh the review accordingly — code that reads unusually verbose, follows an unfamiliar pattern, or touches a lot of files at once often has an LLM behind it, and reviewers benefit from knowing that up front.

**Rule:** if an LLM generated a substantial part of a commit (not just autocomplete or minor suggestions), add a trailer to the commit message:

```
Assisted-by: LLM
```

- Use the generic `LLM` value — don't name the specific product/vendor. The point is disclosure to reviewers, not advertising a tool.
- Trivial LLM use (autocomplete, one-line suggestions, boilerplate you'd have typed anyway) doesn't need the trailer.
- Substantial use — generated functions, whole files, non-trivial refactors, generated tests — does.
- You're still fully responsible for the code you commit. Review, understand, and test it before committing, regardless of how it was produced.

## Example

```
fix: handle nil schedule in conference import

Assisted-by: LLM
```
