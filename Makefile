# Common options
CONFIG ?= Release
RELEASE ?= Sunburst
SANITIZE ?= 0

# OSX build options
OSX_SDK ?= macosx.internal
OSX_ARCHS ?= x86_64 x86_64h arm64e

# IOS build options
IOS_SDK ?= iphoneos.internal
IOS_ARCHS ?= arm64 arm64e

# WatchOS build options
WOS_SDK ?= watchos.internal
WOS_ARCHS ?= armv7k arm64_32

# Buildit record name
BUILDIT_RECORD_NAME ?= zlib

ifeq ($(SANITIZE),0)
  SANITIZER_OPT :=
else
  SANITIZER_OPT := -enableAddressSanitizer YES
endif

LOG_EXT := > ./build/log.txt 2>&1 || ( cat ./build/log.txt && exit 1 )
ARCH_DATE := $(shell date +"%Y%m%d")
ARCH_FILE := $(HOME)/BNNS-$(ARCH_DATE).tgz

define PRINT_OPT
   @echo "\033[1;34m$(1)\033[0m = $(2)"
endef

all: osx

tests: clean osx
	xcodebuild -sdk $(OSX_SDK) -configuration $(CONFIG) -target t_zlib_verify ARCHS="$(OSX_ARCHS)" $(SANITIZER_OPT) $(LOG_EXT)
	./build/Release/t_zlib_verify -t -e 0 -d 10 /Volumes/Data/Sets/CanterburyCorpus/*
	./build/Release/t_zlib_verify -t -e 0 -d 10 -f /Volumes/Data/Sets/CanterburyCorpus/*

osx:
	@[ -d ./build ] || mkdir -p ./build
	xcodebuild -sdk $(OSX_SDK) -configuration $(CONFIG) -target all ARCHS="$(OSX_ARCHS)" $(SANITIZER_OPT) $(LOG_EXT)
ios:
	@[ -d ./build ] || mkdir -p ./build
	xcodebuild -sdk $(IOS_SDK) -configuration $(CONFIG) -target all ARCHS="$(IOS_ARCHS)" $(SANITIZER_OPT) $(LOG_EXT)
wos:
	@[ -d ./build ] || mkdir -p ./build
	xcodebuild -sdk $(WOS_SDK) -configuration $(CONFIG) -target all ARCHS="$(WOS_ARCHS)" $(SANITIZER_OPT) $(LOG_EXT)

buildit-archive: clean
	xbs buildit . -noverify -project zlib -update Prevailing$(RELEASE) -buildAllAliases -buildRecordName zlib -archive
	@cd /tmp/$(BUILDIT_RECORD_NAME).roots/BuildRecords && find . -type f -ls | egrep '\/(SDKContent)?Root\/'

clean:
	/bin/rm -rf ./build /tmp/zlib.dst
