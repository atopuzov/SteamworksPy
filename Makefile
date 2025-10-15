# Makefile for SteamworksPy

# Default compiler settings
CXX ?= g++
CXXFLAGS ?= -std=c++11 -fPIC
LDFLAGS ?=
TARGET ?= SteamworksPy.so

# Default Steam SDK paths (for local development)
STEAM_INCLUDE_DIR ?= steam-include
STEAM_LIB_DIR ?= .

# Add Steam SDK includes and libs to flags
CXXFLAGS += -I$(STEAM_INCLUDE_DIR)
LDFLAGS += -L$(STEAM_LIB_DIR)

# OS-specific settings
ifeq ($(OS),Windows_NT)
    CXX = cl
    CXXFLAGS = /MD
    TARGET = SteamworksPy.dll
    BUILD_CMD = $(CXX) $(CXXFLAGS) -I$(STEAM_INCLUDE_DIR) /LD /Fe$(TARGET) SteamworksPy.cpp /link /LIBPATH:$(STEAM_LIB_DIR) steam_api64.lib
    CLEAN_CMD = del $(TARGET)
else ifeq ($(shell uname -s),Darwin)
    # macOS specific settings
    export MACOSX_DEPLOYMENT_TARGET=10.12
    TARGET_X86_64 = SteamworksPy_x86_64.dylib
    TARGET_ARM64 = SteamworksPy_arm64.dylib
    FAT_TARGET = SteamworksPy.dylib
    CLEAN_CMD = rm -f $(TARGET_X86_64) $(TARGET_ARM64) $(FAT_TARGET)
else
    # Linux specific settings
    CLEAN_CMD = rm -f $(TARGET)
endif

all:
ifeq ($(OS),Windows_NT)
	$(BUILD_CMD)
else ifeq ($(shell uname -s),Darwin)
	$(MAKE) fat_dylib
else
	$(MAKE) $(TARGET)
endif

makeall: all

fat_dylib: $(TARGET_X86_64) $(TARGET_ARM64)
	lipo -create -output $(FAT_TARGET) $(TARGET_X86_64) $(TARGET_ARM64)

$(TARGET_X86_64): SteamworksPy.cpp
	$(CXX) $(CXXFLAGS) -arch x86_64 -o $@ -shared $< $(LDFLAGS) -lsteam_api

$(TARGET_ARM64): SteamworksPy.cpp
	$(CXX) $(CXXFLAGS) -arch arm64 -o $@ -shared $< $(LDFLAGS) -lsteam_api

$(TARGET): SteamworksPy.cpp
	$(CXX) $(CXXFLAGS) -o $@ -shared $< $(LDFLAGS) -lsteam_api

clean:
	$(CLEAN_CMD)

# Phony targets
.PHONY: all makeall clean fat_dylib
