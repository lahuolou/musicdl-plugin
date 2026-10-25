#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
  Darwin)
    exec "$DIR/musicdl-plugin-darwin" "$@"
    ;;
  *)
    exec "$DIR/musicdl-plugin-linux" "$@"
    ;;
esac
