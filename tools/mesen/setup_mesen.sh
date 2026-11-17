#!/bin/bash
# Downloads Mesen 2 (Linux x64) and leaves it ready to run WITHOUT a window (--testrunner mode), which is how
# this project's trace scripts use it.  usage: setup_mesen.sh [dir]   (default: /tmp/mesen)
set -e
HERE=$(dirname "$(realpath "$0")")       # before cd: $0 may be relative
DIR=${1:-${MESEN_DIR:-/tmp/mesen}}
URL=https://github.com/SourMesen/Mesen2/releases/download/2.1.1/Mesen_2.1.1_Linux_x64.zip
mkdir -p "$DIR" && DIR=$(realpath "$DIR") && cd "$DIR"
if [ ! -x Mesen ]; then
  curl -L -o mesen.zip "$URL" && unzip -o -q mesen.zip && rm mesen.zip && chmod +x Mesen
fi
# settings.json NEXT TO the executable: without it Mesen opens the configuration wizard and dies without display.
#  - AllowIoOsAccess: Lua scripts need io/os to write trace files
#  - Port1/Port2 = NesController: without this emu.setInput() has no effect
cp "$HERE/settings.json" "$DIR/settings.json"
mkdir -p "$DIR/home"
# system dependencies (Debian/Ubuntu)
if ! ldconfig -p | grep -q libSDL2-2.0; then
  echo "installing libsdl2 (sudo)..."; sudo apt-get install -y libsdl2-0 >/dev/null
fi
echo "Mesen ready at $DIR"
echo "test:  $HERE/run_trace.sh attract 600 1 /tmp/sf2trace/teste 300"
