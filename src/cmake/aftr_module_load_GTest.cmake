include_guard()

#New Module CMake Template written by Scott Nykl. This requires the engine is already built, compiled, and INSTALL'd to user land (.../repos/aburn/usr/).

#This simply includes the module-wide Google Test cmake script that all modules use
#to create a Test Project so Google Test can be used within a module.
#This CMake script is located in "..../usr/include/cmake/aftrModule_GTest_Proj.cmake"

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "ENTERING Inside of Google Test Setup..."          )
MESSAGE( STATUS "" )


#Compiler settings must be set *before* the add_library / add_execuatable call.
include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_set_compiler_settings.cmake" )
set_compiler_settings( GTest_lib )
set_compiler_settings( GTest )

set( test_sources "" )
set( sources "" )
set( headers "" )
FILE( GLOB test_sources "./*.cpp" )
FILE( GLOB sources "../*.cpp" )
FILE( GLOB headers "../*.h" )

#Google Test cannot have a main.cpp or the entry point gets hijacked,
#so we must remove main.cpp from the list of sources to consider for GTest*
list( FILTER sources EXCLUDE REGEX ".*main\.cpp$" ) #Removes all files that end with main.cpp
message( STATUS "sources is ${sources}")
message( STATUS "test_sources is ${test_sources}")
add_library( GTest_lib "" )
target_sources( GTest_lib PRIVATE ${sources} ${headers})

add_executable( GTest "" ) #Source files added in target_sources command
target_sources( GTest PRIVATE ${test_sources} )
add_dependencies( GTest GTest_lib ) #GTest_lib must be built before GTest
target_link_libraries( GTest PRIVATE GTest_lib )

#All AFTR_CONFIG_USE_* variables are populated from the parent directory at this point

#Need to call a functionto include and link all AftrBurnerEngine dependencies
include( "${AFTR_PATH_TO_CMAKE_SCRIPTS}/aftr_include_and_link_deps_for_usrModule_exe.cmake" )
include_and_link_aburn_deps( GTest_lib )
include_and_link_aburn_deps( GTest )

include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc( GTest_lib )
include_and_link_optional_deps_for_usrModule_like_opencv_pcl_gtest_etc( GTest )


if( AFTR_USE_GTEST )
   target_link_libraries( GTest PRIVATE GTest::GTest GTest::Main ) #only link in the exact project that *is* the gtest exe, otherwise your entry point is hijacked
   #target_link_libraries( GTest_lib PRIVATE GTest::GTest GTest::Main ) #only link in the exact
endif()


add_test( 
   NAME GTest
   COMMAND $<TARGET_FILE:GTest>
   )

MESSAGE( STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                 "LEAVING Google Test Project Setup..." )
MESSAGE( STATUS "" )
