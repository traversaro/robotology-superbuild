# Copyright (C) Fondazione Istituto Italiano di Tecnologia
# CopyPolicy: Released under the terms of the LGPLv2.1 or later, see LGPL.TXT

# Redefine find_or_build_package and ycm_ep_helper
# functions to extract metadata necessary for conda recipe
# generation from the RobotologySuperbuildLogic file
macro(ycm_ep_helper _name)
  # Check arguments
  set(_options )
  set(_oneValueArgs TYPE
                    STYLE
                    COMPONENT
                    FOLDER
                    EXCLUDE_FROM_ALL
                    REPOSITORY  # GIT, SVN and HG
                    TAG         # GIT and HG only
                    REVISION    # SVN only
                    USERNAME    # SVN only
                    PASSWORD    # SVN only
                    TRUST_CERT  # SVN only
                    TEST_BEFORE_INSTALL
                    TEST_AFTER_INSTALL
                    TEST_EXCLUDE_FROM_MAIN
                    CONFIGURE_SOURCE_DIR # DEPRECATED Since YCM 0.10
                    SOURCE_SUBDIR)
  set(_multiValueArgs CMAKE_ARGS
                      CMAKE_CACHE_ARGS
                      CMAKE_CACHE_DEFAULT_ARGS
                      DEPENDS
                      DOWNLOAD_COMMAND
                      UPDATE_COMMAND
                      PATCH_COMMAND
                      CONFIGURE_COMMAND
                      BUILD_COMMAND
                      INSTALL_COMMAND
                      TEST_COMMAND
                      CLEAN_COMMAND)

  cmake_parse_arguments(_YH_${_name} "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" "${ARGN}")

  get_property(_projects GLOBAL PROPERTY YCM_PROJECTS)
  list(APPEND _projects ${_name})
  list(REMOVE_DUPLICATES _projects)
  set_property(GLOBAL PROPERTY YCM_PROJECTS ${_projects})
endmacro()

macro(find_or_build_package _pkg)
  get_property(_superbuild_pkgs GLOBAL PROPERTY YCM_PROJECTS)
  if(NOT ${_pkg} IN_LIST _superbuild_pkgs)
    include(Build${_pkg})
  endif()
endmacro()

set(metametadata_file ${CMAKE_CURRENT_BINARY_DIR}/conda/robotology-superbuild-conda-metametadata.yaml)

macro(generate_metametadata_file)
  # Metametadata file name
  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/conda)
  set(metametadata_file_contents "conda-packages-metametadata:\n")

  get_property(_superbuild_pkgs GLOBAL PROPERTY YCM_PROJECTS)
  foreach(_cmake_pkg IN LISTS _superbuild_pkgs)
    # Compute conda version
    if(DEFINED ${_cmake_pkg}_TAG)
     set(${_cmake_pkg}_CONDA_TAG ${${_cmake_pkg}_TAG})
    else()
     set(${_cmake_pkg}_CONDA_TAG ${_YH_${_cmake_pkg}_TAG})
    endif()

    if(NOT DEFINED ${_cmake_pkg}_CONDA_VERSION)
      set(${_cmake_pkg}_CONDA_VERSION ${${_cmake_pkg}_CONDA_TAG})
    endif()

    # Compute conda CMake options
    set(${_cmake_pkg}_CONDA_CMAKE_ARGS ${_YH_${_cmake_pkg}_CMAKE_ARGS})
    list(APPEND ${_cmake_pkg}_CONDA_CMAKE_ARGS ${_YH_${_cmake_pkg}_CMAKE_CACHE_ARGS})
    list(APPEND ${_cmake_pkg}_CONDA_CMAKE_ARGS ${_YH_${_cmake_pkg}_CMAKE_CACHE_DEFAULT_ARGS})

    # Compute conda dependencies
    # Always append so dependencies not tracked by the superbuild can be injected by
    # defining a ${_cmake_pkg}_CONDA_DEPENDENCIES in CondaGenerationOptions.cmake
    foreach(_cmake_dep IN LISTS _YH_${_cmake_pkg}_DEPENDS)
      list(APPEND ${_cmake_pkg}_CONDA_DEPENDENCIES ${${_cmake_dep}_CONDA_PKG_NAME})
    endforeach()

    # Compute conda github repository
    # We remove the trailing .git (if present)
    string(REPLACE ".git" "" ${_cmake_pkg}_CONDA_GIHUB_REPO "${_YH_${_cmake_pkg}_REPOSITORY}")

    # Dump metametadata in yaml format
    string(APPEND metametadata_file_contents "  ${${_cmake_pkg}_CONDA_PKG_NAME}:\n")
    string(APPEND metametadata_file_contents "    name: ${${_cmake_pkg}_CONDA_PKG_NAME}\n")
    string(APPEND metametadata_file_contents "    version: ${${_cmake_pkg}_CONDA_VERSION}\n")
    string(APPEND metametadata_file_contents "    github_repo: ${${_cmake_pkg}_CONDA_GIHUB_REPO}\n")
    string(APPEND metametadata_file_contents "    github_tag: ${${_cmake_pkg}_CONDA_TAG}\n")

    if(NOT "${${_cmake_pkg}_CONDA_CMAKE_ARGS}" STREQUAL "")
      string(APPEND metametadata_file_contents "    cmake_args:\n")
      foreach(_cmake_arg IN LISTS ${_cmake_pkg}_CONDA_CMAKE_ARGS)
        string(APPEND metametadata_file_contents "      - \"${_cmake_arg}\"\n")
      endforeach()
    endif()

    if(NOT "${${_cmake_pkg}_CONDA_DEPENDENCIES}" STREQUAL "")
      string(APPEND metametadata_file_contents "    dependencies:\n")
      foreach(_dep IN LISTS ${_cmake_pkg}_CONDA_DEPENDENCIES)
        string(APPEND metametadata_file_contents "      - ${_dep}\n")
      endforeach()
    endif()

    string(APPEND metametadata_file_contents "\n")
  endforeach()

  file(WRITE ${metametadata_file} ${metametadata_file_contents})
  message(STATUS "Saved metametadata in ${metametadata_file}")
endmacro()

macro(generate_conda_recipes)
  set(python_generation_script "${CMAKE_CURRENT_SOURCE_DIR}/conda/python/generate_conda_recipes_from_metadatadata.py")
  set(generated_conda_recipes_dir "${CMAKE_CURRENT_BINARY_DIR}/conda/generated_recipes")
  file(MAKE_DIRECTORY ${generated_conda_recipes_dir})
  execute_process(COMMAND python ${python_generation_script} -i ${metametadata_file} -o ${generated_conda_recipes_dir})
  message(STATUS "conda recipes correctly generated in ${generated_conda_recipes_dir}.")
  message(STATUS "To build the generated conda recipes, navigate to the directory and run conda build . in it.")
endmacro()


# Explicitly add YCM as it is not handled as other projects
get_property(_projects GLOBAL PROPERTY YCM_PROJECTS)
list(APPEND _projects YCM)
set_property(GLOBAL PROPERTY YCM_PROJECTS ${_projects})
set(_YH_YCM_REPOSITORY robotology/ycm.git)

include(RobotologySuperbuildLogic)
include(CondaGenerationOptions)

get_property(_superbuild_pkgs GLOBAL PROPERTY YCM_PROJECTS)

# First of all: define the conda package name of each cmake project
foreach(_cmake_pkg IN LISTS _superbuild_pkgs)
  if(NOT DEFINED ${_cmake_pkg}_CONDA_PKG_NAME)
    string(TOLOWER ${_cmake_pkg} ${_cmake_pkg}_CONDA_PKG_NAME)
  endif()
endforeach()

# Second step: generate the ${CMAKE_CURRENT_BINARY_DIR}/conda/robotology-superbuild-conda-metametadata.yaml,
# that contains in yaml form the dependencies and options information contained
# in the CMake scripts of the robotology-superbuild
generate_metametadata_file()

# Third step: generate the conda recipes from the metametadata in
# ${CMAKE_CURRENT_BINARY_DIR}/conda/generate_recipes
generate_conda_recipes()