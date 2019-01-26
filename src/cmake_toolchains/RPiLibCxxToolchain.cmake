include(${CMAKE_CURRENT_LIST_DIR}/RPiToolchain.cmake)

# Select the right standard library. Clang knows where to find it
string(APPEND CMAKE_CXX_FLAGS_INIT " -stdlib=libc++")

# One must also link agains libc++abi
set(CMAKE_CXX_STANDARD_LIBRARIES "-lc++abi")
