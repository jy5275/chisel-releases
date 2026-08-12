# Fork

https://github.com/jy5275/chisel-releases.git is a fork of
https://github.com/canonical/chisel-releases.git. 

Sometimes the former's release branches may lag the latter's 
by several commits. Never commit directly to the fork's release 
branches -- they must stay clean, with no commits that the 
upstream (canonical) release branches do not have.


# Branching

Never commit slice work directly on a release branch (e.g. `ubuntu-26.04`).

For any new slice or slice change, create a feature branch off the target
release branch and land it via a PR into `canonical/chisel-releases`:

- Branch name convention: `feat-<release>-<package>` (e.g. `feat-26.04-libpython3.14`).
- Base the branch on the upstream release branch, not on `main`.
- Open a PR targeting the matching release branch (e.g. `ubuntu-26.04`).
- Keep the local release branch clean -- reset it to `origin/<release>`
  after moving commits onto the feature branch.

# Slicing

When adding a new slice, you must invoke the `write-slice` skill (from
the `chisel-releases` skill). Do not author or commit an SDF by hand.

# AGENTS.md on feat/release branches

This file is tracked only on the fork's `main` branch (so it is
version-controlled and syncs across machines via git push/pull). To make
it visible to agents on feat/release branches -- whose trees must stay
identical to upstream `canonical/chisel-releases` -- a per-repo
`post-checkout` hook materializes it into the working tree as an
**untracked** file whenever you switch to a branch whose tree lacks it.
Because it is untracked on those branches, it never leaks into upstream
release-branch PRs.

Install the hook once per fresh clone:

    bash scripts/install-agents-hook.sh

To update AGENTS.md: edit it on `main`, commit and push, then on any
other branch `rm AGENTS.md && git checkout <same-branch>` to let the
hook refresh it from the latest `main`.
