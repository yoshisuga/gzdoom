message(STATUS "Creating GenZD (iOS) target configuration for zdoom")

message(STATUS "CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")

set(SDL2_FOUND TRUE)
set(SDL2_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/bin/iOS/sdl/include")
set(SDL2_LIBRARY "${CMAKE_SOURCE_DIR}/bin/iOS/sdl/libSDL2.a")
include_directories(SYSTEM "${SDL2_INCLUDE_DIR}")
message(STATUS "✓ SDL2 configured for iOS")


# Debug output
message(STATUS "iOS SDL2_INCLUDE_DIR: ${SDL2_INCLUDE_DIR}")
message(STATUS "iOS SDL2_LIBRARY: ${SDL2_LIBRARY}")

set(IOS_FRAMEWORKS_TO_EMBED
    "${CMAKE_SOURCE_DIR}/bin/iOS/MoltenVK.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/openal.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/zmusic.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/SharpYuv.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/VPX.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/WebP.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/WebPDecoder.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/WebPDemux.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/WebPMux.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/ZIPFoundation.framework"
    "${CMAKE_SOURCE_DIR}/bin/iOS/zmusiclite.framework"
)

set_target_properties(zdoom PROPERTIES
  OUTPUT_NAME "GenZD"
  XCODE_ATTRIBUTE_SDKROOT "iphoneos"
  XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.yoshisuga.genZD"
  XCODE_ATTRIBUTE_PRODUCT_NAME "GenZD"
  XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
  XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "15.0"
  XCODE_ATTRIBUTE_DEAD_CODE_STRIPPING "NO"
  XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "${CMAKE_SOURCE_DIR}/ios/zdoom-Bridging-Header.h"
  XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
  XCODE_ATTRIBUTE_INSTALL_PATH "/Applications"

  XCODE_ATTRIBUTE_FRAMEWORK_SEARCH_PATHS "$(PROJECT_DIR)/bin/iOS"
  LINK_FLAGS "-rpath @executable_path/Frameworks/MoltenVK.framework -rpath @executable_path/Frameworks"

  XCODE_EMBED_FRAMEWORKS "${IOS_FRAMEWORKS_TO_EMBED}"
  XCODE_EMBED_FRAMEWORKS_CODE_SIGN_ON_COPY TRUE
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/ios/genzd-template-info.plist"

  XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon18"
  XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES "AppIcon;AppIconZero;AppIconGold2;AppIconGold1"
)

set( CMAKE_EXE_LINKER_FLAGS "" )

target_link_libraries(zdoom
  "-framework AudioToolbox"
  "-framework AVFoundation"
  "-framework CoreAudio"
  "-framework CoreGraphics"
  "-framework CoreMIDI"
  "-framework CoreMotion"
  "-framework Foundation"
  "-framework GameController"
  "-framework IOSurface"
  "${CMAKE_SOURCE_DIR}/bin/iOS/sdl/libSDL2.a"
  "-framework MobileCoreServices"

  "${CMAKE_SOURCE_DIR}/bin/iOS/zmusic.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/zmusiclite.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/VPX.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/WebP.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/WebPDecoder.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/WebPDemux.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/WebPMux.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/SharpYuv.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/MoltenVK.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/openal.framework"
  "${CMAKE_SOURCE_DIR}/bin/iOS/ZIPFoundation.framework"
)

# Remove rt library for iOS (clock_gettime is in libc on iOS/macOS)
if(IOS OR CMAKE_SYSTEM_NAME STREQUAL "iOS")
    list(REMOVE_ITEM PROJECT_LIBRARIES rt)
    message(STATUS "Removed rt library for iOS build")
endif()

set(DYN_OPENAL OFF CACHE BOOL "Disable dynamic OpenAL loading for iOS" FORCE)

function(add_ios_sources target_name ios_source_dir)
    if(NOT EXISTS "${ios_source_dir}")
        message(STATUS "iOS source directory does not exist: ${ios_source_dir}")
        return()
    endif()
    
    message(STATUS "Adding iOS sources from: ${ios_source_dir}")
    
    # Enable Swift if not already enabled
    enable_language(Swift OPTIONAL)
    
    # Find all source files recursively
    file(GLOB_RECURSE IOS_SOURCE_FILES 
        "${ios_source_dir}/*.swift"
        "${ios_source_dir}/*.m"
        "${ios_source_dir}/*.mm"
        "${ios_source_dir}/*.cpp"
        "${ios_source_dir}/*.c"
        "${ios_source_dir}/*.h"
    )

    if(NOT target_name STREQUAL "genzd-zero")
        message(STATUS "Excluding free-version-only files for target: ${target_name}")
        list(FILTER IOS_SOURCE_FILES EXCLUDE REGEX ".*UpgradeView\\.swift$")
        list(FILTER IOS_SOURCE_FILES EXCLUDE REGEX ".*PurchaseViewModel\\.swift$")
    else()
        message(STATUS "Including all files for free version target: ${target_name}")
    endif()
    
    # Find all resource files recursively
    file(GLOB_RECURSE IOS_RESOURCE_FILES
        "${ios_source_dir}/*.md"
        "${ios_source_dir}/*.storyboard"
        "${ios_source_dir}/*.ttf"
    )

    # Add .xcassets directories explicitly
    file(GLOB XCASSETS_DIRS "${ios_source_dir}/*.xcassets")
    list(APPEND IOS_RESOURCE_FILES ${XCASSETS_DIRS})

    # exclude tvOS for now
    list(FILTER IOS_RESOURCE_FILES EXCLUDE REGEX ".*tvOS\\.storyboard$")
    
    # Add source files to target
    if(IOS_SOURCE_FILES)
        target_sources(${target_name} PRIVATE ${IOS_SOURCE_FILES})
        
        # Set special properties for different file types
        foreach(source_file ${IOS_SOURCE_FILES})
            if(source_file MATCHES "\\.mm$")
                # Objective-C++ files might need special flags
                set_source_files_properties("${source_file}"
                    PROPERTIES COMPILE_FLAGS "-fobjc-arc")
            elseif(source_file MATCHES "\\.m$")
                # Objective-C files
                set_source_files_properties("${source_file}"
                    PROPERTIES COMPILE_FLAGS "-fobjc-arc")
            endif()
        endforeach()
    endif()
    
    # Add resource files with proper properties for iOS bundles
    if(IOS_RESOURCE_FILES)
        target_sources(${target_name} PRIVATE ${IOS_RESOURCE_FILES})
        set_source_files_properties(${IOS_RESOURCE_FILES}
            PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    endif()
    
    # Create hierarchical source groups that preserve exact folder structure
    foreach(source_file ${IOS_SOURCE_FILES})
        get_filename_component(file_dir ${source_file} DIRECTORY)
        file(RELATIVE_PATH rel_dir "${ios_source_dir}" ${file_dir})
        
        if(rel_dir STREQUAL "")
            # File is in root iOS directory
            source_group("iOS Sources" FILES ${source_file})
        else()
            # File is in subdirectory - preserve the exact path
            string(REPLACE "/" "\\" rel_dir_win ${rel_dir})
            source_group("iOS Sources\\${rel_dir_win}" FILES ${source_file})
        endif()
    endforeach()
    
    # Create separate resource groups
    # foreach(resource_file ${IOS_RESOURCE_FILES})
    #     get_filename_component(file_dir ${resource_file} DIRECTORY)
    #     file(RELATIVE_PATH rel_dir "${ios_source_dir}" ${file_dir})
        
    #     if(rel_dir STREQUAL "")
    #         # Resource is in root iOS directory
    #         source_group("iOS Resources" FILES ${resource_file})
    #     else()
    #         # Resource is in subdirectory
    #         string(REPLACE "/" "\\" rel_dir_win ${rel_dir})
    #         source_group("iOS Resources\\${rel_dir_win}" FILES ${resource_file})
    #     endif()
    # endforeach()
    
    # Set up Swift bridging header if it exists
    set(BRIDGING_HEADER "${ios_source_dir}/zdoom-Bridging-Header.h")
    if(EXISTS "${BRIDGING_HEADER}")
        set_target_properties(${target_name} PROPERTIES
            XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "${BRIDGING_HEADER}")
    endif()
    
    set_target_properties(${target_name} PROPERTIES
        XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
        # XCODE_ATTRIBUTE_SWIFT_OBJC_INTERFACE_HEADER_NAME "${target_name}-Swift.h"
    )
    
    # Report what was added
    list(LENGTH IOS_SOURCE_FILES source_count)
    list(LENGTH IOS_RESOURCE_FILES resource_count)
    message(STATUS "✓ iOS: ${source_count} source files, ${resource_count} resources")
    
endfunction()

add_ios_sources(zdoom "${CMAKE_SOURCE_DIR}/src/ios")

message(STATUS "GenZD target configuration complete")
