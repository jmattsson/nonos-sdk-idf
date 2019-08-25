COMPONENT_DEPENDS:=nonos-sdk
COMPONENT_OWNBUILDTARGET:=build

build:
	cp ../nonos-sdk/sdk/lib/libc.a lib$(COMPONENT_NAME).a
