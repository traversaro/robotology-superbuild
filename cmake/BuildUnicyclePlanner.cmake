# Copyright (C) 2018 iCub Facility, Istituto Italiano di Tecnologia
# Authors: Silvio Traversaro <silvio.traversaro@iit.it>
# CopyPolicy: Released under the terms of the LGPLv2.1 or later, see LGPL.TXT

include(YCMEPHelper)
include(FindOrBuildPackage)

find_or_build_package(iDynTree QUIET)

ycm_ep_helper(UnicyclePlanner TYPE GIT
                              STYLE GITHUB
                              REPOSITORY robotology/unicycle-footstep-planner.git
                              TAG master
                              COMPONENT dynamics
                              FOLDER robotology
                              DEPENDS iDynTree)
