# By default the conda package name is obtained by
# converting to lower case the CMake package name
# For the projects for which we like to use a different
# strategy, we specify the _CONDA_PKG_NAME hereafter

# Inject additional conda dependencies
set(YARP_CONDA_DEPENDENCIES ace opencv tinyxml qt eigen sdl sdl2 sqlite libjpeg-turbo)
set(ICUB_CONDA_DEPENDENCIES ace opencv gsl ipopt libode qt sdl)

if(NOT APPLE)
  list(APPEND ICUB_CONDA_DEPENDENCIES freeglut)
endif()

set(iDynTree_CONDA_DEPENDENCIES libxml2 ipopt eigen)
