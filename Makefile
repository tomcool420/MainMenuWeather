GO_EASY_ON_ME=1
export SDKVERSION=4.1
export FW_DEVICE_IP=appletv.local
include theos/makefiles/common.mk

BUNDLE_NAME = MainMenuWeather
MainMenuWeather_FILES = MainMenuWeather.mm APXML/APAttribute.m APXML/APDocument.m APXML/APElement.m SMWeather/SMWeatherControl.m APXML/APXML_SMF.m
MainMenuWeather_FILES += MainMenuWeatherController.m MainMenuWeatherLocationController.m
MainMenuWeather_BUNDLE_EXTENSION = mext
MainMenuWeather_PRIVATE_FRAMEWORKS=IOSurface
MainMenuWeather_LDFLAGS = -undefined dynamic_lookup -framework UIKit
MainMenuWeather_CFLAGS  = -I../ATV2Includes
MainMenuWeather_INSTALL_PATH = /Library/MainMenuExtensions
MainMenuWeather_OBJ_FILES = /Users/tomcool/DVLP/ATV2/SMFramework/obj/SMFramework

include $(FW_MAKEDIR)/bundle.mk


after-install::
	ssh root@$(FW_DEVICE_IP) killall Lowtide