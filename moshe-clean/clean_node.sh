#!/usr/bin/env bash
set -e

target="$1"

if [ -z "$target" ]; then
  echo "ERROR: No directory provided."
  echo 'Usage: ./clean_env.sh "D:\Node\deployment-operator"'
  exit 1
fi

target="${target//\\//}"

echo "Preparing $target ..."

if [ -d "$target" ]; then
  echo "Removing existing directory..."
  rm -rf "$target"
fi

echo "Creating directory..."
mkdir -p "$target"

if [ -d "$target" ]; then
  echo "Ready: $target"
else
  echo "ERROR: Failed to create $target"
  exit 1
fi