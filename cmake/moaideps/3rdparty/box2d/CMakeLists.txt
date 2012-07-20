# Copyright 2012 Douglas Linder
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required (VERSION 2.8)
project(box2d)

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "box2d-2.2.1")

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
add_subdirectory(${PROJECT_REAL_PATH} "${CMAKE_CURRENT_BINARY_DIR}/impl")
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Disable box2d tests, etc.
set(BOX2D_BUILD_EXAMPLES OFF CACHE BOOL "Do not build box2d tests" FORCE)
set(BOX2D_INSTALL OFF CACHE BOOL "Do not build box2d install" FORCE)

# Export libraries
set(PROJECT_LIBRARIES "Box2D")
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/Box2D")
set(PROJECT_NAME "BOX2D")

CONFIGURE_FILE(box2dConfig.cmake.in "${PROJECT_BINARY_DIR}/box2dConfig.cmake")
