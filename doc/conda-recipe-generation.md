Conda Recipe Generation
=======================

## Rationale

`conda` is a package manager (originally for Python, but now quite language agnostic) that works on Linux, macOS and Windows. `conda-forge`  is a channel for the conda package manager that provides many dependency, in particular all the one that are required by the robotology-superbuild . The `robotology-superbuild` now contains experimental support for making the compiled binaries for  projects contained in it available as a `conda` binaries.

The use of conda is complementary to the compilation modes that we already use and are not substituted by conda, but its advantages are:

* Updated dependencies: conda-forge tipically has relatively recent version of the dependencies, so if you want to use a recent vtk or pcl on an old distro such as Ubuntu 16.04, you can. This permits us to support older distributions even when the packages that install via apt are relatively old.
* No need for root permissions: all the software installed by conda is installed and used in a user directory, so even if you are on a system in which you do not have root access (such as a shared workstation) you can still install all you required dependencies
* Use of binaries: conda distributes its packages as binaries, so even to download heavy dependencies such as OpenCV, PCL, Qt and Gazebo on Windows it just takes a few minutes, as opposed to hours necessary to compile them when using vcpkg. This is also useful when producing Docker images that require a recent version of PCL or VTK: installing them via conda takes a few seconds, and this would cut the time necessary to regenerate Docker images.
* Reproducible enviroments: conda has built in support for installing exactly the same version of the packages you were using in the past, up to the patch version. This is quite important for reproducibility in scientific research. See https://www.nature.com/articles/d41586-020-02462-7 for a Nature article on the importance of reproducibility in scientific research.
* On macOS and Windows, conda is also the package manager for which it is more easily possible to obtain working binaries of ROS1 and in the future of ROS2, thanks to the work of the [RoboStack project](https://github.com/RoboStack)

## How to generate recipes

To generate the conda recipes for a given configuration of the `robotology-superbuild`, configure the `robotology-superbuild` in a conda workspace (TODO: docs on this, for now check the GitHub Action CI). As the conda recipes are intendend to build release version of software, specify an option to get a specific release.

After that, install the additional dependencies required for the recipe generation:
~~~
conda install -c conda-forge pyyaml jinja2 conda-build
~~~

Then, set the `ROBOTOLOGY_GENERATE_CONDA_RECIPES` CMake option to `ON` in the `robotology-superbuild` build. This will **deactivate** the usual logic
for building projects of the `robotology-superbuild`, and instead will generate (at CMake configure time) conda recipes in `<build_dir>/conda/generated_recipes` for all the projects of the superbuild. If the configuration was concluded correctly, i.e. CMake configuration ended with:
~~~
-- To build the generated conda recipes, navigate to the directory and run conda build . in it.
-- Configuring done
-- Generating done
-- Build files have been written to: C:/src/robotology-superbuild/build-conda
~~~
you can then build the generated recipes by moving in the `<build_dir>/conda/generated_recipes` directory and running either [`conda build .`](https://github.com/conda/conda-build) or [`boa .`](https://github.com/mamba-org/boa).

Note that the generated recipes will depend on the specific configuration of the robotology-superbuild used, so enabling additional profiles will generate recipes
for the packages contained in those profiles. For this reason, the generated recipes in general are not cross-platform. For example the recipes generated on `Linux` could contain Linux-specific CMake options passed to the projects, so may not be usable on Windows.
If you want to obtain recipe that can be built on a given operating system, please generate them with the robotology-superbuild on that operating system.

## Internals

All the files necessary to generate the conda recipes are contained in the `conda` directory of the root source dir.

In particular:

### `conda/cmake/RobotologySuperbuildGenerateCondaRecipes.cmake`
This CMake scripts contain the logic to generate the recipes. The generation is articulated as follows.

The `cmake/RobotologySuperbuildLogic.cmake` file, that contains the logic of which projects should be built,
is run after redefining the `ycm_ep_helper` and `find_or_build_package` YCM functions, to extract the informations on name,
versions, dependency and cmake options of subpackages. This information are combined with the conda-specific metadata specified
in `conda/cmake/CondaGenerationOptions.cmake` (that contains information such as conda dependencies external to the `robotology-superbuild`)
to generate the `<build_dir>/conda/robotology-superbuild-conda-metametadata.yaml` file.

After that, the data in `<build_dir>/conda/robotology-superbuild-conda-metametadata.yaml` is used via the `conda/python/generate_conda_recipes_from_metadatadata.py`
python script to generate the conda recipes.

### `conda/recipe_template`

This directory contains `Jinja2` templates for the files `meta.yaml`, `bld.bat` and `build.sh` that will be part of each generated recipe.

### `conda/python/generate_conda_recipes_from_metadatadata.py`

Python script that takes the `metametadata` file generated by the `generate_metametadata_file` CMake macro, and uses it to configure the
`Jinja2` templates `conda/recipe_template` to generate the recipe for each specific package.