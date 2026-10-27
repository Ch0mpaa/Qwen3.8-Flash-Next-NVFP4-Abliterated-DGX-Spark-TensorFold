#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

BASE_RECIPE_DIR="base-recipe"
BASE_RECIPE_REPO="https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold.git"

# Clone the base recipe if not present
if [ ! -d "$BASE_RECIPE_DIR" ]; then
    echo "Cloning MiaAI-Lab's TensorFold recipe..."
    git clone "$BASE_RECIPE_REPO" "$BASE_RECIPE_DIR"
fi

# Copy our .env into the base recipe
cp .env "$BASE_RECIPE_DIR/.env"

# Run from the base recipe
cd "$BASE_RECIPE_DIR"
exec ./start.sh "$@"
