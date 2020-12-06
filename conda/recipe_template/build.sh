#!/bin/sh

mkdir build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
{% for cmake_arg in cmake_args %}    {{ cmake_arg }} \
{% endfor %}

cmake --build . --config Release
cmake --build . --config Release --target install