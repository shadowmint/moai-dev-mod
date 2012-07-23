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
project(curl)

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "curl-7.26.0")

# Copy to build directory
set(PROJECT_SRC_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
set(PROJECT_REAL_PATH "${PROJECT_BINARY_DIR}/${PROJECT_KEY}")
file(COPY ${PROJECT_SRC_PATH} DESTINATION ${PROJECT_BINARY_DIR})

# Source and includes
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Dependency target; skip building if it exists already.
set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/lib/.libs/libcurl.a")
if (NOT EXISTS ${PROJECT_LIB_TARGET})

  # <CR> breaks configure
  apply_cr_fix("${PROJECT_REAL_PATH}")

  # Platform config
  import_common_build_flags(BUILD_EXTRA_FLAGS)
  set(BUILD_EXTRA_FLAGS "${BUILD_EXTRA_FLAGS} --disable-ldap")

  # Build
  invoke_autotools("${PROJECT_REAL_PATH}" "${BUILD_EXTRA_FLAGS}")

endif()

# Error if the build using autotools failed
if (NOT EXISTS ${PROJECT_LIB_TARGET})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIB_TARGET}")
endif()

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}/include")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET}")
set(PROJECT_NAME "CURL")

# RTMP support; find package doesn't seem to work
find_library(RTMP_LIBRARY NAMES rtmp librtmp)
if(NOT RTMP_LIBRARY STREQUAL "RTMP_LIBRARY-NOTFOUND")
  list(APPEND PROJECT_LIBRARIES ${RTMP_LIBRARY})
endif()

# Export libraries
CONFIGURE_FILE(curlConfig.cmake.in "${PROJECT_BINARY_DIR}/curlConfig.cmake")
