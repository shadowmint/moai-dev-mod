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

# Project control
set(key "zlcore")
string(TOUPPER ${key} KEY) 

cmake_minimum_required (VERSION 2.8)
project(${key})

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../src/zlcore/")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${key} from ${PROJECT_REAL_PATH}")
endif()
file(GLOB PROJECT_SOURCES "${PROJECT_REAL_PATH}/*.cpp")

# Library
add_library(zlcore STATIC ${PROJECT_SOURCES})

# All 3rdparty libs
include(${PROJECT_BINARY_DIR}/../../moaideps/moaidepsConfig.cmake)
include_directories(${MOAI_DEPS_INCLUDE_DIRS})
target_link_libraries(zlcore ${MOAI_DEPS_LIBRARIES})

# Dependencies and includes
set(PROJECT_LIBRARIES "zlcore")
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/../")
include_directories("${PROJECT_INCLUDE_DIRS}")

# Export libraries
set(PROJECT_NAME "ZLCORE")
configure_file(${key}Config.cmake.in "${PROJECT_BINARY_DIR}/${key}Config.cmake")
