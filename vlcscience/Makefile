#INSTALL_TARGET_PROCESSES = VLC-tvOS
ARCHS = arm64
export THEOS=/Users/$(shell whoami)/Projects/theos
target ?= appletv:clang:latest:10.0
export GO_EASY_ON_ME=1
export DEBUG=1
THEOS_DEVICE_IP=guest-room.local
THEOS_PACKAGE_INSTALL_PREFIX = "/fs/jb/"

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = vlcscience

vlcscience_FILES = VLC.x
vlcscience_CFLAGS = -fobjc-arc -I../include
vlcscience_INSTALL_PATH=/fs/jb/Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/tweak.mk
