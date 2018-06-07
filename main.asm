; rst vectors
SECTION "rst 00", ROM0 [$00]
  jp .l_020c
  
SECTION "rst 08", ROM0 [$08]
	jp .l_020c
  
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
	jp .l_020c
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

.l_020c:
	xor a
	ld hl, $dfff
	ld c, $10
	ld b, $00

.l_0214:
	ldd [hl], a
	dec b
	jr nz, .l_0214
	dec c
	jr nz, .l_0214

.l_021b:
	ld a, $01
	di
	ldh [$ff00 + $0f], a
	ldh [$ff00 + $ff], a
	xor a
	ldh [$ff00 + $42], a
	ldh [$ff00 + $43], a
	ldh [$ff00 + $a4], a
	ldh [$ff00 + $41], a
	ldh [$ff00 + $01], a
	ldh [$ff00 + $02], a
	ld a, $80
	ldh [$ff00 + $40], a

.l_0233:
	ldh a, [$ff00 + $44]
	cp $94
	jr nz, .l_0233
	ld a, $03
	ldh [$ff00 + $40], a
	ld a, $e4
	ldh [$ff00 + $47], a
	ldh [$ff00 + $48], a
	ld a, $c4
	ldh [$ff00 + $49], a
	ld hl, $ff26
	ld a, $80
	ldd [hl], a
	ld a, $ff
	ldd [hl], a
	ld [hl], $77
	ld a, $01
	ld [$2000], a
	ld sp, $cfff
	xor a
	ld hl, $dfff
	ld b, $00

.l_0260:
	ldd [hl], a
	dec b
	jr nz, .l_0260
	ld hl, $cfff
	ld c, $10
	ld b, $00

.l_026b:
	ldd [hl], a
	dec b
	jr nz, .l_026b
	dec c
	jr nz, .l_026b
	ld hl, $9fff
	ld c, $20
	xor a
	ld b, $00

.l_027a:
	ldd [hl], a
	dec b
	jr nz, .l_027a
	dec c
	jr nz, .l_027a
	ld hl, $feff
	ld b, $00

.l_0286:
	ldd [hl], a
	dec b
	jr nz, .l_0286
	ld hl, $fffe
	ld b, $80

.l_028f:
	ldd [hl], a
	dec b
	jr nz, .l_028f
	ld c, $b6
	ld b, $0c
	ld hl, $2a7f

.l_029a:
	ldi a, [hl]
	ldh [c], a
	inc c
	dec b
	jr nz, .l_029a
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
	jp z, .l_021b
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
