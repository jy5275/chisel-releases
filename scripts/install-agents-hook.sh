#!/usr/bin/env bash
# Install a post-checkout hook that materializes AGENTS.md into the working
# tree of any branch whose tree does not contain it, by pulling the file
# from this fork's `main` branch. The hook is per-repo (lives in .git/hooks/)
# so it is never committed and never leaks into release-branch PRs.
#
# AGENTS.md itself is tracked on `main` (so it syncs across machines via
# git push/pull). Only its *working-tree copy* on feat/release branches is
# untracked -- which is exactly what keeps it out of upstream PRs.
#
# Run once per fresh clone:
#   bash scripts/install-agents-hook.sh
set -euo pipefail

repo="$(git rev-parse --show-toplevel)"
hook="$repo/.git/hooks/post-checkout"
marker="# managed-by: scripts/install-agents-hook.sh"

if [ -f "$hook" ] && grep -qF "$marker" "$hook"; then
  echo "post-checkout hook already installed at $hook"
  exit 0
fi

if [ -f "$hook" ] && ! grep -qF "$marker" "$hook"; then
  echo "ERROR: a custom post-checkout hook already exists at $hook" >&2
  echo "       refusing to overwrite. Inspect it and integrate manually." >&2
  exit 1
fi

mkdir -p "$(dirname "$hook")"
cat >"$hook" <<EOF
#!/usr/bin/env bash
# $marker
# After any checkout, if the current branch's tree has no AGENTS.md but
# the fork's main branch does, write main's copy into the working tree as
# an untracked file. This keeps AGENTS.md available to agents on every
# feat/release branch without it ever being committed there.
set -euo pipefail

# Skip if this checkout already has AGENTS.md in its tree.
if git cat-file -e HEAD:AGENTS.md 2>/dev/null; then
  exit 0
fi

# Resolve a remote that carries our fork's main. Prefer 'fork', fall back
# to 'origin' (works when 'origin' points at the fork rather than upstream).
src_ref=""
for remote in fork origin; do
  if git rev-parse --verify --quiet "\$remote/main" >/dev/null; then
    src_ref="\$remote/main"
    break
  fi
done
if [ -z "\$src_ref" ]; then
  # No fork remote -- nothing we can do. Silent so checkout stays quiet.
  exit 0
fi

# Only restore if that remote's main actually has the file.
if ! git cat-file -e "\$src_ref:AGENTS.md" 2>/dev/null; then
  exit 0
fi

# Don't clobber an existing working-tree copy (user may be editing it).
if [ -e AGENTS.md ]; then
  exit 0
fi

git show "\$src_ref:AGENTS.md" >AGENTS.md
EOF
chmod +x "$hook"
echo "Installed post-checkout hook at $hook"
echo "AGENTS.md will now appear (untracked) on branches that lack it in their tree."