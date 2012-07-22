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
set(key "moaicore")
string(TOUPPER ${key} KEY) 

cmake_minimum_required (VERSION 2.8)
project(${key})

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../src/moaicore/")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${key} from ${PROJECT_REAL_PATH}")
endif()
file(GLOB PROJECT_SOURCES "${PROJECT_REAL_PATH}/*.cpp")
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/")
set(PROJECT_LIBRARIES "")

# All 3rdparty libs
include(${PROJECT_BINARY_DIR}/../../moaideps/moaidepsConfig.cmake)
set(PROJECT_INCLUDE_DIRS "${PROJECT_INCLUDE_DIRS};${MOAI_DEPS_INCLUDE_DIRS}")
set(PROJECT_LIBRARIES "${PROJECT_LIBRARIES};${MOAI_DEPS_LIBRARIES}")

# uslscore
include(${PROJECT_BINARY_DIR}/../_uslscore/uslscoreConfig.cmake)
set(PROJECT_INCLUDE_DIRS "${PROJECT_INCLUDE_DIRS};${USLSCORE_INCLUDE_DIRS}")
set(PROJECT_LIBRARIES "${PROJECT_LIBRARIES};${USLSCORE_LIBRARIES}")

# Library
add_library(moaicore STATIC ${PROJECT_SOURCES})

# Own special include dirs
set(PROJECT_INCLUDE_DIRS "${PROJECT_INCLUDE_DIRS};${PROJECT_REAL_PATH}/../config-default")

# Dependencies and includes
include_directories(${PROJECT_INCLUDE_DIRS})
target_link_libraries(moaicore ${PROJECT_LIBRARIES})
set(PROJECT_LIBRARIES "${PROJECT_LIBRARIES};moaicore")

# Export libraries
configure_file(${key}Config.cmake.in "${PROJECT_BINARY_DIR}/${key}Config.cmake")
