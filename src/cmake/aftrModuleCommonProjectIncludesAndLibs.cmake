include_guard()
MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "ENTERING Inside of aftrModuleCommonProjectIncludesAndLibs.cmake..." )

include( CheckSymbolExists )

#####This section adds in other libraries, including AftrBurner, as well as other include paths
#####that were not added as part of the FIND_PACKAGE calls above.

set_property( DIRECTORY PROPERTY VS_STARTUP_PROJECT "${PROJECT_NAME}" )
set_property( GLOBAL PROPERTY USE_FOLDERS ON )


MESSAGE( STATUS "Build path is ${CMAKE_CURRENT_BINARY_DIR}" )
MESSAGE( "" )
ADD_EXECUTABLE( ${PROJECT_NAME} ${sources} ${headers} )
message( STATUS "Building the exe for this module... {PROJECT_NAME} is ${PROJECT_NAME}")


include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_cmake_utils.cmake")
query_AftrConfig_h_for_PREPROCESSOR_DIRECTIVES_and_populate_corresponding_cmake_vars()


#Works for both the engine and userland because AFTR_3RD_PARTY_INCLUDE_ROOT is
#set for either engine or user dynamically when cmake runs.
MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                "Now including common dependencies for AftrBurner..." )

#Before we find_package() for all external dependencies (/repos/libs/*),
#we need to have all cmake variables like AFTR_USE_OPENCV, AFTR_USE_GTEST
#populated. However, some of these libraries are user-selectable for each module.
#Therefore, we must prompt the user and populate the CMAKE variables *before*
#we run aftr_find_build_dependencies(). aftr_find_build_dependencies() will choose
#to *not* include a lib if its corresponding cmake variable is not properly set.

#For a module, there may be 3rd party libs / projects that need to be searched/linked (like OpenCV, PCL, GTest, etc) if *optionally* enabled in
#cmake. Those optional libraries are included here so their CMAKE Vars like AFTR_USE_OPENCV, AFTR_USE_PCL, AFTR_USE_GTEST are defined
#*before*
include("${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_optional_deps_for_usrModule_exe.cmake")
query_user_for_optional_deps_for_useModule_like_opencv_pcl_gtest_etc()
                
#Since both the engine and usr land use this find dependencies, there are typically
#two copies -- one (the original, official GIT version) that remains in the engine
#and is INSTALLed into usr land upon compiling the engine. If CMake is being run from
#the Engine's CMakeLists.txt, we want to use the engine's local copy.
#If we are running from a module in usr land, we want to use the installed version
#in usr land. Thus, we use our handy-dandy variable which points to the proper cmake folder:
include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_FindDependencies.cmake" )
aftr_find_build_dependencies()


include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_include_and_link_deps_for_usrModule_exe.cmake")
include_and_link_aburn_deps( "${PROJECT_NAME}" )




IF( AFTR_USE_GTEST )
   set( gtest_path "${CMAKE_SOURCE_DIR}/gtest/CMakeLists.txt" )
   IF( EXISTS "${CMAKE_SOURCE_DIR}/gtest/CMakeLists.txt" )
      enable_testing() #Let's ctest -C Debug       launch Google Tests from the cwin64 folder
      add_subdirectory( "${CMAKE_SOURCE_DIR}/gtest/" )
      MESSAGE( STATUS "GTEST Adding TESTS -- ${CMAKE_SOURCE_DIR}/gtest/CMakeLists.txt..." )
   else()
      MESSAGE( STATUS "CANNOT ENABLE GTEST -- ${CMAKE_SOURCE_DIR}/gtest/CMakeLists.txt does *NOT* exists..." )
   endif()
ENDIF()

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "LEAVING aftrModuleCommonProjectIncludesAndLibs.cmake..." )