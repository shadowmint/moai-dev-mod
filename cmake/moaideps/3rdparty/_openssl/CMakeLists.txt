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
project(openssl)

# Import macros & setup
string(TOUPPER ${PROJECT_NAME} _PROJECT_NAME)
file(GLOB PROJECT_MACROS "${PROJECT_SOURCE_DIR}/../../cmake/*.cmake")
foreach(ITEM ${PROJECT_MACROS})
  include(${ITEM})
endforeach()

# Config
set(PROJECT_KEY "openssl-1.0.1c")

# Setup
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
get_filename_component(PROJECT_REAL_PATH ${PROJECT_REAL_PATH} ABSOLUTE)
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Openssl config uses symlinks that dont work on windwos
set(PROJECT_CUSTOM_INCLUDES "${CMAKE_CURRENT_BINARY_DIR}/include")
file(COPY ${PROJECT_REAL_PATH}/include DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
file(GLOB_RECURSE PROJECT_CUSTOM_INC "${PROJECT_REAL_PATH}/*.h")
foreach(ITEM ${PROJECT_CUSTOM_INC}) 
  get_filename_component(ITEM_PATH ${ITEM} PATH)
  get_filename_component_last(${ITEM_PATH} ITEM_LAST_PATH)
  if(NOT ITEM_LAST_PATH STREQUAL "openssl")
    message(" ${ITEM} ${ITEM_LAST_PATH} ")
    string(REPLACE "${ITEM_PATH}" "" ITEM_PATH ${ITEM})
    configure_file(${ITEM} ${PROJECT_CUSTOM_INCLUDES}/openssl/${ITEM_PATH} COPY_ONLY)
  endif()  
endforeach()

# Includes
include_directories("${PROJECT_CUSTOM_INCLUDES}")
set(PROJECT_INCLUDE_DIRS "${PROJECT_CUSTOM_INCLUDES}")

# libcrypto
file(GLOB_RECURSE PROJECT_SOURCES "${PROJECT_REAL_PATH}/crypto/*.c")
#filter_list("${PROJECT_SOURCES}" "lua.c;luac.c" PROJECT_SOURCES)
add_library(${PROJECT_NAME}_libcrypto STATIC ${PROJECT_SOURCES})

# libssl
file(GLOB_RECURSE PROJECT_SOURCES "${PROJECT_REAL_PATH}/ssl/*.c")
#filter_list("${PROJECT_SOURCES}" "lua.c;luac.c" PROJECT_SOURCES)
add_library(${PROJECT_NAME}_libssl STATIC ${PROJECT_SOURCES})

# Export libraries
set(PROJECT_LIBRARIES ${PROJECT_NAME}_libssl ${PROJECT_NAME}_libcrypto)

CONFIGURE_FILE(${PROJECT_NAME}Config.cmake.in "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
