include_guard()


####################################
#MakeAbsolute takes a variable as input ie (MakeAbsolute( AFTR_USERLAND_ROOT_DIR ) and will overwrite
#the variable replacing it with a normalized absolute file path.
function( MakeAbsolute path )
   set( aPath "${${path}}" )   
   cmake_path( SET aPath NORMALIZE "${aPath}" ) #https://cmake.org/cmake/help/latest/command/cmake_path.html#normalization
   #MESSAGE( STATUS "In MakeAbsolute and converted ${${path}} -> ${aPath}")
   set( ${path} ${aPath} PARENT_SCOPE )
endfunction()
####################################

####################################
# Get all propreties that cmake supports
execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)

# Convert command output into a CMake list
STRING(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
STRING(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
# Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
list(FILTER CMAKE_PROPERTY_LIST EXCLUDE REGEX "^LOCATION$|^LOCATION_|_LOCATION$")
# For some reason, "TYPE" shows up twice - others might too?
list(REMOVE_DUPLICATES CMAKE_PROPERTY_LIST)

# build whitelist by filtering down from CMAKE_PROPERTY_LIST in case cmake is
# a different version, and one of our hardcoded whitelisted properties
# doesn't exist!
unset(CMAKE_WHITELISTED_PROPERTY_LIST)

foreach(prop ${CMAKE_PROPERTY_LIST})
    if(prop MATCHES "^(INTERFACE|[_a-z]|IMPORTED_LIBNAME_|MAP_IMPORTED_CONFIG_)|^(COMPATIBLE_INTERFACE_(BOOL|NUMBER_MAX|NUMBER_MIN|STRING)|EXPORT_NAME|IMPORTED(_GLOBAL|_CONFIGURATIONS|_LIBNAME)?|NAME|TYPE|NO_SYSTEM_FROM_IMPORTED)$")
        list(APPEND CMAKE_WHITELISTED_PROPERTY_LIST ${prop})
    endif()
endforeach(prop)

####################################
#Given a target, this prints all properties for that given target. For example,
#print_target_properties( SDL2 )       #Displays all properties in CMake related to SDL2
#print_target_properties( SDL2::SDL2 ) #Displays all properties in CMake related to SDL2::SDL2 target (linker/include/interface settings)
function(print_target_properties tgt)  ###Calling this prints all target properties for a target. ex:    print_target_properties( SDL2::SDL2 )
    if(NOT TARGET ${tgt})
        message("There is no target named '${tgt}'")
        return()
    endif()

    get_target_property(target_type ${tgt} TYPE)
    if(target_type STREQUAL "INTERFACE_LIBRARY")
        set(PROP_LIST ${CMAKE_WHITELISTED_PROPERTY_LIST})
    else()
        set(PROP_LIST ${CMAKE_PROPERTY_LIST})
    endif()

    foreach (prop ${PROP_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
        # message ("Checking ${prop}")
        get_property(propval TARGET ${tgt} PROPERTY ${prop} SET)
        if (propval)
            get_target_property(propval ${tgt} ${prop})
            message ("${tgt} ${prop} = ${propval}")
        endif()
    endforeach(prop)
endfunction(print_target_properties)
####################################


####################################
function( aftr_populate_external_projects_sources_and_headers sources headers )

    MESSAGE( STATUS "IN FUNCTION aftr_populate_external_projects_sources_and_headers(sources headers)..." )
    
    set( external_src "" )
    set( external_h "" )

    IF( AFTR_CONFIG_USE_FREE_TYPE_GL_FONTS ) #only compile the FTGL source files if AFTR_CONFIG_USE_FREE_TYPE_GL_FONTS is ON (via the checkbox for the engine build).
        FILE( GLOB sourcesFTGL "${AFTR_EXTERNAL_PROJECTS_ROOT}/FTGL/*.cpp" )
        FILE( GLOB headersFTGL "${AFTR_EXTERNAL_PROJECTS_ROOT}/FTGL/*.h" )
        MakeAbsolute( sourcesFTGL )
        MakeAbsolute( headersFTGL )
        SET( external_src "${external_src};${sourcesFTGL}" )
        SET( external_h   "${external_h};${headersFTGL}" )
        MESSAGE( STATUS "AFTR_CONFIG_USE_FREE_TYPE_GL_FONTS is ON for engine build, including ${AFTR_EXTERNAL_PROJECTS_ROOT}/FTGL/*.h|cpp" )
        MESSAGE( STATUS "FTGL Sources are ${sourcesFTGL}" )
        MESSAGE( STATUS "FTGL Headers are ${headersFTGL}" )
    ENDIF()                  

    IF( AFTR_CONFIG_USE_IMGUI ) #only compile the ImGui source files if AFTR_CONFIG_USE_IMGUI is ON (via the checkbox for the engine build).
        FILE( GLOB sourcesIMGUI                 "${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui/*.cpp" )        #Get ImGui cpp files
        FILE( GLOB sourcesIMGUI_h               "${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui/imgui.h" )      #Include imgui.h for the IDE to more easily find it
        FILE( GLOB sourcesIMPLOT                "${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui/implot/*.cpp" ) #Get ImPlot cpp files
        FILE( GLOB sourcesIMPLOT_h              "${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui/implot/implot.h" ) #Get ImPlot header file
        FILE( GLOB sourcesIMGUI_misc_cpp_stdlib "${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui/misc/cpp/*.cpp" ) #Get ImPlot cpp files
        MakeAbsolute( sourcesIMGUI )
        MakeAbsolute( sourcesIMGUI_h )
        MakeAbsolute( sourcesIMPLOT )
        MakeAbsolute( sourcesIMPLOT_h )
        MakeAbsolute( sourcesIMGUI_misc_cpp_stdlib )
        SET( external_src "${external_src};${sourcesIMGUI};${sourcesIMGUI_h};${sourcesIMPLOT};${sourcesIMPLOT_h};${sourcesIMGUI_misc_cpp_stdlib}" )
        #The aftrModuleCMakeHelper will include the header files for imgui, if the library is enabled.
        MESSAGE( STATUS "AFTR_CONFIG_USE_IMGUI is ON for engine build, including ${AFTR_EXTERNAL_PROJECTS_ROOT}/implot/*.h|cpp" )
        MESSAGE( STATUS "IMGUI  Sources are ${sourcesIMGUI}" )
        MESSAGE( STATUS "IMPLOT Sources are ${sourcesIMPLOT}" )
        MESSAGE( STATUS "IMGUI std lib Sources are ${sourcesIMGUI_misc_cpp_stdlib}" )
    ENDIF()

    SET( sources "${sources};${external_src}" PARENT_SCOPE )
    SET( headers "${headers};${external_h}"   PARENT_SCOPE )

endfunction()
####################################

macro( query_AftrConfig_h_for_PREPROCESSOR_DIRECTIVES_and_populate_corresponding_cmake_vars )
    #Let's check the userland's AftrConfig.h for certain #defines, like AFTR_CONFIG_USE_OCULUS_RIFT_OVR
    #if that is used, then include the corresponding header files and library linker information, else no need to include them.

    #CMAKE TRUE/FALSE NOTE:  (https://cmake.org/cmake/help/v3.0/command/if.html)
    #          False is the constant is 0, OFF, NO, FALSE, N, IGNORE, NOTFOUND, the empty string, or ends in the suffix -NOTFOUND.
    #          True is the constant is 1, ON, YES, TRUE, Y, or a non-zero number.
    MESSAGE( STATUS "---------------------- Inspecting AftrConfig.h for Engine-defined PREPROCESSOR DIRECTIVES ----------------------" )
    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_FREE_TYPE" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_FREE_TYPE )
    MESSAGE( STATUS "AFTR_CONFIG_USE_FREE_TYPE is: ${AFTR_CONFIG_USE_FREE_TYPE}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_FREE_TYPE_GL_FONTS" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_FREE_TYPE_GL_FONTS )
    MESSAGE( STATUS "AFTR_CONFIG_USE_FREE_TYPE_GL_FONTS is: ${AFTR_CONFIG_USE_FREE_TYPE_GL_FONTS}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_FONTS" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_FONTS )
    MESSAGE( STATUS "AFTR_CONFIG_USE_FONTS is: ${AFTR_CONFIG_USE_FONTS}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_OCULUS_RIFT_OVR" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_OCULUS_RIFT_OVR )
    MESSAGE( STATUS "AFTR_CONFIG_USE_OCULUS_RIFT_OVR is: ${AFTR_CONFIG_USE_OCULUS_RIFT_OVR}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_OCULUS_RIFT_DK2" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_OCULUS_RIFT_DK2 )
    MESSAGE( STATUS "AFTR_CONFIG_USE_OCULUS_RIFT_DK2 is: ${AFTR_CONFIG_USE_OCULUS_RIFT_DK2}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_KEYLOK_DONGLE" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_KEYLOK_DONGLE )
    MESSAGE( STATUS "AFTR_CONFIG_USE_KEYLOK_DONGLE is: ${AFTR_CONFIG_USE_KEYLOK_DONGLE}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_GDAL" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_GDAL )
    MESSAGE( STATUS "AFTR_CONFIG_USE_GDAL is: ${AFTR_CONFIG_USE_GDAL}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_ASSIMP" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_ASSIMP )
    MESSAGE( STATUS "AFTR_CONFIG_USE_ASSIMP is: ${AFTR_CONFIG_USE_ASSIMP}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_3DS" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_3DS )
    MESSAGE( STATUS "AFTR_CONFIG_USE_3DS is: ${AFTR_CONFIG_USE_3DS}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_IMGUI" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_IMGUI )
    MESSAGE( STATUS "AFTR_CONFIG_USE_IMGUI is: ${AFTR_CONFIG_USE_IMGUI}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_OGL_GLEW" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_OGL_GLEW )
    MESSAGE( STATUS "AFTR_CONFIG_USE_OGL_GLEW is: ${AFTR_CONFIG_USE_OGL_GLEW}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_FMT_LIB" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_FMT_LIB )
    MESSAGE( STATUS "AFTR_CONFIG_USE_FMT_LIB is: ${AFTR_CONFIG_USE_FMT_LIB}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_RANGE_V3_LIB" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_RANGE_V3_LIB )
    MESSAGE( STATUS "AFTR_CONFIG_USE_RANGE_V3_LIB is: ${AFTR_CONFIG_USE_RANGE_V3_LIB}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_EIGEN_V3" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_EIGEN_V3 )
    MESSAGE( STATUS "AFTR_CONFIG_USE_EIGEN_V3 is: ${AFTR_CONFIG_USE_EIGEN_V3}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_GTEST_LIB" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_GTEST_LIB )
    MESSAGE( STATUS "AFTR_CONFIG_USE_GTEST_LIB is: ${AFTR_CONFIG_USE_GTEST_LIB}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_CAL3D" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_CAL3D )
    MESSAGE( STATUS "AFTR_CONFIG_USE_CAL3D is: ${AFTR_CONFIG_USE_CAL3D}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_ODE" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_ODE )
    MESSAGE( STATUS "AFTR_CONFIG_USE_ODE is: ${AFTR_CONFIG_USE_ODE}" )

    CHECK_SYMBOL_EXISTS( "AFTR_CONFIG_USE_BOOST" "${AFTR_USR_INCLUDE_DIR}/AftrConfig.h" AFTR_CONFIG_USE_BOOST )
    MESSAGE( STATUS "AFTR_CONFIG_USE_BOOST is: ${AFTR_CONFIG_USE_BOOST}" )
    MESSAGE( STATUS "---------------------- Done looking inside of AftrConfig.h for Engine-defined PREPROCESSOR DIRECTIVES ----------" )
endmacro()