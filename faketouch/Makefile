export THEOS_DEVICE_IP = 192.168.2.20
export ARCHS = armv7
TARGET = iphone:latest:7.0
export DEBUG = 0
GO_EASY_ON_ME=1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FakeTouch
FakeTouch_FILES = Tweak.xm
FakeTouch_FRAMEWORKS = UIKit SystemConfiguration CoreFoundation  CoreGraphics CoreMedia  Foundation AudioToolbox
FakeTouch_PRIVATE_FRAMEWORKS = IOKit 
FakeTouch_LDFLAGS += PTFakeTouch
include $(THEOS_MAKE_PATH)/tweak.mk


after-install::
	install.exec "killall -9 WeChat"

include $(THEOS_MAKE_PATH)/aggregate.mk
