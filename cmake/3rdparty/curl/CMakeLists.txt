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
set(PROJECT_KEY "curl-7.19.7")

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Fix stupid autotools fail. Seriously, who uses this shit anymore?
execute_process(COMMAND tr -d '\r' INPUT_FILE "${PROJECT_REAL_PATH}/include/curl/curlver.h" OUTPUT_FILE "${PROJECT_REAL_PATH}/include/curl/curlver.h.new" WORKING_DIRECTORY ${PROJECT_REAL_PATH})
configure_file("${PROJECT_REAL_PATH}/include/curl/curlver.h.new" "${PROJECT_REAL_PATH}/include/curl/curlver.h" COPY_ONLY)

# Configure 
execute_process(COMMAND chmod 755 configure WORKING_DIRECTORY ${PROJECT_REAL_PATH})
execute_process(COMMAND configure WORKING_DIRECTORY ${PROJECT_REAL_PATH})

# Build
execute_process(COMMAND make WORKING_DIRECTORY ${PROJECT_REAL_PATH})
set(PROJECT_LIB_TARGET "${PROJECT_REAL_PATH}/.libs/libcurl.a")

# Error if the build using autotools failed
if (NOT EXISTS ${PROJECT_LIB_TARGET})
 message(FATAL_ERROR "Autotools fail! Unable to find target: ${PROJECT_LIB_TARGET}")
endif()

# Lib and includes
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}")
set(PROJECT_LIBRARIES "${PROJECT_LIB_TARGET}")
set(PROJECT_NAME "CURL")

# Export libraries
CONFIGURE_FILE(curlConfig.cmake.in "${PROJECT_BINARY_DIR}/curlConfig.cmake")
