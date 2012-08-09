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
project (MOAI_DEPS)

# Debug mode?
set(CMAKE_BUILD_TYPE Debug)
option(DEBUG_MESSAGES "Show debug messages during build" ON)

# Flags
set(CMAKE_C_FLAGS "-Wall -pedantic -Wimplicit-function-declaration -Wreturn-type -Wstrict-prototypes -Wextra")
set(CMAKE_OSX_ARCHITECTURES "i386")

# Load cmake definitions
file(GLOB_RECURSE PROJECT_INCLUDES "${PROJECT_SOURCE_DIR}/utils/*.cmake")
foreach(PROJECT_INCLUDE ${PROJECT_INCLUDES})
  include(${PROJECT_INCLUDE})
endforeach(PROJECT_INCLUDE ${PROJECT_INCLUDES})

# Deps: self
set(PROJECT_EXTRA_LIBRARIES "")
set(PROJECT_EXTRA_INCLUDES "")

# Add dependencies
include("${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/CMakeLists.txt")
foreach(PATH ${3RD_PARTY_LIBS}) 

  # Import
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/${PATH})

  # Force cmake to look locally for the library instance
  get_filename_component_last(${PATH} DEP_LOWER)
  if(NOT ${DEP_LOWER} STREQUAL "CMakeLists.txt")

    # Convert to dep id
    string(TOUPPER ${DEP_LOWER} DEP_ID)
    set(${DEP_LOWER}_DIR "${PROJECT_BINARY_DIR}/3rdparty/${DEP_LOWER}")

    # Now for cmake to load the local instance of the libraries
    include("${${DEP_LOWER}_DIR}/${DEP_LOWER}Config.cmake")
    list(APPEND PROJECT_EXTRA_INCLUDES "${${DEP_ID}_INCLUDE_DIRS}")
    set(PROJECT_EXTRA_LIBRARIES "${${DEP_ID}_LIBRARIES};${PROJECT_EXTRA_LIBRARIES}")
  endif()  
endforeach()

# Debug
if(DEBUG_MESSAGES)
  #message("Build debug:")
  #foreach(INC ${PROJECT_EXTRA_INCLUDES})
    #message("- Include: ${INC}")
  #endforeach()
  #foreach(LIB ${PROJECT_EXTRA_LIBRARIES})
  #  message("- Library: ${LIB}")
  #endforeach()
endif()

# Deps setup
set(SOURCES "${PROJECT_SOURCE_DIR}/src/moaideps.c")
set(PROJECT_INCLUDE_DIRS "${PROJECT_EXTRA_INCLUDES}")

# libary headers
include_directories(${PROJECT_INCLUDE_DIRS})

# Add deps library
add_library(moaideps ${SOURCES})
target_link_libraries(moaideps ${PROJECT_EXTRA_LIBRARIES})

# Export libraries
set(PROJECT_LIBRARIES moaideps)
list(APPEND PROJECT_LIBRARIES ${PROJECT_EXTRA_LIBRARIES})

set(PROJECT_NAME "MOAI_DEPS")
CONFIGURE_FILE(moaidepsConfig.cmake.in "${PROJECT_BINARY_DIR}/moaidepsConfig.cmake")

# Add test 
enable_testing()
add_subdirectory("${PROJECT_SOURCE_DIR}/depstest")
add_test(NAME moaidepstest WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/depstest COMMAND moaidepstest)
