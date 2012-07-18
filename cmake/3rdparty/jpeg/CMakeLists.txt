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
project(jpeg)

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "jpeg-8c")

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Dependency target; skip building if it exists already.
set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/.libs/libjpeg.a")
if (NOT EXISTS ${PROJECT_LIB_TARGET})

  # Window doesn't play well with others
  if (WIN32)
    apply_cr_fix("${PROJECT_REAL_PATH}")
  endif()

  # Platform config
  import_common_build_flags(BUILD_EXTRA_FLAGS)

  # Build
  invoke_autotools("${PROJECT_REAL_PATH}" "${BUILD_EXTRA_FLAGS}")

endif()

# Error if the build using autotools failed
if (NOT EXISTS ${PROJECT_LIB_TARGET})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIB_TARGET}")
endif()

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET}")
set(PROJECT_NAME "JPEG")

# Export libraries
CONFIGURE_FILE(jpegConfig.cmake.in "${PROJECT_BINARY_DIR}/jpegConfig.cmake")
