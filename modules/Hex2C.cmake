# write a
function(write_hex _output _hex_list)
  # message("${_hex_list}")
  set(counter 0)
  #iterate through the bytes
  foreach(hex IN LISTS _hex_list)
    #write a byte
    string(APPEND output "0x${hex}, ")
    # increment the element counter by 1
    math(EXPR counter "${counter}+1")
    #add a new line if written 16 bytes already
    if (counter GREATER 13)
      string(APPEND output "\n")
      set(counter 0)
    endif()
  endforeach()

  set(${_output} ${output} PARENT_SCOPE)
endfunction()

# I can use configure_file to do it
function(hex2c _output_c _output_h _name _hex_list)
  set(NAME ${_name})
  write_hex(HEXCODE "${_hex_list}")
  # message("${HEXCODE}")
  set(output_c "${CMAKE_CURRENT_BINARY_DIR}/${NAME}_shader_module.c")
  set(output_h "${CMAKE_CURRENT_BINARY_DIR}/${NAME}_shader_module.h")

  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/shader_module.h.in"
    ${output_h} @ONLY)
  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/shader_module.c.in"
    ${output_c} @ONLY)
  set(${_output_c} ${output_c} PARENT_SCOPE)
  set(${_output_h} ${output_h} PARENT_SCOPE)

endfunction()
