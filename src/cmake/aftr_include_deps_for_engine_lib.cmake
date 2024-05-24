include_guard()

function( include_deps_for_engine_lib )

TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE 
                           "${CMAKE_BINARY_DIR}"     #This lets the project find AftrConfig.h (CMake generated per target)
                           "${AFTR_ENGINE_SRC_DIR}"
                           "${AFTR_EXTERNAL_PROJECTS_ROOT}"
                           "${Boost_INCLUDE_DIRS}"
                          )

#Without adding this line into the engine build, CMake doesn't include SDL2's header files because of how modern cmake works
target_link_libraries( ${PROJECT_NAME} PRIVATE SDL2::SDL2 SDL2::SDL2main )
#Without adding this line into the engine build, CMake doesn't include glm's header files because of how modern cmake works
#glm is found within aftr_FindDependencies.cmake and is "linked" in here via cmake.
target_link_libraries( ${PROJECT_NAME} PRIVATE glm::glm )

IF( AFTR_CONFIG_USE_SDL_IMAGE )
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE "${SDL2Image_INCLUDE_DIR}" )
ENDIF()

IF( AFTR_CONFIG_USE_FREE_TYPE )
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE
                     "${FREETYPE_INCLUDE_DIRS}" )
ENDIF()

IF( AFTR_CONFIG_USE_CAL3D )
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE
                    "$ENV{AFTR_3RD_PARTY_ROOT}/cal3d-0.11rc2/src" )
ENDIF()

IF( AFTR_CONFIG_USE_3DS )
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE  
                    "$ENV{AFTR_3RD_PARTY_ROOT}/lib3ds-20080909/src" )
ENDIF()

IF( AFTR_CONFIG_USE_GDAL )
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE 
                    "${GDAL_INCLUDE_DIR}" )
ENDIF()

IF( AFTR_CONFIG_USE_OGL_GLEW )
   IF( UNIX )
      TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE 
                              "${GLEW_INCLUDE_DIRS}" )
   ENDIF()
   if( WIN32 )
      TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE 
                              "$ENV{AFTR_3RD_PARTY_ROOT}/glew-2.1.0/include" )
   endif()
ENDIF()

IF( AFTR_CONFIG_USE_ASSIMP )
   if( WIN32 )
      target_link_libraries( ${PROJECT_NAME} PRIVATE assimp::assimp )
   endif()
   if( UNIX )
      TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE  "${ASSIMP_INCLUDE_DIR}" ) #"${AFTR_3RD_PARTY_ROOT}/assimp-3.3.1/include" #Only include ASSIMP if it is enabled
   endif()
ENDIF()

IF( AFTR_CONFIG_USE_IMGUI ) #only compile the ImGui source files if AFTR_CONFIG_USE_IMGUI is ON (via the checkbox for the engine build).
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE 
                              "${AFTR_EXTERNAL_PROJECTS_ROOT}"  #Only include IMGUI if it is enabled
                              #"${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui/implot"  #Also include ImPlot so we can make awesome plots!
                              #$<BUILD_INTERFACE:${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui>
                              #$<BUILD_INTERFACE:"${AFTR_EXTERNAL_PROJECTS_ROOT}/imgui/implot">
                              #$<INSTALL_INTERFACE:"${AFTR_USR_ROOT}/include/external/imgui">
                              #$<INSTALL_INTERFACE:"${AFTR_USR_ROOT}/include/external/imgui/plot">
                             )
ENDIF()

IF( AFTR_CONFIG_USE_OCULUS_RIFT_OVR )
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE 
                           "$ENV{AFTR_3RD_PARTY_ROOT}/OculusSDK/ovr_sdk_win_1.26.0_public/OculusSDK/LibOVR/Include"
                             )
ENDIF()
                          
IF( AFTR_CONFIG_USE_OCULUS_RIFT_DK2 )
   TARGET_INCLUDE_DIRECTORIES( ${PROJECT_NAME} PRIVATE 
                           "$ENV{AFTR_3RD_PARTY_ROOT}/OculusSDK/ovr_sdk_win_0.4.4/" #Only include OculusSDK if it is enabled for DK2
                             )
ENDIF()

IF( AFTR_CONFIG_USE_ODE )
   target_link_libraries( ${PROJECT_NAME} PRIVATE ODE::ODE )
ENDIF()

IF( AFTR_CONFIG_USE_FMT_LIB )
   TARGET_LINK_LIBRARIES( ${PROJECT_NAME} PRIVATE fmt::fmt )
ENDIF()

IF( AFTR_CONFIG_USE_RANGE_V3_LIB )
   TARGET_LINK_LIBRARIES( ${PROJECT_NAME} PRIVATE range-v3::range-v3 )
ENDIF()

IF( AFTR_CONFIG_USE_EIGEN_V3 )
   TARGET_LINK_LIBRARIES( ${PROJECT_NAME} PRIVATE Eigen3::Eigen )
ENDIF()

endfunction()