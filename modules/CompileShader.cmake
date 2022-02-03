find_program(GLSLC_EXE NAMES glslc REQUIRED)
if (NOT GLSLC_EXE)
  message(FATAL "The glslc executable is not available. You must install it")
endif()

################################################################################

macro(compile_shader_parse_options)

  if(${CS_INVERT_Y})
    set(ARG_INVERT_Y "-finvert-y")
  endif()

  if(${CS_DEBUG})
    set(ARG_DEBUG "-g")
  endif()

  if(${CS_WERROR})
    set(ARG_WERROR "-Werror")
  endif()

  if(${CS_HLSL})   #compiling HLSL shader
    set(ARG_LANG -x hlsl -fhlsl_functionality1)
  else() #default to glsl shader
    set(ARG_LANG -x glsl)
  endif()

  if(${CS_OPT_PERF})
    set(ARG_OPTIMIZE "-O")
  elseif(${CS_OPT_SIZE})
    set(ARG_OPTIMIZE "-Os")
  else()
    set(ARG_OPTIMIZE "-O0")
  endif()

endmacro()

################################################################################

macro(compile_shader_parse_oneargs)
  if(NOT DEFINED CS_INPUT OR NOT EXISTS "${CS_INPUT}")
    message(FATAL_ERROR "shader compiler requires input")
  endif()

  if(NOT DEFINED CS_OUTPUT)
    message(FATAL_ERROR "shader compiler requires writing output")
  endif()

  if(DEFINED CS_STAGE)
    set(ARG_STAGE "-fshader-stage=${CS_STAGE}")
  endif()

  if(DEFINED CS_TARGET)
    set(ARG_TARGET "--target-env=vulkan${CS_TARGET}")
  else()
    set(ARG_TARGET "--target-env=vulkan1.2")
  endif()

endmacro()

################################################################################

macro(compile_shader_parse_mulargs)
  #adding macros
  foreach(def IN LISTS CS_MACROS)
    list(APPEND ARG_DEFS "-D${def}")
  endforeach()

  foreach(inc IN LISTS CS_INCLUDES)
    if(EXISTS ${inc})
      list(APPEND ARG_INCLUDE -I ${inc})
    else()
      message(FATAL_ERROR "include directory ${inc} does not exist")
    endif()
  endforeach()

endmacro()

################################################################################
#now you can simply add the _spirv to a custom target
function(compile_shader)
  set(options INVERT_Y DEBUG WERROR OPT_SIZE OPT_PERF HLSL)
  set(oneValueArgs INPUT OUTPUT STAGE TARGET)
  set(multiValueArgs MACROS INCLUDES)
  cmake_parse_arguments(CS "${options}" "${oneValueArgs}"
    "${multiValueArgs}" ${ARGN} )

  set(TMPDIR $ENV{TMP})
  if (NOT TMPDIR)
    set(TMPDIR "${CMAKE_CURRENT_BINARY_DIR}/tmp")
  endif()

  get_filename_component(dir      "${CS_INPUT}" DIRECTORY)
  get_filename_component(infile   "${CS_INPUT}" ABSOLUTE)
  get_filename_component(basename "${CS_INPUT}" NAME)
  set(spirv "${TMPDIR}/${basename}.spv")
  set("${CS_OUTPUT}" ${spirv} PARENT_SCOPE)

  compile_shader_parse_options()
  compile_shader_parse_oneargs()
  compile_shader_parse_mulargs()

  # -C will generate the spirv, -E preprocess it, -S generate assemply code.

  #add_custom_command does not simply run, it need the dependency to drive it,
  #this is usually achieved by `add_custom_target` and `add_dependencies`
  add_custom_command(
    OUTPUT "${spirv}"
    COMMAND ${CMAKE_COMMAND} -E make_directory ${TMPDIR}
    COMMAND ${GLSLC_EXE} "${infile}" -o "${spirv}"
    ${ARG_OPTIMIZE} ${ARG_DEBUG} ${ARG_INVERT_Y} ${ARG_WERROR} ${ARG_LANG}
    ${ARG_INCLUDE}  ${ARG_STAGE} ${ARG_TARGET} ${ARG_DEFS}
    WORKING_DIRECTORY "${dir}"
    DEPENDS "${infile}"
    COMMAND_EXPAND_LISTS
    VERBATIM)

endfunction(compile_shader)
