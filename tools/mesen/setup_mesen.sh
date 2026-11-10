#!/bin/bash
# Baixa o Mesen 2 (Linux x64) e deixa pronto para rodar SEM janela (modo --testrunner), que e' como os
# scripts de trace deste projeto o usam.  uso: setup_mesen.sh [dir]   (padrao: /tmp/mesen)
set -e
DIR=${1:-${MESEN_DIR:-/tmp/mesen}}
URL=https://github.com/SourMesen/Mesen2/releases/download/2.1.1/Mesen_2.1.1_Linux_x64.zip
mkdir -p "$DIR" && cd "$DIR"
if [ ! -x Mesen ]; then
  curl -L -o mesen.zip "$URL" && unzip -o -q mesen.zip && rm mesen.zip && chmod +x Mesen
fi
# settings.json AO LADO do executavel: sem ele o Mesen abre o assistente de configuracao e morre sem display.
#  - AllowIoOsAccess: os scripts Lua precisam de io/os para gravar os arquivos de trace
#  - Port1/Port2 = NesController: sem isso emu.setInput() nao tem efeito
cp "$(dirname "$(realpath "$0")")/settings.json" "$DIR/settings.json"
mkdir -p "$DIR/home"
# dependencias de sistema (Debian/Ubuntu)
if ! ldconfig -p | grep -q libSDL2-2.0; then
  echo "instalando libsdl2 (sudo)..."; sudo apt-get install -y libsdl2-2.0-0 >/dev/null
fi
echo "Mesen pronto em $DIR"
echo "teste:  $(dirname "$(realpath "$0")")/run_trace.sh attract 600 1 /tmp/sf2trace/teste 300"
