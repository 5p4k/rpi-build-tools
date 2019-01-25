include(${CMAKE_CURRENT_LIST_DIR}/RPiToolchain.cmake)

string(PREPEND CMAKE_CXX_FLAGS_INIT             "-stdlib=libc++ ")
string(PREPEND CMAKE_CXX_FLAGS                  "-stdlib=libc++ ")
string(PREPEND CMAKE_CXX_STANDARD_LIBRARIES     "-static -lc++abi -lpthread ")
