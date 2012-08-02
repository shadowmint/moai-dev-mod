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

# Let MSVS specific code fail gracefully

# Project control
set(key "vscompat")
string(TOUPPER ${key} KEY) 

cmake_minimum_required (VERSION 2.8)
project(${key})

# Source and includes
file(GLOB PROJECT_SOURCES "${PROJECT_SOURCE_DIR}/src/*.c")
set(PROJECT_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/include")
set(PROJECT_LIBRARIES "compat")

# Library
add_library(compat STATIC ${PROJECT_SOURCES})

set(PROJECT_NAME "VSCOMPAT")

# Export libraries
configure_file(${key}Config.cmake.in "${PROJECT_BINARY_DIR}/${key}Config.cmake")
