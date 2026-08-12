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
