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

run:
	$(ZEAL_NATIVE_BIN) -r $(ZEAL_NATIVE_ROM) # -t tf.img -e eeprom.img

native: all run

