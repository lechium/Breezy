ARCHS = arm64
target ?= appletv:clang:latest:12.4
export THEOS=/Users/$(shell whoami)/Projects/theos
export GO_EASY_ON_ME=1
THEOS_DEVICE_IP=living-room.local
DEBUG=1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Breezy
Breezy_FILES = Breezy.xm FindProcess.m CTBlockDescription.m Log.m
#Breezy_FILES = SVProgressHUD/SVIndefiniteAnimatedView.m SVProgressHUD/SVProgressHUD.m SVProgressHUD/SVRadialGradientLayer.m
Breezy_LIBRARIES = substrate
Breezy_FRAMEWORKS = Foundation UIKit CoreGraphics
#Breezy_LDFLAGS = 
Breezy_CFLAGS = -fobjc-arc -Iinclude -Wno-module-import-in-extern-c
Breezy_LDFLAGS = -F. -framework FrontBoardServices -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	./make.sh

after-install::
	install.exec "killall -9 sharingd lsd PineBoard"
#SUBPROJECTS += provscience
SUBPROJECTS += vlcscience
SUBPROJECTS += bundle
include $(THEOS_MAKE_PATH)/aggregate.mk
