#
# General Compiler Settings
#


ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>/devkitpro")
endif

TOPDIR ?= $(CURDIR)
 
export BUILD_EXEFS_SRC := build/exefs
 
include $(DEVKITPRO)/libnx/switch_rules

APP_TITLE 	:= forsaken-nx
APP_AUTHOR 	:= MVG
APP_VERSION := 1.0.0
ICON 		:= Icon.jpg
BUILD		:=	build
DATA		:=	data
INCLUDES	:=	include
EXEFS_SRC	:=	exefs_src
ROMFS		:=	RomFS


BINDIR	  = release
OUTPUT    = forsaken-nx

# for cross compiling be sure to specify your compiler ex:
# make CC=i686-mingw32-gcc
# compiler, linker and utilities
AR = aarch64-none-elf-gcc-ar
CC = aarch64-none-elf-gcc
CXX = aarch64-none-elf-g++
LD = aarch64-none-elf-g++
ASM = @nasm
ASMFLAGS = -f coff
MD = -mkdir
RM = @rm -f
 

# general compiler settings
ifeq ($(M32),1)
  FLAGS= -m32
endif
FLAGS+= -std=gnu99 -pipe
CFLAGS=$(FLAGS) -w
LDFLAGS=$(FLAGS)

# right now non debug build would probably crash anyway
# we even release debug builds as the official release
DEBUG=1

# might as well leave gprof support on by default as well
PROFILE=1

# use this if you want to build everything statically
STATIC=1

# Mudflap is a pointer use checking library. For more info:
# http://gcc.gnu.org/wiki/Mudflap_Pointer_Debugging
MUDFLAP=0

ifeq ($(MUDFLAP),1)
  ifeq ($(DEBUG),1)
    FLAGS+= -fmudflap
    LIB+= -lmudflap
  else
    X:=$(error Mudflap enabled without debug mode - probably not what you meant)
  endif
endif

# stack-smash protection against buffer overflows and corrupt pointers
# (enabled by default on many systems today)
ifeq ($(SSP),1)
  FLAGS+= -fstack-protector-all
  CFLAGS+= -D_FORTIFY_SOURCE=2
endif

ifeq ($(DEBUG),1)
  FLAGS+= -g
else
  CFLAGS+=-O3 -Winit-self
  LDFLAGS+=-s
endif
 
# which version of sdl do you want to ask pkgconfig for ?
SDL=2
ifeq ($(SDL),1)
  SDL_=sdl
else
  SDL_=sdl$(SDL)
endif

# which version of GL do you want to use ?
GL=3
 
ifeq ($(BOT),1)
  CFLAGS+= -DLUA_BOT
endif

# ProjectX-specific includes
CFLAGS += -I. -Ilua/include -I$(DEVKITPRO)/portlibs/switch/include -I$(DEVKITPRO)/portlibs/switch/include/SDL2 -I$(DEVKITPRO)/portlibs/switch/include/libpng16

# ProjectX-specific macros
ifeq ($(DXMOUSE),1)
  CFLAGS += -DDXMOUSE -Idinput
  LIB += -Ldinput -ldinput -ldxguid
endif
ifeq ($(RENDER_DISABLED),1)
  CFLAGS+= -DRENDER_DISABLED
else
  CFLAGS+= -DGL=$(GL)
endif
CFLAGS+= -DBSP -DLUA_USE_APICHECK -DTEXTURE_PNG -DSOUND_SUPPORT -DSOUND_OPENAL -DLUA_COMPAT_5_2
ifeq ($(DEBUG),1)
  CFLAGS+= -DDEBUG_ON -DDEBUG_COMP -DDEBUG_SPOTFX_SOUND -DDEBUG_VIEWPORT
endif

INC=$(wildcard *.h)
SRC=$(wildcard *.c)
OBJ=$(patsubst %.c,%.o,$(SRC))
 

# LUA Objects
OBJ+=lauxlib.o lapi.o lbaselib.o lbitlib.o lcode.o lcorolib.o lctype.o ldblib.o ldebug.o ldo.o ldump.o lfunc.o lgc.o linit.o liolib.o llex.o
OBJ+=lmathlib.o lmem.o loadlib.o lobject.o lopcodes.o loslib.o lparser.o lstate.o lstring.o lstrlib.o ltable.o ltablib.o ltm.o lundump.o
OBJ+=lutf8lib.o lvm.o lzio.o
LIB= -lopenal-soft -lpng `sdl2-config --libs` -lglad -lEGL  -lglapi -ldrm_nouveau -lz -lnx -lm -lc
 
# allows user to override settings
ADD_FLAGS=
ADD_CFLAGS= -march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIE -D__SWITCH__
ADD_LDFLAGS= -s -specs=$(DEVKITPRO)/libnx/switch.specs -g -march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIE -L$(DEVKITPRO)/libnx/lib -L$(DEVKITPRO)/portlibs/switch/lib
FLAGS+=$(ADD_FLAGS)
CFLAGS+=$(ADD_CFLAGS)
LDFLAGS+=$(ADD_LDFLAGS)

BIN=release/forsaken-nx.elf

all: $(BIN)
 
	
$(BIN): $(OBJ)
	$(CXX) -o $(BIN) $(OBJ) $(LDFLAGS) $(LIB)
 
lapi.o: lua/source/lapi.c
	$(CC) -c lua/source/lapi.c -o lapi.o $(CFLAGS)		

lauxlib.o: lua/source/lauxlib.c
	$(CC) -c lua/source/lauxlib.c -o lauxlib.o $(CFLAGS)		

lbaselib.o: lua/source/lbaselib.c
	$(CC) -c lua/source/lbaselib.c -o lbaselib.o $(CFLAGS)	

lbitlib.o: lua/source/lbitlib.c
	$(CC) -c lua/source/lbitlib.c -o lbitlib.o $(CFLAGS)	

lcode.o: lua/source/lcode.c
	$(CC) -c lua/source/lcode.c -o lcode.o $(CFLAGS)

lcorolib.o: lua/source/lcorolib.c
	$(CC) -c lua/source/lcorolib.c -o lcorolib.o $(CFLAGS)		
	
lctype.o: lua/source/lctype.c
	$(CC) -c lua/source/lctype.c -o lctype.o $(CFLAGS)	

ldblib.o: lua/source/ldblib.c
	$(CC) -c lua/source/ldblib.c -o ldblib.o $(CFLAGS)		
	
ldebug.o: lua/source/ldebug.c
	$(CC) -c lua/source/ldebug.c -o ldebug.o $(CFLAGS)	

ldo.o: lua/source/ldo.c
	$(CC) -c lua/source/ldo.c -o ldo.o $(CFLAGS)

ldump.o: lua/source/ldump.c
	$(CC) -c lua/source/ldump.c -o ldump.o $(CFLAGS)

lfunc.o: lua/source/lfunc.c
	$(CC) -c lua/source/lfunc.c -o lfunc.o $(CFLAGS)	

lgc.o: lua/source/lgc.c
	$(CC) -c lua/source/lgc.c -o lgc.o $(CFLAGS)

linit.o: lua/source/linit.c
	$(CC) -c lua/source/linit.c -o linit.o $(CFLAGS)		

liolib.o: lua/source/liolib.c
	$(CC) -c lua/source/liolib.c -o liolib.o $(CFLAGS)		

llex.o: lua/source/llex.c
	$(CC) -c lua/source/llex.c -o llex.o $(CFLAGS)		
	
lmathlib.o: lua/source/lmathlib.c
	$(CC) -c lua/source/lmathlib.c -o lmathlib.o $(CFLAGS)	
	
lmem.o: lua/source/lmem.c
	$(CC) -c lua/source/lmem.c -o lmem.o $(CFLAGS)		
	
loadlib.o: lua/source/loadlib.c
	$(CC) -c lua/source/loadlib.c -o loadlib.o $(CFLAGS)

lobject.o: lua/source/lobject.c
	$(CC) -c lua/source/lobject.c -o lobject.o $(CFLAGS)		
	
lopcodes.o: lua/source/lopcodes.c
	$(CC) -c lua/source/lopcodes.c -o lopcodes.o $(CFLAGS)	
	
loslib.o: lua/source/loslib.c
	$(CC) -c lua/source/loslib.c -o loslib.o $(CFLAGS)

lparser.o: lua/source/lparser.c
	$(CC) -c lua/source/lparser.c -o lparser.o $(CFLAGS)

lstate.o: lua/source/lstate.c
	$(CC) -c lua/source/lstate.c -o lstate.o $(CFLAGS)	

lstring.o: lua/source/lstring.c
	$(CC) -c lua/source/lstring.c -o lstring.o $(CFLAGS)

lstrlib.o: lua/source/lstrlib.c
	$(CC) -c lua/source/lstrlib.c -o lstrlib.o $(CFLAGS)

ltable.o: lua/source/ltable.c
	$(CC) -c lua/source/ltable.c -o ltable.o $(CFLAGS)	
	
ltablib.o: lua/source/ltablib.c
	$(CC) -c lua/source/ltablib.c -o ltablib.o $(CFLAGS)

ltm.o: lua/source/ltm.c
	$(CC) -c lua/source/ltm.c -o ltm.o $(CFLAGS)

lundump.o: lua/source/lundump.c
	$(CC) -c lua/source/lundump.c -o lundump.o $(CFLAGS)	
	
lutf8lib.o: lua/source/lutf8lib.c
	$(CC) -c lua/source/lutf8lib.c -o lutf8lib.o $(CFLAGS)		
	
lvm.o: lua/source/lvm.c
	$(CC) -c lua/source/lvm.c -o lvm.o $(CFLAGS)		
	
lzio.o: lua/source/lzio.c
	$(CC) -c lua/source/lzio.c -o lzio.o $(CFLAGS)		
 
$(OBJ): $(INC)

clean:
	$(RM) $(OBJ) $(BIN)

check:
	@echo
	@echo "INC = $(INC)"
	@echo
	@echo "SRC = $(SRC)"
	@echo
	@echo "OBJ = $(OBJ)"
	@echo
	@echo "DEBUG = $(DEBUG)"
	@echo "PROFILE = $(PROFILE)"
	@echo "MUDFLAP = $(MUDFLAP)"
	@echo "STATIC = $(STATIC)"
	@echo "PKG_CFG_OPTS = $(PKG_CFG_OPTS)"
	@echo "MINGW = $(MINGW)"
	@echo "CROSS = $(CROSS)"
	@echo "BOT = $(BOT)"
	@echo "GL = $(GL)"
	@echo "RENDER_DISABLED = $(RENDER_DISABLED)"
	@echo "LUA = $(LUA)"
	@echo "SDL = $(SDL)"
	@echo "SDL_ = $(SDL_)"
	@echo
	@echo "CC = $(CC)"
	@echo "BIN = $(BIN)"
	@echo "CFLAGS = $(CFLAGS)"
	@echo "LDFLAGS = $(LDFLAGS)"
	@echo "LIB = $(LIB)"
	@echo

.PHONY: all clean


#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
all	:	$(BINDIR)/$(OUTPUT).pfs0 $(BINDIR)/$(OUTPUT).nro

$(BINDIR)/$(OUTPUT).pfs0	:	$(BINDIR)/$(OUTPUT).nso

$(BINDIR)/$(OUTPUT).nso	:	$(BINDIR)/$(OUTPUT).elf

ifeq ($(strip $(NO_NACP)),)
$(BINDIR)/$(OUTPUT).nro	:	$(BINDIR)/$(OUTPUT).elf $(BINDIR)/$(OUTPUT).nacp
else
$(BINDIR)/$(OUTPUT).nro	:	$(BINDIR)/$(OUTPUT).elf
endif

$(BINDIR)/$(OUTPUT).elf	:	$(OFILES)

$(OFILES_SRC)	: $(HFILES_BIN)
	
# end of Makefile ...	