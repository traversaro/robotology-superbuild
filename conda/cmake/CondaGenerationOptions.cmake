# By default the conda package name is obtained by
# converting to lower case the CMake package name
# For the projects for which we like to use a different
# strategy, we specify the _CONDA_PKG_NAME hereafter
set(ICUB_CONDA_PKG_NAME "icub-main")
set(ICUBcontrib_CONDA_PKG_NAME "icub-contrib")
set(OsqpEigen_CONDA_PKG_NAME "osqp-eigen")
set(WBToolbox_CONDA_PKG_NAME "wb-toolbox")
set(UnicyclePlanner_CONDA_PKG_NAME "unicycle-footstep-planner")

# Temporary overload of YCM and YARP versions
set(YCM_CONDA_VERSION "0.12.0.1")
set(YARP_CONDA_VERSION "3.4.1.1")

# Inject additional conda dependencies
set(YARP_CONDA_DEPENDENCIES ace opencv tinyxml qt eigen sdl sdl2 sqlite)
# gsl omitted due to https://github.com/conda-forge/gsl-feedstock/issues/50
set(ICUB_CONDA_DEPENDENCIES ace opencv ipopt libode qt sdl)
if(NOT APPLE)
  list(APPEND ICUB_CONDA_DEPENDENCIES freeglut)
endif()

set(iDynTree_CONDA_DEPENDENCIES libxml2 ipopt eigen)
