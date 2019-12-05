ARCHS = arm64
TARGET = appletv:10.1:9.0
export GO_EASY_ON_ME=1
export SDKVERSION=10.2
THEOS_DEVICE_IP=twelve.local
DEBUG=0
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BreezySettings
BreezySettings_FILES = BreezySettings.m
BreezySettings_INSTALL_PATH = /Library/PreferenceBundles
BreezySettings_FRAMEWORKS = UIKit
BreezySettings_PRIVATE_FRAMEWORKS = TVSettingKit
BreezySettings_LDFLAGS = -undefined dynamic_lookup -IDownload
BreezySettings_CFLAGS+= -F. -IDownload
BreezySettings_CODESIGN_FLAGS=-Sent.plist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)
	cp -r $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences ../layout/Library/PreferenceLoader/
	cp -r $(THEOS_STAGING_DIR)/Library/PreferenceBundles/* ../layout/Library/PreferenceBundles/

after-install::
	install.exec "killall -9 TVSettings ; lsdtrip launch com.apple.TVSettings"
	
