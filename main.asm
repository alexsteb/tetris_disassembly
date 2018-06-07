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
	jp .l_017e
SECTION "hblank", ROM0 [$48]
	jp .l_26be
SECTION "timer",  ROM0 [$50]
	jp .l_26be
SECTION "serial", ROM0 [$58]
	jp .l_005b

.l_005B:
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


func_006B::
	ldh a, [$ff00 + $cd]
	rst 28
	ld a, b
	nop
	sbc a, a
	nop
	and h
	nop
	cp d
	nop
	ld [$f027], a
	pop hl
	cp $07
	jr z, $08
	cp $06
	ret z
	ld a, $06
	ldh [$ff00 + $e1], a
	ret
	ldh a, [$ff00 + $01]
	cp $55
	jr nz, $08
	ld a, $29
	ldh [$ff00 + $cb], a
	ld a, $01
	jr $08
	cp $29
	ret nz
	ld a, $55
	ldh [$ff00 + $cb], a
	xor a
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
	ldh a, [$ff00 + $41]
	and $03
	jr nz, $fa
	ld b, [hl]
	ldh a, [$ff00 + $41]
	and $03
	jr nz, $fa
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

.l_017E:
	push af
	push bc
	push de
	push hl
	ldh a, [$ff00 + $ce]
	and a
	jr z, $12
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, $0c
	xor a
	ldh [$ff00 + $ce], a
	ldh a, [$ff00 + $cf]
	ldh [$ff00 + $01], a
	ld hl, $ff02
	ld [hl], $81
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
	jr z, $1a
	ldh a, [$ff00 + $98]
	cp $03
	jr nz, $14
	ld hl, $986d
	call func_243b
	ld a, $01
	ldh [$ff00 + $e0], a
	ld hl, $9c6d
	call func_243b
	xor a
	ld [$c0ce], a
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

.l_020C:
	xor a
	ld hl, $dfff
	ld c, $10
	ld b, $00
	ldd [hl], a
	dec b
	jr nz, $fc
	dec c
	jr nz, $f9

.l_021B:
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
	ldh a, [$ff00 + $44]
	cp $94
	jr nz, $fa
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
	ldd [hl], a
	dec b
	jr nz, $fc
	ld hl, $cfff
	ld c, $10
	ld b, $00
	ldd [hl], a
	dec b
	jr nz, $fc
	dec c
	jr nz, $f9
	ld hl, $9fff
	ld c, $20
	xor a
	ld b, $00
	ldd [hl], a
	dec b
	jr nz, $fc
	dec c
	jr nz, $f9
	ld hl, $feff
	ld b, $00
	ldd [hl], a
	dec b
	jr nz, $fc
	ld hl, $fffe
	ld b, $80
	ldd [hl], a
	dec b
	jr nz, $fc
	ld c, $b6
	ld b, $0c
	ld hl, $2a7f
	ldi a, [hl]
	ldh [c], a
	inc c
	dec b
	jr nz, $fa
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

.l_02C4:
	call func_29a6
	call func_02f8
	call func_7ff0
	ldh a, [$ff00 + $80]
	and $0f
	cp $0f
	jp z, .l_021b
	ld hl, $ffa6
	ld b, $02
	ld a, [hl]
	and a
	jr z, $01
	dec [hl]
	inc l
	dec b
	jr nz, $f7
	ldh a, [$ff00 + $c5]
	and a
	jr z, $04
	ld a, $09
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $85]
	and a
	jr z, $fb
	xor a
	ldh [$ff00 + $85], a
	jp .l_02c4


func_02F8::
	ldh a, [$ff00 + $e1]
	rst 28
	adc a, $1b
	ldh [c], a
	inc e
	ld b, h
	ld [de], a
