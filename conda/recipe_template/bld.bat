mkdir build
cd build

:: Hardcoding Visual Studio 2019 as GitHub Actions does not have VS2019
cmake ^
    -G"Visual Studio 16 2019" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
{# Build shared libs for now disabled as a workaround for https://github.com/robotology/icub-main/issues/717 #}
{# -DBUILD_SHARED_LIBS=ON ^ #}
{% for cmake_arg in cmake_args %}    {{ cmake_arg }} ^
{% endfor %}    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
