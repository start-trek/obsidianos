#!/usr/bin/env bash
set -e
echo ">> Creating Python virtual env via Poetry"
poetry config virtualenvs.in-project true
poetry install --no-root
echo ">> Installing UI deps"
cd ui && pnpm install && cd ..

# optional: pre-build the Svelte UI for faster FCP
pnpm --prefix ui build

echo ">> Setting up pre-commit"
pre-commit install
