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

# Base path
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../src/aku")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${key} from ${PROJECT_REAL_PATH}")
endif()

# Host path
set(PROJECT_HOST_PATH "${PROJECT_SOURCE_DIR}/../../../src/hosts")

# Build host dependent files 
# hint: this is a bad way of doing this. 
#       Host dependent files should be called blah-OS.cpp (eg. blah-win.cpp)
#       Mapping GlutHost.h _magically_ to AKUGlut.h is wrong.
#       TODO: Fix this. 
configure_file("${PROJECT_HOST_PATH}/GlutHost.cpp" "${PROJECT_REAL_PATH}/AKUGlut.cpp")
configure_file("${PROJECT_HOST_PATH}/GlutHost.h" "${PROJECT_REAL_PATH}/AKUGlut.h")
if(WIN32)
  configure_file("${PROJECT_HOST_PATH}/FolderWatcher-win.cpp" "${PROJECT_REAL_PATH}/FolderWatcher.cpp")
  configure_file("${PROJECT_HOST_PATH}/FolderWatcher-win.h" "${PROJECT_REAL_PATH}/FolderWatcher.h")
elseif(APPLE)
  configure_file("${PROJECT_HOST_PATH}/FolderWatcher-mac.mm" "${PROJECT_REAL_PATH}/FolderWatcher.mm")
  configure_file("${PROJECT_HOST_PATH}/FolderWatcher-mac.h" "${PROJECT_REAL_PATH}/FolderWatcher.h")
endif()

# Host includes
include_directories(${PROJECT_HOST_PATH})

# Get sources
file(GLOB PROJECT_SOURCES "${PROJECT_REAL_PATH}/*.cpp")
if(APPLE)
  file(GLOB OBJC_PROJECT_SOURCES "${PROJECT_REAL_PATH}/*.mm")
  list(APPEND PROJECT_SOURCES ${OBJC_PROJECT_SOURCES})
endif()

# Disable untz; dont care about this, it doesnt build anyway
filter_list("${PROJECT_SOURCES}" "AKU-untz.cpp;AKU-adcolony.mm;AKU-chartboost.mm;AKU-iphone.mm" PROJECT_SOURCES)

# Library
add_library(aku STATIC ${PROJECT_SOURCES})

# Import moai core
include(${PROJECT_BINARY_DIR}/../moaicore/moaicoreConfig.cmake)
include_directories(${MOAICORE_INCLUDE_DIRS})
target_link_libraries(aku ${MOAICORE_LIBRARIES})

# Import audio sampler
include(${PROJECT_BINARY_DIR}/../_moaiext-audiosampler/moaiext-audiosamplerConfig.cmake)
include_directories(${MOAIEXT-AUDIOSAMPLER_INCLUDE_DIRS})
target_link_libraries(aku ${MOAIEXT-AUDIOSAMPLER_LIBRARIES})

# Dependencies and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/..")
set(PROJECT_LIBRARIES "aku")

# Export libraries
set(PROJECT_NAME "AKU")
configure_file(${key}Config.cmake.in "${PROJECT_BINARY_DIR}/${key}Config.cmake")
