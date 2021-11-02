# find system installed spirv-cross, the installation is usually done by the
# package manager of your Linux distribution, or you install it as lunarG SDK.

# TODO This probably wouln't work for windows since they have different linkage
# for debug and release libraries

#variables we check
set(CHECK_LIBS)
set(CHECK_INCDIRS)
#variables we link or include with
set(LIBS)
set(INCDIRS)

function(FindSC  _name LIBNAME DIRNAME)
  find_library(${LIBNAME}
    NAMES spirv-cross-${_name}

    HINTS
    ${VULKAN_SDK_PATH}/Lib #user defined
    $ENV{VULKAN_SDK}/Lib #sdk defined
    )

  #rename the lib if we are try to find the core library
  if (${_name} STREQUAL "core")
    set(_hname "")
  else()
    set(_hname "_${_name}")
  endif()

  find_path(${DIRNAME}
    NAMES
    spirv${_hname}.hpp
    spirv_cross${_hname}.hpp
    spirv_cross${_hname}.h    #for C components

    PATH_SUFFIXES spirv_cross

    HINTS
    ${VULKAN_SDK_PATH}/Include
    $ENV{VULKAN_SDK}/Include
    )

endfunction()

FindSC(core SC_CORE_LIB SC_CORE_INCDIR)
FindSC(cpp SC_CPP_LIB SC_CPP_INCDIR)

list(APPEND CHECK_LIBS     SC_CORE_LIB SC_CPP_LIB)
list(APPEND CHECK_INCDIRS  SC_CORE_INCDIR SC_CPP_INCDIR)
list(APPEND LIBS           ${SC_CORE_LIB} ${SC_CPP_LIB})
list(APPEND INCDIRS        ${SC_CORE_INCDIR} ${SC_CPP_INCDIR})


set(SC_COMPONENTS c glsl hlsl msl reflect util)
foreach(_comp ${SpirvCross_FIND_COMPONENTS})
  #find library and header
  if (NOT ";${SC_COMPONENTS};" MATCHES ${_comp})
    message(FATAL_ERROR "unsupported component ${_comp}")
  endif()
  findSC(${_comp} SC_${_comp}_LIB SC_${_comp}_INCDIR)
  list(APPEND CHECK_LIBS     SC_${_comp}_LIB)
  list(APPEND CHECK_INCDIRS  SC_${_comp}_INCDIR)
  list(APPEND LIBS           ${SC_${_comp}_LIB})
  list(APPEND INCDIRS        ${SC_${_comp}_INCDIR})

endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SpirvCross DEFAULT_MSG
  ${CHECK_LIBS} ${CHECK_INCDIRS})

if (SpirvCross_FOUND AND NOT TARGET SpirvCross::SpirvCross)
  list(REMOVE_DUPLICATES INCDIRS)
  list(REMOVE_DUPLICATES LIBS)
  #a imported_location has to be a file on the disk, so we just use the core
  #here, Later we will link against the all the libraries, it should be okay
  #as cmake do the transform automatically
  list(GET LIBS 0 SC_LOC)

  add_library(SpirvCross::SpirvCross UNKNOWN IMPORTED)
  target_include_directories(SpirvCross::SpirvCross INTERFACE ${INCDIRS})
  target_link_libraries(SpirvCross::SpirvCross INTERFACE ${LIBS})
  set_target_properties(SpirvCross::SpirvCross PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
    IMPORTED_LOCATION ${SC_LOC})

  # message(FATAL "include:   ${INCDIRS}")
  # message(FATAL "link with: ${LIBS}")

endif()
