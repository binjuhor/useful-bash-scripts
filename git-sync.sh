#!/usr/bin/env bash

set -euo pipefail

VERSION="0.1.0"

usage() {
    cat <<EOF
git sync - GitLab → GitHub repository sync

Usage:
  git sync <gitlab-url> [--force]

Examples:
  git sync git@gitlab.com:binjuhor/elisyam.git
  git sync https://gitlab.com/binjuhor/elisyam.git
  git sync git@gitlab.com:binjuhor/elisyam.git --force

Options:
  --force    Allow overwriting a non-empty GitHub repository
  -h, --help Show this help
  -v, --version Show version

Requirements:
  git
  gh
EOF
}

log() {
    printf '%s\n' "$*"
}

success() {
    printf '✓ %s\n' "$*"
}

error() {
    printf '✗ %s\n' "$*" >&2
    exit 1
}

cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

FORCE=false
GITLAB_URL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            echo "$VERSION"
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            ;;
        *)
            if [[ -n "$GITLAB_URL" ]]; then
                error "Only one GitLab repository URL is allowed."
            fi

            GITLAB_URL="$1"
            shift
            ;;
    esac
done

[[ -n "$GITLAB_URL" ]] || {
    usage
    exit 1
}

# ------------------------------------------------------------
# Check dependencies
# ------------------------------------------------------------

command -v git >/dev/null 2>&1 || error "git is required."
command -v gh >/dev/null 2>&1 || error "GitHub CLI (gh) is required."

gh auth status >/dev/null 2>&1 || {
    error "GitHub CLI is not authenticated. Run: gh auth login"
}

# ------------------------------------------------------------
# Parse GitLab repository URL
# ------------------------------------------------------------

GITLAB_URL="${GITLAB_URL%.git}"

GITLAB_PATH=""

case "$GITLAB_URL" in
    git@gitlab.com:*)
        GITLAB_PATH="${GITLAB_URL#git@gitlab.com:}"
        ;;
    ssh://git@gitlab.com/*)
        GITLAB_PATH="${GITLAB_URL#ssh://git@gitlab.com/}"
        ;;
    https://gitlab.com/*)
        GITLAB_PATH="${GITLAB_URL#https://gitlab.com/}"
        ;;
    http://gitlab.com/*)
        GITLAB_PATH="${GITLAB_URL#http://gitlab.com/}"
        ;;
    *)
        error "Unsupported GitLab URL:
$GITLAB_URL

Supported formats:
  git@gitlab.com:owner/repository.git
  https://gitlab.com/owner/repository.git"
        ;;
esac

# Remove accidental leading/trailing slashes.
GITLAB_PATH="${GITLAB_PATH#/}"
GITLAB_PATH="${GITLAB_PATH%/}"

if [[ "$GITLAB_PATH" != */* ]]; then
    error "Could not determine GitLab owner/repository from:
$GITLAB_URL"
fi

GITHUB_OWNER="${GITLAB_PATH%%/*}"
GITHUB_REPO="${GITLAB_PATH##*/}"

[[ -n "$GITHUB_OWNER" ]] || error "GitLab owner is empty."
[[ -n "$GITHUB_REPO" ]] || error "GitLab repository name is empty."

GITHUB_REPO_FULL="${GITHUB_OWNER}/${GITHUB_REPO}"
GITHUB_SSH_URL="git@github.com:${GITHUB_REPO_FULL}.git"
GITHUB_URL="https://github.com/${GITHUB_REPO_FULL}"

echo
echo "GitLab → GitHub Sync"
echo
echo "  Source:      $GITLAB_URL"
echo "  Repository:  $GITHUB_REPO_FULL"
echo "  Visibility:  private"
echo

# ------------------------------------------------------------
# Check whether GitHub repository exists
# ------------------------------------------------------------

REPO_EXISTS=false

if gh repo view "$GITHUB_REPO_FULL" >/dev/null 2>&1; then
    REPO_EXISTS=true
    success "GitHub repository exists."
else
    log "→ GitHub repository does not exist."
fi

# ------------------------------------------------------------
# Create GitHub repository if necessary
# ------------------------------------------------------------

if [[ "$REPO_EXISTS" == false ]]; then
    log "→ Creating private GitHub repository..."

    gh repo create "$GITHUB_REPO_FULL" \
        --private \
        --confirm >/dev/null

    success "GitHub repository created."
else
    # --------------------------------------------------------
    # Existing repository: check whether it is empty
    # --------------------------------------------------------

    log "→ Checking GitHub repository..."

    REMOTE_HEAD=""

    if REMOTE_HEAD="$(git ls-remote --symref "$GITHUB_SSH_URL" HEAD 2>/dev/null)"; then
        if printf '%s\n' "$REMOTE_HEAD" | grep -q $'\tHEAD$'; then
            if [[ "$FORCE" != true ]]; then
                error "GitHub repository is not empty.

Repository:
  $GITHUB_URL

Use --force if you intentionally want to overwrite it."
            fi

            log "⚠ GitHub repository is not empty."
            log "→ --force supplied; repository will be overwritten."
        fi
    fi
fi

# ------------------------------------------------------------
# Create temporary mirror
# ------------------------------------------------------------

TEMP_DIR="$(mktemp -d)"

MIRROR_DIR="$TEMP_DIR/${GITHUB_REPO}.git"

echo
log "→ Cloning GitLab repository as mirror..."

git clone --mirror "$GITLAB_URL" "$MIRROR_DIR"

success "GitLab repository cloned."

# ------------------------------------------------------------
# Configure GitHub remote
# ------------------------------------------------------------

cd "$MIRROR_DIR"

git remote remove origin 2>/dev/null || true
git remote add origin "$GITHUB_SSH_URL"

# ------------------------------------------------------------
# Push everything
# ------------------------------------------------------------

echo
log "→ Pushing branches, tags and history to GitHub..."

if [[ "$FORCE" == true ]]; then
    git push --mirror --force origin
else
    git push --mirror origin
fi

success "All branches, tags and Git history synced."

# ------------------------------------------------------------
# Final result
# ------------------------------------------------------------

echo
echo "🎉 Sync completed!"
echo
echo "GitHub:"
echo "$GITHUB_URL"
echo
