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
project(png)

# Import macros
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# C99 for long long support
set(CMAKE_C_FLAGS "-std=c99")

# Config
set(PROJECT_KEY "lpng140")

# Source and includes
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
file(GLOB PROJECT_SOURCES "${PROJECT_REAL_PATH}/*.c")
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}")
filter_list("${PROJECT_SOURCES}" "example.c" PROJECT_SOURCES)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Ogg dep
include(${PROJECT_BINARY_DIR}/../_zlib/zlibConfig.cmake)

# Build library (static)
include_directories(${PROJECT_INCLUDE_DIRS})
add_library(png STATIC ${PROJECT_SOURCES})
include_directories(${ZLIB_INCLUDE_DIRS})
target_link_libraries(${ZLIB_LIBRARIES})

# Export libraries
set(PROJECT_LIBRARIES png)
set(PROJECT_NAME "PNG")

CONFIGURE_FILE(pngConfig.cmake.in "${PROJECT_BINARY_DIR}/pngConfig.cmake")
