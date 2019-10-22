INSTALL_TARGET_PROCESSES = Provenance
ARCHS = arm64
target ?= appletv:clang:10.2.2:10.0
export GO_EASY_ON_ME=1
THEOS_DEVICE_IP=4k.local

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = provscience

provscience_FILES = Tweak.x
provscience_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
