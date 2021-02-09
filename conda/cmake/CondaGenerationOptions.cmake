# By default the conda package name is obtained by
# converting to lower case the CMake package name
# For the projects for which we like to use a different
# strategy, we specify the _CONDA_PKG_NAME hereafter
# Example: set(YARP_CONDA_PKG_NAME yarp)


# Inject additional conda dependencies
set(YARP_CONDA_DEPENDENCIES ace opencv tinyxml qt eigen sdl sdl2 sqlite libjpeg-turbo)
set(ICUB_CONDA_DEPENDENCIES ace opencv gsl ipopt libode qt sdl)

if(NOT APPLE)
  list(APPEND ICUB_CONDA_DEPENDENCIES freeglut)
endif()
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  list(APPEND ICUB_CONDA_DEPENDENCIES libglu)
endif()

set(iDynTree_CONDA_DEPENDENCIES libxml2 ipopt eigen qt irrlicht)

# If a package is already available in conda-forge, use it instead of generating a recipe for it
set(osqp_CONDA_PKG_NAME libosqp)
set(osqp_CONDA_PKG_CONDA_FORGE_OVERRIDE ON)
