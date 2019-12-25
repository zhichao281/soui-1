#
# 1394020320@qq.com
#

#option(OUTPATH_WITHOUT_TYPE "Put All generation in same Path" ON)
if ("${OUTPATH_WITHOUT_TYPE}" STREQUAL "")
	set(OUTPATH_WITHOUT_TYPE 1)
endif()

#option(DOWNLOAD_COMPILE_DEMOS "下载并编译Soui-demo中的demo" OFF)
#
#
#

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#
# 设置输出目录
#
if (OUTPATH_WITHOUT_TYPE)
    message("---Put All generation in same Path")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/bin)
else()
    message("---Put All generation in different Path")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)
endif()

#
# 设置多线程编译
#
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP /wd4100 /wd4189 /wd4996")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /wd4100 /wd4189 /wd4996")

#
# 设置输入文件的后缀
#
set(CMAKE_DEBUG_POSTFIX "d")
set(CMAKE_RELEASE_POSTFIX "")
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "possible configurations" FORCE)

if (ENABLE_SOUI_CORE_LIB)
    message("---Building [soui] with LIB_CORE")
else()
    message("---Building [soui] with DLL_CORE")
endif()
if (ENABLE_SOUI_COM_LIB)
    message("---Building [soui components] with LIB_SOUI_COM")
else()
    message("---Building [soui components] with DLL_SOUI_COM")
endif()

macro( readSettingFile KEY DEFAULT_RESULT STRING_RESULT_OUT)

    unset(STRING_RESULT)

    file (TO_CMAKE_PATH "$ENV{SOUI3PATH}" SOUIROOTPATH)
    file(STRINGS "${SOUIROOTPATH}/config/build.cfg" CONFIGSTRING )

    foreach(LINE ${CONFIGSTRING})
        if("${LINE}" MATCHES "${KEY}=.*")
            string(REPLACE "${KEY}=" "" STRING_RESULT ${LINE})
        endif()
    endforeach()

    if("${STRING_RESULT}" STREQUAL "")
        set(STRING_RESULT ${DEFAULT_RESULT} )
    endif()

    set(${STRING_RESULT_OUT} ${STRING_RESULT})
    if ("${KEY}" STREQUAL "MT")
        if (${STRING_RESULT_OUT} STREQUAL "1")
            set(${STRING_RESULT_OUT} "0")
        else()
            set(${STRING_RESULT_OUT} "1")
        endif()
    endif()
endmacro()

set(CORE_LIBS CACHE INTERNAL "core_lib")
set(COM_LIBS CACHE INTERNAL "com_lib")
