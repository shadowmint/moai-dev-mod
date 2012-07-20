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

include(CMakeParseArguments)

## Configuration options
set(MACROS_CONFIG_DISABLE_CR_CHECK 0)

## Copy a single source file to a single target file. 
function(copy_file DIR DEST TARGET COPY) 
  string(REPLACE "${DIR}/" "" FILE_RELATIVE ${TARGET})
  string(REGEX REPLACE ".in$" "" FILE_RELATIVE ${FILE_RELATIVE})
  string(REGEX REPLACE "/[^/]+$" "" FILE_RELATIVE_PATH ${FILE_RELATIVE})
  set(FILE_ABSOLUTE "${DEST}/${FILE_RELATIVE}")

  # If there was actually a directory for that, create it.
  if (NOT FILE_RELATIVE STREQUAL FILE_RELATIVE_PATH)
    set(FILE_ABSOLUTE_PATH "${DEST}/${FILE_RELATIVE_PATH}")
    file(MAKE_DIRECTORY ${FILE_ABSOLUTE_PATH})
  endif()

  # Copy the file into the directory
  if (${COPY}) 
    configure_file(${TARGET} ${FILE_ABSOLUTE} COPYONLY)
  else()
    configure_file(${TARGET} ${FILE_ABSOLUTE})
  endif()
endfunction()

## Copy all source files into the build directory
# @param DIR The directory to search for source files in.
# @param DEST The base directory to copy files to.
function(copy_source_files DIR DEST) 
  file(GLOB_RECURSE FILES "${DIR}/*.lua")
  foreach(FILE ${FILES})
    copy_file(${DIR} ${DEST} ${FILE} 1)
  endforeach()
  file(GLOB_RECURSE FILES "${DIR}/*.lua.in")
  foreach(FILE ${FILES})
    copy_file(${DIR} ${DEST} ${FILE} 0)
  endforeach()
endfunction()

## Get the last item on the path blah/blah/blah/
# @param ITEM The input path
# @param RETURN The return argument
function(get_filename_component_last ITEM RETURN)
  get_filename_component(ITEM_PATH_ABS ${ITEM} ABSOLUTE)
  get_filename_component(ITEM_PATH_PARENT "${ITEM}/.." ABSOLUTE)
  string(REPLACE "${ITEM_PATH_PARENT}/" "" ITEM_CP ${ITEM_PATH_ABS})
  set(${RETURN} ${ITEM_CP} PARENT_SCOPE)
endfunction()

## Filter the given list of absolute paths to exclude files in the excludes list.
# @param ITEMS A set of absolute pathes to files. eg. "${SOURCES}"
# @param EXCLUDES A list of relative excludes, eg. "lua.c;luac.c"
# @param RETURN The return argument
function(filter_list ITEMS EXCLUDES RETURN)
  foreach(ITEM ${ITEMS})
    string(REGEX MATCH "[^/]*$" ITEM_LOCAL ${ITEM})
    list(FIND EXCLUDES ${ITEM_LOCAL} ITEM_FOUND)
    if (${ITEM_FOUND} EQUAL -1)
      list(APPEND ITEMS_RETURN ${ITEM})
    endif()
  endforeach(ITEM ${ITEMS})
  set(${RETURN} ${ITEMS_RETURN} PARENT_SCOPE)
endfunction(filter_list EXCLUDES)

## Implode a list to a string 
# @param ITEMS The items to implode
# @param GLUE The item to insert between items.
# @param RETURN The return variable
function(implode_list ITEMS GLUE RETURN)
  string (REGEX REPLACE "([^\\]|^);" "\\1${GLUE}" _TMP_STR "${ITEMS}")
  string (REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}") #fixes escaping
  set (${RETURN} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

## Import common build flags used in many sub-projects
# @param RETURN The return variable
function(import_common_build_flags RETURN)
  set(FLAGS "")
  if(APPLE)
    list(APPEND FLAGS CFLAGS="-arch i386")
    list(APPEND FLAGS CXXFLAGS="-arch i386")
    list(APPEND FLAGS LDFLAGS="-arch i386")
    list(APPEND FLAGS CPPFLAGS="-arch i386")
  endif()
  implode_list("${FLAGS}" " " FLAGS)
  set (${RETURN} "${FLAGS}" PARENT_SCOPE)
endfunction()

## Invoke autotools in the given directory with the given extra args
#
# If dealing with some crazy (openssl <_<) project that doesn't use config
# normally you can call: invoke_autotools(${PATH} CONFIG_KEY "config")
#
# Some other libraries (>_> openssl, AGAIN) can't build correctly if you've
# tried to build them and failed. Use FORCE_CLEAN to run make clean before
# calling make.
#
# @param REAL_PATH The path to the directory containing a 'configure' script.
# @param EXTRA_FLAGS The extra flags to pass to autoconf when invoking it.
# @param CONFIG_KEY KEY optional; allows non-std config invokation.
function(invoke_autotools REAL_PATH EXTRA_FLAGS)

  # Read args
  set(ARGS ${ARGV})
  if(ARGC GREATER 2)
    list(REMOVE_AT ARGV 0) # REAL_PATH
    list(REMOVE_AT ARGV 0) # EXTRA_FLAGS
    cmake_parse_arguments(AT "FORCE_CLEAN" "CONFIG_KEY" "" ${ARGS})
  endif()  

  # Some projects like to rename their configure files. :/
  if(NOT "${AT_CONFIG_KEY}" STREQUAL "")
    set(CKEY ${AT_CONFIG_KEY})
  else()
    set(CKEY "configure")
  endif()

  # Write conf request to file for debugging
  if(WIN32)
    set(AUTOTOOLS_CONFIG "${CKEY} ${EXTRA_FLAGS}")
  else()
    set(AUTOTOOLS_CONFIG "./${CKEY} ${EXTRA_FLAGS}")
  endif()
  file(WRITE ${REAL_PATH}/cmake.configure ${AUTOTOOLS_CONFIG})

  # Make sure things can be run
  execute_process(COMMAND chmod 755 configure WORKING_DIRECTORY ${REAL_PATH})
  execute_process(COMMAND chmod 755 cmake.configure WORKING_DIRECTORY ${REAL_PATH})

  # Invoke configure
  execute_process(COMMAND sh ${REAL_PATH}/cmake.configure WORKING_DIRECTORY ${REAL_PATH})

  # Build
  if (AT_FORCE_CLEAN)
    execute_process(COMMAND make clean WORKING_DIRECTORY ${REAL_PATH})
  endif()
  execute_process(COMMAND make WORKING_DIRECTORY ${REAL_PATH})
endfunction()

## Replace any file that contains '\r' with a unix file version.
# This is specifically because autoconfig doesn't work with CR's
# @param REAL_PATH The path to the folder with the files in it
function(apply_cr_fix REAL_PATH)
  if(NOT MACROS_CONFIG_DISABLE_CR_CHECK)

    message("Autotools does not like <CR>'s. Checking for invalid files...")

    # Check for dos2unix
    find_program(DOS2UNIX dos2unix)
    if(NOT DOS2UNIX)
      message(FATAL "dos2unix must be installed to correct invalid file types")
    endif()

    # Working files; these shouldn't conflict with anything.
    set(CHECK_CPATH "${REAL_PATH}/cmake.checkfile")
    set(CONF_CPATH "${REAL_PATH}/cmake.configure") 

    # Remove working files so they aren't checked
    file(REMOVE "${CHECK_CPATH}")
    file(REMOVE "${CONF_CPATH}")

    # For all files
    file(GLOB_RECURSE PROJECT_FILES "${REAL_PATH}/*")
    foreach(FILE ${PROJECT_FILES})

      # Check if that file has a carriage return
      message("Checking ${FILE}")
      set(CHECK_CMD "od -a ${FILE} | grep 'cr' -m 1\nif [[ $? != 0 ]]\; then\n exit 1\nfi")
      file(WRITE "${CHECK_CPATH}" ${CHECK_CMD})
      execute_process(COMMAND sh "${CHECK_CPATH}" RESULT_VARIABLE RESULT OUTPUT_VARIABLE OUTPUT)

      # If there was a file with CR in it, apply fix.
      if(NOT "${OUTPUT}" STREQUAL "")
        message("\nMatching fragment: ${OUTPUT}")
        execute_process(COMMAND dos2unix --force "${FILE}")
      endif()
    endforeach()
  endif()    
endfunction()
