ARCHS = arm64
target ?= appletv:clang:12.4
export GO_EASY_ON_ME=1
THEOS_DEVICE_IP=guest-room.local
DEBUG=0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Breezy
Breezy_FILES = Breezy.xm FindProcess.m CTBlockDescription.m
#Breezy_FILES = SVProgressHUD/SVIndefiniteAnimatedView.m SVProgressHUD/SVProgressHUD.m SVProgressHUD/SVRadialGradientLayer.m
Breezy_LIBRARIES = substrate
Breezy_FRAMEWORKS = Foundation UIKit CoreGraphics CoreServices
#Breezy_LDFLAGS = 
Breezy_CFLAGS = -fobjc-arc
Breezy_LDFLAGS = -F. -framework FrontBoardServices -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	./make.sh

after-install::
	install.exec "killall -9 sharingd lsd PineBoard"
SUBPROJECTS += provscience
SUBPROJECTS += vlcscience
SUBPROJECTS += bundle
include $(THEOS_MAKE_PATH)/aggregate.mk
