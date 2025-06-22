#!/usr/bin/env bash
set -e
echo ">> Creating Python virtual env via Poetry"
curl -sSL https://install.python-poetry.org | python3 -
poetry config virtualenvs.in-project true
poetry install --no-root
echo ">> Installing UI deps"
cd ui && pnpm install && cd ..

# optional: pre-build the Svelte UI for faster FCP
pnpm --prefix ui build

echo ">> Setting up pre-commit"
pre-commit install

# Install Poetry if absent
if ! command -v poetry &>/dev/null; then
  echo ">> Installing Poetry"
  curl -sSL https://install.python-poetry.org | python3 -
fi

# Ensure PATH contains Poetry bin
POE_DIR="$(python3 - <<'PY'
import sys, site, os
home = os.path.expanduser("~")
for candidate in (f"{home}/.local/bin", "/root/.local/bin"):
    if os.path.exists(candidate + "/poetry"):
        print(candidate)
        break
PY
)"
grep -qxF "export PATH=\"$POE_DIR:\$PATH\"" ~/.bashrc || \
  echo "export PATH=\"$POE_DIR:\$PATH\"" >> ~/.bashrc
