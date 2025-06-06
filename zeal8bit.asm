    INCLUDE "zos_sys.asm"
    INCLUDE "zos_keyboard.asm"

    PUBLIC getchar
    PUBLIC putchar
    PUBLIC zealinit

    MACRO KB_MODE MODE
        ; raw mode
        ld h, DEV_STDIN
        ld c, KB_CMD_SET_MODE
        ld de, MODE
        IOCTL()
    ENDM

;; copied from target/zeal8bit/keyboard/ps2_scan_qwerty.asm
upper_scan:
        ; 0x27 == ESCAPE, represented with ^
        ; 20 , 21 , 22 , 23 , 24 , 25 , 26 , 27  , 28 , 29 , 2A , 2B , 2C , 2D , 2E , 2F
    DEFB  ' ', '!', '"', '#', '$', '%', '&', '^', '(', ')', '*', '+', '`', '-', '.', '/' ; 20
    DEFB  ')', '!', '@', '@', '$', '%', '^', '&', '*', '(', ':', ':', '<', '+', '>', '?' ; 30
    DEFB  '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O' ; 40
    DEFB  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '{', '|', '}', '^', '_' ; 50
    DEFB  '~', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'I', 'K', 'L', 'M', 'N', 'O' ; 60
    DEFB  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '{', '|', '}', '~', '^' ; 70


zealinit:
    KB_MODE(KB_READ_NON_BLOCK | KB_MODE_RAW)
    ret

; Read from the current input stream (keyboard).
;   Outputs: A = character
;   Destroys: A,F
getchar:
    push bc
    push de
    push hl

    ; loop until a key is pressed
@waitforkey:
    S_READ3(DEV_STDIN, BUFFER, 3)
    or a
    jr nz, @error
    ; A is zero for sure, OR it with C to check if C is 0
    or c
    jr z, @waitforkey ; if no key
    ld a, (de) ; get the code from BUFFER[0]

    cp KB_RELEASED
    jr z, @waitforkey ; ignore key releases

    cp KB_CAPS_LOCK
    jr z, @shifted
    cp KB_LEFT_SHIFT
    jr z, @shifted
    cp KB_RIGHT_SHIFT
    jr z, @shifted

    push af
    ld hl, SHIFTED
    ld a, (hl)
    or a
    jp z, @continue
@shiftit:
    pop af
    cp 0x20
    jp m, @continue ; A is < 20
    sub 0x20
    ld b, 0
    ld c, a
    ld hl, upper_scan
    add hl, bc
    ld a, (hl)
    ld (BUFFER), a
    push af

@continue:
    pop af
    jp @read
@shifted:
    ld a, (SHIFTED)
    xor 1
    ld hl, SHIFTED
    ld (hl), a
    jr @waitforkey
@error:
    ; an error has occurred, handle it
    xor a   ; ????
@read:
    ld a, (BUFFER) ; get the code from BUFFER[0]
    pop hl
    pop de
    pop bc
    ret
;

;OSWRCH - Write a character to console output.
;   Inputs: A = character.
; Destroys: Nothing
;
putchar:
    ld (BUFFER), a
    push af
    push bc
    push de
    push hl
    S_WRITE3(DEV_STDOUT, BUFFER, 1)
    pop hl
    pop de
    pop bc
    pop af
    ret
;

;
BUFFER: DEFS ZOS_STAT_SIZE
SHIFTED: DB 0