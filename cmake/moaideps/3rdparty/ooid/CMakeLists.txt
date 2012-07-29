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
project(ooid)

# Config
set(PROJECT_KEY "ooid-0.99")

# This is just a header project
set(PROJECT_REAL_PATH "${PROJECT_SOURCE_DIR}/../../../../3rdparty/${PROJECT_KEY}")
if (${DEBUG_MESSAGES})
  message("Importing ${PROJECT_KEY} from ${PROJECT_REAL_PATH}")
endif()

# Export libraries
set(PROJECT_INCLUDE_DIRS "${PROJECT_REAL_PATH}")
set(PROJECT_LIBRARIES "")
set(PROJECT_NAME "OOID")

CONFIGURE_FILE(ooidConfig.cmake.in "${PROJECT_BINARY_DIR}/ooidConfig.cmake")
