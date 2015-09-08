#
# Main makefile of the Dreamcast emulator project
#
# @author Roberto Cano <roberto dot cano at google mail>
#
CC=gcc
CXX=g++
MACHINE=$(shell uname)

# Directories
OBJDIR := obj
TOOLSDIR := tools
SRCDIR := src

# SH4 opcode generation tool
SH4OPGEN_SRC := sh4opgen.c
SH4OPGEN_OBJ := $(patsubst %.c, obj/%.o, $(SH4OPGEN_SRC))

# SH4 disassembler tool
SH4DISASM_SRC := sh4disassembler.c sh4opcodedisLUT.c sh4opcodedis.c
SH4DISASM_OBJ := $(patsubst %.c, obj/%.o, $(SH4DISASM_SRC))

# SH4 interpreter tool
SH4INTERP_SRC := sh4interpreter.c sh4opcodeemuLUT.c sh4opcodedisLUT.c sh4opcodeemu.c sh4opcodedis.c
SH4INTERP_OBJ := $(patsubst %.c, obj/%.o, $(SH4INTERP_SRC))

# SH4 ELF loader
SH4ELFLOADER_SRC := sh4elfloader.c
SH4ELFLOADER_OBJ := $(patsubst %.c, obj/%.o, $(SH4ELFLOADER_SRC))

all: createdirs $(TOOLSDIR)/sh4disassembler $(TOOLSDIR)/sh4interpreter $(TOOLSDIR)/sh4elfloader

sh4opgen: $(TOOLSDIR)/sh4opgen

createdirs:
	mkdir -p $(OBJDIR)
	mkdir -p $(TOOLSDIR)

$(TOOLSDIR)/sh4opgen: $(SH4OPGEN_OBJ)
$(TOOLSDIR)/sh4disassembler: $(SH4DISASM_OBJ)
$(TOOLSDIR)/sh4interpreter: $(SH4INTERP_OBJ)
ifeq ($(MACHINE),Linux)
$(TOOLSDIR)/sh4elfloader: CFLAGS += -Ilib/linux/
$(TOOLSDIR)/sh4elfloader: LDFLAGS += lib/linux/libbfd.a lib/linux/libiberty.a -lz
else
$(TOOLSDIR)/sh4elfloader: CFLAGS += -Ilib/osx/
$(TOOLSDIR)/sh4elfloader: LDFLAGS += -Llib/osx/ -lbfd lib/osx/libiberty.a
endif

$(TOOLSDIR)/sh4elfloader: $(SH4ELFLOADER_OBJ)
	$(CXX) -o $@ $^ $(LDFLAGS)

clean:
	rm -rf $(OBJDIR)
	rm -rf $(TOOLSDIR)

obj/%.o: src/%.c
	$(CC) $(CFLAGS) -o $@ -c $<

obj/%.o: src/%.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $<

.PHONY: createdirs sh4opgen
