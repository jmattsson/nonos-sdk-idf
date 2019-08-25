COMPONENT_DEPENDS:=nonos-sdk
COMPONENT_OWNBUILDTARGET:=build

build:
	cp ../nonos-sdk/sdk/lib/lib$(COMPONENT_NAME)_536.a lib$(COMPONENT_NAME).a
