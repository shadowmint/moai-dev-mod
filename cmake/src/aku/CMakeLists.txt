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
set(key "aku")
string(TOUPPER ${key} KEY) 

cmake_minimum_required (VERSION 2.8)
project(${key})

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../src/aku/")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${key} from ${PROJECT_REAL_PATH}")
endif()
file(GLOB PROJECT_SOURCES "${PROJECT_REAL_PATH}/*.cpp")

# Disable untz; dont care about this, it doesnt build anyway
filter_list("${PROJECT_SOURCES}" "AKU-untz.cpp" PROJECT_SOURCES)

# Library
add_library(aku STATIC ${PROJECT_SOURCES})

# Import moai core
include(${PROJECT_BINARY_DIR}/../moaicore/moaicoreConfig.cmake)
include_directories(${MOAICORE_INCLUDE_DIRS})
target_link_libraries(aku ${MOAICORE_LIBRARIES})

# Dependencies and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/..")
set(PROJECT_LIBRARIES "aku")

# Export libraries
set(PROJECT_NAME "AKU")
configure_file(${key}Config.cmake.in "${PROJECT_BINARY_DIR}/${key}Config.cmake")
