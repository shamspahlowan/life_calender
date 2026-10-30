#!/usr/bin/env bash
# Regenerates the Pigeon bridge (Dart + Kotlin) from pigeons/engine_api.dart.
set -euo pipefail

cd "$(dirname "$0")/.."
fvm dart run pigeon --input pigeons/engine_api.dart
