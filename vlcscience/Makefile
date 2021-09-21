#INSTALL_TARGET_PROCESSES = VLC-tvOS
ARCHS = arm64
target ?= appletv:clang:14.3:10.0
export GO_EASY_ON_ME=1
export DEBUG=1
THEOS_DEVICE_IP=guest-room.local

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = vlcscience

vlcscience_FILES = VLC.x
vlcscience_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
