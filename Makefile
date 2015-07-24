THEOS_PACKAGE_DIR_NAME = debs
TARGET = iphone:clang:latest:8.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Arpeggio
Arpeggio_FILES = Dated.xm
Arpeggio_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 Music"
