#!/usr/bin/env bash
# tmux plugins aren't stored in the repo; fetch tpm and let it install the rest.
set -euo pipefail

command -v tmux >/dev/null || exit 0

tpm="$HOME/.config/tmux/plugins/tpm"
[ -d "$tpm/.git" ] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
"$tpm/bin/install_plugins"
