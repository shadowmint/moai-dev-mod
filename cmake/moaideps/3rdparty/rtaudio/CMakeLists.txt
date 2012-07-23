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
set(key "rtaudio")
string(TOUPPER ${key} KEY) 

cmake_minimum_required (VERSION 2.8)
project(${key})

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "rtaudio-4.0.8")

# Copy to build directory
set(PROJECT_SRC_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
set(PROJECT_REAL_PATH "${PROJECT_BINARY_DIR}/${PROJECT_KEY}")
file(COPY ${PROJECT_SRC_PATH} DESTINATION ${PROJECT_BINARY_DIR})

# Source and includes
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Project specific libs and includes
set(PROJECT_LIBRARIES "${PROJECT_REAL_PATH}/librtaudio.a")
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}")
set(PROJECT_LIBRARY_DIRS "${PROJECT_REAL_PATH}")
set(PROJECT_NAME "${KEY}")

# Dependency target; skip building if it exists already.
if (NOT EXISTS ${PROJECT_LIBRARIES})

  # <CR> breaks configure
  apply_cr_fix("${PROJECT_REAL_PATH}")

  # Platform config
  import_common_build_flags(BUILD_EXTRA_FLAGS)

  # Build
  invoke_autotools("${PROJECT_REAL_PATH}" "${BUILD_EXTRA_FLAGS}")

endif()

# Error if the build using autotools failed
if (NOT EXISTS ${PROJECT_LIBRARIES})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIBRARIES}")
endif()

# Export libraries
CONFIGURE_FILE(${key}Config.cmake.in "${PROJECT_BINARY_DIR}/${key}Config.cmake")
