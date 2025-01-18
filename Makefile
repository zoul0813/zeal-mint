BIN=../mint.bin
SRCS = MAIN.asm zeal8bit.asm
BUILDDIR=build

all: build ${BIN}

build:
	mkdir ${BUILDDIR}

${BIN}:
	z88dk-z80asm -DZEAL8BIT=1 -I$(ZOS_PATH)/kernel_headers/z88dk-z80asm/ -O=${BUILDDIR} -o=${BIN} -b -d -l -m $(SRCS)

clean:
	rm -fr ${BUILDDIR}/*
