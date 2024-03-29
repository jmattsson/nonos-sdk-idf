# The IDF only supports relative paths for the include dirs, so we have to
# come up with the correct relative path to the build dir using realpath(1)
#include $(COMPONENT_PATH)/relpath.mk
include $(COMPONENT_PATH)/relpath.mk
COMPONENT_ADD_INCLUDEDIRS:=$(call relpath,$(COMPONENT_BUILD_DIR)/sdk/include,$(COMPONENT_PATH))
COMPONENT_ADD_LDFLAGS:=-L$(COMPONENT_BUILD_DIR)/sdk/ld
COMPONENT_ADD_LINKERDEPS:=$(addprefix sdk/ld/,eagle.app.v6.ld eagle.rom.addr.v6.ld)
COMPONENT_OWNBUILDTARGET := build

NONOS_SDK_FILE_VER  := e4434aa730e78c63040ace360493aef420ec267c
NONOS_SDK_VER       := 3.0-e4434aa
NONOS_SDK_FILE_SHA1 := ac6528a6a206d3d4c220e4035ced423eb314cfbf
NONOS_SDK_ZIP_ROOT  := ESP8266_NONOS_SDK-$(NONOS_SDK_FILE_VER)
NONOS_SDK_GITHUB    := https://github.com/espressif/ESP8266_NONOS_SDK

WGET = wget --tries=10 --timeout=15 --waitretry=30 --read-timeout=20 --retry-connrefused


$(NONOS_SDK_FILE_VER).zip:
	@echo Downloading NON-OS SDK...
	$(WGET) $(NONOS_SDK_GITHUB)/archive/$(NONOS_SDK_FILE_VER).zip -O "$@" || { rm -f "$@"; exit 1; }
	if [ "$(NONOS_SDK_FILE_SHA1)" != "NA" ]; then echo "$(NONOS_SDK_FILE_SHA1)  $@" | sha1sum -c - || { rm -f "$@"; exit 1; }; fi
	@touch "$@"


.extracted: $(NONOS_SDK_FILE_VER).zip
	@echo Extracting NON-OS SDK...
	rm -rf "$(NONOS_SDK_ZIP_ROOT)" sdk
	unzip "$<" \
	  '*/lib/*' \
	  '*/ld/*.v6.ld' \
	  '*/include/*' \
	  '*/bin/esp_init_data_default_v05.bin'
	mv "$(NONOS_SDK_ZIP_ROOT)" sdk
	@touch "$@"

# TODO: build a properly configured newlibc so we don't need the SDK one at all
.pruned: .extracted
	@echo Pruning unwanted NON-OS SDK code...
	$(AR) d sdk/lib/libmain.a time.o
	$(AR) d sdk/lib/libc.a liba_a-time.o
	@touch $@

build: .pruned
	ar cr lib$(COMPONENT_NAME).a # work around IDF regression

.PHONY: nonos-sdk-clean
nonos-sdk-clean:
	rm -rf .extracted .pruned sdk

clean: nonos-sdk-clean
