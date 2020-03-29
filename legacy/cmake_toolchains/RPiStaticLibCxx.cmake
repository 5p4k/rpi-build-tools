include(${CMAKE_CURRENT_LIST_DIR}/RPiLibCxx.cmake)

# Change the linking flags:
#  -nostdlib++ will prevent linking against libc++.so
#  -l:libc++(abi).a will link statically against libc++
#  -lpthread is needed because it's used by the standard library
set(CMAKE_CXX_STANDARD_LIBRARIES "-l:libc++.a -l:libc++abi.a -lpthread -nostdlib++")
