ARCHS = arm64
target ?= appletv:clang:10.2.2:10.0
export GO_EASY_ON_ME=1
THEOS_DEVICE_IP=4k.local
DEBUG=1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Breezy
Breezy_FILES = Breezy.xm FindProcess.m CTBlockDescription.m Extra.xm
#Breezy_FILES = SVProgressHUD/SVIndefiniteAnimatedView.m SVProgressHUD/SVProgressHUD.m SVProgressHUD/SVRadialGradientLayer.m
Breezy_LIBRARIES = substrate
Breezy_FRAMEWORKS = Foundation UIKit CoreGraphics MobileCoreServices
#Breezy_LDFLAGS = -undefined dynamic_lookup
Breezy_CFLAGS = -fobjc-arc -Iextobjc -Iextobjc/Extensions -Iextobjc/Modules 
Breezy_LDFLAGS = -F. -framework FrontBoardServices -Iextobjc -Iextobjc/Extensions -Iextobjc/Modules 

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	./make.sh

after-install::
	install.exec "killall -9 sharingd lsd PineBoard"
SUBPROJECTS += provscience
SUBPROJECTS += vlcscience
SUBPROJECTS += bundle
include $(THEOS_MAKE_PATH)/aggregate.mk
