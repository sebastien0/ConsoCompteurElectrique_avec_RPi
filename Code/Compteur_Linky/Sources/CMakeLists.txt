cmake_minimum_required (VERSION 2.6)

# Project name
project(RPi)

# Target of executable
set(EXECUTABLE_OUTPUT_PATH ../bin/)

# Headers
include_directories(inc/)

# Sources
file(
	GLOB_RECURSE
	source_files
	src/*.c
)

add_executable(
	RPi
	${source_files}
)


set(CMAKE_CXX_FLAGS "-W -Wall -pipe -ldl -export-dynamic")
