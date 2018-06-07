INCLUDE "constants.asm"
INCLUDE "palettes.asm"

; rst vectors
SECTION "rst 00", ROM0 [$00]
  jp .Init
  
SECTION "rst 08", ROM0 [$08]
	jp .Init
  
SECTION "rst 10", ROM0 [$10]
	rst $38
  
SECTION "rst 18", ROM0 [$18]
	rst $38
  
SECTION "rst 20", ROM0 [$20]
	rst $38
  
SECTION "rst 28", ROM0 [$28]
	add a, a
	pop hl
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl

; Continue  
SECTION "rst 30", ROM0 [$30]
	ld d, [hl]
	push de
	pop hl
	jp [hl]
  
SECTION "rst 38", ROM0 [$38]
	rst $38

; Hardware interrupts
SECTION "vblank", ROM0 [$40]
	jp VBlank
SECTION "hblank", ROM0 [$48]
	jp .HBlank_Timer
SECTION "timer",  ROM0 [$50]
	jp .HBlank_Timer
SECTION "serial", ROM0 [$58]
	jp Serial

Serial::
	push af
	push hl
	push de
	push bc
	call func_006b
	ld a, $01
	ldh [$ff00 + $cc], a
	pop bc
	pop de
	pop hl
	pop af
	reti

func_006b::
	ldh a, [$ff00 + $cd]
	rst 28
	
	db 78, 00, 9f, 00, a4, 00, ba, 00, ea, 27
	
.l_0078:
	ldh a, [$ff00 + $e1]
	cp $07
	jr z, .l_0086
	cp $06
	ret z
	ld a, $06
	ldh [$ff00 + $e1], a
	ret

.l_0086:
	ldh a, [$ff00 + $01]
	cp $55
	jr nz, .l_0094
	ld a, $29
	ldh [$ff00 + $cb], a
	ld a, $01
	jr .l_009c

.l_0094:
	cp $29
	ret nz
	ld a, $55
	ldh [$ff00 + $cb], a
	xor a

.l_009c:
	ldh [$ff00 + $02], a
	ret
	ldh a, [$ff00 + $01]
	ldh [$ff00 + $d0], a
	ret
	ldh a, [$ff00 + $01]
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $cb]
	cp $29
	ret z
	ldh a, [$ff00 + $cf]
	ldh [$ff00 + $01], a
	ld a, $ff
	ldh [$ff00 + $cf], a
	ld a, $80
	ldh [$ff00 + $02], a
	ret
	ldh a, [$ff00 + $01]
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $cb]
	cp $29
	ret z
	ldh a, [$ff00 + $cf]
	ldh [$ff00 + $01], a
	ei
	call func_0a98
	ld a, $80
	ldh [$ff00 + $02], a
	ret
	ldh a, [$ff00 + $cd]
	cp $02
	ret nz
	xor a
	ldh [$ff00 + $0f], a
	ei
	ret
	
SECTION "Entry", ROM0 [$100]
  nop
	jp .Start
  
SECTION "Header", ROM0 [$104]
	db ce, ed, 66, 66, cc, 0d, 00, 0b, 03, 73, 00, 83, 00, 0c, 00, 0d, 
	db 00, 08, 11, 1f, 88, 89, 00, 0e, dc, cc, 6e, e6, dd, dd, d9, 99, 
	db bb, bb, 67, 63, 6e, 0e, ec, cc, dd, dc, 99, 9f, bb, b9, 33, 3e, 
	db "TETRIS"
	db $00		;dmg - classic gameboy
	db $00, $$00		;new license
	db $00		;sgb flag: not sgb compatible
	db $00		;cart type: rom
	db $00		;rom size: 32 kb
	db $00		;ram size: 0 b
	db $00		;destination code: japanese
	db $01		;old license: not sgb compatible
	db $01		;mask rom version number
	db $0a		;header check [ok]
	db $16, $bf		;global check [ok]

SECTION "Main", ROM0
.Start:
	jp .Init
	call func_29e3

.l_0156:
	ldh a, [$ff00 + $41]
	and $03
	jr nz, .l_0156
	ld b, [hl]

.l_015d:
	ldh a, [$ff00 + $41]
	and $03
	jr nz, .l_015d
	ld a, [hl]
	and b
	ret
	ld a, e
	add a, [hl]
	daa
	ldi [hl], a
	ld a, d
	adc a, [hl]
	daa
	ldi [hl], a
	ld a, $00
	adc a, [hl]
	daa
	ld [hl], a
	ld a, $01
	ldh [$ff00 + $e0], a
	ret nc
	ld a, $99
	ldd [hl], a
	ldd [hl], a
	ld [hl], a
	ret

.l_017e:
	push af
	push bc
	push de
	push hl
	ldh a, [$ff00 + $ce]
	and a
	jr z, .l_0199
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, .l_0199
	xor a
	ldh [$ff00 + $ce], a
	ldh a, [$ff00 + $cf]
	ldh [$ff00 + $01], a
	ld hl, $ff02
	ld [hl], $81

.l_0199:
	call func_21e0
	call func_23cc
	call func_23b7
	call func_239e
	call func_238c
	call func_237d
	call func_236e
	call func_235f
	call func_2350
	call func_2341
	call func_2332
	call func_2323
	call func_22f8
	call func_22e9
	call func_22da
	call func_22cb
	call func_22bc
	call func_22ad
	call func_229e
	call func_1ed7
	call func_ffb6
	call func_18ca
	ld a, [$c0ce]
	and a
	jr z, .l_01fb
	ldh a, [$ff00 + $98]
	cp $03
	jr nz, .l_01fb
	ld hl, $986d
	call func_243b
	ld a, $01
	ldh [$ff00 + $e0], a
	ld hl, $9c6d
	call func_243b
	xor a
	ld [$c0ce], a

.l_01fb:
	ld hl, $ffe2
	inc [hl]
	xor a
	ldh [$ff00 + $43], a
	ldh [$ff00 + $42], a
	inc a
	ldh [$ff00 + $85], a
	pop hl
	pop de
	pop bc
	pop af
	reti

.Init:
; Flush WRAM Bank 1
	xor a
	ld hl, $dfff	; End of WRAM Bank 1
	ld c, $10	; $1000 = size of WRAM Bank 1
	ld b, $00	; "
.loop_0:
	ldd [hl], a
	dec b
	jr nz, .loop_0
	dec c
	jr nz, .loop_0
	
.Screen_Setup:

rINTERRUPT_DEFAULT EQU %00000001
; * VBlank interrupt enabled
; * everything else disabled

rLCDC_START EQU %10000000
; * LCD enabled
; * everything else disabled

	ld a, rINTERRUPT_DEFAULT
	
	di
	
	ldh [rIF], a
	ldh [rIE], a
	
	xor a
	
	ldh [rSCY], a
	ldh [rSCX], a
	ldh [rUNKNOWN], a
	ldh [rLCDC_STAT], a
	ldh [rSB], a
	ldh [rSC], a
	ld a, rLCDC_START
	ldh [rLCDC], a

.loop_1:
	ldh a, [rLY]
	cp rSCREEN_HEIGHT + 4
	jr nz, .loop_1
	
	ld a, $03
	ldh [rLCDC], a
	
	ld a, rPALETTE_1
	ldh [rBGP], a
	ldh [rOBP0], a
	
	ld a, rPALETTE_2
	ldh [rOBP1], a
	ld hl, rNR52
	
	ld a, rSOUND_ON
	ldd [hl], a	; rNR51
	
	ld a, rUSE_ALL_CHANNELS
	ldd [hl], a	; rNR50
	ld [hl], rMASTER_VOLUME_MAX
	
	ld a, $01
	ld [rMBC], a
	ld sp, rSP_INIT

; Flush WRAM Bank 1 (last page only)
	xor a
	ld hl, $dfff	; End of WRAM Bank 1
	ld b, $00
.loop_2:
	ldd [hl], a
	dec b		
	jr nz, .loop_2	; Flush 256 bytes from end of WRAM Bank 1
	
; Flush WRAM Bank 0
	ld hl, $cfff	; End of WRAM Bank 0
	ld c, $10	; $1000 = size of WRAM Bank 0
	ld b, $00	; "
.loop_3:
	ldd [hl], a
	dec b
	jr nz, .loop_3
	dec c
	jr nz, .loop_3


Flush_VRAM::
	ld hl, $9fff	; End of Video RAM
	ld c, $20	; $2000 = Size of Video RAM
	xor a
	ld b, $00
.loop_4:
	ldd [hl], a
	dec b
	jr nz, .loop_4
	dec c
	jr nz, .loop_4
	
; Flush Object Attribute Memory (OAM)	
	ld hl, $feff	; End of unusable hardware RAM
	ld b, $00
.loop_5:
	ldd [hl], a
	dec b
	jr nz, .loop_5	; Flush 256 bytes from end of hardware RAM, including OAM

; Flush High RAM
	ld hl, $fffe	; End of High RAM
	ld b, $80
.loop_6:
	ldd [hl], a
	dec b
	jr nz, .loop_6	; Flush 128 bytes (Entire HRAM)
	
; Copy DMA Transfer routine into HRAM ($2a7f -> $ffb6)
	ld c, $b6
	ld b, $0c
	ld hl, $2a7f
.loop_7:
	ldi a, [hl]
	ldh [c], a
	inc c
	dec b
	jr nz, .loop_7
	
	call func_2795
	call func_7ff3
	ld a, $09
	ldh [$ff00 + $ff], a
	ld a, $37
	ldh [$ff00 + $c0], a
	ld a, $1c
	ldh [$ff00 + $c1], a
	ld a, $24
	ldh [$ff00 + $e1], a
	ld a, $80
	ldh [$ff00 + $40], a
	ei
	xor a
	ldh [$ff00 + $0f], a
	ldh [$ff00 + $4a], a
	ldh [$ff00 + $4b], a
	ldh [$ff00 + $06], a

.l_02c4:
	call func_29a6
	call func_02f8
	call func_7ff0
	ldh a, [$ff00 + $80]
	and $0f
	cp $0f
	jp z, .Screen_Setup
	ld hl, $ffa6
	ld b, $02

.l_02db:
	ld a, [hl]
	and a
	jr z, .l_02e0
	dec [hl]

.l_02e0:
	inc l
	dec b
	jr nz, .l_02db
	ldh a, [$ff00 + $c5]
	and a
	jr z, .l_02ed
	ld a, $09
	ldh [$ff00 + $ff], a

.l_02ed:
	ldh a, [$ff00 + $85]
	and a
	jr z, .l_02ed
	xor a
	ldh [$ff00 + $85], a
	jp .l_02c4


func_02f8::
	ldh a, [$ff00 + $e1]
	rst 28
	adc a, $1b
	ldh [c], a
	inc e
	ld b, h
	ld [de], a
	ld a, e
	ld [de], a

.l_0303:
	ld b, $1d
	ld h, $1d
	xor [hl]
	inc bc
	ld a, c
	inc b
	ld b, h
	inc d
	adc a, h
	inc d
	rlc a
	ld a, [de]
	ret nz
	dec e
	ld d, $1f
	rr a
	rr a
	dec h
	dec d
	or b
	inc d
	ld a, e
	dec d
	cp a
	dec d
	add hl, hl
	ld d, $7a
	ld d, $eb
	ld d, $13
	add hl, de
	ld [hl], a
	ld b, $2c
	rlc a
	dec h
	ld [$08e4], sp
	ld sp, $eb0b
	inc c
	jp nc, .l_320a
	dec c
	inc hl
	ld c, $12
	ld de, $0d99
	adc a, d
	ld c, $ce
	dec e
	ld b, c
	ld e, $69
	inc bc
	sub a, e
	inc bc
	ld h, a
	ld de, $11e6
	<error>
	ld de, $121c
	rst 0
	dec b
	rst 30
	dec b
	or e
	ld [de], a
	dec b
	inc de
	inc h
	inc de
	ld d, c
	inc de
	ld h, a
	inc de
	ld a, [hl]
	inc de
	or l
	inc de
	push hl
	inc de
	dec de
	inc de
	and b
	inc bc
	ld [$cd27], a
	jr nz, .l_0394
	call func_27d7
	ld de, $4a07
	call func_27eb
	call func_178a
	ld hl, $c300
	ld de, $6450

.l_037e:
	ld a, [de]
	ldi [hl], a
	inc de
	ld a, h
	cp $c4
	jr nz, .l_037e
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $fa
	ldh [$ff00 + $a6], a
	ld a, $25
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld a, $fa
	ldh [$ff00 + $a6], a
	ld a, $35
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $81]
	and a
	jr nz, .l_03a9
	ldh a, [$ff00 + $a6]
	and a
	ret nz

.l_03a9:
	ld a, $06
	ldh [$ff00 + $e1], a
	ret
	call func_2820
	xor a
	ldh [$ff00 + $e9], a
	ldh [$ff00 + $98], a
	ldh [$ff00 + $9c], a
	ldh [$ff00 + $9b], a
	ldh [$ff00 + $fb], a
	ldh [$ff00 + $9f], a
	ldh [$ff00 + $e3], a
	ldh [$ff00 + $c7], a
	call func_2293
	call func_2651
	call func_27d7
	ld hl, $c800

.l_03ce:
	ld a, $2f
	ldi [hl], a
	ld a, h
	cp $cc
	jr nz, .l_03ce
	ld hl, $c801
	call func_26a9
	ld hl, $c80c
	call func_26a9
	ld hl, $ca41
	ld b, $0c
	ld a, $8e

.l_03e9:
	ldi [hl], a
	dec b
	jr nz, .l_03e9
	ld de, $4b6f
	call func_27eb
	call func_178a
	ld hl, $c000
	ld [hl], $80
	inc l
	ld [hl], $10
	inc l
	ld [hl], $58
	ld a, $03
	ld [$dfe8], a
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $07
	ldh [$ff00 + $e1], a
	ld a, $7d
	ldh [$ff00 + $a6], a
	ld a, $04
	ldh [$ff00 + $c6], a
	ldh a, [$ff00 + $e4]
	and a
	ret nz
	ld a, $13
	ldh [$ff00 + $c6], a
	ret

.l_041f:
	ld a, $37
	ldh [$ff00 + $c0], a
	ld a, $09
	ldh [$ff00 + $c2], a
	xor a
	ldh [$ff00 + $c5], a
	ldh [$ff00 + $b0], a
	ldh [$ff00 + $ed], a
	ldh [$ff00 + $ea], a
	ld a, $62
	ldh [$ff00 + $eb], a
	ld a, $b0
	ldh [$ff00 + $ec], a
	ldh a, [$ff00 + $e4]
	cp $02
	ld a, $02
	jr nz, .l_045a
	ld a, $77
	ldh [$ff00 + $c0], a
	ld a, $09
	ldh [$ff00 + $c3], a
	ld a, $02
	ldh [$ff00 + $c4], a
	ld a, $63
	ldh [$ff00 + $eb], a
	ld a, $b0
	ldh [$ff00 + $ec], a
	ld a, $11
	ldh [$ff00 + $b0], a
	ld a, $01

.l_045a:
	ldh [$ff00 + $e4], a
	ld a, $0a
	ldh [$ff00 + $e1], a
	call func_2820
	call func_27ad
	ld de, $4cd7
	call func_27eb
	call func_178a
	ld a, $d3
	ldh [$ff00 + $40], a
	ret
	ld a, $ff
	ldh [$ff00 + $e9], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_0488
	ld hl, $ffc6
	dec [hl]
	jr z, .l_041f
	ld a, $7d
	ldh [$ff00 + $a6], a

.l_0488:
	call func_0a98
	ld a, $55
	ldh [$ff00 + $01], a
	ld a, $80
	ldh [$ff00 + $02], a
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_04a2
	ldh a, [$ff00 + $cb]
	and a
	jr nz, .l_04d7
	xor a
	ldh [$ff00 + $cc], a
	jr .l_0509

.l_04a2:
	ldh a, [$ff00 + $81]
	ld b, a
	ldh a, [$ff00 + $c5]
	bit 2, b
	jr nz, .l_04f3
	bit 4, b
	jr nz, .l_0502
	bit 5, b
	jr nz, .l_0507
	bit 3, b
	ret z
	and a
	ld a, $08
	jr z, .l_04e7
	ld a, b
	cp $08
	ret nz
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_04d7
	ld a, $29
	ldh [$ff00 + $01], a
	ld a, $81
	ldh [$ff00 + $02], a

.l_04cd:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_04cd
	ldh a, [$ff00 + $cb]
	and a
	jr z, .l_0509

.l_04d7:
	ld a, $2a

.l_04d9:
	ldh [$ff00 + $e1], a
	xor a
	ldh [$ff00 + $a6], a
	ldh [$ff00 + $c2], a
	ldh [$ff00 + $c3], a
	ldh [$ff00 + $c4], a
	ldh [$ff00 + $e4], a
	ret

.l_04e7:
	push af
	ldh a, [$ff00 + $80]
	bit 7, a
	jr z, .l_04f0
	ldh [$ff00 + $f4], a

.l_04f0:
	pop af
	jr .l_04d9

.l_04f3:
	xor $01

.l_04f5:
	ldh [$ff00 + $c5], a
	and a
	ld a, $10
	jr z, .l_04fe
	ld a, $60

.l_04fe:
	ld [$c001], a
	ret

.l_0502:
	and a
	ret nz
	xor a
	jr .l_04f3

.l_0507:
	and a
	ret z

.l_0509:
	xor a
	jr .l_04f5


func_050c::
	ldh a, [$ff00 + $e4]
	and a
	ret z
	call func_0a98
	xor a
	ldh [$ff00 + $01], a
	ld a, $80
	ldh [$ff00 + $02], a
	ldh a, [$ff00 + $81]
	bit 3, a
	jr z, .l_052d
	ld a, $33
	ldh [$ff00 + $01], a
	ld a, $81
	ldh [$ff00 + $02], a
	ld a, $06
	ldh [$ff00 + $e1], a
	ret

.l_052d:
	ld hl, $ffb0
	ldh a, [$ff00 + $e4]
	cp $02
	ld b, $10
	jr z, .l_053a
	ld b, $1d

.l_053a:
	ld a, [hl]
	cp b
	ret nz
	ld a, $06
	ldh [$ff00 + $e1], a
	ret


func_0542::
	ldh a, [$ff00 + $e4]
	and a
	ret z
	ldh a, [$ff00 + $e9]
	cp $ff
	ret z
	ldh a, [$ff00 + $ea]
	and a
	jr z, .l_0555
	dec a
	ldh [$ff00 + $ea], a
	jr .l_0571

.l_0555:
	ldh a, [$ff00 + $eb]
	ld h, a
	ldh a, [$ff00 + $ec]
	ld l, a
	ldi a, [hl]
	ld b, a
	ldh a, [$ff00 + $ed]
	xor b
	and b
	ldh [$ff00 + $81], a
	ld a, b
	ldh [$ff00 + $ed], a
	ldi a, [hl]
	ldh [$ff00 + $ea], a
	ld a, h
	ldh [$ff00 + $eb], a
	ld a, l
	ldh [$ff00 + $ec], a
	jr .l_0574

.l_0571:
	xor a
	ldh [$ff00 + $81], a

.l_0574:
	ldh a, [$ff00 + $80]
	ldh [$ff00 + $ee], a
	ldh a, [$ff00 + $ed]
	ldh [$ff00 + $80], a
	ret
	xor a
	ldh [$ff00 + $ed], a
	jr .l_0571
	ret


func_0583::
	ldh a, [$ff00 + $e4]
	and a
	ret z
	ldh a, [$ff00 + $e9]
	cp $ff
	ret nz
	ldh a, [$ff00 + $80]
	ld b, a
	ldh a, [$ff00 + $ed]
	cp b
	jr z, .l_05ad
	ldh a, [$ff00 + $eb]
	ld h, a
	ldh a, [$ff00 + $ec]
	ld l, a
	ldh a, [$ff00 + $ed]
	ldi [hl], a
	ldh a, [$ff00 + $ea]
	ldi [hl], a
	ld a, h
	ldh [$ff00 + $eb], a
	ld a, l
	ldh [$ff00 + $ec], a
	ld a, b
	ldh [$ff00 + $ed], a
	xor a
	ldh [$ff00 + $ea], a
	ret

.l_05ad:
	ldh a, [$ff00 + $ea]
	inc a
	ldh [$ff00 + $ea], a
	ret


func_05b3::
	ldh a, [$ff00 + $e4]
	and a
	ret z
	ldh a, [$ff00 + $e9]
	and a
	ret nz
	ldh a, [$ff00 + $ee]
	ldh [$ff00 + $80], a
	ret

.l_05c0:
	ld hl, $ff02
	set 7, [hl]
	jr .l_05d1
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, .l_05c0

.l_05d1:
	call func_144f
	ld a, $80
	ld [$c210], a
	call func_2671
	ldh [$ff00 + $ce], a
	xor a
	ldh [$ff00 + $01], a
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $dc], a
	ldh [$ff00 + $d2], a
	ldh [$ff00 + $d3], a
	ldh [$ff00 + $d4], a
	ldh [$ff00 + $d5], a
	ldh [$ff00 + $e3], a
	call func_7ff3
	ld a, $2b
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0613
	ldh a, [$ff00 + $f0]
	and a
	jr z, .l_0620
	xor a
	ldh [$ff00 + $f0], a
	ld de, $c201
	call func_1492
	call func_1517
	call func_2671
	jr .l_0620

.l_0613:
	ldh a, [$ff00 + $81]
	bit 0, a
	jr nz, .l_0620
	bit 3, a
	jr nz, .l_0620
	call func_14b0

.l_0620:
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0644
	ldh a, [$ff00 + $cc]
	and a
	ret z
	xor a
	ldh [$ff00 + $cc], a
	ld a, $39
	ldh [$ff00 + $cf], a
	ldh a, [$ff00 + $d0]
	cp $50
	jr z, .l_0664
	ld b, a
	ldh a, [$ff00 + $c1]
	cp b
	ret z
	ld a, b
	ldh [$ff00 + $c1], a
	ld a, $01
	ldh [$ff00 + $f0], a
	ret

.l_0644:
	ldh a, [$ff00 + $81]
	bit 3, a
	jr nz, .l_066c
	bit 0, a
	jr nz, .l_066c
	ldh a, [$ff00 + $cc]
	and a
	ret z
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [$ff00 + $cf]
	cp $50
	jr z, .l_0664
	ldh a, [$ff00 + $c1]

.l_065d:
	ldh [$ff00 + $cf], a
	ld a, $01
	ldh [$ff00 + $ce], a
	ret

.l_0664:
	call func_178a
	ld a, $16
	ldh [$ff00 + $e1], a
	ret

.l_066c:
	ld a, $50
	jr .l_065d

.l_0670:
	ld hl, $ff02
	set 7, [hl]
	jr .l_0696
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, .l_0670
	call func_0aa1
	call func_0aa1
	call func_0aa1
	ld b, $00
	ld hl, $c300

.l_068f:
	call func_0aa1
	ldi [hl], a
	dec b
	jr nz, .l_068f

.l_0696:
	call func_2820
	call func_27ad
	ld de, $5214
	call func_27eb
	call func_178a
	ld a, $2f
	call func_1fdd
	ld a, $03
	ldh [$ff00 + $ce], a
	xor a
	ldh [$ff00 + $01], a
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $dc], a
	ldh [$ff00 + $d2], a
	ldh [$ff00 + $d3], a
	ldh [$ff00 + $d4], a
	ldh [$ff00 + $d5], a
	ldh [$ff00 + $e3], a

.l_06bf:
	ldh [$ff00 + $cc], a
	ld hl, $c400
	ld b, $0a
	ld a, $28

.l_06c8:
	ldi [hl], a
	dec b
	jr nz, .l_06c8
	ldh a, [$ff00 + $d6]
	and a
	jp nz, .l_076d
	call func_1517
	ld a, $d3
	ldh [$ff00 + $40], a
	ld hl, $c080

.l_06dc:
	ld de, $0705
	ld b, $20

.l_06e1:
	call func_0725
	ld hl, $c200
	ld de, $26ed
	ld c, $02
	call func_1776
	call func_080e
	call func_2671
	xor a
	ldh [$ff00 + $d7], a
	ldh [$ff00 + $d8], a
	ldh [$ff00 + $d9], a
	ldh [$ff00 + $da], a
	ldh [$ff00 + $db], a
	ld a, $17
	ldh [$ff00 + $e1], a
	ret
	ld b, b
	jr z, .l_06b6
	nop
	ld b, b
	jr nc, .l_06ba
	jr nz, .l_0756
	jr z, .l_06bf
	nop
	ld c, b
	jr nc, .l_06c3
	jr nz, .l_078e
	jr z, .l_06d8
	nop
	ld a, b
	jr nc, .l_06dc
	jr nz, .l_069e
	jr z, .l_06e1
	nop
	add a, b
	jr nc, .l_06e5
	jr nz, .l_0740
	ldi [hl], a
	inc de
	dec b
	jr nz, $0725
	ret
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0755
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_074a
	ldh a, [$ff00 + $d0]
	cp $60
	jr z, .l_076a
	cp $06
	jr nc, .l_0743
	ldh [$ff00 + $ac], a

.l_0743:
	ldh a, [$ff00 + $ad]
	ldh [$ff00 + $cf], a
	xor a
	ldh [$ff00 + $cc], a

.l_074a:
	ld de, $c210
	call func_1766
	ld hl, $ffad
	jr .l_07bd

.l_0755:
	ldh a, [$ff00 + $81]
	bit 3, a
	jr z, .l_075f
	ld a, $60
	jr .l_07ac

.l_075f:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_07b4
	ldh a, [$ff00 + $cf]
	cp $60
	jr nz, .l_07a2

.l_076a:
	call func_178a

.l_076d:
	ldh a, [$ff00 + $d6]
	and a
	jr nz, .l_078a
	ld a, $18
	ldh [$ff00 + $e1], a
	ldh a, [$ff00 + $cb]
	cp $29
	ret nz
	xor a
	ldh [$ff00 + $a0], a
	ld a, $06
	ld de, $ffe0
	ld hl, $c9a2
	call func_1b68
	ret

.l_078a:
	ldh a, [$ff00 + $cb]
	cp $29

.l_078e:
	jp nz, .l_0828
	xor a
	ldh [$ff00 + $a0], a
	ld a, $06
	ld de, $ffe0
	ld hl, $c9a2
	call func_1b68
	jp .l_0828

.l_07a2:
	ldh a, [$ff00 + $d0]
	cp $06
	jr nc, .l_07aa
	ldh [$ff00 + $ad], a

.l_07aa:
	ldh a, [$ff00 + $ac]

.l_07ac:
	ldh [$ff00 + $cf], a
	xor a
	ldh [$ff00 + $cc], a
	inc a
	ldh [$ff00 + $ce], a

.l_07b4:
	ld de, $c200
	call func_1766
	ld hl, $ffac

.l_07bd:
	ld a, [hl]
	bit 4, b
	jr nz, .l_07d6
	bit 5, b
	jr nz, .l_07e8
	bit 6, b
	jr nz, .l_07ee
	bit 7, b
	jr z, .l_07e1
	cp $03
	jr nc, .l_07e1
	add a, $03
	jr .l_07db

.l_07d6:
	cp $05
	jr z, .l_07e1
	inc a

.l_07db:
	ld [hl], a
	ld a, $01
	ld [$dfe0], a

.l_07e1:
	call func_080e
	call func_2671
	ret

.l_07e8:
	and a
	jr z, .l_07e1
	dec a
	jr .l_07db

.l_07ee:
	cp $03
	jr c, .l_07e1
	sub a, $03
	jr .l_07db
	ld b, b
	ld h, b
	ld b, b
	ld [hl], b
	ld b, b
	add a, b
	ld d, b
	ld h, b
	ld d, b
	ld [hl], b
	ld d, b
	add a, b
	ld a, b
	ld h, b
	ld a, b
	ld [hl], b
	ld a, b
	add a, b
	adc a, b
	ld h, b
	adc a, b
	ld [hl], b
	adc a, b
	add a, b


func_080e::
	ldh a, [$ff00 + $ac]
	ld de, $c201
	ld hl, $07f6
	call func_1755
	ldh a, [$ff00 + $ad]
	ld de, $c211
	ld hl, $0802
	call func_1755
	ret
	call func_2820

.l_0828:
	xor a
	ld [$c210], a
	ldh [$ff00 + $98], a
	ldh [$ff00 + $9c], a
	ldh [$ff00 + $9b], a
	ldh [$ff00 + $fb], a
	ldh [$ff00 + $9f], a
	ldh [$ff00 + $cc], a
	ldh [$ff00 + $01], a
	ldh [$ff00 + $ce], a
	ldh [$ff00 + $d0], a
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $d1], a
	call func_2651
	call func_2293
	call func_1ff2
	xor a
	ldh [$ff00 + $e3], a
	call func_178a
	ld de, $537c
	push de
	ld a, $01
	ldh [$ff00 + $a9], a
	ldh [$ff00 + $c5], a
	call func_27eb

.l_085e:
	pop de
	ld hl, $9c00
	call func_27ee
	ld de, $2839
	ld hl, $9c63
	ld c, $0a
	call func_1f7d
	ld hl, $c200
	ld de, $26bf
	call func_26b6
	ld hl, $c210
	ld de, $26c7
	call func_26b6
	ld hl, $9951
	ld a, $30
	ldh [$ff00 + $9e], a
	ld [hl], $00
	dec l
	ld [hl], $03
	call func_1ae8
	xor a
	ldh [$ff00 + $a0], a
	ldh a, [$ff00 + $cb]
	cp $29
	ld de, $08d4
	ldh a, [$ff00 + $ac]
	jr z, .l_08a4
	ld de, $08c4
	ldh a, [$ff00 + $ad]

.l_08a4:
	ld hl, $98b0
	ld [hl], a
	ld h, $9c
	ld [hl], a
	ld hl, $c080
	ld b, $10
	call func_0725
	ld a, $77
	ldh [$ff00 + $c0], a
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $19
	ldh [$ff00 + $e1], a
	ld a, $01
	ldh [$ff00 + $cd], a
	ret
	jr .l_084a
	ret nz
	nop
	jr .l_0856
	ret nz
	jr nz, .l_08ed
	add a, h
	pop bc
	nop
	jr nz, .l_085e
	pop bc
	jr nz, .l_08ed
	add a, h
	xor [hl]
	nop
	jr .l_0866
	xor [hl]
	jr nz, .l_08fd
	add a, h
	xor a
	nop
	jr nz, .l_086e
	xor a
	jr nz, .l_0923
	ld [$ffe0], sp
	xor a
	ldh [$ff00 + $0f], a
	ldh a, [$ff00 + $cb]

.l_08ed:
	cp $29
	jp nz, .l_09f6

.l_08f2:
	call func_0a98
	call func_0a98
	xor a
	ldh [$ff00 + $cc], a
	ld a, $29

.l_08fd:
	ldh [$ff00 + $01], a
	ld a, $81
	ldh [$ff00 + $02], a

.l_0903:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0903
	ldh a, [$ff00 + $01]
	cp $55
	jr nz, .l_08f2
	ld de, $0016
	ld c, $0a
	ld hl, $c902

.l_0916:
	ld b, $0a

.l_0918:
	xor a
	ldh [$ff00 + $cc], a
	call func_0a98
	ldi a, [hl]
	ldh [$ff00 + $01], a
	ld a, $81

.l_0923:
	ldh [$ff00 + $02], a

.l_0925:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0925
	dec b
	jr nz, .l_0918
	add hl, de
	dec c
	jr nz, .l_0916
	ldh a, [$ff00 + $ac]
	cp $05
	jr z, .l_0974
	ld hl, $ca22
	ld de, $0040

.l_093d:
	add hl, de
	inc a
	cp $05
	jr nz, .l_093d
	ld de, $ca22
	ld c, $0a

.l_0948:
	ld b, $0a

.l_094a:
	ld a, [de]
	ldi [hl], a
	inc e
	dec b
	jr nz, .l_094a
	push de
	ld de, $ffd6
	add hl, de
	pop de
	push hl
	ld hl, $ffd6
	add hl, de
	push hl
	pop de
	pop hl
	dec c
	jr nz, .l_0948
	ld de, $ffd6

.l_0964:
	ld b, $0a
	ld a, h
	cp $c8
	jr z, .l_0974
	ld a, $2f

.l_096d:
	ldi [hl], a
	dec b
	jr nz, .l_096d
	add hl, de
	jr .l_0964

.l_0974:
	call func_0a98
	call func_0a98
	xor a
	ldh [$ff00 + $cc], a
	ld a, $29
	ldh [$ff00 + $01], a
	ld a, $81
	ldh [$ff00 + $02], a

.l_0985:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0985
	ldh a, [$ff00 + $01]
	cp $55
	jr nz, .l_0974
	ld hl, $c300
	ld b, $00

.l_0995:
	xor a
	ldh [$ff00 + $cc], a
	ldi a, [hl]
	call func_0a98
	ldh [$ff00 + $01], a
	ld a, $81
	ldh [$ff00 + $02], a

.l_09a2:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_09a2
	inc b
	jr nz, .l_0995

.l_09aa:
	call func_0a98
	call func_0a98
	xor a
	ldh [$ff00 + $cc], a
	ld a, $30
	ldh [$ff00 + $01], a
	ld a, $81
	ldh [$ff00 + $02], a

.l_09bb:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_09bb
	ldh a, [$ff00 + $01]
	cp $56
	jr nz, .l_09aa

.l_09c6:
	call func_0a8c
	ld a, $09
	ldh [$ff00 + $ff], a
	ld a, $1c
	ldh [$ff00 + $e1], a
	ld a, $02
	ldh [$ff00 + $e3], a
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_09e4
	ld hl, $ff02
	set 7, [hl]

.l_09e4:
	ld hl, $c300
	ldi a, [hl]
	ld [$c203], a
	ldi a, [hl]
	ld [$c213], a
	ld a, h
	ldh [$ff00 + $af], a
	ld a, l
	ldh [$ff00 + $b0], a
	ret

.l_09f6:
	ldh a, [$ff00 + $ad]
	inc a
	ld b, a
	ld hl, $ca42
	ld de, $ffc0

.l_0a00:
	dec b
	jr z, .l_0a06
	add hl, de
	jr .l_0a00

.l_0a06:
	call func_0a98
	xor a
	ldh [$ff00 + $cc], a
	ld a, $55
	ldh [$ff00 + $01], a
	ld a, $80
	ldh [$ff00 + $02], a

.l_0a14:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0a14
	ldh a, [$ff00 + $01]
	cp $29
	jr nz, .l_0a06
	ld de, $0016
	ld c, $0a

.l_0a24:
	ld b, $0a

.l_0a26:
	xor a
	ldh [$ff00 + $cc], a
	ldh [$ff00 + $01], a
	ld a, $80
	ldh [$ff00 + $02], a

.l_0a2f:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0a2f
	ldh a, [$ff00 + $01]
	ldi [hl], a
	dec b
	jr nz, .l_0a26
	add hl, de
	dec c
	jr nz, .l_0a24

.l_0a3e:
	call func_0a98
	xor a
	ldh [$ff00 + $cc], a
	ld a, $55
	ldh [$ff00 + $01], a
	ld a, $80
	ldh [$ff00 + $02], a

.l_0a4c:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0a4c
	ldh a, [$ff00 + $01]
	cp $29
	jr nz, .l_0a3e
	ld b, $00
	ld hl, $c300

.l_0a5c:
	xor a
	ldh [$ff00 + $cc], a
	ldh [$ff00 + $01], a
	ld a, $80
	ldh [$ff00 + $02], a

.l_0a65:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0a65
	ldh a, [$ff00 + $01]
	ldi [hl], a
	inc b
	jr nz, .l_0a5c

.l_0a70:
	call func_0a98
	xor a
	ldh [$ff00 + $cc], a
	ld a, $56
	ldh [$ff00 + $01], a
	ld a, $80
	ldh [$ff00 + $02], a

.l_0a7e:
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_0a7e
	ldh a, [$ff00 + $01]
	cp $30
	jr nz, .l_0a70
	jp .l_09c6


func_0a8c::
	ld hl, $ca42
	ld a, $80
	ld b, $0a

.l_0a93:
	ldi [hl], a
	dec b
	jr nz, .l_0a93
	ret


func_0a98::
	push bc
	ld b, $fa

.l_0a9b:
	ld b, b
	dec b
	jr nz, .l_0a9b
	pop bc
	ret


func_0aa1::
	push hl
	push bc
	ldh a, [$ff00 + $fc]
	and $fc
	ld c, a
	ld h, $03

.l_0aaa:
	ldh a, [$ff00 + $04]
	ld b, a

.l_0aad:
	xor a

.l_0aae:
	dec b
	jr z, .l_0abb
	inc a
	inc a
	inc a
	inc a
	cp $1c
	jr z, .l_0aad
	jr .l_0aae

.l_0abb:
	ld d, a
	ldh a, [$ff00 + $ae]
	ld e, a
	dec h
	jr z, .l_0ac9
	or d
	or c
	and $fc
	cp c
	jr z, .l_0aaa

.l_0ac9:
	ld a, d
	ldh [$ff00 + $ae], a
	ld a, e
	ldh [$ff00 + $fc], a
	pop bc
	pop hl
	ret
	ld a, $01
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $e3]
	and a
	jr nz, .l_0b02
	ld b, $44
	ld c, $20
	call func_113f
	ld a, $02
	ldh [$ff00 + $cd], a
	ld a, [$c0de]
	and a
	jr z, .l_0af1
	ld a, $80
	ld [$c210], a

.l_0af1:
	call func_2683
	call func_2696
	call func_1517
	xor a
	ldh [$ff00 + $d6], a
	ld a, $1a
	ldh [$ff00 + $e1], a
	ret

.l_0b02:
	cp $05
	ret nz
	ld hl, $c030
	ld b, $12

.l_0b0a:
	ld [hl], $f0
	inc hl
	ld [hl], $10
	inc hl
	ld [hl], $b6
	inc hl
	ld [hl], $80
	inc hl
	dec b
	jr nz, .l_0b0a
	ld a, [$c3ff]

.l_0b1c:
	ld b, $0a
	ld hl, $c400

.l_0b21:
	dec a
	jr z, .l_0b2a
	inc l
	dec b
	jr nz, .l_0b21
	jr .l_0b1c

.l_0b2a:
	ld [hl], $2f
	ld a, $03
	ldh [$ff00 + $ce], a
	ret
	ld a, $01
	ldh [$ff00 + $ff], a
	ld hl, $c09c
	xor a
	ldi [hl], a
	ld [hl], $50
	inc l
	ld [hl], $27
	inc l
	ld [hl], $00
	call func_1c0d
	call func_1c88
	call func_24bb
	call func_209c
	call func_213e
	call func_25a1
	call func_224d
	call func_0b9b
	ldh a, [$ff00 + $d5]
	and a
	jr z, .l_0b73
	ld a, $77
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $b1], a
	ld a, $aa
	ldh [$ff00 + $d1], a
	ld a, $1b
	ldh [$ff00 + $e1], a
	ld a, $05
	ldh [$ff00 + $a7], a
	jr .l_0b83

.l_0b73:
	ldh a, [$ff00 + $e1]
	cp $01
	jr nz, .l_0b94
	ld a, $aa
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $b1], a
	ld a, $77
	ldh [$ff00 + $d1], a

.l_0b83:
	xor a
	ldh [$ff00 + $dc], a
	ldh [$ff00 + $d2], a
	ldh [$ff00 + $d3], a
	ldh [$ff00 + $d4], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, .l_0b94
	ldh [$ff00 + $ce], a

.l_0b94:
	call func_0bf0
	call func_0c8c
	ret


func_0b9b::
	ld de, $0020
	ld hl, $c802
	ld a, $2f
	ld c, $12

.l_0ba5:
	ld b, $0a
	push hl

.l_0ba8:
	cp [hl]
	jr nz, .l_0bb5
	inc hl
	dec b
	jr nz, .l_0ba8
	pop hl
	add hl, de
	dec c
	jr nz, .l_0ba5
	push hl

.l_0bb5:
	pop hl
	ld a, c
	ldh [$ff00 + $b1], a
	cp $0c
	ld a, [$dfe9]
	jr nc, .l_0bc7
	cp $08
	ret nz
	call func_1517
	ret

.l_0bc7:
	cp $08
	ret z
	ld a, [$dff0]
	cp $02
	ret z
	ld a, $08
	ld [$dfe8], a
	ret

.l_0bd6:
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0c2e
	ld a, $01
	ld [$df7f], a
	ldh [$ff00 + $ab], a
	ldh a, [$ff00 + $cf]
	ldh [$ff00 + $f1], a
	xor a
	ldh [$ff00 + $f2], a
	ldh [$ff00 + $cf], a
	call func_1ccb
	ret


func_0bf0::
	ldh a, [$ff00 + $cc]
	and a
	ret z
	ld hl, $c030
	ld de, $0004
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [$ff00 + $d0]
	cp $aa
	jr z, .l_0c64
	cp $77
	jr z, .l_0c50
	cp $94
	jr z, .l_0bd6
	ld b, a
	and a
	jr z, .l_0c60
	bit 7, a
	jr nz, .l_0c82
	cp $13
	jr nc, .l_0c2e
	ld a, $12
	sub a, b
	ld c, a
	inc c

.l_0c1c:
	ld a, $98

.l_0c1e:
	ld [hl], a
	add hl, de
	sub a, $08
	dec b
	jr nz, .l_0c1e

.l_0c25:
	ld a, $f0

.l_0c27:
	dec c
	jr z, .l_0c2e
	ld [hl], a
	add hl, de
	jr .l_0c27

.l_0c2e:
	ldh a, [$ff00 + $dc]
	and a
	jr z, .l_0c3a
	or $80
	ldh [$ff00 + $b1], a
	xor a
	ldh [$ff00 + $dc], a

.l_0c3a:
	ld a, $ff
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $cb]
	cp $29
	ldh a, [$ff00 + $b1]
	jr nz, .l_0c4d
	ldh [$ff00 + $cf], a
	ld a, $01
	ldh [$ff00 + $ce], a
	ret

.l_0c4d:
	ldh [$ff00 + $cf], a
	ret

.l_0c50:
	ldh a, [$ff00 + $d1]
	cp $aa
	jr z, .l_0c7c
	ld a, $77
	ldh [$ff00 + $d1], a
	ld a, $01
	ldh [$ff00 + $e1], a
	jr .l_0c2e

.l_0c60:
	ld c, $13
	jr .l_0c25

.l_0c64:
	ldh a, [$ff00 + $d1]
	cp $77
	jr z, .l_0c7c
	ld a, $aa
	ldh [$ff00 + $d1], a
	ld a, $1b
	ldh [$ff00 + $e1], a
	ld a, $05
	ldh [$ff00 + $a7], a
	ld c, $01
	ld b, $12
	jr .l_0c1c

.l_0c7c:
	ld a, $01
	ldh [$ff00 + $ef], a
	jr .l_0c2e

.l_0c82:
	and $7f
	cp $05
	jr nc, .l_0c2e
	ldh [$ff00 + $d2], a
	jr .l_0c3a


func_0c8c::
	ldh a, [$ff00 + $d3]
	and a
	jr z, .l_0c98
	bit 7, a
	ret z
	and $07
	jr .l_0ca2

.l_0c98:
	ldh a, [$ff00 + $d2]
	and a
	ret z
	ldh [$ff00 + $d3], a
	xor a
	ldh [$ff00 + $d2], a
	ret

.l_0ca2:
	ld c, a
	push bc
	ld hl, $c822
	ld de, $ffe0

.l_0caa:
	add hl, de
	dec c
	jr nz, .l_0caa
	ld de, $c822
	ld c, $11

.l_0cb3:
	ld b, $0a

.l_0cb5:
	ld a, [de]
	ldi [hl], a
	inc e
	dec b
	jr nz, .l_0cb5
	push de
	ld de, $0016
	add hl, de
	pop de
	push hl
	ld hl, $0016
	add hl, de
	push hl
	pop de
	pop hl
	dec c
	jr nz, .l_0cb3
	pop bc

.l_0ccd:
	ld de, $c400
	ld b, $0a

.l_0cd2:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, .l_0cd2
	push de
	ld de, $0016
	add hl, de
	pop de
	dec c
	jr nz, .l_0ccd
	ld a, $02
	ldh [$ff00 + $e3], a
	ldh [$ff00 + $d4], a
	xor a
	ldh [$ff00 + $d3], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld a, $01
	ldh [$ff00 + $ff], a
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $d1]
	cp $77
	jr nz, .l_0d09
	ldh a, [$ff00 + $d0]
	cp $aa
	jr nz, .l_0d13

.l_0d03:
	ld a, $01
	ldh [$ff00 + $ef], a
	jr .l_0d13

.l_0d09:
	cp $aa
	jr nz, .l_0d13
	ldh a, [$ff00 + $d0]
	cp $77
	jr z, .l_0d03

.l_0d13:
	ld b, $34
	ld c, $43
	call func_113f
	xor a
	ldh [$ff00 + $e3], a
	ldh a, [$ff00 + $d1]
	cp $aa
	ld a, $1e
	jr nz, .l_0d27
	ld a, $1d

.l_0d27:
	ldh [$ff00 + $e1], a
	ld a, $28
	ldh [$ff00 + $a6], a
	ld a, $1d
	ldh [$ff00 + $c6], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ldh a, [$ff00 + $ef]
	and a
	jr nz, .l_0d40
	ldh a, [$ff00 + $d7]
	inc a
	ldh [$ff00 + $d7], a

.l_0d40:
	call func_0f6f
	ld de, $26f9
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0d4f
	ld de, $270b

.l_0d4f:
	ld hl, $c200
	ld c, $03
	call func_1776
	ld a, $19
	ldh [$ff00 + $a6], a
	ldh a, [$ff00 + $ef]
	and a
	jr z, .l_0d65
	ld hl, $c220
	ld [hl], $80

.l_0d65:
	ld a, $03
	call func_2673
	ld a, $20
	ldh [$ff00 + $e1], a
	ld a, $09
	ld [$dfe8], a
	ldh a, [$ff00 + $d7]
	cp $05
	ret nz
	ld a, $11
	ld [$dfe8], a
	ret

.l_0d7e:
	ldh a, [$ff00 + $d7]
	cp $05
	jr nz, .l_0d8b
	ldh a, [$ff00 + $c6]
	and a
	jr z, .l_0d91
	jr .l_0dad

.l_0d8b:
	ldh a, [$ff00 + $81]
	bit 3, a
	jr z, .l_0dad

.l_0d91:
	ld a, $60
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $ce], a
	jr .l_0db6
	ld a, $01
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $cc]
	jr z, .l_0dad
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0d7e
	ldh a, [$ff00 + $d0]
	cp $60
	jr z, .l_0db6

.l_0dad:
	call func_0dbd
	ld a, $03
	call func_2673
	ret

.l_0db6:
	ld a, $1f
	ldh [$ff00 + $e1], a
	ldh [$ff00 + $cc], a
	ret


func_0dbd::
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_0de5
	ld hl, $ffc6
	dec [hl]
	ld a, $19
	ldh [$ff00 + $a6], a
	call func_0f60
	ld hl, $c201
	ld a, [hl]
	xor $30
	ldi [hl], a
	cp $60
	call z, func_0f17
	inc l
	push af
	ld a, [hl]
	xor $01
	ld [hl], a
	ld l, $13
	ldd [hl], a
	pop af
	dec l
	ld [hl], a

.l_0de5:
	ldh a, [$ff00 + $d7]
	cp $05
	jr nz, .l_0e13
	ldh a, [$ff00 + $c6]
	ld hl, $c221
	cp $06
	jr z, .l_0e0f
	cp $08
	jr nc, .l_0e13
	ld a, [hl]
	cp $72
	jr nc, .l_0e03
	cp $69
	ret z
	inc [hl]
	inc [hl]
	ret

.l_0e03:
	ld [hl], $69
	inc l
	inc l
	ld [hl], $57
	ld a, $06
	ld [$dfe0], a
	ret

.l_0e0f:
	dec l
	ld [hl], $80
	ret

.l_0e13:
	ldh a, [$ff00 + $a7]
	and a
	ret nz
	ld a, $0f
	ldh [$ff00 + $a7], a
	ld hl, $c223
	ld a, [hl]
	xor $01
	ld [hl], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ldh a, [$ff00 + $ef]
	and a
	jr nz, .l_0e31
	ldh a, [$ff00 + $d8]
	inc a
	ldh [$ff00 + $d8], a

.l_0e31:
	call func_0f6f
	ld de, $271d
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0e40
	ld de, $2729

.l_0e40:
	ld hl, $c200
	ld c, $02
	call func_1776
	ld a, $19
	ldh [$ff00 + $a6], a
	ldh a, [$ff00 + $ef]
	and a
	jr z, .l_0e56
	ld hl, $c210
	ld [hl], $80

.l_0e56:
	ld a, $02
	call func_2673
	ld a, $21
	ldh [$ff00 + $e1], a
	ld a, $09
	ld [$dfe8], a
	ldh a, [$ff00 + $d8]
	cp $05
	ret nz
	ld a, $11
	ld [$dfe8], a
	ret

.l_0e6f:
	ldh a, [$ff00 + $d8]
	cp $05
	jr nz, .l_0e7c
	ldh a, [$ff00 + $c6]
	and a
	jr z, .l_0e82
	jr .l_0e9e

.l_0e7c:
	ldh a, [$ff00 + $81]
	bit 3, a
	jr z, .l_0e9e

.l_0e82:
	ld a, $60
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $ce], a
	jr .l_0ea7
	ld a, $01
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $cc]
	jr z, .l_0e9e
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, .l_0e6f
	ldh a, [$ff00 + $d0]
	cp $60
	jr z, .l_0ea7

.l_0e9e:
	call func_0eae
	ld a, $02
	call func_2673
	ret

.l_0ea7:
	ld a, $1f
	ldh [$ff00 + $e1], a
	ldh [$ff00 + $cc], a
	ret


func_0eae::
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_0ecf
	ld hl, $ffc6
	dec [hl]
	ld a, $19
	ldh [$ff00 + $a6], a
	call func_0f60
	ld hl, $c211
	ld a, [hl]
	xor $08
	ldi [hl], a
	cp $68
	call z, func_0f17
	inc l
	ld a, [hl]
	xor $01
	ld [hl], a

.l_0ecf:
	ldh a, [$ff00 + $d8]
	cp $05
	jr nz, .l_0f07
	ldh a, [$ff00 + $c6]
	ld hl, $c201
	cp $05
	jr z, .l_0f03
	cp $06
	jr z, .l_0ef3
	cp $08
	jr nc, .l_0f07
	ld a, [hl]
	cp $72
	jr nc, .l_0f03
	cp $61
	ret z
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

.l_0ef3:
	dec l
	ld [hl], $00
	inc l
	ld [hl], $61
	inc l
	inc l
	ld [hl], $56
	ld a, $06
	ld [$dfe0], a
	ret

.l_0f03:
	dec l
	ld [hl], $80
	ret

.l_0f07:
	ldh a, [$ff00 + $a7]
	and a
	ret nz
	ld a, $0f
	ldh [$ff00 + $a7], a
	ld hl, $c203
	ld a, [hl]
	xor $01
	ld [hl], a
	ret


func_0f17::
	push af
	push hl
	ldh a, [$ff00 + $d7]
	cp $05
	jr z, .l_0f39
	ldh a, [$ff00 + $d8]
	cp $05
	jr z, .l_0f39
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, .l_0f39
	ld hl, $c060
	ld b, $24
	ld de, $0f3c

.l_0f33:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, .l_0f33

.l_0f39:
	pop hl
	pop af
	ret
	ld b, d
	jr nc, .l_0f4c
	nop
	ld b, d
	jr c, .l_0ef5
	nop
	ld b, d
	ld b, b
	ld c, $00
	ld b, d
	ld c, b
	inc e
	nop

.l_0f4c:
	ld b, d
	ld e, b
	ld c, $00
	ld b, d
	ld h, b
	dec e
	nop
	ld b, d
	ld l, b
	or l
	nop
	ld b, d
	ld [hl], b
	cp e
	nop
	ld b, d
	ld a, b
	dec e
	nop


func_0f60::
	ld hl, $c060
	ld de, $0004
	ld b, $09
	xor a

.l_0f69:
	ld [hl], a
	add hl, de
	dec b
	jr nz, .l_0f69
	ret


func_0f6f::
	call func_2820
	ld hl, $55ac
	ld bc, $1000
	call func_27e4
	call func_2795
	ld hl, $9800
	ld de, $54e4
	ld b, $04
	call func_27f0
	ld hl, $9980
	ld b, $06
	call func_27f0
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, .l_0fb9
	ld hl, $9841
	ld [hl], $bd
	inc l
	ld [hl], $b2
	inc l
	ld [hl], $2e
	inc l
	ld [hl], $be
	inc l
	ld [hl], $2e
	ld hl, $9a01
	ld [hl], $b4
	inc l
	ld [hl], $b5
	inc l
	ld [hl], $bb
	inc l
	ld [hl], $2e
	inc l
	ld [hl], $bc

.l_0fb9:
	ldh a, [$ff00 + $ef]
	and a
	jr nz, .l_0fc1
	call func_1085

.l_0fc1:
	ldh a, [$ff00 + $d7]
	and a
	jr z, .l_100f
	cp $05
	jr nz, .l_0fe0
	ld hl, $98a5
	ld b, $0b
	ldh a, [$ff00 + $cb]
	cp $29
	ld de, $10f3
	jr z, .l_0fdb
	ld de, $10fe

.l_0fdb:
	call func_10d8
	ld a, $04

.l_0fe0:
	ld c, a
	ldh a, [$ff00 + $cb]
	cp $29
	ld a, $93
	jr nz, .l_0feb
	ld a, $8f

.l_0feb:
	ldh [$ff00 + $a0], a
	ld hl, $99e7
	call func_106a
	ldh a, [$ff00 + $d9]
	and a
	jr z, .l_100f
	ld a, $ac
	ldh [$ff00 + $a0], a
	ld hl, $99f0
	ld c, $01
	call func_106a
	ld hl, $98a6
	ld de, $1109
	ld b, $09
	call func_10d8

.l_100f:
	ldh a, [$ff00 + $d8]
	and a
	jr z, .l_1052
	cp $05
	jr nz, .l_102e
	ld hl, $98a5
	ld b, $0b
	ldh a, [$ff00 + $cb]
	cp $29
	ld de, $10fe
	jr z, .l_1029
	ld de, $10f3

.l_1029:
	call func_10d8
	ld a, $04

.l_102e:
	ld c, a
	ldh a, [$ff00 + $cb]
	cp $29
	ld a, $8f
	jr nz, .l_1039
	ld a, $93

.l_1039:
	ldh [$ff00 + $a0], a
	ld hl, $9827
	call func_106a
	ldh a, [$ff00 + $da]
	and a
	jr z, .l_1052
	ld a, $ac
	ldh [$ff00 + $a0], a
	ld hl, $9830
	ld c, $01
	call func_106a

.l_1052:
	ldh a, [$ff00 + $db]
	and a
	jr z, .l_1062
	ld hl, $98a7
	ld de, $10ed
	ld b, $06
	call func_10d8

.l_1062:
	ld a, $d3
	ldh [$ff00 + $40], a
	call func_178a
	ret


func_106a::
	ldh a, [$ff00 + $a0]
	push hl
	ld de, $0020
	ld b, $02

.l_1072:
	push hl
	ldi [hl], a
	inc a
	ld [hl], a
	inc a
	pop hl
	add hl, de
	dec b
	jr nz, .l_1072
	pop hl
	ld de, $0003
	add hl, de
	dec c
	jr nz, $106a
	ret


func_1085::
	ld hl, $ffd7
	ld de, $ffd8
	ldh a, [$ff00 + $d9]
	and a
	jr nz, .l_10ca
	ldh a, [$ff00 + $da]
	and a
	jr nz, .l_10d1
	ldh a, [$ff00 + $db]
	and a
	jr nz, .l_10bb
	ld a, [hl]
	cp $04
	jr z, .l_10b0
	ld a, [de]
	cp $04
	ret nz

.l_10a3:
	ld a, $05
	ld [de], a
	jr .l_10b2
	ld a, [de]
	cp $03
	ret nz

.l_10ac:
	ld a, $03
	jr .l_10b5

.l_10b0:
	ld [hl], $05

.l_10b2:
	xor a
	ldh [$ff00 + $db], a

.l_10b5:
	xor a
	ldh [$ff00 + $d9], a
	ldh [$ff00 + $da], a
	ret

.l_10bb:
	ld a, [hl]
	cp $04
	jr nz, .l_10c6
	ldh [$ff00 + $d9], a

.l_10c2:
	xor a
	ldh [$ff00 + $db], a
	ret

.l_10c6:
	ldh [$ff00 + $da], a
	jr .l_10c2

.l_10ca:
	ld a, [hl]
	cp $05
	jr z, .l_10b0
	jr .l_10ac

.l_10d1:
	ld a, [de]
	cp $05
	jr z, .l_10a3
	jr .l_10ac


func_10d8::
	push bc
	push hl

.l_10da:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, .l_10da
	pop hl
	ld de, $0020
	add hl, de
	pop bc
	ld a, $b6

.l_10e8:
	ldi [hl], a
	dec b
	jr nz, .l_10e8
	ret
	or b
	or c
	or d
	or e
	or c
	ld a, $b4
	or l
	cp e
	ld l, $bc
	cpl
	dec l
	ld l, $3d
	ld c, $3e
	cp l
	or d
	ld l, $be
	ld l, $2f
	dec l
	ld l, $3d
	ld c, $3e
	or l
	or b
	ld b, c
	or l
	dec a
	dec e
	or l
	cp [hl]
	or c
	ld a, $01
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	call func_178a
	xor a
	ldh [$ff00 + $ef], a
	ld b, $27
	ld c, $79
	call func_113f
	call func_7ff3
	ldh a, [$ff00 + $d7]
	cp $05
	jr z, .l_113a
	ldh a, [$ff00 + $d8]
	cp $05
	jr z, .l_113a
	ld a, $01
	ldh [$ff00 + $d6], a

.l_113a:
	ld a, $16
	ldh [$ff00 + $e1], a
	ret


func_113f::
	ldh a, [$ff00 + $cc]
	and a
	jr z, .l_1158
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [$ff00 + $cb]
	cp $29
	ldh a, [$ff00 + $d0]
	jr nz, .l_1160
	cp b
	jr z, .l_115a
	ld a, $02
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $ce], a

.l_1158:
	pop hl
	ret

.l_115a:
	ld a, c
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $ce], a
	ret

.l_1160:
	cp c
	ret z
	ld a, b
	ldh [$ff00 + $cf], a
	pop hl
	ret
	call func_11b2
	ld hl, $9ce6
	ld de, $141b
	ld b, $07
	call func_1437
	ld hl, $9ce7
	ld de, $1422
	ld b, $07
	call func_1437
	ld hl, $9d08
	ld [hl], $72
	inc l
	ld [hl], $c4
	ld hl, $9d28
	ld [hl], $b7
	inc l
	ld [hl], $b8
	ld de, $2771
	ld hl, $c200
	ld c, $03
	call func_1776
	ld a, $03
	call func_2673
	ld a, $db
	ldh [$ff00 + $40], a
	ld a, $bb
	ldh [$ff00 + $a6], a
	ld a, $27
	ldh [$ff00 + $e1], a
	ld a, $10
	ld [$dfe8], a
	ret


func_11b2::
	call func_2820
	ld hl, $55ac
	ld bc, $1000
	call func_27e4
	ld hl, $9fff
	call func_2798
	ld hl, $9dc0
	ld de, $51c4
	ld b, $04
	call func_27f0
	ld hl, $9cec
	ld de, $1429
	ld b, $07
	call func_1437
	ld hl, $9ced
	ld de, $1430
	ld b, $07
	call func_1437
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld hl, $c210
	ld [hl], $00
	ld l, $20
	ld [hl], $00
	ld a, $ff
	ldh [$ff00 + $a6], a
	ld a, $28
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr z, .l_1205
	call func_13fa
	ret

.l_1205:
	ld a, $29
	ldh [$ff00 + $e1], a
	ld hl, $c213
	ld [hl], $35
	ld l, $23
	ld [hl], $35
	ld a, $ff
	ldh [$ff00 + $a6], a
	ld a, $2f
	call func_1fd7
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr z, .l_1225
	call func_13fa
	ret

.l_1225:
	ld a, $02
	ldh [$ff00 + $e1], a
	ld hl, $9d08
	ld b, $2f
	call func_19ff
	ld hl, $9d09
	call func_19ff
	ld hl, $9d28
	call func_19ff
	ld hl, $9d29
	call func_19ff
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_1277
	ld a, $0a
	ldh [$ff00 + $a6], a
	ld hl, $c201
	dec [hl]
	ld a, [hl]
	cp $58
	jr nz, .l_1277
	ld hl, $c210
	ld [hl], $00
	inc l
	add a, $20
	ldi [hl], a
	ld [hl], $4c
	inc l
	ld [hl], $40
	ld l, $20
	ld [hl], $80
	ld a, $03
	call func_2673
	ld a, $03
	ldh [$ff00 + $e1], a
	ld a, $04
	ld [$dff8], a
	ret

.l_1277:
	call func_13fa
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_129d
	ld a, $0a
	ldh [$ff00 + $a6], a
	ld hl, $c211
	dec [hl]
	ld l, $01
	dec [hl]
	ld a, [hl]
	cp $d0
	jr nz, .l_129d
	ld a, $9c
	ldh [$ff00 + $c9], a
	ld a, $82
	ldh [$ff00 + $ca], a
	ld a, $2c
	ldh [$ff00 + $e1], a
	ret

.l_129d:
	ldh a, [$ff00 + $a7]
	and a
	jr nz, .l_12ad
	ld a, $06
	ldh [$ff00 + $a7], a
	ld hl, $c213
	ld a, [hl]
	xor $01
	ld [hl], a

.l_12ad:
	ld a, $03
	call func_2673
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld a, $06
	ldh [$ff00 + $a6], a
	ldh a, [$ff00 + $ca]
	sub a, $82
	ld e, a
	ld d, $00
	ld hl, $12f5
	add hl, de
	push hl
	pop de
	ldh a, [$ff00 + $c9]
	ld h, a
	ldh a, [$ff00 + $ca]
	ld l, a
	ld a, [de]
	call func_19fe
	push hl
	ld de, $0020
	add hl, de
	ld b, $b6
	call func_19ff
	pop hl
	inc hl
	ld a, $02
	ld [$dfe0], a
	ld a, h
	ldh [$ff00 + $c9], a
	ld a, l
	ldh [$ff00 + $ca], a
	cp $92
	ret nz
	ld a, $ff
	ldh [$ff00 + $a6], a
	ld a, $2d
	ldh [$ff00 + $e1], a
	ret
	or e
	cp h
	dec a
	cp [hl]
	cp e
	or l
	dec e
	or d
	cp l
	or l
	dec e
	ld l, $bc
	dec a
	ld c, $3e
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	call func_2820
	call func_27ad
	call func_2293
	ld a, $93
	ldh [$ff00 + $40], a
	ld a, $05
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld a, $2e
	ldh [$ff00 + $e1], a
	ret
	call func_11b2
	ld de, $2783
	ld hl, $c200
	ld c, $03
	call func_1776
	ldh a, [$ff00 + $f3]
	ld [$c203], a
	ld a, $03
	call func_2673
	xor a
	ldh [$ff00 + $f3], a
	ld a, $db
	ldh [$ff00 + $40], a
	ld a, $bb
	ldh [$ff00 + $a6], a
	ld a, $2f
	ldh [$ff00 + $e1], a
	ld a, $10
	ld [$dfe8], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld hl, $c210
	ld [hl], $00
	ld l, $20
	ld [hl], $00
	ld a, $a0
	ldh [$ff00 + $a6], a
	ld a, $30
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr z, .l_1370
	call func_13fa
	ret

.l_1370:
	ld a, $31
	ldh [$ff00 + $e1], a
	ld a, $80
	ldh [$ff00 + $a6], a
	ld a, $2f
	call func_1fd7
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_13b1
	ld a, $0a
	ldh [$ff00 + $a6], a
	ld hl, $c201
	dec [hl]
	ld a, [hl]
	cp $6a
	jr nz, .l_13b1
	ld hl, $c210
	ld [hl], $00
	inc l
	add a, $10
	ldi [hl], a
	ld [hl], $54
	inc l
	ld [hl], $5c
	ld l, $20
	ld [hl], $80
	ld a, $03
	call func_2673
	ld a, $32
	ldh [$ff00 + $e1], a
	ld a, $04
	ld [$dff8], a
	ret

.l_13b1:
	call func_13fa
	ret
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_13cf
	ld a, $0a
	ldh [$ff00 + $a6], a
	ld hl, $c211
	dec [hl]
	ld l, $01
	dec [hl]
	ld a, [hl]
	cp $e0
	jr nz, .l_13cf
	ld a, $33
	ldh [$ff00 + $e1], a
	ret

.l_13cf:
	ldh a, [$ff00 + $a7]
	and a
	jr nz, .l_13df
	ld a, $06
	ldh [$ff00 + $a7], a
	ld hl, $c213
	ld a, [hl]
	xor $01
	ld [hl], a

.l_13df:
	ld a, $03
	call func_2673
	ret
	call func_2820
	call func_27ad
	call func_7ff3
	call func_2293
	ld a, $93
	ldh [$ff00 + $40], a
	ld a, $10
	ldh [$ff00 + $e1], a
	ret


func_13fa::
	ldh a, [$ff00 + $a7]
	and a
	ret nz
	ld a, $0a
	ldh [$ff00 + $a7], a
	ld a, $03
	ld [$dff8], a
	ld b, $02
	ld hl, $c210

.l_140c:
	ld a, [hl]
	xor $80
	ld [hl], a
	ld l, $20
	dec b
	jr nz, .l_140c
	ld a, $03
	call func_2673
	ret
	jp nz, .l_caca
	jp z, .l_caca
	jp z, .l_cbc3
	ld e, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ret z
	ld [hl], e
	ld [hl], e
	ld [hl], e
	ld [hl], e
	ld [hl], e
	ld [hl], e
	ret
	ld [hl], h
	ld [hl], h
	ld [hl], h
	ld [hl], h
	ld [hl], h
	ld [hl], h


func_1437::
	ld a, [de]
	ld [hl], a
	inc de
	push de
	ld de, $0020
	add hl, de
	pop de
	dec b
	jr nz, $1437
	ret
	ld a, $01
	ldh [$ff00 + $ff], a
	xor a
	ldh [$ff00 + $01], a
	ldh [$ff00 + $02], a
	ldh [$ff00 + $0f], a


func_144f::
	call func_2820
	call func_27ad
	ld de, $4cd7
	call func_27eb
	call func_178a
	ld hl, $c200
	ld de, $26cf
	ld c, $02
	call func_1776
	ld de, $c201
	call func_148d
	ldh a, [$ff00 + $c0]
	ld e, $12
	ld [de], a
	inc de
	cp $37
	ld a, $1c
	jr z, .l_147d
	ld a, $1d

.l_147d:
	ld [de], a
	call func_2671
	call func_1517
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $0e
	ldh [$ff00 + $e1], a
	ret


func_148d::
	ld a, $01
	ld [$dfe0], a


func_1492::
	ldh a, [$ff00 + $c1]
	push af
	sub a, $1c
	add a, a
	ld c, a
	ld b, $00
	ld hl, $14a8
	add hl, bc
	ldi a, [hl]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	pop af
	ld [de], a
	ret
	ld [hl], b
	scf
	ld [hl], b
	ld [hl], a
	add a, b
	scf
	add a, b
	ld [hl], a


func_14b0::
	ld de, $c200
	call func_1766
	ld hl, $ffc1
	ld a, [hl]
	bit 3, b
	jp nz, .l_1563
	bit 0, b
	jp nz, .l_1563
	bit 1, b
	jr nz, .l_1509

.l_14c8:
	inc e
	bit 4, b
	jr nz, .l_14f3
	bit 5, b
	jr nz, .l_14fe
	bit 6, b
	jr nz, .l_14eb
	bit 7, b
	jp z, .l_155f
	cp $1e
	jr nc, .l_14e7
	add a, $02

.l_14e0:
	ld [hl], a
	call func_148d
	call func_1517

.l_14e7:
	call func_2671
	ret

.l_14eb:
	cp $1e
	jr c, .l_14e7
	sub a, $02
	jr .l_14e0

.l_14f3:
	cp $1d
	jr z, .l_14e7
	cp $1f
	jr z, .l_14e7
	inc a
	jr .l_14e0

.l_14fe:
	cp $1c
	jr z, .l_14e7
	cp $1e
	jr z, .l_14e7
	dec a
	jr .l_14e0

.l_1509:
	push af
	ldh a, [$ff00 + $c5]
	and a
	jr z, .l_1512
	pop af
	jr .l_14c8

.l_1512:
	pop af
	ld a, $0e
	jr .l_1572


func_1517::
	ldh a, [$ff00 + $c1]
	sub a, $17
	cp $08
	jr nz, .l_1521
	ld a, $ff

.l_1521:
	ld [$dfe8], a
	ret
	ld de, $c210
	call func_1766
	ld hl, $ffc0
	ld a, [hl]
	bit 3, b
	jr nz, .l_1563
	bit 0, b
	jr nz, .l_1577
	inc e
	inc e
	bit 4, b
	jr nz, .l_154b
	bit 5, b
	jr z, .l_155f
	cp $37
	jr z, .l_155f
	ld a, $37
	ld b, $1c
	jr .l_1553

.l_154b:
	cp $77
	jr z, .l_155f
	ld a, $77
	ld b, $1d

.l_1553:
	ld [hl], a
	push af
	ld a, $01
	ld [$dfe0], a
	pop af
	ld [de], a
	inc de
	ld a, b

.l_155e:
	ld [de], a

.l_155f:
	call func_2671
	ret

.l_1563:
	ld a, $02
	ld [$dfe0], a
	ldh a, [$ff00 + $c0]
	cp $37
	ld a, $10
	jr z, .l_1572
	ld a, $12

.l_1572:
	ldh [$ff00 + $e1], a
	xor a
	jr .l_155e

.l_1577:
	ld a, $0f
	jr .l_1572
	call func_2820
	ld de, $4e3f
	call func_27eb
	call func_18fc
	call func_178a
	ld hl, $c200
	ld de, $26db
	ld c, $01
	call func_1776
	ld de, $c201
	ldh a, [$ff00 + $c2]
	ld hl, $1615
	call func_174e
	call func_2671
	call func_1795
	call func_18ca
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $11
	ldh [$ff00 + $e1], a
	ldh a, [$ff00 + $c7]
	and a
	jr nz, .l_15ba
	call func_1517
	ret

.l_15ba:
	ld a, $15

.l_15bc:
	ldh [$ff00 + $e1], a
	ret
	ld de, $c200
	call func_1766
	ld hl, $ffc2
	ld a, $0a
	bit 3, b
	jr nz, .l_15bc
	bit 0, b
	jr nz, .l_15bc
	ld a, $08
	bit 1, b
	jr nz, .l_15bc
	ld a, [hl]
	bit 4, b
	jr nz, .l_15f1
	bit 5, b
	jr nz, .l_1607
	bit 6, b
	jr nz, .l_160d
	bit 7, b
	jr z, .l_1603
	cp $05
	jr nc, .l_1603
	add a, $05
	jr .l_15f6

.l_15f1:
	cp $09
	jr z, .l_1603
	inc a

.l_15f6:
	ld [hl], a
	ld de, $c201
	ld hl, $1615
	call func_174e
	call func_1795

.l_1603:
	call func_2671
	ret

.l_1607:
	and a
	jr z, .l_1603
	dec a
	jr .l_15f6

.l_160d:
	cp $05
	jr c, .l_1603
	sub a, $05
	jr .l_15f6
	ld b, b
	jr nc, .l_1658
	ld b, b
	ld b, b
	ld d, b
	ld b, b
	ld h, b
	ld b, b
	ld [hl], b
	ld d, b
	jr nc, .l_1672
	ld b, b
	ld d, b
	ld d, b
	ld d, b
	ld h, b
	ld d, b
	ld [hl], b
	call func_2820
	ld de, $4fa7
	call func_27eb
	call func_178a
	ld hl, $c200
	ld de, $26e1
	ld c, $02
	call func_1776
	ld de, $c201
	ldh a, [$ff00 + $c3]
	ld hl, $16d2
	call func_174e
	ld de, $c211
	ldh a, [$ff00 + $c4]
	ld hl, $1741
	call func_174e
	call func_2671
	call func_17af
	call func_18ca
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $13
	ldh [$ff00 + $e1], a
	ldh a, [$ff00 + $c7]
	and a
	jr nz, .l_1670
	call func_1517
	ret

.l_1670:
	ld a, $15

.l_1672:
	ldh [$ff00 + $e1], a
	ret

.l_1675:
	ldh [$ff00 + $e1], a
	xor a
	ld [de], a
	ret
	ld de, $c200
	call func_1766
	ld hl, $ffc3
	ld a, $0a
	bit 3, b
	jr nz, .l_1675
	ld a, $14
	bit 0, b
	jr nz, .l_1675
	ld a, $08
	bit 1, b
	jr nz, .l_1675
	ld a, [hl]
	bit 4, b
	jr nz, .l_16ae
	bit 5, b
	jr nz, .l_16c4
	bit 6, b
	jr nz, .l_16ca
	bit 7, b
	jr z, .l_16c0
	cp $05
	jr nc, .l_16c0
	add a, $05
	jr .l_16b3

.l_16ae:
	cp $09
	jr z, .l_16c0
	inc a

.l_16b3:
	ld [hl], a
	ld de, $c201
	ld hl, $16d2
	call func_174e
	call func_17af

.l_16c0:
	call func_2671
	ret

.l_16c4:
	and a
	jr z, .l_16c0
	dec a
	jr .l_16b3

.l_16ca:
	cp $05
	jr c, .l_16c0
	sub a, $05
	jr .l_16b3
	ld b, b
	jr .l_1715
	jr z, .l_1717
	jr c, .l_1719
	ld c, b
	ld b, b
	ld e, b
	ld d, b
	jr .l_172f
	jr z, .l_1731
	jr c, .l_1733
	ld c, b
	ld d, b
	ld e, b

.l_16e6:
	ldh [$ff00 + $e1], a
	xor a
	ld [de], a
	ret
	ld de, $c210
	call func_1766
	ld hl, $ffc4
	ld a, $0a
	bit 3, b
	jr nz, .l_16e6
	bit 0, b
	jr nz, .l_16e6
	ld a, $13
	bit 1, b
	jr nz, .l_16e6
	ld a, [hl]
	bit 4, b
	jr nz, .l_171d
	bit 5, b
	jr nz, .l_1733
	bit 6, b
	jr nz, .l_1739
	bit 7, b
	jr z, .l_172f

.l_1715:
	cp $03

.l_1717:
	jr nc, .l_172f

.l_1719:
	add a, $03
	jr .l_1722

.l_171d:
	cp $05
	jr z, .l_172f
	inc a

.l_1722:
	ld [hl], a
	ld de, $c211
	ld hl, $1741
	call func_174e
	call func_17af

.l_172f:
	call func_2671
	ret

.l_1733:
	and a
	jr z, .l_172f
	dec a
	jr .l_1722

.l_1739:
	cp $03
	jr c, .l_172f
	sub a, $03
	jr .l_1722
	ld b, b
	ld [hl], b
	ld b, b
	add a, b
	ld b, b
	sub a, b
	ld d, b
	ld [hl], b
	ld d, b
	add a, b
	ld d, b
	sub a, b
	nop


func_174e::
	push af
	ld a, $01
	ld [$dfe0], a
	pop af


func_1755::
	push af
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ldi a, [hl]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	pop af
	add a, $20
	ld [de], a
	ret


func_1766::
	ldh a, [$ff00 + $81]
	ld b, a
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld a, $10
	ldh [$ff00 + $a6], a
	ld a, [de]
	xor $80
	ld [de], a
	ret


func_1776::
	push hl
	ld b, $06

.l_1779:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, .l_1779
	pop hl
	ld a, $10
	add a, l
	ld l, a
	dec c
	jr nz, $1776
	ld [hl], $80
	ret


func_178a::
	xor a
	ld hl, $c000
	ld b, $a0

.l_1790:
	ldi [hl], a
	dec b
	jr nz, .l_1790
	ret


func_1795::
	call func_18fc
	ldh a, [$ff00 + $c2]
	ld hl, $d654
	ld de, $001b

.l_17a0:
	and a
	jr z, .l_17a7
	dec a
	add hl, de
	jr .l_17a0

.l_17a7:
	inc hl
	inc hl
	push hl
	pop de
	call func_1800
	ret


func_17af::
	call func_18fc
	ldh a, [$ff00 + $c3]
	ld hl, $d000
	ld de, $00a2

.l_17ba:
	and a
	jr z, .l_17c1
	dec a
	add hl, de
	jr .l_17ba

.l_17c1:
	ldh a, [$ff00 + $c4]
	ld de, $001b

.l_17c6:
	and a
	jr z, .l_17cd
	dec a
	add hl, de
	jr .l_17c6

.l_17cd:
	inc hl
	inc hl
	push hl
	pop de
	call func_1800
	ret


func_17d5::
	ld b, $03

.l_17d7:
	ld a, [hl]
	and $f0
	jr nz, .l_17e7
	inc e
	ldd a, [hl]
	and $0f
	jr nz, .l_17f1
	inc e
	dec b
	jr nz, .l_17d7
	ret

.l_17e7:
	ld a, [hl]
	and $f0
	swap a
	ld [de], a
	inc e
	ldd a, [hl]
	and $0f

.l_17f1:
	ld [de], a
	inc e
	dec b
	jr nz, .l_17e7
	ret


func_17f7::
	ld b, $03


func_17f9::
	ldd a, [hl]
	ld [de], a
	dec de
	dec b
	jr nz, $17f9
	ret


func_1800::
	ld a, d
	ldh [$ff00 + $fb], a
	ld a, e
	ldh [$ff00 + $fc], a
	ld c, $03

.l_1808:
	ld hl, $c0a2
	push de
	ld b, $03

.l_180e:
	ld a, [de]
	sub a, [hl]
	jr c, .l_1822
	jr nz, .l_1819
	dec l
	dec de
	dec b
	jr nz, .l_180e

.l_1819:
	pop de
	inc de
	inc de
	inc de
	dec c
	jr nz, .l_1808
	jr .l_1880

.l_1822:
	pop de
	ldh a, [$ff00 + $fb]
	ld d, a
	ldh a, [$ff00 + $fc]
	ld e, a
	push de
	push bc
	ld hl, $0006
	add hl, de
	push hl
	pop de
	dec hl
	dec hl
	dec hl

.l_1834:
	dec c
	jr z, .l_183c
	call func_17f7
	jr .l_1834

.l_183c:
	ld hl, $c0a2
	ld b, $03

.l_1841:
	ldd a, [hl]
	ld [de], a
	dec e
	dec b
	jr nz, .l_1841
	pop bc
	pop de
	ld a, c
	ldh [$ff00 + $c8], a
	ld hl, $0012
	add hl, de
	push hl
	ld de, $0006
	add hl, de
	push hl
	pop de
	pop hl

.l_1858:
	dec c
	jr z, .l_1862
	ld b, $06
	call func_17f9
	jr .l_1858

.l_1862:
	ld a, $60
	ld b, $05

.l_1866:
	ld [de], a
	dec de
	dec b
	jr nz, .l_1866
	ld a, $0a
	ld [de], a
	ld a, d
	ldh [$ff00 + $c9], a
	ld a, e
	ldh [$ff00 + $ca], a
	xor a
	ldh [$ff00 + $9c], a
	ldh [$ff00 + $c6], a
	ld a, $01
	ld [$dfe8], a
	ldh [$ff00 + $c7], a

.l_1880:
	ld de, $c9ac
	ldh a, [$ff00 + $fb]
	ld h, a
	ldh a, [$ff00 + $fc]
	ld l, a
	ld b, $03

.l_188b:
	push hl
	push de
	push bc
	call func_17d5
	pop bc
	pop de
	ld hl, $0020
	add hl, de
	push hl
	pop de
	pop hl
	push de
	ld de, $0003
	add hl, de
	pop de
	dec b
	jr nz, .l_188b
	dec hl
	dec hl
	ld b, $03
	ld de, $c9a4

.l_18aa:
	push de
	ld c, $06

.l_18ad:
	ldi a, [hl]
	and a
	jr z, .l_18b6
	ld [de], a
	inc de
	dec c
	jr nz, .l_18ad

.l_18b6:
	pop de
	push hl
	ld hl, $0020
	add hl, de
	push hl
	pop de
	pop hl
	dec b
	jr nz, .l_18aa
	call func_2651
	ld a, $01
	ldh [$ff00 + $e8], a
	ret


func_18ca::
	ldh a, [$ff00 + $e8]
	and a
	ret z
	ld hl, $99a4
	ld de, $c9a4
	ld c, $06

.l_18d6:
	push hl

.l_18d7:
	ld b, $06

.l_18d9:
	ld a, [de]
	ldi [hl], a
	inc e
	dec b
	jr nz, .l_18d9
	inc e
	inc l
	inc e
	inc l
	dec c
	jr z, .l_18f7
	bit 0, c
	jr nz, .l_18d7
	pop hl
	ld de, $0020
	add hl, de
	push hl
	pop de
	ld a, $30
	add a, d
	ld d, a
	jr .l_18d6

.l_18f7:
	pop hl


func_18f8::
	xor a
	ldh [$ff00 + $e8], a
	ret


func_18fc::
	ld hl, $c9a4
	ld de, $0020
	ld a, $60
	ld c, $03

.l_1906:
	ld b, $0e
	push hl

.l_1909:
	ldi [hl], a
	dec b
	jr nz, .l_1909
	pop hl
	add hl, de
	dec c
	jr nz, .l_1906
	ret
	ldh a, [$ff00 + $c8]
	ld hl, $99e4
	ld de, $ffe0

.l_191b:
	dec a
	jr z, .l_1921
	add hl, de
	jr .l_191b

.l_1921:
	ldh a, [$ff00 + $c6]
	ld e, a
	ld d, $00
	add hl, de
	ldh a, [$ff00 + $c9]
	ld d, a
	ldh a, [$ff00 + $ca]
	ld e, a
	ldh a, [$ff00 + $a6]
	and a
	jr nz, .l_1944
	ld a, $07
	ldh [$ff00 + $a6], a
	ldh a, [$ff00 + $9c]
	xor $01
	ldh [$ff00 + $9c], a
	ld a, [de]
	jr z, .l_1941
	ld a, $2f

.l_1941:
	call func_19fe

.l_1944:
	ldh a, [$ff00 + $81]
	ld b, a
	ldh a, [$ff00 + $80]
	ld c, a
	ld a, $17
	bit 6, b
	jr nz, .l_1987
	bit 6, c
	jr nz, .l_197f
	bit 7, b
	jr nz, .l_19b0
	bit 7, c
	jr nz, .l_19a8
	bit 0, b
	jr nz, .l_19cc
	bit 1, b
	jp nz, .l_19ee
	bit 3, b
	ret z

.l_1968:
	ld a, [de]
	call func_19fe
	call func_1517
	xor a
	ldh [$ff00 + $c7], a
	ldh a, [$ff00 + $c0]
	cp $37
	ld a, $11
	jr z, .l_197c
	ld a, $13

.l_197c:
	ldh [$ff00 + $e1], a
	ret

.l_197f:
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

.l_1987:
	ldh [$ff00 + $aa], a
	ld b, $26
	ldh a, [$ff00 + $f4]
	and a
	jr z, .l_1992
	ld b, $27

.l_1992:
	ld a, [de]
	cp b
	jr nz, .l_19a0
	ld a, $2e

.l_1998:
	inc a

.l_1999:
	ld [de], a
	ld a, $01
	ld [$dfe0], a
	ret

.l_19a0:
	cp $2f
	jr nz, .l_1998
	ld a, $0a
	jr .l_1999

.l_19a8:
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

.l_19b0:
	ldh [$ff00 + $aa], a
	ld b, $26
	ldh a, [$ff00 + $f4]
	and a
	jr z, .l_19bb
	ld b, $27

.l_19bb:
	ld a, [de]
	cp $0a
	jr nz, .l_19c5
	ld a, $30

.l_19c2:
	dec a
	jr .l_1999

.l_19c5:
	cp $2f
	jr nz, .l_19c2
	ld a, b
	jr .l_1999

.l_19cc:
	ld a, [de]
	call func_19fe
	ld a, $02
	ld [$dfe0], a
	ldh a, [$ff00 + $c6]
	inc a
	cp $06
	jr z, .l_1968
	ldh [$ff00 + $c6], a
	inc de
	ld a, [de]
	cp $60
	jr nz, .l_19e7
	ld a, $0a
	ld [de], a

.l_19e7:
	ld a, d
	ldh [$ff00 + $c9], a
	ld a, e
	ldh [$ff00 + $ca], a
	ret

.l_19ee:
	ldh a, [$ff00 + $c6]
	and a
	ret z
	ld a, [de]
	call func_19fe
	ldh a, [$ff00 + $c6]
	dec a
	ldh [$ff00 + $c6], a
	dec de
	jr .l_19e7


func_19fe::
	ld b, a


func_19ff::
	ldh a, [$ff00 + $41]
	and $03
	jr nz, $19ff
	ld [hl], b
	ret
	call func_2820
	xor a
	ld [$c210], a
	ldh [$ff00 + $98], a
	ldh [$ff00 + $9c], a
	ldh [$ff00 + $9b], a
	ldh [$ff00 + $fb], a
	ldh [$ff00 + $9f], a
	ld a, $2f
	call func_1fd7
	call func_1ff2
	call func_2651
	xor a
	ldh [$ff00 + $e3], a
	call func_178a
	ldh a, [$ff00 + $c0]
	ld de, $3ff7
	ld hl, $ffc3
	cp $77
	ld a, $50
	jr z, .l_1a3f
	ld a, $f1
	ld hl, $ffc2
	ld de, $3e8f

.l_1a3f:
	push de
	ldh [$ff00 + $e6], a
	ld a, [hl]
	ldh [$ff00 + $a9], a
	call func_27eb
	pop de
	ld hl, $9c00
	call func_27ee
	ld de, $2839
	ld hl, $9c63
	ld c, $0a
	call func_1f7d
	ld h, $98
	ldh a, [$ff00 + $e6]
	ld l, a
	ldh a, [$ff00 + $a9]
	ld [hl], a
	ld h, $9c
	ld [hl], a
	ldh a, [$ff00 + $f4]
	and a
	jr z, .l_1a71
	inc hl
	ld [hl], $27
	ld h, $98
	ld [hl], $27

.l_1a71:
	ld hl, $c200
	ld de, $26bf
	call func_26b6
	ld hl, $c210
	ld de, $26c7
	call func_26b6
	ld hl, $9951
	ldh a, [$ff00 + $c0]
	cp $77
	ld a, $25
	jr z, .l_1a8f
	xor a

.l_1a8f:
	ldh [$ff00 + $9e], a
	and $0f
	ldd [hl], a
	jr z, .l_1a98
	ld [hl], $02

.l_1a98:
	call func_1ae8
	ld a, [$c0de]
	and a
	jr z, .l_1aa6
	ld a, $80
	ld [$c210], a

.l_1aa6:
	call func_2007
	call func_2007
	call func_2007
	call func_2683
	xor a
	ldh [$ff00 + $a0], a
	ldh a, [$ff00 + $c0]
	cp $77
	jr nz, .l_1ae0
	ld a, $34
	ldh [$ff00 + $99], a
	ldh a, [$ff00 + $c4]
	ld hl, $98b0
	ld [hl], a
	ld h, $9c
	ld [hl], a
	and a
	jr z, .l_1ae0
	ld b, a
	ldh a, [$ff00 + $e4]
	and a
	jr z, .l_1ad6
	call func_1b1b
	jr .l_1ae0

.l_1ad6:
	ld a, b
	ld de, $ffc0
	ld hl, $9a02
	call func_1b68

.l_1ae0:
	ld a, $d3
	ldh [$ff00 + $40], a
	xor a
	ldh [$ff00 + $e1], a
	ret


func_1ae8::
	ldh a, [$ff00 + $a9]
	ld e, a
	ldh a, [$ff00 + $f4]
	and a
	jr z, .l_1afa
	ld a, $0a
	add a, e
	cp $15
	jr c, .l_1af9
	ld a, $14

.l_1af9:
	ld e, a

.l_1afa:
	ld hl, $1b06
	ld d, $00
	add hl, de
	ld a, [hl]
	ldh [$ff00 + $99], a
	ldh [$ff00 + $9a], a
	ret
	inc [hl]
	jr nc, .l_1b35
	jr z, .l_1b2f
	jr nz, .l_1b28
	dec d
	stop
	ld a, [bc]
	add hl, bc
	ld [$0607], sp
	dec b
	dec b
	inc b
	inc b
	inc bc
	inc bc
	ld [bc], a


func_1b1b::
	ld hl, $99c2
	ld de, $1b40
	ld c, $04

.l_1b23:
	ld b, $0a
	push hl

.l_1b26:
	ld a, [de]
	ld [hl], a

.l_1b28:
	push hl
	ld a, h
	add a, $30
	ld h, a
	ld a, [de]
	ld [hl], a

.l_1b2f:
	pop hl
	inc l
	inc de
	dec b
	jr nz, .l_1b26

.l_1b35:
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	dec c
	jr nz, .l_1b23
	ret
	add a, l
	cpl
	add a, d
	add a, [hl]
	add a, e
	cpl
	cpl
	add a, b
	add a, d
	add a, l
	cpl
	add a, d
	add a, h
	add a, d
	add a, e
	cpl
	add a, e
	cpl
	add a, a
	cpl
	cpl
	add a, l
	cpl
	add a, e
	cpl
	add a, [hl]
	add a, d
	add a, b
	add a, c
	cpl
	add a, e
	cpl
	add a, [hl]
	add a, e
	cpl
	add a, l
	cpl
	add a, l
	cpl
	cpl


func_1b68::
	ld b, a

.l_1b69:
	dec b
	jr z, .l_1b6f
	add hl, de
	jr .l_1b69

.l_1b6f:
	ldh a, [$ff00 + $04]
	ld b, a

.l_1b72:
	ld a, $80

.l_1b74:
	dec b
	jr z, .l_1b7f
	cp $80
	jr nz, .l_1b72
	ld a, $2f
	jr .l_1b74

.l_1b7f:
	cp $2f
	jr z, .l_1b8b
	ldh a, [$ff00 + $04]
	and $07
	or $80
	jr .l_1b8d

.l_1b8b:
	ldh [$ff00 + $a0], a

.l_1b8d:
	push af
	ld a, l
	and $0f
	cp $0b
	jr nz, .l_1ba0
	ldh a, [$ff00 + $a0]
	cp $2f
	jr z, .l_1ba0
	pop af
	ld a, $2f
	jr .l_1ba1

.l_1ba0:
	pop af

.l_1ba1:
	ld [hl], a
	push hl
	push af
	ldh a, [$ff00 + $c5]
	and a
	jr nz, .l_1bad
	ld de, $3000
	add hl, de

.l_1bad:
	pop af
	ld [hl], a
	pop hl
	inc hl
	ld a, l
	and $0f
	cp $0c
	jr nz, .l_1b6f
	xor a
	ldh [$ff00 + $a0], a
	ld a, h
	and $0f
	cp $0a
	jr z, .l_1bc8

.l_1bc2:
	ld de, $0016
	add hl, de
	jr .l_1b6f

.l_1bc8:
	ld a, l
	cp $2c
	jr nz, .l_1bc2
	ret
	call func_1c0d
	ldh a, [$ff00 + $ab]
	and a
	ret nz
	call func_050c
	call func_0542
	call func_0583
	call func_24bb
	call func_209c
	call func_213e
	call func_25a1
	call func_224d
	call func_1f91
	call func_05b3
	ret

.l_1bf4:
	bit 2, a
	ret z
	ld a, [$c0de]
	xor $01
	ld [$c0de], a
	jr z, .l_1c0a
	ld a, $80

.l_1c03:
	ld [$c210], a
	call func_2696
	ret

.l_1c0a:
	xor a
	jr .l_1c03


func_1c0d::
	ldh a, [$ff00 + $80]
	and $0f
	cp $0f
	jp z, .Screen_Setup
	ldh a, [$ff00 + $e4]
	and a
	ret nz
	ldh a, [$ff00 + $81]
	bit 3, a
	jr z, .l_1bf4
	ldh a, [$ff00 + $c5]
	and a
	jr nz, .l_1c6a
	ld hl, $ff40
	ldh a, [$ff00 + $ab]
	xor $01
	ldh [$ff00 + $ab], a
	jr z, .l_1c5a
	set 3, [hl]
	ld a, $01
	ld [$df7f], a
	ld hl, $994e
	ld de, $9d4e
	ld b, $04

.l_1c3f:
	ldh a, [$ff00 + $41]
	and $03
	jr nz, .l_1c3f
	ldi a, [hl]
	ld [de], a
	inc de
	dec b
	jr nz, .l_1c3f
	ld a, $80

.l_1c4d:
	ld [$c210], a

.l_1c50:
	ld [$c200], a
	call func_2683
	call func_2696
	ret

.l_1c5a:
	res 3, [hl]
	ld a, $02
	ld [$df7f], a
	ld a, [$c0de]
	and a
	jr z, .l_1c4d
	xor a
	jr .l_1c50

.l_1c6a:
	ldh a, [$ff00 + $cb]
	cp $29
	ret nz
	ldh a, [$ff00 + $ab]
	xor $01
	ldh [$ff00 + $ab], a
	jr z, .l_1caa
	ld a, $01
	ld [$df7f], a
	ldh a, [$ff00 + $d0]
	ldh [$ff00 + $f2], a
	ldh a, [$ff00 + $cf]
	ldh [$ff00 + $f1], a
	call func_1ccb
	ret


func_1c88::
	ldh a, [$ff00 + $ab]
	and a
	ret z
	ldh a, [$ff00 + $cc]
	jr z, .l_1cc9
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, .l_1ca1
	ld a, $94
	ldh [$ff00 + $cf], a
	ldh [$ff00 + $ce], a
	pop hl
	ret

.l_1ca1:
	xor a
	ldh [$ff00 + $cf], a
	ldh a, [$ff00 + $d0]
	cp $94
	jr z, .l_1cc9

.l_1caa:
	ldh a, [$ff00 + $f2]
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $f1]
	ldh [$ff00 + $cf], a
	ld a, $02
	ld [$df7f], a
	xor a
	ldh [$ff00 + $ab], a
	ld hl, $98ee
	ld b, $8e
	ld c, $05

.l_1cc1:
	call func_19ff
	inc l
	dec c
	jr nz, .l_1cc1
	ret

.l_1cc9:
	pop hl
	ret


func_1ccb::
	ld hl, $98ee
	ld c, $05
	ld de, $1cdd

.l_1cd3:
	ld a, [de]
	call func_19fe
	inc de
	inc l
	dec c
	jr nz, .l_1cd3
	ret
	add hl, de
	ld a, [bc]
	ld e, $1c
	ld c, $3e
	add a, b
	ld [$c200], a
	ld [$c210], a
	call func_2683
	call func_2696
	xor a
	ldh [$ff00 + $98], a
	ldh [$ff00 + $9c], a
	call func_2293
	ld a, $87
	call func_1fd7
	ld a, $46
	ldh [$ff00 + $a6], a
	ld a, $0d
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $81]
	bit 0, a
	jr nz, .l_1d0f
	bit 3, a
	ret z

.l_1d0f:
	xor a
	ldh [$ff00 + $e3], a
	ldh a, [$ff00 + $c5]
	and a
	ld a, $16
	jr nz, .l_1d23
	ldh a, [$ff00 + $c0]
	cp $37
	ld a, $10
	jr z, .l_1d23
	ld a, $12

.l_1d23:
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld hl, $c802
	ld de, $2889
	call func_2804
	ldh a, [$ff00 + $c3]
	and a
	jr z, .l_1d66
	ld de, $0040
	ld hl, $c827
	call func_1d84
	ld de, $0100
	ld hl, $c887
	call func_1d84
	ld de, $0300
	ld hl, $c8e7
	call func_1d84
	ld de, $1200
	ld hl, $c947
	call func_1d84
	ld hl, $c0a0
	ld b, $03
	xor a

.l_1d62:
	ldi [hl], a
	dec b
	jr nz, .l_1d62

.l_1d66:
	ld a, $80
	ldh [$ff00 + $a6], a
	ld a, $80
	ld [$c200], a
	ld [$c210], a
	call func_2683
	call func_2696
	call func_7ff3
	ld a, $25
	ldh [$ff00 + $9e], a
	ld a, $0b
	ldh [$ff00 + $e1], a
	ret


func_1d84::
	push hl
	ld hl, $c0a0
	ld b, $03
	xor a

.l_1d8b:
	ldi [hl], a
	dec b
	jr nz, .l_1d8b
	ldh a, [$ff00 + $c3]
	ld b, a
	inc b

.l_1d93:
	ld hl, $c0a0
	call func_0166
	dec b
	jr nz, .l_1d93
	pop hl
	ld b, $03
	ld de, $c0a2

.l_1da2:
	ld a, [de]
	and $f0
	jr nz, .l_1db1
	ld a, [de]
	and $0f
	jr nz, .l_1db7
	dec e
	dec b
	jr nz, .l_1da2
	ret

.l_1db1:
	ld a, [de]
	and $f0
	swap a
	ldi [hl], a

.l_1db7:
	ld a, [de]
	and $0f
	ldi [hl], a
	dec e
	dec b
	jr nz, .l_1db1
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld a, $01
	ld [$c0c6], a
	ld a, $05
	ldh [$ff00 + $a6], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld hl, $c802
	ld de, $510f
	call func_2804
	call func_178a
	ld hl, $c200
	ld de, $2735
	ld c, $0a
	call func_1776
	ld a, $10
	ld hl, $c266
	ld [hl], a
	ld l, $76
	ld [hl], a
	ld hl, $c20e
	ld de, $1e31
	ld b, $0a

.l_1dfa:
	ld a, [de]
	ldi [hl], a
	ldi [hl], a
	inc de
	push de
	ld de, $000e
	add hl, de
	pop de
	dec b
	jr nz, .l_1dfa
	ldh a, [$ff00 + $c4]
	cp $05
	jr nz, .l_1e0f
	ld a, $09

.l_1e0f:
	inc a
	ld b, a
	ld hl, $c200
	ld de, $0010
	xor a

.l_1e18:
	ld [hl], a
	add hl, de
	dec b
	jr nz, .l_1e18
	ldh a, [$ff00 + $c4]
	add a, $0a
	ld [$dfe8], a
	ld a, $25
	ldh [$ff00 + $9e], a
	ld a, $1b
	ldh [$ff00 + $a6], a
	ld a, $23
	ldh [$ff00 + $e1], a
	ret
	inc e
	rrc a
	ld e, $32
	jr nz, .l_1e4f
	ld h, $1d
	jr z, .l_1e66

.l_1e3b:
	ld a, $0a
	call func_2673
	ret
	ldh a, [$ff00 + $a6]
	cp $14
	jr z, .l_1e3b
	and a
	ret nz
	ld hl, $c20e
	ld de, $0010

.l_1e4f:
	ld b, $0a

.l_1e51:
	push hl
	dec [hl]
	jr nz, .l_1e6a
	inc l
	ldd a, [hl]
	ld [hl], a
	ld a, l
	and $f0
	or $03
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	cp $50
	jr z, .l_1e89

.l_1e66:
	cp $51
	jr z, .l_1e8f

.l_1e6a:
	pop hl
	add hl, de
	dec b
	jr nz, .l_1e51
	ld a, $0a
	call func_2673
	ld a, [$dfe9]
	and a
	ret nz
	call func_178a
	ldh a, [$ff00 + $c4]
	cp $05
	ld a, $26
	jr z, .l_1e86
	ld a, $05

.l_1e86:
	ldh [$ff00 + $e1], a
	ret

.l_1e89:
	dec l
	dec l
	ld [hl], $67
	jr .l_1e6a

.l_1e8f:
	dec l
	dec l
	ld [hl], $5d
	jr .l_1e6a

.l_1e95:
	xor a
	ld [$c0c6], a
	ld de, $c0c0
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	or l
	jp z, .l_263a
	dec hl
	ld a, h
	ld [de], a
	dec de
	ld a, l
	ld [de], a
	ld de, $0001
	ld hl, $c0c2
	push de
	call func_0166
	ld de, $c0c4
	ld hl, $99a5
	call func_2a36
	xor a
	ldh [$ff00 + $a6], a
	pop de
	ld hl, $c0a0
	call func_0166
	ld de, $c0a2
	ld hl, $9a25
	call func_2a3a
	ld a, $02
	ld [$dfe0], a
	ret
	ld a, [$c0c6]
	and a
	ret z
	ld a, [$c0c5]
	cp $04
	jr z, .l_1e95
	ld de, $0040
	ld bc, $9823
	ld hl, $c0ac
	and a
	jr z, .l_1f12
	ld de, $0100
	ld bc, $9883
	ld hl, $c0b1
	cp $01
	jr z, .l_1f12
	ld de, $0300
	ld bc, $98e3
	ld hl, $c0b6
	cp $02
	jr z, .l_1f12
	ld de, $1200
	ld bc, $9943
	ld hl, $c0bb

.l_1f12:
	call func_25d9
	ret
	ldh a, [$ff00 + $81]
	and a
	ret z
	ld a, $02
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld a, $04
	ld [$dfe8], a
	ldh a, [$ff00 + $c5]
	and a
	jr z, .l_1f37
	ld a, $3f
	ldh [$ff00 + $a6], a
	ld a, $1b
	ldh [$ff00 + $cc], a
	jr .l_1f6e

.l_1f37:
	ld a, $2f
	call func_1fd7
	ld hl, $c843
	ld de, $293e
	ld c, $07
	call func_1f7d
	ld hl, $c983
	ld de, $2976
	ld c, $06
	call func_1f7d
	ldh a, [$ff00 + $c0]
	cp $37
	jr nz, .l_1f6c
	ld hl, $c0a2
	ld a, [hl]
	ld b, $58
	cp $20
	jr nc, .l_1f71
	inc b
	cp $15
	jr nc, .l_1f71
	inc b
	cp $10
	jr nc, .l_1f71

.l_1f6c:
	ld a, $04

.l_1f6e:
	ldh [$ff00 + $e1], a
	ret

.l_1f71:
	ld a, b
	ldh [$ff00 + $f3], a
	ld a, $90
	ldh [$ff00 + $a6], a
	ld a, $34
	ldh [$ff00 + $e1], a
	ret


func_1f7d::
	ld b, $08
	push hl

.l_1f80:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, .l_1f80
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	dec c
	jr nz, $1f7d
	ret


func_1f91::
	ldh a, [$ff00 + $c0]
	cp $37
	ret nz
	ldh a, [$ff00 + $e1]
	and a
	ret nz
	ldh a, [$ff00 + $e3]
	cp $05
	ret nz
	ld hl, $c0ac
	ld bc, $0005
	ld a, [hl]
	ld de, $0040
	and a
	jr nz, .l_1fc3
	add hl, bc
	ld a, [hl]
	ld de, $0100
	and a
	jr nz, .l_1fc3
	add hl, bc
	ld a, [hl]
	ld de, $0300
	and a
	jr nz, .l_1fc3
	add hl, bc
	ld de, $1200
	ld a, [hl]
	and a
	ret z

.l_1fc3:
	ld [hl], $00
	ldh a, [$ff00 + $a9]
	ld b, a
	inc b

.l_1fc9:
	push bc
	push de
	ld hl, $c0a0
	call func_0166
	pop de
	pop bc
	dec b
	jr nz, .l_1fc9
	ret


func_1fd7::
	push af
	ld a, $02
	ldh [$ff00 + $e3], a
	pop af


func_1fdd::
	ld hl, $c802
	ld c, $12
	ld de, $0020

.l_1fe5:
	push hl
	ld b, $0a

.l_1fe8:
	ldi [hl], a
	dec b
	jr nz, .l_1fe8
	pop hl
	add hl, de
	dec c
	jr nz, .l_1fe5
	ret


func_1ff2::
	ld hl, $cbc2
	ld de, $0016
	ld c, $02
	ld a, $2f

.l_1ffc:
	ld b, $0a

.l_1ffe:
	ldi [hl], a
	dec b
	jr nz, .l_1ffe
	add hl, de
	dec c
	jr nz, .l_1ffc
	ret


func_2007::
	ld hl, $c200
	ld [hl], $00
	inc l
	ld [hl], $18
	inc l
	ld [hl], $3f
	inc l
	ld a, [$c213]
	ld [hl], a
	and $fc
	ld c, a
	ldh a, [$ff00 + $e4]
	and a
	jr nz, .l_2024
	ldh a, [$ff00 + $c5]
	and a
	jr z, .l_2041

.l_2024:
	ld h, $c3
	ldh a, [$ff00 + $b0]
	ld l, a
	ld e, [hl]
	inc hl
	ld a, h
	cp $c4
	jr nz, .l_2033
	ld hl, $c300

.l_2033:
	ld a, l
	ldh [$ff00 + $b0], a
	ldh a, [$ff00 + $d3]
	and a
	jr z, .l_2065
	or $80
	ldh [$ff00 + $d3], a
	jr .l_2065

.l_2041:
	ld h, $03

.l_2043:
	ldh a, [$ff00 + $04]
	ld b, a

.l_2046:
	xor a

.l_2047:
	dec b
	jr z, .l_2054
	inc a
	inc a
	inc a
	inc a
	cp $1c
	jr z, .l_2046
	jr .l_2047

.l_2054:
	ld d, a
	ldh a, [$ff00 + $ae]
	ld e, a
	dec h
	jr z, .l_2062
	or d
	or c
	and $fc
	cp c
	jr z, .l_2043

.l_2062:
	ld a, d
	ldh [$ff00 + $ae], a

.l_2065:
	ld a, e
	ld [$c213], a
	call func_2696
	ldh a, [$ff00 + $9a]
	ldh [$ff00 + $99], a
	ret

.l_2071:
	ld a, [$c0c7]
	and a
	jr z, .l_2083
	ldh a, [$ff00 + $81]
	and $b0
	cp $80
	jr nz, .l_20a4
	xor a
	ld [$c0c7], a

.l_2083:
	ldh a, [$ff00 + $a7]
	and a
	jr nz, .l_20b1
	ldh a, [$ff00 + $98]
	and a
	jr nz, .l_20b1
	ldh a, [$ff00 + $e3]
	and a
	jr nz, .l_20b1
	ld a, $03
	ldh [$ff00 + $a7], a
	ld hl, $ffe5
	inc [hl]
	jr .l_20c2


func_209c::
	ldh a, [$ff00 + $80]
	and $b0
	cp $80
	jr z, .l_2071

.l_20a4:
	ld hl, $ffe5
	ld [hl], $00
	ldh a, [$ff00 + $99]
	and a
	jr z, .l_20b5
	dec a
	ldh [$ff00 + $99], a

.l_20b1:
	call func_2683
	ret

.l_20b5:
	ldh a, [$ff00 + $98]
	cp $03
	ret z
	ldh a, [$ff00 + $e3]
	and a
	ret nz
	ldh a, [$ff00 + $9a]
	ldh [$ff00 + $99], a

.l_20c2:
	ld hl, $c201
	ld a, [hl]
	ldh [$ff00 + $a0], a
	add a, $08
	ld [hl], a
	call func_2683
	call func_2573
	and a
	ret z
	ldh a, [$ff00 + $a0]
	ld hl, $c201
	ld [hl], a
	call func_2683
	ld a, $01
	ldh [$ff00 + $98], a
	ld [$c0c7], a
	ldh a, [$ff00 + $e5]
	and a
	jr z, .l_2103
	ld c, a
	ldh a, [$ff00 + $c0]
	cp $37
	jr z, .l_2126
	ld de, $c0c0
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ld b, $00
	dec c
	add hl, bc
	ld a, h
	ld [de], a
	ld a, l
	dec de
	ld [de], a

.l_2100:
	xor a
	ldh [$ff00 + $e5], a

.l_2103:
	ld a, [$c201]
	cp $18
	ret nz
	ld a, [$c202]
	cp $3f
	ret nz
	ld hl, $fffb
	ld a, [hl]
	cp $01
	jr nz, .l_2124
	call func_7ff3
	ld a, $01
	ldh [$ff00 + $e1], a
	ld a, $02
	ld [$dff0], a
	ret

.l_2124:
	inc [hl]
	ret

.l_2126:
	xor a

.l_2127:
	dec c
	jr z, .l_212e
	inc a
	daa
	jr .l_2127

.l_212e:
	ld e, a
	ld d, $00
	ld hl, $c0a0
	call func_0166
	ld a, $01
	ld [$c0ce], a
	jr .l_2100


func_213e::
	ldh a, [$ff00 + $98]
	cp $02
	ret nz
	ld a, $02
	ld [$dff8], a
	xor a
	ldh [$ff00 + $a0], a
	ld de, $c0a3
	ld hl, $c842
	ld b, $10

.l_2153:
	ld c, $0a
	push hl

.l_2156:
	ldi a, [hl]
	cp $2f
	jp z, .l_21d8
	dec c
	jr nz, .l_2156
	pop hl
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	inc de
	ldh a, [$ff00 + $a0]
	inc a
	ldh [$ff00 + $a0], a

.l_216b:
	push de
	ld de, $0020
	add hl, de
	pop de
	dec b
	jr nz, .l_2153
	ld a, $03
	ldh [$ff00 + $98], a
	dec a
	ldh [$ff00 + $a6], a
	ldh a, [$ff00 + $a0]
	and a
	ret z
	ld b, a
	ld hl, $ff9e
	ldh a, [$ff00 + $c0]
	cp $77
	jr z, .l_219b
	ld a, b
	add a, [hl]
	daa
	ldi [hl], a
	ld a, $00
	adc a, [hl]
	daa
	ld [hl], a
	jr nc, .l_21aa
	ld [hl], $99
	dec hl
	ld [hl], $99
	jr .l_21aa

.l_219b:
	ld a, [hl]
	or a
	sub a, b
	jr z, .l_21db
	jr c, .l_21db
	daa
	ld [hl], a
	and $f0
	cp $90
	jr z, .l_21db

.l_21aa:
	ld a, b
	ld c, $06
	ld hl, $c0ac
	ld b, $00
	cp $01
	jr z, .l_21cf
	ld hl, $c0b1
	ld b, $01
	cp $02
	jr z, .l_21cf
	ld hl, $c0b6
	ld b, $02
	cp $03
	jr z, .l_21cf
	ld hl, $c0bb
	ld b, $04
	ld c, $07

.l_21cf:
	inc [hl]
	ld a, b
	ldh [$ff00 + $dc], a
	ld a, c
	ld [$dfe0], a
	ret

.l_21d8:
	pop hl
	jr .l_216b

.l_21db:
	xor a
	ldh [$ff00 + $9e], a
	jr .l_21aa
	ldh a, [$ff00 + $98]
	cp $03
	ret nz
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ld de, $c0a3
	ldh a, [$ff00 + $9c]
	bit 0, a
	jr nz, .l_222e
	ld a, [de]
	and a
	jr z, .l_2248

.l_21f6:
	sub a, $30
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	ldh a, [$ff00 + $9c]
	cp $06
	ld a, $8c
	jr nz, .l_2206
	ld a, $2f

.l_2206:
	ld c, $0a

.l_2208:
	ldi [hl], a
	dec c
	jr nz, .l_2208
	inc de
	ld a, [de]
	and a
	jr nz, .l_21f6

.l_2211:
	ldh a, [$ff00 + $9c]
	inc a
	ldh [$ff00 + $9c], a
	cp $07
	jr z, .l_221f
	ld a, $0a
	ldh [$ff00 + $a6], a
	ret

.l_221f:
	xor a
	ldh [$ff00 + $9c], a
	ld a, $0d
	ldh [$ff00 + $a6], a
	ld a, $01
	ldh [$ff00 + $e3], a

.l_222a:
	xor a
	ldh [$ff00 + $98], a
	ret

.l_222e:
	ld a, [de]
	ld h, a
	sub a, $30
	ld c, a
	inc de
	ld a, [de]
	ld l, a
	ld b, $0a

.l_2238:
	ld a, [hl]
	push hl
	ld h, c
	ld [hl], a
	pop hl
	inc hl
	dec b
	jr nz, .l_2238
	inc de
	ld a, [de]
	and a
	jr nz, .l_222e
	jr .l_2211

.l_2248:
	call func_2007
	jr .l_222a


func_224d::
	ldh a, [$ff00 + $a6]
	and a
	ret nz
	ldh a, [$ff00 + $e3]
	cp $01
	ret nz
	ld de, $c0a3
	ld a, [de]

.l_225a:
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	push de
	push hl
	ld bc, $ffe0
	add hl, bc
	pop de

.l_2265:
	push hl
	ld b, $0a

.l_2268:
	ldi a, [hl]
	ld [de], a
	inc de
	dec b
	jr nz, .l_2268
	pop hl
	push hl
	pop de
	ld bc, $ffe0
	add hl, bc
	ld a, h
	cp $c7
	jr nz, .l_2265
	pop de
	inc de
	ld a, [de]
	and a
	jr nz, .l_225a
	ld hl, $c802
	ld a, $2f
	ld b, $0a

.l_2287:
	ldi [hl], a
	dec b
	jr nz, .l_2287
	call func_2293
	ld a, $02
	ldh [$ff00 + $e3], a
	ret


func_2293::
	ld hl, $c0a3
	xor a
	ld b, $09

.l_2299:
	ldi [hl], a
	dec b
	jr nz, .l_2299
	ret
	ldh a, [$ff00 + $e3]
	cp $02
	ret nz
	ld hl, $9a22
	ld de, $ca22
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $03
	ret nz
	ld hl, $9a02
	ld de, $ca02
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $04
	ret nz
	ld hl, $99e2
	ld de, $c9e2
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $05
	ret nz
	ld hl, $99c2
	ld de, $c9c2
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $06
	ret nz
	ld hl, $99a2
	ld de, $c9a2
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $07
	ret nz
	ld hl, $9982
	ld de, $c982
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $08
	ret nz
	ld hl, $9962
	ld de, $c962
	call func_24ac
	ldh a, [$ff00 + $c5]
	and a
	ldh a, [$ff00 + $e1]
	jr nz, .l_2315
	and a
	ret nz

.l_230f:
	ld a, $01
	ld [$dff8], a
	ret

.l_2315:
	cp $1a
	ret nz
	ldh a, [$ff00 + $d4]
	and a
	jr z, .l_230f
	ld a, $05
	ld [$dfe0], a
	ret
	ldh a, [$ff00 + $e3]
	cp $09
	ret nz
	ld hl, $9942
	ld de, $c942
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $0a
	ret nz
	ld hl, $9922
	ld de, $c922
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $0b
	ret nz
	ld hl, $9902
	ld de, $c902
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $0c
	ret nz
	ld hl, $98e2
	ld de, $c8e2
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $0d
	ret nz
	ld hl, $98c2
	ld de, $c8c2
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $0e
	ret nz
	ld hl, $98a2
	ld de, $c8a2
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $0f
	ret nz
	ld hl, $9882
	ld de, $c882
	call func_24ac
	ret
	ldh a, [$ff00 + $e3]
	cp $10
	ret nz
	ld hl, $9862
	ld de, $c862
	call func_24ac
	call func_244b
	ret
	ldh a, [$ff00 + $e3]
	cp $11
	ret nz
	ld hl, $9842
	ld de, $c842
	call func_24ac
	ld hl, $9c6d
	call func_243b
	ld a, $01
	ldh [$ff00 + $e0], a
	ret
	ldh a, [$ff00 + $e3]
	cp $12
	ret nz
	ld hl, $9822
	ld de, $c822
	call func_24ac
	ld hl, $986d
	call func_243b
	ret
	ldh a, [$ff00 + $e3]
	cp $13
	ret nz
	ld [$c0c7], a
	ld hl, $9802
	ld de, $c802
	call func_24ac
	xor a
	ldh [$ff00 + $e3], a
	ldh a, [$ff00 + $c5]
	and a
	ldh a, [$ff00 + $e1]
	jr nz, .l_242f
	and a
	ret nz

.l_23e9:
	ld hl, $994e
	ld de, $ff9f
	ld c, $02
	ldh a, [$ff00 + $c0]
	cp $37
	jr z, .l_23ff
	ld hl, $9950
	ld de, $ff9e
	ld c, $01

.l_23ff:
	call func_2a3c
	ldh a, [$ff00 + $c0]
	cp $37
	jr z, .l_242b
	ldh a, [$ff00 + $9e]
	and a
	jr nz, .l_242b
	ld a, $64
	ldh [$ff00 + $a6], a
	ld a, $02
	ld [$dfe8], a
	ldh a, [$ff00 + $c5]
	and a
	jr z, .l_241e
	ldh [$ff00 + $d5], a
	ret

.l_241e:
	ldh a, [$ff00 + $c3]
	cp $09
	ld a, $05
	jr nz, .l_2428
	ld a, $22

.l_2428:
	ldh [$ff00 + $e1], a
	ret

.l_242b:
	call func_2007
	ret

.l_242f:
	cp $1a
	ret nz
	ldh a, [$ff00 + $d4]
	and a
	jr z, .l_23e9
	xor a
	ldh [$ff00 + $d4], a
	ret


func_243b::
	ldh a, [$ff00 + $e1]
	and a
	ret nz
	ldh a, [$ff00 + $c0]
	cp $37
	ret nz
	ld de, $c0a2
	call func_2a36
	ret


func_244b::
	ldh a, [$ff00 + $e1]
	and a
	ret nz
	ldh a, [$ff00 + $c0]
	cp $37
	ret nz
	ld hl, $ffa9
	ld a, [hl]
	cp $14
	ret z
	call func_249d
	ldh a, [$ff00 + $9f]
	ld d, a
	and $f0
	ret nz
	ld a, d
	and $0f
	swap a
	ld d, a
	ldh a, [$ff00 + $9e]
	and $f0
	swap a
	or d
	cp b
	ret c
	ret z
	inc [hl]
	call func_249d
	and $0f
	ld c, a
	ld hl, $98f1

.l_247e:
	ld [hl], c
	ld h, $9c
	ld [hl], c
	ld a, b
	and $f0
	jr z, .l_2494
	swap a
	ld c, a
	ld a, l
	cp $f0
	jr z, .l_2494
	ld hl, $98f0
	jr .l_247e

.l_2494:
	ld a, $08
	ld [$dfe0], a
	call func_1ae8
	ret


func_249d::
	ld a, [hl]
	ld b, a
	and a
	ret z
	xor a

.l_24a2:
	or a
	inc a
	daa
	dec b
	jr z, .l_24aa
	jr .l_24a2

.l_24aa:
	ld b, a
	ret


func_24ac::
	ld b, $0a

.l_24ae:
	ld a, [de]
	ld [hl], a
	inc l
	inc e
	dec b
	jr nz, .l_24ae
	ldh a, [$ff00 + $e3]
	inc a
	ldh [$ff00 + $e3], a
	ret


func_24bb::
	ld hl, $c200
	ld a, [hl]
	cp $80
	ret z
	ld l, $03
	ld a, [hl]
	ldh [$ff00 + $a0], a
	ldh a, [$ff00 + $81]
	ld b, a
	bit 1, b
	jr nz, .l_24e0
	bit 0, b
	jr z, .l_2509
	ld a, [hl]
	and $03
	jr z, .l_24da
	dec [hl]
	jr .l_24ee

.l_24da:
	ld a, [hl]
	or $03
	ld [hl], a
	jr .l_24ee

.l_24e0:
	ld a, [hl]
	and $03
	cp $03
	jr z, .l_24ea
	inc [hl]
	jr .l_24ee

.l_24ea:
	ld a, [hl]
	and $fc
	ld [hl], a

.l_24ee:
	ld a, $03
	ld [$dfe0], a
	call func_2683
	call func_2573
	and a
	jr z, .l_2509
	xor a
	ld [$dfe0], a
	ld hl, $c203
	ldh a, [$ff00 + $a0]
	ld [hl], a
	call func_2683

.l_2509:
	ld hl, $c202
	ldh a, [$ff00 + $81]
	ld b, a
	ldh a, [$ff00 + $80]
	ld c, a
	ld a, [hl]
	ldh [$ff00 + $a0], a
	bit 4, b
	ld a, $17
	jr nz, .l_2527
	bit 4, c
	jr z, .l_254c
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

.l_2527:
	ldh [$ff00 + $aa], a
	ld a, [hl]
	add a, $08
	ld [hl], a
	call func_2683
	ld a, $04
	ld [$dfe0], a
	call func_2573
	and a
	ret z

.l_253a:
	ld hl, $c202
	xor a
	ld [$dfe0], a
	ldh a, [$ff00 + $a0]
	ld [hl], a
	call func_2683
	ld a, $01

.l_2549:
	ldh [$ff00 + $aa], a
	ret

.l_254c:
	bit 5, b
	ld a, $17
	jr nz, .l_255e
	bit 5, c
	jr z, .l_2549
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

.l_255e:
	ldh [$ff00 + $aa], a
	ld a, [hl]
	sub a, $08
	ld [hl], a
	ld a, $04
	ld [$dfe0], a
	call func_2683
	call func_2573
	and a
	ret z
	jr .l_253a


func_2573::
	ld hl, $c010
	ld b, $04

.l_2578:
	ldi a, [hl]
	ldh [$ff00 + $b2], a
	ldi a, [hl]
	and a
	jr z, .l_2596
	ldh [$ff00 + $b3], a
	push hl
	push bc
	call func_29e3
	ld a, h
	add a, $30
	ld h, a
	ld a, [hl]
	cp $2f
	jr nz, .l_259a
	pop bc
	pop hl
	inc l
	inc l
	dec b
	jr nz, .l_2578

.l_2596:
	xor a
	ldh [$ff00 + $9b], a
	ret

.l_259a:
	pop bc
	pop hl
	ld a, $01
	ldh [$ff00 + $9b], a
	ret


func_25a1::
	ldh a, [$ff00 + $98]
	cp $01
	ret nz
	ld hl, $c010
	ld b, $04

.l_25ab:
	ldi a, [hl]
	ldh [$ff00 + $b2], a
	ldi a, [hl]
	and a
	jr z, .l_25cf
	ldh [$ff00 + $b3], a
	push hl
	push bc
	call func_29e3
	push hl
	pop de
	pop bc
	pop hl

.l_25bd:
	ldh a, [$ff00 + $41]
	and $03
	jr nz, .l_25bd
	ld a, [hl]
	ld [de], a
	ld a, d
	add a, $30
	ld d, a
	ldi a, [hl]
	ld [de], a
	inc l
	dec b
	jr nz, .l_25ab

.l_25cf:
	ld a, $02
	ldh [$ff00 + $98], a
	ld hl, $c200
	ld [hl], $80
	ret


func_25d9::
	ld a, [$c0c6]
	cp $02
	jr z, .l_2626
	push de
	ld a, [hl]
	or a
	jr z, .l_2639
	dec a
	ldi [hl], a
	ld a, [hl]
	inc a
	daa
	ld [hl], a
	and $0f
	ld [bc], a
	dec c
	ldi a, [hl]
	swap a
	and $0f
	jr z, .l_25f7
	ld [bc], a

.l_25f7:
	push bc
	ldh a, [$ff00 + $c3]
	ld b, a
	inc b

.l_25fc:
	push hl
	call func_0166
	pop hl
	dec b
	jr nz, .l_25fc
	pop bc
	inc hl
	inc hl
	push hl
	ld hl, $0023
	add hl, bc
	pop de
	call func_2a3a
	pop de
	ldh a, [$ff00 + $c3]
	ld b, a
	inc b
	ld hl, $c0a0

.l_2618:
	push hl
	call func_0166
	pop hl
	dec b
	jr nz, .l_2618
	ld a, $02
	ld [$c0c6], a
	ret

.l_2626:
	ld de, $c0a2
	ld hl, $9a25
	call func_2a3a
	ld a, $02
	ld [$dfe0], a
	xor a
	ld [$c0c6], a
	ret

.l_2639:
	pop de

.l_263a:
	ld a, $21
	ldh [$ff00 + $a6], a
	xor a
	ld [$c0c6], a
	ld a, [$c0c5]
	inc a
	ld [$c0c5], a
	cp $05
	ret nz
	ld a, $04
	ldh [$ff00 + $e1], a
	ret


func_2651::
	ld hl, $c0ac
	ld b, $1b
	xor a

.l_2657:
	ldi [hl], a
	dec b
	jr nz, .l_2657
	ld hl, $c0a0
	ld b, $03

.l_2660:
	ldi [hl], a
	dec b
	jr nz, .l_2660
	ret
	ld a, [hl]
	and $f0
	swap a
	ld [de], a
	ld a, [hl]
	and $0f
	inc e
	ld [de], a
	ret


func_2671::
	ld a, $02


func_2673::
	ldh [$ff00 + $8f], a
	xor a
	ldh [$ff00 + $8e], a
	ld a, $c0
	ldh [$ff00 + $8d], a
	ld hl, $c200
	call func_2a89
	ret


func_2683::
	ld a, $01
	ldh [$ff00 + $8f], a
	ld a, $10
	ldh [$ff00 + $8e], a
	ld a, $c0
	ldh [$ff00 + $8d], a
	ld hl, $c200
	call func_2a89
	ret


func_2696::
	ld a, $01
	ldh [$ff00 + $8f], a
	ld a, $20
	ldh [$ff00 + $8e], a
	ld a, $c0
	ldh [$ff00 + $8d], a
	ld hl, $c210
	call func_2a89
	ret


func_26a9::
	ld b, $20
	ld a, $8e
	ld de, $0020

.l_26b0:
	ld [hl], a
	add hl, de
	dec b
	jr nz, .l_26b0
	ret


func_26b6::
	ld a, [de]
	cp $ff
	ret z
	ldi [hl], a
	inc de
	jr $26b6
	reti
	nop
	jr .l_2701
	nop
	add a, b
	nop
	nop
	rst 38
	nop
	add a, b
	adc a, a
	nop
	add a, b
	nop
	nop
	rst 38
	nop
	ld [hl], b
	scf
	inc e
	nop
	nop
	nop
	jr c, .l_270f
	inc e
	nop
	nop
	nop
	ld b, b
	inc [hl]
	jr nz, .l_26e0

.l_26e0:
	nop
	nop
	ld b, b
	inc e
	jr nz, .l_26e6

.l_26e6:
	nop
	nop
	ld b, b
	ld [hl], h
	jr nz, .l_26ec

.l_26ec:
	nop
	nop
	ld b, b
	ld l, b
	ld hl, $0000
	nop
	ld a, b
	ld l, b
	ld hl, $0000
	nop
	ld h, b
	ld h, b
	ldi a, [hl]
	add a, b
	nop
	nop
	ld h, b

.l_2701:
	ld [hl], d
	ldi a, [hl]
	add a, b
	jr nz, .l_2706

.l_2706:
	ld l, b
	jr c, .l_2747
	add a, b
	nop
	nop
	ld h, b
	ld h, b
	ld [hl], $80
	nop
	nop
	ld h, b
	ld [hl], d
	ld [hl], $80
	jr nz, .l_2718

.l_2718:
	ld l, b
	jr c, .l_274d
	add a, b
	nop
	nop
	ld h, b
	ld h, b
	ld l, $80
	nop
	nop
	ld l, b
	jr c, .l_2763
	add a, b
	nop
	nop
	ld h, b
	ld h, b
	ldd a, [hl]
	add a, b
	nop
	nop
	ld l, b
	jr c, .l_2763
	add a, b
	nop
	add a, b
	ccf
	ld b, b
	ld b, h
	nop
	nop
	add a, b
	ccf
	jr nz, .l_2789
	nop
	nop
	add a, b
	ccf
	jr nc, .l_278b
	nop
	nop

.l_2747:
	add a, b
	ld [hl], a
	jr nz, .l_2793

.l_274b:
	nop
	nop

.l_274d:
	add a, b
	add a, a
	ld c, b
	ld c, h
	nop
	nop
	add a, b
	add a, a
	ld e, b
	ld c, [hl]
	nop
	nop
	add a, b
	ld h, a
	ld c, l
	ld d, b
	nop
	nop
	add a, b
	ld h, a
	ld e, l
	ld d, d

.l_2763:
	nop
	nop
	add a, b
	adc a, a
	adc a, b
	ld d, h
	nop
	nop
	add a, b
	adc a, a
	sbc a, b
	ld d, l
	nop
	nop
	nop
	ld e, a
	ld d, a
	inc l
	nop
	nop
	add a, b
	add a, b
	ld d, b
	inc [hl]
	nop
	nop
	add a, b
	add a, b
	ld h, b
	inc [hl]
	nop
	jr nz, .l_2784

.l_2784:
	ld l, a
	ld d, a
	ld e, b
	nop
	nop

.l_2789:
	add a, b
	add a, b

.l_278b:
	ld d, l
	inc [hl]
	nop
	nop
	add a, b
	add a, b
	ld e, e
	inc [hl]

.l_2793:
	nop
	jr nz, .l_27b7
	rst 38
	sbc a, e


func_2798::
	ld bc, $0400

.l_279b:
	ld a, $2f
	ldd [hl], a
	dec bc
	ld a, b
	or c
	jr nz, .l_279b
	ret


func_27a4::
	ldi a, [hl]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, $27a4
	ret


func_27ad::
	call func_27c3
	ld bc, $00a0
	call func_27a4
	ld hl, $323f
	ld de, $8300
	ld bc, $0d00
	call func_27a4
	ret


func_27c3::
	ld hl, $415f
	ld bc, $0138
	ld de, $8000

.l_27cc:
	ldi a, [hl]
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .l_27cc
	ret


func_27d7::
	call func_27c3
	ld bc, $0da0
	call func_27a4
	ret
	ld bc, $1000


func_27e4::
	ld de, $8000
	call func_27a4
	ret


func_27eb::
	ld hl, $9800


func_27ee::
	ld b, $12


func_27f0::
	push hl
	ld c, $14

.l_27f3:
	ld a, [de]
	ldi [hl], a
	inc de
	dec c
	jr nz, .l_27f3
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	dec b
	jr nz, $27f0
	ret


func_2804::
	ld b, $0a
	push hl

.l_2807:
	ld a, [de]
	cp $ff
	jr z, .l_281a
	ldi [hl], a
	inc de
	dec b
	jr nz, .l_2807
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	jr $2804

.l_281a:
	pop hl
	ld a, $02
	ldh [$ff00 + $e3], a
	ret


func_2820::
	ldh a, [$ff00 + $ff]
	ldh [$ff00 + $a1], a
	res 0, a
	ldh [$ff00 + $ff], a

.l_2828:
	ldh a, [$ff00 + $44]
	cp $91
	jr nz, .l_2828
	ldh a, [$ff00 + $40]
	and $7f
	ldh [$ff00 + $40], a
	ldh a, [$ff00 + $a1]
	ldh [$ff00 + $ff], a
	ret
	cpl
	cpl
	ld de, $1d12
	cpl
	cpl
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	cpl
	inc e
	dec e
	ld a, [bc]
	dec de
	dec e
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	cpl
	cpl
	dec e
	jr .l_288e
	cpl
	cpl
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	inc c
	jr .l_2883
	dec e
	ld [de], a
	rl a
	ld e, $0e
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	stop
	ld a, [bc]
	ld d, $0e
	cpl
	cpl
	cpl
	cpl

.l_2883:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	inc e
	ld [de], a
	rl a
	stop
	dec d

.l_288e:
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	inc b
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec c
	jr .l_28c8
	dec bc
	dec d
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	ld bc, $0000
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec e
	dec de
	ld [de], a

.l_28c8:
	add hl, de
	dec d
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	inc bc
	nop
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec e
	ld c, $1d
	dec de
	ld [de], a
	inc e
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	ld bc, $0002
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec c
	dec de
	jr .l_291e
	inc e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl

.l_291e:
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	dec e
	ld de, $1c12
	cpl
	inc e
	dec e
	ld a, [bc]
	stop
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	rst 38
	ld h, c
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, e
	ld h, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld h, l
	ld h, h
	cpl
	stop
	ld a, [bc]
	ld d, $0e
	cpl
	ld h, l
	ld h, h
	cpl
	xor l
	xor l
	xor l
	xor l
	cpl
	ld h, l
	ld h, h
	cpl
	jr .l_2981
	ld c, $1b
	cpl
	ld h, l
	ld h, h
	cpl
	xor l
	xor l
	xor l
	xor l
	cpl
	ld h, l
	ld h, [hl]
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, d
	add hl, de
	dec d
	ld c, $0a
	inc e
	ld c, $2f
	cpl
	add hl, hl
	add hl, hl
	add hl, hl

.l_2981:
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	dec e
	dec de
	ldi [hl], a
	cpl
	cpl
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, [bc]
	stop
	ld a, [bc]
	ld [de], a
	rl a
	daa
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl


func_29a6::
	ld a, $20
	ldh [$ff00 + $00], a
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	cpl
	and $0f
	swap a
	ld b, a
	ld a, $10
	ldh [$ff00 + $00], a
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	ldh a, [$ff00 + $00]
	cpl
	and $0f
	or b
	ld c, a
	ldh a, [$ff00 + $80]
	xor c
	and c
	ldh [$ff00 + $81], a
	ld a, c
	ldh [$ff00 + $80], a
	ld a, $30
	ldh [$ff00 + $00], a
	ret


func_29e3::
	ldh a, [$ff00 + $b2]
	sub a, $10
	srl a
	srl a
	srl a
	ld de, $0000
	ld e, a
	ld hl, $9800
	ld b, $20

.l_29f6:
	add hl, de
	dec b
	jr nz, .l_29f6
	ldh a, [$ff00 + $b3]
	sub a, $08
	srl a
	srl a
	srl a
	ld de, $0000
	ld e, a
	add hl, de
	ld a, h
	ldh [$ff00 + $b5], a
	ld a, l
	ldh [$ff00 + $b4], a
	ret
	ldh a, [$ff00 + $b5]
	ld d, a
	ldh a, [$ff00 + $b4]
	ld e, a
	ld b, $04

.l_2a18:
	rr d
	rr e
	dec b
	jr nz, .l_2a18
	ld a, e
	sub a, $84
	and $fe
	rlc a
	rlc a
	add a, $08
	ldh [$ff00 + $b2], a
	ldh a, [$ff00 + $b4]
	and $1f
	rl a
	rl a
	rl a
	add a, $08
	ldh [$ff00 + $b3], a
	ret


func_2a36::
	ldh a, [$ff00 + $e0]
	and a
	ret z


func_2a3a::
	ld c, $03


func_2a3c::
	xor a
	ldh [$ff00 + $e0], a

.l_2a3f:
	ld a, [de]
	ld b, a
	swap a
	and $0f
	jr nz, .l_2a6f
	ldh a, [$ff00 + $e0]
	and a
	ld a, $00
	jr nz, .l_2a50
	ld a, $2f

.l_2a50:
	ldi [hl], a
	ld a, b
	and $0f
	jr nz, .l_2a77
	ldh a, [$ff00 + $e0]
	and a
	ld a, $00
	jr nz, .l_2a66
	ld a, $01
	cp c
	ld a, $00
	jr z, .l_2a66
	ld a, $2f

.l_2a66:
	ldi [hl], a
	dec e
	dec c
	jr nz, .l_2a3f
	xor a
	ldh [$ff00 + $e0], a
	ret

.l_2a6f:
	push af
	ld a, $01
	ldh [$ff00 + $e0], a
	pop af
	jr .l_2a50

.l_2a77:
	push af
	ld a, $01
	ldh [$ff00 + $e0], a
	pop af
	jr .l_2a66
	ld a, $c0
	ldh [$ff00 + $46], a
	ld a, $28

.l_2a85:
	dec a
	jr nz, .l_2a85
	ret


func_2a89::
	ld a, h
	ldh [$ff00 + $96], a
	ld a, l
	ldh [$ff00 + $97], a
	ld a, [hl]
	and a
	jr z, .l_2ab0
	cp $80
	jr z, .l_2aae

.l_2a97:
	ldh a, [$ff00 + $96]
	ld h, a
	ldh a, [$ff00 + $97]
	ld l, a
	ld de, $0010
	add hl, de
	ldh a, [$ff00 + $8f]
	dec a
	ldh [$ff00 + $8f], a
	ret z
	jr $2a89

.l_2aa9:
	xor a
	ldh [$ff00 + $95], a
	jr .l_2a97

.l_2aae:
	ldh [$ff00 + $95], a

.l_2ab0:
	ld b, $07
	ld de, $ff86

.l_2ab5:
	ldi a, [hl]
	ld [de], a
	inc de
	dec b
	jr nz, .l_2ab5
	ldh a, [$ff00 + $89]
	ld hl, $2b64
	rlc a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ldh [$ff00 + $90], a
	inc de
	ld a, [de]
	ldh [$ff00 + $91], a
	ld e, [hl]
	inc hl
	ld d, [hl]

.l_2ad8:
	inc hl
	ldh a, [$ff00 + $8c]
	ldh [$ff00 + $94], a
	ld a, [hl]
	cp $ff
	jr z, .l_2aa9
	cp $fd
	jr nz, .l_2af4
	ldh a, [$ff00 + $8c]
	xor $20
	ldh [$ff00 + $94], a
	inc hl
	ld a, [hl]
	jr .l_2af8

.l_2af0:
	inc de
	inc de
	jr .l_2ad8

.l_2af4:
	cp $fe
	jr z, .l_2af0

.l_2af8:
	ldh [$ff00 + $89], a
	ldh a, [$ff00 + $87]
	ld b, a
	ld a, [de]
	ld c, a
	ldh a, [$ff00 + $8b]
	bit 6, a
	jr nz, .l_2b0b
	ldh a, [$ff00 + $90]
	add a, b
	adc a, c
	jr .l_2b15

.l_2b0b:
	ld a, b
	push af
	ldh a, [$ff00 + $90]
	ld b, a
	pop af
	sub a, b
	sbc a, c
	sbc a, $08

.l_2b15:
	ldh [$ff00 + $93], a
	ldh a, [$ff00 + $88]
	ld b, a
	inc de
	ld a, [de]
	inc de
	ld c, a
	ldh a, [$ff00 + $8b]
	bit 5, a
	jr nz, .l_2b2a
	ldh a, [$ff00 + $91]
	add a, b
	adc a, c
	jr .l_2b34

.l_2b2a:
	ld a, b
	push af
	ldh a, [$ff00 + $91]
	ld b, a
	pop af
	sub a, b
	sbc a, c
	sbc a, $08

.l_2b34:
	ldh [$ff00 + $92], a
	push hl
	ldh a, [$ff00 + $8d]
	ld h, a
	ldh a, [$ff00 + $8e]
	ld l, a
	ldh a, [$ff00 + $95]
	and a
	jr z, .l_2b46
	ld a, $ff
	jr .l_2b48

.l_2b46:
	ldh a, [$ff00 + $93]

.l_2b48:
	ldi [hl], a
	ldh a, [$ff00 + $92]
	ldi [hl], a
	ldh a, [$ff00 + $89]
	ldi [hl], a
	ldh a, [$ff00 + $94]
	ld b, a
	ldh a, [$ff00 + $8b]
	or b
	ld b, a
	ldh a, [$ff00 + $8a]
	or b
	ldi [hl], a
	ld a, h
	ldh [$ff00 + $8d], a
	ld a, l
	ldh [$ff00 + $8e], a
	pop hl
	jp .l_2ad8
	jr nz, .l_2b92
	inc h
	inc l
	jr z, .l_2b96
	inc l
	inc l
	jr nc, .l_2b9a
	inc [hl]
	inc l
	jr c, .l_2b9e
	inc a
	inc l
	ld b, b
	inc l
	ld b, h
	inc l
	ld c, b
	inc l
	ld c, h
	inc l
	ld d, b
	inc l
	ld d, h
	inc l
	ld e, b
	inc l
	ld e, h
	inc l
	ld h, b
	inc l
	ld h, h
	inc l
	ld l, b
	inc l
	ld l, h

.l_2b8b:
	inc l
	ld [hl], b
	inc l
	ld [hl], h
	inc l
	ld a, b
	inc l

.l_2b92:
	ld a, h
	inc l
	add a, b
	inc l

.l_2b96:
	add a, h
	inc l
	adc a, b
	inc l

.l_2b9a:
	adc a, h
	inc l
	sub a, b
	inc l

.l_2b9e:
	sub a, h
	inc l
	sbc a, b
	inc l
	sbc a, h
	inc l
	and b
	inc l
	and h
	inc l
	xor b
	inc l
	xor h
	inc l
	or b
	inc l
	or h
	inc l
	cp b
	inc l
	cp h
	inc l
	ret nz
	inc l
	call nz, func_c82c

.l_2bb9:
	inc l
	call z, func_c72c
	jr nc, .l_2b8b
	inc l
	ret nc
	inc l
	call nc, func_d82c
	inc l
	call c, func_e02c

.l_2bc9:
	inc l
	<error>
	inc l
	ld [$ee30], a
	jr nc, .l_2bb9
	inc l
	<error>
	inc l
	<error>
	jr nc, .l_2bcd
	jr nc, .l_2bc9
	inc l
	<error>
	inc l
	ldhl sp, d
	inc l
	<error>
	inc l
	nop
	dec l
	inc b
	dec l
	ld a, [$fe30]
	jr nc, .l_2bed
	dec l
	ld [$082d], sp

.l_2bed:
	dec l
	inc c
	dec l
	stop
	dec l
	inc d
	dec l
	jr .l_2c23
	inc e
	dec l
	jr nz, .l_2c27
	inc h
	dec l
	jr z, .l_2c2b
	inc l
	dec l
	jr nc, .l_2c2f
	inc [hl]
	dec l
	jr c, .l_2c33
	inc a
	dec l
	ld b, b
	dec l
	ld b, h
	dec l
	ld c, b
	dec l
	ld c, h
	dec l
	ld d, b
	dec l
	ld d, h
	dec l
	ld a, [bc]
	ld sp, $310e
	ld [de], a
	ld sp, $3112
	ld [bc], a
	ld sp, $3106
	ld e, b
	dec l
	rst 28

.l_2c23:
	ldh a, [$ff00 + $68]
	dec l
	rst 28

.l_2c27:
	ldh a, [$ff00 + $7a]
	dec l
	rst 28

.l_2c2b:
	ldh a, [$ff00 + $89]
	dec l
	rst 28

.l_2c2f:
	ldh a, [$ff00 + $9a]
	dec l
	rst 28

.l_2c33:
	ldh a, [$ff00 + $ac]
	dec l
	rst 28
	ldh a, [$ff00 + $bd]
	dec l
	rst 28
	ldh a, [$ff00 + $cb]
	dec l
	rst 28
	ldh a, [$ff00 + $dc]
	dec l
	rst 28
	ldh a, [$ff00 + $eb]
	dec l
	rst 28
	ldh a, [$ff00 + $fc]
	dec l
	rst 28
	ldh a, [$ff00 + $0b]
	ld l, $ef
	ldh a, [$ff00 + $1c]
	ld l, $ef
	ldh a, [$ff00 + $2e]
	ld l, $ef
	ldh a, [$ff00 + $40]
	ld l, $ef
	ldh a, [$ff00 + $52]
	ld l, $ef
	ldh a, [$ff00 + $64]
	ld l, $ef
	ldh a, [$ff00 + $76]
	ld l, $ef
	ldh a, [$ff00 + $86]
	ld l, $ef
	ldh a, [$ff00 + $98]
	ld l, $ef
	ldh a, [$ff00 + $a8]
	ld l, $ef
	ldh a, [$ff00 + $b9]
	ld l, $ef
	ldh a, [$ff00 + $ca]
	ld l, $ef
	ldh a, [$ff00 + $db]
	ld l, $ef
	ldh a, [$ff00 + $0b]
	cpl
	rst 28
	ldh a, [$ff00 + $1c]
	cpl
	rst 28
	ldh a, [$ff00 + $ec]
	ld l, $ef
	ldh a, [$ff00 + $fa]
	ld l, $ef
	ldh a, [$ff00 + $2d]
	cpl
	nop
	add sp, d
	ld [hl], $2f
	nop
	add sp, d
	ccf
	cpl
	nop
	add sp, d
	ld c, b
	cpl
	nop
	add sp, d
	ld d, c
	cpl
	nop
	nop
	ld d, l
	cpl
	nop
	nop
	ld e, c
	cpl
	nop
	nop
	ld e, l
	cpl
	nop
	nop
	ld h, c
	cpl
	nop
	nop
	ld h, l
	cpl
	nop
	nop
	ld l, c
	cpl
	nop
	nop
	ld l, l
	cpl
	nop
	nop
	ld [hl], c
	cpl
	nop
	nop
	ld [hl], l
	cpl
	nop
	nop
	ld a, c
	cpl
	ldh a, [$ff00 + $f8]
	add a, h
	cpl
	ldh a, [$ff00 + $f8]
	adc a, a
	cpl
	ldh a, [$ff00 + $f0]
	and e
	cpl
	ldh a, [$ff00 + $f0]
	cp b
	cpl
	ldhl sp, d
	ldhl sp, d
	pop bc
	cpl
	ldhl sp, d
	ldhl sp, d
	jp z, .l_f82f
	ldhl sp, d
	pop de
	cpl
	ldhl sp, d

.l_2ce7:
	ldhl sp, d
	ret c
	cpl
	ldh a, [$ff00 + $f8]
	<error>
	cpl
	ldh a, [$ff00 + $f8]
	xor $2f
	ldh a, [$ff00 + $f0]
	inc bc
	jr nc, .l_2ce7

.l_2cf7:
	ldh a, [$ff00 + $19]
	jr nc, .l_2cf3

.l_2cfb:
	ldhl sp, d
	ldi [hl], a
	jr nc, .l_2cf7

.l_2cff:
	ldhl sp, d
	dec hl
	jr nc, .l_2cfb

.l_2d03:
	ldhl sp, d
	ldd [hl], a
	jr nc, .l_2cff

.l_2d07:
	ldhl sp, d
	add hl, sp
	jr nc, .l_2d03

.l_2d0b:
	ldhl sp, d
	ld b, b
	jr nc, .l_2d07

.l_2d0f:
	ldhl sp, d
	ld b, a
	jr nc, .l_2d0b

.l_2d13:
	ldhl sp, d
	ld c, [hl]
	jr nc, .l_2d0f

.l_2d17:
	ldhl sp, d
	ld d, l
	jr nc, .l_2d13

.l_2d1b:
	ldhl sp, d
	ld e, h
	jr nc, .l_2d17

.l_2d1f:
	ldhl sp, d
	ld h, a
	jr nc, .l_2d1b

.l_2d23:
	ldhl sp, d
	ld l, [hl]
	jr nc, .l_2d1f

.l_2d27:
	ldhl sp, d
	ld [hl], l
	jr nc, .l_2d23

.l_2d2b:
	ldhl sp, d
	ld a, h
	jr nc, .l_2d27

.l_2d2f:
	ldhl sp, d
	add a, e
	jr nc, .l_2d2b

.l_2d33:
	ldhl sp, d
	adc a, h
	jr nc, .l_2d2f

.l_2d37:
	ldhl sp, d
	sub a, l
	jr nc, .l_2d33

.l_2d3b:
	ldhl sp, d
	sbc a, [hl]
	jr nc, .l_2d37

.l_2d3f:
	ldhl sp, d
	and a
	jr nc, .l_2d3b

.l_2d43:
	ldhl sp, d
	or b
	jr nc, .l_2d3f

.l_2d47:
	ldhl sp, d
	cp c
	jr nc, .l_2d43
	ldhl sp, d
	ret nz
	jr nc, .l_2d47
	ldhl sp, d
	ld b, [hl]
	ld sp, $f0f0
	ld e, l
	ld sp, $f8f8
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	add a, h
	add a, h
	add a, h
	cp $84
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $84
	cp $fe
	cp $84
	cp $fe
	cp $84
	add a, h
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	add a, h
	cp $84
	add a, h
	add a, h
	cp $ff
	xor c
	ld sp, $fefe
	cp $fe
	add a, h
	add a, h
	cp $fe
	cp $84
	cp $fe
	cp $84
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	add a, c
	add a, c
	add a, c
	cp $fe
	cp $81
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $81
	add a, c
	cp $fe
	add a, c
	cp $fe
	cp $81
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	add a, c
	cp $fe
	cp $81
	add a, c
	add a, c
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $81
	cp $fe
	cp $81
	cp $fe
	add a, c
	add a, c
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	adc a, d
	adc a, e
	adc a, e
	adc a, a
	rst 38
	xor c
	ld sp, $80fe
	cp $fe
	cp $88
	cp $fe
	cp $88
	cp $fe
	cp $89
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	adc a, d
	adc a, e
	adc a, e
	adc a, a
	rst 38
	xor c
	ld sp, $80fe
	cp $fe
	cp $88
	cp $fe
	cp $88
	cp $fe
	cp $89
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	cp $83
	add a, e
	cp $fe
	add a, e
	add a, e
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	cp $83
	add a, e
	cp $fe
	add a, e
	add a, e
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	cp $83
	add a, e
	cp $fe
	add a, e
	add a, e
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	cp $83
	add a, e
	cp $fe
	add a, e
	add a, e
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	add a, d
	add a, d
	cp $fe
	cp $82
	add a, d
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $82
	cp $fe
	add a, d
	add a, d
	cp $fe
	add a, d
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	add a, d
	add a, d
	cp $fe
	cp $82
	add a, d
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $82
	cp $fe
	add a, d
	add a, d
	cp $fe
	add a, d
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	cp $86
	add a, [hl]
	cp $86
	add a, [hl]
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	add a, [hl]
	cp $fe
	cp $86
	add a, [hl]
	cp $fe
	cp $86
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	cp $86
	add a, [hl]
	cp $86
	add a, [hl]
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	add a, [hl]
	cp $fe
	cp $86
	add a, [hl]
	cp $fe
	cp $86
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $85
	cp $fe
	add a, l
	add a, l
	add a, l
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $85
	cp $fe
	add a, l
	add a, l
	cp $fe
	cp $85
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $fe
	cp $fe
	add a, l
	add a, l
	add a, l
	cp $fe
	add a, l
	rst 38
	xor c
	ld sp, $fefe
	cp $fe
	cp $85
	cp $fe
	cp $85
	add a, l
	cp $fe
	add a, l
	rst 38
	ret
	ld sp, $250a
	dec e
	ldi [hl], a
	add hl, de
	ld c, $ff
	ret
	ld sp, $250b
	dec e
	ldi [hl], a
	add hl, de
	ld c, $ff
	ret
	ld sp, $250c
	dec e
	ldi [hl], a
	add hl, de
	ld c, $ff
	ret
	ld sp, $182f
	rrc a
	rrc a
	cpl
	cpl
	rst 38
	ret
	ld sp, $ff00
	ret
	ld sp, $ff01
	ret
	ld sp, $ff02
	ret
	ld sp, $ff03
	ret
	ld sp, $ff04
	ret
	ld sp, $ff05
	ret
	ld sp, $ff06
	ret
	ld sp, $ff07
	ret
	ld sp, $ff08
	ret
	ld sp, $ff09
	reti
	ld sp, $012f
	cpl
	ld de, $2120
	jr nc, .l_2fb4
	rst 38
	reti
	ld sp, $032f
	ld [de], a
	inc de
	ldi [hl], a
	inc hl
	ldd [hl], a
	inc sp
	rst 38
	xor c
	ld sp, $052f
	<error>
	dec b
	cpl
	cpl
	dec d
	inc b
	rl a
	inc h
	dec h
	ld h, $27
	inc [hl]
	dec [hl]
	ld [hl], $2f
	rst 38
	xor c
	ld sp, $3708
	<error>
	scf
	<error>
	ld [$1918], sp
	inc d
	dec de
	jr z, .l_2fda
	ldi a, [hl]
	dec hl
	ld h, b

.l_2fb4:
	ld [hl], b
	ld [hl], $2f
	rst 38
	reti
	ld sp, $fdb9
	cp c
	cp d
	<error>
	cp d
	rst 38
	reti
	ld sp, $fd82
	add a, d
	add a, e
	<error>
	add a, e
	rst 38
	reti
	ld sp, $0a09
	ldd a, [hl]
	dec sp
	rst 38
	reti
	ld sp, $400b
	ld a, h
	ld l, a
	rst 38
	reti
	ld sp, $0f2f
	cpl
	rr a
	ld e, a
	inc l
	cpl
	ccf
	rst 38
	reti
	ld sp, $3c6c
	ld c, e
	ld c, h
	ld e, e
	ld e, h
	ld l, e
	cpl
	rst 38
	xor c
	ld sp, $4d2f
	<error>
	ld c, l
	cpl
	cpl
	ld e, l
	ld e, [hl]
	ld c, [hl]
	ld e, a
	ld l, l
	ld l, [hl]
	cpl
	cpl
	ld a, l
	<error>
	ld a, l
	cpl
	rst 38
	xor c
	ld sp, $7708
	<error>
	ld [hl], a
	<error>
	ld [$7818], sp
	ld b, e
	ld d, e
	ld a, d
	ld a, e
	ld d, b
	cpl
	cpl
	ld [bc], a
	<error>
	ld a, l
	cpl
	rst 38
	reti
	ld sp, $fdb9
	cp c
	cp d
	<error>
	cp d
	rst 38
	reti
	ld sp, $fd82
	add a, d
	add a, e
	<error>
	add a, e
	rst 38
	reti
	ld sp, $0a09
	ldd a, [hl]
	dec sp
	rst 38
	reti
	ld sp, $400b
	ld a, h
	ld l, a
	rst 38
	reti
	ld sp, $dddc
	ldh [$ff00 + $e1], a
	rst 38
	reti
	ld sp, $dfde
	ldh [$ff00 + $e1], a
	rst 38
	reti
	ld sp, $e2de
	ldh [$ff00 + $e4], a
	rst 38
	reti
	ld sp, $eedc
	ldh [$ff00 + $e3], a
	rst 38
	reti
	ld sp, $e6e5
	rst 20
	add sp, d
	rst 38
	reti
	ld sp, $e6fd
	<error>
	push hl
	<error>
	add sp, d
	<error>
	rst 20
	rst 38
	reti
	ld sp, $eae9
	<error>
	<error>
	rst 38
	reti
	ld sp, $eaed
	<error>
	<error>
	rst 38
	reti
	ld sp, $f4f2
	di
	cp a
	rst 38
	reti
	ld sp, $f2f4
	cp a
	di
	rst 38
	reti
	ld sp, $fdc2
	jp nz, .l_fdc3
	jp .l_d9ff
	ld sp, $fdc4
	call nz, func_fdc5
	push bc
	rst 38
	reti
	ld sp, $fddc
	call c, func_fdef
	rst 28
	rst 38
	reti
	ld sp, $fdf0
	ldh a, [$ff00 + $f1]
	<error>
	pop af
	rst 38
	reti
	ld sp, $fddc
	ldh a, [$ff00 + $f1]
	<error>
	rst 28
	rst 38
	reti
	ld sp, $fdf0
	call c, func_fdef
	pop af
	rst 38
	reti
	ld sp, $bebd
	cp e
	cp h
	rst 38
	reti
	ld sp, $bab9
	jp c, .l_ffdb
	swap b
	ldh [$ff00 + $f0], a
	push af
	ld sp, $c1c0
	push bc
	add a, $cc
	call func_7675
	and h
	and l
	and [hl]
	and a
	ld d, h
	ld d, l
	ld d, [hl]
	ld d, a
	ld b, h
	ld b, l
	ld b, [hl]
	ld b, a
	and b
	and c
	and d
	and e
	sbc a, h
	sbc a, l
	sbc a, [hl]
	sbc a, a
	rst 38
	ld d, $31
	ldhl sp, d
	add sp, d
	inc e
	ld sp, $e8f0
	dec h
	ld sp, $0000
	dec hl
	ld sp, $0000
	ld sp, $0031
	nop
	ldd a, [hl]
	ld sp, $0000
	sbc a, l
	ld sp, $0000
	and e
	ld sp, $0000
	ld h, h
	ld sp, $f8d8
	ld a, h
	ld sp, $f8e8
	adc a, [hl]
	ld sp, $f8f0
	dec l
	ldd [hl], a
	ld h, e
	ld h, h
	ld h, l
	rst 38
	dec l
	ldd [hl], a
	ld h, e
	ld h, h
	ld h, l
	ld h, [hl]
	ld h, a
	ld l, b
	rst 38
	dec l
	ldd [hl], a
	ld b, c
	ld b, c
	ld b, c
	rst 38
	dec l
	ldd [hl], a
	ld b, d
	ld b, d
	ld b, d
	rst 38
	dec l
	ldd [hl], a
	ld d, d
	ld d, d
	ld d, d
	ld h, d
	ld h, d
	ld h, d
	rst 38
	dec l
	ldd [hl], a
	ld d, c
	ld d, c
	ld d, c
	ld h, c
	ld h, c
	ld h, c
	ld [hl], c
	ld [hl], c
	ld [hl], c
	rst 38
	xor c
	ld sp, $2f2f
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld h, e
	ld h, h
	<error>
	ld h, h
	<error>
	ld h, e
	ld h, [hl]
	ld h, a
	<error>
	ld h, a
	<error>
	ld h, [hl]
	rst 38
	reti
	ld sp, $2f2f
	ld h, e
	ld h, h
	rst 38
	reti
	ld sp, $fd00
	nop
	stop
	<error>
	stop
	ld c, a
	<error>
	ld c, a
	add a, b
	<error>
	add a, b
	add a, b
	<error>
	add a, b
	add a, c
	<error>
	add a, c
	sub a, a
	<error>
	sub a, a
	rst 38
	reti
	ld sp, $fd98
	sbc a, b
	sbc a, c
	<error>
	sbc a, c
	add a, b
	<error>
	add a, b
	sbc a, d
	<error>
	sbc a, d
	sbc a, e
	<error>
	sbc a, e
	rst 38
	reti
	ld sp, $fda8
	xor b
	xor c
	<error>
	xor c
	xor d
	<error>
	xor d
	xor e
	<error>
	xor e
	rst 38
	reti
	ld sp, $2f41
	cpl
	rst 38
	reti
	ld sp, $2f52
	ld h, d
	rst 38
	nop
	nop
	nop
	ld [$1000], sp
	nop
	jr .l_31ba
	nop
	ld [$0808], sp
	stop
	ld [$1018], sp

.l_31ba:
	nop
	stop
	ld [$1010], sp
	stop
	jr .l_31da
	nop
	jr .l_31cd
	jr .l_31d7
	jr .l_31e1
	nop
	nop
	nop
	ld [$1000], sp
	nop
	jr .l_31d2

.l_31d2:
	jr nz, .l_31d4

.l_31d4:
	jr z, .l_31d6

.l_31d6:
	jr nc, .l_31d8

.l_31d8:
	jr c, .l_31da

.l_31da:
	nop
	nop
	ld [$0008], sp
	ld [$1008], sp
	nop
	stop
	ld [$0018], sp
	jr .l_31f1
	jr nz, .l_31eb

.l_31eb:
	jr nz, .l_31f5
	jr z, .l_31ef

.l_31ef:
	jr z, .l_31f9

.l_31f1:
	jr nc, .l_31f3

.l_31f3:
	jr nc, .l_31fd

.l_31f5:
	nop
	ld [$1000], sp

.l_31f9:
	ld [$0808], sp
	stop

.l_31fd:
	stop
	nop
	stop
	ld [$1010], sp
	stop
	jr .l_321e
	nop
	jr .l_3211
	jr .l_321b
	jr .l_3225
	jr nz, .l_320f

.l_320f:
	jr nz, .l_3219

.l_3211:
	jr nz, .l_3223
	jr nz, .l_322d
	jr z, .l_3217

.l_3217:
	jr z, .l_3221

.l_3219:
	jr z, .l_322b

.l_321b:
	jr z, .l_3235
	jr nc, .l_321f

.l_321f:
	jr nc, .l_3229

.l_3221:
	jr nc, .l_3233

.l_3223:
	jr nc, .l_323d

.l_3225:
	jr c, .l_3227

.l_3227:
	jr c, .l_3231

.l_3229:
	jr c, .l_323b

.l_322b:
	jr c, .l_3245

.l_322d:
	nop
	nop
	nop
	ld [$1000], sp

.l_3233:
	ld [$0800], sp
	ld [$1008], sp
	stop
	nop

.l_323b:
	stop
	ld [$1010], sp
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a

.l_3245:
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, h
	ld a, h
	ld a, b
	ld a, c
	ld a, b
	ld a, e
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38


func_3264::
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ccf
	ccf
	rr a
	sbc a, a
	rr a
	rst 18
	ld a, b
	ld a, e
	ld a, b
	ld a, c
	ld a, h
	ld a, h
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	nop
	nop
	nop
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rr a
	rst 18
	rr a
	sbc a, a
	ccf
	ccf
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ldhl sp, d
	ldhl sp, d
	ldh a, [$ff00 + $f2]
	pop hl
	push af
	<error>
	<error>
	and $ff
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rr a
	rr a
	rrc a
	ld c, a
	add a, a
	xor a
	rst 0
	ld c, a
	ld h, a
	<error>
	and $f2
	and $f2
	and $f2
	and $f2
	and $f2
	and $f2
	and $f2
	and $4f
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a


func_330c::
	ld h, a
	ld c, a
	ld h, a
	<error>
	and $f5
	<error>
	<error>
	pop hl
	ldhl sp, d
	ldh a, [$ff00 + $ff]
	ldhl sp, d
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	rst 38
	rst 38
	nop
	rst 38
	nop
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ld c, a
	ld h, a
	xor a
	rst 0
	ld c, a
	add a, a
	rr a
	rrc a
	rst 38
	rr a
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ld a, b
	ld a, e
	ld a, b
	ld a, c
	ld a, h
	ld a, h
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, h
	ld a, h
	ld a, b
	ld a, c
	ld a, b
	ld a, e
	rr a
	rst 18
	rr a
	sbc a, a
	ccf
	ccf
	rst 38
	rst 38
	rst 38
	rst 38
	ccf
	ccf
	rr a
	sbc a, a
	rr a
	rst 18
	nop
	nop
	nop
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop


func_3372::
	ld a, a
	nop
	nop
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	ld a, b
	ld a, d
	nop
	ld [bc], a
	nop
	ld a, d
	nop
	ld a, d
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	rr a
	ld e, a
	nop
	ld b, b
	nop
	ld e, a
	nop
	ld e, a
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	ccf
	ccf
	ccf
	ccf
	jr nc, .l_33e9
	jr nc, .l_33eb
	inc sp

.l_33bc:
	ldd [hl], a
	inc sp
	jr nc, .l_33c0

.l_33c0:
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	rst 38
	ld [bc], a
	rst 38
	jr nz, .l_33d0

.l_33d0:
	nop
	nop
	nop
	<error>
	<error>
	<error>
	<error>
	inc c
	inc c
	inc c
	inc c
	call z, func_cc0c
	inc c
	inc sp
	jr nc, .l_3415
	jr nc, .l_3417
	jr nc, .l_3419
	jr nc, .l_341b
	jr nc, .l_341d
	jr nc, .l_341f
	ldd [hl], a
	inc sp
	jr nc, .l_33bc
	inc c
	call z, func_cc4c
	inc c
	call z, func_cc0c
	inc c
	call z, func_cc8c
	inc c
	call z, func_330c
	jr nc, .l_3435
	jr nc, .l_3434
	jr nc, .l_3436
	jr nc, .l_3447
	ccf
	ccf
	ccf
	nop
	nop
	nop
	nop
	rst 38
	inc b
	rst 38
	ld b, b
	nop
	nop

.l_3415:
	nop
	nop

.l_3417:
	rst 38
	rst 38

.l_3419:
	rst 38
	rst 38

.l_341b:
	nop
	nop

.l_341d:
	nop
	nop

.l_341f:
	call z, func_cc0c
	ld c, h
	inc c
	inc c
	inc c
	inc c
	<error>
	<error>
	<error>
	<error>
	nop
	nop
	nop
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38

.l_3434:
	nop

.l_3435:
	rst 38

.l_3436:
	ld [bc], a
	rst 38
	jr nz, .l_3439
	nop
	rst 38
	inc b
	rst 38
	nop
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	ld b, b
	rst 38
	nop

.l_3447:
	rst 38
	ld [$01ff], sp
	rst 38
	ld b, e
	rst 38
	rlc a
	rst 38
	inc b
	rst 38
	ld b, b
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	rst 38
	nop
	rst 38
	ld b, b
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	stop
	rst 38
	add a, b
	rst 38
	jp nz, .l_e0ff
	cp $06
	cp $46
	cp $06
	cp $06
	cp $16
	cp $86
	cp $06
	cp $06
	ld a, a
	ld h, h
	ld a, a
	ld h, b
	ld a, a
	ld h, d
	ld a, a
	ld h, b
	ld a, a
	ld h, b
	ld a, a
	ld l, b
	ld a, a
	ld h, d
	ld a, a
	ld h, b
	rst 38
	ld [bc], a
	rst 38
	ld b, b
	rst 38
	nop
	rst 38
	nop
	rst 38
	ld [$80ff], sp
	rst 38
	rr a
	ldh a, [$ff00 + $10]
	rst 38
	ld [bc], a
	rst 38
	jr nz, .l_34a3
	nop
	rst 38
	nop
	rst 38
	inc b
	rst 38
	nop
	rst 38
	rst 38
	nop
	nop
	rst 38
	rlc a
	rst 38
	inc de
	rst 38
	ld bc, $00ff
	rst 38
	ld b, b
	rst 38
	nop
	rst 38
	rst 38
	ld [$0008], sp
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	jr nz, .l_34cb
	rst 38
	nop
	nop
	rst 38
	ldh [$ff00 + $ff], a
	ret z
	rst 38
	add a, b
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	rst 38
	ld [$ff08], sp
	nop
	rst 38
	ld [bc], a
	rst 38
	ld b, b
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	ldhl sp, d
	rrc a
	ld [$10f0], sp
	ldh a, [$ff00 + $10]
	ldh a, [$ff00 + $10]
	ldh a, [$ff00 + $50]
	ldh a, [$ff00 + $10]
	ldh a, [$ff00 + $10]
	ldh a, [$ff00 + $10]
	ldh a, [$ff00 + $10]
	rrc a
	ld [$0a0f], sp
	rrc a
	ld [$080f], sp
	rrc a
	ld [$080f], sp
	rrc a
	add hl, bc
	rrc a
	ld [$0000], sp
	nop
	ld a, a
	nop
	nop
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, h
	ld a, h
	ld a, b
	ld a, c
	ld a, b
	ld a, e
	nop
	nop
	nop
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	ccf
	ccf
	rr a
	sbc a, a
	rr a
	rst 18
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	nop
	nop
	nop
	ld a, a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	xor d
	xor d
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rrc a
	rrc a
	rr a
	rr a
	jr c, .l_3591
	inc sp
	jr nc, .l_3592
	jr nc, .l_3592
	jr nc, .l_3560

.l_3560:
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldh a, [$ff00 + $f0]
	ldhl sp, d
	ldhl sp, d
	inc e
	inc e
	call z, func_6c0c
	inc c
	inc l
	inc c
	inc [hl]
	jr nc, .l_35b6
	jr nc, .l_35b8
	jr nc, .l_35ba
	jr nc, .l_35bc
	jr nc, .l_35be
	jr nc, .l_35c0
	jr nc, .l_35c2
	jr nc, .l_35bc
	inc c

.l_3591:
	inc l

.l_3592:
	inc c
	inc l
	inc c
	inc l
	inc c
	inc l
	inc c
	inc l
	inc c
	inc l
	inc c
	inc l
	inc c
	inc [hl]
	jr nc, .l_35d8
	jr nc, .l_35d7
	jr nc, .l_35de
	jr c, .l_35c7
	rr a
	rrc a
	rrc a
	nop
	nop
	nop
	nop
	nop
	ld a, e
	nop
	ld a, c
	nop
	ld a, h
	nop

.l_35b6:
	ld a, a
	nop

.l_35b8:
	ld a, a
	nop

.l_35ba:
	nop
	nop

.l_35bc:
	ld a, a
	nop

.l_35be:
	nop
	nop

.l_35c0:
	rst 18
	nop

.l_35c2:
	sbc a, a
	nop
	ccf
	nop
	rst 38

.l_35c7:
	nop
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop

.l_35d7:
	rst 38

.l_35d8:
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop

.l_35de:
	nop
	inc l
	inc c
	ld l, h
	inc c
	call z, func_1c0c
	inc e
	ldhl sp, d
	ldhl sp, d
	ldh a, [$ff00 + $f0]
	nop
	nop
	nop
	nop
	ld [$ff08], sp
	rst 38
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	jr nz, .l_35f9
	nop
	rst 38
	ld [bc], a
	rst 38
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	jr nz, .l_360b
	rst 38
	ld [$ff08], sp
	rlc a
	rst 38
	inc de
	rst 38
	ld bc, $00ff
	rst 38
	ld b, b
	rst 38
	nop
	rst 38
	rst 38
	nop
	nop
	rst 38
	ldh [$ff00 + $ff], a
	ret z
	rst 38
	add a, b
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	rst 38
	nop
	nop
	ld [$0808], sp
	ld [$0808], sp
	ld [$0808], sp
	ld [$0808], sp
	ld [$0808], sp
	ld [$00ff], sp
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	jr nz, .l_3647
	ld [bc], a
	rst 38
	nop
	rst 38
	rst 38
	ld [$f008], sp
	stop
	rst 38
	rr a
	ldh a, [$ff00 + $1f]
	ldh a, [$ff00 + $1f]
	ldh a, [$ff00 + $1f]
	ldh a, [$ff00 + $1f]
	rst 38
	ld e, a
	ldh a, [$ff00 + $10]
	nop
	nop
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	nop
	nop
	ld [$ff08], sp
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	ld [$0f08], sp
	ld [$f8ff], sp
	rrc a
	ldhl sp, d
	rrc a
	ldhl sp, d
	rrc a
	ldhl sp, d
	rrc a
	ldhl sp, d
	rst 38
	ld a, [$080f]
	rst 38
	rlc a
	rst 38
	ld b, e
	rst 38
	ld bc, $00ff
	rst 38
	nop
	rst 38
	add a, b
	rst 38
	rr a
	ldh a, [$ff00 + $10]
	rst 38
	ldh [$ff00 + $ff], a
	jp nz, .l_80ff
	rst 38
	nop
	rst 38
	ldi [hl], a
	rst 38
	nop
	rst 38
	ldhl sp, d
	rrc a
	ld [$0000], sp
	nop
	nop
	nop
	nop
	inc a
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld c, [hl]
	nop
	ld c, [hl]
	nop
	ld a, [hl]
	nop
	ld c, [hl]
	nop
	ld c, [hl]
	nop
	nop
	nop
	nop
	nop
	ld a, h
	nop
	ld h, [hl]
	nop
	ld a, h
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	ld a, h
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld h, [hl]
	nop
	ld h, b
	nop
	ld h, b
	nop
	ld h, [hl]
	nop
	inc a
	nop
	nop
	nop
	<error>
	ld b, h
	rst 38
	ld b, h
	rst 38
	rst 38
	ld [hl], a
	ld de, $11ff
	rst 38
	rst 38
	<error>
	ld b, h
	rst 38
	ld b, h
	rst 38
	rst 38
	ld [hl], a
	ld de, $11ff
	rst 38
	rst 38
	<error>
	ld b, h
	rst 38
	ld b, h
	rst 38
	rst 38
	ld [hl], a
	ld de, $11ff
	rst 38
	rst 38
	<error>
	ld b, h
	rst 38
	ld b, h
	rst 38
	rst 38
	ld [hl], a
	ld de, $11ff
	rst 38
	rst 38
	nop
	nop
	ld a, [hl]
	nop
	jr .l_3725

.l_3725:
	jr .l_3727

.l_3727:
	jr .l_3729

.l_3729:
	jr .l_372b

.l_372b:
	jr .l_372d

.l_372d:
	nop
	nop
	nop
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	inc a
	nop
	jr .l_3739

.l_3739:
	jr .l_373b

.l_373b:
	jr .l_373d

.l_373d:
	nop
	nop
	rst 38
	rst 38
	rst 30
	adc a, c
	<error>
	and e
	rst 38
	add a, c
	or a
	ret
	<error>
	add a, e
	rst 10
	xor c
	rst 38
	add a, c
	rst 38
	rst 38
	rst 38
	add a, c
	rst 38
	cp l
	rst 20
	and l
	rst 20
	and l
	rst 38
	cp l
	rst 38
	add a, c
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	add a, c
	rst 38
	add a, c
	rst 38
	sbc a, c
	rst 38
	sbc a, c
	rst 38
	add a, c
	rst 38
	add a, c
	rst 38
	rst 38
	rst 38
	rst 38
	add a, c
	add a, c
	cp l
	cp l
	cp l
	cp l
	cp l
	cp l
	cp l
	cp l
	add a, c
	add a, c
	rst 38
	rst 38
	rst 38
	rst 38
	add a, c
	rst 38
	add a, c
	rst 38
	add a, c
	rst 38
	add a, c
	rst 38
	add a, c
	rst 38
	add a, c
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	add a, c
	jp .l_df81
	add a, l
	rst 18
	add a, l
	rst 38
	cp l
	rst 38
	add a, c
	rst 38
	rst 38
	rst 38
	rst 38
	add a, c
	rst 38
	cp l
	rst 38
	and l
	rst 20
	and l
	rst 20
	cp l
	rst 38
	add a, c
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	add a, c
	add a, c
	cp l
	add a, e
	cp l
	add a, e
	cp l
	add a, e
	cp l
	add a, e
	add a, c
	rst 38
	rst 38
	rst 38
	<error>
	sub a, e
	cp a
	pop bc
	push af
	adc a, e
	rst 18
	and c
	<error>
	add a, e
	xor a
	pop de
	ei
	add a, l
	rst 18
	and c
	<error>
	add a, e
	rst 28
	sub a, c
	cp e
	push bc
	rst 28
	sub a, c
	cp l
	jp .l_89f7
	rst 18
	and c
	rst 38
	rst 38
	rst 38
	rst 38
	<error>
	and h
	rst 38
	add a, b
	or l
	jp z, .l_80ff
	<error>
	and d
	rst 30
	adc a, b
	rst 38
	rst 38
	rst 38
	rst 38
	ld d, a
	xor b
	<error>
	ld [bc], a
	rst 18
	jr nz, .l_3873
	add a, h
	xor $11
	cp e
	ld b, h
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ld [hl], a
	adc a, c
	rst 18
	ld hl, $05fb
	xor a
	ld d, c
	<error>
	inc bc
	rst 10
	add hl, hl
	rst 38
	rst 38
	nop
	nop
	inc a
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	jr .l_3853

.l_3853:
	jr c, .l_3855

.l_3855:
	jr .l_3857

.l_3857:
	jr .l_3859

.l_3859:
	jr .l_385b

.l_385b:
	inc a
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld c, [hl]
	nop
	ld c, $00
	inc a
	nop
	ld [hl], b
	nop
	ld a, [hl]
	nop
	nop
	nop
	nop
	nop
	ld a, h
	nop

.l_3873:
	ld c, $00
	inc a
	nop
	ld c, $00
	ld c, $00
	ld a, h
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld l, h
	nop
	ld c, h
	nop
	ld c, [hl]
	nop
	ld a, [hl]
	nop
	inc c
	nop
	nop
	nop
	nop
	nop
	ld a, h
	nop
	ld h, b
	nop
	ld a, h
	nop
	ld c, $00
	ld c, [hl]
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld h, b
	nop
	ld a, h
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	ld a, [hl]
	nop
	ld b, $00
	inc c
	nop
	jr .l_38b9

.l_38b9:
	jr c, .l_38bb

.l_38bb:
	jr c, .l_38bd

.l_38bd:
	nop
	nop
	nop
	nop
	inc a
	nop
	ld c, [hl]
	nop
	inc a
	nop
	ld c, [hl]
	nop
	ld c, [hl]
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld c, [hl]
	nop
	ld c, [hl]
	nop
	ld a, $00
	ld c, $00
	inc a
	nop
	nop
	nop
	nop
	nop
	ld a, h
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	ld a, h
	nop
	ld h, b
	nop
	ld h, b
	nop
	nop
	nop
	nop
	nop
	ld a, [hl]
	nop
	ld h, b
	nop
	ld a, h
	nop
	ld h, b
	nop
	ld h, b
	nop
	ld a, [hl]
	nop
	nop
	nop
	nop
	nop
	ld a, [hl]
	nop
	ld h, b
	nop
	ld h, b
	nop
	ld a, h
	nop
	ld h, b
	nop
	ld h, b
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld h, [hl]
	nop
	ld h, b
	nop
	ld l, [hl]
	nop
	ld h, [hl]
	nop
	ld a, $00
	nop
	nop
	nop
	nop
	ld b, [hl]
	nop
	ld l, [hl]
	nop
	ld a, [hl]
	nop
	ld d, [hl]
	nop
	ld b, [hl]
	nop
	ld b, [hl]
	nop
	nop
	nop
	nop
	nop
	ld b, [hl]
	nop
	ld b, [hl]
	nop
	ld b, [hl]
	nop
	ld b, [hl]
	nop
	ld c, [hl]
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	ld h, b
	nop
	inc a
	nop
	ld c, $00
	ld c, [hl]
	nop
	inc a
	nop
	nop
	nop
	nop
	nop
	inc a
	nop
	jr .l_3965

.l_3965:
	jr .l_3967

.l_3967:
	jr .l_3969

.l_3969:
	jr .l_396b

.l_396b:
	inc a
	nop
	nop
	nop
	nop
	nop
	ld h, b
	nop
	ld h, b
	nop
	ld h, b
	nop
	ld h, b
	nop
	ld h, b
	nop
	ld a, [hl]
	nop
	nop
	nop
	nop
	nop
	ld b, [hl]
	nop
	ld b, [hl]
	nop
	ld b, [hl]
	nop
	ld b, [hl]
	nop
	inc l
	nop
	jr .l_398d

.l_398d:
	nop
	nop
	nop
	nop
	ld a, h
	nop
	ld h, [hl]
	nop
	ld h, [hl]
	nop
	ld a, h
	nop
	ld l, b
	nop
	ld h, [hl]
	nop
	nop
	nop
	nop
	nop
	ld b, [hl]
	nop
	ld h, [hl]
	nop
	halt
	nop
	ld e, [hl]
	nop
	ld c, [hl]
	nop
	ld b, [hl]
	nop
	nop
	nop
	nop
	nop
	ld a, h
	nop
	ld c, [hl]
	nop
	ld c, [hl]
	nop
	ld c, [hl]
	nop
	ld c, [hl]
	nop
	ld a, h
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	stop
	rst 38
	add a, b
	rst 38
	ld [bc], a
	rst 38
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	jr nz, .l_39db
	rst 38
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	add a, b
	add a, b
	add a, b
	add a, b
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	jr nz, .l_3a09
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rlc a
	rlc a
	jr .l_3a42
	ld hl, $473e
	ld a, a
	ld e, a
	ld a, a
	add hl, sp
	jr nc, .l_3aa7
	ld h, d
	ei
	or d
	rst 38
	and b
	rst 38
	jp nz, .l_547f
	ld a, a
	ld e, h
	ccf
	ld l, $7f
	ld h, e
	cp a
	ldhl sp, d
	scf
	rst 38
	ld bc, $0101

.l_3a42:
	ld bc, $0101
	ld bc, $0101
	ld bc, $0101
	ld bc, $8301
	add a, e
	ld bc, $0101
	ld bc, $0101
	ld bc, $0101
	ld bc, $0101
	ld bc, $ff01
	rst 38
	rst 38
	rst 38
	ld bc, $0101
	ld bc, $0101
	ld bc, $0101
	ld bc, $0101
	add a, e
	add a, e
	rst 38
	rst 38
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	rst 38
	rst 38
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	reti
	add a, a
	nop
	jr c, .l_3aa2

.l_3aa2:
	jr c, .l_3aa4

.l_3aa4:
	jr c, .l_3aa6

.l_3aa6:
	jr c, .l_3aa8

.l_3aa8:
	jr c, .l_3aaa

.l_3aaa:
	jr c, .l_3aac

.l_3aac:
	jr c, .l_3aae

.l_3aae:
	jr c, .l_3b2c
	nop
	ld a, h
	nop
	ld a, h
	nop
	ld a, h
	nop
	ld a, h
	nop
	ld a, h
	nop
	ld a, a
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	ld [$0800], sp
	nop

.l_3ac7:
	ld [$0800], sp
	nop
	inc e
	nop
	inc e
	nop
	nop
	nop
	nop
	ld c, $01
	dec e
	ld e, $06
	ldi a, [hl]
	ldi a, [hl]
	daa
	daa
	stop
	inc de
	inc c
	dec c
	nop
	nop
	ret nz
	ret nz
	jr nz, .l_3b05
	stop
	ret nc
	ret nc
	stop

.l_3ae9:
	ldh a, [$ff00 + $30]
	ret z
	add sp, d
	ld [$04e8], sp
	rlc a
	inc bc
	inc bc
	inc c
	inc c
	stop
	stop
	dec [hl]
	jr nz, .l_3b24
	jr nz, .l_3b3b
	ccf
	inc c
	inc c
	jr z, .l_3ae9
	ret c
	ret nz
	ld b, b
	ld b, b

.l_3b05:
	jr nz, .l_3b27
	ld d, b
	stop
	or b

.l_3b0a:
	stop
	ldh a, [$ff00 + $f0]
	ret nz
	ret nz
	nop
	ldh [$ff00 + $01], a
	ld [hl], c
	ldd [hl], a
	ld b, d
	inc [hl]
	dec [hl]
	ld d, l
	ld d, h
	ld c, a
	ld c, [hl]
	ld hl, $1827
	dec de
	nop
	nop
	add a, b
	add a, b
	ld b, b

.l_3b24:
	ld b, b
	jr nz, .l_3ac7

.l_3b27:
	and b
	jr nz, .l_3b0a
	ld h, b
	sub a, b

.l_3b2c:
	ldh a, [$ff00 + $08]
	ret z
	cp b
	cp b
	add a, h
	add a, h
	add a, h
	add a, h
	<error>
	<error>
	sub a, d
	sub a, d
	sub a, d
	sub a, d

.l_3b3b:
	ld l, h
	ld l, h
	xor $ee
	rlc a
	rlc a
	rr a
	jr .l_3b82
	jr nz, .l_3bc5
	ld c, a
	ld a, a
	ld e, a
	ld [hl], b
	ld [hl], b
	and d
	and d
	or b
	or b
	or h
	or h
	ld h, h
	ld h, h
	inc a
	inc a
	ld l, $2e
	daa
	daa
	stop
	stop
	ld l, h
	ld a, h
	rst 8
	or e
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	ld [bc], a
	rlc a
	ld b, $09
	add hl, bc
	ld d, $17
	ld [de], a
	ld de, $0f0e
	ld [$0809], sp
	ld [$0f0f], sp
	ld [$0908], sp
	add hl, bc
	ld a, [bc]
	ld a, [bc]
	ld b, $06
	ld c, $0e
	inc bc
	inc bc
	inc bc

.l_3b82:
	inc bc
	inc bc
	ld [bc], a
	rr a
	ld e, $21
	ld hl, $554a
	ld c, d
	ld [hl], l
	ld a, [bc]
	dec [hl]
	ld a, [bc]
	dec d
	ld [$0f08], sp
	rrc a
	ld [$0908], sp
	add hl, bc
	ld a, [bc]
	ld a, [bc]
	ld b, $06
	ld c, $0e
	nop
	nop
	ld h, [hl]
	nop
	ld l, h
	nop
	ld a, b
	nop
	ld a, b
	nop
	ld l, h
	nop
	ld h, [hl]
	nop
	nop
	nop
	nop
	nop
	ld b, [hl]
	nop
	inc l
	nop
	jr .l_3bb7

.l_3bb7:
	jr c, .l_3bb9

.l_3bb9:
	ld h, h
	nop
	ld b, d
	nop
	nop
	nop
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>

.l_3bc5:
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	ldhl sp, d
	nop
	ldh [$ff00 + $00], a
	ret nz
	nop
	add a, b
	nop
	add a, b
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld a, a
	nop
	rr a
	nop
	rrc a
	nop
	rlc a
	nop
	rlc a
	nop
	inc bc
	nop
	inc bc
	nop
	inc bc
	nop
	nop
	nop
	add a, b
	nop
	add a, b
	nop
	ret nz
	nop
	ldh [$ff00 + $00], a
	ldhl sp, d
	nop
	rst 38
	nop
	rst 38
	nop
	inc bc

.l_3c00:
	nop
	rlc a
	nop
	rlc a
	nop
	rrc a
	nop
	rr a
	nop
	ld a, a
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	rst 38
	nop
	nop
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	ld bc, $02fe
	cp $02
	<error>
	inc b
	<error>
	inc b
	<error>
	inc b
	rst 38
	ld [bc], a
	rst 38
	ld bc, $01ff
	ld bc, $ff01
	ld bc, $0101
	rst 38
	ld bc, $0101
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	inc bc
	inc bc
	inc b
	dec b
	ld [$1109], sp
	ld [de], a
	ld hl, $4326
	ld c, h
	nop
	nop
	ld bc, $0201
	ld [bc], a
	inc b
	inc b
	ld [$1009], sp
	inc de
	jr nz, .l_3c84
	jr nz, .l_3c8e
	add a, a
	sbc a, b
	ld b, $39
	ld c, $71
	ld e, $e1
	inc a
	jp .l_c33c
	ld a, b
	add a, a
	ld a, b
	add a, a
	ld b, b
	ld c, a
	ld b, b
	ld c, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	ldhl sp, d
	rlc a
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldhl sp, d

.l_3c8e:
	rlc a
	ld b, b
	ld e, a
	ld b, b
	ld c, a
	jr nz, .l_3cc4
	jr nz, .l_3cbe
	stop
	ld de, $0f0f
	inc b
	inc b
	rlc a
	rlc a
	ld a, b
	add a, a
	ld a, h
	add a, e
	inc a
	jp .l_e11e
	rrc a
	ldh a, [$ff00 + $ff]
	rst 38
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	nop

.l_3cbe:
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	ld [bc], a

.l_3cc4:
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	stop
	nop
	jr c, .l_3cd3

.l_3cd3:
	ld a, h
	nop
	cp $00
	cp $00

.l_3cd9:
	cp $00
	ld a, h
	nop
	nop
	nop
	ld [bc], a
	inc bc
	ld bc, $0201
	ld [bc], a
	inc b
	inc b
	dec c
	ld [$080a], sp
	rrc a
	rrc a
	inc bc
	inc bc
	jr z, .l_3cd9
	ldh a, [$ff00 + $d0]
	jr nc, .l_3d25
	ld [$5408], sp
	inc b
	xor h
	inc b
	<error>
	<error>
	jr nc, .l_3d2f
	nop
	nop
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	ld [bc], a
	rlc a
	ld b, $09
	add hl, bc
	ld [$0b08], sp
	dec bc
	nop
	nop
	ret nz
	ret nz
	call nz, func_e8c4
	ld l, b
	sub a, b
	ldh a, [$ff00 + $a8]
	ldhl sp, d
	ld c, b
	ld a, b
	ldhl sp, d
	cp b
	nop
	nop
	rlc a
	rlc a
	rlc a
	rlc a

.l_3d25:
	rlc a
	inc b
	rlc a
	inc b
	dec bc
	dec bc
	stop
	stop
	rl a
	rl a

.l_3d2f:
	nop
	nop
	add a, b
	add a, b
	add a, b
	add a, b
	ldh [$ff00 + $e0], a
	sub a, b
	ldh a, [$ff00 + $a8]
	ldhl sp, d
	ld c, b
	ld a, b
	cp b
	cp b
	ld [$0f08], sp
	rrc a
	ld [$0f08], sp
	rrc a
	add hl, bc
	add hl, bc
	add hl, bc
	add hl, bc
	ld b, $06
	ld c, $0e
	<error>
	<error>
	ldi [hl], a
	ldi [hl], a
	jr nz, .l_3d75
	ldh [$ff00 + $e0], a
	jr nz, .l_3d79
	jr nz, .l_3d7b
	ret nz
	ret nz
	ldh [$ff00 + $e0], a
	jr .l_3d79
	sbc a, b
	sbc a, b
	sbc a, b
	sbc a, b
	ldhl sp, d
	ldhl sp, d
	sbc a, h
	sbc a, b
	inc a
	inc a
	inc a
	inc a
	ld a, [hl]
	ld a, [hl]
	ld a, a
	nop
	cp $fe
	ld a, [hl]
	ld a, [hl]

.l_3d75:
	cp $da
	ld a, [hl]
	ld e, d

.l_3d79:
	ld a, [hl]
	ld a, [hl]

.l_3d7b:
	<error>
	<error>
	ldhl sp, d
	ldhl sp, d
	cp $0e
	cp $fe
	ld a, [hl]
	ld a, [hl]
	cp $da
	ld a, [hl]
	ld e, d
	ld a, [hl]
	ld a, [hl]
	<error>
	<error>
	ldhl sp, d
	ldhl sp, d
	add a, b
	add a, b
	add a, e
	add a, e
	add a, e
	add a, e
	jp .l_ef02
	ld l, $97
	sub a, a
	ld b, a
	ld b, h
	inc h
	inc h
	nop
	nop
	ret nz
	ret nz
	ret nz
	ret nz
	ret nz
	ld b, b
	ldh [$ff00 + $60], a
	ldhl sp, d
	ldhl sp, d
	<error>

.l_3dac:
	inc h
	inc [hl]
	inc [hl]
	rl a
	inc d
	rl a
	inc d
	rl a
	inc d
	inc e
	rr a
	rl a
	rl a
	rrc a
	rrc a
	ld e, $1e
	nop
	nop
	<error>
	inc h
	ldhl sp, d
	jr z, .l_3dac
	jr z, .l_3dfe
	ldhl sp, d
	add sp, d
	add sp, d
	sub a, b
	sub a, b
	ld [hl], b
	ld [hl], b
	ld a, b
	ld a, b
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	ld [bc], a
	rrc a
	ld c, $11
	ld de, $3737
	ld [hl], c
	ld d, d
	ld a, l
	ld c, [hl]
	ret nz
	ret nz
	ret nz
	ret nz
	ret nz
	ld b, b
	ret nz
	ld b, b
	and b
	and b
	stop
	stop
	rst 38
	rst 38
	rst 8
	inc sp
	ld a, a
	ld b, b
	ccf
	ccf
	ld [$0f08], sp
	rrc a
	add hl, bc
	add hl, bc
	add hl, bc
	add hl, bc
	ld b, $06
	ld c, $0e
	<error>
	<error>
	jr nz, .l_3e23
	jr nz, .l_3e25
	ldh [$ff00 + $e0], a
	jr nz, .l_3e29
	jr nz, .l_3e2b
	ret nz
	ret nz
	ldh [$ff00 + $e0], a
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	ld [bc], a
	rlc a
	ld b, $09
	add hl, bc
	inc sp
	inc sp
	ld [hl], a
	ld d, h
	ld [hl], e
	ld c, h
	jr .l_3e39
	ret c
	ret c

.l_3e23:
	ret c
	ret c

.l_3e25:
	ldhl sp, d
	ld a, b
	call c, func_bc58
	cp h

.l_3e2b:
	inc a
	inc a
	ld a, [hl]
	ld a, [hl]
	add hl, bc
	ld c, $07
	rlc a
	ld [$080f], sp
	rrc a
	add hl, bc
	rrc a

.l_3e39:
	ld a, [bc]
	ld c, $06
	ld b, $0e
	ld c, $00
	nop
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	ld [bc], a
	rst 38
	ld a, [hl]
	ret
	ccf
	ld a, b
	ld a, a
	add hl, bc
	rrc a
	inc b
	inc b
	rlc a
	rlc a
	cp b
	cp a
	ret nz
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop


func_3e5c::
	nop
	nop
	nop
	nop
	nop
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, e
	ld c, b
	ld h, b
	ld e, a
	or [hl]
	or b
	add a, h
	add a, h
	cp b
	cp b
	add a, h
	add a, h
	add a, h
	add a, h
	add a, h
	add a, h
	ld a, [$92fa]
	sub a, d
	sbc a, [hl]
	sbc a, [hl]
	ld h, a
	ld h, a
	ldh [$ff00 + $e0], a
	nop
	nop
	nop
	nop
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld c, b
	ld b, b
	ld a, [hl]
	or h
	or b
	add a, h
	add a, h
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	jr nc, .l_3ecf
	ld sp, $3131
	ld sp, $2a32
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld b, h
	inc e
	inc c
	jr .l_3ed0
	ld c, $45
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	ld h, a
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld l, b
	ldi a, [hl]
	ld a, e
	cpl
	cpl

.l_3ecf:
	cpl

.l_3ed0:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld b, e
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	jr nc, .l_3f33
	ld sp, $3131
	ld sp, $2a32
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	ld [hl], $15
	ld c, $1f
	ld c, $15
	scf
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	ldi a, [hl]
	ld a, l
	cpl
	cpl

.l_3f33:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	ld b, b
	ld b, d
	ld b, d
	ld b, d
	ld b, d
	ld b, d
	ld b, c
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	ld [hl], $15
	ld [de], a
	rl a
	ld c, $1c
	scf
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	inc sp
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	dec [hl]
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	dec hl
	jr c, .l_3fc8
	add hl, sp
	add hl, sp
	add hl, sp
	ldd a, [hl]
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e

.l_3fc8:
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	dec hl
	dec a
	ld a, $3e
	ld a, $3e
	ccf
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl

.l_4000:
	cpl
	cpl
	cpl
	ld a, e
	jr nc, .l_4037
	ld sp, $3131
	ld sp, $2a32
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld [hl], $15
	ld c, $1f
	ld c, $15
	scf
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	ldi a, [hl]
	ld a, e
	cpl
	cpl

.l_4037:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	ld b, b
	ld b, d
	ld b, d
	ld b, d
	ld b, d
	ld b, d
	ld b, c
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld [hl], $11
	ld [de], a
	stop
	ld de, $372f
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	inc sp
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	dec [hl]
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	dec hl
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	jr nc, .l_40d7
	ld sp, $3131
	ld sp, $2a32
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	ld [hl], $15
	ld [de], a
	rl a
	ld c, $1c
	scf
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld [hl], $2f
	cpl
	ld [bc], a
	dec b
	cpl
	scf
	ldi a, [hl]
	ld a, l
	cpl
	cpl

.l_40d7:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	inc sp
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	dec [hl]
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	dec hl
	jr c, .l_4130
	add hl, sp
	add hl, sp
	add hl, sp
	ldd a, [hl]
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e

.l_4130:
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	ldi a, [hl]
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	dec hl
	dec a
	ld a, $3e
	ld a, $3e
	ccf
	nop
	inc a
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	inc a
	nop
	nop
	jr .l_41a2
	jr .l_4184
	jr .l_41aa
	nop
	nop
	inc a
	ld c, [hl]
	ld c, $3c
	ld [hl], b
	ld a, [hl]
	nop
	nop
	ld a, h
	ld c, $3c
	ld c, $0e
	ld a, h
	nop
	nop
	inc a
	ld l, h
	ld c, h
	ld c, [hl]

.l_4184:
	ld a, [hl]
	inc c
	nop
	nop
	ld a, h
	ld h, b
	ld a, h
	ld c, $4e
	inc a
	nop
	nop
	inc a
	ld h, b
	ld a, h
	ld h, [hl]
	ld h, [hl]
	inc a
	nop
	nop
	ld a, [hl]
	ld b, $0c
	jr .l_41d5
	jr c, .l_419f

.l_419f:
	nop
	inc a
	ld c, [hl]

.l_41a2:
	inc a
	ld c, [hl]
	ld c, [hl]
	inc a
	nop
	nop
	inc a
	ld c, [hl]

.l_41aa:
	ld c, [hl]
	ld a, $0e
	inc a
	nop
	nop
	inc a
	ld c, [hl]
	ld c, [hl]
	ld a, [hl]
	ld c, [hl]
	ld c, [hl]
	nop
	nop
	ld a, h
	ld h, [hl]
	ld a, h
	ld h, [hl]
	ld h, [hl]
	ld a, h
	nop
	nop
	inc a
	ld h, [hl]
	ld h, b
	ld h, b
	ld h, [hl]
	inc a
	nop
	nop
	ld a, h
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld a, h
	nop
	nop
	ld a, [hl]
	ld h, b
	ld a, h
	ld h, b
	ld h, b

.l_41d5:
	ld a, [hl]
	nop
	nop
	ld a, [hl]
	ld h, b
	ld h, b
	ld a, h
	ld h, b
	ld h, b
	nop
	nop
	inc a
	ld h, [hl]
	ld h, b
	ld l, [hl]
	ld h, [hl]
	ld a, $00
	nop
	ld b, [hl]
	ld b, [hl]
	ld a, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	nop
	nop
	inc a
	jr .l_420b
	jr .l_420d
	inc a
	nop
	nop
	ld e, $0c
	inc c
	ld l, h
	ld l, h
	jr c, .l_41ff

.l_41ff:
	nop
	ld h, [hl]
	ld l, h
	ld a, b
	ld a, b
	ld l, h
	ld h, [hl]
	nop
	nop
	ld h, b
	ld h, b
	ld h, b

.l_420b:
	ld h, b
	ld h, b

.l_420d:
	ld a, [hl]
	nop
	nop
	ld b, [hl]
	ld l, [hl]
	ld a, [hl]
	ld d, [hl]
	ld b, [hl]
	ld b, [hl]
	nop
	nop
	ld b, [hl]
	ld h, [hl]
	halt
	ld e, [hl]
	ld c, [hl]
	ld b, [hl]
	nop
	nop
	inc a
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	inc a
	nop
	nop
	ld a, h
	ld h, [hl]
	ld h, [hl]
	ld a, h
	ld h, b
	ld h, b
	nop
	nop
	inc a
	ld h, d
	ld h, d
	ld l, d
	ld h, h
	ldd a, [hl]
	nop
	nop
	ld a, h
	ld h, [hl]
	ld h, [hl]
	ld a, h

.l_423c:
	ld l, b
	ld h, [hl]
	nop
	nop
	inc a
	ld h, b
	inc a
	ld c, $4e
	inc a
	nop
	nop
	ld a, [hl]
	jr .l_4263
	jr .l_4265
	jr .l_424f

.l_424f:
	nop
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld c, [hl]
	inc a
	nop
	nop
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	inc l
	jr .l_425f

.l_425f:
	nop
	ld b, [hl]
	ld b, [hl]
	ld d, [hl]

.l_4263:
	ld a, [hl]
	ld l, [hl]

.l_4265:
	ld b, [hl]
	nop
	nop
	ld b, [hl]
	inc l
	jr .l_42a4
	ld h, h
	ld b, d
	nop
	nop
	ld h, [hl]
	ld h, [hl]
	inc a
	jr .l_428d
	jr .l_4277

.l_4277:
	nop
	ld a, [hl]
	ld c, $1c
	jr c, .l_42ed
	ld a, [hl]
	nop
	nop
	nop
	nop
	nop
	nop
	ld h, b
	ld h, b
	nop
	nop
	nop
	nop
	inc a
	inc a
	nop

.l_428d:
	nop
	nop
	nop
	nop
	ldi [hl], a
	inc d
	ld [$2214], sp
	nop
	nop
	nop
	ld [hl], $36
	ld e, a
	ld c, c
	ld e, a
	ld b, c
	ld a, a
	ld b, c
	ld a, $22
	inc e

.l_42a4:
	inc d
	ld [$ff08], sp
	rst 38
	rst 38
	add a, c
	pop bc
	cp a
	pop bc
	cp a
	pop bc
	cp a
	pop bc
	cp a
	add a, c
	rst 38
	rst 38
	rst 38
	xor d
	xor d
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	rst 38
	nop
	rst 38
	ld b, b
	rst 38
	ld [bc], a

.l_42ed:
	rst 38
	nop
	rst 38
	stop
	rst 38
	add a, b
	rst 38
	ld [bc], a
	rst 38
	nop
	ldh a, [$ff00 + $10]
	rst 38
	rr a
	rst 38
	nop
	rst 38
	ld b, b
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	ld b, b
	rst 38
	nop
	rrc a
	ld [$f8ff], sp
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	nop
	rst 38
	ld b, b
	rst 38
	ld [bc], a
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	jr .l_4345
	jr c, .l_4367
	jr .l_4349
	jr .l_434b
	jr .l_434d
	inc a
	inc a
	nop
	nop
	nop
	nop
	inc a

.l_433c:
	inc a
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld a, $3e
	ld c, $0e

.l_4345:
	inc a
	inc a
	nop
	nop

.l_4349:
	nop
	nop

.l_434b:
	inc a
	inc a

.l_434d:
	ld c, [hl]
	ld c, [hl]
	inc a
	inc a
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	inc a
	inc a
	nop
	nop
	jr c, .l_4393
	ld b, h
	ld b, h
	cp d
	cp d
	and d
	and d
	cp d
	cp d
	ld b, h
	ld b, h
	jr c, .l_439f

.l_4367:
	add a, $c6
	and $e6
	and $e6
	sub a, $d6
	sub a, $d6
	adc a, $ce
	adc a, $ce
	add a, $c6
	ret nz
	ret nz
	ret nz
	ret nz
	nop
	nop
	<error>
	<error>
	<error>
	<error>
	reti
	reti
	reti
	reti
	reti
	reti
	nop
	nop
	jr nc, .l_43bb
	ld a, b
	ld a, b
	inc sp
	inc sp
	or [hl]
	or [hl]
	or a
	or a

.l_4393:
	or [hl]
	or [hl]
	or e
	or e
	nop
	nop
	nop
	nop
	nop
	nop
	call func_6ecd
	ld l, [hl]
	<error>
	<error>
	inc c
	inc c
	<error>
	<error>
	ld bc, $0101
	ld bc, $0101
	adc a, a
	adc a, a
	reti
	reti
	reti
	reti
	reti
	reti
	rst 8
	rst 8
	add a, b
	add a, b
	add a, b
	add a, b

.l_43bb:
	add a, b
	add a, b
	sbc a, [hl]
	sbc a, [hl]
	or e
	or e
	or e
	or e
	or e
	or e
	sbc a, [hl]
	sbc a, [hl]
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 28
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop

.l_43d5:
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 20
	nop
	rst 20
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	nop
	nop
	rst 38
	rst 38
	nop

.l_43f5:
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	ld bc, $02ff
	cp $fe
	ld [bc], a
	inc b
	<error>
	<error>
	inc b
	<error>
	inc b
	nop
	rst 38
	rst 38
	rst 38
	add a, b
	rst 38
	ld b, b
	ld a, a
	rst 38
	ld b, b
	ldh [$ff00 + $3f], a
	rst 38
	jr nz, .l_43d5
	ld h, b
	rst 38
	nop
	rst 38
	nop
	rst 38
	ld bc, $02fe
	cp $02
	<error>
	inc b
	<error>
	inc b
	<error>
	inc b
	rst 38
	nop
	rst 38
	nop
	rst 38
	add a, b
	ld a, a
	ld b, b
	rst 38
	ld b, b
	rst 38
	jr nz, .l_4433
	jr nz, .l_43f5
	ld h, b
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	rst 38
	ld [bc], a
	rst 38
	ld bc, $01ff
	rst 38
	ld bc, $01ff
	rst 38
	ld bc, $01ff
	rst 38
	ld bc, $c07f
	rst 38
	add a, b
	rst 38
	add a, b
	rst 38
	add a, b
	rst 38
	add a, b
	rst 38
	add a, b
	rst 38
	add a, b
	rst 38
	add a, b
	cp $02
	cp $02
	rst 38
	inc bc
	<error>
	dec b
	ldhl sp, d
	add hl, bc
	pop af
	ld [de], a
	pop hl
	ld h, $c3
	ld c, h
	ld a, a
	ret nz
	ld a, a
	ret nz
	rst 38
	ret nz
	cp a
	ld h, b
	sbc a, a
	ld [hl], b
	xor a
	ld e, b
	daa
	call c, func_ce33
	rst 38
	nop
	rst 38
	ld bc, $02fe
	<error>
	inc b
	ldhl sp, d
	add hl, bc
	ldh a, [$ff00 + $13]
	ldh [$ff00 + $27], a
	ldh [$ff00 + $2f], a
	add a, a
	sbc a, b
	ld b, $39
	ld c, $71
	ld e, $e1
	inc a
	jp .l_c33c
	ld a, b
	add a, a
	ld a, b
	add a, a
	dec [hl]
	swap d
	call func_c53a
	ld a, c
	add a, [hl]
	ld a, b
	add a, a
	ld a, b
	add a, a
	ld a, h
	add a, e
	ld a, h
	add a, e
	rst 38
	nop
	rst 38
	add a, b
	ld a, a
	ret nz
	ccf
	ldh [$ff00 + $9f], a
	ld [hl], b
	ld c, a
	cp b
	ld h, a
	sbc a, h
	scf
	call z, func_4fc0
	ret nz
	ld c, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	add a, b
	sbc a, a
	ldhl sp, d
	rlc a
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0f]
	ldhl sp, d
	rlc a
	ld a, h
	add a, e
	ld a, [hl]
	add a, c
	ld a, [hl]
	add a, c
	ld a, $c1
	ccf
	ret nz
	rr a
	ldh [$ff00 + $1f], a
	ldh [$ff00 + $1f], a
	ldh [$ff00 + $33], a
	adc a, $1b
	and $09
	rst 30
	dec c
	di
	dec c
	di
	dec c
	di
	dec c
	di
	add hl, bc
	rst 30
	ret nz
	ld e, a
	ret nz
	ld c, a
	ldh [$ff00 + $2f], a
	ldh [$ff00 + $27], a
	ldh a, [$ff00 + $11]
	cp a
	ld c, a
	inc c
	<error>
	rlc a
	rst 38
	ld a, b
	add a, a
	ld a, h
	add a, e
	inc a
	jp .l_e11e
	rrc a
	ldh a, [$ff00 + $ff]
	rst 38
	rst 38
	nop
	rst 38
	rst 38
	rrc a
	ldh a, [$ff00 + $0f]
	ldh a, [$ff00 + $0e]
	pop af
	ld c, $f1
	ld b, $f9
	rst 38
	rst 38
	push bc
	ccf
	rst 38
	rst 38
	dec de
	and $13
	xor $37
	call z, func_dc27
	ld c, a
	cp b
	<error>
	di
	<error>
	and e
	ldh [$ff00 + $ff], a
	cp $02
	cp $02
	cp a
	ld b, e
	inc e
	push hl
	cp b
	ld c, c
	or c
	ld d, d
	and c
	ld h, [hl]
	ld b, e
	call z, func_00ff
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 28
	stop
	rst 0
	jr c, .l_4567
	nop
	ei
	inc b
	ei
	inc b
	ei
	inc b
	ei
	inc b
	pop af
	ld c, $f1
	ld c, $f1
	ld c, $83
	ld a, h
	ld bc, $01fe
	cp $01
	cp $83
	ld a, h
	rst 38
	nop
	add a, e
	ld a, h
	add a, e
	ld a, h
	pop af
	ld c, $e0
	rr a
	ldh [$ff00 + $1f], a
	ldh [$ff00 + $1f], a
	ldh [$ff00 + $1f], a
	ldh [$ff00 + $1f], a
	add a, b
	ld a, a
	add a, b
	ld a, a
	rst 30
	ld [$14eb], sp
	rst 30
	ld [$08f7], sp
	<error>
	inc e
	<error>
	inc e
	ld h, e
	sbc a, h
	ld bc, $00fe
	nop
	ld h, b
	ld h, b
	ld [hl], b
	ld [hl], b
	ld a, b
	ld a, b
	ld a, b
	ld a, b
	ld [hl], b
	ld [hl], b
	ld h, b
	ld h, b
	nop
	nop
	nop
	nop
	jr nc, .l_45eb
	ld [hl], b
	ld [hl], b
	jr nc, .l_45ef
	jr nc, .l_45f1
	jr nc, .l_45f3
	ld a, b
	ld a, b
	nop
	nop
	ldh [$ff00 + $e0], a
	ldh a, [$ff00 + $e0]
	ei
	ldh [$ff00 + $fc], a
	ldh [$ff00 + $fc], a
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	nop
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	rlc a
	rlc a
	rrc a
	rlc a

.l_45eb:
	rst 18
	rlc a
	ccf
	rlc a

.l_45ef:
	ccf
	add a, a

.l_45f1:
	ccf
	add a, a

.l_45f3:
	ccf
	add a, a
	ccf
	add a, a
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	pop hl
	<error>
	ldh [$ff00 + $ff], a
	rst 20
	rst 38
	rst 28
	ldh [$ff00 + $ff], a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rst 38
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	ccf
	add a, a
	ccf
	rlc a
	rst 38
	rst 20
	rst 38
	rst 30
	rlc a
	rst 38
	ldhl sp, d
	nop
	ldh [$ff00 + $00], a
	ret nz
	nop
	add a, b
	nop
	add a, b
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld a, a
	nop
	rr a
	nop
	rrc a
	nop
	rlc a
	nop
	rlc a
	nop
	inc bc
	nop
	inc bc
	nop
	inc bc
	nop
	nop
	nop
	add a, b
	nop
	add a, b
	nop
	ret nz
	nop
	ldh [$ff00 + $00], a
	ldhl sp, d
	nop
	rst 38
	nop
	rst 38
	nop
	inc bc
	nop
	rlc a
	nop
	rlc a
	nop
	rrc a
	nop
	rr a
	nop
	ld a, a
	nop
	rst 38
	nop
	rst 38
	nop
	ld bc, $0101
	ld bc, $8181
	pop bc
	pop bc
	pop bc
	pop bc
	pop hl
	pop hl
	pop af
	pop af
	ld sp, hl
	ld sp, hl
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	cp $fe
	ld a, [hl]
	ld a, [hl]
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ccf
	ccf
	sbc a, a
	sbc a, a
	adc a, a
	adc a, a
	rst 8
	rst 8
	rst 20
	rst 20
	di
	di
	rst 30
	rst 30
	ldh [$ff00 + $e0], a
	ldh [$ff00 + $e0], a
	ldh [$ff00 + $e0], a
	ldh [$ff00 + $e0], a
	ldh [$ff00 + $e0], a
	ret nz
	ret nz
	ret nz
	ret nz
	add a, b
	add a, b
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $f0]
	nop
	nop
	ld a, h
	ld a, h
	ld b, a
	ld b, a
	ld b, c
	ld b, c
	ld b, b
	ld b, b
	ld b, b
	ld b, b
	ld b, b
	ld b, b
	ld a, a
	ld b, b
	nop
	nop
	ld bc, $0101
	ld bc, $8181
	pop bc
	pop bc
	ld b, c
	ld b, c
	ld h, c
	ld h, c
	pop hl
	ld h, c
	nop
	nop
	cp $fe
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	cp $06
	nop
	nop
	dec de
	dec de
	ldd [hl], a
	ldd [hl], a
	ld e, c
	ld e, c
	ld c, h
	ld c, h
	adc a, h
	adc a, h
	add a, [hl]
	add a, [hl]
	rst 38
	add a, e
	nop
	nop
	rst 38
	rst 38
	ld bc, $0101
	ld bc, $8181
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ccf
	ld hl, $0000
	cp [hl]
	cp [hl]
	adc a, b
	adc a, b
	adc a, b
	adc a, b
	adc a, b
	adc a, b
	adc a, b
	adc a, b
	add a, b
	add a, b
	add a, b
	add a, b
	nop
	nop
	adc a, b
	adc a, b
	ret c
	ret c
	xor b
	xor b
	adc a, b
	adc a, b
	adc a, b
	adc a, b
	nop
	nop
	nop
	nop
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ld b, a
	ld a, a
	pop hl
	ld h, c
	pop hl
	ld h, c
	pop hl
	ld h, c
	pop hl
	ld h, c
	pop hl
	ld h, c
	pop bc
	pop bc
	pop bc
	pop bc
	add a, c
	add a, c
	cp $06
	cp $06
	cp $06
	cp $06
	cp $06
	cp $06
	cp $06
	ld b, $fe
	rst 38
	add a, e
	rst 38
	add a, c
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	ccf
	jr nz, .l_47d3
	jr nz, .l_47a6
	rr a
	rr a
	ld de, $919f
	rst 8
	ret
	rst 0
	push bc
	<error>
	ld h, e
	di
	inc sp
	ld sp, hl
	add hl, de
	ld [$80f8], sp
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	ld e, a
	ld a, a
	ld a, b
	ld a, b
	ld h, b
	ld h, b
	ld d, b
	ld [hl], b
	ld d, b
	ld [hl], b
	ld c, b
	ld a, b
	ld b, h
	ld a, h
	ld a, [hl]
	ld a, [hl]
	ld bc, $0101
	ld bc, $0101
	ld bc, $0101
	ld bc, $0101

.l_47d3:
	ld bc, $0101
	ld bc, $fe06
	ld b, $fe
	ld b, $fe
	ld b, $fe
	ld b, $fe
	ld b, $fe
	ld b, $fe
	cp $fe
	ld [$440f], sp
	ld b, a
	ld h, h
	ld h, a
	ld [hl], d
	ld [hl], e
	ld d, c
	ld [hl], c
	ld e, c
	ld a, c
	ld c, h
	ld a, h
	ld a, [hl]
	ld a, [hl]
	inc c
	<error>
	ld b, $fe
	inc bc
	rst 38
	ld bc, $01ff
	rst 38
	nop
	rst 38
	add a, b
	rst 38
	ld a, a
	ld a, a
	nop
	nop
	nop
	nop
	nop
	nop
	add a, b
	add a, b
	add a, b
	add a, b
	ret nz
	ret nz
	ret nz
	ret nz
	ldh [$ff00 + $e0], a
	ld a, [hl]
	ld a, [hl]
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	ld a, a
	nop
	nop
	inc bc
	inc bc
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	inc bc
	ld [bc], a
	nop
	nop
	ei
	ei
	ld a, [bc]
	ld a, [bc]
	ld [de], a
	ld [de], a
	ldi [hl], a
	ldi [hl], a
	ldi [hl], a
	ldi [hl], a
	ld b, d
	ld b, d
	jp .l_0042
	nop
	<error>
	<error>
	dec c
	dec c
	inc c
	inc c
	inc c
	inc c
	inc c
	inc c
	inc c
	inc c
	<error>
	inc c
	nop
	nop
	<error>
	<error>
	inc c
	inc c
	adc a, h
	adc a, h
	ld c, h
	ld c, h
	ld c, h
	ld c, h
	inc l
	inc l
	inc a
	inc l
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	inc bc
	inc bc
	inc bc
	ld [bc], a
	ld [bc], a
	nop
	nop
	nop
	nop
	nop
	nop
	add a, e
	add a, d
	add a, e
	add a, d
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	ld [bc], a
	inc bc
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	inc c
	<error>
	inc e
	inc e
	inc e
	inc e
	inc c
	inc c
	inc c
	inc c
	inc b
	inc b
	nop
	nop
	nop
	nop
	nop
	nop
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	inc bc
	inc bc
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	inc c
	<error>
	<error>
	<error>
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	<error>
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	ld bc, $0301
	inc bc
	rlc a
	rlc a
	rrc a
	rrc a
	rr a
	rr a
	ccf
	ccf
	ld a, a
	ld a, a
	nop
	nop
	rst 38
	rst 38
	add a, e
	add a, e
	add a, e
	add a, e
	add a, e
	add a, e
	add a, e
	add a, e
	add a, e
	add a, e
	rst 38
	add a, e
	nop
	nop
	ld a, a
	ld a, a
	jr nz, .l_495d
	stop
	stop
	ld [$0408], sp
	inc b
	ld [bc], a
	ld [bc], a
	ld bc, $0001
	nop
	di
	di
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	ldd [hl], a
	di
	ldd [hl], a
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e

.l_495d:
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e
	add a, e
	rst 38
	nop
	nop
	nop
	nop
	ld bc, $0301
	inc bc
	rlc a
	rlc a
	rrc a
	dec bc
	rr a
	inc de
	inc hl
	ccf
	di
	or d
	ld [hl], e
	ld [hl], d
	inc sp
	inc sp
	inc de
	inc de
	ld [bc], a
	ld [bc], a
	nop
	nop
	nop
	nop
	nop
	nop
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	add a, e
	rst 38
	rst 38
	rst 38
	ld b, e
	ld a, a
	inc hl
	ccf
	inc de
	rr a
	dec bc
	rrc a
	rlc a
	rlc a
	inc bc
	inc bc
	ld bc, $0001
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	stop
	stop
	jr nc, .l_49e5
	ld [hl], b
	ld [hl], b
	nop
	nop
	ld a, b
	ld a, b
	sbc a, h
	sbc a, h
	inc e
	inc e
	ld a, b
	ld a, b
	ldh [$ff00 + $e0], a
	<error>
	<error>
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec de
	dec de
	dec de
	dec de
	add hl, bc
	add hl, bc
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

.l_49e5:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	jr nz, .l_4a15
	nop
	nop
	dec de
	dec de
	dec de
	dec de
	add hl, bc
	add hl, bc
	nop
	nop
	nop
	nop
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	nop
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl

.l_4a15:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	sbc a, e
	dec e
	ld d, $2f
	ld a, [bc]
	rl a
	dec c
	cpl
	inc sp
	ld bc, $0809
	rlc a
	cpl
	ld c, $15
	jr .l_4a48
	stop
	sbc a, h
	cpl
	dec e
	ld c, $1d
	dec de
	ld [de], a
	inc e
	cpl
	dec d
	ld [de], a
	inc c
	ld c, $17
	inc e
	ld c, $0d
	cpl
	dec e
	jr .l_4a72
	cpl
	cpl
	cpl
	cpl
	dec bc

.l_4a48:
	ld e, $15
	dec d
	ld c, $1d
	dec h
	add hl, de
	dec de
	jr .l_4a6a
	rrc a
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	inc e
	jr .l_4a6d
	dec e
	jr nz, .l_4a6b
	dec de
	ld c, $2f
	ld a, [bc]
	rl a
	dec c
	cpl
	cpl
	cpl

.l_4a6a:
	cpl

.l_4a6b:
	cpl
	cpl

.l_4a6d:
	cpl
	inc e
	ld e, $0b
	dec h

.l_4a72:
	dec d
	ld [de], a
	inc c
	ld c, $17
	inc e
	ld c, $0d
	cpl
	dec e
	jr .l_4aad
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	rl a
	ld [de], a
	rl a
	dec e
	ld c, $17
	dec c
	jr .l_4ab2
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	inc sp
	ld bc, $0809
	add hl, bc

.l_4aad:
	cpl
	dec bc
	ld e, $15
	dec d

.l_4ab2:
	ld c, $1d
	dec h
	add hl, de
	dec de
	jr .l_4ad1
	rrc a
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	inc e
	jr .l_4ad3
	dec e
	jr nz, .l_4ad1
	dec de
	ld c, $24
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl

.l_4ad1:
	cpl
	inc sp

.l_4ad3:
	jr nc, .l_4b06
	ldd [hl], a
	ld sp, $342f
	dec [hl]
	ld [hl], $37
	jr c, .l_4b17
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, [bc]
	dec d
	dec d
	cpl
	dec de
	ld [de], a
	stop
	ld de, $1c1d
	cpl
	dec de
	ld c, $1c
	ld c, $1b
	rr a
	ld c, $0d
	inc h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl

.l_4b17:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	jr .l_4b3e
	ld [de], a
	stop
	ld [de], a
	rl a
	ld a, [bc]
	dec d
	cpl
	inc c
	jr .l_4b44
	inc c
	ld c, $19
	dec e
	sbc a, h
	cpl
	cpl
	dec c
	ld c, $1c
	ld [de], a
	stop
	rl a
	cpl
	ld a, [bc]
	rl a
	dec c

.l_4b3e:
	cpl
	add hl, de
	dec de
	jr .l_4b53
	dec de

.l_4b44:
	ld a, [bc]
	ld d, $2f
	dec bc
	ldi [hl], a
	cpl
	ld a, [bc]
	dec d
	ld c, $21
	ld c, $22
	cpl
	add hl, de
	ld a, [bc]

.l_4b53:
	inc hl
	ld de, $1d12
	rl a
	jr .l_4b79
	sbc a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]

.l_4b79:
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	ld e, d
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, e
	ld e, h
	ld e, l
	add a, b
	add a, c
	add a, d
	add a, e
	sub a, b
	sub a, c
	sub a, d
	add a, c
	add a, d
	add a, e
	sub a, b
	ld l, h
	ld l, l
	ld l, [hl]
	ld l, a
	ld [hl], b
	ld [hl], c
	ld [hl], d
	ld e, [hl]
	ld e, l
	add a, h
	add a, l
	add a, [hl]
	add a, a
	sub a, e
	sub a, h
	sub a, l
	add a, l
	add a, [hl]
	add a, a
	sub a, e
	ld [hl], e
	ld [hl], h
	ld [hl], l
	halt
	ld [hl], a
	ld a, b
	cpl
	ld e, [hl]
	ld e, l
	cpl
	adc a, b
	adc a, c
	cpl
	sub a, [hl]
	sub a, a
	sbc a, b
	adc a, b
	adc a, c
	cpl
	sub a, [hl]
	ld a, c
	ld a, d
	ld a, e
	ld a, h
	ld a, l
	ld a, [hl]
	cpl
	ld e, [hl]
	ld e, l
	cpl
	adc a, d
	adc a, e
	cpl
	adc a, [hl]
	adc a, a
	ld l, e
	adc a, d
	adc a, e
	cpl
	adc a, [hl]
	ld a, a
	ld h, [hl]
	ld h, a
	ld l, b
	ld l, c
	ld l, d
	cpl
	ld e, [hl]
	ld e, a
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, c
	adc a, [hl]
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	inc a
	dec a
	ld a, $3c
	inc a
	inc a
	adc a, [hl]
	adc a, [hl]
	adc a, h
	adc a, h
	ld h, d
	ld h, e
	adc a, h
	adc a, h
	ldd a, [hl]
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	ldd a, [hl]
	ld b, d
	ld b, e
	dec sp
	adc a, h
	adc a, h
	adc a, [hl]
	adc a, [hl]
	ldd a, [hl]
	adc a, h
	ld h, h
	ld h, l
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	dec sp
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	ld b, h
	ld b, l
	adc a, h
	adc a, h
	adc a, h
	adc a, [hl]
	adc a, [hl]
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	ld b, [hl]
	ld b, a
	ld c, b
	ld c, c
	ccf
	ld b, b
	adc a, [hl]
	adc a, [hl]
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	ldd a, [hl]
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	ld d, e
	ld d, h
	adc a, h
	ld c, d
	ld c, e
	ld c, h
	ld c, l
	ld b, d
	ld b, e
	adc a, [hl]
	adc a, [hl]
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	ld d, h
	ld d, l
	ld d, [hl]
	ld d, a
	ld c, [hl]
	ld c, a
	ld d, b
	ld d, c
	ld d, d
	ld b, l
	adc a, [hl]
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	ld b, c
	cpl
	cpl
	ld e, c
	add hl, de
	dec d
	ld a, [bc]
	ldi [hl], a
	ld c, $1b
	cpl
	cpl
	cpl
	sbc a, c
	add hl, de
	dec d
	ld a, [bc]
	ldi [hl], a
	ld c, $1b
	cpl
	cpl
	cpl
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	cpl
	cpl
	cpl
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	sbc a, d
	cpl
	cpl
	cpl
	cpl
	cpl
	inc sp
	jr nc, .l_4ce7
	ldd [hl], a
	ld sp, $342f
	dec [hl]
	ld [hl], $37
	jr c, .l_4cf8
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld b, a
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b

.l_4ce7:
	ld c, b
	ld c, b
	ld c, b
	ld c, c
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l

.l_4cf8:
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, e
	stop
	ld a, [bc]
	ld d, $0e
	cpl
	dec e
	ldi [hl], a
	add hl, de
	ld c, $54
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	ld d, l
	ld d, [hl]
	ld l, l
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	xor c
	ld e, b
	ld e, b
	ld e, b
	ld l, [hl]
	ld d, [hl]
	ld d, [hl]
	ld e, d
	inc l
	ld c, e
	ld c, d
	inc l
	ld e, e
	ld a, b
	ld [hl], a
	ld a, [hl]
	ld a, a
	sbc a, d
	sbc a, e
	cpl
	xor d
	ld a, c
	ld [hl], a
	ld a, [hl]
	ld a, a
	sbc a, d
	sbc a, e
	ld e, h
	inc l
	ld c, e
	ld c, d
	inc l
	dec l
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	xor h
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld l, $2c
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, e
	ld d, $1e
	inc e
	ld [de], a
	inc c
	cpl
	dec e
	ldi [hl], a
	add hl, de
	ld c, $54
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	ld d, l
	ld d, [hl]
	ld l, l
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	xor c
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld l, [hl]
	ld d, [hl]
	ld e, d
	inc l
	ld c, e
	ld c, d
	inc l
	ld e, e
	ld a, b
	ld [hl], a
	ld a, [hl]
	ld a, a
	sbc a, d
	sbc a, e
	cpl
	xor d
	ld a, c
	ld [hl], a
	ld a, [hl]
	ld a, a
	sbc a, d
	sbc a, e
	ld e, h
	inc l
	ld c, e
	ld c, d
	inc l
	ld [hl], c
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], d
	xor e
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], d
	ld [hl], h
	inc l
	ld c, e
	ld c, d
	inc l
	ld e, e
	ld a, d
	ld [hl], a
	ld a, [hl]
	ld a, a
	sbc a, d
	sbc a, e
	cpl
	xor d
	cpl
	sbc a, l
	sbc a, h
	sbc a, h
	cpl
	cpl
	ld e, h
	inc l
	ld c, e
	ld c, d
	inc l
	dec l
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	xor h
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld l, $2c
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, h
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, [hl]
	ld b, a
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, c
	ld c, d
	cpl
	ld a, [bc]
	dec h
	dec e
	ldi [hl], a
	add hl, de
	ld c, $2f
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	ld d, e
	dec d
	ld c, $1f
	ld c, $15
	ld d, h
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, l
	ld d, [hl]
	ld d, a
	ld e, b
	ld l, h
	ld e, b
	ld l, h
	ld e, b
	ld e, c
	ld d, [hl]
	ld e, d
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld e, e
	sub a, b
	ld l, a
	sub a, c
	ld l, a
	sub a, d
	ld l, a
	sub a, e
	ld l, a
	sub a, h
	ld e, h
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld [hl], c
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], h
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld e, e
	sub a, l
	ld l, a
	sub a, [hl]
	ld l, a
	sub a, a
	ld l, a
	sbc a, b
	ld l, a
	sbc a, c
	ld e, h
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	dec l
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, $2c
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, e
	dec e
	jr .l_4f3c
	dec h
	inc e
	inc c
	jr .l_4f43
	ld c, $54
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	ld d, l
	ld d, [hl]
	ld [hl], b
	ld l, l
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b

.l_4f3c:
	ld e, b
	ld l, [hl]
	ld d, [hl]
	ld d, [hl]
	ld d, [hl]
	ld e, d
	ld c, e

.l_4f43:
	ld c, d
	ld e, e
	ld bc, $606f
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	cpl
	cpl
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld e, h
	ld c, e
	ld c, d
	ld e, e
	ld [bc], a
	ld l, a
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	cpl
	cpl
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld e, h
	ld c, e
	ld c, d
	ld e, e
	inc bc
	ld l, a
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	cpl
	cpl
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld e, h
	ld c, e
	ld c, d
	dec l
	ld c, a
	ld l, e
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld l, $4b
	ld c, h
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, [hl]
	ld b, a
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, c
	ld c, d
	cpl
	dec bc
	dec h
	dec e


func_4fc0::
	ldi [hl], a
	add hl, de
	ld c, $2f
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld d, e
	dec d
	ld c, $1f
	ld c, $15
	ld d, h
	inc l
	inc l
	ld d, e
	ld de, $1012
	ld de, $2c54
	ld c, e
	ld c, d
	ld d, l
	ld d, [hl]
	ld d, a
	ld e, b
	ld l, h
	ld e, b
	ld l, h
	ld e, b
	ld e, c
	ld d, [hl]
	ld e, d
	ld [hl], l
	ld e, b
	ld l, h
	ld e, b
	ld l, h
	ld l, [hl]
	ld e, d
	ld c, e
	ld c, d
	ld e, e
	sub a, b
	ld l, a
	sub a, c
	ld l, a
	sub a, d
	ld l, a
	sub a, e
	ld l, a
	sub a, h
	ld e, h
	ld e, e
	sub a, b
	ld l, a
	sub a, c
	ld l, a
	sub a, d
	ld e, h
	ld c, e
	ld c, d
	ld [hl], c
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], h
	ld [hl], c
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], h
	ld c, e
	ld c, d
	ld e, e
	sub a, l
	ld l, a
	sub a, [hl]
	ld l, a
	sub a, a
	ld l, a
	sbc a, b
	ld l, a
	sbc a, c
	ld e, h
	ld e, e
	sub a, e
	ld l, a
	sub a, h
	ld l, a
	sub a, l
	ld e, h
	ld c, e
	ld c, d
	dec l
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, $2d
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, $4b
	ld c, d
	inc l
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	ld d, e
	dec e
	jr .l_50a4
	dec h
	inc e
	inc c
	jr .l_50ab
	ld c, $54
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	ld d, l
	ld d, [hl]
	ld [hl], b
	ld l, l
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b
	ld e, b

.l_50a4:
	ld e, b
	ld l, [hl]
	ld d, [hl]
	ld d, [hl]
	ld d, [hl]
	ld e, d
	ld c, e

.l_50ab:
	ld c, d
	ld e, e
	ld bc, $606f
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	cpl
	cpl
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld e, h
	ld c, e
	ld c, d
	ld e, e
	ld [bc], a
	ld l, a
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	cpl
	cpl
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld e, h
	ld c, e
	ld c, d
	ld e, e
	inc bc
	ld l, a
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	cpl
	cpl
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld e, h
	ld c, e
	ld c, d
	dec l
	ld c, a
	ld l, e
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld c, a
	ld l, $4b
	ld c, h
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, [hl]
	call func_cdcd
	call func_cdcd
	call func_cdcd
	call func_c98c
	jp z, .l_8c8c
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	set 1, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, h
	adc a, $d7
	rst 10
	rst 10
	rst 10
	rst 10
	rst 10
	rst 10
	rst 10
	rst 10
	rst 8
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ret nc
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	pop de
	jp nc, .l_2f2f
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	<error>
	call nc, func_7c7c
	ld a, h
	ld a, h
	ld a, h
	ld a, h
	cpl
	cpl
	push de
	sub a, $7d
	ld a, l
	ld a, l
	ld a, l
	cpl
	cpl
	cpl
	cpl
	ret c
	cpl
	ld a, e
	ld a, e
	ld a, e
	ld a, e
	cpl
	cpl
	cpl
	cpl
	ret c
	cpl
	ld a, h
	ld a, h
	ld a, h
	ld a, h
	cpl
	cpl
	cpl
	cpl
	ret c
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ret c
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld a, h
	ld a, h
	ld a, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, h
	ld a, l
	ld a, l
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, l
	cpl
	cpl
	cpl
	reti
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, e
	or a
	cp b
	reti
	or a
	cpl
	ld a, h
	ld a, h
	ld a, h
	ld a, h
	ld a, h
	ld a, l
	ld a, l
	ld a, l
	ld a, l
	ld a, l
	ld a, l
	ld a, l
	ld a, l
	ld a, l
	ld a, l
	rst 38
	ld c, d
	ld c, d
	ld c, d
	ld c, d
	ld c, d
	ld c, d
	ld e, c
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld c, c
	ld c, d
	ld c, d
	ld c, d
	ld c, d
	ld c, d
	ld c, d
	ld e, d
	ld e, d
	ld e, d
	ld e, d
	ld e, d
	ld e, d
	add a, l
	add a, l
	add a, l
	add a, l
	add a, l
	add a, l
	add a, l
	add a, l
	ld e, d
	ld e, d
	jr c, .l_5223
	jr c, .l_5246
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	ld l, d
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	ld b, a
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b

.l_5223:
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ld c, c
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld d, $0a
	dec de
	ld [de], a
	jr .l_5274
	rr a

.l_5246:
	inc e
	inc h
	dec d
	ld e, $12
	stop
	ld [de], a
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld d, e
	ld de, $1012
	ld de, $2c54
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld d, l
	ld d, [hl]
	ld d, [hl]
	ld e, d
	inc l
	inc l
	inc l
	ld [hl], l
	ld e, b
	ld l, h
	ld e, b
	ld l, h
	ld l, [hl]
	ld e, d
	inc l
	inc l
		ld c, e
	ld c, d
	inc l
	inc l
	ld e, e
	cpl
	cpl
	ld e, h
	inc l
	inc l
	inc l
	ld e, e
	sub a, b
	ld l, a
	sub a, c
	ld l, a
	sub a, d
	ld e, h
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld e, e
	cpl
	cpl
	ld e, h
	inc l
	inc l
	inc l
	ld [hl], c
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], h
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	dec l
	ld c, a
	ld c, a
	ld l, $2c
	inc l
	inc l
	ld e, e
	sub a, e
	ld l, a
	sub a, h
	ld l, a
	sub a, l
	ld e, h
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld d, $0a
	dec de
	ld [de], a
	jr .l_52fd
	inc l
	dec l
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, $2c
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld d, b
	ld d, c
	ld d, c
	ld d, c
	ld d, c
	ld d, d
	inc l
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	inc l
	ld d, e
	ld de, $1012
	ld de, $2c54
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld d, l
	ld d, [hl]
	ld d, [hl]
	ld e, d
	inc l
	inc l
	inc l
	ld [hl], l
	ld e, b
	ld l, h
	ld e, b
	ld l, h
	ld l, [hl]
	ld e, d
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld e, e
	cpl
	cpl
	ld e, h
	inc l
	inc l
	inc l
	ld e, e
	sub a, b
	ld l, a
	sub a, c
	ld l, a
	sub a, d
	ld e, h
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	ld e, e
	cpl
	cpl
	ld e, h
	inc l
	inc l
	inc l
	ld [hl], c
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], e
	ld [hl], d
	ld [hl], h
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	dec l
	ld c, a
	ld c, a
	ld l, $2c
	inc l
	inc l
	ld e, e
	sub a, e
	ld l, a
	sub a, h
	ld l, a
	sub a, l
	ld e, h
	inc l
	inc l
	ld c, e
	ld c, d
	inc l
	inc l
	dec d
	ld e, $12
	stop
	ld [de], a
	inc l
	inc l
	dec l
	ld c, a
	ld l, e
	ld c, a
	ld l, e
	ld c, a
	ld l, $2c
	inc l
	ld c, e
	ld c, h
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, l
	ld c, [hl]
	adc a, [hl]
	or d
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or e
	jr nc, .l_53bc
	ld sp, $3131
	ld sp, $8e32
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	adc a, [hl]
	or b
	cpl
	cpl

.l_53bc:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	ld b, b
	ld b, d
	ld b, d
	ld b, d
	ld b, d
	ld b, d
	ld b, c
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	ld [hl], $11
	ld [de], a
	stop
	ld de, $372f
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	inc sp
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	dec [hl]
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	dec hl
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	jr nc, .l_545c
	ld sp, $3131
	ld sp, $8e32
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	ld [hl], $15
	ld [de], a
	rl a
	ld c, $1c
	scf
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	ld [hl], $2f
	cpl
	cpl
	cpl
	cpl
	scf
	adc a, [hl]
	or b
	cpl
	cpl

.l_545c:
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	inc sp
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	dec [hl]
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	dec hl
	jr c, .l_54b5
	add hl, sp
	add hl, sp
	add hl, sp

.l_547f:
	ldd a, [hl]
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l

.l_54b5:
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	adc a, [hl]
	or b
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or l
	dec hl
	dec sp
	cpl
	cpl
	cpl
	cpl
	inc a
	adc a, [hl]
	or c
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	or h
	dec hl
	dec a
	ld a, $3e
	ld a, $3e
	ccf
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	add a, h
	add a, a
	add a, a
	adc a, h
	add a, a
	add a, a
	adc a, h
	add a, a
	add a, a
	adc a, h
	add a, a
	add a, a
	add a, [hl]
	rlc a
	rlc a
	ld e, $1e
	ld e, $1e
	ld e, $79
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, b
	rlc a
	rlc a
	or h
	or l
	cp e
	ld l, $bc
	ld a, c
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, b
	rlc a
	rlc a
	cp a
	cp a
	cp a
	cp a
	cp a
	adc a, c
	adc a, d
	adc a, d
	adc a, [hl]
	adc a, d
	adc a, d
	adc a, [hl]
	adc a, d
	adc a, d
	adc a, [hl]
	adc a, d
	adc a, d
	adc a, e
	rlc a
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	ld d, $16
	ld d, $16
	ld d, $16
	ld d, $16
	ld d, $16
	ld d, $16
	ld d, $16
	ld d, $16
	ld d, $16
	ld d, $16
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	rlc a
	add a, h
	add a, a
	add a, a
	adc a, h
	add a, a
	add a, a
	adc a, h
	add a, a
	add a, a
	adc a, h
	add a, a
	add a, a
	add a, [hl]
	rlc a
	rlc a
	ld e, $1e
	ld e, $1e
	ld e, $79
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, b
	rlc a
	rlc a
	cp l
	or d
	ld l, $be
	ld l, $79
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, l
	cpl
	cpl
	adc a, b
	rlc a
	rlc a
	cp a
	cp a
	cp a
	cp a
	cp a
	adc a, c
	adc a, d
	adc a, d
	adc a, [hl]
	adc a, d
	adc a, d
	adc a, [hl]
	adc a, d
	adc a, d
	adc a, [hl]
	adc a, d
	adc a, d
	adc a, e
	rlc a
	ld bc, $0101
	ld bc, $0101
	ld [bc], a
	ld [bc], a
	inc bc
	inc bc
	ld bc, $0101
	ld bc, $0202
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rlc a
	rlc a
	jr .l_55e7
	ld hl, $473e
	ld a, a
	<error>
	cp $12
	ld e, $12
	ld e, $12
	ld e, $7e
	ld a, [hl]
	rst 38
	add a, e
	rst 38
	add a, c
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rlc a
	rlc a
	jr .l_5607
	ld hl, $473e
	ld a, a
	inc b
	<error>
	ld [bc], a
	cp $02
	cp $07
	<error>
	rlc a
	<error>
	rr a
	rst 38
	rst 38
	rst 38
	rst 38
	ld a, [$0000]
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

.l_5607:
	nop
	rlc a
	rlc a
	jr .l_562b
	rst 38
	rst 38
	ld [hl], a
	ld de, $11ff
	rst 38
	rst 38
	<error>
	ld b, h
	rst 38
	ld b, h
	rst 38
	rst 38
	ld [hl], a
	ld de, $ffff
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38

.l_562b:
	rst 38
	nop
	nop
	inc bc
	inc bc
	dec b
	inc b
	inc bc
	inc bc
	nop
	nop
	jr .l_5650
	inc l
	inc h
	ld a, [de]
	ld a, [de]
	ld [$4008], sp
	ld b, b
	rlc a
	rlc a
	jr .l_5663
	and b
	cp a
	dec sp
	ccf
	ld a, h
	ld b, h
	ld a, h
	ld b, h

.l_564c:
	stop
	stop
	ld [bc], a
	ld [bc], a

.l_5650:
	ldh [$ff00 + $e0], a
	jr .l_564c
	dec b
	<error>
	adc a, h
	<error>
	ld a, b
	ld c, b
	ld l, h
	ld [hl], h
	nop
	nop
	rlc a
	rlc a
	jr .l_5681
	jr nz, .l_56a3
	jr nc, .l_56a5
	rr a
	dec e
	ld a, $22
	ld a, $22
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	nop
	nop
	ret nz
	ret nz
	ldh [$ff00 + $e0], a
	ldh [$ff00 + $e0], a
	nop
	nop
	ld a, h
	ld a, h
	ld h, [hl]

.l_5681:
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld a, h
	ld a, h
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	nop
	nop
	nop
	nop
	inc a
	inc a
	ld h, b
	ld h, b
	inc a
	inc a
	ld c, $0e
	ld c, [hl]
	ld c, [hl]
	inc a
	inc a
	nop
	nop
	rlc a
	rlc a
	rr a
	jr .l_56df
	jr nz, .l_5722

.l_56a3:
	ld c, a
	ld a, a

.l_56a5:
	ld e, a
	ld [hl], b
	ld [hl], b
	and d
	and d
	or b
	or b
	inc b
	inc b
	rlc a
	inc b
	inc b
	inc b
	inc b
	dec c
	inc b
	dec c
	inc b
	inc b
	inc b
	inc b
	inc bc
	ld [bc], a
	ld e, a
	ld a, a
	add hl, sp
	jr nc, .l_573c
	ld h, d
	ei
	or d
	rst 38
	and b
	rst 38
	jp nz, .l_547f
	ld a, a
	ld e, h
	nop
	nop
	nop
	nop
	nop
	nop
	inc bc
	inc bc
	inc b
	inc b
	ld [$0908], sp
	add hl, bc
	inc b
	inc b
	ld e, a
	ld a, a
	add hl, sp

.l_56df:
	jr nc, .l_575c
	ld h, d
	ei
	or d
	rst 38
	and b

.l_56e6:
	rst 38
	jp nz, .l_547f
	ld a, a
	ld e, h
	jr .l_56e6
	inc b
	<error>
	ld [bc], a
	cp $02
	cp $07
	<error>
	rlc a
	<error>
	rst 38
	rst 38
	rst 38
	ld a, [$3f20]
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ldh [$ff00 + $bf], a
	ldh [$ff00 + $bf], a
	ldhl sp, d
	rst 38
	ld a, a
	ld a, a
	ld a, a
	ld e, a
	rst 38
	ld de, $ffff
	<error>
	ld b, h
	rst 38
	ld b, h
	rst 38
	rst 38
	ld [hl], a
	ld de, $11ff
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop

.l_5722:
	nop
	nop
	nop
	nop
	nop
	nop
	add a, b
	add a, b
	ret nz
	ld b, b
	nop
	nop
	nop
	nop
	nop
	nop
	inc b
	inc b
	ld [$1c08], sp
	inc d
	inc d
	inc d
	ld [$1808], sp
	rr a
	jr nz, .l_577f
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ldh [$ff00 + $bf], a
	ldh [$ff00 + $bf], a
	ld a, a
	ld a, a
	ld a, a
	ld e, a
	<error>
	ld b, h
	rst 38
	ld b, h
	rst 38
	rst 38
	ld [hl], a
	ld de, $11ff
	rst 38
	rst 38
	<error>
	ld b, h
	rst 38
	ld b, h

.l_575c:
	nop
	nop
	nop
	nop
	nop
	nop
	jr nz, .l_5784
	stop
	stop
	jr c, .l_5790
	jr z, .l_5792
	sub a, b
	sub a, b
	nop
	nop
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld a, [hl]
	ld a, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	nop
	nop
	nop
	nop
	ld a, [hl]

.l_577f:
	ld a, [hl]
	jr .l_579a
	jr .l_579c

.l_5784:
	jr .l_579e
	jr .l_57a0
	jr .l_57a2
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38

.l_5790:
	rst 38
	rst 38

.l_5792:
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop

.l_579a:
	nop
	xor $b4
	or h

.l_579e:
	ld h, h
	ld h, h

.l_57a0:
	inc a
	inc a

.l_57a2:
	ld l, $2e
	daa
	daa
	ld [hl], b
	ld [hl], b
	<error>
	sbc a, h
	rst 30
	sbc a, a
	nop
	nop
	nop
	nop
	nop
	nop
	ld bc, $0101
	ld bc, $0202
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ccf
	ld l, $7f
	ld h, e
	rst 38
	sbc a, b
	rst 30
	rr a
	rst 30
	inc e
	rst 30
	rst 10
	inc [hl]
	ccf
	xor h
	cp a
	inc bc
	inc bc
	ld bc, $0101
	ld bc, $0000
	nop
	nop
	ld b, $06
	dec b
	dec b

.l_57da:
	rlc a
	rlc a
	rst 38
	xor [hl]
	rst 38
	inc hl
	rst 38
	jr .l_57da
	sbc a, a
	rst 30
	sbc a, h
	ld [hl], a
	ld d, a
	inc [hl]
	ccf
	ld l, h
	ld a, a
	nop
	nop
	nop
	nop
	nop
	nop
	ld bc, $0101
	ld bc, $0202
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ccf
	cpl
	ld a, a
	ld a, h
	rst 30
	sbc a, h
	di
	rr a
	ldh a, [$ff00 + $1f]
	ldh a, [$ff00 + $df]
	jr nc, .l_5849
	and b
	cp a
	rst 38
	<error>
	rst 38
	ld a, $ef
	jr c, .l_57e2
	ldhl sp, d
	rrc a
	ei
	ld c, $fa
	inc c
	<error>
	inc b
	<error>
	ldh [$ff00 + $20], a
	ldh [$ff00 + $20], a
	ldh [$ff00 + $20], a

.l_5822:
	ret nz
	ld b, b
	add a, b
	add a, b
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld bc, $0101
	ld bc, $0202
	ld [bc], a
	ld [bc], a
	ccf
	cpl
	ccf
	inc a
	ld [hl], a
	ld e, h
	di
	sbc a, a
	ldh a, [$ff00 + $1f]
	ldh a, [$ff00 + $1f]
	ldh a, [$ff00 + $ff]
	jr nz, .l_588b
	rst 38
	<error>
	rst 38
	ld a, $ef
	jr c, .l_5822
	ld sp, hl
	ld c, $fa
	ld c, $fa
	inc c
	<error>
	inc b
	<error>
	ret nz
	ld b, b
	ret nz
	ld b, b
	ret nz
	ld b, b
	add a, b
	add a, b
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rst 30
	inc e
	rst 30
	inc [hl]
	rst 30
	cp a
	ld l, h
	ld a, a
	stop
	rr a
	ld d, b
	ld e, a
	ldd [hl], a
	ccf
	pop af
	rst 38
	nop
	nop
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld d, [hl]
	ld d, [hl]
	ld a, [hl]
	ld a, [hl]
	ld l, [hl]
	ld l, [hl]
	ld b, [hl]
	ld b, [hl]
	nop

.l_588b:
	nop
	nop
	nop
	inc a
	inc a
	jr .l_58aa
	jr .l_58ac
	jr .l_58ae
	jr .l_58b0
	inc a
	inc a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

.l_58aa:
	nop
	nop

.l_58ac:
	ld [bc], a
	ld [bc], a

.l_58ae:
	ld bc, $0001
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld b, b
	ld a, a
	ret nz
	rst 38
	jr nz, .l_5901
	ldi [hl], a
	ccf
	ld de, $721f
	ld a, [hl]
	cp a
	cp a
	rst 38
	rst 38
	rlc a
	rlc a
	ld b, $07
	ld b, $07
	ld b, $07
	rlc a
	rlc a
	nop
	nop
	nop
	nop
	nop
	nop
	ret nz
	rst 38
	nop
	rst 38
	nop
	rst 38
	ld [bc], a
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	ld [bc], a
	ld [bc], a
	ld bc, $0001
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld b, b
	ld a, a
	ret nz
	rst 38
	jr nz, .l_5941
	jr nz, .l_5943
	ld de, $721f
	ld a, [hl]
	rst 38
	rst 38
	rst 38
	rst 38
	ld [bc], a
	cp $02
	cp $04
	<error>
	inc b
	<error>
	adc a, b
	ldhl sp, d
	ld c, [hl]
	ld a, [hl]
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	add a, b
	add a, b
	ld b, b
	ld b, b
	nop
	nop
	nop
	nop
	nop
	nop
	rlc a
	rlc a
	nop
	nop
	nop
	nop
	rst 38
	nop
	<error>
	ld [bc], a
	call func_0932
	or $08
	rst 30
	nop
	rst 38
	nop
	nop
	nop
	nop
	rst 38

.l_5941:
	nop
	rst 38

.l_5943:
	nop
	rst 38
	nop
	<error>
	inc bc
	call z, func_0833
	rst 30
	ld a, h
	ld b, h
	ccf
	ccf
	stop
	rr a
	stop
	rr a
	ld [de], a
	rr a
	add hl, de
	rr a
	ccf
	ccf
	ld a, $3e
	adc a, $f2
	adc a, [hl]
	jp c, .l_f909
	add hl, bc
	ld sp, hl
	ld c, [hl]
	cp $98
	ldhl sp, d
	<error>
	<error>
	ld a, h
	ld a, h
	rlc a
	rlc a
	rr a
	jr .l_59af
	jr nz, .l_59f2
	ld c, a
	ld a, a
	ld e, a
	ld [hl], b
	ld [hl], b
	and d
	and d
	or b
	or b
	nop
	nop
	ld b, [hl]
	ld b, [hl]
	ld h, [hl]
	ld h, [hl]
	halt
	halt
	ld e, [hl]
	ld e, [hl]
	ld c, [hl]
	ld c, [hl]
	ld b, [hl]
	ld b, [hl]
	nop
	nop
	nop
	nop
	jr .l_59a8
	jr .l_59aa
	jr .l_59ac
	jr .l_59ae
	nop
	nop
	jr .l_59b2
	nop
	nop
	ld [de], a
	ld e, $12
	ld e, $12
	ld e, $12
	ld e, $7e
	ld a, [hl]
	cp a
	add a, e

.l_59a8:
	rst 38
	add a, c

.l_59aa:
	rst 38
	rst 38

.l_59ac:
	nop
	nop

.l_59ae:
	ldh [$ff00 + $e0], a
	jr .l_59aa

.l_59b2:
	inc b
	<error>
	inc c
	<error>
	ldhl sp, d
	ret z
	inc l
	inc [hl]
	ld l, $32
	nop
	nop
	ld b, [hl]

.l_59bf:
	ld b, [hl]
	ld b, [hl]

.l_59c1:
	ld b, [hl]
	ld b, [hl]

.l_59c3:
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	inc l
	inc l
	jr .l_59e2
	nop
	nop
	nop
	nop
	ld [hl], $36
	ld e, a
	ld c, c
	ld e, a
	ld b, c
	ld a, a
	ld b, c
	ld a, $22
	inc e
	inc d

.l_59da:
	ld [$fe08], sp
	ld [bc], a
	<error>
	dec b
	<error>
	dec b

.l_59e2:
	rst 38
	rr a
	rst 38
	<error>
	rst 38
	cp $ef
	jr c, .l_59da
	add hl, sp
	nop
	inc b
	nop
	inc b
	nop
	inc b

.l_59f2:
	ld bc, $0105
	dec b
	inc bc
	rlc a
	ld b, $06
	inc c
	inc c
	jp z, .l_c8c0
	ret nz
	jp z, .l_88c0
	add a, b
	adc a, b
	add a, a
	ld [$0a00], sp
	nop
	ld [$6f00], sp
	inc de
	cpl
	inc de
	ld l, a
	inc de
	cpl
	ld de, $d12d
	inc l
	stop
	ld l, h
	stop
	inc l
	stop
	and b
	jr nz, .l_59bf
	jr nz, .l_59c1
	jr nz, .l_59c3
	and b
	and b
	and b
	ldh [$ff00 + $e0], a
	ld h, b
	ld h, b
	jr nc, .l_5a5c
	ld [$08a8], sp
	jr .l_5a39
	xor b
	ld [$0848], sp
	xor b
	ld [$0818], sp

.l_5a39:
	xor b
	ld [$0048], sp
	cp $00
	rst 38
	ld a, a
	rst 38
	ld a, a
	pop bc
	ld a, a
	pop bc
	ld a, a
	<error>
	ld a, a
	pop bc
	ld bc, $00ff
	nop
	nop
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	rst 38
	nop
	nop
	nop
	rst 38
	nop

.l_5a5c:
	stop
	stop
	dec bc
	dec bc
	rlc a
	inc b
	rlc a
	inc b
	inc bc
	ld [bc], a
	ld bc, $0001
	nop
	nop
	nop
	or h
	or h
	<error>
	<error>
	cp h
	cp h
	xor $6e
	rst 20
	daa
	ldh a, [$ff00 + $10]
	<error>
	sbc a, h
	ld [hl], a
	ld e, a
	nop
	nop
	nop
	nop
	rlc a
	rlc a
	rr a
	jr .l_5ac4
	jr nz, .l_5b06
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	nop
	nop
	nop
	nop
	nop
	nop
	add a, b
	add a, b
	ret nz
	ld b, b
	ret nz
	ld b, b
	ret nz
	ld b, b
	add a, b
	add a, b
	ld [bc], a
	inc bc
	dec b
	inc b
	rlc a
	inc b
	inc b
	rlc a
	inc b
	rlc a
	inc b
	ld b, $04
	dec b
	inc b
	rlc a
	adc a, $fa
	inc c
	<error>
	ld [$08f8], sp
	ldhl sp, d
	ld [$08f8], sp
	ldhl sp, d
	ld [$88f8], sp
	ldhl sp, d
	nop
	inc a
	nop
	ld a, [hl]
	stop
	ld h, a
	inc h
	jp .l_c324
	inc h

.l_5ac7:
	jp .l_c324
	inc [hl]

.l_5acb:
	jp .l_3c00
	nop
	ld h, [hl]
	nop
	rst 20
	inc l
	jp .l_c33c
	inc a
	jp .l_423c
	jr .l_5b42
	nop
	nop
	nop
	nop
	nop
	nop
	jr nz, .l_5b04
	sub a, b
	sub a, b
	cp b
	xor b
	xor b
	xor b
	stop
	stop
	ld a, [bc]
	stop
	ld b, $08
	ld [bc], a
	inc b
	nop
	inc b
	nop
	inc b
	nop
	inc b
	nop
	inc b
	nop
	inc b
	rl a
	ld d, b
	jr z, .l_5b60
	ldi a, [hl]
	ld h, b
	jr z, .l_5b64

.l_5b04:
	ldi a, [hl]
	ld h, b

.l_5b06:
	jr z, .l_5b68
	jr z, .l_5b71
	ld l, b
	ld h, b
	sbc a, $2b
	ld l, $17
	ld l, [hl]
	rl a
	ld l, $17
	ld l, [hl]
	rl a
	ld l, $17
	ld l, $d7
	ld l, $17
	sbc a, b
	ld c, b
	or b
	ld d, b
	and b
	ld h, b
	and b
	jr nz, .l_5ac5
	jr nz, .l_5ac7
	jr nz, .l_5ac9
	jr nz, .l_5acb
	jr nz, .l_5b35
	xor b
	ld [$0818], sp
	xor b
	ld [$0848], sp

.l_5b35:
	cp b
	ld [$083f], sp
	cp a
	add hl, bc
	ld a, a
	nop
	ld a, a
	nop
	rst 38
	ld a, [hl]
	rst 38

.l_5b42:
	ld a, [hl]
	pop bc
	ld a, [hl]
	pop bc
	ld a, [hl]
	<error>
	ld a, [hl]
	pop bc
	nop
	rst 38
	nop
	nop
	nop
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	nop
	jr c, .l_5b98

.l_5b60:
	inc [hl]
	inc h
	inc a
	inc h

.l_5b64:
	ccf
	daa
	inc a
	daa

.l_5b68:
	inc a
	daa
	ccf
	cpl
	scf
	inc a
	rl a
	inc d
	rl a

.l_5b71:
	rr a
	inc e
	rr a
	ldh a, [$ff00 + $ff]
	nop
	rst 38
	ld [bc], a
	rst 38
	rst 38
	rst 38
	cp a
	and b
	cp a
	and b
	cp a
	cp b
	ld a, a
	ld a, a
	cpl
	cpl
	ld a, a
	ld a, a
	rst 30
	sbc a, h

.l_5b8a:
	rst 30
	sbc a, h
	<error>
	dec b
	<error>
	dec b
	<error>
	dec e
	rst 38
	rst 38
	rst 30
	<error>
	rst 38
	cp $ef
	jr c, .l_5b8a
	jr c, .l_5b9e
	ld bc, $0101
	ld bc, $0201
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld bc, $0001
	nop
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld bc, $0001
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	inc [hl]
	jp .l_433c
	inc a
	ld b, e
	jr .l_5c2a
	jr .l_5c2c
	ld [$0876], sp
	ld [hl], $08
	inc [hl]
	jr .l_5bf4
	jr .l_5bf4
	jr .l_5bf6
	ld [$0034], sp
	jr .l_5bd7

.l_5bd7:
	ld [$0800], sp
	nop
	ld [$0000], sp
	rrc a
	rrc a
	rr a
	stop
	inc a
	jr nz, .l_5c55
	ld b, b
	ld [hl], e
	ld b, e
	ld h, a
	ld c, h
	ccf
	jr z, .l_5bed

.l_5bed:
	nop
	add a, b
	add a, b
	call c, func_3e5c
	ldi [hl], a

.l_5bf4:
	ldd [hl], a
	ldh [c], a

.l_5bf6:
	or c
	pop bc
	jp .l_274b
	ld a, h
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldh [$ff00 + $e0], a
	ret nc
	stop
	ret nc
	ret nc
	ldh [$ff00 + $20], a
	ld e, h
	ld d, b
	ld a, h
	ld d, b
	add hl, sp
	jr nc, .l_5c8f
	ld c, h
	xor $82
	ret nz
	add a, h
	ld h, b
	ld b, e
	ld sp, $1f26
	inc a
	cp e
	ld h, d
	pop af
	ld b, c
	ld h, c
	ld b, c
	jp .l_f703
	inc b
	xor $08

.l_5c2a:
	sbc a, h
	ld h, b

.l_5c2c:
	sub a, b

.l_5c2d:
	stop
	ld [$1808], sp
	jr .l_5c6f
	ld h, h
	<error>
	jp nz, .l_60e3
	add hl, sp
	jr nz, .l_5c2d
	nop
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	nop
	rst 38
	nop
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	rst 38
	rst 38
	nop
	rst 38
	nop

.l_5c55:
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	jr c, .l_5c96
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

.l_5c6f:
	nop
	nop
	nop
	nop
	nop
	ld c, $0e
	ld de, $1111
	ld de, $1212
	di
	rr a
	ldh a, [$ff00 + $3f]
	ldh a, [$ff00 + $bf]
	ld h, b
	ld a, a
	stop
	rr a
	ld d, b
	ld e, a
	jr nc, .l_5cc9
	pop af
	rst 38
	rst 8
	ei
	inc c

.l_5c8f:
	<error>
	ld [$08f8], sp
	ldhl sp, d
	ld [$08f8], sp
	ldhl sp, d
	ld [$88f8], sp
	ldhl sp, d
	ld c, [hl]
	ld a, d
	ret
	reti
	add hl, bc
	ld sp, hl
	ld c, $fe
	ld c, b
	ldhl sp, d
	sbc a, b
	ldhl sp, d
	<error>
	<error>
	ld a, h
	ld a, h
	and b
	cp a
	ld b, b
	ld a, a
	ldh [$ff00 + $ff], a
	jr nz, .l_5cf3
	ld de, $721f
	ld a, [hl]
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	inc a
	nop
	inc e
	nop
	inc e
	nop
	jr .l_5cc5

.l_5cc5:
	ld [$0000], sp
	nop

.l_5cc9:
	nop
	nop
	nop
	nop
	rst 38
	nop
	xor e
	nop
	ld d, l
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec d
	nop
	jr .l_5ce1

.l_5ce1:
	dec d
	nop
	ld [de], a
	nop
	dec d
	nop
	jr .l_5ce9

.l_5ce9:
	dec d
	nop
	ld [de], a
	ld b, b
	ld b, b
	ld b, b
	ret nz
	ld b, b
	ld b, b
	ld b, b

.l_5cf3:
	ld b, b
	ld b, b
	ld b, b
	ld b, b
	ret nz
	ld b, b
	ld b, b
	ld b, b
	ld b, b
	ld c, $32
	ld c, $32
	ld c, $32
	ld c, $32
	rrc a
	inc sp
	adc a, a
	or e
	adc a, $f3
	xor $73
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	add a, b
	add a, b
	ret nz
	ld b, b
	nop
	nop
	nop
	nop
	add a, b
	add a, b
	ld b, a
	ld b, a
	rr a
	jr .l_5d66
	jr nz, .l_5da8
	ld b, b
	ld a, a
	ld b, b
	ld a, a
	ld b, b
	cp a
	and b
	cp a
	and b
	cp a
	cp b
	ld a, a
	ld a, a
	ccf
	ccf
	ld [hl], a
	ld a, h
	rst 30
	sbc a, h
	<error>
	and $f2
	and $f2
	and $f2
	and $f2
	and $f2
	and $f2
	and $f2
	and $00
	nop
	ld bc, $0101
	ld bc, $0101
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld bc, $f301
	sbc a, a
	ldh a, [$ff00 + $1f]
	ldh a, [$ff00 + $3f]
	ldh [$ff00 + $bf], a
	ld [hl], b
	ld a, a

.l_5d66:
	stop
	rr a
	ld d, b
	ld e, a
	ld sp, $3e3f
	ldi [hl], a
	rr a
	rr a
	stop
	rr a
	stop
	rr a
	ld [de], a
	rr a
	add hl, de
	rr a
	ccf
	ccf
	ld a, $3e
	ld [de], a
	ld e, $12
	ld e, $12
	ld e, $12
	ld e, $7e
	ld a, [hl]
	rst 38
	add a, e
	rst 38
	add a, c
	rst 38
	rst 38
	ld bc, $0101
	ld bc, $0101
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld bc, $0001
	nop
	ld h, b
	ldh [$ff00 + $80], a
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b
	add a, b

.l_5da8:
	add a, b
	add a, b
	add a, b
	add a, b
	rlc a
	inc b
	rlc a
	inc b
	rlc a
	inc b
	rlc a
	inc b
	rlc a
	inc b
	rlc a
	inc b
	rlc a
	inc b
	rlc a
	inc b
	dec bc
	add hl, bc
	dec bc
	ld a, [bc]
	rrc a
	ld a, [bc]
	rl a
	ld [de], a
	rl a
	inc e
	inc d
	rl a
	rl a
	inc d
	cpl
	inc h
	nop
	nop
	ld [hl], b
	ld [hl], b
	adc a, a
	adc a, a
	sbc a, b
	sbc a, a
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $9f]
	ld a, b
	ld d, a
	ld a, a
	ld c, h
	dec sp
	cpl
	ret nc
	rst 18
	ldh a, [$ff00 + $ff]
	ret nz
	rst 38
	ret nz
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ldhl sp, d
	ldhl sp, d
	ldh a, [$ff00 + $f2]
	pop hl
	push af
	<error>
	<error>
	and $ff
	rst 38
	rst 38
	add a, c
	jp .l_df81
	add a, l
	rst 18
	add a, l
	rst 38
	cp l
	rst 38
	add a, c
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rr a
	rr a
	rrc a
	ld c, a
	add a, a
	xor a
	rst 0
	ld c, a
	ld h, a
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	rst 38
	rst 38
	rst 38
	nop
	nop
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	ld c, a
	ld h, a
	<error>
	and $f5
	<error>
	<error>
	pop hl
	ldhl sp, d
	ldh a, [$ff00 + $ff]
	ldhl sp, d
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	rst 38
	rst 38
	nop
	rst 38
	nop
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	ld c, a
	ld h, a
	xor a
	rst 0
	ld c, a
	add a, a
	rr a
	rrc a
	rst 38
	rr a
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	rst 28
	rst 20
	rst 8
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	inc h
	inc c
	rst 20
	rst 8
	nop
	rst 28
	nop
	nop
	rst 38
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rlc a
	rlc a
	jr .l_5ebf
	ld hl, $473e
	ld a, a
	ld e, a
	ld a, a
	add hl, sp
	jr nc, .l_5f24
	ld h, d
	ei
	or d
	ldh [$ff00 + $e0], a
	jr .l_5ea8
	add a, h
	ld a, h
	ldh [c], a
	cp $fa
	cp $9c
	inc c
	sbc a, $46
	rst 18
	ld c, l
	rst 38
	and b
	rst 38

.l_5ebf:
	jp nz, .l_547f
	ld a, a
	ld e, h
	ccf
	ld l, $3f
	inc hl
	rr a
	jr .l_5ed2
	rlc a
	rst 38
	dec b
	rst 38
	ld b, e
	cp $2a

.l_5ed2:
	cp $3a
	<error>
	ld [hl], h
	<error>
	call nz, func_18f8
	ldh [$ff00 + $e0], a
	rlc a
	rlc a
	rr a
	jr .l_5f1f
	jr nz, .l_5f62
	ld c, a
	ld a, a
	ld e, a
	ld [hl], b
	ld [hl], b
	and d
	and d
	or b
	or b
	ldh [$ff00 + $e0], a
	ldhl sp, d
	jr .l_5f6d
	inc b
	cp $f2
	cp $fa
	ld c, $0e
	ld b, l
	ld b, l
	dec c
	dec c
	or h
	or h
	ld h, h
	ld h, h
	inc a
	inc a
	ld l, $2e
	daa
	daa
	stop
	stop
	inc c
	inc c
	inc bc
	inc bc
	dec l
	dec l
	ld h, $26
	inc a
	inc a
	ld [hl], h
	ld [hl], h
	<error>
	<error>
	ld [$3008], sp
	jr nc, .l_5edb
	ret nz
	cpl
	inc h
	cpl

.l_5f1f:
	inc h
	cpl
	inc h
	cpl
	inc h

.l_5f24:
	ld h, a
	ld a, h
	cp h
	and a
	rst 38
	<error>

.l_5f2a:
	dec de
	dec de
	nop
	nop
	nop
	nop
	ld bc, $0101
	ld bc, $0303
	inc bc
	inc bc
	inc bc
	ld [bc], a
	rlc a
	inc b
	inc b
	rlc a
	rlc a
	inc b
	rlc a
	inc b
	inc b
	inc b
	ld b, $06
	dec b
	dec b
	dec b
	dec b
	ld b, $06
	rlc a
	inc b
	rlc a
	inc b
	inc b
	rlc a
	inc b
	inc b
	inc b
	inc b
	rlc a
	rlc a
	rlc a
	rlc a
	ld b, $06
	ld b, $06
	ld b, $06
	inc b
	inc b

.l_5f62:
	rlc a
	rlc a
	dec b
	dec b
	inc bc
	inc bc
	dec b
	dec b
	ld c, $0e
	rrc a

.l_5f6d:
	rr a
	ld bc, $0110
	stop
	ld bc, $0110
	ld [$0701], sp
	inc b
	add hl, bc
	nop
	rrc a
	ld [$f801], sp
	pop af
	ld c, [hl]
	pop bc
	ld [bc], a
	rst 0
	adc a, h
	cp l
	add a, h
	xor l

.l_5f88:
	ld h, d
	rst 8
	ld a, [hl]
	cp $ec
	sub a, b
	rst 28
	sbc a, a
	ld a, [$daf7]
	rst 20
	cp l
	cp l
	or l
	xor l
	jp nc, .l_7fef

.l_5f9b:
	ld a, a
	ldhl sp, d
	ldhl sp, d
	jr .l_5f88
	jr c, .l_5f2a
	cp b
	ld [$10b0], sp
	ldh [$ff00 + $e0], a
	ret nc
	jr nc, .l_5f9b
	ldh a, [$ff00 + $18]
	jr .l_5fdf

.l_5faf:
	jr nc, .l_6011
	ld h, b
	ret nz
	ret nz
	ret nz
	ret nz
	rst 38
	rst 38
	add a, e

.l_5fb9:
	add a, e
	ld h, b
	ld h, d
	ld a, [bc]
	nop
	ld [$0800], sp
	rlc a
	ld [$0800], sp
	ld bc, $f1f8
	ldhl sp, d
	pop af
	ld [$6c01], sp
	stop
	inc l
	stop
	inc l
	pop de
	inc l
	ld de, $90ac
	rst 28
	sbc a, a
	rst 28
	sbc a, a
	<error>
	sub a, b
	jr .l_5ff6
	inc c

.l_5fdf:
	inc c
	ld b, $c6
	inc bc
	jp .l_0303
	rst 38
	rst 38
	pop bc
	pop bc
	ld b, $46
	nop
	inc b
	nop
	inc c
	ld [bc], a
	stop
	ld [bc], a
	stop
	ld [bc], a
	stop

.l_5ff6:
	ld [bc], a
	stop
	ld [bc], a
	stop
	ld [bc], a
	stop
	inc c
	ld c, h
	inc c
	ld c, h
	add hl, bc
	ld c, c
	dec bc
	ld c, e
	ld a, [bc]
	ld c, d
	stop
	ld d, b
	ld [de], a
	ld d, d
	stop
	ld d, b
	ld a, [hl]
	inc sp
	ld a, [hl]
	inc sp
	cp [hl]

.l_6011:
	sub a, e
	cp $d3
	ld a, [hl]
	ld d, e
	ld a, $0b
	ld a, [hl]
	ld c, e
	ld a, $0b
	and b
	jr nz, .l_5faf
	jr nc, .l_5fb9
	ld c, b
	sbc a, b
	ld c, b
	sbc a, b
	ld c, b
	sbc a, b
	ld c, b
	sbc a, b
	ld c, b
	sbc a, b
	ld c, b
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld bc, $0101
	ld bc, $0202
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	nop
	ld bc, $0202
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	ld [bc], a
	inc bc
	ld [bc], a
	ld [bc], a
	ld b, $06
	ld c, $0a
	ld c, $0a
	dec bc
	ld a, [bc]
	dec bc
	ld a, [bc]
	rrc a
	ld a, [bc]
	ld a, [bc]
	ld a, [bc]
	ld b, $06
	ld a, [bc]
	ld a, [bc]
	ld a, [de]
	ld [de], a
	rr a
	rr a
	nop
	nop
	nop
	nop
	rr a
	rr a
	ccf
	jr nz, .l_60f4
	ld b, a
	ld a, h
	ld c, h
	ld a, h
	ld c, h
	ld a, h
	ld c, h
	nop
	nop
	nop

.l_607f:
	nop
	ldh [$ff00 + $e0], a
	ldh a, [$ff00 + $30]
	ldhl sp, d
	jr .l_607f
	sbc a, b
	ldhl sp, d
	sbc a, b
	ldhl sp, d
	sbc a, b
	ld a, a
	ld c, a
	ld a, a
	ld b, b
	ld a, a
	ld c, a
	ld a, h
	ld c, h
	ld a, h
	ld c, h
	ld a, h
	ld a, h
	nop

.l_6099:
	nop
	nop
	nop
	ldhl sp, d
	sbc a, b
	ldhl sp, d
	jr .l_6099
	sbc a, b
	ldhl sp, d
	sbc a, b
	ldhl sp, d
	sbc a, b
	ldhl sp, d
	ldhl sp, d
	nop
	nop
	nop
	nop
	nop
	nop
	ld a, h
	ld a, h
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld a, h
	ld a, h
	nop
	nop
	nop
	nop
	ld a, [hl]
	ld a, [hl]
	ld h, b
	ld h, b
	ld a, h
	ld a, h
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld a, [hl]
	ld a, [hl]
	nop
	nop
	nop
	nop
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld c, [hl]
	ld c, [hl]
	inc a
	inc a
	nop
	nop
	nop
	nop
	inc a
	inc a
	ld h, [hl]
	ld h, [hl]
	ld h, b

.l_60e3:
	ld h, b
	ld h, b
	ld h, b
	ld h, [hl]
	ld h, [hl]
	inc a
	inc a
	nop
	nop
	nop
	nop
	ld b, [hl]
	ld b, [hl]
	ld l, [hl]
	ld l, [hl]
	ld a, [hl]
	ld a, [hl]

.l_60f4:
	ld d, [hl]
	ld d, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	nop
	nop
	nop
	nop
	inc a
	inc a
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld a, [hl]
	ld a, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	nop
	nop
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld bc, $ff01
	ld bc, $ff01
	rst 38
	rst 38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldh a, [$ff00 + $f0]
	ldh a, [$ff00 + $b0]
	ldh a, [$ff00 + $b0]
	ldh a, [$ff00 + $f0]
	nop
	nop
	nop
	nop
	rlc a
	rlc a
	jr .l_6163
	jr nz, .l_6185
	jr nc, .l_6187
	jr .l_6161
	ccf
	inc l
	ld a, e
	ld c, a
	ld [hl], b
	ld e, a
	sub a, b
	sbc a, a
	sub a, b
	sbc a, a
	ld [hl], b
	ld a, a
	ld de, $3e1f
	ld a, $3e
	ld a, $00
	nop
	ld a, h
	ld a, h
	ld h, [hl]

.l_6161:
	ld h, [hl]
	ld h, [hl]

.l_6163:
	ld h, [hl]
	ld a, h
	ld a, h
	ld l, b
	ld l, b
	ld h, [hl]
	ld h, [hl]
	nop
	nop
	nop
	nop
	inc a
	inc a
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	ld h, [hl]
	inc a
	inc a
	nop
	nop
	nop
	nop
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b
	ld h, b

.l_6185:
	ld h, b
	ld h, b

.l_6187:
	ld h, b
	ld a, [hl]
	ld a, [hl]
	nop
	nop
	nop
	nop
	inc a
	inc a
	ld h, [hl]
	ld h, [hl]
	ld h, b
	ld h, b
	ld l, [hl]
	ld l, [hl]
	ld h, [hl]
	ld h, [hl]
	ld a, $3e
	nop
	nop
	nop
	xor $00
	nop
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	rst 38
	nop
	ld bc, $0200
	nop
	ld [bc], a
	nop
	inc b
	nop
	ld [$0800], sp
	nop
	stop
	nop
	stop
	add a, b
	add a, b
	ret nz
	ld b, b
	ret nz
	ld b, b
	ldh [$ff00 + $20], a
	jr nc, .l_6216
	jr nc, .l_6218
	jr c, .l_6212
	jr .l_61f4
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	inc bc
	nop
	inc bc
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld [$08f8], sp
	jr .l_61f1
	xor b
	ld [$0048], sp
	add a, b
	nop
	add a, b
	nop

.l_61f1:
	add a, b
	nop
	add a, b

.l_61f4:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	jr nz, .l_61ff

.l_61ff:
	jr nz, .l_6201

.l_6201:
	jr nz, .l_6222
	jr nz, .l_6205

.l_6205:
	ld b, b
	nop
	ld b, b
	nop
	ld b, b
	nop
	ld b, b
	inc e
	inc h
	inc c
	inc [hl]
	inc c
	inc [hl]

.l_6212:
	inc b
	<error>
	ld c, $32

.l_6216:
	ld c, $32

.l_6218:
	ld c, $32
	ld c, $32
	nop
	nop
	nop
	nop
	nop
	nop

.l_6222:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rr a
	nop
	jr .l_6239

.l_6239:
	dec d
	nop
	ld [de], a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld b, b
	ret nz
	ld b, b
	ret nz
	ld b, b
	ld b, b
	ld b, b
	ld b, b
	nop
	ld [bc], a
	nop
	inc bc
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	ld [bc], a
	nop
	inc bc
	nop
	ld [bc], a
	nop
	ld [bc], a
	ld [$08af], sp
	ld a, [de]
	ld [$08ad], sp
	ld c, a
	ld [$08a8], sp
	jr .l_6271
	xor b
	ld [$0048], sp
	nop
	nop
	nop
	nop

.l_6271:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld bc, $0200
	nop
	ld b, b
	dec d
	ld b, b
	dec d
	ld b, b
	dec d
	ld b, b
	dec d
	ret nz
	dec d
	pop bc
	rl a
	ld b, e
	ld d, $46
	inc h
	inc c
	inc [hl]
	inc c
	inc [hl]
	inc b
	<error>
	ld c, $32
	ld c, $32
	ld c, $32
	ld c, $32
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldi a, [hl]
	jr nz, .l_62b5
	nop

.l_62b5:
	dec e
	ld bc, $0009
	rlc a
	ld bc, $000b
	inc bc
	jr nz, .l_62c4
	nop
	jr nz, .l_62e3
	ld b, $00
	ld a, [bc]
	add a, b
	rl a
	nop
	ld b, $01
	ld b, $00
	inc b
	ld bc, $0005
	ld e, $80
	dec bc
	nop
	ld b, $80
	inc e
	nop
	ld a, [bc]
	stop
	ld [$0411], sp
	ld bc, $0002
	inc b
	ld bc, $0006
	nop
	stop
	ld b, $00
	inc b
	stop
	dec b
	nop
	ld a, [de]
	add a, b
	inc h
	nop
	dec d
	ld bc, $0007
	jr nz, .l_6307
	inc b
	nop
	dec b
	stop
	inc bc
	nop
	dec c
	stop
	ld b, $00
	inc bc
	stop
	dec b
	nop
	dec h
	add a, b

.l_6307:
	dec d
	nop
	dec de
	stop
	inc b
	nop
	inc de
	add a, b
	inc bc
	nop
	inc e
	add a, b
	add hl, de
	nop
	ld a, [de]
	ld bc, $0006
	ld a, [bc]
	jr nz, .l_631d
	nop

.l_631d:
	add hl, bc
	jr nz, .l_6322
	nop
	inc d

.l_6322:
	stop
	inc bc
	nop
	ld c, $80
	ld d, $00
	ld a, [bc]
	stop
	ld a, [bc]
	ld de, $1006
	ld d, $00
	inc de
	add a, b
	dec h
	nop
	inc e
	ld bc, $0006
	inc bc
	jr nz, .l_633e
	nop
	ld c, $20
	inc bc
	nop
	inc b
	jr nz, .l_6346
	nop
	inc bc

.l_6346:
	jr nz, .l_634d
	nop
	dec c
	add a, b
	ld hl, $1300
	ld bc, $0007
	dec b
	ld bc, $0006
	inc b
	ld bc, $0005
	ld b, $20
	inc bc
	nop
	dec b
	jr nz, .l_6362
	nop
	inc e

.l_6362:
	jr nz, .l_6367
	nop
	ld c, $80

.l_6367:
	ld [de], a
	nop
	inc c
	stop
	inc b
	nop
	ld [bc], a
	ld bc, $0008
	stop
	ld bc, $0008
	ld e, $80
	add hl, de
	nop
	stop
	stop
	inc bc
	nop
	inc b
	stop
	dec b
	nop
	inc h
	add a, b
	inc e
	nop
	dec b
	ld bc, $0005
	ld de, $0320
	nop
	ld [de], a
	add a, b
	jr nz, .l_6391

.l_6391:
	ld a, [bc]
	stop
	ld bc, $0611
	ld bc, $0000
	inc b
	stop
	inc b
	nop
	inc b
	stop
	inc bc
	nop
	ld [bc], a
	stop
	add hl, de
	nop
	inc b
	stop
	rlc a
	nop
	ld a, [bc]
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld c, l
	jr nz, .l_63bc
	ld hl, $2006
	dec bc
	nop
	rlc a
	jr nz, .l_63c2

.l_63bc:
	nop
	ld h, h
	stop
	nop
	ld de, $1006
	dec b
	nop
	cpl
	add a, b
	ld d, $00
	rl a
	jr nz, .l_63d1
	nop
	ld b, $20
	ld b, $00

.l_63d1:
	stop
	add a, b
	jr .l_63d5

.l_63d5:
	inc [hl]
	ld bc, $0005
	ld bc, $0e10
	ld de, $1006
	jr nz, .l_63e1

.l_63e1:
	ld a, [bc]
	add a, b
	ld a, [bc]
	nop
	dec hl
	jr nz, .l_63ee
	nop
	ld b, $20
	dec b
	nop
	dec b

.l_63ee:
	jr nz, .l_63f6
	nop
	ld a, [bc]
	add a, b
	inc c
	nop
	ld a, [bc]

.l_63f6:
	ld bc, $0007
	ld [bc], a
	stop
	dec bc
	nop
	dec b
	stop
	inc b
	nop
	dec c
	add a, b
	inc e
	nop
	ld [hl], l
	ld bc, $0006
	ld c, $80
	rr a
	nop
	ld a, [de]
	ld bc, $0006
	nop
	stop
	rlc a
	nop
	dec b
	stop
	ld b, $00
	inc b
	stop
	ld [$0300], sp
	stop
	ld [$0c00], sp
	add a, b
	rrc a
	nop
	ld a, [bc]
	ld bc, $0007
	nop
	stop
	dec a
	nop
	dec b
	add a, b
	rr a
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	stop
	jr .l_6453

.l_6453:
	inc b
	ld [$0400], sp
	ld [$0008], sp
	inc b
	inc d
	stop
	ld [$1010], sp
	inc d
	jr .l_6477
	nop
	inc c
	inc b
	jr .l_6468

.l_6468:
	inc d
	inc d
	ld [$0404], sp
	inc c
	nop
	jr .l_6475
	nop
	ld [$0c0c], sp

.l_6475:
	jr .l_6477

.l_6477:
	inc c
	ld [$1800], sp
	stop
	inc d
	inc d
	jr .l_6488
	xor d
	ld h, l
	add a, $65
	<error>
	ld h, [hl]
	jr z, .l_64ee

.l_6488:
	inc [hl]
	ld h, a
	xor a
	ld h, [hl]
	pop af
	ld h, l
	ld d, h
	ld h, [hl]
	or d
	ld h, l
	adc a, $65
	inc d
	ld h, a
	adc a, $65
	adc a, $65
	jp .l_f766
	ld h, l
	ld h, b
	ld h, [hl]
	call nc, func_dc67
	ld h, a
	sbc a, l
	ld h, a
	and l
	ld h, a
	<error>
	ld h, a
	<error>
	ld h, a
	<error>
	ld h, a
	xor l
	ld h, a
	ccf
	ld l, a
	ld c, d
	ld l, a
	ld d, l
	ld l, a
	ld h, b
	ld l, a
	ld l, e
	ld l, a
	halt
	ld l, a
	add a, c
	ld l, a
	adc a, h
	ld l, a
	sub a, a
	ld l, a
	and d
	ld l, a
	xor l
	ld l, a
	cp b
	ld l, a
	jp .l_ce6f
	ld l, a
	reti
	ld l, a
	<error>
	ld l, a
	rst 28
	ld l, a


func_64d2::
	ret

.l_64d3:
	push af
	push bc
	push de
	push hl
	ld a, [$df7f]
	cp $01
	jr z, .l_6524
	cp $02
	jr z, .l_655d
	ld a, [$df7e]
	and a
	jr nz, .l_6563

.l_64e8:
	ldh a, [$ff00 + $e4]
	and a
	jr z, .l_64fa
	xor a

.l_64ee:
	ld [$dfe0], a
	ld [$dfe8], a
	ld [$dff0], a
	ld [$dff8], a

.l_64fa:
	call func_64d2
	call func_69dd
	call func_69fd
	call func_683c
	call func_6a21
	call func_6c44
	call func_6a65

.l_650f:
	xor a
	ld [$dfe0], a
	ld [$dfe8], a
	ld [$dff0], a
	ld [$dff8], a
	ld [$df7f], a
	pop hl
	pop de
	pop bc
	pop af
	ret

.l_6524:
	call func_69c7
	xor a
	ld [$dfe1], a
	ld [$dff1], a
	ld [$dff9], a
	ld hl, $dfbf
	res 7, [hl]
	ld hl, $df9f
	res 7, [hl]
	ld hl, $dfaf
	res 7, [hl]
	ld hl, $dfcf
	res 7, [hl]
	ld hl, $6ee9
	call func_6998
	ld a, $30
	ld [$df7e], a

.l_6550:
	ld hl, $657b

.l_6553:
	call func_695d
	jr .l_650f

.l_6558:
	ld hl, $657f
	jr .l_6553

.l_655d:
	xor a
	ld [$df7e], a
	jr .l_64e8

.l_6563:
	ld hl, $df7e
	dec [hl]
	ld a, [hl]
	cp $28
	jr z, .l_6558
	cp $20
	jr z, .l_6550
	cp $18
	jr z, .l_6558
	cp $10
	jr nz, .l_650f
	inc [hl]
	jr .l_650f
	or d
	<error>
	add a, e
	rst 0
	or d
	<error>
	pop bc
	rst 0


func_6583::
	ld a, [$dff1]
	cp $01
	ret


func_6589::
	ld a, [$dfe1]
	cp $05
	ret


func_658f::
	ld a, [$dfe1]
	cp $07
	ret


func_6595::
	ld a, [$dfe1]
	cp $08
	ret
	nop
	or l
	ret nc
	ld b, b
	rst 0
	nop
	or l
	jr nz, .l_65e4
	rst 0
	nop
	or [hl]
	and c
	add a, b
	rst 0
	ld a, $05
	ld hl, $659b
	jp .l_6936
	call func_698b
	and a
	ret nz
	ld hl, $dfe4
	inc [hl]
	ld a, [hl]
	cp $02
	jr z, .l_65d3
	ld hl, $65a0
	jp .l_6956
	ld a, $03
	ld hl, $65a5
	jp .l_6936
	call func_698b
	and a
	ret nz

.l_65d3:
	xor a
	ld [$dfe1], a
	ldh [$ff00 + $10], a
	ld a, $08
	ldh [$ff00 + $12], a
	ld a, $80
	ldh [$ff00 + $14], a
	ld hl, $df9f

.l_65e4:
	res 7, [hl]
	ret
	nop
	add a, b
	pop hl
	pop bc
	add a, a
	nop
	add a, b
	pop hl
	xor h
	add a, a
	ld hl, $65e7
	jp .l_6936
	ld hl, $dfe4
	inc [hl]
	ld a, [hl]
	cp $04
	jr z, .l_6617
	cp $0b
	jr z, .l_661d
	cp $0f
	jr z, .l_6617
	cp $18
	jp z, .l_660e
	ret

.l_660e:
	ld a, $01
	ld hl, $dff0
	ld [hl], a
	jp .l_65d3

.l_6617:
	ld hl, $65ec
	jp .l_6956

.l_661d:
	ld hl, $65e7
	jp .l_6956
	ld c, b
	cp h
	ld b, d
	ld h, [hl]
	add a, a
	call func_6583
	ret z
	call func_6595
	ret z
	call func_658f
	ret z
	call func_6589
	ret z
	ld a, $02
	ld hl, $6623
	jp .l_6936
	nop
	or b
	pop af
	or [hl]
	rst 0
	nop
	or b
	pop af
	call nz, func_00c7
	or b
	pop af
	adc a, $c7
	nop
	or b
	pop af
	<error>
	rst 0
	call func_658f
	ret z
	ld a, $07
	ld hl, $6640
	jp .l_6936
	call func_698b
	and a
	ret nz
	ld hl, $dfe4
	inc [hl]
	ld a, [hl]
	cp $01
	jr z, .l_6680
	cp $02
	jr z, .l_6685
	cp $03
	jr z, .l_668a
	cp $04
	jr z, .l_668f
	cp $05
	jp z, .l_65d3
	ret

.l_6680:
	ld hl, $6645
	jr .l_6692

.l_6685:
	ld hl, $664a
	jr .l_6692

.l_668a:
	ld hl, $664f
	jr .l_6692

.l_668f:
	ld hl, $6640

.l_6692:
	jp .l_6956
	ld a, $80
	<error>
	nop
	call nz, func_8393
	add a, e
	ld [hl], e
	ld h, e
	ld d, e
	ld b, e
	inc sp
	inc hl
	inc de
	nop
	nop
	inc hl
	ld b, e
	ld h, e
	add a, e
	and e
	jp .l_e3d3
	rst 38
	call func_6583
	ret z
	call func_6595
	ret z
	call func_658f
	ret z
	ld a, $06
	ld hl, $6695
	jp .l_6936
	call func_698b
	and a
	ret nz
	ld hl, $dfe4
	ld c, [hl]
	inc [hl]
	ld b, $00
	ld hl, $669a
	add hl, bc
	ld a, [hl]
	and a
	jp z, .l_65d3
	ld e, a
	ld hl, $66a5
	add hl, bc
	ld a, [hl]
	ld d, a
	ld b, $86

.l_66e1:
	ld c, $12
	ld a, e
	ldh [c], a
	inc c
	ld a, d
	ldh [c], a
	inc c
	ld a, b
	ldh [c], a
	ret
	dec sp
	add a, b
	or d
	add a, a
	add a, a
	and d
	sub a, e
	ld h, d
	ld b, e
	inc hl
	nop
	add a, b
	ld b, b
	add a, b
	ld b, b
	add a, b
	call func_6583
	ret z
	call func_6595
	ret z
	call func_658f
	ret z
	call func_6589
	ret z
	ld a, $03
	ld hl, $66ec
	jp .l_6936
	call func_698b
	and a
	ret nz
	ld hl, $dfe4
	ld c, [hl]
	inc [hl]
	ld b, $00
	ld hl, $66f1
	add hl, bc
	ld a, [hl]
	and a
	jp z, .l_65d3
	ld e, a
	ld hl, $66f7
	add hl, bc
	ld a, [hl]
	ld d, a
	ld b, $87
	jr .l_66e1
	call func_658f
	ret z
	ld a, $28
	ld hl, $6740
	jp .l_6936
	or a
	add a, b
	sub a, b
	rst 38
	add a, e
	nop
	pop de
	ld b, l
	add a, b
	nop
	pop af
	ld d, h
	add a, b
	nop
	push de
	ld h, l
	add a, b
	nop
	ld [hl], b
	ld h, [hl]
	add a, b
	ld h, l
	ld h, l
	ld h, l
	ld h, h
	ld d, a
	ld d, [hl]
	ld d, l
	ld d, h
	ld d, h
	ld d, h
	ld d, h
	ld d, h
	ld b, a
	ld b, [hl]
	ld b, [hl]
	ld b, l
	ld b, l
	ld b, l
	ld b, h
	ld b, h
	ld b, h
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ld [hl], b
	ld h, b
	ld [hl], b
	ld [hl], b
	ld [hl], b
	add a, b
	sub a, b
	and b
	ret nc
	ldh a, [$ff00 + $e0]
	ret nc
	ret nz
	or b
	and b
	sub a, b
	add a, b
	ld [hl], b
	ld h, b
	ld d, b
	ld b, b
	jr nc, .l_67c0
	jr nz, .l_67b2
	jr nz, .l_67b4
	jr nz, .l_67b6
	jr nz, .l_67b8
	jr nz, .l_67ba
	jr nz, .l_67ac
	stop
	ld a, $30
	ld hl, $674d
	jp .l_6936
	ld a, $30
	ld hl, $6751
	jp .l_6936
	call func_698b
	and a
	ret nz

.l_67b2:
	ld hl, $dffc
	ld a, [hl]

.l_67b6:
	ld c, a
	cp $24
	jp z, .l_67e9
	inc [hl]
	ld b, $00
	push bc

.l_67c0:
	ld hl, $6755
	add hl, bc
	ld a, [hl]
	ldh [$ff00 + $22], a
	pop bc
	ld hl, $6779
	add hl, bc
	ld a, [hl]
	ldh [$ff00 + $21], a
	ld a, $80
	ldh [$ff00 + $23], a
	ret
	ld a, $20
	ld hl, $6749
	jp .l_6936
	ld a, $12
	ld hl, $6745
	jp .l_6936
	call func_698b
	and a
	ret nz

.l_67e9:
	xor a
	ld [$dff9], a
	ld a, $08
	ldh [$ff00 + $21], a
	ld a, $80
	ldh [$ff00 + $23], a
	ld hl, $dfcf

.l_67f8:
	res 7, [hl]
	ret

.l_67fb:
	add a, b
	ldd a, [hl]
	jr nz, .l_685f
	add a, $21
	reti
	ld l, [hl]
	call func_690d
	ldh a, [$ff00 + $04]
	and $1f
	ld b, a
	ld a, $d0
	add a, b
	ld [$dff5], a
	ld hl, $67fb
	jp .l_6964

.l_6817:
	ldh a, [$ff00 + $04]
	and $0f
	ld b, a
	ld hl, $dff4
	inc [hl]
	ld a, [hl]
	ld hl, $dff5
	cp $0e
	jr nc, .l_6832
	inc [hl]
	inc [hl]

.l_682a:
	ld a, [hl]
	and $f0
	or b
	ld c, $1d
	ldh [c], a
	ret

.l_6832:
	cp $1e
	jp z, .l_68e2
	dec [hl]
	dec [hl]
	dec [hl]
	jr .l_682a


func_683c::
	ld a, [$dff0]
	cp $01
	jp z, .l_686b
	cp $02
	jp z, .l_6800
	ld a, [$dff1]
	cp $01
	jp z, .l_68b6
	cp $02
	jp z, .l_6817
	ret
	add a, b
	add a, b
	jr nz, .l_67f8
	add a, a
	add a, b
	ldhl sp, d
	jr nz, .l_67f8
	add a, a
	add a, b
	ei
	jr nz, .l_67fb
	add a, a
	add a, b
	or $20
	sub a, l
	add a, a

.l_686b:
	ld hl, $6ea9
	call func_690d
	ld hl, $685a
	ld a, [hl]
	ld [$dff6], a
	ld a, $01
	ld [$dff5], a
	ld hl, $6857

.l_6880:
	jp .l_6964

.l_6883:
	ld a, $00
	ld [$dff5], a
	ld hl, $685f
	ld a, [hl]
	ld [$dff6], a
	ld hl, $685c
	jr .l_6880

.l_6894:
	ld a, $01
	ld [$dff5], a
	ld hl, $6864
	ld a, [hl]
	ld [$dff6], a
	ld hl, $6861
	jr .l_6880

.l_68a5:
	ld a, $02
	ld [$dff5], a
	ld hl, $6869
	ld a, [hl]
	ld [$dff6], a
	ld hl, $6866
	jr .l_6880

.l_68b6:
	ld hl, $dff4
	inc [hl]
	ldi a, [hl]
	cp $09
	jr z, .l_6883
	cp $13
	jr z, .l_6894
	cp $17
	jr z, .l_68a5
	cp $20
	jr z, .l_68e2
	ldi a, [hl]
	cp $00
	ret z
	cp $01
	jr z, .l_68d8
	cp $02
	jr z, .l_68dc
	ret

.l_68d8:
	inc [hl]
	inc [hl]
	jr .l_68de

.l_68dc:
	dec [hl]
	dec [hl]

.l_68de:
	ld a, [hl]
	ldh [$ff00 + $1d], a
	ret

.l_68e2:
	xor a
	ld [$dff1], a
	ldh [$ff00 + $1a], a
	ld hl, $dfbf
	res 7, [hl]
	ld hl, $df9f
	res 7, [hl]
	ld hl, $dfaf
	res 7, [hl]
	ld hl, $dfcf
	res 7, [hl]
	ld a, [$dfe9]
	cp $05
	jr z, .l_6908
	ld hl, $6ee9
	jr .l_6932

.l_6908:
	ld hl, $6ec9
	jr .l_6932


func_690d::
	push hl
	ld [$dff1], a
	ld hl, $dfbf
	set 7, [hl]
	xor a
	ld [$dff4], a
	ld [$dff5], a
	ld [$dff6], a
	ldh [$ff00 + $1a], a
	ld hl, $df9f
	set 7, [hl]
	ld hl, $dfaf
	set 7, [hl]
	ld hl, $dfcf
	set 7, [hl]
	pop hl

.l_6932:
	call func_6998
	ret

.l_6936:
	push af
	dec e
	ld a, [$df71]
	ld [de], a
	inc e
	pop af
	inc e
	ld [de], a
	dec e
	xor a
	ld [de], a
	inc e
	inc e
	ld [de], a
	inc e
	ld [de], a
	ld a, e
	cp $e5
	jr z, .l_6956
	cp $f5
	jr z, .l_6964
	cp $fd
	jr z, .l_696b
	ret

.l_6956:
	push bc
	ld c, $10
	ld b, $05
	jr .l_6970


func_695d::
	push bc
	ld c, $16
	ld b, $04
	jr .l_6970

.l_6964:
	push bc
	ld c, $1a
	ld b, $05
	jr .l_6970

.l_696b:
	push bc
	ld c, $20
	ld b, $04

.l_6970:
	ldi a, [hl]
	ldh [c], a
	inc c
	dec b
	jr nz, .l_6970
	pop bc
	ret


func_6978::
	inc e
	ld [$df71], a


func_697c::
	inc e
	dec a
	sla a
	ld c, a
	ld b, $00
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld l, c
	ld h, b
	ld a, h
	ret


func_698b::
	push de
	ld l, e
	ld h, d
	inc [hl]
	ldi a, [hl]
	cp [hl]
	jr nz, .l_6996
	dec l
	xor a
	ld [hl], a

.l_6996:
	pop de
	ret


func_6998::
	push bc
	ld c, $30

.l_699b:
	ldi a, [hl]
	ldh [c], a
	inc c
	ld a, c
	cp $40
	jr nz, .l_699b
	pop bc
	ret


func_69a5::
	xor a
	ld [$dfe1], a
	ld [$dfe9], a
	ld [$dff1], a
	ld [$dff9], a
	ld [$df9f], a
	ld [$dfaf], a
	ld [$dfbf], a
	ld [$dfcf], a
	ld a, $ff
	ldh [$ff00 + $25], a
	ld a, $03
	ld [$df78], a


func_69c7::
	ld a, $08
	ldh [$ff00 + $12], a
	ldh [$ff00 + $17], a
	ldh [$ff00 + $21], a
	ld a, $80
	ldh [$ff00 + $14], a
	ldh [$ff00 + $19], a
	ldh [$ff00 + $23], a
	xor a
	ldh [$ff00 + $10], a
	ldh [$ff00 + $1a], a
	ret


func_69dd::
	ld de, $dfe0
	ld a, [de]
	and a
	jr z, .l_69f0
	ld hl, $df9f
	set 7, [hl]
	ld hl, $6480
	call func_6978
	jp [hl]

.l_69f0:
	inc e
	ld a, [de]
	and a
	jr z, .l_69fc
	ld hl, $6490
	call func_697c
	jp [hl]

.l_69fc:
	ret


func_69fd::
	ld de, $dff8
	ld a, [de]
	and a
	jr z, .l_6a10
	ld hl, $dfcf
	set 7, [hl]
	ld hl, $64a0
	call func_6978
	jp [hl]

.l_6a10:
	inc e
	ld a, [de]
	and a
	jr z, .l_6a1c
	ld hl, $64a8
	call func_697c
	jp [hl]

.l_6a1c:
	ret

.l_6a1d:
	call func_69a5
	ret


func_6a21::
	ld hl, $dfe8
	ldi a, [hl]
	and a
	ret z
	cp $ff
	jr z, .l_6a1d
	ld [hl], a
	ld b, a
	ld hl, $64b0
	and $1f
	call func_697c
	call func_6b13
	call func_6a3c
	ret


func_6a3c::
	ld a, [$dfe9]
	and a
	ret z
	ld hl, $6abe

.l_6a44:
	dec a
	jr z, .l_6a4d
	inc hl
	inc hl
	inc hl
	inc hl
	jr .l_6a44

.l_6a4d:
	ldi a, [hl]
	ld [$df78], a
	ldi a, [hl]
	ld [$df76], a
	ldi a, [hl]
	ld [$df79], a
	ldi a, [hl]
	ld [$df7a], a
	xor a
	ld [$df75], a
	ld [$df77], a
	ret


func_6a65::
	ld a, [$dfe9]
	and a
	jr z, .l_6aa8
	ld hl, $df75
	ld a, [$df78]
	cp $01
	jr z, .l_6aac
	cp $03
	jr z, .l_6aa8
	inc [hl]
	ldi a, [hl]
	cp [hl]
	jr nz, .l_6ab1
	dec l
	ld [hl], $00
	inc l
	inc l
	inc [hl]
	ld a, [$df79]
	bit 0, [hl]
	jp z, .l_6a8f
	ld a, [$df7a]

.l_6a8f:
	ld b, a
	ld a, [$dff1]
	and a
	jr z, .l_6a9a
	set 2, b
	set 6, b

.l_6a9a:
	ld a, [$dff9]
	and a
	jr z, .l_6aa4
	set 3, b
	set 7, b

.l_6aa4:
	ld a, b

.l_6aa5:
	ldh [$ff00 + $25], a
	ret

.l_6aa8:
	ld a, $ff
	jr .l_6aa5

.l_6aac:
	ld a, [$df79]
	jr .l_6a8f

.l_6ab1:
	ld a, [$dff9]
	and a
	jr nz, .l_6aa8
	ld a, [$dff1]
	and a
	jr nz, .l_6aa8
	ret
	ld bc, $ef24
	ld d, [hl]
	ld bc, $e500
	nop
	ld bc, $fd20
	nop
	ld bc, $de20
	rst 30
	inc bc
	jr .l_6b50
	rst 30
	inc bc
	jr .l_6acc
	ld a, a
	inc bc
	ld c, b
	rst 18
	ld e, e
	ld bc, $db18
	rst 20
	ld bc, $fd00
	rst 30
	inc bc
	jr nz, .l_6b64
	rst 30
	ld bc, $ed20
	rst 30
	ld bc, $ed20
	rst 30
	ld bc, $ed20
	rst 30
	ld bc, $ed20
	rst 30
	ld bc, $ed20
	rst 30
	ld bc, $ef20
	rst 30
	ld bc, $ef20
	rst 30


func_6b02::
	ldi a, [hl]
	ld c, a
	ld a, [hl]
	ld b, a
	ld a, [bc]
	ld [de], a
	inc e
	inc bc
	ld a, [bc]
	ld [de], a
	ret


func_6b0d::
	ldi a, [hl]
	ld [de], a
	inc e
	ldi a, [hl]
	ld [de], a
	ret


func_6b13::
	call func_69c7
	xor a
	ld [$df75], a
	ld [$df77], a
	ld de, $df80
	ld b, $00
	ldi a, [hl]
	ld [de], a
	inc e
	call func_6b0d
	ld de, $df90
	call func_6b0d
	ld de, $dfa0
	call func_6b0d
	ld de, $dfb0
	call func_6b0d
	ld de, $dfc0
	call func_6b0d
	ld hl, $df90
	ld de, $df94
	call func_6b02
	ld hl, $dfa0
	ld de, $dfa4
	call func_6b02
	ld hl, $dfb0
	ld de, $dfb4
	call func_6b02
	ld hl, $dfc0
	ld de, $dfc4
	call func_6b02

.l_6b64:
	ld bc, $0410
	ld hl, $df92

.l_6b6a:
	ld [hl], $01
	ld a, c
	add a, l
	ld l, a
	dec b
	jr nz, .l_6b6a
	xor a
	ld [$df9e], a
	ld [$dfae], a
	ld [$dfbe], a
	ret

.l_6b7d:
	push hl
	xor a
	ldh [$ff00 + $1a], a
	ld l, e
	ld h, d
	call func_6998
	pop hl
	jr .l_6bb3

.l_6b89:
	call func_6bb9
	call func_6bce
	ld e, a
	call func_6bb9
	call func_6bce
	ld d, a
	call func_6bb9
	call func_6bce
	ld c, a
	inc l
	inc l
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], c
	dec l
	dec l
	dec l
	dec l
	push hl
	ld hl, $df70
	ld a, [hl]
	pop hl
	cp $03
	jr z, .l_6b7d

.l_6bb3:
	call func_6bb9
	jp .l_6c5e


func_6bb9::
	push de
	ldi a, [hl]
	ld e, a
	ldd a, [hl]
	ld d, a
	inc de

.l_6bbf:
	ld a, e
	ldi [hl], a
	ld a, d
	ldd [hl], a
	pop de
	ret


func_6bc5::
	push de
	ldi a, [hl]
	ld e, a
	ldd a, [hl]
	ld d, a
	inc de
	inc de
	jr .l_6bbf


func_6bce::
	ldi a, [hl]
	ld c, a
	ldd a, [hl]
	ld b, a
	ld a, [bc]
	ld b, a
	ret

.l_6bd5:
	pop hl
	jr .l_6c04

.l_6bd8:
	ld a, [$df70]
	cp $03
	jr nz, .l_6bef
	ld a, [$dfb8]
	bit 7, a
	jr z, .l_6bef
	ld a, [hl]
	cp $06
	jr nz, .l_6bef
	ld a, $40
	ldh [$ff00 + $1c], a

.l_6bef:
	push hl
	ld a, l
	add a, $09
	ld l, a
	ld a, [hl]
	and a
	jr nz, .l_6bd5
	ld a, l
	add a, $04
	ld l, a
	bit 7, [hl]
	jr nz, .l_6bd5
	pop hl
	call func_6d67

.l_6c04:
	dec l
	dec l
	jp .l_6d39

.l_6c09:
	dec l
	dec l
	dec l


func_6c0c::
	dec l
	call func_6bc5

.l_6c10:
	ld a, l
	add a, $04
	ld e, a
	ld d, h
	call func_6b02
	cp $00
	jr z, .l_6c3b
	cp $ff
	jr z, .l_6c24
	inc l
	jp .l_6c5c

.l_6c24:
	dec l
	push hl
	call func_6bc5
	call func_6bce
	ld e, a
	call func_6bb9
	call func_6bce
	ld d, a
	pop hl
	ld a, e
	ldi [hl], a
	ld a, d
	ldd [hl], a
	jr .l_6c10

.l_6c3b:
	ld hl, $dfe9
	ld [hl], $00
	call func_69a5
	ret


func_6c44::
	ld hl, $dfe9
	ld a, [hl]
	and a
	ret z
	ld a, $01
	ld [$df70], a
	ld hl, $df90

.l_6c52:
	inc l
	ldi a, [hl]
	and a
	jp z, .l_6c04
	dec [hl]
	jp nz, .l_6bd8

.l_6c5c:
	inc l
	inc l

.l_6c5e:
	call func_6bce
	cp $00
	jp z, .l_6c09
	cp $9d
	jp z, .l_6b89
	and $f0
	cp $a0
	jr nz, .l_6c8b
	ld a, b
	and $0f
	ld c, a
	ld b, $00
	push hl
	ld de, $df81
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	add hl, bc
	ld a, [hl]
	pop hl
	dec l
	ldi [hl], a
	call func_6bb9
	call func_6bce

.l_6c8b:
	ld a, b
	ld c, a
	ld b, $00
	call func_6bb9
	ld a, [$df70]
	cp $04
	jp z, .l_6cbc
	push hl
	ld a, l
	add a, $05
	ld l, a
	ld e, l
	ld d, h
	inc l
	inc l
	ld a, c
	cp $01
	jr z, .l_6cb7
	ld [hl], $00
	ld hl, $6e02
	add hl, bc
	ldi a, [hl]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a
	pop hl
	jp .l_6cd3

.l_6cb7:
	ld [hl], $01
	pop hl
	jr .l_6cd3

.l_6cbc:
	push hl
	ld de, $dfc6
	ld hl, $6e94
	add hl, bc

.l_6cc4:
	ldi a, [hl]
	ld [de], a
	inc e
	ld a, e
	cp $cb
	jr nz, .l_6cc4
	ld c, $20
	ld hl, $dfc4
	jr .l_6d01

.l_6cd3:
	push hl
	ld a, [$df70]
	cp $01
	jr z, .l_6cfc
	cp $02
	jr z, .l_6cf8
	ld c, $1a
	ld a, [$dfbf]
	bit 7, a
	jr nz, .l_6ced
	xor a
	ldh [c], a
	ld a, $80
	ldh [c], a

.l_6ced:
	inc c
	inc l
	inc l
	inc l
	inc l
	ldi a, [hl]
	ld e, a
	ld d, $00
	jr .l_6d0d

.l_6cf8:
	ld c, $16
	jr .l_6d01

.l_6cfc:
	ld c, $10
	ld a, $00
	inc c

.l_6d01:
	inc l
	inc l
	inc l
	ldd a, [hl]
	and a
	jr nz, .l_6d57
	ldi a, [hl]
	ld e, a

.l_6d0a:
	inc l
	ldi a, [hl]
	ld d, a

.l_6d0d:
	push hl
	inc l
	inc l
	ldi a, [hl]
	and a
	jr z, .l_6d16
	ld e, $01

.l_6d16:
	inc l
	inc l
	ld [hl], $00
	inc l
	ld a, [hl]
	pop hl
	bit 7, a
	jr nz, .l_6d34
	ld a, d
	ldh [c], a
	inc c
	ld a, e
	ldh [c], a
	inc c
	ldi a, [hl]
	ldh [c], a
	inc c
	ld a, [hl]
	or $80
	ldh [c], a
	ld a, l
	or $05
	ld l, a
	res 0, [hl]

.l_6d34:
	pop hl
	dec l
	ldd a, [hl]
	ldd [hl], a
	dec l

.l_6d39:
	ld de, $df70
	ld a, [de]
	cp $04
	jr z, .l_6d4a
	inc a
	ld [de], a
	ld de, $0010
	add hl, de
	jp .l_6c52

.l_6d4a:
	ld hl, $df9e
	inc [hl]
	ld hl, $dfae
	inc [hl]
	ld hl, $dfbe
	inc [hl]
	ret

.l_6d57:
	ld b, $00
	push hl
	pop hl
	inc l
	jr .l_6d0a


func_6d5e::
	ld a, b
	srl a
	ld l, a
	ld h, $00
	add hl, de
	ld e, [hl]
	ret


func_6d67::
	push hl
	ld a, l
	add a, $06
	ld l, a
	ld a, [hl]
	and $0f
	jr z, .l_6d89
	ld [$df71], a
	ld a, [$df70]
	ld c, $13
	cp $01
	jr z, .l_6d8b
	ld c, $18
	cp $02
	jr z, .l_6d8b
	ld c, $1d
	cp $03
	jr z, .l_6d8b

.l_6d89:
	pop hl
	ret

.l_6d8b:
	inc l
	ldi a, [hl]
	ld e, a
	ld a, [hl]
	ld d, a
	push de
	ld a, l
	add a, $04
	ld l, a
	ld b, [hl]
	ld a, [$df71]
	cp $01
	jr .l_6da6
	cp $03
	jr .l_6da1

.l_6da1:
	ld hl, $ffff
	jr .l_6dc2

.l_6da6:
	ld de, $6dcb
	call func_6d5e
	bit 0, b
	jr nz, .l_6db2
	swap e

.l_6db2:
	ld a, e
	and $0f
	bit 3, a
	jr z, .l_6dbf
	ld h, $ff
	or $f0
	jr .l_6dc1

.l_6dbf:
	ld h, $00

.l_6dc1:
	ld l, a

.l_6dc2:
	pop de
	add hl, de
	ld a, l
	ldh [c], a
	inc c
	ld a, h
	ldh [c], a
	jr .l_6d89
	nop
	nop
	nop
	nop
	nop
	nop
	stop
	nop
	rrc a
	nop
	nop
	ld de, $0f00
	ldh a, [$ff00 + $01]
	ld [de], a
	stop
	rst 38
	rst 28
	ld bc, $1012
	rst 38
	rst 28
	ld bc, $1012
	rst 38
	rst 28
	ld bc, $1012
	rst 38
	rst 28
	ld bc, $1012
	rst 38
	rst 28
	ld bc, $1012
	rst 38
	rst 28
	ld bc, $1012
	rst 38
	rst 28
	ld bc, $1012
	rst 38
	rst 28
	nop
	rrc a
	inc l
	nop
	sbc a, h
	nop
	ld b, $01
	ld l, e
	ld bc, $01c9
	inc hl
	ld [bc], a
	ld [hl], a
	ld [bc], a
	add a, $02
	ld [de], a
	inc bc
	ld d, [hl]
	inc bc
	sbc a, e
	inc bc
	jp c, .l_1603
	inc b
	ld c, [hl]
	inc b
	add a, e
	inc b
	or l
	inc b
	push hl
	inc b
	ld de, $3b05
	dec b
	ld h, e
	dec b
	adc a, c
	dec b
	xor h
	dec b
	adc a, $05
	<error>
	dec b
	ld a, [bc]
	ld b, $27
	ld b, $42
	ld b, $5b
	ld b, $72
	ld b, $89
	ld b, $9e
	ld b, $b2
	ld b, $c4
	ld b, $d6
	ld b, $e7
	ld b, $f7
	ld b, $06
	rlc a
	inc d
	rlc a
	ld hl, $2d07
	rlc a
	add hl, sp
	rlc a
	ld b, h
	rlc a
	ld c, a
	rlc a
	ld e, c
	rlc a
	ld h, d
	rlc a
	ld l, e
	rlc a
	ld [hl], e
	rlc a
	ld a, e
	rlc a
	add a, e
	rlc a
	adc a, d
	rlc a
	sub a, b
	rlc a
	sub a, a
	rlc a
	sbc a, l
	rlc a
	and d
	rlc a
	and a
	rlc a
	xor h
	rlc a
	or c
	rlc a
	or [hl]
	rlc a
	cp d
	rlc a
	cp [hl]
	rlc a
	pop bc
	rlc a
	call nz, func_c807
	rlc a
	rlc a
	adc a, $07
	pop de
	rlc a
	call nc, func_d607
	rlc a
	reti
	rlc a
	<error>
	rlc a
	<error>
	rlc a
	rst 18
	rlc a
	nop
	nop
	nop
	nop
	nop
	ret nz
	and c
	nop
	ldd a, [hl]
	nop
	ret nz
	or c
	nop
	add hl, hl
	ld bc, $61c0
	nop
	ldd a, [hl]
	nop
	ret nz
	ld [de], a
	inc [hl]
	ld b, l
	ld h, a
	sbc a, d
	cp h
	sbc a, $fe
	sbc a, b
	ld a, d
	or a
	cp [hl]
	xor b
	halt
	ld d, h
	ld sp, $2301
	ld b, h
	ld d, l
	ld h, a
	adc a, b
	sbc a, d
	cp e
	xor c
	adc a, b
	halt
	ld d, l
	ld b, h
	inc sp
	ldi [hl], a
	ld de, $2301
	ld b, l
	ld h, a


func_6ecd::
	adc a, c
	xor e
	call func_feef
	call c, func_98ba
	halt
	ld d, h
	ldd [hl], a
	stop
	and c
	add a, d
	inc hl
	inc [hl]
	ld b, l
	ld d, [hl]
	ld h, a
	ld a, b
	adc a, c
	sbc a, d
	xor e
	cp h
	call func_3264
	stop
	ld de, $5623
	ld a, b
	sbc a, c
	sbc a, b
	halt
	ld h, a
	sbc a, d
	rst 18
	cp $c9
	add a, l
	ld b, d
	ld de, $0231
	inc b
	ld [$2010], sp
	ld b, b
	inc c
	jr .l_6f32
	dec b
	nop
	ld bc, $0503
	ld a, [bc]
	inc d
	jr z, .l_6f5b
	rrc a
	ld e, $3c
	inc bc
	ld b, $0c
	jr .l_6f43
	ld h, b
	ld [de], a
	inc h
	ld c, b
	ld [$0010], sp
	rlc a
	ld c, $1c
	jr c, .l_6f8f
	dec d
	ldi a, [hl]
	ld d, h
	inc b
	ld [$2010], sp
	ld b, b
	add a, b
	jr .l_6f5a
	ld h, b
	inc b
	add hl, bc
	ld [de], a
	inc h
	ld c, b
	sub a, b
	dec de

.l_6f32:
	ld [hl], $6c
	inc c
	jr .l_6f3b
	ld a, [bc]
	inc d
	jr z, .l_6f8b

.l_6f3b:
	and b
	ld e, $3c
	ld a, b
	nop
	ld c, $6f
	ld sp, hl

.l_6f43:
	ld a, h
	rst 38
	ld a, h
	ld de, $217d
	ld a, l
	nop
	dec b
	ld l, a
	ld c, b
	ld a, [hl]
	ld b, h
	ld a, [hl]
	ld c, d
	ld a, [hl]
	ld c, h
	ld a, [hl]
	nop
	ld c, $6f
	dec sp
	halt

.l_6f5a:
	inc sp

.l_6f5b:
	halt
	ld b, c
	halt
	ld h, e
	halt
	nop
	ld sp, hl
	ld l, [hl]
	nop
	halt
	<error>
	ld [hl], l
	ld [bc], a
	halt
	nop
	nop
	nop
	ld c, $6f
	ld c, h
	ld [hl], c
	ld b, d
	ld [hl], c
	ld d, [hl]
	ld [hl], c
	ld h, d
	ld [hl], c
	nop
	ld c, $6f
	add a, $72
	cp b
	ld [hl], d
	call nc, func_0272
	ld [hl], e
	nop
	ld c, $6f
	ld [$fa70], sp
	ld l, a
	nop
	nop
	nop

.l_6f8b:
	nop
	nop
	dec b
	ld l, a

.l_6f8f:
	sbc a, l
	ld a, [hl]
	sub a, c
	ld a, [hl]
	xor c
	ld a, [hl]
	or l
	ld a, [hl]
	nop
	ld c, $6f
	jr z, .l_7018
	inc h
	ld a, h
	ldi a, [hl]
	ld a, h
	inc l
	ld a, h
	nop
	ld c, $6f
	nop
	nop
	nop
	ld a, d
	nop
	nop
	nop
	nop
	nop
	ld c, $6f
	nop
	nop
	ld h, $7a
	ldi a, [hl]
	ld a, d
	nop
	nop
	nop
	ld c, $6f
	ld [hl], e
	ld a, d
	ld l, a
	ld a, d
	ld [hl], l
	ld a, d
	nop
	nop
	nop
	ld c, $6f
	rst 18
	ld a, d
	<error>
	ld a, d
	push hl
	ld a, d
	rst 20
	ld a, d
	nop
	ld c, $6f
	ld h, l
	ld a, e
	ld l, e
	ld a, e
	ld l, a
	ld a, e
	ld [hl], e
	ld a, e
	nop
	ld c, $6f
	ld l, h
	ld a, b
	halt
	ld a, b
	ld a, [hl]
	ld a, b
	add a, [hl]
	ld a, b
	nop
	dec hl
	ld l, a
	ld b, e
	ld [hl], l
	ld c, e
	ld [hl], l
	ld d, c
	ld [hl], l
	nop
	nop
	nop
	ld c, $6f
	adc a, l
	ld [hl], l
	sub a, l
	ld [hl], l
	sbc a, e
	ld [hl], l
	nop
	nop
	ld d, $70
	inc [hl]
	ld [hl], b
	ld d, $70
	ld c, l
	ld [hl], b
	sub a, e
	ld [hl], b
	rst 38
	rst 38
	ld a, [$626f]
	ld [hl], b
	ld [hl], h
	ld [hl], b
	ld h, d
	ld [hl], b
	add a, l
	ld [hl], b
	<error>
	ld [hl], b
	rst 38
	rst 38
	ld [$9d70], sp
	ld [hl], h

.l_7018:
	nop
	ld b, c
	and d
	ld b, h
	ld c, h
	ld d, [hl]
	ld c, h
	ld b, d

.l_7020:
	ld c, h
	ld b, h
	ld c, h
	ld a, $4c
	inc a
	ld c, h
	ld b, h
	ld c, h
	ld d, [hl]
	ld c, h
	ld b, d
	ld c, h
	ld b, h
	ld c, h
	ld a, $4c
	inc a
	ld c, h
	nop
	ld b, h
	ld c, h
	ld b, h
	ld a, $4e
	ld c, b
	ld b, d
	ld c, b
	ld b, d
	ldd a, [hl]
	ld c, h
	ld b, h
	ld a, $4c
	ld c, b
	ld b, h
	ld b, d
	ld a, $3c
	inc [hl]
	inc a
	ld b, d
	ld c, h
	ld c, b
	nop
	ld b, h
	ld c, h
	ld b, h
	ld a, $4e
	ld c, b
	ld b, d
	ld c, b
	ld b, d
	ldd a, [hl]
	ld d, d
	ld c, b
	ld c, h
	ld d, d
	ld c, h
	ld b, h
	ldd a, [hl]
	ld b, d
	xor b
	ld b, h
	nop
	sbc a, l
	ld h, h
	nop
	ld b, c
	and e
	ld h, $3e
	inc a
	ld h, $2c
	inc [hl]
	ld a, $36
	inc [hl]
	ld a, $2c
	inc [hl]
	nop
	ld h, $3e
	jr nc, .l_709a
	ldd a, [hl]
	inc l
	ld e, $36
	jr nc, .l_7020
	inc [hl]
	ld [hl], $34
	jr nc, .l_70af
	ldi a, [hl]
	nop
	and e
	ld h, $3e
	jr nc, .l_70ac
	ldd a, [hl]
	ldi a, [hl]
	inc l
	inc [hl]
	inc [hl]
	inc l
	ldi [hl], a
	inc d
	nop
	and d
	ld d, d
	ld c, [hl]
	ld c, h
	ld c, b
	ld b, h
	ld b, d

.l_709a:
	ld b, h
	ld c, b
	ld c, h
	ld b, h
	ld c, b
	ld c, [hl]
	ld c, h
	ld c, [hl]
	and e
	ld d, d
	ld b, d
	and d
	ld b, h
	ld c, b
	and e
	ld c, h
	ld c, b
	ld c, h

.l_70ac:
	ld d, [hl]
	ld d, b
	and d

.l_70af:
	ld d, [hl]
	ld e, d
	and e
	ld e, h
	ld e, d
	and d
	ld d, [hl]
	ld d, d
	ld d, b
	ld c, h
	ld d, b
	ld c, d
	xor b
	ld c, h

.l_70bd:
	and a
	ld d, d
	and c
	ld d, [hl]
	ld e, b
	and e
	ld d, [hl]
	and d
	ld d, d
	ld c, [hl]
	ld d, d
	ld c, h
	ld c, [hl]
	ld c, b
	and a
	ld d, [hl]
	and c
	ld e, d

.l_70cf:
	ld e, h
	and e
	ld e, d
	and d
	ld d, [hl]
	ld d, h
	ld d, [hl]
	ld d, b
	ld d, h
	ld c, h
	ld e, d
	ld d, h
	ld c, h

.l_70dc:
	ld d, h
	ld e, d
	ld h, b
	ld h, [hl]
	ld d, h
	ld h, h
	ld d, h
	ld h, b
	ld d, h
	and e
	ld e, h
	and d
	ld h, b
	ld e, h
	ld e, d
	ld e, h
	and c
	ld d, [hl]
	ld e, d
	and h
	ld d, [hl]
	and d
	ld bc, $a200
	inc [hl]
	ldd a, [hl]
	ld b, h
	ldd a, [hl]
	jr nc, .l_7135
	inc [hl]
	ldd a, [hl]
	inc l
	ldd a, [hl]
	ldi a, [hl]
	ldd a, [hl]
	inc l
	ldd a, [hl]
	ld b, h
	ldd a, [hl]
	jr nc, .l_7141
	inc [hl]
	ldd a, [hl]
	inc l
	ldd a, [hl]
	ldi a, [hl]
	ldd a, [hl]
	inc l
	inc [hl]
	inc l
	ld h, $3e
	jr c, .l_7146
	jr c, .l_7140
	jr c, .l_714a
	jr c, .l_70bd
	inc [hl]
	ld b, d
	ldi a, [hl]
	and d
	inc [hl]
	ldd a, [hl]
	ld b, d
	ldd a, [hl]
	jr nc, .l_715e
	ld l, $34
	ld h, $34
	ld l, $34
	xor b
	jr nc, .l_70cf
	ldd [hl], a
	jr c, .l_715a
	jr c, .l_7164
	jr c, .l_70dc
	inc [hl]

.l_7135:
	and e
	inc [hl]
	ldi a, [hl]
	inc h
	inc e
	jr nz, .l_7160
	inc l
	jr nc, .l_7173
	xor b

.l_7140:
	ld h, $00
	ld l, b
	ld [hl], c
	ld l, b
	ld [hl], c

.l_7146:
	xor [hl]
	ld [hl], c
	rst 38
	rst 38

.l_714a:
	ld b, d
	ld [hl], c
	bit 6, c
	bit 6, c
	dec e
	ld [hl], d
	rst 38
	rst 38
	ld c, h
	ld [hl], c
	ldd a, [hl]
	ld [hl], d
	ldd a, [hl]
	ld [hl], d

.l_715a:
	ld a, a
	ld [hl], d
	ld a, a
	ld [hl], d

.l_715e:
	rst 38
	rst 38

.l_7160:
	ld d, [hl]
	ld [hl], c
	and e
	ld [hl], d

.l_7164:
	rst 38
	rst 38
	ld h, d
	ld [hl], c
	sbc a, l
	add a, h
	nop
	add a, c
	and e
	ld d, d
	and d
	ld c, b
	ld c, d
	and e
	ld c, [hl]

.l_7173:
	and d
	ld c, d
	ld c, b
	and e
	ld b, h
	and d
	ld b, h
	ld c, d
	and e
	ld d, d
	and d
	ld c, [hl]
	ld c, d
	and a
	ld c, b
	and d
	ld c, d
	and e
	ld c, [hl]
	ld d, d
	and e
	ld c, d
	ld b, h
	ld b, h
	ld bc, $01a2
	and e
	ld c, [hl]
	and d
	ld d, h
	and e
	ld e, h
	and d
	ld e, b
	ld d, h
	and a
	ld d, d
	and d
	ld c, d
	and e
	ld d, d
	and d
	ld c, [hl]
	ld c, d
	and e
	ld c, b
	and d
	ld c, b
	ld c, d
	and e
	ld c, [hl]
	ld d, d
	and e
	ld c, d
	ld b, h
	ld b, h
	ld bc, $9d00
	ld d, b
	nop
	add a, c
	and h
	ldd a, [hl]
	ldd [hl], a
	ld [hl], $30
	and h
	ldd [hl], a
	inc l
	xor b
	ldi a, [hl]
	and e
	ld bc, $3aa4
	ldd [hl], a
	ld [hl], $30
	and e
	ldd [hl], a
	ldd a, [hl]
	and h
	ld b, h
	ld b, d
	ld bc, $9d00
	ld b, e
	nop
	add a, c
	and e
	ld c, b
	and d
	ld b, d
	ld b, h
	ld c, b
	and c
	ld d, d
	ld c, [hl]
	and d
	ld b, h
	ld b, d
	and a
	ldd a, [hl]
	and d
	ld b, h
	ld c, d
	ld bc, $48a2
	ld b, h
	and c
	ld b, d
	ld b, d
	and d
	ldd a, [hl]
	ld b, d
	ld b, h
	and e
	ld c, b
	ld c, d
	and e
	ld b, h
	ldd a, [hl]
	ldd a, [hl]
	ld bc, $1ea2
	and e
	inc a
	and d
	ld b, h
	ld c, d
	and c
	ld c, d
	ld c, d
	and d
	ld c, b
	ld b, h
	and a
	ld b, b
	and d
	ldd a, [hl]
	ld b, b
	and c
	ld b, h
	ld b, b
	and d
	inc a
	ldd a, [hl]
	ld b, d
	ldd a, [hl]
	ld b, d
	ld b, h
	ld c, b
	ld b, d
	ld c, d
	ld b, d
	and c
	ld b, h
	ld c, d
	ldd a, [hl]
	ld bc, $3aa3
	ldd a, [hl]
	ld bc, $9d00
	jr nc, .l_7220

.l_7220:
	add a, c
	and h
	ldd [hl], a
	inc l
	jr nc, .l_7250

.l_7226:
	inc l
	ldi [hl], a
	and h
	ldi [hl], a
	and e
	jr nc, .l_722e
	and h

.l_722e:
	ldd [hl], a
	inc l
	jr nc, .l_725c
	and e
	inc l
	ldd [hl], a
	and h
	ldd a, [hl]
	ld [hl], $01
	nop
	sbc a, l
	ret
	ld l, [hl]
	jr nz, .l_71e1
	ldi [hl], a
	ldd a, [hl]
	ldi [hl], a
	ldd a, [hl]
	ldi [hl], a
	ldd a, [hl]
	ldi [hl], a
	ldd a, [hl]
	inc l
	ld b, h
	inc l
	ld b, h
	inc l
	ld b, h
	inc l
	ld b, h
	ldi a, [hl]

.l_7250:
	ld b, d
	ldi a, [hl]
	ld b, d
	ldi [hl], a
	ldd a, [hl]
	ldi [hl], a
	ldd a, [hl]
	inc l
	ld b, h
	inc l
	ld b, h
	inc l

.l_725c:
	ld b, h
	jr nc, .l_7291
	ld [hl], $1e
	ld bc, $011e
	ld e, $2c
	inc h
	ld a, [de]
	ldd [hl], a
	ld bc, $1a32
	jr z, .l_7296
	ld bc, $4830
	ld bc, $0148
	ldd a, [hl]
	ld bc, $2c42
	ldd a, [hl]
	inc l
	ldd a, [hl]
	and e
	inc l
	ld bc, $9d00
	ret
	ld l, [hl]
	jr nz, .l_7226
	ld b, h
	ld d, d
	ld b, h
	ld d, d
	ld b, h
	ld d, d
	ld b, h
	ld d, d
	ld b, d
	ld d, d
	ld b, d
	ld d, d
	ld b, d

.l_7291:
	ld d, d
	ld b, d
	ld d, d
	ld b, h
	ld d, d

.l_7296:
	ld b, h
	ld d, d
	ld b, h
	ld d, d
	ld b, h
	ld d, d
	ld b, d
	ld d, d
	ld b, d
	ld d, d
	and h
	ld bc, $a200
	ld bc, $0106
	ld b, $01
	and c
	ld b, $06
	and d
	ld bc, $0106
	ld b, $01
	ld b, $01
	ld b, $06
	ld b, $00
	dec bc
	ld [hl], e
	ccf
	ld [hl], e
	ld h, a
	ld [hl], e
	ld h, a
	ld [hl], e
	ret
	ld [hl], e
	rst 38
	rst 38
	cp b
	ld [hl], d
	ld [$3c73], sp
	ld [hl], e
	adc a, [hl]
	ld [hl], e
	adc a, [hl]
	ld [hl], e
	ld c, e
	ld [hl], h
	rst 38
	rst 38
	add a, $72
	rr a
	ld [hl], e
	ld d, e
	ld [hl], e
	or l
	ld [hl], e
	or l
	ld [hl], e
	or l
	ld [hl], e
	or l
	ld [hl], e
	or l
	ld [hl], e
	or l
	ld [hl], e
	ret nz
	ld [hl], h
	sbc a, $74
	sbc a, $74
	sbc a, $74
	xor $74
	cp $74
	cp $74
	ld c, $75
	ld c, $75
	ld e, $75
	ld e, $75
	ld c, $75
	ld l, $75
	rst 38
	rst 38
	call nc, func_3372
	ld [hl], e
	rst 38
	rst 38
	ld [bc], a
	ld [hl], e
	and l
	ld bc, $9d00
	ld h, d
	nop
	add a, b
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	jr nc, .l_7347
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	jr nc, .l_734e
	nop
	sbc a, l
	jp [hl]
	ld l, [hl]
	and b
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	jr nc, .l_735b
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	jr nc, .l_7362
	nop
	and d
	ld b, $a1
	ld b, $06
	and d
	ld b, $06
	nop
	and l
	ld bc, $9d00
	ldd [hl], a
	nop
	add a, b
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]

.l_7347:
	ldd a, [hl]
	and d
	jr nc, .l_737b
	ldd a, [hl]
	and c
	ldd a, [hl]

.l_734e:
	ldd a, [hl]
	and d
	jr nc, .l_7382
	nop
	sbc a, l
	jp [hl]
	ld l, [hl]
	and b
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]

.l_735b:
	ldd a, [hl]
	and d
	jr nc, .l_738f
	ldd a, [hl]
	and c
	ldd a, [hl]

.l_7362:
	ldd a, [hl]
	and d
	jr nc, .l_7396
	nop
	sbc a, l
	add a, d
	nop
	add a, b
	and d
	ldd a, [hl]
	ld c, b
	ld d, d
	ld d, b
	ld d, d
	and c
	ld c, b
	ld c, b
	and d
	ld c, d
	ld b, h
	ld c, b
	and c
	ld b, b
	ld b, b

.l_737b:
	and d
	ld b, h
	ld a, $40
	and c
	ldd a, [hl]
	ldd a, [hl]

.l_7382:
	and d
	ld a, $38
	ldd a, [hl]
	jr nc, .l_73ba
	jr c, .l_73c4
	jr nc, .l_73be
	ld a, $00
	sbc a, l

.l_738f:
	ld d, e
	nop
	ld b, b
	and d
	jr nc, .l_73d5
	ld b, b

.l_7396:
	ld b, h
	ld b, b
	and c
	ld a, $40
	and d
	ld b, h
	ld a, $40
	and c
	jr c, .l_73dc
	and d
	ld a, $38
	ldd a, [hl]
	and c
	ld l, $30
	and d
	jr c, .l_73dc
	jr nc, .l_73d6
	inc l
	inc l
	jr nc, .l_73da
	inc l
	jr c, .l_73b5

.l_73b5:
	sbc a, l
	jp [hl]
	ld l, [hl]
	and b
	and d

.l_73ba:
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]

.l_73be:
	and d
	jr nc, .l_73f1
	ldd a, [hl]
	and c
	ldd a, [hl]

.l_73c4:
	ldd a, [hl]
	and d
	jr nc, .l_73f8
	nop
	xor b
	ldd a, [hl]
	and d
	ld a, $38
	xor b
	ldd a, [hl]
	and e
	ld a, $a2
	ld b, b
	and c

.l_73d5:
	ld b, b

.l_73d6:
	ld b, b
	and d
	ld b, h
	ld a, $40
	and c

.l_73dc:
	ld b, b
	ld b, b
	and d
	ld b, h
	ld a, $a8
	ld b, b
	and e
	ld b, h
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, d
	ld b, h
	ld c, b
	and c
	ld c, b

.l_73f0:
	ld c, b

.l_73f1:
	and d
	ld c, d
	ld b, h
	xor b
	ld c, b

.l_73f6:
	and e
	ld c, h

.l_73f8:
	and d
	ld c, [hl]
	and c
	ld c, [hl]
	ld c, [hl]
	and d
	ld c, [hl]
	ld c, [hl]
	ld d, d
	ld c, [hl]
	ld c, [hl]
	ld c, h
	ld c, [hl]
	and c
	ld c, [hl]
	ld c, [hl]
	and d
	ld c, [hl]
	ld c, [hl]
	ld d, d
	ld c, [hl]
	ld c, [hl]
	ld c, h
	ld c, [hl]
	and c
	ld c, [hl]
	ld c, [hl]
	and d
	ld c, [hl]
	ld c, [hl]
	ld c, h
	and c
	ld c, h
	ld c, h
	and d
	ld c, h
	ld c, h
	ld c, d
	and c
	ld c, d
	ld c, d
	and d
	ld c, d
	ld b, h
	ld a, $40
	ld b, h
	ld [hl], $44
	and c
	ld b, b
	ld b, b
	and d
	ld [hl], $a3
	ld b, b
	and c
	ld [hl], $3a
	and d
	ld [hl], $30
	ld b, h
	and c
	ld b, b
	ld b, b
	and d
	ld [hl], $a3
	ld b, b
	and c
	ld [hl], $3a
	and d
	ld [hl], $2e
	and l
	ld [hl], $a8

.l_7447:
	ld bc, $38a3
	nop
	xor b
	jr nc, .l_73f0
	jr nc, .l_7480
	xor b
	jr nc, .l_73f6
	ld [hl], $a5
	ld bc, $01a8
	and e
	ld a, $a2
	ld b, b
	and c
	ld b, b
	ld b, b
	and d
	ld b, h
	ld a, $40
	and c
	ld b, b
	ld b, b
	and d
	ld b, h
	ld a, $a8
	ld [hl], $a3
	ldd a, [hl]
	and d
	ld a, $a1
	ld b, b
	ld b, h
	and d
	ld a, $44
	ld c, b
	ld c, b
	ld c, b
	ldd a, [hl]
	ld a, $a1
	ld b, b
	ld b, h
	and d
	ld a, $44

.l_7480:
	ld b, [hl]
	ld b, [hl]

.l_7482:
	ld b, [hl]
	ldd a, [hl]
	ld a, $a1

.l_7486:
	ld b, b
	ld b, h
	and d

.l_7489:
	ld a, $44
	ldd a, [hl]
	and c

.l_748d:
	ld a, $40
	and d
	ldd a, [hl]
	ld b, b

.l_7492:
	ldd a, [hl]
	and c
	ld a, $40

.l_7496:
	and d
	ld a, $3e

.l_7499:
	inc l
	ldd a, [hl]
	ld a, $26

.l_749d:
	jr nc, .l_7440
	jr nc, .l_74d1
	and d
	jr nc, .l_7447
	jr nc, .l_7447
	jr nc, .l_74dc
	and d

.l_74a9:
	jr nc, .l_74d3
	ld l, $a1

.l_74ad:
	ld l, $2e
	and d
	ld l, $a3
	ld l, $a1
	ld l, $32
	and d
	ld l, $28
	and l
	ld h, $a8
	ld bc, $2ca3
	nop
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd [hl], a
	inc l
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	jr c, .l_74ff
	ldd a, [hl]
	and c

.l_74d1:
	ldd a, [hl]
	ldd a, [hl]

.l_74d3:
	and d
	ldd [hl], a
	inc l
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	inc l

.l_74dc:
	ld e, $00
	and d
	jr z, .l_7482
	ld b, b
	jr z, .l_7486
	ld e, $36
	jr z, .l_7489
	ld b, b
	jr z, .l_748d
	ld e, $36
	nop
	and d
	jr z, .l_7492
	ld b, b
	jr z, .l_7496
	ld e, $36
	jr z, .l_7499
	ld b, b
	jr z, .l_749d
	inc l
	ld b, h
	nop
	and d

.l_74ff:
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	jr z, .l_74a9
	ld b, b
	jr z, .l_74ad
	jr z, .l_754d
	nop
	and d
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	nop
	and d
	ldi [hl], a
	and c
	ldd a, [hl]
	ldi [hl], a
	and d
	ldi [hl], a
	ldd a, [hl]
	ldi [hl], a
	and c
	ldd a, [hl]
	ldi [hl], a
	and d
	ldi [hl], a
	ldd a, [hl]
	nop
	and d
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	ld e, $a1
	ld [hl], $1e
	and d
	and h
	ld a, $00
	ld [hl], $3e
	ld b, h
	and h
	ld b, h
	ld d, a
	ld [hl], l
	ld h, d
	ld [hl], l
	rst 38
	rst 38
	ld b, l
	ld [hl], l
	ld e, [hl]
	ld [hl], l

.l_754d:
	rst 38
	rst 38
	ld c, e
	ld [hl], l
	ld a, h
	ld [hl], l
	rst 38
	rst 38
	ld d, c
	ld [hl], l
	sbc a, l
	jr nz, .l_755a

.l_755a:
	add a, c
	xor d
	ld bc, $9d00
	ld [hl], b
	nop
	add a, c
	and d
	ld b, d
	ldd [hl], a
	jr c, .l_75a9
	ld b, [hl]
	inc [hl]
	inc a
	ld b, [hl]
	ld c, d
	jr c, .l_75b0
	ld c, d
	ld c, h
	inc a
	ld b, d
	ld c, h
	ld b, [hl]
	inc [hl]
	inc a
	ld b, [hl]
	ld b, b
	ld l, $34
	ld b, b
	nop
	sbc a, l
	jp [hl]
	ld l, [hl]
	ld hl, $42a8
	and e
	ldi a, [hl]
	xor b
	ld b, d
	and e
	ldi a, [hl]
	xor b
	ld b, d
	and e
	ldi a, [hl]
	nop
	and c
	ld [hl], l
	xor h
	ld [hl], l
	rst 38
	rst 38
	adc a, a
	ld [hl], l
	xor b
	ld [hl], l
	rst 38
	rst 38
	sub a, l
	ld [hl], l
	xor $75
	rst 38
	rst 38
	sbc a, e
	ld [hl], l
	sbc a, l
	jr nz, .l_75a4

.l_75a4:
	add a, c
	xor d
	ld bc, $9d00

.l_75a9:
	ld [hl], b
	nop
	add a, c
	and d
	ld c, h
	ld b, d
	ld d, b

.l_75b0:
	ld b, d
	ld d, h
	ld b, d
	ld d, b
	ld b, d
	ld d, [hl]
	ld b, d
	ld d, h
	ld b, d
	ld d, b
	ld b, d
	ld d, h
	ld b, d
	ld c, h
	ld b, d
	ld d, b
	ld b, d
	ld d, h
	ld b, d
	ld d, b
	ld b, d
	ld d, [hl]
	ld b, d
	ld d, h
	ld b, d
	ld d, b

.l_75ca:
	ld b, d
	ld d, h
	ld b, d
	ld e, d
	ld b, [hl]
	ld d, [hl]
	ld b, [hl]
	ld d, h
	ld b, [hl]
	ld d, b
	ld b, [hl]
	ld c, [hl]
	ld b, [hl]
	ld d, b
	ld b, [hl]
	ld d, h
	ld b, [hl]
	ld d, b
	ld b, [hl]
	ld d, b
	ld a, $4c
	ld a, $4c
	ld a, $4a
	ld a, $4a
	ld a, $46
	ld a, $4a
	ld a, $50
	ld a, $00
	sbc a, l
	jp [hl]
	ld l, [hl]
	ld hl, $4ca5
	ld c, d
	ld b, [hl]
	ld b, d
	jr c, .l_7637
	ld b, d
	ld b, d
	nop
	inc b
	halt
	nop
	nop
	inc d
	halt
	inc hl
	halt
	sbc a, l
	or d
	nop
	add a, b
	and d
	ld h, b
	ld e, h
	ld h, b
	ld e, h
	ld h, b
	ld h, d
	ld h, b
	ld e, h
	and h
	ld h, b
	nop
	sbc a, l
	sub a, d
	nop
	add a, b
	and d
	ld d, d
	ld c, [hl]
	ld d, d
	ld c, [hl]
	ld d, d
	ld d, h
	ld d, d
	ld c, [hl]
	and h
	ld d, d
	sbc a, l
	jp [hl]
	ld l, [hl]
	jr nz, .l_75ca
	ld h, d
	ld h, b
	ld h, d
	ld h, b
	ld h, d
	ld h, [hl]
	ld h, d
	ld h, b
	and e
	ld h, d
	ld bc, $766f
	ld l, c
	ld [hl], a

.l_7637:
	ld l, c
	ld [hl], a

.l_7639:
	nop
	nop
	cp a
	halt
	xor d
	ld [hl], a
	inc a
	ld a, b
	inc c
	ld [hl], a
	<error>
	ld [hl], a
	<error>
	ld [hl], a
	push af
	ld [hl], a
	<error>
	ld [hl], a
	<error>
	ld [hl], a
	cp $77
	push af
	ld [hl], a
	<error>
	ld [hl], a
	<error>
	ld [hl], a
	cp $77
	push af
	ld [hl], a
	rlc a
	ld a, b
	ld de, $fe78
	ld [hl], a
	push af
	ld [hl], a
	<error>
	ld [hl], a
	ld e, e
	ld [hl], a
	ld e, e
	ld [hl], a
	ld a, [de]
	ld a, b
	ld a, [de]
	ld a, b
	ld a, [de]
	ld a, b
	ld a, [de]
	ld a, b
	sbc a, l
	jp .l_8000
	and d
	inc a


func_7675::
	ld a, $3c
	ld a, $38
	ld d, b
	and e
	ld bc, $3ca2
	ld a, $3c
	ld a, $38
	ld d, b
	and e
	ld bc, $01a2
	ld c, b
	ld bc, $0146
	ld b, d
	ld bc, $a146
	ld b, d
	ld b, [hl]
	and d
	ld b, d
	ld b, d
	jr c, .l_7639
	inc a
	ld bc, $3ea2
	ld b, d
	ld a, $42
	inc a
	ld d, h
	and e
	ld bc, $3ea2
	ld b, d
	ld a, $42
	inc a
	ld d, h
	and e
	ld bc, $01a2
	ld d, [hl]
	ld bc, $0154
	ld d, h
	ld bc, $a250
	ld bc, $50a1
	ld d, h
	and d
	ld d, b
	ld c, [hl]
	and e
	ld d, b
	ld bc, $9d00
	ld [hl], h
	nop
	add a, b
	and d
	ld [hl], $38
	ld [hl], $38
	ld l, $3e
	and e
	ld bc, $36a2
	jr c, .l_7706
	jr c, .l_7700
	ld a, $a3
	ld bc, $01a2
	ld [hl], $01
	ld [hl], $01
	ldd [hl], a
	ld bc, $3636
	ldd [hl], a
	ldd [hl], a
	jr nc, .l_7686
	ld [hl], $01
	and d
	jr c, .l_7724
	jr c, .l_7726
	ld [hl], $4e
	and e
	ld bc, $38a2
	inc a
	jr c, .l_772f
	ld [hl], $4e
	and e
	ld bc, $01a2
	ld d, b

.l_76fa:
	ld bc, $014e
	ld b, [hl]
	ld bc, $a246
	ld bc, $48a1
	ld c, [hl]
	and d

.l_7706:
	ld c, b
	ld b, [hl]
	and e
	ld b, b
	ld bc, $9d00
	jp [hl]
	ld l, [hl]
	jr nz, .l_76b3
	ld c, b
	ld b, [hl]
	ld c, b
	ld b, [hl]
	ld a, $20
	and e
	ld bc, $48a2
	ld b, [hl]
	ld c, b
	ld b, [hl]
	ld a, $20
	and e
	ld bc, $2ea2

.l_7724:
	inc a
	ld l, $24
	inc h
	inc h
	inc h
	inc a
	ldi a, [hl]
	ld a, $2a
	ld a, $a6
	ld l, $a3
	ld bc, $01a1
	and d
	ld c, b
	ld b, [hl]
	ld c, b
	ld b, [hl]
	ld l, $2e
	and e
	ld bc, $48a2
	ld b, [hl]
	ld c, b

.l_7742:
	ld b, [hl]
	ld l, $2e
	and e
	ld bc, $2aa2
	inc a
	ldi a, [hl]
	inc a
	ld l, $3e
	ld l, $3e
	ld l, $42
	ld l, $42
	and [hl]
	jr c, .l_76fa
	ld bc, $01a1
	nop
	xor b
	ld bc, $06a2
	dec bc
	xor b
	ld bc, $06a2
	dec bc
	and l
	ld bc, $0001
	sbc a, l
	push bc
	nop
	add a, b
	and c
	ld b, [hl]
	ld c, d
	and h
	ld b, [hl]
	and d
	ld bc, $50a3
	xor b
	ld c, d
	and e
	ld bc, $42a1
	ld b, [hl]
	and h
	ld b, d
	and d
	ld bc, $4ea3
	and c
	ld c, [hl]
	ld d, b
	and h
	ld b, [hl]
	and a
	ld bc, $40a1
	ld b, [hl]
	and h
	ld b, b
	and d
	ld bc, $46a3
	and c
	ld b, [hl]
	ld c, d
	and h
	ld b, d
	and a
	ld bc, $36a1
	jr c, .l_7742
	ld [hl], $a2
	ld bc, $3ca3
	and a
	ld b, d
	and h
	ld b, b
	and d
	ld bc, $9d00
	add a, h
	nop
	ld b, c
	and c
	ld b, b
	ld b, d
	and h
	ld b, b
	and d
	ld bc, $40a3
	xor b
	ld b, d
	and e
	ld bc, $3ca1
	ld b, b
	and h
	inc a
	and d
	ld bc, $3ca3
	and c
	inc a
	ld b, b
	and h
	ld b, b
	and a
	ld bc, $36a1
	ldd [hl], a
	and h
	ld l, $a2
	ld bc, $40a3
	and c
	ld [hl], $38
	and h
	ldd [hl], a
	and a
	ld bc, $2ea1
	ldd [hl], a
	and h
	ld l, $a2
	ld bc, $2aa3
	and a
	jr nc, .l_778b
	ld l, $a2
	ld bc, $a200
	jr c, .l_7826
	ld bc, $3838
	jr c, .l_77f4
	jr c, .l_77f5

.l_77f5:
	ld l, $2e
	ld bc, $2e2e
	ld l, $01
	ld l, $00
	ldi a, [hl]
	ldi a, [hl]
	ld bc, $2a2a
	ldi a, [hl]
	ld bc, $002a
	and d
	jr c, .l_7842
	ld bc, $3638
	ld [hl], $01
	ld [hl], $00
	ldd [hl], a
	ldd [hl], a
	ld bc, $2e32
	ld l, $01
	ld l, $00
	and d
	ld b, $0b
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0106
	dec bc
	ld bc, $000b
	sbc a, l
	ld h, [hl]
	nop
	add a, c
	and a
	ld e, b

.l_7842:
	ld e, d
	and e
	ld e, b
	and a
	ld e, [hl]
	and h
	ld e, d
	and d
	ld bc, $50a7
	ld d, h
	and e
	ld e, b
	and a
	ld e, d
	and h
	ld e, b
	and d
	ld bc, $50a7
	and e
	ld c, [hl]
	and a
	ld c, [hl]
	ld e, b
	ld d, h
	and e
	ld c, d
	and a
	ld e, d
	ld e, [hl]
	and e
	ld e, d
	and a
	ld d, h
	and h
	ld d, b
	and d
	ld bc, $8e00
	ld a, b
	ld de, $8e79
	ld a, b
	sub a, [hl]
	ld a, c
	nop
	nop
	xor l
	ld a, b
	jr c, .l_78f3
	xor l
	ld a, b

.l_787c:
	cp d
	ld a, c
	push de
	ld a, b
	ld e, [hl]
	ld a, c
	push de
	ld a, b
	<error>
	ld a, c
	cp $78
	add a, h
	ld a, c
	cp $78
	add a, h
	ld a, c
	sbc a, l
	pop de
	nop
	add a, b
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld d, d
	ld c, h
	ld c, b
	ld b, h
	and c
	ld c, h
	ld d, d
	nop
	sbc a, l
	or d
	nop
	add a, b
	and d
	ld d, d
	and c
	ld d, d
	ld d, d
	and d
	ld d, d
	and c
	ld d, d
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld b, h
	ld bc, $a14c
	ld c, h
	ld c, h
	and d
	ld c, h
	and c
	ld c, h
	ld c, h
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	ld bc, $9d00
	jp [hl]
	ld l, [hl]
	jr nz, .l_787c
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld c, [hl]
	and c
	ld d, d
	ld d, d
	and d
	ld d, [hl]
	ld bc, $5ca2
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c

.l_78f3:
	ld e, h
	ld e, h
	and d
	ld b, h
	and c
	ld c, b
	ld c, b
	and d
	ld c, h
	ld bc, $a200
	ld b, $a7
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $06a2
	and a
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $a200
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld b, d
	and c
	ld b, d
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld c, h
	and c
	ld c, h
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld c, b
	ld b, h
	and c
	ld c, b
	ld d, d
	ld d, [hl]
	ld e, d
	nop
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ld [hl], $a1
	ld [hl], $36
	and d
	ld [hl], $01
	nop
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld b, d
	and c
	ld b, d
	ld b, d
	and d
	ld b, d
	ld bc, $a200
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	ld bc, $0b0b
	ld bc, $a200
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld b, d
	and c
	ld b, d
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld c, h
	and c
	ld c, h
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	ld d, d
	and e
	ld e, h
	nop
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ldd a, [hl]
	and c
	ldd a, [hl]
	ldd a, [hl]
	and d
	ld bc, $a33a
	ld c, h
	nop
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
		ld b, h

.l_79f2:
	and c
	ld b, h
	ld b, h
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld bc, $a34c
	ld b, h
	nop
	inc b
	ld a, d
	nop
	nop
	sbc a, l
	jp nz, .l_4000
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld d, d
	ld c, h
	ld c, b
	and c
	ld b, h
	ld b, d
	and d
	ld b, h
	and h
	ld bc, $2c00
	ld a, d
	nop
	nop
	ld c, e
	ld a, d
	sbc a, l
	jp nz, .l_8000
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld c, h
	ld b, h
	ld d, d
	and e
	ld e, h
	and h
	ld bc, $9d00
	jp [hl]
	ld l, [hl]
	jr nz, .l_79f2
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld c, [hl]

.l_7a5b:
	ld d, d
	ld d, [hl]
	ld bc, $5ca2
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld d, d
	ld c, h
	ld b, h
	ld bc, $01a5
	ld [hl], a
	ld a, d
	nop
	nop
	sub a, [hl]
	ld a, d
	or h
	ld a, d
	sbc a, l
	jp nz, .l_8000
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld c, h
	ld b, h
	ld d, d
	and e
	ld e, h
	and h
	ld bc, $9d00
	jp nz, .l_4000
	and d
	ld c, [hl]
	and c
	ld c, [hl]
	ld d, d
	and d
	ld d, [hl]
	ld c, [hl]
	and e
	ld c, b
	ld c, b
	and d
	ld c, h
	and c
	ld c, h
	ld c, d
	and d
	ld c, h
	ld b, h
	inc [hl]
	ld c, h
	and e
	ld c, h
	and l
	ld bc, $9d00
	jp [hl]
	ld l, [hl]
	jr nz, .l_7a5b
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld c, [hl]
	ld d, d
	and c
	ld d, [hl]
	ld d, [hl]
	and d
	ld d, [hl]
	and d
	ld e, h

.l_7acc:
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld d, d
	ld c, h
	and c
	ld b, h
	ld b, h
	and d
	ld bc, $01a5
	nop
	jp [hl]
	ld a, d
	nop
	nop
	ld [$257b], sp
	ld a, e
	ld c, a
	ld a, e
	sbc a, l
	jp nz, .l_8000
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld c, h
	ld b, h
	ld d, d
	and e
	ld e, h
	and h
	ld bc, $9d00
	or d
	nop
	add a, b
	and d
	ld c, [hl]
	and c
	ld c, [hl]
	ld d, d
	and d
	ld d, [hl]
	ld c, [hl]
	and e
	ld c, b
	ld c, b
	and d
	ld c, h
	and c
	ld c, h
	ld c, d
	and d
	ld c, h
	ld b, h
	inc [hl]
	ld c, h
	and e
	ld c, h
	and l
	ld bc, $e99d
	ld l, [hl]
	jr nz, .l_7acc
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	ld c, [hl]
	ld d, [hl]
	ld e, h
	ld d, [hl]
	ld c, [hl]
	ld b, h
	ld a, $44
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	ld d, d
	ld c, h
	ld b, h
	ld c, h
	ld e, h
	ld bc, $01a2
	and l
	ld bc, $0ba2
	dec bc
	dec bc
	dec bc
	and d
	dec bc
	dec bc
	dec bc
	ld bc, $0ba2
	dec bc
	dec bc
	dec bc
	and d
	dec bc
	dec bc
	dec bc
	ld bc, $01a5
	ld [hl], a
	ld a, e
	adc a, $7b
	nop
	nop
	sub a, [hl]
	ld a, e
	<error>
	ld a, e
	xor b
	ld a, e
	ld [bc], a
	ld a, h
	cp e
	ld a, e
	ld [de], a
	ld a, h
	sbc a, l
	pop de
	nop
	add a, b
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld d, d
	ld c, h
	ld c, b
	ld b, h
	and c
	ld c, h
	ld d, d
	nop
	and d
	ld d, d
	and a
	ld bc, $44a2
	ld b, h
	ld b, h
	ld bc, $a74c
	ld bc, $3aa2
	ldd a, [hl]
	ldd a, [hl]
	ld bc, $a200
	ld e, h
	and a
	ld bc, $4ea2
	ld d, d
	ld d, [hl]
	ld bc, $5ca2
	and a
	ld bc, $44a2
	ld c, b
	ld c, h
	ld bc, $a200
	ld b, $a7
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $06a2
	and a
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $a200
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld b, d
	and c
	ld b, d
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld c, h
	and c
	ld c, h
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld e, h
	ld d, d
	and e
	ld e, h
	nop
	ld bc, $013a
	ldd a, [hl]
	ld bc, $013a
	ldd a, [hl]
	ld bc, $013a
	ldd a, [hl]
	ld bc, $a33a
	inc [hl]
	ld bc, $0148
	ld c, b
	ld bc, $0148
	ld c, b
	ld bc, $0144
	ld b, h
	ld bc, $a34c
	ld b, h
	and d
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	and d

.l_7c20:
	ld bc, $0b0b
	ld bc, $7c2e
	nop
	nop
	ld h, e
	ld a, h
	sub a, a
	ld a, h
	bit 7, h

.l_7c2e:
	sbc a, l
	or e
	nop
	add a, b
	and [hl]
	ld d, d
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ld c, b
	and e
	ld bc, $4ca6
	and c
	ld c, d
	and [hl]
	ld c, h
	and c
	ld c, d
	and [hl]
	ld c, h
	and c
	ld b, d
	and e
	ld bc, $3ea6
	and c
	ld b, d
	and [hl]
	ld b, h
	and c
	ld c, b
	and [hl]
	ld c, h
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ld d, [hl]
	and [hl]
	ld d, d
	and c
	ld l, d
	nop
	sbc a, l
	sub a, e
	nop
	ret nz
	and [hl]
	ld b, d
	and c
	ld b, b
	and [hl]
	ld b, d
	and c
	ld b, b
	and [hl]
	ld b, d
	and c
	ld b, d
	and e
	ld bc, $3aa6
	and c
	jr c, .l_7c20
	ldd a, [hl]
	and c


func_7c7c::
	jr c, .l_7c24
	ldd a, [hl]
	and c
	ldd a, [hl]
	and e
	ld bc, $38a6
	and c
	jr c, .l_7c2e
	ldd a, [hl]
	and c
	ld a, $a6
	ld b, d
	and c
	ld b, h
	and [hl]
	ld c, b
	and c
	ld c, h
	and [hl]
	ld b, d
	and c
	ld b, d
	sbc a, l
	jp [hl]
	ld l, [hl]
	and b
	and [hl]
	ld c, b
	and c
	ld b, [hl]
	and [hl]
	ld c, b
	and c
	ld b, [hl]
	and [hl]
	ld c, b
	and c
	ld d, d
	and e
	ld bc, $44a6
	and c
	ld b, d
	and [hl]
	ld b, h
	and c
	ld b, d
	and [hl]
	ld b, h
	and c
	ld c, h
	and e
	ld bc, $48a6
	and c
	ldd a, [hl]
	and [hl]
	ld a, $a1
	ld b, d
	and [hl]
	ld b, h
	and c
	ld c, b
	and [hl]
	ld c, h
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ldd a, [hl]
	and [hl]
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a3
	ld bc, $0ba6
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a3
	ld bc, $0ba6
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a3
	ld bc, $0ba6
	and c
	ld b, $2e
	ld a, l
	rst 38
	rst 38
	ld bc, $297d
	ld a, l
	dec [hl]
	ld a, l
	ld e, e
	ld a, l
	add a, d
	ld a, l
	ld e, e
	ld a, l
	and h
	ld a, l
	add a, $7d
	rst 38
	rst 38
	inc bc
	ld a, l
	dec sp
	ld a, l

.l_7d13:
	ld l, h
	ld a, l
	sub a, e
	ld a, l
	ld l, h
	ld a, l
	or l
	ld a, l
	rlc a
	ld a, [hl]
	rst 38
	rst 38
	inc de
	ld a, l
	ld a, $7d
	ld b, c
	ld a, l
	rst 38
	rst 38
	inc hl
	ld a, l
	sbc a, l
	ld h, b
	nop
	add a, c
	nop
	sbc a, l
	jr nz, .l_7d31

.l_7d31:
	add a, c
	xor d
	ld bc, $a300
	ld bc, $5450
	ld e, b
	nop
	and l
	ld bc, $a500
	ld bc, $a300
	ld bc, $0106
	ld b, $01
	and d
	ld b, $06
	and e
	ld bc, $a306
	ld bc, $0106
	ld b, $01
	and d
	ld b, $06
	ld bc, $0601
	ld b, $00
	and a
	ld e, d
	and d
	ld e, [hl]
	and a
	ld e, d
	and d
	ld e, b
	and a
	ld e, b
	and d
	ld d, h
	and a
	ld e, b
	and d
	ld d, h
	nop
	sbc a, l
	ret
	ld l, [hl]
	jr nz, .l_7d13
	ld e, d
	ld h, d
	ld l, b
	ld [hl], b
	ld e, d
	ld h, d
	ld l, b
	ld [hl], b
	ld e, d
	ld h, h
	ld h, [hl]
	ld l, h
	ld e, d
	ld h, h
	ld h, [hl]
	ld l, h
	nop
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, b
	and d
	ld c, h
	and a
	ld c, d
	and d
	ld d, b
	nop
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld d, b
	ld d, h
	ld e, b
	ld e, [hl]
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	nop
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, b
	and d
	ld c, h
	and a
	ld c, d
	and d
	ld b, [hl]
	nop
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld d, b
	ld d, h
	ld e, b
	ld e, [hl]
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	nop
	and a
	ld c, d
	and d
	ld c, h
	and a
	ld c, d
	and d
	ld b, [hl]
	and a
	ld b, [hl]
	and d
	ld b, h
	and a
	ld b, [hl]
	and d
	ld c, d
	and a
	ld c, h
	and d
	ld d, b
	and a
	ld c, h
	and d
	ld c, d
	and a
	ld c, d
	and d
	ld b, [hl]
	and a
	ld c, d
	and d
	ld c, h
	and a
	ld d, b
	and d
	ld c, [hl]
	and a
	ld d, b
	and d
	ld d, d
	and a
	ld e, b
	and d
	ld d, h
	and a
	ld e, d
	and d
	ld d, h
	and a
	ld d, d
	and d
	ld d, b
	and a
	ld c, h
	and d
	ld c, d
	and d
	ld b, d
	jr c, .l_7e3e
	ld c, d
	and e
	ld b, d
	ld bc, $4a00
	ld d, d
	ld e, b
	ld e, [hl]
	ld c, d
	ld e, b
	ld e, [hl]
	ld h, d
	ld d, h
	ld h, d
	ld l, b
	ld l, h
	ld d, h
	ld h, d
	ld l, b
	ld l, h
	ld b, [hl]
	ld c, h

.l_7e19:
	ld d, h
	ld e, [hl]
	ld b, [hl]
	ld c, h
	ld d, h
	ld e, d
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	ld d, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld c, d
	ld d, b
	ld e, b
	ld e, [hl]
	ld c, d
	ld e, b
	ld e, [hl]
	ld h, d
	ld c, [hl]
	ld d, h
	ld e, d
	ld h, d
	ld c, [hl]
	ld d, h
	ld e, d
	ld h, [hl]
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	ld d, b
	ld e, [hl]
	ld h, h

.l_7e3e:
	ld l, b
	xor b
	ld e, d
	and e
	ld bc, $4e00
	ld a, [hl]
	nop
	nop
	ld e, [hl]
	ld a, [hl]
	ld l, l
	ld a, [hl]
	ld a, l
	ld a, [hl]
	sbc a, l
	or c
	nop
	add a, b
	and a
	ld bc, $5ea1
	ld e, [hl]
	and [hl]
	ld l, b
	and c
	ld e, [hl]
	and h
	ld l, b
	nop
	sbc a, l
	sub a, c
	nop
	add a, b
	and a
	ld bc, $54a1
	ld d, h
	and [hl]
	ld e, [hl]
	and c
	ld e, b
	and h
	ld e, [hl]
	sbc a, l
	jp [hl]
	ld l, [hl]
	jr nz, .l_7e19
	ld bc, $4ea1
	ld c, [hl]
	and [hl]
	ld e, b
	and c
	ld d, b
	and e
	ld e, b
	ld bc, $01a7
	and c
	ld b, $06
	and [hl]
	dec bc
	and c
	ld b, $a0
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	and e
	ld bc, $7ebb
	jr z, .l_7f14
	cp e
	ld a, [hl]
	ld [hl], e
	ld a, a
	rst 38
	rst 38
	sub a, c
	ld a, [hl]
	push hl
	ld a, [hl]
	ld c, a
	ld a, a
	push hl

.l_7ea2:
	ld a, [hl]
	sub a, [hl]
	ld a, a
	rst 38
	rst 38
	sbc a, l
	ld a, [hl]
	ei
	ld a, [hl]
	ld h, c
	ld a, a
	ei
	ld a, [hl]
	xor [hl]
	ld a, a
	rst 38
	rst 38
	xor c
	ld a, [hl]
	ld de, $ff7f
	rst 38
	or l
	ld a, [hl]
	sbc a, l
	add a, d
	nop
	add a, b
	and d
	ld d, h
	and c
	ld d, h
	ld d, h
	ld d, h
	ld c, d
	ld b, [hl]
	ld c, d
	and d
	ld d, h
	and c
	ld d, h
	ld d, h
	ld d, h
	ld e, b
	ld e, h
	ld e, b
	and d
	ld d, h
	and c
	ld d, h
	ld d, h
	ld e, b
	ld d, h
	ld d, d
	ld d, h
	and c
	ld e, b
	ld e, h
	ld e, b
	ld e, h
	and d
	ld e, b
	and c
	ld d, [hl]
	ld e, b
	nop
	sbc a, l
	ld h, d
	nop
	add a, b
	and d
	ld bc, $0144
	ld b, b
	ld bc, $0144
	ld b, [hl]
	ld bc, $0144
	ld b, h
	ld bc, $0140
	ld b, b
	nop
	sbc a, l
	jp [hl]
	ld l, [hl]
	jr nz, .l_7ea2
	ld d, h
	ld d, h
	ld c, d
	ld d, d
	ld d, h
	ld d, h
	ld c, d
	ld e, b
	ld d, h
	ld d, h
	ld d, d
	ld d, h
	ld c, [hl]
	ld d, h
	ld c, d
	ld d, d
	nop
	and d
	ld b, $0b

.l_7f14:
	ld b, $0b
	ld b, $0b
	ld b, $0b
	ld b, $0b
	ld b, $0b
	ld b, $a1
	dec bc
	dec bc
	ld b, $a2
	dec bc
	and c
	ld b, $00
	and d
	ld e, [hl]
	and c
	ld e, [hl]
	ld e, [hl]
	ld e, [hl]
	ld d, h
	ld d, b
	ld d, h
	and d
	ld e, [hl]
	and c
	ld e, [hl]
	ld e, [hl]
	ld e, [hl]
	ld h, d
	ld h, [hl]
	ld h, d
	and d
	ld e, [hl]
	and c
	ld e, [hl]
	ld e, h
	and d
	ld e, b
	and c
	ld e, b
	ld d, h
	and c
	ld d, d
	ld d, h
	ld d, d
	ld d, h
	and d
	ld d, d
	and c
	ld c, [hl]
	ld d, d
	nop
	and d
	ld bc, $0146
	ld c, d
	ld bc, $0146
	ld c, d
	ld bc, $0146
	ld b, [hl]
	ld bc, $0146
	ld b, [hl]
	nop
	and d
	ld b, [hl]
	ld d, h
	ld d, h
	ld d, h
	ld b, [hl]
	ld d, h
	ld d, h
	ld d, h
	ld b, [hl]
	ld d, h
	ld d, d
	ld e, b
	ld b, h
	ld d, d
	ld c, d
	ld e, b
	nop
	and d
	ld h, d
	and c
	ld h, d
	ld h, d
	ld h, d
	ld e, [hl]
	ld e, d
	ld e, [hl]
	and d
	ld h, d
	and c
	ld h, d
	ld h, d
	ld h, d
	ld e, [hl]
	ld e, d
	ld e, [hl]
	and d
	ld h, d
	and c
	ld c, d
	ld c, [hl]
	and d
	ld d, d
	and c
	ld c, d
	ld e, h
	and e
	ld e, b
	and c
	ld d, h
	and [hl]
	ld l, h
	nop
	and d
	ld bc, $014a
	ld c, d
	ld bc, $014a
	ld c, d
	ld bc, $46a1
	ld b, [hl]
	and d
	ld b, [hl]
	and c
	ld b, [hl]
	ld b, [hl]
	and e
	ld b, [hl]
	and d
	ld b, h
	ld bc, $a200
	ld b, d
	ld e, d
	ld d, b
	ld e, d
	ld b, d
	ld e, d
	ld d, b
	ld e, d
	ld c, d
	and c
	ld d, d
	ld d, d
	and d
	ld d, d
	and c
	ld d, d
	ld d, d
	and e
	ld d, d
	and d
	ld d, h
	ld bc, $0000
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

.l_7fef:
	nop


func_7ff0::
	jp .l_64d3


func_7ff3::
	jp $69a5
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop