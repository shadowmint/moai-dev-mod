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
project (MOAI_DEPS_TEST)

# Debug mode?
set(CMAKE_BUILD_TYPE Debug)

# Flags
set(CMAKE_C_FLAGS "-Wall -pedantic -Wimplicit-function-declaration -Wreturn-type -Wstrict-prototypes -Wextra")
set(CMAKE_OSX_ARCHITECTURES "i386")

# Load deps
include(${PROJECT_BINARY_DIR}/../moaidepsConfig.cmake)

# Add exec
add_executable(moaidepstest "${PROJECT_SOURCE_DIR}/src/moaidepstest.c")
include_directories(${MOAI_DEPS_INCLUDE_DIRECTORIES})
target_link_libraries(moaidepstest ${MOAI_DEPS_LIBRARIES})
