# Support for getting a relative path from two absolute paths.
# On Linux it's as simple as 'realpath --relative-to=path1 path2', but since
# we have to cater for Windows builds too, here's a pure make version
# courtesy Stackoverflow:
#   https://stackoverflow.com/questions/3341482/in-a-makefile-how-to-get-the-relative-path-from-one-absolute-path-to-another

relpath_space_builder_helper:=

override define \s :=
$(relpath_space_builder_helper) $(relpath_space_builder_helper)
endef

ifndef $(\s)
  override $(\s) :=
else
  $(error Defined special variable '$(\s)': reserved for internal use)
endif

override define dirname
$(patsubst %/,%,$(dir $(patsubst %/,%,$1)))
endef

override define prefix_1
$(if $(or $\
  $(patsubst $(abspath $3)%,,$(abspath $1)),$\
  $(patsubst $(abspath $3)%,,$(abspath $2))),$\
  $(strip $(call prefix_1,$1,$2,$(call dirname,$3))),$\
  $(strip $(abspath $3)))
endef

override define prefix
$(call prefix_1,$1,$2,$1)
endef

override define relpath_1
$(patsubst /%,%,$(subst $(\s),/,$(patsubst %,..,$(subst /,$(\s),$\
  $(patsubst $3%,%,$(abspath $2)))))$\
  $(patsubst $3%,%,$(abspath $1)))
endef

override define relpath
$(call relpath_1,$1,$2,$(call prefix,$1,$2))
endef
