#!/bin/bash


for arg in "$@"; do
  declare $arg=true
done

if [ -z "${clang+x}" ]; then declare gcc=true; else gcc=false; fi
if [ -z "${release+x}" ]; then declare debug=true; else debug=false; fi

if [ "${debug}" = true ]; then echo "[debug mode]"; fi
if [ "${release}" = true ]; then echo "[release mode]"; fi

if [ "${clang}" = true ]; then echo "[clang compile]"; fi
if [ "${gcc}" = true ]; then echo "[gcc compile]"; fi


inc_tracy="/opt/tracy/public/"

if [ "${tracy}" = true ]; then
  def_tracy="-DTRACY_ENABLE"
fi

gcc_common="  -I../core/code/ -mavx2 -mfma -std=c99 -D_GNU_SOURCE=1 -Wall -Werror -Wno-unused-function -Wno-unused-variable  -Wno-null-dereference -Wno-unused-but-set-variable -Wno-misleading-indentation"
clang_common="-I${inc_tracy} ${def_tracy} -I${gl_include} -std=c99 -D_GNU_SOURCE=1   -I../core/code/ -mfma -mavx2 -fdiagnostics-absolute-paths -Wall -Werror -Wno-unused-function -Wno-unused-variable  -Wno-null-dereference -Wno-unused-but-set-variable -Wno-missing-braces -Wno-deprecated" 

gcc_debug="gcc -g -O0 -DBUILD_DEBUG=1 ${gcc_common}"
gcc_release="gcc -g -O2 -DBUILD_DEBUG=0 ${gcc_common}"

clang_debug="clang -g -O0 -DBUILD_DEBUG=1 ${clang_common}"
clang_release="clang -g -O2 -march=znver4 -DBUILD_DEBUG=0 ${clang_common}" 

if [ "${tracy}" = true ]; then
  link_tracy="/opt/tracy/build/TracyClient.o -lstdc++"
fi
gcc_link=" -lpthread -lwayland-cursor -lxkbcommon -lm -lwayland-client -lwayland-egl -lEGL -lGL ${link_tracy}"
clang_link=" -lwayland-cursor -lxkbcommon -lm -lwayland-client -lwayland-egl -lEGL -lGL ${link_tracy}"

gcc_out="-o"
clang_out="-o"

if [ "${clang}" = true ]; then
  compile_debug="${clang_debug}"
  compile_release="${clang_debug}"
  compile_link="${clang_link}"
  out="${clang_out}"
elif [ "${gcc}" = true ]; then
  compile_debug="${gcc_debug}"
  compile_release="${gcc_debug}"
  compile_link="${gcc_link}"
  out="${gcc_out}"
fi


if [ "${debug}" = true ]; then
  compile="${compile_debug}"
elif [ "${release}" = true ]; then
  compile="${compile_release}"
fi

didbuild=false

mkdir -p build && cd build


if [ "${main}" = true ]; then
  didbuild=true
  eval "$compile" ../code/main.c "$compile_link" "$out" main
fi

cd ..


if [ "$didbuild" = false ]; then
  echo "[WARNING] no valid build target specified; must use build target names as arguments to this script."
fi
