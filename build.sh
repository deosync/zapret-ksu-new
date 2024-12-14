#!/bin/bash

# Настройка переменных
set -e

# Параметры
ABI=$1
NDK_HOME=$2
API=21
TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
TARGET="${ABI/-*/}-linux-android"
CC="$TOOLCHAIN/bin/$TARGET$API-clang"
CXX="$TOOLCHAIN/bin/$TARGET$API-clang++"
AR="$TOOLCHAIN/bin/llvm-ar"
AS="$TOOLCHAIN/bin/llvm-as"
LD="$TOOLCHAIN/bin/ld"
RANLIB="$TOOLCHAIN/bin/llvm-ranlib"

echo "Сборка для ABI: $ABI"

# Убедимся, что все пути существуют
if [ ! -f "$CC" ]; then
    echo "Ошибка: Не найден компилятор $CC"
    exit 1
fi

# Переход в директорию проекта
cd zapret/nfq

# Очистка предыдущих сборок
make clean

# Сборка с выводом подробной информации
make ABI=$ABI VERBOSE=1

# Копирование бинарника в папку артефактов
mkdir -p ../../binaries/my/$ABI
cp nfqws ../../binaries/my/$ABI/nfqws

echo "Сборка завершена для $ABI"
