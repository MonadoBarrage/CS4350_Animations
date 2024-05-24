#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

set(_IMPORT_PREFIX "${AFTR_USERLAND_ROOT_DIR}")


# Import target "AftrBurnerEngine::AftrBurnerEngine" for configuration "Debug"
set_property(TARGET AftrBurnerEngine::AftrBurnerEngine APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(AftrBurnerEngine::AftrBurnerEngine PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib64/AftrBurnerEngine_debug.lib"
  )

message(STATUS "\n\n\n\nTHTHTHHTHTHTHTHTHH ${_IMPORT_PREFIX}\n\n\n\n ")

list(APPEND _cmake_import_check_targets AftrBurnerEngine::AftrBurnerEngine )
list(APPEND _cmake_import_check_files_for_AftrBurnerEngine::AftrBurnerEngine "${_IMPORT_PREFIX}/lib64/AftrBurnerEngine_debug.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
