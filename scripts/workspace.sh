#!/bin/bash

WORKSPACE_NAME=$1

if [ -z "$WORKSPACE_NAME" ]; then
  echo "Usage: $0 <workspace-name>"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_DIR="$ROOT_DIR/$WORKSPACE_NAME"

# Check if workspace directory already exists
if [ -d "$WORKSPACE_DIR" ]; then
  echo "Workspace '$WORKSPACE_NAME' already exists."
  exit 1
fi

# Create the workspace directory
mkdir -p "$WORKSPACE_DIR"

# Create package.json in the new workspace
cat <<EOL > "$WORKSPACE_DIR/package.json"
{
  "name": "$WORKSPACE_NAME",
  "version": "0.1.0",
  "private": true,
  "type": "module"
}
EOL

# Create tsconfig.json in the new workspace
cat <<EOL > "$WORKSPACE_DIR/tsconfig.json"
{
  "extends": "../tsconfig.base.json",
  "compilerOptions": {
    "target": "ES6",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "baseUrl": "./",
    "paths": {
      "@/*": ["./*"],
      "@core/*": ["./core/*"]
    },
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["**/*.ts", "**/*.d.ts", "**/*.json"],
  "exclude": ["dist/**/*"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOL

# Create tsconfig.node.json in the new workspace
cat <<EOL > "$WORKSPACE_DIR/tsconfig.node.json"
{
  "extends": "../tsconfig.base.json",
  "compilerOptions": {
    "composite": true,
    "moduleResolution": "Node",
    "allowSyntheticDefaultImports": true,
    "outDir": "../.cache/typescript-$WORKSPACE_NAME",
    "emitDeclarationOnly": true
  },
  "include": ["core/config.ts"]
}
EOL

fp=(
  "tsconfig.json|\"references\": \[| { \"path\": \"./$WORKSPACE_NAME\" },"
  "pnpm-workspace.yaml|packages:|  - \"$WORKSPACE_NAME\""
  "package.json|\"workspaces\": \[|    \"$WORKSPACE_NAME\","
)

# Process each file and modify it accordingly
for e in "${fp[@]}"; do
  fn=$(echo "$e" | cut -d'|' -f1)
  p=$(echo "$e" | cut -d'|' -f2)
  i=$(echo "$e" | cut -d'|' -f3)

  f="$ROOT_DIR/$fn"

  # Escape special characters for sed
  escaped_i=$(printf '%s' "$i" | sed 's/[\]/\\&/g')

  if [ -f "$f" ]; then
    if grep -q "$escaped_i" "$f"; then
      echo "Workspace '$WORKSPACE_NAME' already exists in $f."
    else
      sed -i.bak -E "/$p/ {s|($p)|\1\n$escaped_i|;}" "$f"
      echo "Workspace '$WORKSPACE_NAME' added to $f."
    fi
  else
    echo "File $f does not exist. Skipping."
  fi
done

# Run pnpm install to link the new workspace
pnpm install

echo "Workspace '$WORKSPACE_NAME' created successfully."
