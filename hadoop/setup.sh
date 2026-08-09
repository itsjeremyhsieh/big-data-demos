#!/usr/bin/env bash
# Create venv for running the local Hadoop-style demo.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 -m venv .venv
source .venv/bin/activate

echo
echo "Setup complete. No extra pip packages needed."
echo "Activate the venv with:"
echo "  source .venv/bin/activate"
