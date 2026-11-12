# tcat_ref <repository>: which branch of a sibling TransientCatalysis repository
# CI should install. Sourced, never executed: `. "$RUNNER_TEMP/tcat_ref.sh"`.
#
# Cross-repository changes (COLLABORATION.md): on a pull request, a sibling is
# installed from the branch of the SAME NAME when that branch exists, so a change
# spanning several repositories goes green in each of them before any merges;
# otherwise from main. Existence is checked explicitly, never by falling back on an
# install FAILURE -- that would test main whenever the branch is broken, and report
# green on code nobody asked about.
#
# Every standard and tool is public, so no credential is needed. HUB_TOKEN is used
# only when the CALLER sets it, for a private dependency; a workflow that installs
# only public siblings sets nothing.
tcat_ref() {
  local b="${GITHUB_HEAD_REF:-}" rc=0
  local url="https://github.com/TransientCatalysis/$1.git"
  if [ -n "${HUB_TOKEN:-}" ]; then
    url="https://x-access-token:${HUB_TOKEN}@github.com/TransientCatalysis/$1.git"
  fi
  # Dependabot gives every repository the SAME branch names
  # (dependabot/github_actions/actions/checkout-7.0.1), so matching one would
  # install a sibling's own, possibly stale, Dependabot branch instead of main.
  case "$b" in ""|main|dependabot/*) echo main; return 0 ;; esac
  # From OUTSIDE the checkout: actions/checkout writes this repository's own
  # GITHUB_TOKEN into the checkout's local git config as an Authorization
  # extra-header, which git would send instead of a token in the URL.
  git -C "${RUNNER_TEMP:-/tmp}" ls-remote --exit-code --heads "$url" "refs/heads/$b" >/dev/null 2>&1 || rc=$?
  case "$rc" in
    0) echo "::notice::$1 installed from branch $b, not main" >&2; echo "$b" ;;
    2) echo main ;;
    *) echo "::error::could not query $1 for branch $b (git exit $rc)" >&2; return 1 ;;
  esac
}
