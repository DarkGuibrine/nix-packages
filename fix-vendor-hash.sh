#!/usr/bin/env bash
set -euo pipefail

FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
FILE="flake/packages.nix"

for attr in netbird netbird-ui; do
  echo "Building $attr to discover vendorHash..."
  output=$(nix build ".#$attr" --no-link 2>&1 || true)
  real_hash=$(echo "$output" | grep -oP 'got:\s+\K\S+' | head -1)

  if [ -z "$real_hash" ]; then
    echo "$attr: hash already correct or build failed for another reason, skipping."
    continue
  fi

  echo "$attr: replacing $FAKE_HASH -> $real_hash"
  sed -i "s|$FAKE_HASH|$real_hash|g" "$FILE"
done

echo "Done."
