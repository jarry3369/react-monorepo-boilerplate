#!/bin/bash

WORKSPACE_NAME=$1
FLAG=$2 # "-rm"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_DIR="$ROOT_DIR/$WORKSPACE_NAME"


if [ -z "$WORKSPACE_NAME" ]; then
  echo "Usage: $0 <workspace-name>"
  exit 1
fi

fp=(
  "tsconfig.json|\"references\": \[|{ \"path\": \"./$WORKSPACE_NAME\" },"
  "pnpm-workspace.yaml|packages:|  - \"$WORKSPACE_NAME\""
  "package.json|\"workspaces\": \[|    \"$WORKSPACE_NAME\","
)

gen() {
  local p=$1
  local v=$2
  echo "$v" > "$p"
}
core() {
  local m=$1 # "add" | "remove"

  for e in "${fp[@]}"; do
    local fn=$(echo "$e" | cut -d'|' -f1)
    local p=$(echo "$e" | cut -d'|' -f2)
    local i=$(echo "$e" | cut -d'|' -f3)

    local f="$ROOT_DIR/$fn"
    local ei=$(printf '%s\n' "$i" | sed -e 's/[\/&"]/\\&/g')


    if [ -f "$f" ]; then
      case "$m" in
        "add")
          if grep -q "$i" "$f"; then
            echo "Workspace '$WORKSPACE_NAME' already exists in $f."
            else
            sed -i '' -e "/$p/ s|$p|&\\n$i|" "$f"

            echo "Workspace '$WORKSPACE_NAME' added to $f."
          fi
        ;;
        
        "remove")
          if grep -qF "$i" "$f"; then
            sed -i '' -e "s|$i||g" "$f"
            sed -i '' -e '/^[[:space:]]*$/d' "$f"
            echo "Workspace '$WORKSPACE_NAME' removed from $f."
          else
            echo "target'$i' does not exist in $f."
          fi
        ;;
        *)
          echo "Unknown mode '$m'. Skipping."
        ;;
      esac
    
      pnpm prettier $f -w
      else
          echo "File $f does not exist. Skipping."
    fi
  done
}

case "$FLAG" in
  "-rm")
    if [ -d "$WORKSPACE_DIR" ]; then
      rm -rf "$WORKSPACE_DIR"
      echo "Removed workspace directory: $WORKSPACE_DIR"
    fi

    core "remove"
    pnpm install
    echo "Workspace '$WORKSPACE_NAME' and references removed successfully."
    exit 0
  ;;
  *)

    if [ -d "$WORKSPACE_DIR" ]; then
    echo "Workspace '$WORKSPACE_NAME' already exists."
    exit 1
    fi

    mkdir -p "$WORKSPACE_DIR"
    gen "$WORKSPACE_DIR/package.json" '{"name":"'"$WORKSPACE_NAME"'","version":"0.1.0","private":true,"type":"module"}'
    gen "$WORKSPACE_DIR/tsconfig.node.json" '{"extends":"../tsconfig.base.json","compilerOptions":{"composite":true,"moduleResolution":"Node","allowSyntheticDefaultImports":true,"outDir":"../.cache/typescript-'"$WORKSPACE_NAME"'","emitDeclarationOnly":true}}'
    gen "$WORKSPACE_DIR/tsconfig.json" '{"extends":"../tsconfig.base.json","compilerOptions":{"target":"ES6","useDefineForClassFields":true,"lib":["ES2020","DOM","DOM.Iterable"],"module":"ESNext","baseUrl":"./","paths":{"@/*":["./*"],"@core/*":["./core/*"]},"moduleResolution":"bundler","allowImportingTsExtensions":true,"resolveJsonModule":true,"isolatedModules":true,"noEmit":true},"include":["**/*.ts","**/*.d.ts","**/*.json"],"exclude":["dist/**/*"],"references":[{"path":"./tsconfig.node.json"}]}'
  core "add"
    pnpm prettier $WORKSPACE_DIR -w
    pnpm install

    echo "Workspace '$WORKSPACE_NAME' created successfully."
  ;;
esac
