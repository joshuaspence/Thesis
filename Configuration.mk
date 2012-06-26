# Directories
BUILD_DIR  := build
OTHER_DIRS := data
EXT_DIRS   := ext
IMG_DIRS   := img
SRC_DIRS   := src

# Files in the build directory which should not be deleted on a 'clean'
BUILD_PERSIST := 

# The location of the LaTeX sources files
BIB_DIRS := $(SRC_DIRS)
BST_DIRS := $(EXT_DIRS)
CLS_DIRS := $(EXT_DIRS)
STY_DIRS := $(EXT_DIRS) $(SRC_DIRS)
TEX_DIRS := $(SRC_DIRS)
