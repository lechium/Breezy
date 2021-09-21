#INSTALL_TARGET_PROCESSES = Provenance
ARCHS = arm64
target ?= appletv:clang:14.3:10.0
export GO_EASY_ON_ME=1
export DEBUG=0
THEOS_DEVICE_IP=guest-room.local

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = provscience

provscience_FILES = Tweak.x
provscience_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
