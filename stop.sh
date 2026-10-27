#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

BASE_RECIPE_DIR="base-recipe"

if [ -d "$BASE_RECIPE_DIR" ]; then
    cd "$BASE_RECIPE_DIR"
    exec ./stop.sh "$@"
else
    echo "Base recipe not found. Nothing to stop."
    exit 1
fi
