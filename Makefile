THEOS_PACKAGE_DIR_NAME = debs
TARGET = iphone:clang:latest
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Arpeggio
Arpeggio_FILES = Arpeggio.xm
Arpeggio_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 Music"
