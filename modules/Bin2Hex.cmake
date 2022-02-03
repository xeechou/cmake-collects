# The function generates a _hex array from given file

# You write this in the function it will be able to run.
# This should be a script.

function(bin2hex _hex _input_file)
  if(NOT EXISTS ${_input_file})
    message(FATAL_ERROR "bin2hex: ${_input_file} does not exist")
  endif()
  # read file into a long hex array
  file(READ "${_input_file}" contents HEX)
  # separate every 2 hex value into a byte, thus forms a list
  string(REGEX MATCHALL "[A-Fa-f0-9][A-Fa-f0-9]" separate ${contents})
  set(${_hex} ${separate} PARENT_SCOPE)

endfunction()
