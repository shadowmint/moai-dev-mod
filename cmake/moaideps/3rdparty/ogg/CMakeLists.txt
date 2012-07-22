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
set(key "ogg")
string(TOUPPER ${key} KEY) 

cmake_minimum_required (VERSION 2.8)
project(${key})

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "libogg-1.2.2")

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Project specific libs and includes
set(PROJECT_LIBRARIES "${PROJECT_REAL_PATH}/src/.libs/libogg.a")
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include")
set(PROJECT_LIBRARY_DIRS "${PROJECT_REAL_PATH}/src/.libs")
set(PROJECT_NAME "${KEY}")

# Dependency target; skip building if it exists already.
if (NOT EXISTS ${PROJECT_LIBRARIES})

  # Window doesn't play well with others
  if (WIN32)
    apply_cr_fix("${PROJECT_REAL_PATH}")
  endif()

  # Platform config
  if(APPLE)
    import_common_build_flags(BUILD_EXTRA_FLAGS EXTRA_C_FLAGS "-O5") # For xcode bug
  else()
    import_common_build_flags(BUILD_EXTRA_FLAGS)
  endif()

  # Build
  invoke_autotools("${PROJECT_REAL_PATH}" "${BUILD_EXTRA_FLAGS}")

endif()

# Error if the build using autotools failed
if (NOT EXISTS ${PROJECT_LIBRARIES})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIBRARIES}")
endif()

# Export libraries
CONFIGURE_FILE(${key}Config.cmake.in "${PROJECT_BINARY_DIR}/${key}Config.cmake")
