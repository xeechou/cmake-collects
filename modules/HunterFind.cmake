## find the package in system, if not, try hunter, note that this small
## function requires HunterGate included first

option(HUNTER_SKIP_SYSTEM "Skip searching system libraries" OFF)

function(find_package_or_hunter)
  if (HUNTER_SKIP_SYSTEM)
    hunter_add_package(${ARGV})
    find_package(${ARGV} REQUIRED)
  else() #try finding the
    find_package(${ARGV} QUIET)
    if (NOT ${ARGV0}_FOUND)
      hunter_add_package(${ARGV})
      find_package(${ARGV} REQUIRED)
    endif()
  endif()
endfunction()
