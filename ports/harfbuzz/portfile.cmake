include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 1.9.0
    SHA512 132cd6bb3718d4c7bc072edd641bfa0cdc62c1a9ddb48c58ebd03ad7e4bd861fa2687093c99c2b4bd47c407af62f6b0b26fb97427fa17ca2264385ce2c360d31
    HEAD_REF master
    PATCHES
        0001-fix-uwp-build.patch
        find-package-freetype-2.patch
        glib-cmake.patch
        0001-fix-cmake-export.patch
)

SET(HB_HAVE_ICU "OFF")
if("icu" IN_LIST FEATURES)
    SET(HB_HAVE_ICU "ON")
endif()

SET(HB_HAVE_GRAPHITE2 "OFF")
if("graphite2" IN_LIST FEATURES)
    SET(HB_HAVE_GRAPHITE2 "ON")
endif()

## Unicode callbacks

# Builtin (UCDN)
set(BUILTIN_UCDN OFF)
if("ucdn" IN_LIST FEATURES)
    set(BUILTIN_UCDN ON)
endif()

# Glib
set(HAVE_GLIB OFF)
if("glib" IN_LIST FEATURES)
    set(HAVE_GLIB ON)
endif()

# At least one Unicode callback must be specified, or harfbuzz compilation fails
if(NOT (BUILTIN_UCDN OR HAVE_GLIB))
    message(FATAL_ERROR "Error: At least one Unicode callback must be specified (ucdn, glib).")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DHB_HAVE_FREETYPE=ON
        -DHB_BUILTIN_UCDN=${BUILTIN_UCDN}
        -DHB_HAVE_ICU=${HB_HAVE_ICU}
        -DHB_HAVE_GLIB=${HAVE_GLIB}
        -DHB_HAVE_GRAPHITE2=${HB_HAVE_GRAPHITE2}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-harfbuzz TARGET_PATH share/unofficial-harfbuzz)
vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/harfbuzz/COPYING ${CURRENT_PACKAGES_DIR}/share/harfbuzz/copyright)

vcpkg_test_cmake(PACKAGE_NAME unofficial-harfbuzz)
