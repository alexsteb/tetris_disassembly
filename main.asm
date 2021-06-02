INCLUDE "constants.asm"
INCLUDE "palettes.asm"

; rst vectors
SECTION "rst 00", ROM0 [$00]
	jp Init
  
SECTION "rst 08", ROM0 [$08]
	jp Init
	db $FF, $FF, $FF, $FF, $FF
SECTION "rst 10", ROM0 [$10]
	rst $38
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF
SECTION "rst 18", ROM0 [$18]
	rst $38
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF
SECTION "rst 20", ROM0 [$20]
	rst $38
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF
SECTION "rst 28", ROM0 [$28]

; Helper function:
; * doubles the current game status (register A)
; * finds an address in a list located after caller's address (depending on game status)
; * jumps to that address

	add a, a	; double GAME_STATUS
	pop hl		
	ld e, a
	ld d, $00
	add hl, de	; add 2 * GAME_STATUS to caller address
	ld e, [hl]	; get 2-byte-address from that location
	inc hl
	ld d, [hl]
	push de
	pop hl
	jp hl		; jump to that address
	db $FF, $FF, $FF, $FF
SECTION "rst 38", ROM0 [$38]
	rst $38
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF
; Hardware interrupts
SECTION "vblank", ROM0 [$40]
	jp VBlank
	db $FF, $FF, $FF, $FF, $FF
SECTION "hblank", ROM0 [$48]
	jp HBlank_Timer
	db $FF, $FF, $FF, $FF, $FF
SECTION "timer",  ROM0 [$50]
	jp HBlank_Timer
	db $FF, $FF, $FF, $FF, $FF
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

; Small switch statement: 
; (rst 28 jumps to following address, depending on current $ff00 + $cd)
func_006b:
	ldh a, [$ff00 + $cd]
	rst $28
	
	db $78, $00	; => 0078
	db $9f, $00	; => 009f
	db $a4, $00	; => 00a4
	db $ba, $00	; => 00ba
	db $ea, $27	; => 27ea
	
l_0078:
	ldh a, [rGAME_STATUS]
	cp MENU_TITLE
	jr z, l_0086
	
	cp MENU_TITLE_INIT
	ret z
	
	ld a, MENU_TITLE_INIT
	ldh [rGAME_STATUS], a
	ret

l_0086:
	ldh a, [rSB]
	cp $55
	jr nz, l_0094
	ld a, $29
	ldh [$ff00 + $cb], a
	ld a, $01
	jr l_009c
l_0094:
	cp $29
	ret nz
	ld a, $55
	ldh [$ff00 + $cb], a
	xor a
l_009c:
	ldh [rSC], a
	ret

func_009f:
	ldh a, [rSB]
	ldh [$ff00 + $d0], a
	ret
	
func_00a4:
	ldh a, [rSB]
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $cb]
	cp $29
	ret z
	ldh a, [rSB_DATA]
	ldh [rSB], a
	ld a, $ff
	ldh [rSB_DATA], a
	ld a, $80
	ldh [rSC], a
	ret

func_00ba:
	ldh a, [rSB]
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $cb]
	cp $29
	ret z
	ldh a, [rSB_DATA]
	ldh [rSB], a
	ei
	call WASTE_TIME
	ld a, $80
	ldh [rSC], a
	ret
	
func_00d0:
	ldh a, [$ff00 + $cd]
	cp $02
	ret nz
	xor a
	ldh [rIF], a		; Clear all interrupt flags
	ei
	ret

	db $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	
SECTION "Entry", ROM0 [$100]
  nop
	jp Start
  
SECTION "Header", ROM0 [$104]
	db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d,
	db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99,
	db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e, 
	db "TETRIS", $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00		;dmg - classic gameboy
	db $00, $00	;new license
	db $00		;sgb flag: not sgb compatible
	db $00		;cart type: rom
	db $00		;rom size: 32 kb
	db $00		;ram size: 0 b
	db $00		;destination code: japanese
	db $01		;old license: not sgb compatible
	db $01		;mask rom version number
	db $0a		;header check [ok]
	db $16, $bf		;global check [ok]

SECTION "Main", ROM0 [$150]
Start:
	jp Init
	call func_29e3

l_0156:
	ldh a, [rLCDC_STAT]
	and $03
	jr nz, l_0156
	ld b, [hl]
l_015d:
	ldh a, [$ff00 + $41]
	and $03
	jr nz, l_015d
	ld a, [hl]
	and b
	ret
	
func_0166:
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

; The VBlank interrupt handler, must occur once somewhen during the game-loop
VBlank::	
	push af				; Store registers
	push bc
	push de
	push hl
	
	ldh a, [rREQUEST_SERIAL_TRANSFER]	; Transfer data only if requested
	and a
	jr z, .skip_serial_connection
	
	ldh a, [$ff00 + $cb]			; ?
	cp $29
	jr nz, .skip_serial_connection
	
	xor a
	ldh [rREQUEST_SERIAL_TRANSFER], a	; Clear request
	ldh a, [rSB_DATA]			
	ldh [rSB], a				; Send data to link cable
	ld hl, rSC
	ld [hl], $81				; Use internal clock (= this GB is the master)
						; and request a data transfer (of rSB) to the other GB

.skip_serial_connection:
	call clear_row_animation
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
	call $FFB6    ; OAM routine?
	call func_18ca
	ld a, [$c0ce]
	and a
	jr z, l_01fb
	ldh a, [rBLOCK_STATUS]
	cp $03
	jr nz, l_01fb
	ld hl, $986d
	call func_243b
	ld a, $01
	ldh [$ff00 + $e0], a
	ld hl, $9c6d
	call func_243b
	xor a
	ld [$c0ce], a

l_01fb:
	ld hl, $ffe2
	inc [hl]
	xor a
	ldh [$ff00 + $43], a
	ldh [$ff00 + $42], a
	inc a
	ldh [rVBLANK_DONE], a
	pop hl
	pop de
	pop bc
	pop af
	reti

Init:
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
	
Screen_Setup: ; $21B

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
	ldh [rUNKNOWN1], a
	ldh [rLCDC_STAT], a
	ldh [rSB], a
	ldh [rSC], a
	ld a, rLCDC_START
	ldh [rLCDC], a

.loop_1:
	ldh a, [rLY]
	cp SCREEN_HEIGHT + 4
	jr nz, .loop_1
	
	ld a, $03
	ldh [rLCDC], a
	
	ld a, PALETTE_1
	ldh [rBGP], a
	ldh [rOBP0], a
	
	ld a, PALETTE_2
	ldh [rOBP1], a
	ld hl, rNR52
	
	ld a, SOUND_ON
	ldd [hl], a	; rNR51
	
	ld a, USE_ALL_CHANNELS
	ldd [hl], a	; rNR50
	ld [hl], MASTER_VOLUME_MAX
	
	ld a, $01
	ld [rMBC], a
	ld sp, SP_INIT

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
	
; Copy DMA Transfer routine into HRAM
	ld c, $b6	; Target location in HRAM
	ld b, $0c	; Routine length
	ld hl, $2a7f	; Source location in ROM
.loop_7:
	ldi a, [hl]
	ldh [c], a
	inc c
	dec b
	jr nz, .loop_7
	
	call Flush_BG1
	call Sound_Init

rINTERRUPT_SERIAL EQU %00001001
; * VBlank interrupt enabled
; * Serial interrupt enabled
; * everything else disabled

	ld a, rINTERRUPT_SERIAL
	ldh [rIE], a		; enable VBlank & Serial Interrupt

; Set up a few game variables
	ld a, GAME_TYPE_A
	ldh [rGAME_TYPE], a
	
	ld a, MUSIC_TYPE_A
	ldh [rMUSIC_TYPE], a
	
	ld a, MENU_COPYRIGHT_INIT
	ldh [rGAME_STATUS], a
	
	ld a, LCDC_ON
	ldh [rLCDC], a
	
	ei			; enable interrupts (VBlank interrupt handler can occur now)
	
	xor a
	ldh [rIF], a		; clear all interrupt flags
	ldh [rWY], a		; Set Window X & Y Position to initial
	ldh [rWX], a
	ldh [rTMA], a		; Clear the timer modulo

.Main_Loop:
	call Read_Joypad
	call State_Machine
	call func_7ff0
	
	ldh a, [rBUTTON_DOWN]
	and $0f
	cp $0f			
	jp z, Screen_Setup	; if all directional keys are pressed, reset game
	
; Countdown both $ffa6 and $ffa7 by 1, if >0
	ld hl, rCOUNTDOWN
	ld b, $02
.loop_8:
	ld a, [hl]
	and a
	jr z, .skip_1
	dec [hl]		; if countdown is > 0, count one down
.skip_1:
	inc l
	dec b
	jr nz, .loop_8

	ldh a, [rPLAYERS]
	and a
	jr z, .wait_for_vblank
	ld a, rINTERRUPT_SERIAL
	ldh [rIE], a		; If in 2-player mode, enable serial interrupt
.wait_for_vblank:
	ldh a, [rVBLANK_DONE]
	and a
	jr z, .wait_for_vblank	; Loop until VBlank handler has finished executing
	xor a
	ldh [rVBLANK_DONE], a
	
	jp .Main_Loop


State_Machine::
	ldh a, [rGAME_STATUS]
	rst $28

; Big switch statement: 
; (rst $28 jumps to following address, depending on current GAME_STATUS)
	db $ce, $1b	; MENU_IN_GAME 		=> 1bce
	db $e2, $1c	; MENU_GAME_OVER_INIT	=> 1ce2
	db $44, $12	; MENU_ROCKET_1D	=> 1244
	db $7b, $12	; MENU_ROCKET_1E	=> 127b
	db $06, $1d	; MENU_GAME_OVER 	=> 1d06
	db $26, $1d	; MENU_TYPE_B_WON	=> 1d26
	db $ae, $03	; MENU_TITLE_INIT 	=> 03ae
	db $79, $04	; MENU_TITLE 		=> 0479
	db $44, $14	; MENU_SELECT_TYPE_INIT => 1444
	db $8c, $14	; (unused)
	db $07, $1a	; MENU_IN_GAME_INIT 	=> 1a07
	db $c0, $1d	; MENU_SCORE_B		=> 1dc0
	db $16, $1f	; (unknown) 		=> 1f16
	db $1f, $1f	; MENU_LOST_ANIM	=> 1f1f
	db $25, $15	; MENU_SELECT_TYPE	=> 1525
	db $b0, $14	; MENU_SELECT_MUSIC	=> 14b0
	db $7b, $15	; MENU_LEVEL_A_INIT	=> 157b
	db $bf, $15	; MENU_LEVEL_A		=> 15bf
	db $29, $16	; MENU_LEVEL_B_INIT	=> 1629
	db $7a, $16	; MENU_LEVEL_B		=> 167a
	db $eb, $16	; MENU_HIGH_B		=> 16eb
	db $13, $19	; MENU_HISCORE		=> 1913
	db $77, $06	; MENU_VS_INIT		=> 0677
	db $2c, $07	; MENU_VS_MODE		=> 072c
	db $25, $08	; MENU_VS_GAME_INIT	=> 0825
	db $e4, $08	; MENU_VS_GAME		=> 08e4
	db $31, $0b	; (unknown)		=> 0b31
	db $eb, $0c	; (unknown)		=> 0ceb
	db $d2, $0a	; (unknown)		=> 0ad2
	db $32, $0d	; MENU_LUIGI_WON_INIT	=> 0d32
	db $23, $0e	; MENU_LUIGI_LOST_INIT	=> 0e23
	db $12, $11	; (unknown)		=> 1112
	db $99, $0d	; MENU_LUIGI_WON	=> 0d99
	db $8a, $0e	; MENU_LUIGI_LOST	=> 0e8a
	db $ce, $1d	; MENU_CELEBRATE	=> 1dce
	db $41, $1e	; (unknown)		=> 1e41
	db $69, $03	; MENU_COPYRIGHT_INIT	=> 0369
	db $93, $03	; MENU_COPYRIGHT_1	=> 0393
	db $67, $11	; MENU_ROCKET_1_INIT	=> 1167
	db $e6, $11	; MENU_ROCKET_1A	=> 11e6
	db $fc, $11	; MENU_ROCKET_1B	=> 11fc
	db $1c, $12	; MENU_ROCKET_1C	=> 121c
	db $c7, $05	; (unknown)		=> 05c7
	db $f7, $05	; (unknown)		=> 05f7
	db $b3, $12	; MENU_ROCKET_1F	=> 12b3
	db $05, $13	; MENU_ROCKET_1G	=> 1305
	db $24, $13	; MENU_ROCKET_2A	=> 1324
	db $51, $13	; MENU_ROCKET_2B	=> 1351
	db $67, $13	; MENU_ROCKET_2C	=> 1367
	db $7e, $13	; MENU_ROCKET_2D	=> 137e
	db $b5, $13	; MENU_ROCKET_2E	=> 13b5
	db $e5, $13	; MENU_ROCKET_2F	=> 13e5
	db $1b, $13	; MENU_ROCKET_2_INIT	=> 131b
	db $a0, $03	; MENU_COPYRIGHT_2	=> 03a0
	db $ea, $27	; (unknown)		=> 27ea
 
 
lbl_MENU_COPYRIGHT_INIT::
	call WAIT_FOR_VBLANK
	call COPY_TITLE_TILES
	ld de, $4a07		; Starting address of copyright screen tile map in ROM
	call COPY_TILEMAP
	call CLEAR_OAM_DATA
	
	ld hl, $c300		; Copy some values into $c300+. Seems to be serial related
	ld de, $6450
.loop_12:
	ld a, [de]
	ldi [hl], a
	inc de
	ld a, h
	cp $c4
	jr nz, .loop_12
	
	ld a, LCDC_STANDARD		
	ldh [rLCDC], a
	ld a, $fa		; ~ 4 seconds
	ldh [rCOUNTDOWN], a
	ld a, MENU_COPYRIGHT_1
	ldh [rGAME_STATUS], a
	ret

; Wait until previous countdown is done, set a new one and change the game status to MENU_COPYRIGHT_2
lbl_MENU_COPYRIGHT_1::
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld a, $fa		; ~ 4 seconds
	ldh [rCOUNTDOWN], a
	ld a, MENU_COPYRIGHT_2
	ld [rGAME_STATUS], a
	ret
	
	
; Wait until either previous countdown (4 secs) is done, or anz button was hit, then change game status to MENU_TITLE_INIT
lbl_MENU_COPYRIGHT_2::
	ldh a, [rBUTTON_HIT]
	and a
	jr nz, .skip_2
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
.skip_2:
	ld a, MENU_TITLE_INIT
	ld [rGAME_STATUS], a
	ret
	
lbl_MENU_TITLE_INIT::
	call WAIT_FOR_VBLANK
	xor a
	ldh [rUNUSED], a
	ldh [rBLOCK_STATUS], a
	ldh [rCLEAR_PROGRESS], a
	ldh [$ff00 + $9b], a
	ldh [$ff00 + $fb], a
	ldh [rLINES_CLEARED2], a
	ldh [rROW_UPDATE], a
	ldh [$ff00 + $c7], a
	call func_2293
	call func_2651
	call COPY_TITLE_TILES
	ld hl, $c800
l_03ce:
	ld a, $2f
	ldi [hl], a
	ld a, h
	cp $cc
	jr nz, l_03ce
	ld hl, $c801
	call func_26a9
	ld hl, $c80c
	call func_26a9
	ld hl, $ca41
	ld b, $0c
	ld a, $8e
l_03e9:
	ldi [hl], a
	dec b
	jr nz, l_03e9
	ld de, $4b6f
	call COPY_TILEMAP
	call CLEAR_OAM_DATA
	ld hl, $c000		; Address of OAM data
	ld [hl], $80		; Little arrow Y location
	inc l
	ld [hl], $10		; Little arrow X location
	inc l
	ld [hl], $58		; Little arrow tile address
	ld a, $03
	ld [$dfe8], a
	
	ld a, LCDC_STANDARD
	ldh [rLCDC], a
	
	ld a, MENU_TITLE
	ldh [rGAME_STATUS], a
	
	ld a, $7d		; ~ 2 seconds
	ldh [rCOUNTDOWN], a
	
	ld a, $04
	ldh [rMUSIC_COUNTDOWN], a
	
	ldh a, [rDEMO_GAME]
	and a
	ret nz
	
	ld a, $13
	ldh [rMUSIC_COUNTDOWN], a
	ret

PLAY_DEMO_GAME:
	ld a, GAME_TYPE_A
	ldh [rGAME_TYPE], a
	
	ld a, $09
	ldh [rLEVEL_A], a		; set to level 9
	
	xor a
	ldh [rPLAYERS], a		; 1 player mode
	ldh [rDEMO_STATUS], a
	ldh [rDEMO_BUTTON_HIT], a
	ldh [rDEMO_ACTION_COUNTDOWN], a
	
	ld a, $62			; $62b0 = start address of first demo storyboard
	ldh [rDEMO_STORYBOARD_1], a
	ld a, $b0
	ldh [rDEMO_STORYBOARD_2], a
	
	ldh a, [rDEMO_GAME]
	cp $02
	ld a, $02
	jr nz, .set_up_first_demo_game	; jump if NOT first demo game was played just now
					; (if rDEMO_GAME = 2, then first demo was running. If not, jump.)
; set up second demo game:
	ld a, GAME_TYPE_B
	ldh [rGAME_TYPE], a
	
	ld a, $09
	ldh [rLEVEL_B], a		; set to level 9
	
	ld a, $02
	ldh [rINITIAL_HEIGHT], a
	
	ld a, $63			; $63b0 = start address of second demo storyboard
	ldh [rDEMO_STORYBOARD_1], a
	ld a, $b0
	ldh [rDEMO_STORYBOARD_2], a
	
	ld a, $11
	ldh [rDEMO_STATUS], a
	ld a, $01

.set_up_first_demo_game:
	ldh [rDEMO_GAME], a
	
	ld a, MENU_IN_GAME_INIT
	ldh [rGAME_STATUS], a		; start a normal in-game (called routines are mostly the same)
	
	call WAIT_FOR_VBLANK
	call COPY_IN_GAME_TILES
	
	ld de, $4cd7			; start of tile map for game select screen
	call COPY_TILEMAP		; copy that tile map to VRAM (useless!)
	call CLEAR_OAM_DATA
	
	ld a, LCDC_STANDARD
	ldh [rLCDC], a
	ret
	
	
func_0474: 	; not used function
	ld a, $ff
	ldh [rUNUSED], a
	ret
	
	
lbl_MENU_TITLE::	
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, .skip_still_no_demo
	ld hl, rMUSIC_COUNTDOWN
	dec [hl]
	jr z, PLAY_DEMO_GAME
	
	ld a, $7d		; ~ 2 seconds
	ldh [rCOUNTDOWN], a
	
.skip_still_no_demo:
	call WASTE_TIME
	
	ld a, $55		; Something Serial Data related
	ldh [rSB], a
	ld a, $80
	ldh [rSC], a
	ldh a, [$ff00 + $cc]
	and a
	jr z, .skip_title_serial_check
	
	ldh a, [$ff00 + $cb]
	and a
	jr nz, l_04d7
	
	xor a
	ldh [$ff00 + $cc], a
	jr l_0509
	
.skip_title_serial_check:
	ldh a, [rBUTTON_HIT]
	ld b, a
	
	ldh a, [rPLAYERS]
	
	bit BTN_SELECT, b
	jr nz, MENU_TITLE_SELECT_BTN
	
	bit BTN_RIGHT, b
	jr nz, MENU_TITLE_RIGHT_BTN
	
	bit BTN_LEFT, b
	jr nz, MENU_TITLE_LEFT_BTN
	
	bit BTN_START, b
	ret z			; Return if no relevant button was pressed
	
	and a
	ld a, $08
	jr z, first_player_selected	; jump if 1 player selected
	
	ld a, b
	cp $08
	ret nz
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_04d7
	ld a, $29
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a
l_04cd:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_04cd
	ldh a, [$ff00 + $cb]
	and a
	jr z, l_0509
l_04d7:
	ld a, $2a
l_04d9:
	ldh [rGAME_STATUS], a
	xor a
	ldh [rCOUNTDOWN], a
	ldh [rLEVEL_A], a
	ldh [rLEVEL_B], a
	ldh [rINITIAL_HEIGHT], a
	ldh [rDEMO_GAME], a
	ret


first_player_selected:
	push af
	ldh a, [rBUTTON_DOWN]
	bit BTN_DOWN, a
	jr z, .skip_hard_mode	; set hard mode only if (Start + Down) are pressed.
	ldh [rHARD_MODE], a
.skip_hard_mode:
	pop af
	jr l_04d9

MENU_TITLE_SELECT_BTN:
	xor $01		; toggles rPLAYERS value (i.e. 0 -> 1 and 1 -> 0)
l_04f5:
	ldh [rPLAYERS], a
	
	and a
	ld a, $10
	jr z, .move_arrow_left
	ld a, $60		; move arrow right - left of "2PLAYER" text
.move_arrow_left:
	ld [$c001], a		; X location of first OAM data entry (= title menu arrow)
	ret

MENU_TITLE_RIGHT_BTN:
	and a
	ret nz		; return if rPLAYERS = 1 (i.e. 2 players)
	xor a
	jr MENU_TITLE_SELECT_BTN

MENU_TITLE_LEFT_BTN:
	and a
	ret z		; return if rPLAYERS = 0 (i.e. 1 player)
l_0509:
	xor a
	jr l_04f5


CHECK_DEMO_GAME_FINISHED::
	ldh a, [rDEMO_GAME]
	and a
	ret z			; return if NOT in demo mode
	
	call WASTE_TIME
	
	xor a				; empty serial connection byte
	ldh [rSB], a
	ld a, $80			; turn on serial connection and act as slave (allow receiving)
	ldh [rSC], a			
	
	ldh a, [rBUTTON_HIT]
	bit BTN_START, a
	jr z, .dont_cancel_demo_game	; jump if Start button not pressed
					; Start button pressed:
	ld a, $33			; load byte $33 for starting a serial connection
	ldh [rSB], a
	ld a, $81			; turn on serial connection and act as master (try sending)
	ldh [rSC], a			 
	
	ld a, MENU_TITLE_INIT		; quit demo game and return to main menu
	ldh [rGAME_STATUS], a
	ret

.dont_cancel_demo_game:
	ld hl, rDEMO_STATUS
	ldh a, [rDEMO_GAME]
	cp $02				; if is currently running the first demo game, ...
	
	ld b, $10
	jr z, .skip_3
	
	ld b, $1d
.skip_3:				; ... then set b to $10, otherwise set b to $1d.
	ld a, [hl]			
	cp b				
	ret nz				; if rDEMO_STATUS not equal b then keep going, ...
	
	ld a, MENU_TITLE_INIT		; ... otherwise return to main menu.
	ldh [rGAME_STATUS], a		; (rDEMO_STATUS increases with each block, game 1 goes from $03 to $09, game 2 from $14 to $1c)
	ret


; This function reads from the storyboard a button configuration and a frame number, how long to hold the buttons (or none)
; Actual button pressed are stored and replaced by these simulated presses.
SIMULATE_BUTTON_PRESSES::
	ldh a, [rDEMO_GAME]
	and a
	ret z			; return if NOT in demo mode
	
	ldh a, [rUNUSED]
	cp $ff
	ret z			; always false
	
	ldh a, [rDEMO_ACTION_COUNTDOWN]
	and a
	jr z, .retrieve_next_action	; jump if countdown reached zero
	
	dec a
	ldh [rDEMO_ACTION_COUNTDOWN], a ; countdown by 1
	jr .clear_real_button_press

.retrieve_next_action:
	ldh a, [rDEMO_STORYBOARD_1]
	ld h, a
	ldh a, [rDEMO_STORYBOARD_2]
	ld l, a				; load the current storyboard address into hl
	ldi a, [hl]			; get first value at address -> supposed button press
	
	ld b, a
	ldh a, [rDEMO_BUTTON_HIT]
	xor b
	and b
	ldh [rBUTTON_HIT], a		; set (actual) button hit to the new button presses.
					; if any button is pressed twice in a row, turn it off now.
	ld a, b
	ldh [rDEMO_BUTTON_HIT], a	; (also save it at rDEMO_BUTTON_HIT)
	
	ldi a, [hl]			; load the button press duration from storyboard
	ldh [rDEMO_ACTION_COUNTDOWN], a
	
	ld a, h
	ldh [rDEMO_STORYBOARD_1], a
	ld a, l
	ldh [rDEMO_STORYBOARD_2], a	; put the next storyboard address into rDEMO_STORYBOARD_n
	jr .store_actual_button_press

.clear_real_button_press:
	xor a
	ldh [rBUTTON_HIT], a
	
.store_actual_button_press:
	ldh a, [rBUTTON_DOWN]
	ldh [rDEMO_ACTUAL_BUTTON], a	; store actual button presses into rDEMO_ACTUAL_BUTTON
	ldh a, [rDEMO_BUTTON_HIT]	
	ldh [rBUTTON_DOWN], a		; replace them with the simulated buttons from the demo storyboard
	ret

; 057D - unused code
	xor a
	ldh [rDEMO_BUTTON_HIT], a
	jr .clear_real_button_press
	ret


USELESS_FUNCTION::
	ldh a, [rDEMO_GAME]
	and a
	ret z				; return if NOT demo mode
	
	ldh a, [rUNUSED]
	cp $ff
	ret nz				; always true - always return

; function never executed:
	ldh a, [rBUTTON_DOWN]
	ld b, a
	ldh a, [rDEMO_BUTTON_HIT]
	cp b
	jr z, l_05ad
	
	ldh a, [rDEMO_STORYBOARD_1]
	ld h, a
	ldh a, [rDEMO_STORYBOARD_2]
	ld l, a
	
	ldh a, [rDEMO_BUTTON_HIT]
	ldi [hl], a
	ldh a, [rDEMO_ACTION_COUNTDOWN]
	ldi [hl], a
	
	ld a, h
	ldh [rDEMO_STORYBOARD_1], a
	ld a, l
	ldh [rDEMO_STORYBOARD_2], a
	ld a, b
	ldh [rDEMO_BUTTON_HIT], a
	
	xor a
	ldh [rDEMO_ACTION_COUNTDOWN], a
	ret

l_05ad:
	ldh a, [rDEMO_ACTION_COUNTDOWN]
	inc a
	ldh [rDEMO_ACTION_COUNTDOWN], a
	ret


RESTORE_BUTTON_PRESSES::
	ldh a, [rDEMO_GAME]
	and a
	ret z				; return if NOT in demo game 
	
	ldh a, [rUNUSED]
	and a
	ret nz
	
	ldh a, [rDEMO_ACTUAL_BUTTON]
	ldh [rBUTTON_DOWN], a		; restore stored real button presses at begin of menu_in_game function
	ret

l_05c0:
	ld hl, $ff02
	set 7, [hl]
	jr l_05d1
l_05c7:
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, l_05c0

l_05d1:
	call func_144f
	ld a, $80
	ld [rNEXT_BLOCK_VISIBILITY], a
	call func_2671
	ldh [rREQUEST_SERIAL_TRANSFER], a
	xor a
	ldh [rSB], a
	ldh [rSB_DATA], a
	ldh [$ff00 + $dc], a
	ldh [$ff00 + $d2], a
	ldh [$ff00 + $d3], a
	ldh [$ff00 + $d4], a
	ldh [$ff00 + $d5], a
	ldh [rROW_UPDATE], a
	call Sound_Init
	ld a, $2b
	ldh [rGAME_STATUS], a
	ret
	
	
func_05f7:
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0613
	ldh a, [$ff00 + $f0]
	and a
	jr z, l_0620
	xor a
	ldh [$ff00 + $f0], a
	ld de, rBLOCK_Y
	call func_1492
	call func_1517
	call func_2671
	jr l_0620

l_0613:
	ldh a, [rBUTTON_HIT]
	bit 0, a
	jr nz, l_0620
	bit 3, a
	jr nz, l_0620
	call func_14b0

l_0620:
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0644
	ldh a, [$ff00 + $cc]
	and a
	ret z
	xor a
	ldh [$ff00 + $cc], a
	ld a, $39
	ldh [rSB_DATA], a
	ldh a, [$ff00 + $d0]
	cp $50
	jr z, l_0664
	ld b, a
	ldh a, [$ff00 + $c1]
	cp b
	ret z
	ld a, b
	ldh [$ff00 + $c1], a
	ld a, $01
	ldh [$ff00 + $f0], a
	ret

l_0644:
	ldh a, [rBUTTON_HIT]
	bit 3, a
	jr nz, l_066c
	bit 0, a
	jr nz, l_066c
	ldh a, [$ff00 + $cc]
	and a
	ret z
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [rSB_DATA]
	cp $50
	jr z, l_0664
	ldh a, [$ff00 + $c1]

l_065d:
	ldh [rSB_DATA], a
	ld a, $01
	ldh [rREQUEST_SERIAL_TRANSFER], a
	ret

l_0664:
	call CLEAR_OAM_DATA
	ld a, $16
	ldh [rGAME_STATUS], a
	ret

l_066c:
	ld a, $50
	jr l_065d

l_0670:
	ld hl, $ff02
	set 7, [hl]
	jr l_0696
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, l_0670
	call func_0aa1
	call func_0aa1
	call func_0aa1
	ld b, $00
	ld hl, $c300

l_068f:
	call func_0aa1
	ldi [hl], a
	dec b
	jr nz, l_068f

l_0696:
	call WAIT_FOR_VBLANK
	call COPY_IN_GAME_TILES
	ld de, $5214
	call COPY_TILEMAP
	call CLEAR_OAM_DATA
	ld a, $2f
	call func_1fdd
	ld a, $03
	ldh [rREQUEST_SERIAL_TRANSFER], a
	xor a
	ldh [rSB], a
	ldh [rSB_DATA], a
	ldh [$ff00 + $dc], a
	ldh [$ff00 + $d2], a
	ldh [$ff00 + $d3], a
	ldh [$ff00 + $d4], a
	ldh [$ff00 + $d5], a
	ldh [rROW_UPDATE], a

l_06bf:
	ldh [$ff00 + $cc], a
	ld hl, $c400
	ld b, $0a
	ld a, $28

l_06c8:
	ldi [hl], a
	dec b
	jr nz, l_06c8
	ldh a, [$ff00 + $d6]
	and a
	jp nz, l_076d
	call func_1517
	ld a, $d3
	ldh [$ff00 + $40], a
	ld hl, $c080

l_06dc:
	ld de, $0705
	ld b, $20

l_06e1:
	call func_0725
	ld hl, rBLOCK_VISIBILITY
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
	ldh [rGAME_STATUS], a
	ret

	db $40, $28, $AE, $00, $40, $30, $AE, $20, $48, $28, $AF, $00
	db $48, $30, $AF, $20, $78, $28, $C0, $00, $78, $30, $C0, $20
	db $80, $28, $C1, $00, $80, $30, $C1, $20
	
func_0725:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, func_0725
	ret

	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0755
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_074a
	ldh a, [$ff00 + $d0]
	cp $60
	jr z, l_076a
	cp $06
	jr nc, l_0743
	ldh [$ff00 + $ac], a

l_0743:
	ldh a, [$ff00 + $ad]
	ldh [rSB_DATA], a
	xor a
	ldh [$ff00 + $cc], a

l_074a:
	ld de, rNEXT_BLOCK_VISIBILITY
	call func_1766
	ld hl, $ffad
	jr l_07bd

l_0755:
	ldh a, [rBUTTON_HIT]
	bit 3, a
	jr z, l_075f
	ld a, $60
	jr l_07ac

l_075f:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_07b4
	ldh a, [rSB_DATA]
	cp $60
	jr nz, l_07a2

l_076a:
	call CLEAR_OAM_DATA

l_076d:
	ldh a, [$ff00 + $d6]
	and a
	jr nz, l_078a
	ld a, $18
	ldh [rGAME_STATUS], a
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

l_078a:
	ldh a, [$ff00 + $cb]
	cp $29

l_078e:
	jp nz, l_0828
	xor a
	ldh [$ff00 + $a0], a
	ld a, $06
	ld de, $ffe0
	ld hl, $c9a2
	call func_1b68
	jp l_0828

l_07a2:
	ldh a, [$ff00 + $d0]
	cp $06
	jr nc, l_07aa
	ldh [$ff00 + $ad], a

l_07aa:
	ldh a, [$ff00 + $ac]

l_07ac:
	ldh [rSB_DATA], a
	xor a
	ldh [$ff00 + $cc], a
	inc a
	ldh [rREQUEST_SERIAL_TRANSFER], a

l_07b4:
	ld de, rBLOCK_VISIBILITY
	call func_1766
	ld hl, $ffac

l_07bd:
	ld a, [hl]
	bit 4, b
	jr nz, l_07d6
	bit 5, b
	jr nz, l_07e8
	bit 6, b
	jr nz, l_07ee
	bit 7, b
	jr z, l_07e1
	cp $03
	jr nc, l_07e1
	add a, $03
	jr l_07db

l_07d6:
	cp $05
	jr z, l_07e1
	inc a

l_07db:
	ld [hl], a
	ld a, $01
	ld [$dfe0], a

l_07e1:
	call func_080e
	call func_2671
	ret

l_07e8:
	and a
	jr z, l_07e1
	dec a
	jr l_07db

l_07ee:
	cp $03
	jr c, l_07e1
	sub a, $03
	jr l_07db

;data $7f6 - 80d (incl.)
	db $40, $60, $40, $70, $40, $80, $50, $60, $50, $70, $50, $80
	db $78, $60, $78, $70, $78, $80, $88, $60, $88, $70, $88, $80

func_080e:
	ldh a, [$ff00 + $ac]
	ld de, rBLOCK_Y
	ld hl, $07f6
	call func_1755
	ldh a, [$ff00 + $ad]
	ld de, rNEXT_BLOCK_Y
	ld hl, $0802
	call func_1755
	ret
	call WAIT_FOR_VBLANK

l_0828:
	xor a
	ld [rNEXT_BLOCK_VISIBILITY], a
	ldh [rBLOCK_STATUS], a
	ldh [rCLEAR_PROGRESS], a
	ldh [$ff00 + $9b], a
	ldh [$ff00 + $fb], a
	ldh [rLINES_CLEARED2], a
	ldh [$ff00 + $cc], a
	ldh [rSB], a
	ldh [rREQUEST_SERIAL_TRANSFER], a
	ldh [$ff00 + $d0], a
	ldh [rSB_DATA], a
	ldh [$ff00 + $d1], a
	call func_2651
	call func_2293
	call func_1ff2
	xor a
	ldh [rROW_UPDATE], a
	call CLEAR_OAM_DATA
	ld de, $537c
	push de
	ld a, $01
	ldh [$ff00 + $a9], a
	ldh [rPLAYERS], a
	call COPY_TILEMAP

l_085e:
	pop de
	ld hl, $9c00
	call COPY_TILEMAP_B
	ld de, $2839
	ld hl, $9c63
	ld c, $0a
	call func_1f7d
	ld hl, rBLOCK_VISIBILITY
	ld de, $26bf
	call func_26b6
	ld hl, rNEXT_BLOCK_VISIBILITY
	ld de, $26c7
	call func_26b6
	ld hl, $9951
	ld a, $30
	ldh [rLINES_CLEARED1], a
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
	jr z, l_08a4
	ld de, $08c4
	ldh a, [$ff00 + $ad]

l_08a4:
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
	ldh [rGAME_STATUS], a
	ld a, $01
	ldh [$ff00 + $cd], a
	ret

	db $18, $84, $C0, $00, $18, $8C, $C0, $20, $20, $84, $C1, $00
	db $20, $8C, $C1, $20, $18, $84, $AE, $00, $18, $8C, $AE, $20
	db $20, $84, $AF, $00, $20, $8C, $AF

	jr nz, l_0923
	ld [$ffe0], sp
	xor a
	ldh [$ff00 + $0f], a
	ldh a, [$ff00 + $cb]

l_08ed:
	cp $29
	jp nz, l_09f6

l_08f2:
	call WASTE_TIME
	call WASTE_TIME
	xor a
	ldh [$ff00 + $cc], a
	ld a, $29

l_08fd:
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a

l_0903:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0903
	ldh a, [rSB]
	cp $55
	jr nz, l_08f2
	ld de, $0016
	ld c, $0a
	ld hl, $c902

l_0916:
	ld b, $0a

l_0918:
	xor a
	ldh [$ff00 + $cc], a
	call WASTE_TIME
	ldi a, [hl]
	ldh [rSB], a
	ld a, $81

l_0923:
	ldh [rSC], a

l_0925:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0925
	dec b
	jr nz, l_0918
	add hl, de
	dec c
	jr nz, l_0916
	ldh a, [$ff00 + $ac]
	cp $05
	jr z, l_0974
	ld hl, $ca22
	ld de, $0040

l_093d:
	add hl, de
	inc a
	cp $05
	jr nz, l_093d
	ld de, $ca22
	ld c, $0a

l_0948:
	ld b, $0a

l_094a:
	ld a, [de]
	ldi [hl], a
	inc e
	dec b
	jr nz, l_094a
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
	jr nz, l_0948
	ld de, $ffd6

l_0964:
	ld b, $0a
	ld a, h
	cp $c8
	jr z, l_0974
	ld a, $2f

l_096d:
	ldi [hl], a
	dec b
	jr nz, l_096d
	add hl, de
	jr l_0964

l_0974:
	call WASTE_TIME
	call WASTE_TIME
	xor a
	ldh [$ff00 + $cc], a
	ld a, $29
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a

l_0985:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0985
	ldh a, [rSB]
	cp $55
	jr nz, l_0974
	ld hl, $c300
	ld b, $00

l_0995:
	xor a
	ldh [$ff00 + $cc], a
	ldi a, [hl]
	call WASTE_TIME
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a

l_09a2:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_09a2
	inc b
	jr nz, l_0995

l_09aa:
	call WASTE_TIME
	call WASTE_TIME
	xor a
	ldh [$ff00 + $cc], a
	ld a, $30
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a

l_09bb:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_09bb
	ldh a, [rSB]
	cp $56
	jr nz, l_09aa

l_09c6:
	call func_0a8c
	ld a, $09
	ldh [$ff00 + $ff], a
	ld a, $1c
	ldh [rGAME_STATUS], a
	ld a, $02
	ldh [rROW_UPDATE], a
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_09e4
	ld hl, $ff02
	set 7, [hl]

l_09e4:
	ld hl, $c300
	ldi a, [hl]
	ld [rBLOCK_TYPE], a
	ldi a, [hl]
	ld [rNEXT_BLOCK_TYPE], a
	ld a, h
	ldh [$ff00 + $af], a
	ld a, l
	ldh [rDEMO_STATUS], a
	ret

l_09f6:
	ldh a, [$ff00 + $ad]
	inc a
	ld b, a
	ld hl, $ca42
	ld de, $ffc0

l_0a00:
	dec b
	jr z, l_0a06
	add hl, de
	jr l_0a00

l_0a06:
	call WASTE_TIME
	xor a
	ldh [$ff00 + $cc], a
	ld a, $55
	ldh [rSB], a
	ld a, $80
	ldh [rSC], a

l_0a14:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0a14
	ldh a, [rSB]
	cp $29
	jr nz, l_0a06
	ld de, $0016
	ld c, $0a

l_0a24:
	ld b, $0a

l_0a26:
	xor a
	ldh [$ff00 + $cc], a
	ldh [rSB], a
	ld a, $80
	ldh [rSC], a

l_0a2f:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0a2f
	ldh a, [rSB]
	ldi [hl], a
	dec b
	jr nz, l_0a26
	add hl, de
	dec c
	jr nz, l_0a24

l_0a3e:
	call WASTE_TIME
	xor a
	ldh [$ff00 + $cc], a
	ld a, $55
	ldh [rSB], a
	ld a, $80
	ldh [rSC], a

l_0a4c:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0a4c
	ldh a, [rSB]
	cp $29
	jr nz, l_0a3e
	ld b, $00
	ld hl, $c300

l_0a5c:
	xor a
	ldh [$ff00 + $cc], a
	ldh [rSB], a
	ld a, $80
	ldh [rSC], a

l_0a65:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0a65
	ldh a, [rSB]
	ldi [hl], a
	inc b
	jr nz, l_0a5c

l_0a70:
	call WASTE_TIME
	xor a
	ldh [$ff00 + $cc], a
	ld a, $56
	ldh [rSB], a
	ld a, $80
	ldh [rSC], a

l_0a7e:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_0a7e
	ldh a, [rSB]
	cp $30
	jr nz, l_0a70
	jp l_09c6


func_0a8c:
	ld hl, $ca42
	ld a, $80
	ld b, $0a

l_0a93:
	ldi [hl], a
	dec b
	jr nz, l_0a93
	ret


WASTE_TIME::
	push bc
	ld b, $fa
l_0a9b:
	ld b, b
	dec b
	jr nz, l_0a9b
	pop bc
	ret


func_0aa1:
	push hl
	push bc
	ldh a, [$ff00 + $fc]
	and $fc
	ld c, a
	ld h, $03

l_0aaa:
	ldh a, [$ff00 + $04]
	ld b, a

l_0aad:
	xor a

l_0aae:
	dec b
	jr z, l_0abb
	inc a
	inc a
	inc a
	inc a
	cp $1c
	jr z, l_0aad
	jr l_0aae

l_0abb:
	ld d, a
	ldh a, [$ff00 + $ae]
	ld e, a
	dec h
	jr z, l_0ac9
	or d
	or c
	and $fc
	cp c
	jr z, l_0aaa

l_0ac9:
	ld a, d
	ldh [$ff00 + $ae], a
	ld a, e
	ldh [$ff00 + $fc], a
	pop bc
	pop hl
	ret
	ld a, $01
	ldh [$ff00 + $ff], a
	ldh a, [rROW_UPDATE]
	and a
	jr nz, l_0b02
	ld b, $44
	ld c, $20
	call func_113f
	ld a, $02
	ldh [$ff00 + $cd], a
	ld a, [$c0de]
	and a
	jr z, l_0af1
	ld a, $80
	ld [rNEXT_BLOCK_VISIBILITY], a

l_0af1:
	call func_2683
	call func_2696
	call func_1517
	xor a
	ldh [$ff00 + $d6], a
	ld a, $1a
	ldh [rGAME_STATUS], a
	ret

l_0b02:
	cp $05
	ret nz
	ld hl, $c030
	ld b, $12

l_0b0a:
	ld [hl], $f0
	inc hl
	ld [hl], $10
	inc hl
	ld [hl], $b6
	inc hl
	ld [hl], $80
	inc hl
	dec b
	jr nz, l_0b0a
	ld a, [$c3ff]

l_0b1c:
	ld b, $0a
	ld hl, $c400

l_0b21:
	dec a
	jr z, l_0b2a
	inc l
	dec b
	jr nz, l_0b21
	jr l_0b1c

l_0b2a:
	ld [hl], $2f
	ld a, $03
	ldh [rREQUEST_SERIAL_TRANSFER], a
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
	call START_SELECT_HANDLER
	call func_1c88
	call func_24bb
	call func_209c
	call func_213e
	call func_25a1
	call func_224d
	call func_0b9b
	ldh a, [$ff00 + $d5]
	and a
	jr z, l_0b73
	ld a, $77
	ldh [rSB_DATA], a
	ldh [$ff00 + $b1], a
	ld a, $aa
	ldh [$ff00 + $d1], a
	ld a, $1b
	ldh [rGAME_STATUS], a
	ld a, $05
	ldh [rCOUNTDOWN2], a
	jr l_0b83

l_0b73:
	ldh a, [rGAME_STATUS]
	cp $01
	jr nz, l_0b94
	ld a, $aa
	ldh [rSB_DATA], a
	ldh [$ff00 + $b1], a
	ld a, $77
	ldh [$ff00 + $d1], a

l_0b83:
	xor a
	ldh [$ff00 + $dc], a
	ldh [$ff00 + $d2], a
	ldh [$ff00 + $d3], a
	ldh [$ff00 + $d4], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, l_0b94
	ldh [rREQUEST_SERIAL_TRANSFER], a

l_0b94:
	call func_0bf0
	call func_0c8c
	ret


func_0b9b:
	ld de, $0020
	ld hl, $c802
	ld a, $2f
	ld c, $12

l_0ba5:
	ld b, $0a
	push hl

l_0ba8:
	cp [hl]
	jr nz, l_0bb5
	inc hl
	dec b
	jr nz, l_0ba8
	pop hl
	add hl, de
	dec c
	jr nz, l_0ba5
	push hl

l_0bb5:
	pop hl
	ld a, c
	ldh [$ff00 + $b1], a
	cp $0c
	ld a, [$dfe9]
	jr nc, l_0bc7
	cp $08
	ret nz
	call func_1517
	ret

l_0bc7:
	cp $08
	ret z
	ld a, [$dff0]
	cp $02
	ret z
	ld a, $08
	ld [$dfe8], a
	ret

l_0bd6:
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0c2e
	ld a, $01
	ld [rPAUSED], a
	ldh [$ff00 + $ab], a
	ldh a, [rSB_DATA]
	ldh [$ff00 + $f1], a
	xor a
	ldh [$ff00 + $f2], a
	ldh [rSB_DATA], a
	call func_1ccb
	ret


func_0bf0:
	ldh a, [$ff00 + $cc]
	and a
	ret z
	ld hl, $c030
	ld de, $0004
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [$ff00 + $d0]
	cp $aa
	jr z, l_0c64
	cp $77
	jr z, l_0c50
	cp $94
	jr z, l_0bd6
	ld b, a
	and a
	jr z, l_0c60
	bit 7, a
	jr nz, l_0c82
	cp $13
	jr nc, l_0c2e
	ld a, $12
	sub a, b
	ld c, a
	inc c

l_0c1c:
	ld a, $98

l_0c1e:
	ld [hl], a
	add hl, de
	sub a, $08
	dec b
	jr nz, l_0c1e

l_0c25:
	ld a, $f0

l_0c27:
	dec c
	jr z, l_0c2e
	ld [hl], a
	add hl, de
	jr l_0c27

l_0c2e:
	ldh a, [$ff00 + $dc]
	and a
	jr z, l_0c3a
	or $80
	ldh [$ff00 + $b1], a
	xor a
	ldh [$ff00 + $dc], a

l_0c3a:
	ld a, $ff
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $cb]
	cp $29
	ldh a, [$ff00 + $b1]
	jr nz, l_0c4d
	ldh [rSB_DATA], a
	ld a, $01
	ldh [rREQUEST_SERIAL_TRANSFER], a
	ret

l_0c4d:
	ldh [rSB_DATA], a
	ret

l_0c50:
	ldh a, [$ff00 + $d1]
	cp $aa
	jr z, l_0c7c
	ld a, $77
	ldh [$ff00 + $d1], a
	ld a, $01
	ldh [rGAME_STATUS], a
	jr l_0c2e

l_0c60:
	ld c, $13
	jr l_0c25

l_0c64:
	ldh a, [$ff00 + $d1]
	cp $77
	jr z, l_0c7c
	ld a, $aa
	ldh [$ff00 + $d1], a
	ld a, $1b
	ldh [rGAME_STATUS], a
	ld a, $05
	ldh [rCOUNTDOWN2], a
	ld c, $01
	ld b, $12
	jr l_0c1c

l_0c7c:
	ld a, $01
	ldh [$ff00 + $ef], a
	jr l_0c2e

l_0c82:
	and $7f
	cp $05
	jr nc, l_0c2e
	ldh [$ff00 + $d2], a
	jr l_0c3a


func_0c8c:
	ldh a, [$ff00 + $d3]
	and a
	jr z, l_0c98
	bit 7, a
	ret z
	and $07
	jr l_0ca2

l_0c98:
	ldh a, [$ff00 + $d2]
	and a
	ret z
	ldh [$ff00 + $d3], a
	xor a
	ldh [$ff00 + $d2], a
	ret

l_0ca2:
	ld c, a
	push bc
	ld hl, $c822
	ld de, $ffe0

l_0caa:
	add hl, de
	dec c
	jr nz, l_0caa
	ld de, $c822
	ld c, $11

l_0cb3:
	ld b, $0a

l_0cb5:
	ld a, [de]
	ldi [hl], a
	inc e
	dec b
	jr nz, l_0cb5
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
	jr nz, l_0cb3
	pop bc

l_0ccd:
	ld de, $c400
	ld b, $0a

l_0cd2:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, l_0cd2
	push de
	ld de, $0016
	add hl, de
	pop de
	dec c
	jr nz, l_0ccd
	ld a, $02
	ldh [rROW_UPDATE], a
	ldh [$ff00 + $d4], a
	xor a
	ldh [$ff00 + $d3], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld a, $01
	ldh [$ff00 + $ff], a
	ld a, $03
	ldh [$ff00 + $cd], a
	ldh a, [$ff00 + $d1]
	cp $77
	jr nz, l_0d09
	ldh a, [$ff00 + $d0]
	cp $aa
	jr nz, l_0d13

l_0d03:
	ld a, $01
	ldh [$ff00 + $ef], a
	jr l_0d13

l_0d09:
	cp $aa
	jr nz, l_0d13
	ldh a, [$ff00 + $d0]
	cp $77
	jr z, l_0d03

l_0d13:
	ld b, $34
	ld c, $43
	call func_113f
	xor a
	ldh [rROW_UPDATE], a
	ldh a, [$ff00 + $d1]
	cp $aa
	ld a, $1e
	jr nz, l_0d27
	ld a, $1d

l_0d27:
	ldh [rGAME_STATUS], a
	ld a, $28
	ldh [rCOUNTDOWN], a
	ld a, $1d
	ldh [$ff00 + $c6], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ldh a, [$ff00 + $ef]
	and a
	jr nz, l_0d40
	ldh a, [$ff00 + $d7]
	inc a
	ldh [$ff00 + $d7], a

l_0d40:
	call func_0f6f
	ld de, $26f9
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0d4f
	ld de, $270b

l_0d4f:
	ld hl, rBLOCK_VISIBILITY
	ld c, $03
	call func_1776
	ld a, $19
	ldh [rCOUNTDOWN], a
	ldh a, [$ff00 + $ef]
	and a
	jr z, l_0d65
	ld hl, $c220
	ld [hl], $80

l_0d65:
	ld a, $03
	call func_2673
	ld a, $20
	ldh [rGAME_STATUS], a
	ld a, $09
	ld [$dfe8], a
	ldh a, [$ff00 + $d7]
	cp $05
	ret nz
	ld a, $11
	ld [$dfe8], a
	ret

l_0d7e:
	ldh a, [$ff00 + $d7]
	cp $05
	jr nz, l_0d8b
	ldh a, [$ff00 + $c6]
	and a
	jr z, l_0d91
	jr l_0dad

l_0d8b:
	ldh a, [rBUTTON_HIT]
	bit 3, a
	jr z, l_0dad

l_0d91:
	ld a, $60
	ldh [rSB_DATA], a
	ldh [rREQUEST_SERIAL_TRANSFER], a
	jr l_0db6
	ld a, $01
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $cc]
	jr z, l_0dad
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0d7e
	ldh a, [$ff00 + $d0]
	cp $60
	jr z, l_0db6

l_0dad:
	call func_0dbd
	ld a, $03
	call func_2673
	ret

l_0db6:
	ld a, $1f
	ldh [rGAME_STATUS], a
	ldh [$ff00 + $cc], a
	ret


func_0dbd:
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, l_0de5
	ld hl, $ffc6
	dec [hl]
	ld a, $19
	ldh [rCOUNTDOWN], a
	call func_0f60
	ld hl, rBLOCK_Y
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

l_0de5:
	ldh a, [$ff00 + $d7]
	cp $05
	jr nz, l_0e13
	ldh a, [$ff00 + $c6]
	ld hl, $c221
	cp $06
	jr z, l_0e0f
	cp $08
	jr nc, l_0e13
	ld a, [hl]
	cp $72
	jr nc, l_0e03
	cp $69
	ret z
	inc [hl]
	inc [hl]
	ret

l_0e03:
	ld [hl], $69
	inc l
	inc l
	ld [hl], $57
	ld a, $06
	ld [$dfe0], a
	ret

l_0e0f:
	dec l
	ld [hl], $80
	ret

l_0e13:
	ldh a, [rCOUNTDOWN2]
	and a
	ret nz
	ld a, $0f
	ldh [rCOUNTDOWN2], a
	ld hl, $c223
	ld a, [hl]
	xor $01
	ld [hl], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ldh a, [$ff00 + $ef]
	and a
	jr nz, l_0e31
	ldh a, [$ff00 + $d8]
	inc a
	ldh [$ff00 + $d8], a

l_0e31:
	call func_0f6f
	ld de, $271d
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0e40
	ld de, $2729

l_0e40:
	ld hl, rBLOCK_VISIBILITY
	ld c, $02
	call func_1776
	ld a, $19
	ldh [rCOUNTDOWN], a
	ldh a, [$ff00 + $ef]
	and a
	jr z, l_0e56
	ld hl, rNEXT_BLOCK_VISIBILITY
	ld [hl], $80

l_0e56:
	ld a, $02
	call func_2673
	ld a, $21
	ldh [rGAME_STATUS], a
	ld a, $09
	ld [$dfe8], a
	ldh a, [$ff00 + $d8]
	cp $05
	ret nz
	ld a, $11
	ld [$dfe8], a
	ret

l_0e6f:
	ldh a, [$ff00 + $d8]
	cp $05
	jr nz, l_0e7c
	ldh a, [$ff00 + $c6]
	and a
	jr z, l_0e82
	jr l_0e9e

l_0e7c:
	ldh a, [rBUTTON_HIT]
	bit 3, a
	jr z, l_0e9e

l_0e82:
	ld a, $60
	ldh [rSB_DATA], a
	ldh [rREQUEST_SERIAL_TRANSFER], a
	jr l_0ea7
	ld a, $01
	ldh [$ff00 + $ff], a
	ldh a, [$ff00 + $cc]
	jr z, l_0e9e
	ldh a, [$ff00 + $cb]
	cp $29
	jr z, l_0e6f
	ldh a, [$ff00 + $d0]
	cp $60
	jr z, l_0ea7

l_0e9e:
	call func_0eae
	ld a, $02
	call func_2673
	ret

l_0ea7:
	ld a, $1f
	ldh [rGAME_STATUS], a
	ldh [$ff00 + $cc], a
	ret


func_0eae:
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, l_0ecf
	ld hl, $ffc6
	dec [hl]
	ld a, $19
	ldh [rCOUNTDOWN], a
	call func_0f60
	ld hl, rNEXT_BLOCK_Y
	ld a, [hl]
	xor $08
	ldi [hl], a
	cp $68
	call z, func_0f17
	inc l
	ld a, [hl]
	xor $01
	ld [hl], a

l_0ecf:
	ldh a, [$ff00 + $d8]
	cp $05
	jr nz, l_0f07
	ldh a, [$ff00 + $c6]
	ld hl, rBLOCK_Y
	cp $05
	jr z, l_0f03
	cp $06
	jr z, l_0ef3
	cp $08
	jr nc, l_0f07
	ld a, [hl]
	cp $72
	jr nc, l_0f03
	cp $61
	ret z
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

l_0ef3:
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

l_0f03:
	dec l
	ld [hl], $80
	ret

l_0f07:
	ldh a, [rCOUNTDOWN2]
	and a
	ret nz
	ld a, $0f
	ldh [rCOUNTDOWN2], a
	ld hl, rBLOCK_TYPE
	ld a, [hl]
	xor $01
	ld [hl], a
	ret


func_0f17:
	push af
	push hl
	ldh a, [$ff00 + $d7]
	cp $05
	jr z, l_0f39
	ldh a, [$ff00 + $d8]
	cp $05
	jr z, l_0f39
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, l_0f39
	ld hl, $c060
	ld b, $24
	ld de, $0f3c

l_0f33:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, l_0f33

l_0f39:
	pop hl
	pop af
	ret

	db $42, $30, $0D, $00, $42, $38, $B2, $00, $42, $40, $0E, $00
	db $42, $48, $1C, $00, $42, $58, $0E, $00, $42, $60, $1D, $00
	db $42, $68, $B5, $00, $42, $70, $BB, $00, $42, $78, $1D, $00

func_0f60:
	ld hl, $c060
	ld de, $0004
	ld b, $09
	xor a

l_0f69:
	ld [hl], a
	add hl, de
	dec b
	jr nz, l_0f69
	ret


func_0f6f:
	call WAIT_FOR_VBLANK
	ld hl, $55ac
	ld bc, $1000
	call func_27e4
	call Flush_BG1
	ld hl, $9800
	ld de, $54e4
	ld b, $04
	call COPY_TILEMAP_FEWER_ROWS
	ld hl, $9980
	ld b, $06
	call COPY_TILEMAP_FEWER_ROWS
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, l_0fb9
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

l_0fb9:
	ldh a, [$ff00 + $ef]
	and a
	jr nz, l_0fc1
	call func_1085

l_0fc1:
	ldh a, [$ff00 + $d7]
	and a
	jr z, l_100f
	cp $05
	jr nz, l_0fe0
	ld hl, $98a5
	ld b, $0b
	ldh a, [$ff00 + $cb]
	cp $29
	ld de, $10f3
	jr z, l_0fdb
	ld de, $10fe

l_0fdb:
	call func_10d8
	ld a, $04

l_0fe0:
	ld c, a
	ldh a, [$ff00 + $cb]
	cp $29
	ld a, $93
	jr nz, l_0feb
	ld a, $8f

l_0feb:
	ldh [$ff00 + $a0], a
	ld hl, $99e7
	call func_106a
	ldh a, [$ff00 + $d9]
	and a
	jr z, l_100f
	ld a, $ac
	ldh [$ff00 + $a0], a
	ld hl, $99f0
	ld c, $01
	call func_106a
	ld hl, $98a6
	ld de, $1109
	ld b, $09
	call func_10d8

l_100f:
	ldh a, [$ff00 + $d8]
	and a
	jr z, l_1052
	cp $05
	jr nz, l_102e
	ld hl, $98a5
	ld b, $0b
	ldh a, [$ff00 + $cb]
	cp $29
	ld de, $10fe
	jr z, l_1029
	ld de, $10f3

l_1029:
	call func_10d8
	ld a, $04

l_102e:
	ld c, a
	ldh a, [$ff00 + $cb]
	cp $29
	ld a, $8f
	jr nz, l_1039
	ld a, $93

l_1039:
	ldh [$ff00 + $a0], a
	ld hl, $9827
	call func_106a
	ldh a, [$ff00 + $da]
	and a
	jr z, l_1052
	ld a, $ac
	ldh [$ff00 + $a0], a
	ld hl, $9830
	ld c, $01
	call func_106a

l_1052:
	ldh a, [$ff00 + $db]
	and a
	jr z, l_1062
	ld hl, $98a7
	ld de, $10ed
	ld b, $06
	call func_10d8

l_1062:
	ld a, $d3
	ldh [$ff00 + $40], a
	call CLEAR_OAM_DATA
	ret


func_106a:
	ldh a, [$ff00 + $a0]
	push hl
	ld de, $0020
	ld b, $02

l_1072:
	push hl
	ldi [hl], a
	inc a
	ld [hl], a
	inc a
	pop hl
	add hl, de
	dec b
	jr nz, l_1072
	pop hl
	ld de, $0003
	add hl, de
	dec c
	jr nz, $106a
	ret


func_1085:
	ld hl, $ffd7
	ld de, $ffd8
	ldh a, [$ff00 + $d9]
	and a
	jr nz, l_10ca
	ldh a, [$ff00 + $da]
	and a
	jr nz, l_10d1
	ldh a, [$ff00 + $db]
	and a
	jr nz, l_10bb
	ld a, [hl]
	cp $04
	jr z, l_10b0
	ld a, [de]
	cp $04
	ret nz

l_10a3:
	ld a, $05
	ld [de], a
	jr l_10b2
	ld a, [de]
	cp $03
	ret nz

l_10ac:
	ld a, $03
	jr l_10b5

l_10b0:
	ld [hl], $05

l_10b2:
	xor a
	ldh [$ff00 + $db], a

l_10b5:
	xor a
	ldh [$ff00 + $d9], a
	ldh [$ff00 + $da], a
	ret

l_10bb:
	ld a, [hl]
	cp $04
	jr nz, l_10c6
	ldh [$ff00 + $d9], a

l_10c2:
	xor a
	ldh [$ff00 + $db], a
	ret

l_10c6:
	ldh [$ff00 + $da], a
	jr l_10c2

l_10ca:
	ld a, [hl]
	cp $05
	jr z, l_10b0
	jr l_10ac

l_10d1:
	ld a, [de]
	cp $05
	jr z, l_10a3
	jr l_10ac


func_10d8:
	push bc
	push hl

l_10da:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, l_10da
	pop hl
	ld de, $0020
	add hl, de
	pop bc
	ld a, $b6

l_10e8:
	ldi [hl], a
	dec b
	jr nz, l_10e8
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
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	call CLEAR_OAM_DATA
	xor a
	ldh [$ff00 + $ef], a
	ld b, $27
	ld c, $79
	call func_113f
	call Sound_Init
	ldh a, [$ff00 + $d7]
	cp $05
	jr z, l_113a
	ldh a, [$ff00 + $d8]
	cp $05
	jr z, l_113a
	ld a, $01
	ldh [$ff00 + $d6], a

l_113a:
	ld a, $16
	ldh [rGAME_STATUS], a
	ret


func_113f:
	ldh a, [$ff00 + $cc]
	and a
	jr z, l_1158
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [$ff00 + $cb]
	cp $29
	ldh a, [$ff00 + $d0]
	jr nz, l_1160
	cp b
	jr z, l_115a
	ld a, $02
	ldh [rSB_DATA], a
	ldh [rREQUEST_SERIAL_TRANSFER], a

l_1158:
	pop hl
	ret

l_115a:
	ld a, c
	ldh [rSB_DATA], a
	ldh [rREQUEST_SERIAL_TRANSFER], a
	ret

l_1160:
	cp c
	ret z
	ld a, b
	ldh [rSB_DATA], a
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
	ld hl, rBLOCK_VISIBILITY
	ld c, $03
	call func_1776
	ld a, $03
	call func_2673
	ld a, $db
	ldh [$ff00 + $40], a
	ld a, $bb
	ldh [rCOUNTDOWN], a
	ld a, $27
	ldh [rGAME_STATUS], a
	ld a, $10
	ld [$dfe8], a
	ret


func_11b2:
	call WAIT_FOR_VBLANK
	ld hl, $55ac
	ld bc, $1000
	call func_27e4
	ld hl, $9fff
	call func_2798
	ld hl, $9dc0
	ld de, $51c4
	ld b, $04
	call COPY_TILEMAP_FEWER_ROWS
	ld hl, $9cec
	ld de, $1429
	ld b, $07
	call func_1437
	ld hl, $9ced
	ld de, $1430
	ld b, $07
	call func_1437
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld hl, rNEXT_BLOCK_VISIBILITY
	ld [hl], $00
	ld l, $20
	ld [hl], $00
	ld a, $ff
	ldh [rCOUNTDOWN], a
	ld a, $28
	ldh [rGAME_STATUS], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	jr z, l_1205
	call func_13fa
	ret

l_1205:
	ld a, $29
	ldh [rGAME_STATUS], a
	ld hl, rNEXT_BLOCK_TYPE
	ld [hl], $35
	ld l, $23
	ld [hl], $35
	ld a, $ff
	ldh [rCOUNTDOWN], a
	ld a, $2f
	call func_1fd7
	ret
	ldh a, [rCOUNTDOWN]
	and a
	jr z, l_1225
	call func_13fa
	ret

l_1225:
	ld a, $02
	ldh [rGAME_STATUS], a
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
	
	
lbl_MENU_ROCKET_1D::
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, l_1277
	ld a, $0a
	ldh [rCOUNTDOWN], a
	ld hl, rBLOCK_Y
	dec [hl]
	ld a, [hl]
	cp $58
	jr nz, l_1277
	ld hl, rNEXT_BLOCK_VISIBILITY
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
	ldh [rGAME_STATUS], a
	ld a, $04
	ld [$dff8], a
	ret

l_1277:
	call func_13fa
	ret
	
	
lbl_MENU_ROCKET_1E::
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, l_129d
	ld a, $0a
	ldh [rCOUNTDOWN], a
	ld hl, rNEXT_BLOCK_Y
	dec [hl]
	ld l, $01
	dec [hl]
	ld a, [hl]
	cp $d0
	jr nz, l_129d
	ld a, $9c
	ldh [$ff00 + $c9], a
	ld a, $82
	ldh [$ff00 + $ca], a
	ld a, $2c
	ldh [rGAME_STATUS], a
	ret

l_129d:
	ldh a, [rCOUNTDOWN2]
	and a
	jr nz, l_12ad
	ld a, $06
	ldh [rCOUNTDOWN2], a
	ld hl, rNEXT_BLOCK_TYPE
	ld a, [hl]
	xor $01
	ld [hl], a

l_12ad:
	ld a, $03
	call func_2673
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld a, $06
	ldh [rCOUNTDOWN], a
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
	ldh [rCOUNTDOWN], a
	ld a, $2d
	ldh [rGAME_STATUS], a
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
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	call WAIT_FOR_VBLANK
	call COPY_IN_GAME_TILES
	call func_2293
	ld a, $93
	ldh [$ff00 + $40], a
	ld a, $05
	ldh [rGAME_STATUS], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld a, $2e
	ldh [rGAME_STATUS], a
	ret
	call func_11b2
	ld de, $2783
	ld hl, rBLOCK_VISIBILITY
	ld c, $03
	call func_1776
	ldh a, [$ff00 + $f3]
	ld [rBLOCK_TYPE], a
	ld a, $03
	call func_2673
	xor a
	ldh [$ff00 + $f3], a
	ld a, $db
	ldh [$ff00 + $40], a
	ld a, $bb
	ldh [rCOUNTDOWN], a
	ld a, $2f
	ldh [rGAME_STATUS], a
	ld a, $10
	ld [$dfe8], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld hl, rNEXT_BLOCK_VISIBILITY
	ld [hl], $00
	ld l, $20
	ld [hl], $00
	ld a, $a0
	ldh [rCOUNTDOWN], a
	ld a, $30
	ldh [rGAME_STATUS], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	jr z, l_1370
	call func_13fa
	ret

l_1370:
	ld a, $31
	ldh [rGAME_STATUS], a
	ld a, $80
	ldh [rCOUNTDOWN], a
	ld a, $2f
	call func_1fd7
	ret
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, l_13b1
	ld a, $0a
	ldh [rCOUNTDOWN], a
	ld hl, rBLOCK_Y
	dec [hl]
	ld a, [hl]
	cp $6a
	jr nz, l_13b1
	ld hl, rNEXT_BLOCK_VISIBILITY
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
	ldh [rGAME_STATUS], a
	ld a, $04
	ld [$dff8], a
	ret

l_13b1:
	call func_13fa
	ret
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, l_13cf
	ld a, $0a
	ldh [rCOUNTDOWN], a
	ld hl, rNEXT_BLOCK_Y
	dec [hl]
	ld l, $01
	dec [hl]
	ld a, [hl]
	cp $e0
	jr nz, l_13cf
	ld a, $33
	ldh [rGAME_STATUS], a
	ret

l_13cf:
	ldh a, [rCOUNTDOWN2]
	and a
	jr nz, l_13df
	ld a, $06
	ldh [rCOUNTDOWN2], a
	ld hl, rNEXT_BLOCK_TYPE
	ld a, [hl]
	xor $01
	ld [hl], a

l_13df:
	ld a, $03
	call func_2673
	ret
	call WAIT_FOR_VBLANK
	call COPY_IN_GAME_TILES
	call Sound_Init
	call func_2293
	ld a, $93
	ldh [$ff00 + $40], a
	ld a, $10
	ldh [rGAME_STATUS], a
	ret


func_13fa:
	ldh a, [rCOUNTDOWN2]
	and a
	ret nz
	ld a, $0a
	ldh [rCOUNTDOWN2], a
	ld a, $03
	ld [$dff8], a
	ld b, $02
	ld hl, rNEXT_BLOCK_VISIBILITY

l_140c:
	ld a, [hl]
	xor $80
	ld [hl], a
	ld l, $20
	dec b
	jr nz, l_140c
	ld a, $03
	call func_2673
	ret

	db $C2, $CA, $CA, $CA, $CA, $CA, $CA, $C3, $CB, $58, $48, $48
	db $48, $48, $C8, $73, $73, $73, $73, $73, $73, $C9, $74, $74
	db $74, $74, $74, $74

func_1437:
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
	ldh [rSB], a
	ldh [rSC], a
	ldh [$ff00 + $0f], a


func_144f:
	call WAIT_FOR_VBLANK
	call COPY_IN_GAME_TILES
	ld de, $4cd7
	call COPY_TILEMAP
	call CLEAR_OAM_DATA
	ld hl, rBLOCK_VISIBILITY
	ld de, $26cf
	ld c, $02
	call func_1776
	ld de, rBLOCK_Y
	call func_148d
	ldh a, [$ff00 + $c0]
	ld e, $12
	ld [de], a
	inc de
	cp $37
	ld a, $1c
	jr z, l_147d
	ld a, $1d

l_147d:
	ld [de], a
	call func_2671
	call func_1517
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $0e
	ldh [rGAME_STATUS], a
	ret


func_148d:
	ld a, $01
	ld [$dfe0], a


func_1492:
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


func_14b0:
	ld de, rBLOCK_VISIBILITY
	call func_1766
	ld hl, $ffc1
	ld a, [hl]
	bit 3, b
	jp nz, l_1563
	bit 0, b
	jp nz, l_1563
	bit 1, b
	jr nz, l_1509

l_14c8:
	inc e
	bit 4, b
	jr nz, l_14f3
	bit 5, b
	jr nz, l_14fe
	bit 6, b
	jr nz, l_14eb
	bit 7, b
	jp z, l_155f
	cp $1e
	jr nc, l_14e7
	add a, $02

l_14e0:
	ld [hl], a
	call func_148d
	call func_1517

l_14e7:
	call func_2671
	ret

l_14eb:
	cp $1e
	jr c, l_14e7
	sub a, $02
	jr l_14e0

l_14f3:
	cp $1d
	jr z, l_14e7
	cp $1f
	jr z, l_14e7
	inc a
	jr l_14e0

l_14fe:
	cp $1c
	jr z, l_14e7
	cp $1e
	jr z, l_14e7
	dec a
	jr l_14e0

l_1509:
	push af
	ldh a, [rPLAYERS]
	and a
	jr z, l_1512
	pop af
	jr l_14c8

l_1512:
	pop af
	ld a, $0e
	jr l_1572


func_1517:
	ldh a, [$ff00 + $c1]
	sub a, $17
	cp $08
	jr nz, l_1521
	ld a, $ff

l_1521:
	ld [$dfe8], a
	ret
	ld de, rNEXT_BLOCK_VISIBILITY
	call func_1766
	ld hl, $ffc0
	ld a, [hl]
	bit 3, b
	jr nz, l_1563
	bit 0, b
	jr nz, l_1577
	inc e
	inc e
	bit 4, b
	jr nz, l_154b
	bit 5, b
	jr z, l_155f
	cp $37
	jr z, l_155f
	ld a, $37
	ld b, $1c
	jr l_1553

l_154b:
	cp $77
	jr z, l_155f
	ld a, $77
	ld b, $1d

l_1553:
	ld [hl], a
	push af
	ld a, $01
	ld [$dfe0], a
	pop af
	ld [de], a
	inc de
	ld a, b

l_155e:
	ld [de], a

l_155f:
	call func_2671
	ret

l_1563:
	ld a, $02
	ld [$dfe0], a
	ldh a, [$ff00 + $c0]
	cp $37
	ld a, $10
	jr z, l_1572
	ld a, $12

l_1572:
	ldh [rGAME_STATUS], a
	xor a
	jr l_155e

l_1577:
	ld a, $0f
	jr l_1572
	call WAIT_FOR_VBLANK
	ld de, $4e3f
	call COPY_TILEMAP
	call func_18fc
	call CLEAR_OAM_DATA
	ld hl, rBLOCK_VISIBILITY
	ld de, $26db
	ld c, $01
	call func_1776
	ld de, rBLOCK_Y
	ldh a, [rLEVEL_A]
	ld hl, $1615
	call func_174e
	call func_2671
	call func_1795
	call func_18ca
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $11
	ldh [rGAME_STATUS], a
	ldh a, [$ff00 + $c7]
	and a
	jr nz, l_15ba
	call func_1517
	ret

l_15ba:
	ld a, $15

l_15bc:
	ldh [rGAME_STATUS], a
	ret
	ld de, rBLOCK_VISIBILITY
	call func_1766
	ld hl, $ffc2
	ld a, $0a
	bit 3, b
	jr nz, l_15bc
	bit 0, b
	jr nz, l_15bc
	ld a, $08
	bit 1, b
	jr nz, l_15bc
	ld a, [hl]
	bit 4, b
	jr nz, l_15f1
	bit 5, b
	jr nz, l_1607
	bit 6, b
	jr nz, l_160d
	bit 7, b
	jr z, l_1603
	cp $05
	jr nc, l_1603
	add a, $05
	jr l_15f6

l_15f1:
	cp $09
	jr z, l_1603
	inc a

l_15f6:
	ld [hl], a
	ld de, rBLOCK_Y
	ld hl, $1615
	call func_174e
	call func_1795

l_1603:
	call func_2671
	ret

l_1607:
	and a
	jr z, l_1603
	dec a
	jr l_15f6

l_160d:
	cp $05
	jr c, l_1603
	sub a, $05
	jr l_15f6

	db $40, $30, $40, $40, $40, $50, $40, $60, $40, $70, $50, $30,
	db $50, $40, $50, $50, $50, $60, $50, $70

	call WAIT_FOR_VBLANK
	ld de, $4fa7
	call COPY_TILEMAP
	call CLEAR_OAM_DATA
	ld hl, rBLOCK_VISIBILITY
	ld de, $26e1
	ld c, $02
	call func_1776
	ld de, rBLOCK_Y
	ldh a, [$ff00 + $c3]
	ld hl, $16d2
	call func_174e
	ld de, rNEXT_BLOCK_Y
	ldh a, [rINITIAL_HEIGHT]
	ld hl, $1741
	call func_174e
	call func_2671
	call func_17af
	call func_18ca
	ld a, $d3
	ldh [$ff00 + $40], a
	ld a, $13
	ldh [rGAME_STATUS], a
	ldh a, [$ff00 + $c7]
	and a
	jr nz, l_1670
	call func_1517
	ret

l_1670:
	ld a, $15

l_1672:
	ldh [rGAME_STATUS], a
	ret

l_1675:
	ldh [rGAME_STATUS], a
	xor a
	ld [de], a
	ret
	ld de, rBLOCK_VISIBILITY
	call func_1766
	ld hl, $ffc3
	ld a, $0a
	bit 3, b
	jr nz, l_1675
	ld a, $14
	bit 0, b
	jr nz, l_1675
	ld a, $08
	bit 1, b
	jr nz, l_1675
	ld a, [hl]
	bit 4, b
	jr nz, l_16ae
	bit 5, b
	jr nz, l_16c4
	bit 6, b
	jr nz, l_16ca
	bit 7, b
	jr z, l_16c0
	cp $05
	jr nc, l_16c0
	add a, $05
	jr l_16b3

l_16ae:
	cp $09
	jr z, l_16c0
	inc a

l_16b3:
	ld [hl], a
	ld de, rBLOCK_Y
	ld hl, $16d2
	call func_174e
	call func_17af

l_16c0:
	call func_2671
	ret

l_16c4:
	and a
	jr z, l_16c0
	dec a
	jr l_16b3

l_16ca:
	cp $05
	jr c, l_16c0
	sub a, $05
	jr l_16b3

	db $40, $18, $40, $28, $40, $38, $40, $48, $40, $58, $50, $18
	db $50, $28, $50, $38, $50, $48, $50, $58

l_16e6:
	ldh [rGAME_STATUS], a
	xor a
	ld [de], a
	ret
	ld de, rNEXT_BLOCK_VISIBILITY
	call func_1766
	ld hl, $ffc4
	ld a, $0a
	bit 3, b
	jr nz, l_16e6
	bit 0, b
	jr nz, l_16e6
	ld a, $13
	bit 1, b
	jr nz, l_16e6
	ld a, [hl]
	bit 4, b
	jr nz, l_171d
	bit 5, b
	jr nz, l_1733
	bit 6, b
	jr nz, l_1739
	bit 7, b
	jr z, l_172f

l_1715:
	cp $03

l_1717:
	jr nc, l_172f

l_1719:
	add a, $03
	jr l_1722

l_171d:
	cp $05
	jr z, l_172f
	inc a

l_1722:
	ld [hl], a
	ld de, rNEXT_BLOCK_Y
	ld hl, $1741
	call func_174e
	call func_17af

l_172f:
	call func_2671
l_1731:
	ret

l_1733:
	and a
	jr z, l_172f
	dec a
	jr l_1722

l_1739:
	cp $03
	jr c, l_172f
	sub a, $03
	jr l_1722
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


func_174e:
	push af
	ld a, $01
	ld [$dfe0], a
	pop af


func_1755:
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


func_1766:
	ldh a, [rBUTTON_HIT]
	ld b, a
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld a, $10
	ldh [rCOUNTDOWN], a
	ld a, [de]
	xor $80
	ld [de], a
	ret


func_1776:
	push hl
	ld b, $06

l_1779:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, l_1779
	pop hl
	ld a, $10
	add a, l
	ld l, a
	dec c
	jr nz, $1776
	ld [hl], $80
	ret


CLEAR_OAM_DATA::
	xor a
	ld hl, $c000
	ld b, $a0
.loop_16:
	ldi [hl], a
	dec b
	jr nz, .loop_16
	ret


func_1795:
	call func_18fc
	ldh a, [rLEVEL_A]
	ld hl, $d654
	ld de, $001b

l_17a0:
	and a
	jr z, l_17a7
	dec a
	add hl, de
	jr l_17a0

l_17a7:
	inc hl
	inc hl
	push hl
	pop de
	call func_1800
	ret


func_17af:
	call func_18fc
	ldh a, [$ff00 + $c3]
	ld hl, $d000
	ld de, $00a2

l_17ba:
	and a
	jr z, l_17c1
	dec a
	add hl, de
	jr l_17ba

l_17c1:
	ldh a, [rINITIAL_HEIGHT]
	ld de, $001b

l_17c6:
	and a
	jr z, l_17cd
	dec a
	add hl, de
	jr l_17c6

l_17cd:
	inc hl
	inc hl
	push hl
	pop de
	call func_1800
	ret


func_17d5:
	ld b, $03

l_17d7:
	ld a, [hl]
	and $f0
	jr nz, l_17e7
	inc e
	ldd a, [hl]
	and $0f
	jr nz, l_17f1
	inc e
	dec b
	jr nz, l_17d7
	ret

l_17e7:
	ld a, [hl]
	and $f0
	swap a
	ld [de], a
	inc e
	ldd a, [hl]
	and $0f

l_17f1:
	ld [de], a
	inc e
	dec b
	jr nz, l_17e7
	ret


func_17f7:
	ld b, $03


func_17f9:
	ldd a, [hl]
	ld [de], a
	dec de
	dec b
	jr nz, $17f9
	ret


func_1800:
	ld a, d
	ldh [$ff00 + $fb], a
	ld a, e
	ldh [$ff00 + $fc], a
	ld c, $03

l_1808:
	ld hl, $c0a2
	push de
	ld b, $03

l_180e:
	ld a, [de]
	sub a, [hl]
	jr c, l_1822
	jr nz, l_1819
	dec l
	dec de
	dec b
	jr nz, l_180e

l_1819:
	pop de
	inc de
	inc de
	inc de
	dec c
	jr nz, l_1808
	jr l_1880

l_1822:
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

l_1834:
	dec c
	jr z, l_183c
	call func_17f7
	jr l_1834

l_183c:
	ld hl, $c0a2
	ld b, $03

l_1841:
	ldd a, [hl]
	ld [de], a
	dec e
	dec b
	jr nz, l_1841
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

l_1858:
	dec c
	jr z, l_1862
	ld b, $06
	call func_17f9
	jr l_1858

l_1862:
	ld a, $60
	ld b, $05

l_1866:
	ld [de], a
	dec de
	dec b
	jr nz, l_1866
	ld a, $0a
	ld [de], a
	ld a, d
	ldh [$ff00 + $c9], a
	ld a, e
	ldh [$ff00 + $ca], a
	xor a
	ldh [rCLEAR_PROGRESS], a
	ldh [$ff00 + $c6], a
	ld a, $01
	ld [$dfe8], a
	ldh [$ff00 + $c7], a

l_1880:
	ld de, $c9ac
	ldh a, [$ff00 + $fb]
	ld h, a
	ldh a, [$ff00 + $fc]
	ld l, a
	ld b, $03

l_188b:
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
	jr nz, l_188b
	dec hl
	dec hl
	ld b, $03
	ld de, $c9a4

l_18aa:
	push de
	ld c, $06

l_18ad:
	ldi a, [hl]
	and a
	jr z, l_18b6
	ld [de], a
	inc de
	dec c
	jr nz, l_18ad

l_18b6:
	pop de
	push hl
	ld hl, $0020
	add hl, de
	push hl
	pop de
	pop hl
	dec b
	jr nz, l_18aa
	call func_2651
	ld a, $01
	ldh [$ff00 + $e8], a
	ret


func_18ca:
	ldh a, [$ff00 + $e8]
	and a
	ret z
	ld hl, $99a4
	ld de, $c9a4
	ld c, $06
l_18d6:
	push hl
l_18d7:
	ld b, $06
l_18d9:
	ld a, [de]
	ldi [hl], a
	inc e
	dec b
	jr nz, l_18d9
	inc e
	inc l
	inc e
	inc l
	dec c
	jr z, l_18f7
	bit 0, c
	jr nz, l_18d7
	pop hl
	ld de, $0020
	add hl, de
	push hl
	pop de
	ld a, $30
	add a, d
	ld d, a
	jr l_18d6
l_18f7:
	pop hl
func_18f8:
	xor a
	ldh [$ff00 + $e8], a
	ret


func_18fc:
	ld hl, $c9a4
	ld de, $0020
	ld a, $60
	ld c, $03

l_1906:
	ld b, $0e
	push hl

l_1909:
	ldi [hl], a
	dec b
	jr nz, l_1909
	pop hl
	add hl, de
	dec c
	jr nz, l_1906
	ret
	ldh a, [$ff00 + $c8]
	ld hl, $99e4
	ld de, $ffe0

l_191b:
	dec a
	jr z, l_1921
	add hl, de
	jr l_191b

l_1921:
	ldh a, [$ff00 + $c6]
	ld e, a
	ld d, $00
	add hl, de
	ldh a, [$ff00 + $c9]
	ld d, a
	ldh a, [$ff00 + $ca]
	ld e, a
	ldh a, [rCOUNTDOWN]
	and a
	jr nz, l_1944
	ld a, $07
	ldh [rCOUNTDOWN], a
	ldh a, [rCLEAR_PROGRESS]
	xor $01
	ldh [rCLEAR_PROGRESS], a
	ld a, [de]
	jr z, l_1941
	ld a, $2f

l_1941:
	call func_19fe

l_1944:
	ldh a, [rBUTTON_HIT]
	ld b, a
	ldh a, [rBUTTON_DOWN]
	ld c, a
	ld a, $17
	bit 6, b
	jr nz, l_1987
	bit 6, c
	jr nz, l_197f
	bit 7, b
	jr nz, l_19b0
	bit 7, c
	jr nz, l_19a8
	bit 0, b
	jr nz, l_19cc
	bit 1, b
	jp nz, l_19ee
	bit 3, b
	ret z

l_1968:
	ld a, [de]
	call func_19fe
	call func_1517
	xor a
	ldh [$ff00 + $c7], a
	ldh a, [$ff00 + $c0]
	cp $37
	ld a, $11
	jr z, l_197c
	ld a, $13

l_197c:
	ldh [rGAME_STATUS], a
	ret

l_197f:
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

l_1987:
	ldh [$ff00 + $aa], a
	ld b, $26
	ldh a, [rHARD_MODE]
	and a
	jr z, l_1992
	ld b, $27

l_1992:
	ld a, [de]
	cp b
	jr nz, l_19a0
	ld a, $2e

l_1998:
	inc a

l_1999:
	ld [de], a
	ld a, $01
	ld [$dfe0], a
	ret

l_19a0:
	cp $2f
	jr nz, l_1998
	ld a, $0a
	jr l_1999

l_19a8:
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

l_19b0:
	ldh [$ff00 + $aa], a
	ld b, $26
	ldh a, [rHARD_MODE]
	and a
	jr z, l_19bb
	ld b, $27

l_19bb:
	ld a, [de]
	cp $0a
	jr nz, l_19c5
	ld a, $30

l_19c2:
	dec a
	jr l_1999

l_19c5:
	cp $2f
	jr nz, l_19c2
	ld a, b
	jr l_1999

l_19cc:
	ld a, [de]
	call func_19fe
	ld a, $02
	ld [$dfe0], a
	ldh a, [$ff00 + $c6]
	inc a
	cp $06
	jr z, l_1968
	ldh [$ff00 + $c6], a
	inc de
	ld a, [de]
	cp $60
	jr nz, l_19e7
	ld a, $0a
	ld [de], a

l_19e7:
	ld a, d
	ldh [$ff00 + $c9], a
	ld a, e
	ldh [$ff00 + $ca], a
	ret

l_19ee:
	ldh a, [$ff00 + $c6]
	and a
	ret z
	ld a, [de]
	call func_19fe
	ldh a, [$ff00 + $c6]
	dec a
	ldh [$ff00 + $c6], a
	dec de
	jr l_19e7


func_19fe:
	ld b, a


func_19ff:
	ldh a, [$ff00 + $41]
	and $03
	jr nz, $19ff
	ld [hl], b
	ret
	call WAIT_FOR_VBLANK
	xor a
	ld [rNEXT_BLOCK_VISIBILITY], a
	ldh [rBLOCK_STATUS], a
	ldh [rCLEAR_PROGRESS], a
	ldh [$ff00 + $9b], a
	ldh [$ff00 + $fb], a
	ldh [rLINES_CLEARED2], a
	ld a, $2f
	call func_1fd7
	call func_1ff2
	call func_2651
	xor a
	ldh [rROW_UPDATE], a
	call CLEAR_OAM_DATA
	ldh a, [$ff00 + $c0]
	ld de, $3ff7
	ld hl, $ffc3
	cp $77
	ld a, $50
	jr z, l_1a3f
	ld a, $f1
	ld hl, $ffc2
	ld de, $3e8f

l_1a3f:
	push de
	ldh [$ff00 + $e6], a
	ld a, [hl]
	ldh [$ff00 + $a9], a
	call COPY_TILEMAP
	pop de
	ld hl, $9c00
	call COPY_TILEMAP_B
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
	ldh a, [rHARD_MODE]
	and a
	jr z, l_1a71
	inc hl
	ld [hl], $27
	ld h, $98
	ld [hl], $27

l_1a71:
	ld hl, rBLOCK_VISIBILITY
	ld de, $26bf
	call func_26b6
	ld hl, rNEXT_BLOCK_VISIBILITY
	ld de, $26c7
	call func_26b6
	ld hl, $9951
	ldh a, [$ff00 + $c0]
	cp $77
	ld a, $25
	jr z, l_1a8f
	xor a

l_1a8f:
	ldh [rLINES_CLEARED1], a
	and $0f
	ldd [hl], a
	jr z, l_1a98
	ld [hl], $02

l_1a98:
	call func_1ae8
	ld a, [rHIDE_NEXT_BLOCK]
	and a
	jr z, l_1aa6
	ld a, $80
	ld [rNEXT_BLOCK_VISIBILITY], a

l_1aa6:
	call func_2007
	call func_2007
	call func_2007
	call func_2683
	xor a
	ldh [$ff00 + $a0], a
	ldh a, [rGAME_TYPE]
	cp GAME_TYPE_B
	jr nz, l_1ae0
	ld a, $34
	ldh [rGRAVITY], a
	ldh a, [rINITIAL_HEIGHT]
	ld hl, $98b0
	ld [hl], a
	ld h, $9c
	ld [hl], a
	and a
	jr z, l_1ae0
	ld b, a
	ldh a, [rDEMO_GAME]
	and a
	jr z, l_1ad6
	call func_1b1b
	jr l_1ae0

l_1ad6:
	ld a, b
	ld de, $ffc0
	ld hl, $9a02
	call func_1b68

l_1ae0:
	ld a, $d3
	ldh [$ff00 + $40], a
	xor a
	ldh [rGAME_STATUS], a
	ret

func_1ae8:
	ldh a, [$ff00 + $a9]
	ld e, a
	ldh a, [rHARD_MODE]
	and a
	jr z, l_1afa
	ld a, $0a
	add a, e
	cp $15
	jr c, l_1af9
	ld a, $14

l_1af9:
	ld e, a

l_1afa:
	ld hl, $1b06
	ld d, $00
	add hl, de
	ld a, [hl]
	ldh [rGRAVITY], a
	ldh [$ff00 + $9a], a
	ret
	
	db $34, $30, $2C, $28, $24, $20, $1B, $15, $10, $0A, $09, $08
	db $07, $06, $05, $05, $04, $04, $03, $03, $02

func_1b1b:
	ld hl, $99c2
	ld de, $1b40
	ld c, $04

l_1b23:
	ld b, $0a
	push hl

l_1b26:
	ld a, [de]
	ld [hl], a

l_1b28:
	push hl
	ld a, h
	add a, $30
	ld h, a
	ld a, [de]
	ld [hl], a

l_1b2f:
	pop hl
	inc l
	inc de
	dec b
	jr nz, l_1b26

l_1b35:
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	dec c
	jr nz, l_1b23
	ret

	db $85, $2F, $82, $86, $83, $2F, $2F, $80, $82, $85, $2F, $82
	db $84, $82, $83, $2F, $83, $2F, $87, $2F, $2F, $85, $2F, $83
	db $2F, $86, $82, $80, $81, $2F, $83, $2F, $86, $83, $2F, $85
	db $2F, $85, $2F, $2F

func_1b68:
	ld b, a

l_1b69:
	dec b
	jr z, l_1b6f
	add hl, de
	jr l_1b69

l_1b6f:
	ldh a, [$ff00 + $04]
	ld b, a

l_1b72:
	ld a, $80

l_1b74:
	dec b
	jr z, l_1b7f
	cp $80
	jr nz, l_1b72
	ld a, $2f
	jr l_1b74

l_1b7f:
	cp $2f
	jr z, l_1b8b
	ldh a, [$ff00 + $04]
	and $07
	or $80
	jr l_1b8d

l_1b8b:
	ldh [$ff00 + $a0], a

l_1b8d:
	push af
	ld a, l
	and $0f
	cp $0b
	jr nz, l_1ba0
	ldh a, [$ff00 + $a0]
	cp $2f
	jr z, l_1ba0
	pop af
	ld a, $2f
	jr l_1ba1

l_1ba0:
	pop af

l_1ba1:
	ld [hl], a
	push hl
	push af
	ldh a, [rPLAYERS]
	and a
	jr nz, l_1bad
	ld de, $3000
	add hl, de

l_1bad:
	pop af
	ld [hl], a
	pop hl
	inc hl
	ld a, l
	and $0f
	cp $0c
	jr nz, l_1b6f
	xor a
	ldh [$ff00 + $a0], a
	ld a, h
	and $0f
	cp $0a
	jr z, l_1bc8

l_1bc2:
	ld de, $0016
	add hl, de
	jr l_1b6f

l_1bc8:
	ld a, l
	cp $2c
	jr nz, l_1bc2
	ret
	
SECTION "MENU_IN_GAME", ROM0 [$1BCE]
lbl_MENU_IN_GAME::
	call START_SELECT_HANDLER	; check if start or select was pressed
	
	ldh a, [rPAUSE_MENU]
	and a
	ret nz				; return if in pause menu
	
	call CHECK_DEMO_GAME_FINISHED
	call SIMULATE_BUTTON_PRESSES
	call USELESS_FUNCTION		; does nothing b/c depending on unused variable
	call func_24bb
	call func_209c
	call func_213e
	call func_25a1
	call func_224d
	call func_1f91
	call RESTORE_BUTTON_PRESSES
	ret

toggle_next_block_hidden:
	bit 2, a
	ret z
	ld a, [rHIDE_NEXT_BLOCK]
	xor $01
	ld [rHIDE_NEXT_BLOCK], a
	jr z, l_1c0a
	ld a, $80
l_1c03:
	ld [rNEXT_BLOCK_VISIBILITY], a
	call func_2696
	ret

l_1c0a:
	xor a
	jr l_1c03


START_SELECT_HANDLER::
	ldh a, [rBUTTON_DOWN]
	and $0f
	cp $0f
	jp z, Screen_Setup		; if buttons A, B, Select and Start are all pressed, reset game
	
	ldh a, [rDEMO_GAME]
	and a
	ret nz				; return now, if it is only a demo game
	
	ldh a, [rBUTTON_HIT]
	bit BTN_START, a
	jr z, toggle_next_block_hidden	; if Start is NOT pressed, check if Select is pressed
					
					; start button was pressed:
	ldh a, [rPLAYERS]
	and a
	jr nz, l_1c6a			; jump if 2 player mode
	
	ld hl, rLCDC
	
	ldh a, [rPAUSE_MENU]
	xor $01				; toggle start menu flag
	ldh [rPAUSE_MENU], a
	jr z, .unpausing			; jump if now unpausing
					
					; pausing now:
	set 3, [hl]			; select second background tile map at $9c00 (already contains the pause menu text)
	
	ld a, $01
	ld [rPAUSED], a			; set "just paused" flag
	
	ld hl, $994e			; start of line tiles on BG tile map 1
	ld de, $9d4e			; start of line tiles on BG tile map 2
	ld b, $04			; length of line tiles (4 numbers max, 9999 is highest line number)
.loop_18:
	ldh a, [rLCDC_STAT]
	and $03
	jr nz, .loop_18			; Loop until H-Blank reached (bits 0 and 1 of rLCDC_STAT not set)
	
	ldi a, [hl]
	ld [de], a			; Copy score tile from BG tile map 1 to BG tile map 2
	inc de
	dec b
	jr nz, .loop_18			; loop while there are still tiles left (and wait for H-Blank again)
	
	ld a, $80
.set_next_block_display:
	ld [rHIDE_NEXT_BLOCK_DISPLAY], a	; set the actual visibility of the next block display
.l_1c50:
	ld [rBLOCK_VISIBILITY], a
	
	call func_2683
	call func_2696
	ret

.unpausing:
	res 3, [hl]			; select first background tile map at $9800 (still contains the fallen blocks)
	ld a, $02
	ld [rPAUSED], a			; set the "just unpaused" flag
	
	ld a, [rHIDE_NEXT_BLOCK]
	and a
	jr z, .set_next_block_display	; jump if next block was not hidden before pausing
	
	xor a
	jr .l_1c50			; jump if next block was hidden before pausing

l_1c6a:
	ldh a, [$ff00 + $cb]
	cp $29
	ret nz
	ldh a, [$ff00 + $ab]
	xor $01
	ldh [$ff00 + $ab], a
	jr z, l_1caa
	ld a, $01
	ld [rPAUSED], a
	ldh a, [$ff00 + $d0]
	ldh [$ff00 + $f2], a
	ldh a, [rSB_DATA]
	ldh [$ff00 + $f1], a
	call func_1ccb
	ret


func_1c88:
	ldh a, [$ff00 + $ab]
	and a
	ret z
	ldh a, [$ff00 + $cc]
	jr z, l_1cc9
	xor a
	ldh [$ff00 + $cc], a
	ldh a, [$ff00 + $cb]
	cp $29
	jr nz, l_1ca1
	ld a, $94
	ldh [rSB_DATA], a
	ldh [rREQUEST_SERIAL_TRANSFER], a
	pop hl
	ret

l_1ca1:
	xor a
	ldh [rSB_DATA], a
	ldh a, [$ff00 + $d0]
	cp $94
	jr z, l_1cc9

l_1caa:
	ldh a, [$ff00 + $f2]
	ldh [$ff00 + $d0], a
	ldh a, [$ff00 + $f1]
	ldh [rSB_DATA], a
	ld a, $02
	ld [rPAUSED], a
	xor a
	ldh [$ff00 + $ab], a
	ld hl, $98ee
	ld b, $8e
	ld c, $05

l_1cc1:
	call func_19ff
	inc l
	dec c
	jr nz, l_1cc1
	ret

l_1cc9:
	pop hl
	ret


func_1ccb:
	ld hl, $98ee
	ld c, $05
	ld de, $1cdd

l_1cd3:
	ld a, [de]
	call func_19fe
	inc de
	inc l
	dec c
	jr nz, l_1cd3
	ret
	add hl, de
	ld a, [bc]
	ld e, $1c
	db $0E
	
lbl_MENU_GAME_OVER_INIT::
	ld a, $80
	ld [rBLOCK_VISIBILITY], a
	ld [rNEXT_BLOCK_VISIBILITY], a
	call func_2683
	call func_2696
	xor a
	ldh [rBLOCK_STATUS], a
	ldh [rCLEAR_PROGRESS], a
	call func_2293
	ld a, $87
	call func_1fd7
	ld a, $46
	ldh [rCOUNTDOWN], a
	ld a, $0d
	ldh [rGAME_STATUS], a
	ret
	
	
lbl_MENU_GAME_OVER::
	ldh a, [rBUTTON_HIT]
	bit 0, a
	jr nz, l_1d0f
	bit 3, a
	ret z
l_1d0f:
	xor a
	ldh [rROW_UPDATE], a
	ldh a, [rPLAYERS]
	and a
	ld a, $16
	jr nz, l_1d23
	ldh a, [$ff00 + $c0]
	cp $37
	ld a, $10
	jr z, l_1d23
	ld a, $12
l_1d23:
	ldh [rGAME_STATUS], a
	ret
	
	
lbl_MENU_TYPE_B_WON::
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld hl, $c802
	ld de, $2889
	call func_2804
	ldh a, [$ff00 + $c3]
	and a
	jr z, l_1d66
	ld de, $0040
	ld hl, $c827
	call func_1d83
	ld de, $0100
	ld hl, $c887
	call func_1d83
	ld de, $0300
	ld hl, $c8e7
	call func_1d83
	ld de, $1200
	ld hl, $c947
	call func_1d83
	ld hl, $c0a0
	ld b, $03
	xor a

l_1d62:
	ldi [hl], a
	dec b
	jr nz, l_1d62

l_1d66:
	ld a, $80
	ldh [rCOUNTDOWN], a
	ld a, $80
	ld [rBLOCK_VISIBILITY], a
	ld [rNEXT_BLOCK_VISIBILITY], a
	call func_2683
	call func_2696
	call Sound_Init
	ld a, $25
	ldh [rLINES_CLEARED1], a
	ld a, $0b
	ldh [rGAME_STATUS], a
	ret


func_1d83:
	push hl
	ld hl, $c0a0
	ld b, $03
	xor a

l_1d8b:
	ldi [hl], a
	dec b
	jr nz, l_1d8b
	ldh a, [$ff00 + $c3]
	ld b, a
	inc b

l_1d93:
	ld hl, $c0a0
	call func_0166
	dec b
	jr nz, l_1d93
	pop hl
	ld b, $03
	ld de, $c0a2

l_1da2:
	ld a, [de]
	and $f0
	jr nz, l_1db1
	ld a, [de]
	and $0f
	jr nz, l_1db7
	dec e
	dec b
	jr nz, l_1da2
	ret

l_1db1:
	ld a, [de]
	and $f0
	swap a
	ldi [hl], a

l_1db7:
	ld a, [de]
	and $0f
	ldi [hl], a
	dec e
	dec b
	jr nz, l_1db1
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld a, $01
	ld [$c0c6], a
	ld a, $05
	ldh [rCOUNTDOWN], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld hl, $c802
	ld de, $510f
	call func_2804
	call CLEAR_OAM_DATA
	ld hl, rBLOCK_VISIBILITY
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

l_1dfa:
	ld a, [de]
	ldi [hl], a
	ldi [hl], a
	inc de
	push de
	ld de, $000e
	add hl, de
	pop de
	dec b
	jr nz, l_1dfa
	ldh a, [rINITIAL_HEIGHT]
	cp $05
	jr nz, l_1e0f
	ld a, $09

l_1e0f:
	inc a
	ld b, a
	ld hl, rBLOCK_VISIBILITY
	ld de, $0010
	xor a

l_1e18:
	ld [hl], a
	add hl, de
	dec b
	jr nz, l_1e18
	ldh a, [rINITIAL_HEIGHT]
	add a, $0a
	ld [$dfe8], a
	ld a, $25
	ldh [rLINES_CLEARED1], a
	ld a, $1b
	ldh [rCOUNTDOWN], a
	ld a, $23
	ldh [rGAME_STATUS], a
	ret
	inc e
	rrca
	ld e, $32
	jr nz, l_1e4f
	ld h, $1d
	jr z, l_1e66

l_1e3b:
	ld a, $0a
	call func_2673
	ret
	ldh a, [rCOUNTDOWN]
	cp $14
	jr z, l_1e3b
	and a
	ret nz
	ld hl, $c20e
	ld de, $0010

l_1e4f:
	ld b, $0a

l_1e51:
	push hl
	dec [hl]
	jr nz, l_1e6a
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
	jr z, l_1e89

l_1e66:
	cp $51
	jr z, l_1e8f

l_1e6a:
	pop hl
	add hl, de
	dec b
	jr nz, l_1e51
	ld a, $0a
	call func_2673
	ld a, [$dfe9]
	and a
	ret nz
	call CLEAR_OAM_DATA
	ldh a, [rINITIAL_HEIGHT]
	cp $05
	ld a, $26
	jr z, l_1e86
	ld a, $05

l_1e86:
	ldh [rGAME_STATUS], a
	ret

l_1e89:
	dec l
	dec l
	ld [hl], $67
	jr l_1e6a

l_1e8f:
	dec l
	dec l
	ld [hl], $5d
	jr l_1e6a

l_1e95:
	xor a
	ld [$c0c6], a
	ld de, $c0c0
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	or l
	jp z, l_263a
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
	ldh [rCOUNTDOWN], a
	pop de
	ld hl, $c0a0
	call func_0166
	ld de, $c0a2
	ld hl, $9a25
	call func_2a3a
	ld a, $02
	ld [$dfe0], a
	ret

func_1ed7:
	ld a, [$c0c6]
	and a
	ret z
	ld a, [$c0c5]
	cp $04
	jr z, l_1e95
	ld de, $0040
	ld bc, $9823
	ld hl, $c0ac
	and a
	jr z, l_1f12
	ld de, $0100
	ld bc, $9883
	ld hl, $c0b1
	cp $01
	jr z, l_1f12
	ld de, $0300
	ld bc, $98e3
	ld hl, $c0b6
	cp $02
	jr z, l_1f12
	ld de, $1200
	ld bc, $9943
	ld hl, $c0bb

l_1f12:
	call func_25d9
	ret
	ldh a, [rBUTTON_HIT]
	and a
	ret z
	ld a, $02
	ldh [rGAME_STATUS], a
	ret
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ld a, $04
	ld [$dfe8], a
	ldh a, [rPLAYERS]
	and a
	jr z, l_1f37
	ld a, $3f
	ldh [rCOUNTDOWN], a
	ld a, $1b
	ldh [$ff00 + $cc], a
	jr l_1f6e

l_1f37:
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
	jr nz, l_1f6c
	ld hl, $c0a2
	ld a, [hl]
	ld b, $58
	cp $20
	jr nc, l_1f71
	inc b
	cp $15
	jr nc, l_1f71
	inc b
	cp $10
	jr nc, l_1f71

l_1f6c:
	ld a, $04

l_1f6e:
	ldh [rGAME_STATUS], a
	ret

l_1f71:
	ld a, b
	ldh [$ff00 + $f3], a
	ld a, $90
	ldh [rCOUNTDOWN], a
	ld a, $34
	ldh [rGAME_STATUS], a
	ret

func_1f7d:
	ld b, $08
	push hl

l_1f80:
	ld a, [de]
	ldi [hl], a
	inc de
	dec b
	jr nz, l_1f80
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	dec c
	jr nz, $1f7d
	ret


func_1f91:
	ldh a, [$ff00 + $c0]
	cp $37
	ret nz
	ldh a, [rGAME_STATUS]
	and a
	ret nz
	ldh a, [rROW_UPDATE]
	cp $05
	ret nz
	ld hl, $c0ac
	ld bc, $0005
	ld a, [hl]
	ld de, $0040
	and a
	jr nz, l_1fc3
	add hl, bc
	ld a, [hl]
	ld de, $0100
	and a
	jr nz, l_1fc3
	add hl, bc
	ld a, [hl]
	ld de, $0300
	and a
	jr nz, l_1fc3
	add hl, bc
	ld de, $1200
	ld a, [hl]
	and a
	ret z

l_1fc3:
	ld [hl], $00
	ldh a, [$ff00 + $a9]
	ld b, a
	inc b

l_1fc9:
	push bc
	push de
	ld hl, $c0a0
	call func_0166
	pop de
	pop bc
	dec b
	jr nz, l_1fc9
	ret


func_1fd7:
	push af
	ld a, $02
	ldh [rROW_UPDATE], a
	pop af


func_1fdd:
	ld hl, $c802
	ld c, $12
	ld de, $0020

l_1fe5:
	push hl
	ld b, $0a

l_1fe8:
	ldi [hl], a
	dec b
	jr nz, l_1fe8
	pop hl
	add hl, de
	dec c
	jr nz, l_1fe5
	ret


func_1ff2:
	ld hl, $cbc2
	ld de, $0016
	ld c, $02
	ld a, $2f

l_1ffc:
	ld b, $0a

l_1ffe:
	ldi [hl], a
	dec b
	jr nz, l_1ffe
	add hl, de
	dec c
	jr nz, l_1ffc
	ret


func_2007:
	ld hl, rBLOCK_VISIBILITY
	ld [hl], $00
	inc l
	ld [hl], $18
	inc l
	ld [hl], $3f
	inc l
	ld a, [rNEXT_BLOCK_TYPE]
	ld [hl], a
	and $fc
	ld c, a
	ldh a, [rDEMO_GAME]
	and a
	jr nz, l_2024
	ldh a, [rPLAYERS]
	and a
	jr z, l_2041
l_2024:
	ld h, $c3
	ldh a, [rDEMO_STATUS]
	ld l, a
	ld e, [hl]
	inc hl
	ld a, h
	cp $c4
	jr nz, l_2033
	ld hl, $c300
l_2033:
	ld a, l
	ldh [rDEMO_STATUS], a
	ldh a, [$ff00 + $d3]
	and a
	jr z, l_2065
	or $80
	ldh [$ff00 + $d3], a
	jr l_2065
l_2041:
	ld h, $03
l_2043:
	ldh a, [rDIV]
	ld b, a
l_2046:
	xor a
l_2047:
	dec b
	jr z, l_2054
	inc a
	inc a
	inc a
	inc a
	cp $1c
	jr z, l_2046
	jr l_2047

l_2054:
	ld d, a
	ldh a, [$ff00 + $ae]
	ld e, a
	dec h
	jr z, l_2062
	or d
	or c
	and $fc
	cp c
	jr z, l_2043

l_2062:
	ld a, d
	ldh [$ff00 + $ae], a

l_2065:
	ld a, e
	ld [rNEXT_BLOCK_TYPE], a
	call func_2696
	ldh a, [$ff00 + $9a]
	ldh [rGRAVITY], a
	ret

l_2071:
	ld a, [$c0c7]
	and a
	jr z, l_2083
	ldh a, [rBUTTON_HIT]
	and $b0
	cp $80
	jr nz, l_20a4
	xor a
	ld [$c0c7], a

l_2083:
	ldh a, [rCOUNTDOWN2]
	and a
	jr nz, l_20b1
	ldh a, [rBLOCK_STATUS]
	and a
	jr nz, l_20b1
	ldh a, [rROW_UPDATE]
	and a
	jr nz, l_20b1
	ld a, $03
	ldh [$ff00 + $a7], a
	ld hl, $ffe5
	inc [hl]
	jr l_20c2


func_209c:
	ldh a, [rBUTTON_DOWN]
	and $b0
	cp $80
	jr z, l_2071

l_20a4:
	ld hl, $ffe5
	ld [hl], $00
	ldh a, [rGRAVITY]
	and a
	jr z, l_20b5
	dec a
	ldh [rGRAVITY], a

l_20b1:
	call func_2683
	ret

l_20b5:
	ldh a, [rBLOCK_STATUS]
	cp $03
	ret z
	ldh a, [rROW_UPDATE]
	and a
	ret nz
	ldh a, [$ff00 + $9a]
	ldh [rGRAVITY], a

l_20c2:
	ld hl, rBLOCK_Y
	ld a, [hl]
	ldh [$ff00 + $a0], a
	add a, $08
	ld [hl], a
	call func_2683
	call func_2573
	and a
	ret z
	ldh a, [$ff00 + $a0]
	ld hl, rBLOCK_Y
	ld [hl], a
	call func_2683
	ld a, $01
	ldh [rBLOCK_STATUS], a
	ld [$c0c7], a
	ldh a, [$ff00 + $e5]
	and a
	jr z, l_2103
	ld c, a
	ldh a, [$ff00 + $c0]
	cp $37
	jr z, l_2126
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

l_2100:
	xor a
	ldh [$ff00 + $e5], a

l_2103:
	ld a, [rBLOCK_Y]
	cp $18
	ret nz
	ld a, [rBLOCK_X]
	cp $3f
	ret nz
	ld hl, $fffb
	ld a, [hl]
	cp $01
	jr nz, l_2124
	call Sound_Init
	ld a, $01
	ldh [rGAME_STATUS], a
	ld a, $02
	ld [$dff0], a
	ret

l_2124:
	inc [hl]
	ret

l_2126:
	xor a

l_2127:
	dec c
	jr z, l_212e
	inc a
	daa
	jr l_2127

l_212e:
	ld e, a
	ld d, $00
	ld hl, $c0a0
	call func_0166
	ld a, $01
	ld [$c0ce], a
	jr l_2100


func_213e:
	ldh a, [rBLOCK_STATUS]
	cp $02
	ret nz
	ld a, $02
	ld [$dff8], a
	xor a
	ldh [$ff00 + $a0], a
	ld de, rLINE_CLEAR_START
	ld hl, $c842
	ld b, $10

l_2153:
	ld c, $0a
	push hl

l_2156:
	ldi a, [hl]
	cp $2f
	jp z, l_21d8
	dec c
	jr nz, l_2156
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

l_216b:
	push de
	ld de, $0020
	add hl, de
	pop de
	dec b
	jr nz, l_2153
	ld a, $03
	ldh [rBLOCK_STATUS], a
	dec a
	ldh [rCOUNTDOWN], a
	ldh a, [$ff00 + $a0]
	and a
	ret z
	ld b, a
	ld hl, $ff9e
	ldh a, [$ff00 + $c0]
	cp $77
	jr z, l_219b
	ld a, b
	add a, [hl]
	daa
	ldi [hl], a
	ld a, $00
	adc a, [hl]
	daa
	ld [hl], a
	jr nc, l_21aa
	ld [hl], $99
	dec hl
	ld [hl], $99
	jr l_21aa

l_219b:
	ld a, [hl]
	or a
	sub a, b
	jr z, l_21db
	jr c, l_21db
	daa
	ld [hl], a
	and $f0
	cp $90
	jr z, l_21db

l_21aa:
	ld a, b
	ld c, $06
	ld hl, $c0ac
	ld b, $00
	cp $01
	jr z, l_21cf
	ld hl, $c0b1
	ld b, $01
	cp $02
	jr z, l_21cf
	ld hl, $c0b6
	ld b, $02
	cp $03
	jr z, l_21cf
	ld hl, $c0bb
	ld b, $04
	ld c, $07

l_21cf:
	inc [hl]
	ld a, b
	ldh [$ff00 + $dc], a
	ld a, c
	ld [$dfe0], a
	ret

l_21d8:
	pop hl
	jr l_216b

l_21db:
	xor a
	ldh [rLINES_CLEARED1], a
	jr l_21aa


; When rows are completed (and RAM values $c0a3 to $c0aa are set to indicate where)
; - Between every state change a countdown of 10 draw cycles (~ 0.15 secs) is run.
; - Function kicks off with rBLOCK_STATUS set to 3
; - rCLEAR_PROGRESS starts with 0 and is increased by 1 every run, until 7
; - on odd numbers the original blocks are displayed,
; - on even numbers dark blocks replace them
; - on 6, blocks are replaced by white blocks
; - when it reaches 7, rBLOCK_STATUS and rCLEAR_PROGRESS are set to 0, rROW_UPDATE is set to 1
; - Countdown is set to 13
clear_row_animation::
	ldh a, [rBLOCK_STATUS]
	cp $03
	ret nz				; Return if not right at end of block placement handling
	
	ldh a, [rCOUNTDOWN]
	and a
	ret nz				; Return if there is a countdown running
	
	ld de, rLINE_CLEAR_START
	ldh a, [rCLEAR_PROGRESS]
	bit 0, a			; Check if lowest bit of rCLEAR_PROGRESS is set
	jr nz, .unfill_block_rows	; Jump if rCLEAR_PROGRESS = 1,3,5 or 7
	
	ld a, [de]
	and a
	jr z, .nothing_to_clear		; Jump if line is clear	



; At RAM addresses $c0a3 to $c0aa lie the VRAM starting map addresses for the
; to be removed block lines. (The higher byte needs to be reduced by $30 first)
; i.e.: The second to last line is to be cleared, the first block on that row has
; the map address of $9A02. 
; It is therefore saved at $c0a3 as $ca02.

.fill_block_rows:
	sub a, $30		
	ld h, a				; Get the first block's address' high byte
	inc de
	ld a, [de]				
	ld l, a				; Get the first block's address' low byte
	ldh a, [rCLEAR_PROGRESS]	
	cp $06						
	ld a, $8c			
	jr nz, .dark_blocks		; if the clearing progress is in state 6 (= almost done)
	ld a, $2f			; fill line with white blocks (tile 2f)
.dark_blocks:				; otherwise use dark blocks (tile 8c)
	ld c, $0a			; 10 = width of tetris block line		
.loop_10:				
	ldi [hl], a			; fill whole line of tile map with chosen block
	dec c				
	jr nz, .loop_10			
	inc de
	ld a, [de]
	and a
	jr nz, .fill_block_rows		; check if another line needs to be cleared, then loop	
.increase_clear_progress:
	ldh a, [rCLEAR_PROGRESS]
	inc a
	ldh [rCLEAR_PROGRESS], a	; go to next clearing state (different block filling)
	cp $07
	jr z, .fill_state_7
	ld a, $0a
	ldh [rCOUNTDOWN], a
	ret

.fill_state_7:
	xor a
	ldh [rCLEAR_PROGRESS], a
	ld a, $0d
	ldh [rCOUNTDOWN], a
	ld a, $01
	ldh [rROW_UPDATE], a
.clear_block_status:
	xor a
	ldh [rBLOCK_STATUS], a
	ret

.unfill_block_rows:
	ld a, [de]	; ([de] still points to the first block of the first line to be removed)
	ld h, a		
	sub a, $30	
	ld c, a		; set bc to the correct RAM location (where all tiles are saved)
	inc de
	ld a, [de]
	ld l, a		; set hl to the correct VRAM location (where the displayed tilemap is saved)
	ld b, $0a	; 10 = number of rows
.loop_11:
	ld a, [hl]
	push hl
	ld h, c
	ld [hl], a	; move all ten tiles from RAM to VRAM
	pop hl
	inc hl
	dec b
	jr nz, .loop_11
	
	inc de
	ld a, [de]
	and a
	jr nz, .unfill_block_rows	; check if another line needs to be restored, then loop
	jr .increase_clear_progress

.nothing_to_clear:
	call func_2007
	jr .clear_block_status


func_224d:
	ldh a, [rCOUNTDOWN]
	and a
	ret nz
	ldh a, [rROW_UPDATE]
	cp $01
	ret nz
	ld de, rLINE_CLEAR_START
	ld a, [de]

l_225a:
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	push de
	push hl
	ld bc, $ffe0
	add hl, bc
	pop de

l_2265:
	push hl
	ld b, $0a

l_2268:
	ldi a, [hl]
	ld [de], a
	inc de
	dec b
	jr nz, l_2268
	pop hl
	push hl
	pop de
	ld bc, $ffe0
	add hl, bc
	ld a, h
	cp $c7
	jr nz, l_2265
	pop de
	inc de
	ld a, [de]
	and a
	jr nz, l_225a
	ld hl, $c802
	ld a, $2f
	ld b, $0a

l_2287:
	ldi [hl], a
	dec b
	jr nz, l_2287
	call func_2293
	ld a, $02
	ldh [rROW_UPDATE], a
	ret


func_2293:
	ld hl, rLINE_CLEAR_START
	xor a
	ld b, $09

l_2299:
	ldi [hl], a
	dec b
	jr nz, l_2299
	ret

func_229e:
	ldh a, [rROW_UPDATE]
	cp $02
	ret nz
	ld hl, $9a22
	ld de, $ca22
	call COPY_ROW
	ret

func_22ad:
	ldh a, [rROW_UPDATE]
	cp $03
	ret nz
	ld hl, $9a02
	ld de, $ca02
	call COPY_ROW
	ret

func_22bc:
	ldh a, [rROW_UPDATE]
	cp $04
	ret nz
	ld hl, $99e2
	ld de, $c9e2
	call COPY_ROW
	ret

func_22cb:
	ldh a, [rROW_UPDATE]
	cp $05
	ret nz
	ld hl, $99c2
	ld de, $c9c2
	call COPY_ROW
	ret

func_22da:
	ldh a, [rROW_UPDATE]
	cp $06
	ret nz
	ld hl, $99a2
	ld de, $c9a2
	call COPY_ROW
	ret

func_22e9:
	ldh a, [rROW_UPDATE]
	cp $07
	ret nz
	ld hl, $9982
	ld de, $c982
	call COPY_ROW
	ret

func_22f8:
	ldh a, [rROW_UPDATE]
	cp $08
	ret nz
	ld hl, $9962
	ld de, $c962
	call COPY_ROW
	ldh a, [rPLAYERS]
	and a
	ldh a, [rGAME_STATUS]
	jr nz, l_2315
	and a
	ret nz

l_230f:
	ld a, $01
	ld [$dff8], a
	ret

l_2315:
	cp $1a
	ret nz
	ldh a, [$ff00 + $d4]
	and a
	jr z, l_230f
	ld a, $05
	ld [$dfe0], a
	ret

func_2323:
	ldh a, [rROW_UPDATE]
	cp $09
	ret nz
	ld hl, $9942
	ld de, $c942
	call COPY_ROW
	ret

func_2332:
	ldh a, [rROW_UPDATE]
	cp $0a
	ret nz
	ld hl, $9922
	ld de, $c922
	call COPY_ROW
	ret

func_2341:
	ldh a, [rROW_UPDATE]
	cp $0b
	ret nz
	ld hl, $9902
	ld de, $c902
	call COPY_ROW
	ret

func_2350:
	ldh a, [rROW_UPDATE]
	cp $0c
	ret nz
	ld hl, $98e2
	ld de, $c8e2
	call COPY_ROW
	ret

func_235f:
	ldh a, [rROW_UPDATE]
	cp $0d
	ret nz
	ld hl, $98c2
	ld de, $c8c2
	call COPY_ROW
	ret

func_236e:
	ldh a, [rROW_UPDATE]
	cp $0e
	ret nz
	ld hl, $98a2
	ld de, $c8a2
	call COPY_ROW
	ret

func_237d:
	ldh a, [rROW_UPDATE]
	cp $0f
	ret nz
	ld hl, $9882
	ld de, $c882
	call COPY_ROW
	ret

func_238c:
	ldh a, [rROW_UPDATE]
	cp $10
	ret nz
	ld hl, $9862
	ld de, $c862
	call COPY_ROW
	call func_244b
	ret

func_239e:
	ldh a, [rROW_UPDATE]
	cp $11
	ret nz
	ld hl, $9842
	ld de, $c842
	call COPY_ROW
	ld hl, $9c6d
	call func_243b
	ld a, $01
	ldh [$ff00 + $e0], a
	ret

func_23b7:
	ldh a, [rROW_UPDATE]
	cp $12		
	ret nz			; Return if not row 12 is to be copied
	ld hl, $9822		
	ld de, $c822
	call COPY_ROW
	ld hl, $986d
	call func_243b
	ret


func_23cc:
	ldh a, [rROW_UPDATE]
	cp $13
	ret nz
	ld [$c0c7], a
	ld hl, $9802
	ld de, $c802
	call COPY_ROW
	xor a
	ldh [rROW_UPDATE], a
	ldh a, [rPLAYERS]
	and a
	ldh a, [rGAME_STATUS]
	jr nz, l_242f
	and a
	ret nz
l_23e9:
	ld hl, $994e
	ld de, $ff9f
	ld c, $02
	ldh a, [rGAME_TYPE]
	cp GAME_TYPE_A
	jr z, l_23ff
	ld hl, $9950
	ld de, $ff9e
	ld c, $01
l_23ff:
	call func_2a3c
	ldh a, [rGAME_TYPE]
	cp GAME_TYPE_A
	jr z, l_242b
	ldh a, [rLINES_CLEARED1]
	and a
	jr nz, l_242b
	ld a, $64
	ldh [rCOUNTDOWN], a
	ld a, $02
	ld [$dfe8], a
	ldh a, [rPLAYERS]
	and a
	jr z, l_241e
	ldh [$ff00 + $d5], a
	ret

l_241e:
	ldh a, [$ff00 + $c3]
	cp $09
	ld a, $05
	jr nz, l_2428
	ld a, $22
l_2428:
	ldh [rGAME_STATUS], a
	ret

l_242b:
	call func_2007
	ret

l_242f:
	cp $1a
	ret nz
	ldh a, [$ff00 + $d4]
	and a
	jr z, l_23e9
	xor a
	ldh [$ff00 + $d4], a
	ret


func_243b:
	ldh a, [rGAME_STATUS]
	and a
	ret nz		; return if not in-game
	
	ldh a, [rGAME_TYPE]
	cp GAME_TYPE_A
	ret nz		; return if type B game
	
	ld de, $c0a2
	call func_2a36
	ret


func_244b:
	ldh a, [rGAME_STATUS]
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
	ldh a, [rLINES_CLEARED2]
	ld d, a
	and $f0
	ret nz
	ld a, d
	and $0f
	swap a
	ld d, a
	ldh a, [rLINES_CLEARED1]
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

l_247e:
	ld [hl], c
	ld h, $9c
	ld [hl], c
	ld a, b
	and $f0
	jr z, l_2494
	swap a
	ld c, a
	ld a, l
	cp $f0
	jr z, l_2494
	ld hl, $98f0
	jr l_247e

l_2494:
	ld a, $08
	ld [$dfe0], a
	call func_1ae8
	ret


func_249d:
	ld a, [hl]
	ld b, a
	and a
	ret z
	xor a

l_24a2:
	or a
	inc a
	daa
	dec b
	jr z, l_24aa
	jr l_24a2

l_24aa:
	ld b, a
	ret


COPY_ROW::
	ld b, $0a
.loop_17:
	ld a, [de]
	ld [hl], a
	inc l
	inc e
	dec b
	jr nz, .loop_17
	ldh a, [rROW_UPDATE]
	inc a
	ldh [rROW_UPDATE], a
	ret


func_24bb:
	ld hl, rBLOCK_VISIBILITY
	ld a, [hl]
	cp $80
	ret z				; return if there is no falling block (visible)
	
	ld l, $03
	ld a, [hl]			; = rBLOCK_TYPE
	ldh [$ff00 + $a0], a		; store current block type
	
	ldh a, [rBUTTON_HIT]
	ld b, a
	
	bit BTN_B, b
	jr nz, .rotate_B_button		; jump if button B was pressed
	
	bit BTN_A, b
	jr z, l_2509			; jump if anything BUT button A was pressed
					
					; Button A pressed:	
	ld a, [hl]
	and $03
	jr z, .block_variation_low_end	; jump if block type MOD 4 = 0 (lowest variation of block)
	
	dec [hl]			; change to lower variation (rotate clockwise)
	
	jr .rotation_finished

.block_variation_low_end:
	ld a, [hl]
	or $03
	ld [hl], a			; add 3 to the block variation (starting back at the highest variation)
	
	jr .rotation_finished

.rotate_B_button:
	ld a, [hl]
	and $03
	cp $03
	jr z, .block_variation_high_end	; jump if block type MOD 4 = 3 (highest variation of block)
	
	inc [hl]			; change to higher variation (rotate counter-clockwise)
	
	jr .rotation_finished

.block_variation_high_end:
	ld a, [hl]
	and $fc				; subtract 3 from block variation (starting back at lowest variation)
	ld [hl], a

.rotation_finished:
	ld a, $03
	ld [$dfe0], a
	
	call func_2683
	call func_2573
	
	and a
	jr z, l_2509
	
	xor a
	ld [$dfe0], a
	
	ld hl, rBLOCK_TYPE
	ldh a, [$ff00 + $a0]
	ld [hl], a
	
	call func_2683

l_2509:
	ld hl, rBLOCK_X
	ldh a, [rBUTTON_HIT]
	ld b, a
	ldh a, [rBUTTON_DOWN]
	ld c, a
	ld a, [hl]
	ldh [$ff00 + $a0], a
	bit 4, b
	ld a, $17
	jr nz, l_2527
	bit 4, c
	jr z, l_254c
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

l_2527:
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

l_253a:
	ld hl, rBLOCK_X
	xor a
	ld [$dfe0], a
	ldh a, [$ff00 + $a0]
	ld [hl], a
	call func_2683
	ld a, $01

l_2549:
	ldh [$ff00 + $aa], a
	ret
	

l_254c:
	bit 5, b
	ld a, $17
	jr nz, l_255e
	bit 5, c
	jr z, l_2549
	ldh a, [$ff00 + $aa]
	dec a
	ldh [$ff00 + $aa], a
	ret nz
	ld a, $09

l_255e:
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
	jr l_253a


func_2573:
	ld hl, $c010
	ld b, $04

l_2578:
	ldi a, [hl]
	ldh [$ff00 + $b2], a
	ldi a, [hl]
	and a
	jr z, l_2596
	ldh [$ff00 + $b3], a
	push hl
	push bc
	call func_29e3
	ld a, h
	add a, $30
	ld h, a
	ld a, [hl]
	cp $2f
	jr nz, l_259a
	pop bc
	pop hl
	inc l
	inc l
	dec b
	jr nz, l_2578

l_2596:
	xor a
	ldh [$ff00 + $9b], a
	ret

l_259a:
	pop bc
	pop hl
	ld a, $01
	ldh [$ff00 + $9b], a
	ret


func_25a1:
	ldh a, [rBLOCK_STATUS]
	cp $01
	ret nz
	ld hl, $c010
	ld b, $04

l_25ab:
	ldi a, [hl]
	ldh [$ff00 + $b2], a
	ldi a, [hl]
	and a
	jr z, l_25cf
	ldh [$ff00 + $b3], a
	push hl
	push bc
	call func_29e3
	push hl
	pop de
	pop bc
	pop hl

l_25bd:
	ldh a, [$ff00 + $41]
	and $03
	jr nz, l_25bd
	ld a, [hl]
	ld [de], a
	ld a, d
	add a, $30
	ld d, a
	ldi a, [hl]
	ld [de], a
	inc l
	dec b
	jr nz, l_25ab

l_25cf:
	ld a, $02
	ldh [rBLOCK_STATUS], a
	ld hl, rBLOCK_VISIBILITY
	ld [hl], $80
	ret


func_25d9:
	ld a, [$c0c6]
	cp $02
	jr z, l_2626
	push de
	ld a, [hl]
	or a
	jr z, l_2639
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
	jr z, l_25f7
	ld [bc], a

l_25f7:
	push bc
	ldh a, [$ff00 + $c3]
	ld b, a
	inc b

l_25fc:
	push hl
	call func_0166
	pop hl
	dec b
	jr nz, l_25fc
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

l_2618:
	push hl
	call func_0166
	pop hl
	dec b
	jr nz, l_2618
	ld a, $02
	ld [$c0c6], a
	ret

l_2626:
	ld de, $c0a2
	ld hl, $9a25
	call func_2a3a
	ld a, $02
	ld [$dfe0], a
	xor a
	ld [$c0c6], a
	ret

l_2639:
	pop de

l_263a:
	ld a, $21
	ldh [rCOUNTDOWN], a
	xor a
	ld [$c0c6], a
	ld a, [$c0c5]
	inc a
	ld [$c0c5], a
	cp $05
	ret nz
	ld a, $04
	ldh [rGAME_STATUS], a
	ret


func_2651:
	ld hl, $c0ac
	ld b, $1b
	xor a

l_2657:
	ldi [hl], a
	dec b
	jr nz, l_2657
	ld hl, $c0a0
	ld b, $03

l_2660:
	ldi [hl], a
	dec b
	jr nz, l_2660
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


func_2671:
	ld a, $02


func_2673:
	ldh [rAMOUNT_SPRITES_TO_DRAW], a
	xor a
	ldh [rOAM_TILE_ADDRESS_2], a
	ld a, $c0
	ldh [rOAM_TILE_ADDRESS_1], a
	ld hl, rBLOCK_VISIBILITY
	call func_2a89
	ret


func_2683:
	ld a, $01
	ldh [rAMOUNT_SPRITES_TO_DRAW], a
	ld a, $10
	ldh [rOAM_TILE_ADDRESS_2], a
	ld a, $c0
	ldh [rOAM_TILE_ADDRESS_1], a
	
	ld hl, rBLOCK_VISIBILITY
	call func_2a89
	ret


func_2696:
	ld a, $01
	ldh [rAMOUNT_SPRITES_TO_DRAW], a
	ld a, $20
	ldh [rOAM_TILE_ADDRESS_2], a
	ld a, $c0
	ldh [rOAM_TILE_ADDRESS_1], a
	ld hl, rNEXT_BLOCK_VISIBILITY
	call func_2a89
	ret


func_26a9:
	ld b, $20
	ld a, $8e
	ld de, $0020

l_26b0:
	ld [hl], a
	add hl, de
	dec b
	jr nz, l_26b0
	ret

func_26b6:
	ld a, [de]
	cp $ff
	ret z
	ldi [hl], a
	inc de
	jr $26b6

HBlank_Timer::
	reti

	;data $26BF - $2794 (incl.)
	db $00, $18, $3F, $00, $80, $00, $00, $FF, $00, $80, $8F, $00
	db $80, $00, $00, $FF, $00, $70, $37, $1C, $00, $00, $00, $38
	db $37, $1C, $00, $00, $00, $40, $34, $20, $00, $00, $00, $40
	db $1C, $20, $00, $00, $00, $40, $74, $20, $00, $00, $00, $40
	db $68, $21, $00, $00, $00, $78, $68, $21, $00, $00, $00, $60
	db $60, $2A, $80, $00, $00, $60, $72, $2A, $80, $20, $00, $68
	db $38, $3E, $80, $00, $00, $60, $60, $36, $80, $00, $00, $60
	db $72, $36, $80, $20, $00, $68, $38, $32, $80, $00, $00, $60
	db $60, $2E, $80, $00, $00, $68, $38, $3C, $80, $00, $00, $60
	db $60, $3A, $80, $00, $00, $68, $38, $30, $80, $00, $80, $3F
	db $40, $44, $00, $00, $80, $3F, $20, $4A, $00, $00, $80, $3F
	db $30, $46, $00, $00, $80, $77, $20, $48, $00, $00, $80, $87
	db $48, $4C, $00, $00, $80, $87, $58, $4E, $00, $00, $80, $67
	db $4D, $50, $00, $00, $80, $67, $5D, $52, $00, $00, $80, $8F
	db $88, $54, $00, $00, $80, $8F, $98, $55, $00, $00, $00, $5F
	db $57, $2C, $00, $00, $80, $80, $50, $34, $00, $00, $80, $80
	db $60, $34, $00, $20, $00, $6F, $57, $58, $00, $00, $80, $80
	db $55, $34, $00, $00, $80, $80, $5B, $34, $00, $20

Flush_BG1::
; Fill BG Map 1 entirely with value $2F

	ld hl, $9bff	; End of BG Map Data 1
func_2798:
	ld bc, $0400	; Size of BG Map Data 1
.loop_9:
	ld a, $2f
	ldd [hl], a
	dec bc
	ld a, b
	or c
	jr nz, .loop_9
	ret


; copy all tiles as specified in registers de (target), hl (source) and bc (length) 
COPY_TILES::
	ldi a, [hl]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, COPY_TILES
	ret


COPY_IN_GAME_TILES::
	call COPY_CHARACTERS
	ld bc, $00a0
	call COPY_TILES		; continue copying right after characters
	ld hl, $323f		; address of in-game tiles in memory
	ld de, $8300		; not starting at $8000 -> Keeping character tiles
	ld bc, $0d00
	call COPY_TILES		; Copy in-game tiles (blocks, walls, GUI, celebration screens)
	ret


; copy characters such as numbers, letters and .,-"
COPY_CHARACTERS::
	ld hl, $415f		; address of (black-white) character set in ROM
	ld bc, $0138		; length of data set
	ld de, $8000		; Starting address of tile data in VRAM
.loop_14:
	ldi a, [hl]
	ld [de], a
	inc de			; copy each byte at $415f twice into $8000,
	ld [de], a		; because characters are stored as only black and white
	inc de			; but the GB uses two bytes per character to allow for 4 colors
	dec bc
	ld a, b
	or c
	jr nz, .loop_14
	ret


COPY_TITLE_TILES::
	call COPY_CHARACTERS
	ld bc, $0da0		; length of symbol data set (starting right after characters)
	call COPY_TILES		; copy all title image tiles (picture of Moscow cathedral)
	ret
	
	
	ld bc, $1000


func_27e4:
	ld de, $8000
	call COPY_TILES
	ret


; Takes a ROM address (de) and copies the full tilemap into Tilemap A (starting at $9800)
COPY_TILEMAP::
	ld hl, $9800
	
; Allows for a unique tilemap starting address - is only ever used for Tilemap B (starting at $9C00)
COPY_TILEMAP_B::
	ld b, $12		; = full 18 rows of tiles
	
; Allows for unique tilemap and a custom number of rows (less than the full 18)
COPY_TILEMAP_FEWER_ROWS::
	push hl
	ld c, $14		; = full 20 columns of tiles
.loop_15:
	ld a, [de]
	ldi [hl], a
	inc de
	dec c
	jr nz, .loop_15
	
	pop hl
	push de
	ld de, $0020
	add hl, de		; Add $20 to target address, to skip area of tile map outside the window
	pop de
	dec b
	jr nz, COPY_TILEMAP_FEWER_ROWS
	ret


func_2804:
	ld b, $0a
	push hl

l_2807:
	ld a, [de]
	cp $ff
	jr z, l_281a
	ldi [hl], a
	inc de
	dec b
	jr nz, l_2807
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	jr $2804

l_281a:
	pop hl
	ld a, $02
	ldh [rROW_UPDATE], a
	ret



WAIT_FOR_VBLANK::
	ldh a, [rIE]
	ldh [rIE_TEMP], a	
	res 0, a		
	ldh [rIE], a		; turn off V-Blank interrupt
.loop_13:
	ldh a, [rLY]		; loop until in V-Blank area
	cp SCREEN_HEIGHT + 1
	jr nz, .loop_13
	
	ldh a, [rLCDC]
	and $7f
	ldh [rLCDC], a		; turn off LCDC (keep other settings in rLCDC)
	
	ldh a, [rIE_TEMP]
	ldh [rIE], a
	ret
	

	; data section $2839 - $29a5 incl.
data:
	db $2F, $2F, $11, $12, $1D, $2F, $2F, $2F, $2F, $2F, $29, $29
	db $29, $2F, $2F, $2F, $2F, $1C, $1D, $0A, $1B, $1D, $2F, $2F
	db $2F, $29, $29, $29, $29, $29, $2F, $2F, $2F, $2F, $2F, $1D
	db $18, $2F, $2F, $2F, $2F, $2F, $2F, $29, $29, $2F, $2F, $2F
	db $0C, $18, $17, $1D, $12, $17, $1E, $0E, $29, $29, $29, $29
	db $29, $29, $29, $29, $2F, $2F, $10, $0A, $16, $0E, $2F, $2F
	db $2F, $2F, $29, $29, $29, $29, $2F, $2F, $1C, $12, $17, $10
	db $15, $0E, $2F, $2F, $2F, $2F, $2F, $00, $2F, $26, $2F, $04
	db $00, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $00, $2F, $0D, $18, $1E, $0B, $15, $0E, $2F, $2F, $2F, $2F
	db $2F, $00, $2F, $26, $2F, $01, $00, $00, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $00, $2F, $1D, $1B, $12, $19
	db $15, $0E, $2F, $2F, $2F, $2F, $2F, $00, $2F, $26, $2F, $03
	db $00, $00, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $00, $2F, $1D, $0E, $1D, $1B, $12, $1C, $2F, $2F, $2F, $2F
	db $2F, $00, $2F, $26, $2F, $01, $02, $00, $00, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $00, $2F, $0D, $1B, $18, $19
	db $1C, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $00, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $29, $29, $29, $29, $29, $29, $29, $29, $29, $29
	db $1D, $11, $12, $1C, $2F, $1C, $1D, $0A, $10, $0E, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $00, $2F, $FF, $61, $62, $62
	db $62, $62, $62, $62, $63, $64, $2F, $2F, $2F, $2F, $2F, $2F
	db $65, $64, $2F, $10, $0A, $16, $0E, $2F, $65, $64, $2F, $AD
	db $AD, $AD, $AD, $2F, $65, $64, $2F, $18, $1F, $0E, $1B, $2F
	db $65, $64, $2F, $AD, $AD, $AD, $AD, $2F, $65, $66, $69, $69
	db $69, $69, $69, $69, $6A, $19, $15, $0E, $0A, $1C, $0E, $2F
	db $2F, $29, $29, $29, $29, $29, $29, $2F, $2F, $2F, $1D, $1B
	db $22, $2F, $2F, $2F, $2F, $2F, $29, $29, $29, $2F, $2F, $2F
	db $2F, $2F, $2F, $0A, $10, $0A, $12, $17, $27, $2F, $2F, $29
	db $29, $29, $29, $29, $2F


Read_Joypad::
	ld a, 1 << 5 	; select direction keys
	ldh [rJOYP], a
	rept 4
	ldh a, [rJOYP]	; poll buttons multiple times
	endr
	cpl		; reverse bits (as pressed buttons are shown as 0's)
	and $0f		; mask lower nibble
	swap a		; move it to higher nibble
	ld b, a		
	
	ld a, 1 << 4 	; select button keys
	ldh [rJOYP], a
	rept 10
	ldh a, [rJOYP]
	endr
	cpl
	and $0f
	or b		; In register A: lower nibble = buttons, higher nibble = directional keys
	
	ld c, a
	ldh a, [rBUTTON_DOWN]
	xor c			; XOR+AND gate (only true, if "false -> true",
	and c			; i.e. button pressed now, but wasn't pressed before)
	ldh [rBUTTON_HIT], a
	ld a, c
	ldh [rBUTTON_DOWN], a
	ld a, 1 << 5 | 1 << 4	; deselect both directional and button keys
	ldh [$ff00 + $00], a
	ret


func_29e3:  ; Shutdown routine?
	ldh a, [$ff00 + $b2]
	sub a, $10
	srl a
	srl a
	srl a
	ld de, $0000
	ld e, a
	ld hl, $9800
	ld b, $20

l_29f6:
	add hl, de
	dec b
	jr nz, l_29f6
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

l_2a18:
	rr d
	rr e
	dec b
	jr nz, l_2a18
	ld a, e
	sub a, $84
	and $fe
	rlca
	rlca
	add a, $08
	ldh [$ff00 + $b2], a
	ldh a, [$ff00 + $b4]
	and $1f
	rla
	rla
	rla
	add a, $08
	ldh [$ff00 + $b3], a
	ret

func_2a36:
	ldh a, [$ff00 + $e0]		; is $01 before the first block and shortly after a line clear
	and a
	ret z
func_2a3a:
	ld c, $03
func_2a3c:
	xor a
	ldh [$ff00 + $e0], a
l_2a3f:
	ld a, [de]
	ld b, a
	swap a
	and $0f
	jr nz, l_2a6f
	ldh a, [$ff00 + $e0]
	and a
	ld a, $00
	jr nz, l_2a50
	ld a, $2f
l_2a50:
	ldi [hl], a
	ld a, b
	and $0f
	jr nz, l_2a77
	ldh a, [$ff00 + $e0]
	and a
	ld a, $00
	jr nz, l_2a66
	ld a, $01
	cp c
	ld a, $00
	jr z, l_2a66
	ld a, $2f
l_2a66:
	ldi [hl], a
	dec e
	dec c
	jr nz, l_2a3f
	xor a
	ldh [$ff00 + $e0], a
	ret

l_2a6f:
	push af
	ld a, $01
	ldh [$ff00 + $e0], a
	pop af
	jr l_2a50

l_2a77:
	push af
	ld a, $01
	ldh [$ff00 + $e0], a
	pop af
	jr l_2a66
	ld a, $c0
	ldh [$ff00 + $46], a
	ld a, $28

l_2a85:
	dec a
	jr nz, l_2a85
	ret

func_2a89:
	ld a, h			
	ldh [rSPRITE_ORIGINAL_ADDRESS_1], a
	ld a, l
	ldh [rSPRITE_ORIGINAL_ADDRESS_2], a
	ld a, [hl]
	and a
	jr z, l_2ab0		; jmp if sprite is (supposed to be) visible
	
	cp $80
	jr z, l_2aae		; jmp if sprite is (supposed to be) invisible
	
l_2a97:
	ldh a, [rSPRITE_ORIGINAL_ADDRESS_1]
	ld h, a
	ldh a, [rSPRITE_ORIGINAL_ADDRESS_2]
	ld l, a
	ld de, $0010
	add hl, de
	ldh a, [rAMOUNT_SPRITES_TO_DRAW]
	dec a
	ldh [rAMOUNT_SPRITES_TO_DRAW], a
	ret z
	jr $2a89

l_2aa9:
	xor a
	ldh [rOAM_VISIBLE], a
	jr l_2a97

l_2aae:
	ldh [rOAM_VISIBLE], a
l_2ab0:
	ld b, $07
	ld de, $ff86

l_2ab5:
	ldi a, [hl]		; store current sprite info into $ff86 - $ff8d
	ld [de], a
	inc de
	dec b
	jr nz, l_2ab5
	
	ldh a, [rOAM_TILE_NO]	; = sprite index (block type)
	ld hl, $2b64		; list of addresses
	rlca			
	ld e, a
	ld d, $00
	add hl, de		; add sprite index * 2 to $2b64
	ld e, [hl]
	inc hl
	ld d, [hl]		; retrieve a memory address dependent on current sprite index (smallest is $2c20)
	ld a, [de]		
	ld l, a
	inc de
	ld a, [de]
	ld h, a			; retrieve a new memory address at the previously retrieved address (smallest is $2d58)
	inc de
	ld a, [de]
	ldh [$ff00 + $90], a	
	inc de
	ld a, [de]
	ldh [$ff00 + $91], a	; store also two further values in each $ff00 + $90 and $ff00 + $91
	ld e, [hl]
	inc hl
	ld d, [hl]		; retrieve a new memory address at the previously retrieved address (smallest is $31a9)

read_next_design_element:
	inc hl			; retrieve the sprite design of the sprite index, using tile numbers, $fe for nothing and $ff for end of block
	ldh a, [$ff00 + $8c]	; ?
	ldh [$ff00 + $94], a
	
	ld a, [hl]
	cp $ff
	jr z, l_2aa9		; jump if end of this sprite's design found 
	
	cp $fd			; (there is $fd during congratulation animation.)
	jr nz, l_2af4		; jump if not $fd
	
	ldh a, [$ff00 + $8c]
	xor $20
	ldh [$ff00 + $94], a
	
	inc hl
	ld a, [hl]		; read input byte after the $fd
	
	jr l_2af8

is_empty_design_element:
	inc de
	inc de			; skip two de bytes and read next design element
	jr read_next_design_element

l_2af4:
	cp $fe
	jr z, is_empty_design_element

l_2af8:
	ldh [rOAM_TILE_NO], a
	ldh a, [$ff00 + $87]
	ld b, a
	ld a, [de]
	ld c, a
	ldh a, [$ff00 + $8b]
	bit 6, a
	jr nz, l_2b0b
	
	ldh a, [$ff00 + $90]
	add a, b
	adc a, c
	jr l_2b15

l_2b0b:
	ld a, b
	push af
	ldh a, [$ff00 + $90]
	ld b, a
	pop af
	sub a, b
	sbc a, c
	sbc a, $08

l_2b15:
	ldh [rOAM_Y_POS], a
	ldh a, [$ff00 + $88]
	ld b, a
	inc de
	ld a, [de]
	inc de
	ld c, a
	ldh a, [$ff00 + $8b]
	bit 5, a
	jr nz, l_2b2a
	ldh a, [$ff00 + $91]
	add a, b
	adc a, c
	jr l_2b34

l_2b2a:
	ld a, b
	push af
	ldh a, [$ff00 + $91]
	ld b, a
	pop af
	sub a, b
	sbc a, c
	sbc a, $08

l_2b34:
	ldh [rOAM_X_POS], a
	push hl
	ldh a, [rOAM_TILE_ADDRESS_1]
	ld h, a
	ldh a, [rOAM_TILE_ADDRESS_2]
	ld l, a
	ldh a, [rOAM_VISIBLE]
	and a
	jr z, l_2b46			; jump if sprite is (supposed to be) visible
	
	ld a, $ff
	jr l_2b48

l_2b46:
	ldh a, [rOAM_Y_POS]

l_2b48:
	ldi [hl], a		
	ldh a, [rOAM_X_POS]		
	ldi [hl], a			
	ldh a, [rOAM_TILE_NO]
	ldi [hl], a
	ldh a, [$ff00 + $94]		; 
	ld b, a				; 
	ldh a, [$ff00 + $8b]		; 
	or b				; 
	ld b, a				; 
	ldh a, [rOAM_ATTRIBUTE_NO]		; 
	or b				; "or" both 8b and 9f into the attribute 
	ldi [hl], a
	ld a, h
	ldh [rOAM_TILE_ADDRESS_1], a
	ld a, l
	ldh [rOAM_TILE_ADDRESS_2], a
	pop hl
	jp read_next_design_element
	
; start of data section (see above): starting at $2b64
SECTION "Data", ROM0 [$2B64]
	db $20, $2C, $24, $2C, $28, $2C, $2C, $2C, $30, $2C, $34, $2C
	db $38, $2C, $3C, $2C, $40, $2C, $44, $2C, $48, $2C, $4C, $2C
	db $50, $2C, $54, $2C, $58, $2C, $5C, $2C, $60, $2C, $64, $2C
	db $68, $2C, $6C, $2C, $70, $2C, $74, $2C, $78, $2C, $7C, $2C
	db $80, $2C, $84, $2C, $88, $2C, $8C, $2C, $90, $2C, $94, $2C
	db $98, $2C, $9C, $2C, $A0, $2C, $A4, $2C, $A8, $2C, $AC, $2C
	db $B0, $2C, $B4, $2C, $B8, $2C, $BC, $2C, $C0, $2C, $C4, $2C
	db $C8, $2C, $CC, $2C, $C7, $30, $CC, $2C, $D0, $2C, $D4, $2C
	db $D8, $2C, $DC, $2C, $E0, $2C, $E4, $2C, $EA, $30, $EE, $30
	db $E8, $2C, $EC, $2C, $F2, $30, $F6, $30, $F0, $2C, $F4, $2C
	db $F8, $2C, $FC, $2C, $00, $2D, $04, $2D, $FA, $30, $FE, $30
	db $04, $2D, $08, $2D, $08, $2D, $0C, $2D, $10, $2D, $14, $2D
	db $18, $2D, $1C, $2D, $20, $2D, $24, $2D, $28, $2D, $2C, $2D
	db $30, $2D, $34, $2D, $38, $2D, $3C, $2D, $40, $2D, $44, $2D
	db $48, $2D, $4C, $2D, $50, $2D, $54, $2D, $0A, $31, $0E, $31
	db $12, $31, $12, $31, $02, $31, $06, $31, $58, $2D, $EF, $F0
	db $68, $2D, $EF, $F0, $7A, $2D, $EF, $F0, $89, $2D, $EF, $F0
	db $9A, $2D, $EF, $F0, $AC, $2D, $EF, $F0, $BD, $2D, $EF, $F0
	db $CB, $2D, $EF, $F0, $DC, $2D, $EF, $F0, $EB, $2D, $EF, $F0
	db $FC, $2D, $EF, $F0, $0B, $2E, $EF, $F0, $1C, $2E, $EF, $F0
	db $2E, $2E, $EF, $F0, $40, $2E, $EF, $F0, $52, $2E, $EF, $F0
	db $64, $2E, $EF, $F0, $76, $2E, $EF, $F0, $86, $2E, $EF, $F0
	db $98, $2E, $EF, $F0, $A8, $2E, $EF, $F0, $B9, $2E, $EF, $F0
	db $CA, $2E, $EF, $F0, $DB, $2E, $EF, $F0, $0B, $2F, $EF, $F0
	db $1C, $2F, $EF, $F0, $EC, $2E, $EF, $F0, $FA, $2E, $EF, $F0
	db $2D, $2F, $00, $E8, $36, $2F, $00, $E8, $3F, $2F, $00, $E8
	db $48, $2F, $00, $E8, $51, $2F, $00, $00, $55, $2F, $00, $00
	db $59, $2F, $00, $00, $5D, $2F, $00, $00, $61, $2F, $00, $00
	db $65, $2F, $00, $00, $69, $2F, $00, $00, $6D, $2F, $00, $00
	db $71, $2F, $00, $00, $75, $2F, $00, $00, $79, $2F, $F0, $F8
	db $84, $2F, $F0, $F8, $8F, $2F, $F0, $F0, $A3, $2F, $F0, $F0
	db $B8, $2F, $F8, $F8, $C1, $2F, $F8, $F8, $CA, $2F, $F8, $F8
	db $D1, $2F, $F8, $F8, $D8, $2F, $F0, $F8, $E3, $2F, $F0, $F8
	db $EE, $2F, $F0, $F0, $03, $30, $F0, $F0, $19, $30, $F8, $F8
	db $22, $30, $F8, $F8, $2B, $30, $F8, $F8, $32, $30, $F8, $F8
	db $39, $30, $F8, $F8, $40, $30, $F8, $F8, $47, $30, $F8, $F8
	db $4E, $30, $F8, $F8, $55, $30, $F8, $F8, $5C, $30, $F8, $F8
	db $67, $30, $F8, $F8, $6E, $30, $F8, $F8, $75, $30, $F8, $F8
	db $7C, $30, $F8, $F8, $83, $30, $F8, $F8, $8C, $30, $F8, $F8
	db $95, $30, $F8, $F8, $9E, $30, $F8, $F8, $A7, $30, $F8, $F8
	db $B0, $30, $F8, $F8, $B9, $30, $F8, $F8, $C0, $30, $F8, $F8
	db $46, $31, $F0, $F0, $5D, $31, $F8, $F8, $A9, $31, $FE, $FE
	db $FE, $FE, $FE, $FE, $FE, $FE, $84, $84, $84, $FE, $84, $FF
	db $A9, $31, $FE, $FE, $FE, $FE, $FE, $84, $FE, $FE, $FE, $84
	db $FE, $FE, $FE, $84, $84, $FF, $A9, $31, $FE, $FE, $FE, $FE
	db $FE, $FE, $84, $FE, $84, $84, $84, $FE, $FF, $A9, $31, $FE
	db $FE, $FE, $FE, $84, $84, $FE, $FE, $FE, $84, $FE, $FE, $FE
	db $84, $FF, $A9, $31, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE
	db $81, $81, $81, $FE, $FE, $FE, $81, $FF, $A9, $31, $FE, $FE
	db $FE, $FE, $FE, $81, $81, $FE, $FE, $81, $FE, $FE, $FE, $81
	db $FF, $A9, $31, $FE, $FE, $FE, $FE, $81, $FE, $FE, $FE, $81
	db $81, $81, $FF, $A9, $31, $FE, $FE, $FE, $FE, $FE, $81, $FE
	db $FE, $FE, $81, $FE, $FE, $81, $81, $FF, $A9, $31, $FE, $FE
	db $FE, $FE, $FE, $FE, $FE, $FE, $8A, $8B, $8B, $8F, $FF, $A9
	db $31, $FE, $80, $FE, $FE, $FE, $88, $FE, $FE, $FE, $88, $FE
	db $FE, $FE, $89, $FF, $A9, $31, $FE, $FE, $FE, $FE, $FE, $FE
	db $FE, $FE, $8A, $8B, $8B, $8F, $FF, $A9, $31, $FE, $80, $FE
	db $FE, $FE, $88, $FE, $FE, $FE, $88, $FE, $FE, $FE, $89, $FF
	db $A9, $31, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $83
	db $83, $FE, $FE, $83, $83, $FF, $A9, $31, $FE, $FE, $FE, $FE
	db $FE, $FE, $FE, $FE, $FE, $83, $83, $FE, $FE, $83, $83, $FF
	db $A9, $31, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $83
	db $83, $FE, $FE, $83, $83, $FF, $A9, $31, $FE, $FE, $FE, $FE
	db $FE, $FE, $FE, $FE, $FE, $83, $83, $FE, $FE, $83, $83, $FF
	db $A9, $31, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $82, $82
	db $FE, $FE, $FE, $82, $82, $FF, $A9, $31, $FE, $FE, $FE, $FE
	db $FE, $82, $FE, $FE, $82, $82, $FE, $FE, $82, $FF, $A9, $31
	db $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $82, $82, $FE, $FE
	db $FE, $82, $82, $FF, $A9, $31, $FE, $FE, $FE, $FE, $FE, $82
	db $FE, $FE, $82, $82, $FE, $FE, $82, $FF, $A9, $31, $FE, $FE
	db $FE, $FE, $FE, $FE, $FE, $FE, $FE, $86, $86, $FE, $86, $86
	db $FF, $A9, $31, $FE, $FE, $FE, $FE, $86, $FE, $FE, $FE, $86
	db $86, $FE, $FE, $FE, $86, $FF, $A9, $31, $FE, $FE, $FE, $FE
	db $FE, $FE, $FE, $FE, $FE, $86, $86, $FE, $86, $86, $FF, $A9
	db $31, $FE, $FE, $FE, $FE, $86, $FE, $FE, $FE, $86, $86, $FE
	db $FE, $FE, $86, $FF, $A9, $31, $FE, $FE, $FE, $FE, $FE, $85
	db $FE, $FE, $85, $85, $85, $FF, $A9, $31, $FE, $FE, $FE, $FE
	db $FE, $85, $FE, $FE, $85, $85, $FE, $FE, $FE, $85, $FF, $A9
	db $31, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $85, $85, $85
	db $FE, $FE, $85, $FF, $A9, $31, $FE, $FE, $FE, $FE, $FE, $85
	db $FE, $FE, $FE, $85, $85, $FE, $FE, $85, $FF, $C9, $31, $0A
	db $25, $1D, $22, $19, $0E, $FF, $C9, $31, $0B, $25, $1D, $22
	db $19, $0E, $FF, $C9, $31, $0C, $25, $1D, $22, $19, $0E, $FF
	db $C9, $31, $2F, $18, $0F, $0F, $2F, $2F, $FF, $C9, $31, $00
	db $FF, $C9, $31, $01, $FF, $C9, $31, $02, $FF, $C9, $31, $03
	db $FF, $C9, $31, $04, $FF, $C9, $31, $05, $FF, $C9, $31, $06
	db $FF, $C9, $31, $07, $FF, $C9, $31, $08, $FF, $C9, $31, $09
	db $FF, $D9, $31, $2F, $01, $2F, $11, $20, $21, $30, $31, $FF
	db $D9, $31, $2F, $03, $12, $13, $22, $23, $32, $33, $FF, $A9
	db $31, $2F, $05, $FD, $05, $2F, $2F, $15, $04, $17, $24, $25
	db $26, $27, $34, $35, $36, $2F, $FF, $A9, $31, $08, $37, $FD
	db $37, $FD, $08, $18, $19, $14, $1B, $28, $29, $2A, $2B, $60
	db $70, $36, $2F, $FF, $D9, $31, $B9, $FD, $B9, $BA, $FD, $BA
	db $FF, $D9, $31, $82, $FD, $82, $83, $FD, $83, $FF, $D9, $31
	db $09, $0A, $3A, $3B, $FF, $D9, $31, $0B, $40, $7C, $6F, $FF
	db $D9, $31, $2F, $0F, $2F, $1F, $5F, $2C, $2F, $3F, $FF, $D9
	db $31, $6C, $3C, $4B, $4C, $5B, $5C, $6B, $2F, $FF, $A9, $31
	db $2F, $4D, $FD, $4D, $2F, $2F, $5D, $5E, $4E, $5F, $6D, $6E
	db $2F, $2F, $7D, $FD, $7D, $2F, $FF, $A9, $31, $08, $77, $FD
	db $77, $FD, $08, $18, $78, $43, $53, $7A, $7B, $50, $2F, $2F
	db $02, $FD, $7D, $2F, $FF, $D9, $31, $B9, $FD, $B9, $BA, $FD
	db $BA, $FF, $D9, $31, $82, $FD, $82, $83, $FD, $83, $FF, $D9
	db $31, $09, $0A, $3A, $3B, $FF, $D9, $31, $0B, $40, $7C, $6F
	db $FF, $D9, $31, $DC, $DD, $E0, $E1, $FF, $D9, $31, $DE, $DF
	db $E0, $E1, $FF, $D9, $31, $DE, $E2, $E0, $E4, $FF, $D9, $31
	db $DC, $EE, $E0, $E3, $FF, $D9, $31, $E5, $E6, $E7, $E8, $FF
	db $D9, $31, $FD, $E6, $FD, $E5, $FD, $E8, $FD, $E7, $FF, $D9
	db $31, $E9, $EA, $EB, $EC, $FF, $D9, $31, $ED, $EA, $EB, $EC
	db $FF, $D9, $31, $F2, $F4, $F3, $BF, $FF, $D9, $31, $F4, $F2
	db $BF, $F3, $FF, $D9, $31, $C2, $FD, $C2, $C3, $FD, $C3, $FF
	db $D9, $31, $C4, $FD, $C4, $C5, $FD, $C5, $FF, $D9, $31, $DC
	db $FD, $DC, $EF, $FD, $EF, $FF, $D9, $31, $F0, $FD, $F0, $F1
	db $FD, $F1, $FF, $D9, $31, $DC, $FD, $F0, $F1, $FD, $EF, $FF
	db $D9, $31, $F0, $FD, $DC, $EF, $FD, $F1, $FF, $D9, $31, $BD
	db $BE, $BB, $BC, $FF, $D9, $31, $B9, $BA, $DA, $DB, $FF, $CB
	db $30, $E0, $F0, $F5, $31, $C0, $C1, $C5, $C6, $CC, $CD, $75
	db $76, $A4, $A5, $A6, $A7, $54, $55, $56, $57, $44, $45, $46
	db $47, $A0, $A1, $A2, $A3, $9C, $9D, $9E, $9F, $FF, $16, $31
	db $F8, $E8, $1C, $31, $F0, $E8, $25, $31, $00, $00, $2B, $31
	db $00, $00, $31, $31, $00, $00, $3A, $31, $00, $00, $9D, $31
	db $00, $00, $A3, $31, $00, $00, $64, $31, $D8, $F8, $7C, $31
	db $E8, $F8, $8E, $31, $F0, $F8, $2D, $32, $63, $64, $65, $FF
	db $2D, $32, $63, $64, $65, $66, $67, $68, $FF, $2D, $32, $41
	db $41, $41, $FF, $2D, $32, $42, $42, $42, $FF, $2D, $32, $52
	db $52, $52, $62, $62, $62, $FF, $2D, $32, $51, $51, $51, $61
	db $61, $61, $71, $71, $71, $FF, $A9, $31, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $63, $64, $FD, $64, $FD, $63, $66, $67
	db $FD, $67, $FD, $66, $FF, $D9, $31, $2F, $2F, $63, $64, $FF
	db $D9, $31, $00, $FD, $00, $10, $FD, $10, $4F, $FD, $4F, $80
	db $FD, $80, $80, $FD, $80, $81, $FD, $81, $97, $FD, $97, $FF
	db $D9, $31, $98, $FD, $98, $99, $FD, $99, $80, $FD, $80, $9A
	db $FD, $9A, $9B, $FD, $9B, $FF, $D9, $31, $A8, $FD, $A8, $A9
	db $FD, $A9, $AA, $FD, $AA, $AB, $FD, $AB, $FF, $D9, $31, $41
	db $2F, $2F, $FF, $D9, $31, $52, $2F, $62, $FF, $00, $00, $00
	db $08, $00, $10, $00, $18, $08, $00, $08, $08, $08, $10, $08
	db $18, $10, $00, $10, $08, $10, $10, $10, $18, $18, $00, $18
	db $08, $18, $10, $18, $18, $00, $00, $00, $08, $00, $10, $00
	db $18, $00, $20, $00, $28, $00, $30, $00, $38, $00, $00, $00
	db $08, $08, $00, $08, $08, $10, $00, $10, $08, $18, $00, $18
	db $08, $20, $00, $20, $08, $28, $00, $28, $08, $30, $00, $30
	db $08, $00, $08, $00, $10, $08, $08, $08, $10, $10, $00, $10
	db $08, $10, $10, $10, $18, $18, $00, $18, $08, $18, $10, $18
	db $18, $20, $00, $20, $08, $20, $10, $20, $18, $28, $00, $28
	db $08, $28, $10, $28, $18, $30, $00, $30, $08, $30, $10, $30
	db $18, $38, $00, $38, $08, $38, $10, $38, $18, $00, $00, $00
	db $08, $00, $10, $08, $00, $08, $08, $08, $10, $10, $00, $10
	db $08, $10, $10, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
	db $7F, $7C, $7C, $78, $79, $78, $7B, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF, $00, $00, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $3F, $1F
	db $9F, $1F, $DF, $78, $7B, $78, $79, $7C, $7C, $7F, $7F, $7F
	db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $00, $00, $00, $FF, $00
	db $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F
	db $DF, $1F, $9F, $3F, $3F, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $78, $7A, $78, $7A, $78, $7A, $78, $7A, $78
	db $7A, $78, $7A, $78, $7A, $78, $7A, $1F, $5F, $1F, $5F, $1F
	db $5F, $1F, $5F, $1F, $5F, $1F, $5F, $1F, $5F, $1F, $5F, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $F8, $F8, $F0, $F2, $E1, $F5
	db $E3, $F2, $E6, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00
	db $00, $00, $FF, $FF, $FF, $00, $00, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $1F, $1F, $0F, $4F, $87, $AF, $C7, $4F, $67, $F2
	db $E6, $F2, $E6, $F2, $E6, $F2, $E6, $F2, $E6, $F2, $E6, $F2
	db $E6, $F2, $E6, $4F, $67, $4F, $67, $4F, $67, $4F, $67, $4F
	db $67, $4F, $67, $4F, $67, $4F, $67, $F2, $E6, $F5, $E3, $F2
	db $E1, $F8, $F0, $FF, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $00
	db $00, $FF, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $FF, $FF
	db $FF, $FF, $FF, $4F, $67, $AF, $C7, $4F, $87, $1F, $0F, $FF
	db $1F, $FF, $FF, $FF, $FF, $FF, $FF, $78, $7B, $78, $79, $7C
	db $7C, $7F, $7F, $7F, $7F, $7C, $7C, $78, $79, $78, $7B, $1F
	db $DF, $1F, $9F, $3F, $3F, $FF, $FF, $FF, $FF, $3F, $3F, $1F
	db $9F, $1F, $DF, $00, $00, $00, $FF, $00, $00, $FF, $FF, $FF
	db $FF, $00, $00, $00, $FF, $00, $00, $00, $00, $00, $7F, $00
	db $00, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $78
	db $7A, $78, $7A, $78, $7A, $78, $7A, $78, $7A, $00, $02, $00
	db $7A, $00, $7A, $1F, $5F, $1F, $5F, $1F, $5F, $1F, $5F, $1F
	db $5F, $00, $40, $00, $5F, $00, $5F, $00, $00, $00, $FF, $00
	db $00, $00, $FF, $00, $FF, $00, $00, $00, $FF, $00, $00, $00
	db $00, $00, $00, $3F, $3F, $3F, $3F, $30, $30, $30, $30, $33
	db $32, $33, $30, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00
	db $00, $00, $00, $FF, $02, $FF, $20, $00, $00, $00, $00, $FC
	db $FC, $FC, $FC, $0C, $0C, $0C, $0C, $CC, $0C, $CC, $0C, $33
	db $30, $33, $30, $33, $30, $33, $30, $33, $30, $33, $30, $33
	db $32, $33, $30, $CC, $0C, $CC, $4C, $CC, $0C, $CC, $0C, $CC
	db $0C, $CC, $8C, $CC, $0C, $CC, $0C, $33, $30, $33, $30, $30
	db $30, $30, $30, $3F, $3F, $3F, $3F, $00, $00, $00, $00, $FF
	db $04, $FF, $40, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00
	db $00, $00, $00, $CC, $0C, $CC, $4C, $0C, $0C, $0C, $0C, $FC
	db $FC, $FC, $FC, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF
	db $00, $FF, $02, $FF, $20, $FF, $00, $FF, $04, $FF, $00, $FF
	db $00, $FF, $02, $FF, $40, $FF, $00, $FF, $08, $FF, $01, $FF
	db $43, $FF, $07, $FF, $04, $FF, $40, $FF, $02, $FF, $00, $FF
	db $00, $FF, $FF, $FF, $FF, $00, $00, $FF, $00, $FF, $40, $FF
	db $02, $FF, $00, $FF, $10, $FF, $80, $FF, $C2, $FF, $E0, $FE
	db $06, $FE, $46, $FE, $06, $FE, $06, $FE, $16, $FE, $86, $FE
	db $06, $FE, $06, $7F, $64, $7F, $60, $7F, $62, $7F, $60, $7F
	db $60, $7F, $68, $7F, $62, $7F, $60, $FF, $02, $FF, $40, $FF
	db $00, $FF, $00, $FF, $08, $FF, $80, $FF, $1F, $F0, $10, $FF
	db $02, $FF, $20, $FF, $00, $FF, $00, $FF, $04, $FF, $00, $FF
	db $FF, $00, $00, $FF, $07, $FF, $13, $FF, $01, $FF, $00, $FF
	db $40, $FF, $00, $FF, $FF, $08, $08, $00, $00, $FF, $FF, $FF
	db $FF, $FF, $00, $FF, $02, $FF, $20, $FF, $FF, $00, $00, $FF
	db $E0, $FF, $C8, $FF, $80, $FF, $00, $FF, $02, $FF, $00, $FF
	db $FF, $08, $08, $FF, $00, $FF, $02, $FF, $40, $FF, $00, $FF
	db $02, $FF, $00, $FF, $F8, $0F, $08, $F0, $10, $F0, $10, $F0
	db $10, $F0, $50, $F0, $10, $F0, $10, $F0, $10, $F0, $10, $0F
	db $08, $0F, $0A, $0F, $08, $0F, $08, $0F, $08, $0F, $08, $0F
	db $09, $0F, $08, $00, $00, $00, $7F, $00, $00, $7F, $7F, $7F
	db $7F, $7C, $7C, $78, $79, $78, $7B, $00, $00, $00, $FF, $00
	db $00, $FF, $FF, $FF, $FF, $3F, $3F, $1F, $9F, $1F, $DF, $7F
	db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $00, $00, $00
	db $7F, $00, $00, $00, $00, $00, $00, $00, $00, $AA, $AA, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0F
	db $0F, $1F, $1F, $38, $38, $33, $30, $36, $30, $34, $30, $00
	db $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $FF, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $F0, $F0, $F8, $F8, $1C
	db $1C, $CC, $0C, $6C, $0C, $2C, $0C, $34, $30, $34, $30, $34
	db $30, $34, $30, $34, $30, $34, $30, $34, $30, $34, $30, $2C
	db $0C, $2C, $0C, $2C, $0C, $2C, $0C, $2C, $0C, $2C, $0C, $2C
	db $0C, $2C, $0C, $34, $30, $36, $30, $33, $30, $38, $38, $1F
	db $1F, $0F, $0F, $00, $00, $00, $00, $00, $7B, $00, $79, $00
	db $7C, $00, $7F, $00, $7F, $00, $00, $00, $7F, $00, $00, $00
	db $DF, $00, $9F, $00, $3F, $00, $FF, $00, $FF, $00, $00, $00
	db $FF, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $00, $FF
	db $FF, $FF, $FF, $00, $00, $00, $00, $2C, $0C, $6C, $0C, $CC
	db $0C, $1C, $1C, $F8, $F8, $F0, $F0, $00, $00, $00, $00, $08
	db $08, $FF, $FF, $FF, $02, $FF, $00, $FF, $20, $FF, $00, $FF
	db $02, $FF, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $00, $FF
	db $02, $FF, $20, $FF, $FF, $08, $08, $FF, $07, $FF, $13, $FF
	db $01, $FF, $00, $FF, $40, $FF, $00, $FF, $FF, $00, $00, $FF
	db $E0, $FF, $C8, $FF, $80, $FF, $00, $FF, $02, $FF, $00, $FF
	db $FF, $00, $00, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $FF, $00, $FF, $02, $FF
	db $00, $FF, $20, $FF, $02, $FF, $00, $FF, $FF, $08, $08, $F0
	db $10, $FF, $1F, $F0, $1F, $F0, $1F, $F0, $1F, $F0, $1F, $FF
	db $5F, $F0, $10, $00, $00, $FF, $FF, $00, $FF, $00, $FF, $00
	db $FF, $00, $FF, $FF, $FF, $00, $00, $08, $08, $FF, $FF, $00
	db $FF, $00, $FF, $00, $FF, $00, $FF, $FF, $FF, $08, $08, $0F
	db $08, $FF, $F8, $0F, $F8, $0F, $F8, $0F, $F8, $0F, $F8, $FF
	db $FA, $0F, $08, $FF, $07, $FF, $43, $FF, $01, $FF, $00, $FF
	db $00, $FF, $80, $FF, $1F, $F0, $10, $FF, $E0, $FF, $C2, $FF
	db $80, $FF, $00, $FF, $22, $FF, $00, $FF, $F8, $0F, $08, $00
	db $00, $00, $00, $00, $00, $3C, $00, $3C, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $3C, $00, $4E, $00, $4E, $00, $7E
	db $00, $4E, $00, $4E, $00, $00, $00, $00, $00, $7C, $00, $66
	db $00, $7C, $00, $66, $00, $66, $00, $7C, $00, $00, $00, $00
	db $00, $3C, $00, $66, $00, $60, $00, $60, $00, $66, $00, $3C
	db $00, $00, $00, $DD, $44, $FF, $44, $FF, $FF, $77, $11, $FF
	db $11, $FF, $FF, $DD, $44, $FF, $44, $FF, $FF, $77, $11, $FF
	db $11, $FF, $FF, $DD, $44, $FF, $44, $FF, $FF, $77, $11, $FF
	db $11, $FF, $FF, $DD, $44, $FF, $44, $FF, $FF, $77, $11, $FF
	db $11, $FF, $FF, $00, $00, $7E, $00, $18, $00, $18, $00, $18
	db $00, $18, $00, $18, $00, $00, $00, $00, $00, $66, $00, $66
	db $00, $3C, $00, $18, $00, $18, $00, $18, $00, $00, $00, $FF
	db $FF, $F7, $89, $DD, $A3, $FF, $81, $B7, $C9, $FD, $83, $D7
	db $A9, $FF, $81, $FF, $FF, $FF, $81, $FF, $BD, $E7, $A5, $E7
	db $A5, $FF, $BD, $FF, $81, $FF, $FF, $FF, $FF, $FF, $81, $FF
	db $81, $FF, $99, $FF, $99, $FF, $81, $FF, $81, $FF, $FF, $FF
	db $FF, $81, $81, $BD, $BD, $BD, $BD, $BD, $BD, $BD, $BD, $81
	db $81, $FF, $FF, $FF, $FF, $81, $FF, $81, $FF, $81, $FF, $81
	db $FF, $81, $FF, $81, $FF, $FF, $FF, $FF, $FF, $FF, $81, $C3
	db $81, $DF, $85, $DF, $85, $FF, $BD, $FF, $81, $FF, $FF, $FF
	db $FF, $81, $FF, $BD, $FF, $A5, $E7, $A5, $E7, $BD, $FF, $81
	db $FF, $FF, $FF, $FF, $FF, $81, $81, $BD, $83, $BD, $83, $BD
	db $83, $BD, $83, $81, $FF, $FF, $FF, $ED, $93, $BF, $C1, $F5
	db $8B, $DF, $A1, $FD, $83, $AF, $D1, $FB, $85, $DF, $A1, $FD
	db $83, $EF, $91, $BB, $C5, $EF, $91, $BD, $C3, $F7, $89, $DF
	db $A1, $FF, $FF, $FF, $FF, $DB, $A4, $FF, $80, $B5, $CA, $FF
	db $80, $DD, $A2, $F7, $88, $FF, $FF, $FF, $FF, $57, $A8, $FD
	db $02, $DF, $20, $7B, $84, $EE, $11, $BB, $44, $FF, $FF, $FF
	db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
	db $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
	db $FF, $00, $FF, $00, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $77, $89, $DF, $21, $FB, $05, $AF, $51, $FD, $03, $D7
	db $29, $FF, $FF, $00, $00, $3C, $00, $66, $00, $66, $00, $66
	db $00, $66, $00, $3C, $00, $00, $00, $00, $00, $18, $00, $38
	db $00, $18, $00, $18, $00, $18, $00, $3C, $00, $00, $00, $00
	db $00, $3C, $00, $4E, $00, $0E, $00, $3C, $00, $70, $00, $7E
	db $00, $00, $00, $00, $00, $7C, $00, $0E, $00, $3C, $00, $0E
	db $00, $0E, $00, $7C, $00, $00, $00, $00, $00, $3C, $00, $6C
	db $00, $4C, $00, $4E, $00, $7E, $00, $0C, $00, $00, $00, $00
	db $00, $7C, $00, $60, $00, $7C, $00, $0E, $00, $4E, $00, $3C
	db $00, $00, $00, $00, $00, $3C, $00, $60, $00, $7C, $00, $66
	db $00, $66, $00, $3C, $00, $00, $00, $00, $00, $7E, $00, $06
	db $00, $0C, $00, $18, $00, $38, $00, $38, $00, $00, $00, $00
	db $00, $3C, $00, $4E, $00, $3C, $00, $4E, $00, $4E, $00, $3C
	db $00, $00, $00, $00, $00, $3C, $00, $4E, $00, $4E, $00, $3E
	db $00, $0E, $00, $3C, $00, $00, $00, $00, $00, $7C, $00, $66
	db $00, $66, $00, $7C, $00, $60, $00, $60, $00, $00, $00, $00
	db $00, $7E, $00, $60, $00, $7C, $00, $60, $00, $60, $00, $7E
	db $00, $00, $00, $00, $00, $7E, $00, $60, $00, $60, $00, $7C
	db $00, $60, $00, $60, $00, $00, $00, $00, $00, $3C, $00, $66
	db $00, $66, $00, $66, $00, $66, $00, $3C, $00, $00, $00, $00
	db $00, $3C, $00, $66, $00, $60, $00, $6E, $00, $66, $00, $3E
	db $00, $00, $00, $00, $00, $46, $00, $6E, $00, $7E, $00, $56
	db $00, $46, $00, $46, $00, $00, $00, $00, $00, $46, $00, $46
	db $00, $46, $00, $46, $00, $4E, $00, $3C, $00, $00, $00, $00
	db $00, $3C, $00, $60, $00, $3C, $00, $0E, $00, $4E, $00, $3C
	db $00, $00, $00, $00, $00, $3C, $00, $18, $00, $18, $00, $18
	db $00, $18, $00, $3C, $00, $00, $00, $00, $00, $60, $00, $60
	db $00, $60, $00, $60, $00, $60, $00, $7E, $00, $00, $00, $00
	db $00, $46, $00, $46, $00, $46, $00, $46, $00, $2C, $00, $18
	db $00, $00, $00, $00, $00, $7C, $00, $66, $00, $66, $00, $7C
	db $00, $68, $00, $66, $00, $00, $00, $00, $00, $46, $00, $66
	db $00, $76, $00, $5E, $00, $4E, $00, $46, $00, $00, $00, $00
	db $00, $7C, $00, $4E, $00, $4E, $00, $4E, $00, $4E, $00, $7C
	db $00, $00, $00, $FF, $FF, $FF, $00, $FF, $00, $FF, $00, $FF
	db $10, $FF, $80, $FF, $02, $FF, $00, $00, $00, $FF, $FF, $FF
	db $FF, $FF, $00, $FF, $02, $FF, $20, $FF, $FF, $80, $80, $80
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $80, $80, $80, $80, $80, $FF, $FF, $00, $FF, $00, $FF, $00
	db $FF, $00, $FF, $FF, $FF, $80, $80, $80, $80, $FF, $FF, $FF
	db $00, $FF, $02, $FF, $20, $FF, $00, $FF, $00, $FF, $00, $FF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $07, $07, $18, $1F, $21, $3E, $47, $7F, $5F
	db $7F, $39, $30, $7B, $62, $FB, $B2, $FF, $A0, $FF, $C2, $7F
	db $54, $7F, $5C, $3F, $2E, $7F, $63, $BF, $F8, $37, $FF, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $83, $83, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $FF, $FF, $FF, $FF, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $83, $83, $FF
	db $FF, $D9, $87, $D9, $87, $D9, $87, $D9, $87, $D9, $87, $D9
	db $87, $D9, $87, $D9, $87, $D9, $87, $D9, $87, $D9, $87, $D9
	db $87, $D9, $87, $D9, $87, $FF, $FF, $D9, $87, $D9, $87, $D9
	db $87, $D9, $87, $D9, $87, $D9, $87, $D9, $87, $D9, $87, $00
	db $38, $00, $38, $00, $38, $00, $38, $00, $38, $00, $38, $00
	db $38, $00, $38, $7C, $00, $7C, $00, $7C, $00, $7C, $00, $7C
	db $00, $7C, $00, $7F, $00, $FF, $00, $00, $00, $00, $00, $08
	db $00, $08, $00, $08, $00, $08, $00, $1C, $00, $1C, $00, $00
	db $00, $00, $0E, $01, $1D, $1E, $06, $2A, $2A, $27, $27, $10
	db $13, $0C, $0D, $00, $00, $C0, $C0, $20, $20, $10, $D0, $D0
	db $10, $F0, $30, $C8, $E8, $08, $E8, $04, $07, $03, $03, $0C
	db $0C, $10, $10, $35, $20, $2A, $20, $3F, $3F, $0C, $0C, $28
	db $E8, $D8, $C0, $40, $40, $20, $20, $50, $10, $B0, $10, $F0
	db $F0, $C0, $C0, $00, $E0, $01, $71, $32, $42, $34, $35, $55
	db $54, $4F, $4E, $21, $27, $18, $1B, $00, $00, $80, $80, $40
	db $40, $20, $A0, $A0, $20, $E0, $60, $90, $F0, $08, $C8, $B8
	db $B8, $84, $84, $84, $84, $FC, $FC, $92, $92, $92, $92, $6C
	db $6C, $EE, $EE, $07, $07, $1F, $18, $3E, $20, $7F, $4F, $7F
	db $5F, $70, $70, $A2, $A2, $B0, $B0, $B4, $B4, $64, $64, $3C
	db $3C, $2E, $2E, $27, $27, $10, $10, $6C, $7C, $CF, $B3, $03
	db $03, $03, $03, $03, $02, $07, $06, $09, $09, $16, $17, $12
	db $11, $0E, $0F, $08, $09, $08, $08, $0F, $0F, $08, $08, $09
	db $09, $0A, $0A, $06, $06, $0E, $0E, $03, $03, $03, $03, $03
	db $02, $1F, $1E, $21, $21, $4A, $55, $4A, $75, $0A, $35, $0A
	db $15, $08, $08, $0F, $0F, $08, $08, $09, $09, $0A, $0A, $06
	db $06, $0E, $0E, $00, $00, $66, $00, $6C, $00, $78, $00, $78
	db $00, $6C, $00, $66, $00, $00, $00, $00, $00, $46, $00, $2C
	db $00, $18, $00, $38, $00, $64, $00, $42, $00, $00, $00, $FD
	db $FD, $FD, $FD, $FD, $FD, $FD, $FD, $FD, $FD, $FD, $FD, $FD
	db $FD, $FD, $FD, $F8, $00, $E0, $00, $C0, $00, $80, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $7F, $00, $1F, $00, $0F
	db $00, $07, $00, $07, $00, $03, $00, $03, $00, $03, $00, $00
	db $00, $80, $00, $80, $00, $C0, $00, $E0, $00, $F8, $00, $FF
	db $00, $FF, $00, $03, $00, $07, $00, $07, $00, $0F, $00, $1F
	db $00, $7F, $00, $FF, $00, $FF, $00, $FF, $FF, $FF, $FF, $00
	db $FF, $FF, $FF, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $FF
	db $00, $FF, $00, $FF, $01, $FE, $02, $FE, $02, $FC, $04, $FC
	db $04, $FC, $04, $FF, $02, $FF, $01, $FF, $01, $01, $01, $FF
	db $01, $01, $01, $FF, $01, $01, $01, $02, $02, $02, $02, $03
	db $03, $04, $05, $08, $09, $11, $12, $21, $26, $43, $4C, $00
	db $00, $01, $01, $02, $02, $04, $04, $08, $09, $10, $13, $20
	db $27, $20, $2F, $87, $98, $06, $39, $0E, $71, $1E, $E1, $3C
	db $C3, $3C, $C3, $78, $87, $78, $87, $40, $4F, $40, $4F, $80
	db $9F, $80, $9F, $80, $9F, $80, $9F, $80, $9F, $80, $9F, $F8
	db $07, $F0, $0F, $F0, $0F, $F0, $0F, $F0, $0F, $F0, $0F, $F0
	db $0F, $F8, $07, $40, $5F, $40, $4F, $20, $2F, $20, $27, $10
	db $11, $0F, $0F, $04, $04, $07, $07, $78, $87, $7C, $83, $3C
	db $C3, $1E, $E1, $0F, $F0, $FF, $FF, $FF, $00, $FF, $FF, $FF
	db $00, $FF, $00, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF
	db $00, $00, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
	db $00, $02, $00, $02, $00, $02, $00, $10, $00, $38, $00, $7C
	db $00, $FE, $00, $FE, $00, $FE, $00, $7C, $00, $00, $00, $02
	db $03, $01, $01, $02, $02, $04, $04, $0D, $08, $0A, $08, $0F
	db $0F, $03, $03, $28, $E8, $F0, $D0, $30, $30, $08, $08, $54
	db $04, $AC, $04, $FC, $FC, $30, $30, $00, $00, $03, $03, $03
	db $03, $03, $02, $07, $06, $09, $09, $08, $08, $0B, $0B, $00
	db $00, $C0, $C0, $C4, $C4, $E8, $68, $90, $F0, $A8, $F8, $48
	db $78, $F8, $B8, $00, $00, $07, $07, $07, $07, $07, $04, $07
	db $04, $0B, $0B, $10, $10, $17, $17, $00, $00, $80, $80, $80
	db $80, $E0, $E0, $90, $F0, $A8, $F8, $48, $78, $B8, $B8, $08
	db $08, $0F, $0F, $08, $08, $0F, $0F, $09, $09, $09, $09, $06
	db $06, $0E, $0E, $E4, $E4, $22, $22, $20, $20, $E0, $E0, $20
	db $20, $20, $20, $C0, $C0, $E0, $E0, $18, $18, $98, $98, $98
	db $98, $F8, $F8, $9C, $98, $3C, $3C, $3C, $3C, $7E, $7E, $7F
	db $00, $FE, $FE, $7E, $7E, $FE, $DA, $7E, $5A, $7E, $7E, $FC
	db $FC, $F8, $F8, $FE, $0E, $FE, $FE, $7E, $7E, $FE, $DA, $7E
	db $5A, $7E, $7E, $FC, $FC, $F8, $F8, $80, $80, $83, $83, $83
	db $83, $C3, $02, $EF, $2E, $97, $97, $47, $44, $24, $24, $00
	db $00, $C0, $C0, $C0, $C0, $C0, $40, $E0, $60, $F8, $F8, $E4
	db $24, $34, $34, $17, $14, $17, $14, $17, $14, $1C, $1F, $17
	db $17, $0F, $0F, $1E, $1E, $00, $00, $F4, $24, $F8, $28, $E8
	db $28, $38, $F8, $E8, $E8, $90, $90, $70, $70, $78, $78, $03
	db $03, $03, $03, $03, $02, $0F, $0E, $11, $11, $37, $37, $71
	db $52, $7D, $4E, $C0, $C0, $C0, $C0, $C0, $40, $C0, $40, $A0
	db $A0, $10, $10, $FF, $FF, $CF, $33, $7F, $40, $3F, $3F, $08
	db $08, $0F, $0F, $09, $09, $09, $09, $06, $06, $0E, $0E, $FC
	db $FC, $20, $20, $20, $20, $E0, $E0, $20, $20, $20, $20, $C0
	db $C0, $E0, $E0, $03, $03, $03, $03, $03, $02, $07, $06, $09
	db $09, $33, $33, $77, $54, $73, $4C, $18, $18, $D8, $D8, $D8
	db $D8, $F8, $78, $DC, $58, $BC, $BC, $3C, $3C, $7E, $7E, $09
	db $0E, $07, $07, $08, $0F, $08, $0F, $09, $0F, $0A, $0E, $06
	db $06, $0E, $0E, $00, $00, $03, $03, $03, $03, $03, $02, $FF
	db $7E, $C9, $3F, $78, $7F, $09, $0F, $04, $04, $07, $07, $B8
	db $BF, $C0, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00
	db $00, $78, $78, $78, $78, $7B, $48, $60, $5F, $B6, $B0, $84
	db $84, $B8, $B8, $84, $84, $84, $84, $84, $84, $FA, $FA, $92
	db $92, $9E, $9E, $67, $67, $E0, $E0, $00, $00, $00, $00, $78
	db $78, $78, $78, $78, $48, $40, $7E, $B4, $B0, $84, $84, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $30, $31, $31, $31, $31, $31, $32, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $44, $1C, $0C, $18
	db $1B, $0E, $45, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $67, $46, $46, $46, $46, $46, $68, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $2F, $2F, $2F, $2F, $2F, $00, $2F, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $43, $34, $34, $34
	db $34, $34, $34, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $30, $31, $31, $31, $31, $31, $32, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $36, $15, $0E, $1F, $0E, $15, $37, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $36, $2F, $2F, $2F
	db $2F, $2F, $37, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $40, $42, $42, $42, $42, $42, $41, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $36, $15, $12, $17, $0E, $1C, $37, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $36, $2F, $2F, $2F
	db $2F, $2F, $37, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $33, $34, $34, $34, $34, $34, $35, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $2B, $38, $39, $39, $39, $39, $3A, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $2B, $3B, $2F, $2F
	db $2F, $2F, $3C, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $2B, $3B, $2F, $2F, $2F, $2F, $3C, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $2B, $3B, $2F, $2F, $2F, $2F, $3C, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $2B, $3B, $2F, $2F
	db $2F, $2F, $3C, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $2B, $3D, $3E, $3E, $3E, $3E, $3F, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F

SECTION "Data2", romx
	db $2F, $2F, $2F, $7B
	db $30, $31, $31, $31, $31, $31, $32, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $36, $15, $0E, $1F
	db $0E, $15, $37, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $36, $2F, $2F, $2F, $2F, $2F, $37, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $40, $42, $42, $42, $42, $42, $41, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $36, $11, $12, $10
	db $11, $2F, $37, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $36, $2F, $2F, $2F, $2F, $2F, $37, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $33, $34, $34, $34, $34, $34, $35, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $2B, $8E, $8E, $8E
	db $8E, $8E, $8E, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $30, $31, $31, $31, $31, $31, $32, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $36, $15, $12, $17, $0E, $1C, $37, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $36, $2F, $2F, $02
	db $05, $2F, $37, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $33, $34, $34, $34, $34, $34, $35, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $2B, $38, $39, $39, $39, $39, $3A, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $2B, $3B, $2F, $2F
	db $2F, $2F, $3C, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $2B, $3B, $2F, $2F, $2F, $2F, $3C, $2A
	db $7B, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7B
	db $2B, $3B, $2F, $2F, $2F, $2F, $3C, $2A, $7C, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $7C, $2B, $3B, $2F, $2F
	db $2F, $2F, $3C, $2A, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $7D, $2B, $3D, $3E, $3E, $3E, $3E, $3F, $00
	db $3C, $66, $66, $66, $66, $3C, $00, $00, $18, $38, $18, $18
	db $18, $3C, $00, $00, $3C, $4E, $0E, $3C, $70, $7E, $00, $00
	db $7C, $0E, $3C, $0E, $0E, $7C, $00, $00, $3C, $6C, $4C, $4E
	db $7E, $0C, $00, $00, $7C, $60, $7C, $0E, $4E, $3C, $00, $00
	db $3C, $60, $7C, $66, $66, $3C, $00, $00, $7E, $06, $0C, $18
	db $38, $38, $00, $00, $3C, $4E, $3C, $4E, $4E, $3C, $00, $00
	db $3C, $4E, $4E, $3E, $0E, $3C, $00, $00, $3C, $4E, $4E, $7E
	db $4E, $4E, $00, $00, $7C, $66, $7C, $66, $66, $7C, $00, $00
	db $3C, $66, $60, $60, $66, $3C, $00, $00, $7C, $4E, $4E, $4E
	db $4E, $7C, $00, $00, $7E, $60, $7C, $60, $60, $7E, $00, $00
	db $7E, $60, $60, $7C, $60, $60, $00, $00, $3C, $66, $60, $6E
	db $66, $3E, $00, $00, $46, $46, $7E, $46, $46, $46, $00, $00
	db $3C, $18, $18, $18, $18, $3C, $00, $00, $1E, $0C, $0C, $6C
	db $6C, $38, $00, $00, $66, $6C, $78, $78, $6C, $66, $00, $00
	db $60, $60, $60, $60, $60, $7E, $00, $00, $46, $6E, $7E, $56
	db $46, $46, $00, $00, $46, $66, $76, $5E, $4E, $46, $00, $00
	db $3C, $66, $66, $66, $66, $3C, $00, $00, $7C, $66, $66, $7C
	db $60, $60, $00, $00, $3C, $62, $62, $6A, $64, $3A, $00, $00
	db $7C, $66, $66, $7C, $68, $66, $00, $00, $3C, $60, $3C, $0E
	db $4E, $3C, $00, $00, $7E, $18, $18, $18, $18, $18, $00, $00
	db $46, $46, $46, $46, $4E, $3C, $00, $00, $46, $46, $46, $46
	db $2C, $18, $00, $00, $46, $46, $56, $7E, $6E, $46, $00, $00
	db $46, $2C, $18, $38, $64, $42, $00, $00, $66, $66, $3C, $18
	db $18, $18, $00, $00, $7E, $0E, $1C, $38, $70, $7E, $00, $00	
	db $00, $00, $00, $00, $60, $60, $00, $00, $00, $00, $3C, $3C
	db $00, $00, $00, $00, $00, $22, $14, $08, $14, $22, $00, $00
	db $00, $36, $36, $5F, $49, $5F, $41, $7F, $41, $3E, $22, $1C
	db $14, $08, $08, $FF, $FF, $FF, $81, $C1, $BF, $C1, $BF, $C1
	db $BF, $C1, $BF, $81, $FF, $FF, $FF, $AA, $AA, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE
	db $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE
	db $FE, $FE, $FE, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
	db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $FF, $00, $FF, $40, $FF
	db $02, $FF, $00, $FF, $10, $FF, $80, $FF, $02, $FF, $00, $F0
	db $10, $FF, $1F, $FF, $00, $FF, $40, $FF, $00, $FF, $02, $FF
	db $40, $FF, $00, $0F, $08, $FF, $F8, $FF, $00, $FF, $02, $FF
	db $00, $FF, $40, $FF, $02, $FF, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $18, $18, $38, $38, $18, $18, $18, $18, $18
	db $18, $3C, $3C, $00, $00, $00, $00, $3C, $3C, $4E, $4E, $4E
	db $4E, $3E, $3E, $0E, $0E, $3C, $3C, $00, $00, $00, $00, $3C
	db $3C, $4E, $4E, $3C, $3C, $4E, $4E, $4E, $4E, $3C, $3C, $00
	db $00, $38, $38, $44, $44, $BA, $BA, $A2, $A2, $BA, $BA, $44
	db $44, $38, $38, $C6, $C6, $E6, $E6, $E6, $E6, $D6, $D6, $D6
	db $D6, $CE, $CE, $CE, $CE, $C6, $C6, $C0, $C0, $C0, $C0, $00
	db $00, $DB, $DB, $DD, $DD, $D9, $D9, $D9, $D9, $D9, $D9, $00
	db $00, $30, $30, $78, $78, $33, $33, $B6, $B6, $B7, $B7, $B6
	db $B6, $B3, $B3, $00, $00, $00, $00, $00, $00, $CD, $CD, $6E
	db $6E, $EC, $EC, $0C, $0C, $EC, $EC, $01, $01, $01, $01, $01
	db $01, $8F, $8F, $D9, $D9, $D9, $D9, $D9, $D9, $CF, $CF, $80
	db $80, $80, $80, $80, $80, $9E, $9E, $B3, $B3, $B3, $B3, $B3
	db $B3, $9E, $9E, $FF, $00, $FF, $00, $FF, $00, $EF, $00, $FF
	db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
	db $00, $E7, $00, $E7, $00, $FF, $00, $FF, $00, $FF, $00, $00
	db $FF, $FF, $FF, $00, $FF, $00, $FF, $FF, $00, $00, $FF, $FF
	db $00, $FF, $00, $00, $FF, $FF, $FF, $01, $FF, $02, $FE, $FE
	db $02, $04, $FC, $FC, $04, $FC, $04, $00, $FF, $FF, $FF, $80
	db $FF, $40, $7F, $FF, $40, $E0, $3F, $FF, $20, $BF, $60, $FF
	db $00, $FF, $00, $FF, $01, $FE, $02, $FE, $02, $FC, $04, $FC
	db $04, $FC, $04, $FF, $00, $FF, $00, $FF, $80, $7F, $40, $FF
	db $40, $FF, $20, $FF, $20, $BF, $60, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF
	db $02, $FF, $01, $FF, $01, $FF, $01, $FF, $01, $FF, $01, $FF
	db $01, $FF, $01, $7F, $C0, $FF, $80, $FF, $80, $FF, $80, $FF
	db $80, $FF, $80, $FF, $80, $FF, $80, $FE, $02, $FE, $02, $FF
	db $03, $FC, $05, $F8, $09, $F1, $12, $E1, $26, $C3, $4C, $7F
	db $C0, $7F, $C0, $FF, $C0, $BF, $60, $9F, $70, $AF, $58, $27
	db $DC, $33, $CE, $FF, $00, $FF, $01, $FE, $02, $FC, $04, $F8
	db $09, $F0, $13, $E0, $27, $E0, $2F, $87, $98, $06, $39, $0E
	db $71, $1E, $E1, $3C, $C3, $3C, $C3, $78, $87, $78, $87, $35
	db $CB, $32, $CD, $3A, $C5, $79, $86, $78, $87, $78, $87, $7C
	db $83, $7C, $83, $FF, $00, $FF, $80, $7F, $C0, $3F, $E0, $9F
	db $70, $4F, $B8, $67, $9C, $37, $CC, $C0, $4F, $C0, $4F, $80
	db $9F, $80, $9F, $80, $9F, $80, $9F, $80, $9F, $80, $9F, $F8
	db $07, $F0, $0F, $F0, $0F, $F0, $0F, $F0, $0F, $F0, $0F, $F0
	db $0F, $F8, $07, $7C, $83, $7E, $81, $7E, $81, $3E, $C1, $3F
	db $C0, $1F, $E0, $1F, $E0, $1F, $E0, $33, $CE, $1B, $E6, $09
	db $F7, $0D, $F3, $0D, $F3, $0D, $F3, $0D, $F3, $09, $F7, $C0
	db $5F, $C0, $4F, $E0, $2F, $E0, $27, $F0, $11, $BF, $4F, $0C
	db $F4, $07, $FF, $78, $87, $7C, $83, $3C, $C3, $1E, $E1, $0F
	db $F0, $FF, $FF, $FF, $00, $FF, $FF, $0F, $F0, $0F, $F0, $0E
	db $F1, $0E, $F1, $06, $F9, $FF, $FF, $C5, $3F, $FF, $FF, $1B
	db $E6, $13, $EE, $37, $CC, $27, $DC, $4F, $B8, $FC, $F3, $FC
	db $A3, $E0, $FF, $FE, $02, $FE, $02, $BF, $43, $1C, $E5, $B8
	db $49, $B1, $52, $A1, $66, $43, $CC, $FF, $00, $FF, $00, $FF
	db $00, $FF, $00, $FF, $00, $FF, $00, $EF, $10, $C7, $38, $FF
	db $00, $FB, $04, $FB, $04, $FB, $04, $FB, $04, $F1, $0E, $F1
	db $0E, $F1, $0E, $83, $7C, $01, $FE, $01, $FE, $01, $FE, $83
	db $7C, $FF, $00, $83, $7C, $83, $7C, $F1, $0E, $E0, $1F, $E0
	db $1F, $E0, $1F, $E0, $1F, $E0, $1F, $80, $7F, $80, $7F, $F7
	db $08, $EB, $14, $F7, $08, $F7, $08, $E3, $1C, $E3, $1C, $63
	db $9C, $01, $FE, $00, $00, $60, $60, $70, $70, $78, $78, $78
	db $78, $70, $70, $60, $60, $00, $00, $00, $00, $30, $30, $70
	db $70, $30, $30, $30, $30, $30, $30, $78, $78, $00, $00, $E0
	db $E0, $F0, $E0, $FB, $E0, $FC, $E0, $FC, $E1, $FC, $E1, $FC
	db $E1, $FC, $E1, $00, $00, $00, $00, $FF, $00, $00, $00, $00
	db $FF, $00, $00, $00, $00, $00, $00, $07, $07, $0F, $07, $DF
	db $07, $3F, $07, $3F, $87, $3F, $87, $3F, $87, $3F, $87, $FC
	db $E1, $FC, $E1, $FC, $E1, $FC, $E1, $FC, $E1, $FC, $E1, $FC
	db $E1, $FC, $E1, $3F, $87, $3F, $87, $3F, $87, $3F, $87, $3F
	db $87, $3F, $87, $3F, $87, $3F, $87, $FC, $E1, $FC, $E1, $FC
	db $E1, $FC, $E1, $FC, $E0, $FF, $E7, $FF, $EF, $E0, $FF, $00
	db $00, $00, $00, $00, $00, $00, $FF, $00, $00, $FF, $FF, $FF
	db $FF, $00, $FF, $3F, $87, $3F, $87, $3F, $87, $3F, $87, $3F
	db $07, $FF, $E7, $FF, $F7, $07, $FF, $F8, $00, $E0, $00, $C0
	db $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $7F
	db $00, $1F, $00, $0F, $00, $07, $00, $07, $00, $03, $00, $03
	db $00, $03, $00, $00, $00, $80, $00, $80, $00, $C0, $00, $E0
	db $00, $F8, $00, $FF, $00, $FF, $00, $03, $00, $07, $00, $07
	db $00, $0F, $00, $1F, $00, $7F, $00, $FF, $00, $FF, $00, $01
	db $01, $01, $01, $81, $81, $C1, $C1, $C1, $C1, $E1, $E1, $F1
	db $F1, $F9, $F9, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE
	db $FE, $FE, $FE, $FE, $FE, $FE, $FE, $7E, $7E, $7F, $7F, $7F
	db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
	db $7F, $3F, $3F, $9F, $9F, $8F, $8F, $CF, $CF, $E7, $E7, $F3
	db $F3, $F7, $F7, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
	db $E0, $C0, $C0, $C0, $C0, $80, $80, $F0, $F0, $F0, $F0, $F0
	db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $00
	db $00, $7C, $7C, $47, $47, $41, $41, $40, $40, $40, $40, $40
	db $40, $7F, $40, $00, $00, $01, $01, $01, $01, $81, $81, $C1
	db $C1, $41, $41, $61, $61, $E1, $61, $00, $00, $FE, $FE, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $FE, $06, $00
	db $00, $1B, $1B, $32, $32, $59, $59, $4C, $4C, $8C, $8C, $86
	db $86, $FF, $83, $00, $00, $FF, $FF, $01, $01, $01, $01, $81
	db $81, $41, $41, $41, $41, $3F, $21, $00, $00, $BE, $BE, $88
	db $88, $88, $88, $88, $88, $88, $88, $80, $80, $80, $80, $00
	db $00, $88, $88, $D8, $D8, $A8, $A8, $88, $88, $88, $88, $00
	db $00, $00, $00, $7F, $40, $7F, $40, $7F, $40, $7F, $40, $7F
	db $40, $7F, $40, $7F, $40, $47, $7F, $E1, $61, $E1, $61, $E1
	db $61, $E1, $61, $E1, $61, $C1, $C1, $C1, $C1, $81, $81, $FE
	db $06, $FE, $06, $FE, $06, $FE, $06, $FE, $06, $FE, $06, $FE
	db $06, $06, $FE, $FF, $83, $FF, $81, $7F, $40, $7F, $40, $7F
	db $40, $3F, $20, $3F, $20, $10, $1F, $1F, $11, $9F, $91, $CF
	db $C9, $C7, $C5, $E3, $63, $F3, $33, $F9, $19, $08, $F8, $80
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $80, $80, $80, $5F, $7F, $78, $78, $60, $60, $50, $70, $50
	db $70, $48, $78, $44, $7C, $7E, $7E, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $06
	db $FE, $06, $FE, $06, $FE, $06, $FE, $06, $FE, $06, $FE, $06
	db $FE, $FE, $FE, $08, $0F, $44, $47, $64, $67, $72, $73, $51
	db $71, $59, $79, $4C, $7C, $7E, $7E, $0C, $FC, $06, $FE, $03
	db $FF, $01, $FF, $01, $FF, $00, $FF, $80, $FF, $7F, $7F, $00
	db $00, $00, $00, $00, $00, $80, $80, $80, $80, $C0, $C0, $C0
	db $C0, $E0, $E0, $7E, $7E, $7F, $7F, $7F, $7F, $7F, $7F, $7F
	db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $00, $00, $03, $03, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $03, $02, $00
	db $00, $FB, $FB, $0A, $0A, $12, $12, $22, $22, $22, $22, $42
	db $42, $C3, $42, $00, $00, $FD, $FD, $0D, $0D, $0C, $0C, $0C
	db $0C, $0C, $0C, $0C, $0C, $FC, $0C, $00, $00, $FC, $FC, $0C
	db $0C, $8C, $8C, $4C, $4C, $4C, $4C, $2C, $2C, $3C, $2C, $03
	db $02, $03, $02, $03, $03, $03, $03, $02, $02, $00, $00, $00
	db $00, $00, $00, $83, $82, $83, $82, $03, $02, $03, $02, $03
	db $02, $03, $02, $03, $02, $02, $03, $FC, $0C, $FC, $0C, $FC
	db $0C, $FC, $0C, $FC, $0C, $FC, $0C, $FC, $0C, $0C, $FC, $1C
	db $1C, $1C, $1C, $0C, $0C, $0C, $0C, $04, $04, $00, $00, $00
	db $00, $00, $00, $02, $03, $02, $03, $02, $03, $02, $03, $02
	db $03, $02, $03, $02, $03, $03, $03, $0C, $FC, $0C, $FC, $0C
	db $FC, $0C, $FC, $0C, $FC, $0C, $FC, $0C, $FC, $FC, $FC, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	db $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FF, $00, $FF, $00, $FF
	db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $00
	db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
	db $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $01, $01, $03
	db $03, $07, $07, $0F, $0F, $1F, $1F, $3F, $3F, $7F, $7F, $00
	db $00, $FF, $FF, $83, $83, $83, $83, $83, $83, $83, $83, $83
	db $83, $FF, $83, $00, $00, $7F, $7F, $20, $20, $10, $10, $08
	db $08, $04, $04, $02, $02, $01, $01, $00, $00, $F3, $F3, $32
	db $32, $32, $32, $32, $32, $32, $32, $32, $32, $F3, $32, $FF
	db $83, $FF, $83, $FF, $83, $FF, $83, $FF, $83, $FF, $83, $FF
	db $83, $83, $FF, $00, $00, $00, $00, $01, $01, $03, $03, $07
	db $07, $0F, $0B, $1F, $13, $23, $3F, $F3, $B2, $73, $72, $33
	db $33, $13, $13, $02, $02, $00, $00, $00, $00, $00, $00, $83
	db $FF, $83, $FF, $83, $FF, $83, $FF, $83, $FF, $83, $FF, $83
	db $FF, $FF, $FF, $43, $7F, $23, $3F, $13, $1F, $0B, $0F, $07
	db $07, $03, $03, $01, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $10, $10, $30, $30, $70, $70, $00
	db $00, $78, $78, $9C, $9C, $1C, $1C, $78, $78, $E0, $E0, $FC
	db $FC, $00, $00, $FF, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $1B, $1B, $1B, $1B, $09
	db $09, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $60, $60, $60, $60, $20
	db $20, $00, $00, $1B, $1B, $1B, $1B, $09, $09, $00, $00, $00
	db $00, $60, $60, $60, $60, $00, $00, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $9B, $1D, $16, $2F, $0A, $17, $0D, $2F, $33
	db $01, $09, $08, $07, $2F, $0E, $15, $18, $1B, $10, $9C, $2F
	db $1D, $0E, $1D, $1B, $12, $1C, $2F, $15, $12, $0C, $0E, $17
	db $1C, $0E, $0D, $2F, $1D, $18, $2F, $2F, $2F, $2F, $2F, $0B
	db $1E, $15, $15, $0E, $1D, $25, $19, $1B, $18, $18, $0F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $1C, $18, $0F, $1D, $20
	db $0A, $1B, $0E, $2F, $0A, $17, $0D, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $1C, $1E, $0B, $25, $15, $12, $0C, $0E, $17, $1C
	db $0E, $0D, $2F, $1D, $18, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $17, $12, $17, $1D, $0E, $17, $0D, $18, $24, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $33, $01, $09, $08, $09, $2F, $0B, $1E, $15, $15, $0E, $1D
	db $25, $19, $1B, $18, $18, $0F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $1C, $18, $0F, $1D, $20, $0A, $1B, $0E, $24, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $33, $30, $31, $32, $31, $2F
	db $34, $35, $36, $37, $38, $39, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $0A, $15, $15, $2F, $1B
	db $12, $10, $11, $1D, $1C, $2F, $1B, $0E, $1C, $0E, $1B, $1F
	db $0E, $0D, $24, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $18, $1B, $12, $10, $12, $17, $0A, $15, $2F, $0C, $18
	db $17, $0C, $0E, $19, $1D, $9C, $2F, $2F, $0D, $0E, $1C, $12
	db $10, $17, $2F, $0A, $17, $0D, $2F, $19, $1B, $18, $10, $1B
	db $0A, $16, $2F, $0B, $22, $2F, $0A, $15, $0E, $21, $0E, $22
	db $2F, $19, $0A, $23, $11, $12, $1D, $17, $18, $1F, $9D, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $8E, $8E, $8E, $8E, $8E
	db $8E, $8E, $8E, $8E, $8E, $8E, $8E, $8E, $8E, $8E, $8E, $8E
	db $8E, $8E, $8E, $5A, $5B, $5B, $5B, $5B, $5B, $5B, $5B, $5B
	db $5B, $5B, $5B, $5B, $5B, $5B, $5B, $5B, $5B, $5B, $5C, $5D
	db $80, $81, $82, $83, $90, $91, $92, $81, $82, $83, $90, $6C
	db $6D, $6E, $6F, $70, $71, $72, $5E, $5D, $84, $85, $86, $87
	db $93, $94, $95, $85, $86, $87, $93, $73, $74, $75, $76, $77
	db $78, $2F, $5E, $5D, $2F, $88, $89, $2F, $96, $97, $98, $88
	db $89, $2F, $96, $79, $7A, $7B, $7C, $7D, $7E, $2F, $5E, $5D
	db $2F, $8A, $8B, $2F, $8E, $8F, $6B, $8A, $8B, $2F, $8E, $7F
	db $66, $67, $68, $69, $6A, $2F, $5E, $5F, $60, $60, $60, $60
	db $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60
	db $60, $60, $61, $8E, $3C, $3C, $3C, $3C, $3C, $3C, $3C, $3C
	db $3C, $3C, $3C, $3C, $3C, $3D, $3E, $3C, $3C, $3C, $8E, $8E
	db $8C, $8C, $62, $63, $8C, $8C, $3A, $8C, $8C, $8C, $8C, $8C
	db $3A, $42, $43, $3B, $8C, $8C, $8E, $8E, $3A, $8C, $64, $65
	db $8C, $8C, $8C, $8C, $3B, $8C, $8C, $8C, $8C, $44, $45, $8C
	db $8C, $8C, $8E, $8E, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C
	db $8C, $8C, $8C, $8C, $46, $47, $48, $49, $3F, $40, $8E, $8E
	db $8C, $8C, $8C, $8C, $3A, $8C, $8C, $8C, $8C, $53, $54, $8C
	db $4A, $4B, $4C, $4D, $42, $43, $8E, $8E, $8C, $8C, $8C, $8C
	db $8C, $8C, $8C, $8C, $54, $55, $56, $57, $4E, $4F, $50, $51
	db $52, $45, $8E, $41, $41, $41, $41, $41, $41, $41, $41, $41
	db $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $2F
	db $2F, $59, $19, $15, $0A, $22, $0E, $1B, $2F, $2F, $2F, $99
	db $19, $15, $0A, $22, $0E, $1B, $2F, $2F, $2F, $9A, $9A, $9A
	db $9A, $9A, $9A, $9A, $2F, $2F, $2F, $9A, $9A, $9A, $9A, $9A
	db $9A, $9A, $2F, $2F, $2F, $2F, $2F, $33, $30, $31, $32, $31
	db $2F, $34, $35, $36, $37, $38, $39, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $47, $48, $48, $48, $48
	db $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48
	db $48, $48, $49, $4A, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $50, $51, $51, $51, $51, $51, $51, $51, $51
	db $51, $52, $2C, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $2C, $53
	db $10, $0A, $16, $0E, $2F, $1D, $22, $19, $0E, $54, $2C, $2C
	db $2C, $2C, $4B, $4A, $2C, $55, $56, $6D, $58, $58, $58, $58
	db $58, $A9, $58, $58, $58, $6E, $56, $56, $5A, $2C, $4B, $4A
	db $2C, $5B, $78, $77, $7E, $7F, $9A, $9B, $2F, $AA, $79, $77
	db $7E, $7F, $9A, $9B, $5C, $2C, $4B, $4A, $2C, $2D, $4F, $4F
	db $4F, $4F, $4F, $4F, $4F, $AC, $4F, $4F, $4F, $4F, $4F, $4F
	db $2E, $2C, $4B, $4A, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $2C, $50
	db $51, $51, $51, $51, $51, $51, $51, $51, $51, $51, $52, $2C
	db $2C, $2C, $4B, $4A, $2C, $2C, $2C, $53, $16, $1E, $1C, $12
	db $0C, $2F, $1D, $22, $19, $0E, $54, $2C, $2C, $2C, $4B, $4A
	db $2C, $55, $56, $6D, $58, $58, $58, $58, $58, $A9, $58, $58
	db $58, $58, $6E, $56, $5A, $2C, $4B, $4A, $2C, $5B, $78, $77
	db $7E, $7F, $9A, $9B, $2F, $AA, $79, $77, $7E, $7F, $9A, $9B
	db $5C, $2C, $4B, $4A, $2C, $71, $72, $72, $72, $72, $72, $72
	db $72, $AB, $72, $72, $72, $72, $72, $72, $74, $2C, $4B, $4A
	db $2C, $5B, $7A, $77, $7E, $7F, $9A, $9B, $2F, $AA, $2F, $9D
	db $9C, $9C, $2F, $2F, $5C, $2C, $4B, $4A, $2C, $2D, $4F, $4F
	db $4F, $4F, $4F, $4F, $4F, $AC, $4F, $4F, $4F, $4F, $4F, $4F
	db $2E, $2C, $4B, $4A, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4C
	db $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D
	db $4D, $4D, $4D, $4D, $4D, $4D, $4E, $47, $48, $48, $48, $48
	db $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48
	db $48, $48, $49, $4A, $2F, $0A, $25, $1D, $22, $19, $0E, $2F
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $2C, $2C
	db $2C, $50, $51, $51, $51, $51, $51, $52, $2C, $2C, $2C, $2C
	db $2C, $2C, $4B, $4A, $2C, $2C, $2C, $2C, $2C, $53, $15, $0E
	db $1F, $0E, $15, $54, $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $55, $56, $57, $58, $6C, $58, $6C, $58, $59
	db $56, $5A, $2C, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $2C, $5B
	db $90, $6F, $91, $6F, $92, $6F, $93, $6F, $94, $5C, $2C, $2C
	db $2C, $2C, $4B, $4A, $2C, $2C, $2C, $71, $72, $73, $72, $73
	db $72, $73, $72, $73, $72, $74, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $5B, $95, $6F, $96, $6F, $97, $6F, $98, $6F
	db $99, $5C, $2C, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $2C, $2D
	db $4F, $6B, $4F, $6B, $4F, $6B, $4F, $6B, $4F, $2E, $2C, $2C
	db $2C, $2C, $4B, $4A, $2C, $2C, $2C, $50, $51, $51, $51, $51
	db $51, $51, $51, $51, $51, $52, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $53, $1D, $18, $19, $25, $1C, $0C, $18, $1B
	db $0E, $54, $2C, $2C, $2C, $2C, $4B, $4A, $55, $56, $70, $6D
	db $58, $58, $58, $58, $58, $58, $58, $58, $58, $6E, $56, $56
	db $56, $5A, $4B, $4A, $5B, $01, $6F, $60, $60, $60, $60, $60
	db $60, $2F, $2F, $60, $60, $60, $60, $60, $60, $5C, $4B, $4A
	db $5B, $02, $6F, $60, $60, $60, $60, $60, $60, $2F, $2F, $60
	db $60, $60, $60, $60, $60, $5C, $4B, $4A, $5B, $03, $6F, $60
	db $60, $60, $60, $60, $60, $2F, $2F, $60, $60, $60, $60, $60
	db $60, $5C, $4B, $4A, $2D, $4F, $6B, $4F, $4F, $4F, $4F, $4F
	db $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $2E, $4B, $4C
	db $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D
	db $4D, $4D, $4D, $4D, $4D, $4D, $4E, $47, $48, $48, $48, $48
	db $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48
	db $48, $48, $49, $4A, $2F, $0B, $25, $1D, $22, $19, $0E, $2F
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $50, $51
	db $51, $51, $51, $51, $52, $2C, $2C, $50, $51, $51, $51, $51
	db $52, $2C, $4B, $4A, $2C, $2C, $53, $15, $0E, $1F, $0E, $15
	db $54, $2C, $2C, $53, $11, $12, $10, $11, $54, $2C, $4B, $4A
	db $55, $56, $57, $58, $6C, $58, $6C, $58, $59, $56, $5A, $75
	db $58, $6C, $58, $6C, $6E, $5A, $4B, $4A, $5B, $90, $6F, $91
	db $6F, $92, $6F, $93, $6F, $94, $5C, $5B, $90, $6F, $91, $6F
	db $92, $5C, $4B, $4A, $71, $72, $73, $72, $73, $72, $73, $72
	db $73, $72, $74, $71, $72, $73, $72, $73, $72, $74, $4B, $4A
	db $5B, $95, $6F, $96, $6F, $97, $6F, $98, $6F, $99, $5C, $5B
	db $93, $6F, $94, $6F, $95, $5C, $4B, $4A, $2D, $4F, $6B, $4F
	db $6B, $4F, $6B, $4F, $6B, $4F, $2E, $2D, $4F, $6B, $4F, $6B
	db $4F, $2E, $4B, $4A, $2C, $2C, $2C, $50, $51, $51, $51, $51
	db $51, $51, $51, $51, $51, $52, $2C, $2C, $2C, $2C, $4B, $4A
	db $2C, $2C, $2C, $53, $1D, $18, $19, $25, $1C, $0C, $18, $1B
	db $0E, $54, $2C, $2C, $2C, $2C, $4B, $4A, $55, $56, $70, $6D
	db $58, $58, $58, $58, $58, $58, $58, $58, $58, $6E, $56, $56
	db $56, $5A, $4B, $4A, $5B, $01, $6F, $60, $60, $60, $60, $60
	db $60, $2F, $2F, $60, $60, $60, $60, $60, $60, $5C, $4B, $4A
	db $5B, $02, $6F, $60, $60, $60, $60, $60, $60, $2F, $2F, $60
	db $60, $60, $60, $60, $60, $5C, $4B, $4A, $5B, $03, $6F, $60
	db $60, $60, $60, $60, $60, $2F, $2F, $60, $60, $60, $60, $60
	db $60, $5C, $4B, $4A, $2D, $4F, $6B, $4F, $4F, $4F, $4F, $4F
	db $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $2E, $4B, $4C
	db $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D
	db $4D, $4D, $4D, $4D, $4D, $4D, $4E, $CD, $CD, $CD, $CD, $CD
	db $CD, $CD, $CD, $CD, $CD, $8C, $C9, $CA, $8C, $8C, $8C, $8C
	db $8C, $8C, $8C, $8C, $CB, $CC, $8C, $8C, $8C, $8C, $8C, $8C
	db $CE, $D7, $D7, $D7, $D7, $D7, $D7, $D7, $D7, $D7, $CF, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $D0, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $D1, $D2, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $D3, $D4, $7C, $7C, $7C, $7C, $7C, $7C, $2F
	db $2F, $D5, $D6, $7D, $7D, $7D, $7D, $2F, $2F, $2F, $2F, $D8
	db $2F, $7B, $7B, $7B, $7B, $2F, $2F, $2F, $2F, $D8, $2F, $7C
	db $7C, $7C, $7C, $2F, $2F, $2F, $2F, $D8, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $D8, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $7C, $7C, $7C, $7C, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $7C, $7D, $7D, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $7D, $2F, $2F, $2F, $D9, $2F, $2F, $2F, $2F, $2F, $7B, $B7
	db $B8, $D9, $B7, $2F, $7C, $7C, $7C, $7C, $7C, $7D, $7D, $7D
	db $7D, $7D, $7D, $7D, $7D, $7D, $7D, $FF, $4A, $4A, $4A, $4A
	db $4A, $4A, $59, $69, $69, $69, $69, $69, $69, $49, $4A, $4A
	db $4A, $4A, $4A, $4A, $5A, $5A, $5A, $5A, $5A, $5A, $85, $85
	db $85, $85, $85, $85, $85, $85, $5A, $5A, $38, $39, $38, $5A
	db $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
	db $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $07, $07, $07, $07
	db $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
	db $07, $07, $07, $07, $47, $48, $48, $48, $48, $48, $48, $48
	db $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $49
	db $4A, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $16
	db $0A, $1B, $12, $18, $2F, $1F, $1C, $24, $15, $1E, $12, $10
	db $12, $2C, $2C, $4B, $4A, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	db $2C, $2C, $50, $51, $51, $51, $51, $52, $2C, $2C, $2C, $4B
	db $4A, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $53, $11
	db $12, $10, $11, $54, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $55
	db $56, $56, $5A, $2C, $2C, $2C, $75, $58, $6C, $58, $6C, $6E
	db $5A, $2C, $2C, $4B, $4A, $2C, $2C, $5B, $2F, $2F, $5C, $2C
	db $2C, $2C, $5B, $90, $6F, $91, $6F, $92, $5C, $2C, $2C, $4B
	db $4A, $2C, $2C, $5B, $2F, $2F, $5C, $2C, $2C, $2C, $71, $72
	db $73, $72, $73, $72, $74, $2C, $2C, $4B, $4A, $2C, $2C, $2D
	db $4F, $4F, $2E, $2C, $2C, $2C, $5B, $93, $6F, $94, $6F, $95
	db $5C, $2C, $2C, $4B, $4A, $2C, $2C, $16, $0A, $1B, $12, $18
	db $2C, $2C, $2D, $4F, $6B, $4F, $6B, $4F, $2E, $2C, $2C, $4B
	db $4A, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $50, $51
	db $51, $51, $51, $52, $2C, $2C, $2C, $4B, $4A, $2C, $2C, $2C
	db $2C, $2C, $2C, $2C, $2C, $2C, $53, $11, $12, $10, $11, $54
	db $2C, $2C, $2C, $4B, $4A, $2C, $2C, $55, $56, $56, $5A, $2C
	db $2C, $2C, $75, $58, $6C, $58, $6C, $6E, $5A, $2C, $2C, $4B
	db $4A, $2C, $2C, $5B, $2F, $2F, $5C, $2C, $2C, $2C, $5B, $90
	db $6F, $91, $6F, $92, $5C, $2C, $2C, $4B, $4A, $2C, $2C, $5B
	db $2F, $2F, $5C, $2C, $2C, $2C, $71, $72, $73, $72, $73, $72
	db $74, $2C, $2C, $4B, $4A, $2C, $2C, $2D, $4F, $4F, $2E, $2C
	db $2C, $2C, $5B, $93, $6F, $94, $6F, $95, $5C, $2C, $2C, $4B
	db $4A, $2C, $2C, $15, $1E, $12, $10, $12, $2C, $2C, $2D, $4F
	db $6B, $4F, $6B, $4F, $2E, $2C, $2C, $4B, $4C, $4D, $4D, $4D
	db $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D, $4D
	db $4D, $4D, $4D, $4E, $8E, $B2, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $B3, $30, $31, $31, $31, $31, $31, $32
	db $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $B5, $36, $2F, $2F, $2F, $2F, $2F, $37, $8E, $B0, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $B5, $36, $2F, $2F
	db $2F, $2F, $2F, $37, $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $B5, $40, $42, $42, $42, $42, $42, $41
	db $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $B5, $36, $11, $12, $10, $11, $2F, $37, $8E, $B0, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $B5, $36, $2F, $2F
	db $2F, $2F, $2F, $37, $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $B5, $33, $34, $34, $34, $34, $34, $35
	db $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $B5, $2B, $8E, $8E, $8E, $8E, $8E, $8E, $8E, $B0, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $B5, $30, $31, $31
	db $31, $31, $31, $32, $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $B5, $36, $15, $12, $17, $0E, $1C, $37
	db $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $B5, $36, $2F, $2F, $2F, $2F, $2F, $37, $8E, $B0, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $B5, $33, $34, $34
	db $34, $34, $34, $35, $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $B5, $2B, $38, $39, $39, $39, $39, $3A
	db $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $B5, $2B, $3B, $2F, $2F, $2F, $2F, $3C, $8E, $B0, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $B5, $2B, $3B, $2F
	db $2F, $2F, $2F, $3C, $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F
	db $2F, $2F, $2F, $2F, $B5, $2B, $3B, $2F, $2F, $2F, $2F, $3C
	db $8E, $B0, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F
	db $B5, $2B, $3B, $2F, $2F, $2F, $2F, $3C, $8E, $B1, $2F, $2F
	db $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $B4, $2B, $3D, $3E
	db $3E, $3E, $3E, $3F, $07, $07, $07, $07, $07, $07, $84, $87
	db $87, $8C, $87, $87, $8C, $87, $87, $8C, $87, $87, $86, $07
	db $07, $1E, $1E, $1E, $1E, $1E, $79, $2F, $2F, $8D, $2F, $2F
	db $8D, $2F, $2F, $8D, $2F, $2F, $88, $07, $07, $B4, $B5, $BB
	db $2E, $BC, $79, $2F, $2F, $8D, $2F, $2F, $8D, $2F, $2F, $8D
	db $2F, $2F, $88, $07, $07, $BF, $BF, $BF, $BF, $BF, $89, $8A
	db $8A, $8E, $8A, $8A, $8E, $8A, $8A, $8E, $8A, $8A, $8B, $07
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $16, $16, $16, $16
	db $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16
	db $16, $16, $16, $16, $07, $07, $07, $07, $07, $07, $84, $87
	db $87, $8C, $87, $87, $8C, $87, $87, $8C, $87, $87, $86, $07
	db $07, $1E, $1E, $1E, $1E, $1E, $79, $2F, $2F, $8D, $2F, $2F
	db $8D, $2F, $2F, $8D, $2F, $2F, $88, $07, $07, $BD, $B2, $2E
	db $BE, $2E, $79, $2F, $2F, $8D, $2F, $2F, $8D, $2F, $2F, $8D
	db $2F, $2F, $88, $07, $07, $BF, $BF, $BF, $BF, $BF, $89, $8A
	db $8A, $8E, $8A, $8A, $8E, $8A, $8A, $8E, $8A, $8A, $8B, $07
	db $01, $01, $01, $01, $01, $01, $02, $02, $03, $03, $01, $01
	db $01, $01, $02, $02, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $07, $18, $1F, $21, $3E, $47, $7F, $F2, $FE, $12, $1E
	db $12, $1E, $12, $1E, $7E, $7E, $FF, $83, $FF, $81, $FF, $FF
	db $00, $00, $00, $00, $00, $00, $00, $00, $07, $07, $18, $1F
	db $21, $3E, $47, $7F, $04, $FC, $02, $FE, $02, $FE, $07, $FD
	db $07, $FD, $1F, $FF, $FF, $FF, $FF, $FA, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $07, $07, $18, $1F
	db $FF, $FF, $77, $11, $FF, $11, $FF, $FF, $DD, $44, $FF, $44
	db $FF, $FF, $77, $11, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $03, $03
	db $05, $04, $03, $03, $00, $00, $18, $18, $2C, $24, $1A, $1A
	db $08, $08, $40, $40, $07, $07, $18, $1F, $A0, $BF, $3B, $3F
	db $7C, $44, $7C, $44, $10, $10, $02, $02, $E0, $E0, $18, $F8
	db $05, $FD, $8C, $FC, $78, $48, $6C, $74, $00, $00, $07, $07
	db $18, $1F, $20, $3F, $30, $3F, $1F, $1D, $3E, $22, $3E, $22
	db $80, $80, $80, $80, $80, $80, $80, $80, $00, $00, $C0, $C0
	db $E0, $E0, $E0, $E0, $00, $00, $7C, $7C, $66, $66, $66, $66
	db $7C, $7C, $60, $60, $60, $60, $00, $00, $00, $00, $3C, $3C
	db $60, $60, $3C, $3C, $0E, $0E, $4E, $4E, $3C, $3C, $00, $00
	db $07, $07, $1F, $18, $3E, $20, $7F, $4F, $7F, $5F, $70, $70
	db $A2, $A2, $B0, $B0, $04, $04, $07, $04, $04, $04, $04, $0D
	db $04, $0D, $04, $04, $04, $04, $03, $02, $5F, $7F, $39, $30
	db $7B, $62, $FB, $B2, $FF, $A0, $FF, $C2, $7F, $54, $7F, $5C
	db $00, $00, $00, $00, $00, $00, $03, $03, $04, $04, $08, $08
	db $09, $09, $04, $04, $5F, $7F, $39, $30, $7B, $62, $FB, $B2
	db $FF, $A0, $FF, $C2, $7F, $54, $7F, $5C, $18, $F8, $04, $FC
	db $02, $FE, $02, $FE, $07, $FD, $07, $FD, $FF, $FF, $FF, $FA
	db $20, $3F, $40, $7F, $40, $7F, $E0, $BF, $E0, $BF, $F8, $FF
	db $7F, $7F, $7F, $5F, $FF, $11, $FF, $FF, $DD, $44, $FF, $44
	db $FF, $FF, $77, $11, $FF, $11, $FF, $FF, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $C0, $40
	db $00, $00, $00, $00, $00, $00, $04, $04, $08, $08, $1C, $14
	db $14, $14, $08, $08, $18, $1F, $20, $3F, $40, $7F, $40, $7F
	db $E0, $BF, $E0, $BF, $7F, $7F, $7F, $5F, $DD, $44, $FF, $44
	db $FF, $FF, $77, $11, $FF, $11, $FF, $FF, $DD, $44, $FF, $44
	db $00, $00, $00, $00, $00, $00, $20, $20, $10, $10, $38, $28
	db $28, $28, $90, $90, $00, $00, $46, $46, $46, $46, $7E, $7E
	db $46, $46, $46, $46, $46, $46, $00, $00, $00, $00, $7E, $7E
	db $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $00, $00
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $00, $00, $00, $EE, $B4, $B4, $64, $64, $3C, $3C, $2E, $2E
	db $27, $27, $70, $70, $FC, $9C, $F7, $9F, $00, $00, $00, $00
	db $00, $00, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02
	db $3F, $2E, $7F, $63, $FF, $98, $F7, $1F, $F7, $1C, $F7, $D7
	db $34, $3F, $AC, $BF, $03, $03, $01, $01, $01, $01, $00, $00
	db $00, $00, $06, $06, $05, $05, $07, $07, $FF, $AE, $FF, $23
	db $FF, $18, $F7, $9F, $F7, $9C, $77, $57, $34, $3F, $6C, $7F
	db $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $02, $02
	db $02, $02, $02, $02, $3F, $2F, $7F, $7C, $F7, $9C, $F3, $1F
	db $F0, $1F, $F0, $DF, $30, $3F, $A0, $BF, $FF, $F4, $FF, $3E
	db $EF, $38, $CF, $F8, $0F, $FB, $0E, $FA, $0C, $FC, $04, $FC
	db $E0, $20, $E0, $20, $E0, $20, $C0, $40, $80, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $01, $01, $01, $02, $02, $02, $02, $3F, $2F, $3F, $3C
	db $77, $5C, $F3, $9F, $F0, $1F, $F0, $1F, $F0, $FF, $20, $3F
	db $FF, $F4, $FF, $3E, $EF, $38, $CF, $F9, $0E, $FA, $0E, $FA
	db $0C, $FC, $04, $FC, $C0, $40, $C0, $40, $C0, $40, $80, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $F7, $1C, $F7, $34
	db $F7, $BF, $6C, $7F, $10, $1F, $50, $5F, $32, $3F, $F1, $FF
	db $00, $00, $46, $46, $46, $46, $56, $56, $7E, $7E, $6E, $6E
	db $46, $46, $00, $00, $00, $00, $3C, $3C, $18, $18, $18, $18
	db $18, $18, $18, $18, $3C, $3C, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $02, $02, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $40, $7F, $C0, $FF, $20, $3F, $22, $3F
	db $11, $1F, $72, $7E, $BF, $BF, $FF, $FF, $07, $07, $06, $07
	db $06, $07, $06, $07, $07, $07, $00, $00, $00, $00, $00, $00
	db $C0, $FF, $00, $FF, $00, $FF, $02, $FF, $FF, $FF, $00, $00
	db $00, $00, $00, $00, $02, $02, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $40, $7F, $C0, $FF
	db $20, $3F, $20, $3F, $11, $1F, $72, $7E, $FF, $FF, $FF, $FF
	db $02, $FE, $02, $FE, $04, $FC, $04, $FC, $88, $F8, $4E, $7E
	db $FF, $FF, $FF, $FF, $00, $00, $00, $00, $80, $80, $40, $40
	db $00, $00, $00, $00, $00, $00, $07, $07, $00, $00, $00, $00
	db $FF, $00, $FD, $02, $CD, $32, $09, $F6, $08, $F7, $00, $FF
	db $00, $00, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FC, $03
	db $CC, $33, $08, $F7, $7C, $44, $3F, $3F, $10, $1F, $10, $1F
	db $12, $1F, $19, $1F, $3F, $3F, $3E, $3E, $CE, $F2, $8E, $DA
	db $09, $F9, $09, $F9, $4E, $FE, $98, $F8, $FC, $FC, $7C, $7C
	db $07, $07, $1F, $18, $3E, $20, $7F, $4F, $7F, $5F, $70, $70
	db $A2, $A2, $B0, $B0, $00, $00, $46, $46, $66, $66, $76, $76
	db $5E, $5E, $4E, $4E, $46, $46, $00, $00, $00, $00, $18, $18
	db $18, $18, $18, $18, $18, $18, $00, $00, $18, $18, $00, $00
	db $12, $1E, $12, $1E, $12, $1E, $12, $1E, $7E, $7E, $BF, $83
	db $FF, $81, $FF, $FF, $00, $00, $E0, $E0, $18, $F8, $04, $FC
	db $0C, $FC, $F8, $C8, $2C, $34, $2E, $32, $00, $00, $46, $46
	db $46, $46, $46, $46, $46, $46, $2C, $2C, $18, $18, $00, $00
	db $00, $00, $36, $36, $5F, $49, $5F, $41, $7F, $41, $3E, $22
	db $1C, $14, $08, $08, $FE, $02, $FD, $05, $FD, $05, $FF, $1F
	db $FF, $FC, $FF, $FE, $EF, $38, $EF, $39, $00, $04, $00, $04
	db $00, $04, $01, $05, $01, $05, $03, $07, $06, $06, $0C, $0C
	db $CA, $C0, $C8, $C0, $CA, $C0, $88, $80, $88, $87, $08, $00
	db $0A, $00, $08, $00, $6F, $13, $2F, $13, $6F, $13, $2F, $11
	db $2D, $D1, $2C, $10, $6C, $10, $2C, $10, $A0, $20, $A0, $20
	db $A0, $20, $A0, $A0, $A0, $A0, $E0, $E0, $60, $60, $30, $30
	db $08, $A8, $08, $18, $08, $A8, $08, $48, $08, $A8, $08, $18
	db $08, $A8, $08, $48, $00, $FE, $00, $FF, $7F, $FF, $7F, $C1
	db $7F, $C1, $7F, $EB, $7F, $C1, $01, $FF, $00, $00, $00, $00
	db $00, $00, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $00
	db $10, $10, $0B, $0B, $07, $04, $07, $04, $03, $02, $01, $01
	db $00, $00, $00, $00, $B4, $B4, $E4, $E4, $BC, $BC, $EE, $6E
	db $E7, $27, $F0, $10, $FC, $9C, $77, $5F, $00, $00, $00, $00
	db $07, $07, $1F, $18, $3F, $20, $7F, $40, $7F, $40, $7F, $40
	db $00, $00, $00, $00, $00, $00, $80, $80, $C0, $40, $C0, $40
	db $C0, $40, $80, $80, $02, $03, $05, $04, $07, $04, $04, $07
	db $04, $07, $04, $06, $04, $05, $04, $07, $CE, $FA, $0C, $FC
	db $08, $F8, $08, $F8, $08, $F8, $08, $F8, $08, $F8, $88, $F8
	db $00, $3C, $00, $7E, $10, $67, $24, $C3, $24, $C3, $24, $C3
	db $24, $C3, $34, $C3, $00, $3C, $00, $66, $00, $E7, $2C, $C3
	db $3C, $C3, $3C, $C3, $3C, $42, $18, $66, $00, $00, $00, $00
	db $00, $00, $20, $20, $90, $90, $B8, $A8, $A8, $A8, $10, $10
	db $0A, $10, $06, $08, $02, $04, $00, $04, $00, $04, $00, $04
	db $00, $04, $00, $04, $17, $50, $28, $60, $2A, $60, $28, $60
	db $2A, $60, $28, $60, $28, $67, $68, $60, $DE, $2B, $2E, $17
	db $6E, $17, $2E, $17, $6E, $17, $2E, $17, $2E, $D7, $2E, $17
	db $98, $48, $B0, $50, $A0, $60, $A0, $20, $A0, $20, $A0, $20
	db $A0, $20, $A0, $20, $08, $A8, $08, $18, $08, $A8, $08, $48
	db $08, $B8, $08, $3F, $08, $BF, $09, $7F, $00, $7F, $00, $FF
	db $7E, $FF, $7E, $C1, $7E, $C1, $7E, $EB, $7E, $C1, $00, $FF
	db $00, $00, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
	db $FF, $00, $FF, $00, $00, $00, $38, $38, $34, $24, $3C, $24
	db $3F, $27, $3C, $27, $3C, $27, $3F, $2F, $37, $3C, $17, $14
	db $17, $1F, $1C, $1F, $F0, $FF, $00, $FF, $02, $FF, $FF, $FF
	db $BF, $A0, $BF, $A0, $BF, $B8, $7F, $7F, $2F, $2F, $7F, $7F
	db $F7, $9C, $F7, $9C, $FD, $05, $FD, $05, $FD, $1D, $FF, $FF
	db $F7, $F4, $FF, $FE, $EF, $38, $EF, $38, $01, $01, $01, $01
	db $01, $01, $02, $02, $02, $02, $02, $02, $01, $01, $00, $00
	db $02, $02, $02, $02, $01, $01, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $34, $C3, $3C, $43, $3C, $43, $18, $66
	db $18, $66, $08, $76, $08, $36, $08, $34, $18, $26, $18, $24
	db $18, $24, $08, $34, $00, $18, $00, $08, $00, $08, $00, $08
	db $00, $00, $0F, $0F, $1F, $10, $3C, $20, $70, $40, $73, $43
	db $67, $4C, $3F, $28, $00, $00, $80, $80, $DC, $5C, $3E, $22
	db $32, $E2, $B1, $C1, $C3, $4B, $27, $7C, $00, $00, $00, $00
	db $00, $00, $00, $00, $E0, $E0, $D0, $10, $D0, $D0, $E0, $20
	db $5C, $50, $7C, $50, $39, $30, $7C, $4C, $EE, $82, $C0, $84
	db $60, $43, $31, $26, $1F, $3C, $BB, $62, $F1, $41, $61, $41
	db $C3, $03, $F7, $04, $EE, $08, $9C, $60, $90, $10, $08, $08
	db $18, $18, $3C, $64, $F2, $C2, $E3, $60, $39, $20, $F2, $00
	db $00, $FF, $00, $FF, $FF, $FF, $FF, $00, $FF, $00, $FF, $00
	db $00, $FF, $00, $FF, $FF, $FF, $FF, $00, $FF, $FF, $00, $FF
	db $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $38, $38, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $0E, $0E, $11, $11
	db $11, $11, $12, $12, $F3, $1F, $F0, $3F, $F0, $BF, $60, $7F
	db $10, $1F, $50, $5F, $30, $3F, $F1, $FF, $CF, $FB, $0C, $FC
	db $08, $F8, $08, $F8, $08, $F8, $08, $F8, $08, $F8, $88, $F8
	db $4E, $7A, $C9, $D9, $09, $F9, $0E, $FE, $48, $F8, $98, $F8
	db $FC, $FC, $7C, $7C, $A0, $BF, $40, $7F, $E0, $FF, $20, $3F
	db $11, $1F, $72, $7E, $FF, $FF, $FF, $FF, $00, $3C, $00, $1C
	db $00, $1C, $00, $18, $00, $08, $00, $00, $00, $00, $00, $00
	db $00, $FF, $00, $AB, $00, $55, $00, $FF, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $15, $00, $18, $00, $15, $00, $12
	db $00, $15, $00, $18, $00, $15, $00, $12, $40, $40, $40, $C0
	db $40, $40, $40, $40, $40, $40, $40, $C0, $40, $40, $40, $40
	db $0E, $32, $0E, $32, $0E, $32, $0E, $32, $0F, $33, $8F, $B3
	db $CE, $F3, $EE, $73, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $80, $80, $C0, $40, $00, $00, $00, $00
	db $80, $80, $47, $47, $1F, $18, $3F, $20, $7F, $40, $7F, $40
	db $7F, $40, $BF, $A0, $BF, $A0, $BF, $B8, $7F, $7F, $3F, $3F
	db $77, $7C, $F7, $9C, $F2, $E6, $F2, $E6, $F2, $E6, $F2, $E6
	db $F2, $E6, $F2, $E6, $F2, $E6, $F2, $E6, $00, $00, $01, $01
	db $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $01, $01
	db $F3, $9F, $F0, $1F, $F0, $3F, $E0, $BF, $70, $7F, $10, $1F
	db $50, $5F, $31, $3F, $3E, $22, $1F, $1F, $10, $1F, $10, $1F
	db $12, $1F, $19, $1F, $3F, $3F, $3E, $3E, $12, $1E, $12, $1E
	db $12, $1E, $12, $1E, $7E, $7E, $FF, $83, $FF, $81, $FF, $FF
	db $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02
	db $01, $01, $00, $00, $60, $E0, $80, $80, $80, $80, $80, $80
	db $80, $80, $80, $80, $80, $80, $80, $80, $07, $04, $07, $04
	db $07, $04, $07, $04, $07, $04, $07, $04, $07, $04, $07, $04
	db $0B, $09, $0B, $0A, $0F, $0A, $17, $12, $17, $1C, $14, $17
	db $17, $14, $2F, $24, $00, $00, $70, $70, $8F, $8F, $98, $9F
	db $E0, $FF, $F0, $9F, $78, $57, $7F, $4C, $3B, $2F, $D0, $DF
	db $F0, $FF, $C0, $FF, $C0, $FF, $FF, $FF, $00, $00, $00, $00
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $F8, $F8, $F0, $F2, $E1
	db $F5, $E3, $F2, $E6, $FF, $FF, $FF, $81, $C3, $81, $DF, $85
	db $DF, $85, $FF, $BD, $FF, $81, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $1F, $1F, $0F, $4F, $87, $AF, $C7, $4F, $67
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF
	db $FF, $FF, $00, $00, $4F, $67, $4F, $67, $4F, $67, $4F, $67
	db $4F, $67, $4F, $67, $4F, $67, $4F, $67, $F2, $E6, $F5, $E3
	db $F2, $E1, $F8, $F0, $FF, $F8, $FF, $FF, $FF, $FF, $FF, $FF
	db $00, $00, $FF, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $FF
	db $FF, $FF, $FF, $FF, $4F, $67, $AF, $C7, $4F, $87, $1F, $0F
	db $FF, $1F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $00, $00, $00, $00, $EF, $E7, $CF, $24, $0C
	db $24, $0C, $24, $0C, $24, $0C, $24, $0C, $24, $0C, $24, $0C
	db $24, $0C, $24, $0C, $24, $0C, $E7, $CF, $00, $EF, $00, $00
	db $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF, $07, $07, $18, $1F
	db $21, $3E, $47, $7F, $5F, $7F, $39, $30, $7B, $62, $FB, $B2
	db $E0, $E0, $18, $F8, $84, $7C, $E2, $FE, $FA, $FE, $9C, $0C
	db $DE, $46, $DF, $4D, $FF, $A0, $FF, $C2, $7F, $54, $7F, $5C
	db $3F, $2E, $3F, $23, $1F, $18, $07, $07, $FF, $05, $FF, $43
	db $FE, $2A, $FE, $3A, $FC, $74, $FC, $C4, $F8, $18, $E0, $E0
	db $07, $07, $1F, $18, $3E, $20, $7F, $4F, $7F, $5F, $70, $70
	db $A2, $A2, $B0, $B0, $E0, $E0, $F8, $18, $7C, $04, $FE, $F2
	db $FE, $FA, $0E, $0E, $45, $45, $0D, $0D, $B4, $B4, $64, $64
	db $3C, $3C, $2E, $2E, $27, $27, $10, $10, $0C, $0C, $03, $03
	db $2D, $2D, $26, $26, $3C, $3C, $74, $74, $E4, $E4, $08, $08
	db $30, $30, $C0, $C0, $2F, $24, $2F, $24, $2F, $24, $2F, $24
	db $67, $7C, $BC, $A7, $FF, $E4, $1B, $1B, $00, $00, $00, $00
	db $01, $01, $01, $01, $03, $03, $03, $03, $03, $02, $07, $04
	db $04, $07, $07, $04, $07, $04, $04, $04, $06, $06, $05, $05
	db $05, $05, $06, $06, $07, $04, $07, $04, $04, $07, $04, $04
	db $04, $04, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06
	db $04, $04, $07, $07, $05, $05, $03, $03, $05, $05, $0E, $0E
	db $0F, $1F, $01, $10, $01, $10, $01, $10, $01, $08, $01, $07
	db $04, $09, $00, $0F, $08, $01, $F8, $F1, $4E, $C1, $02, $C7
	db $8C, $BD, $84, $AD, $62, $CF, $7E, $FE, $EC, $90, $EF, $9F
	db $FA, $F7, $DA, $E7, $BD, $BD, $B5, $AD, $D2, $EF, $7F, $7F
	db $F8, $F8, $18, $E8, $38, $88, $B8, $08, $B0, $10, $E0, $E0
	db $D0, $30, $F0, $F0, $18, $18, $30, $30, $60, $60, $C0, $C0
	db $C0, $C0, $FF, $FF, $83, $83, $60, $62, $0A, $00, $08, $00
	db $08, $07, $08, $00, $08, $01, $F8, $F1, $F8, $F1, $08, $01
	db $6C, $10, $2C, $10, $2C, $D1, $2C, $11, $AC, $90, $EF, $9F
	db $EF, $9F, $EC, $90, $18, $18, $0C, $0C, $06, $C6, $03, $C3
	db $03, $03, $FF, $FF, $C1, $C1, $06, $46, $00, $04, $00, $0C
	db $02, $10, $02, $10, $02, $10, $02, $10, $02, $10, $02, $10
	db $0C, $4C, $0C, $4C, $09, $49, $0B, $4B, $0A, $4A, $10, $50
	db $12, $52, $10, $50, $7E, $33, $7E, $33, $BE, $93, $FE, $D3
	db $7E, $53, $3E, $0B, $7E, $4B, $3E, $0B, $A0, $20, $90, $30
	db $98, $48, $98, $48, $98, $48, $98, $48, $98, $48, $98, $48
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $00, $01
	db $02, $02, $02, $02, $02, $02, $02, $03, $02, $03, $02, $02
	db $02, $02, $02, $03, $02, $02, $06, $06, $0E, $0A, $0E, $0A
	db $0B, $0A, $0B, $0A, $0F, $0A, $0A, $0A, $06, $06, $0A, $0A
	db $1A, $12, $1F, $1F, $00, $00, $00, $00, $1F, $1F, $3F, $20
	db $7F, $47, $7C, $4C, $7C, $4C, $7C, $4C, $00, $00, $00, $00
	db $E0, $E0, $F0, $30, $F8, $18, $F8, $98, $F8, $98, $F8, $98
	db $7F, $4F, $7F, $40, $7F, $4F, $7C, $4C, $7C, $4C, $7C, $7C
	db $00, $00, $00, $00, $F8, $98, $F8, $18, $F8, $98, $F8, $98
	db $F8, $98, $F8, $F8, $00, $00, $00, $00, $00, $00, $7C, $7C
	db $4E, $4E, $4E, $4E, $4E, $4E, $4E, $4E, $7C, $7C, $00, $00
	db $00, $00, $7E, $7E, $60, $60, $7C, $7C, $60, $60, $60, $60
	db $7E, $7E, $00, $00, $00, $00, $46, $46, $46, $46, $46, $46
	db $46, $46, $4E, $4E, $3C, $3C, $00, $00, $00, $00, $3C, $3C
	db $66, $66, $60, $60, $60, $60, $66, $66, $3C, $3C, $00, $00
	db $00, $00, $46, $46, $6E, $6E, $7E, $7E, $56, $56, $46, $46
	db $46, $46, $00, $00, $00, $00, $3C, $3C, $4E, $4E, $4E, $4E
	db $7E, $7E, $4E, $4E, $4E, $4E, $00, $00, $FF, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $FF, $01
	db $01, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
	db $F0, $F0, $F0, $B0, $F0, $B0, $F0, $F0, $00, $00, $00, $00
	db $07, $07, $18, $1F, $20, $3F, $30, $3F, $18, $17, $3F, $2C
	db $7B, $4F, $70, $5F, $90, $9F, $90, $9F, $70, $7F, $11, $1F
	db $3E, $3E, $3E, $3E, $00, $00, $7C, $7C, $66, $66, $66, $66
	db $7C, $7C, $68, $68, $66, $66, $00, $00, $00, $00, $3C, $3C
	db $66, $66, $66, $66, $66, $66, $66, $66, $3C, $3C, $00, $00
	db $00, $00, $60, $60, $60, $60, $60, $60, $60, $60, $60, $60
	db $7E, $7E, $00, $00, $00, $00, $3C, $3C, $66, $66, $60, $60
	db $6E, $6E, $66, $66, $3E, $3E, $00, $00, $00, $EE, $00, $00
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $00, $01, $00, $02, $00, $02, $00, $04, $00, $08, $00, $08
	db $00, $10, $00, $10, $80, $80, $C0, $40, $C0, $40, $E0, $20
	db $30, $50, $30, $50, $38, $48, $18, $28, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $03, $00, $03, $00, $02, $00, $02
	db $00, $00, $00, $00, $00, $00, $00, $00, $08, $F8, $08, $18
	db $08, $A8, $08, $48, $00, $80, $00, $80, $00, $80, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $00, $20
	db $00, $20, $1F, $20, $00, $40, $00, $40, $00, $40, $00, $40
	db $1C, $24, $0C, $34, $0C, $34, $04, $FC, $0E, $32, $0E, $32
	db $0E, $32, $0E, $32, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $1F, $00, $18, $00, $15, $00, $12
	db $00, $00, $00, $00, $00, $00, $00, $00, $40, $C0, $40, $C0
	db $40, $40, $40, $40, $00, $02, $00, $03, $00, $02, $00, $02
	db $00, $02, $00, $03, $00, $02, $00, $02, $08, $AF, $08, $1A
	db $08, $AD, $08, $4F, $08, $A8, $08, $18, $08, $A8, $08, $48
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $00, $02, $00, $40, $15, $40, $15, $40, $15, $40
	db $15, $C0, $15, $C1, $17, $43, $16, $46, $24, $0C, $34, $0C
	db $34, $04, $FC, $0E, $32, $0E, $32, $0E, $32, $0E, $32, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $2A, $20, $01
	db $00, $1D, $01, $09, $00, $07, $01, $0B, $00, $03, $20, $04
	db $00, $20, $20, $06, $00, $0A, $80, $17, $00, $06, $01, $06
	db $00, $04, $01, $05, $00, $1E, $80, $0B, $00, $06, $80, $1C
	db $00, $0A, $10, $08, $11, $04, $01, $02, $00, $04, $01, $06
	db $00, $00, $10, $06, $00, $04, $10, $05, $00, $1A, $80, $24
	db $00, $15, $01, $07, $00, $20, $10, $04, $00, $05, $10, $03
	db $00, $0D, $10, $06, $00, $03, $10, $05, $00, $25, $80, $15
	db $00, $1B, $10, $04, $00, $13, $80, $03, $00, $1C, $80, $19
	db $00, $1A, $01, $06, $00, $0A, $20, $01, $00, $09, $20, $02
	db $00, $14, $10, $03, $00, $0E, $80, $16, $00, $0A, $10, $0A
	db $11, $06, $10, $16, $00, $13, $80, $25, $00, $1C, $01, $06
	db $00, $03, $20, $02, $00, $0E, $20, $03, $00, $04, $20, $02
	db $00, $03, $20, $05, $00, $0D, $80, $21, $00, $13, $01, $07
	db $00, $05, $01, $06, $00, $04, $01, $05, $00, $06, $20, $03
	db $00, $05, $20, $02, $00, $1C, $20, $03, $00, $0E, $80, $12
	db $00, $0C, $10, $04, $00, $02, $01, $08, $00, $10, $01, $08
	db $00, $1E, $80, $19, $00, $10, $10, $03, $00, $04, $10, $05
	db $00, $24, $80, $1C, $00, $05, $01, $05, $00, $11, $20, $03
	db $00, $12, $80, $20, $00, $0A, $10, $01, $11, $06, $01, $00
	db $00, $04, $10, $04, $00, $04, $10, $03, $00, $02, $10, $19
	db $00, $04, $10, $07, $00, $0A, $00, $00, $00, $00, $00, $00
	db $00, $4D, $20, $08, $21, $06, $20, $0B, $00, $07, $20, $06
	db $00, $64, $10, $00, $11, $06, $10, $05, $00, $2F, $80, $16
	db $00, $17, $20, $05, $00, $06, $20, $06, $00, $10, $80, $18
	db $00, $34, $01, $05, $00, $01, $10, $0E, $11, $06, $10, $20
	db $00, $0A, $80, $0A, $00, $2B, $20, $06, $00, $06, $20, $05
	db $00, $05, $20, $06, $00, $0A, $80, $0C, $00, $0A, $01, $07
	db $00, $02, $10, $0B, $00, $05, $10, $04, $00, $0D, $80, $1C
	db $00, $75, $01, $06, $00, $0E, $80, $1F, $00, $1A, $01, $06
	db $00, $00, $10, $07, $00, $05, $10, $06, $00, $04, $10, $08
	db $00, $03, $10, $08, $00, $0C, $80, $0F, $00, $0A, $01, $07
	db $00, $00, $10, $3D, $00, $05, $80, $1F, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $10, $18, $00, $04, $08, $00, $04, $08
	db $08, $00, $04, $14, $10, $08, $10, $10, $14, $18, $14, $00
	db $0C, $04, $18, $00, $14, $14, $08, $04, $04, $0C, $00, $18
	db $04, $00, $08, $0C, $0C, $18, $00, $0C, $08, $00, $18, $10
	db $14, $14, $18, $08, $AA, $65, $C6, $65, $FC, $66, $28, $66
	db $34, $67, $AF, $66, $F1, $65, $54, $66, $B2, $65, $CE, $65
	db $14, $67, $CE, $65, $CE, $65, $C3, $66, $F7, $65, $60, $66
	db $D4, $67, $DC, $67, $9D, $67, $A5, $67, $E4, $67, $E4, $67
	db $E4, $67, $AD, $67, $3F, $6F, $4A, $6F, $55, $6F, $60, $6F
	db $6B, $6F, $76, $6F, $81, $6F, $8C, $6F, $97, $6F, $A2, $6F
	db $AD, $6F, $B8, $6F, $C3, $6F, $CE, $6F, $D9, $6F, $E4, $6F
	db $EF, $6F, $C9
l_64d3:
	db $F5, $C5, $D5, $E5, $FA, $7F, $DF, $FE, $01
	db $28, $46, $FE, $02, $28, $7B, $FA, $7E, $DF, $A7, $20, $7B
	db $F0, $E4, $A7, $28, $0D, $AF, $EA, $E0, $DF, $EA, $E8, $DF
	db $EA, $F0, $DF, $EA, $F8, $DF, $CD, $D2, $64, $CD, $DD, $69
	db $CD, $FD, $69, $CD, $3C, $68, $CD, $21, $6A, $CD, $44, $6C
	db $CD, $65, $6A, $AF, $EA, $E0, $DF, $EA, $E8, $DF, $EA, $F0
	db $DF, $EA, $F8, $DF, $EA, $7F, $DF, $E1, $D1, $C1, $F1, $C9

	db $CD, $C7, $69, $AF, $EA, $E1, $DF, $EA, $F1, $DF, $EA, $F9
	db $DF, $21, $BF, $DF, $CB, $BE, $21, $9F, $DF, $CB, $BE, $21
	db $AF, $DF, $CB, $BE, $21, $CF, $DF, $CB, $BE, $21, $E9, $6E
	db $CD, $98, $69, $3E, $30, $EA, $7E, $DF, $21, $7B, $65, $CD
	db $5D, $69, $18, $B7, $21, $7F, $65, $18, $F6, $AF, $EA, $7E
	db $DF, $18, $85, $21, $7E, $DF, $35, $7E, $FE, $28, $28, $EC
	db $FE, $20, $28, $E0, $FE, $18, $28, $E4, $FE, $10, $20, $97
	db $34, $18, $94, $B2, $E3, $83, $C7, $B2, $E3, $C1, $C7, $FA
	db $F1, $DF, $FE, $01, $C9, $FA, $E1, $DF, $FE, $05, $C9, $FA
	db $E1, $DF, $FE, $07, $C9, $FA, $E1, $DF, $FE, $08, $C9, $00
	db $B5, $D0, $40, $C7, $00, $B5, $20, $40, $C7, $00, $B6, $A1
	db $80, $C7, $3E, $05, $21, $9B, $65, $C3, $36, $69, $CD, $8B
	db $69, $A7, $C0, $21, $E4, $DF, $34, $7E, $FE, $02, $28, $13
	db $21, $A0, $65, $C3, $56, $69, $3E, $03, $21, $A5, $65, $C3
	db $36, $69, $CD, $8B, $69, $A7, $C0, $AF, $EA, $E1, $DF, $E0
	db $10, $3E, $08, $E0, $12, $3E, $80, $E0, $14, $21, $9F, $DF
	db $CB, $BE, $C9, $00, $80, $E1, $C1, $87, $00, $80, $E1, $AC
	db $87, $21, $E7, $65, $C3, $36, $69, $21, $E4, $DF, $34, $7E
	db $FE, $04, $28, $17, $FE, $0B, $28, $19, $FE, $0F, $28, $0F
	db $FE, $18, $CA, $0E, $66, $C9, $3E, $01, $21, $F0, $DF, $77
	db $C3, $D3, $65, $21, $EC, $65, $C3, $56, $69, $21, $E7, $65
	db $C3, $56, $69, $48, $BC, $42, $66, $87, $CD, $83, $65, $C8
	db $CD, $95, $65, $C8, $CD, $8F, $65, $C8, $CD, $89, $65, $C8
	db $3E, $02, $21, $23, $66, $C3, $36, $69, $00, $B0, $F1, $B6
	db $C7, $00, $B0, $F1, $C4, $C7, $00, $B0, $F1, $CE, $C7, $00
	db $B0, $F1, $DB, $C7, $CD, $8F, $65, $C8, $3E, $07, $21, $40
	db $66, $C3, $36, $69, $CD, $8B, $69, $A7, $C0, $21, $E4, $DF
	db $34, $7E, $FE, $01, $28, $12, $FE, $02, $28, $13, $FE, $03
	db $28, $14, $FE, $04, $28, $15, $FE, $05, $CA, $D3, $65, $C9
	db $21, $45, $66, $18, $0D, $21, $4A, $66, $18, $08, $21, $4F
	db $66, $18, $03, $21, $40, $66, $C3, $56, $69, $3E, $80, $E3
	db $00, $C4, $93, $83, $83, $73, $63, $53, $43, $33, $23, $13
	db $00, $00, $23, $43, $63, $83, $A3, $C3, $D3, $E3, $FF, $CD
	db $83, $65, $C8, $CD, $95, $65, $C8, $CD, $8F, $65, $C8, $3E
	db $06, $21, $95, $66, $C3, $36, $69, $CD, $8B, $69, $A7, $C0
	db $21, $E4, $DF, $4E, $34, $06, $00, $21, $9A, $66, $09, $7E
	db $A7, $CA, $D3, $65, $5F, $21, $A5, $66, $09, $7E, $57, $06
	db $86, $0E, $12, $7B, $E2, $0C, $7A, $E2, $0C, $78, $E2, $C9
	db $3B, $80, $B2, $87, $87, $A2, $93, $62, $43, $23, $00, $80
	db $40, $80, $40, $80, $CD, $83, $65, $C8, $CD, $95, $65, $C8
	db $CD, $8F, $65, $C8, $CD, $89, $65, $C8, $3E, $03, $21, $EC
	db $66, $C3, $36, $69, $CD, $8B, $69, $A7, $C0, $21, $E4, $DF
	db $4E, $34, $06, $00, $21, $F1, $66, $09, $7E, $A7, $CA, $D3
	db $65, $5F, $21, $F7, $66, $09, $7E, $57, $06, $87, $18, $AD
	db $CD, $8F, $65, $C8, $3E, $28, $21, $40, $67, $C3, $36, $69
	db $B7, $80, $90, $FF, $83, $00, $D1, $45, $80, $00, $F1, $54
	db $80, $00, $D5, $65, $80, $00, $70, $66, $80, $65, $65, $65
	db $64, $57, $56, $55, $54, $54, $54, $54, $54, $47, $46, $46
	db $45, $45, $45, $44, $44, $44, $34, $34, $34, $34, $34, $34
	db $34, $34, $34, $34, $34, $34, $34, $34, $34, $70, $60, $70
	db $70, $70, $80, $90, $A0, $D0, $F0, $E0, $D0, $C0, $B0, $A0
	db $90, $80, $70, $60, $50, $40, $30, $30, $20, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $10, $10, $3E, $30, $21
	db $4D, $67, $C3, $36, $69, $3E, $30, $21, $51, $67, $C3, $36
	db $69, $CD, $8B, $69, $A7, $C0, $21, $FC, $DF, $7E, $4F, $FE
	db $24, $CA, $E9, $67, $34, $06, $00, $C5, $21, $55, $67, $09
	db $7E, $E0, $22, $C1, $21, $79, $67, $09, $7E, $E0, $21, $3E
	db $80, $E0, $23, $C9, $3E, $20, $21, $49, $67, $C3, $36, $69
	db $3E, $12, $21, $45, $67, $C3, $36, $69, $CD, $8B, $69, $A7
	db $C0, $AF, $EA, $F9, $DF, $3E, $08, $E0, $21, $3E, $80, $E0
	db $23, $21, $CF, $DF, $CB, $BE, $C9, $80, $3A, $20, $60, $C6
	db $21, $D9, $6E, $CD, $0D, $69, $F0, $04, $E6, $1F, $47, $3E
	db $D0, $80, $EA, $F5, $DF, $21, $FB, $67, $C3, $64, $69, $F0
	db $04, $E6, $0F, $47, $21, $F4, $DF, $34, $7E, $21, $F5, $DF
	db $FE, $0E, $30, $0A, $34, $34, $7E, $E6, $F0, $B0, $0E, $1D
	db $E2, $C9, $FE, $1E, $CA, $E2, $68, $35, $35, $35, $18, $EE
	db $FA, $F0, $DF, $FE, $01, $CA, $6B, $68, $FE, $02, $CA, $00
	db $68, $FA, $F1, $DF, $FE, $01, $CA, $B6, $68, $FE, $02, $CA
	db $17, $68, $C9, $80, $80, $20, $9D, $87, $80, $F8, $20, $98
	db $87, $80, $FB, $20, $96, $87, $80, $F6, $20, $95, $87, $21
	db $A9, $6E, $CD, $0D, $69, $21, $5A, $68, $7E, $EA, $F6, $DF
	db $3E, $01, $EA, $F5, $DF, $21, $57, $68, $C3, $64, $69, $3E
	db $00, $EA, $F5, $DF, $21, $5F, $68, $7E, $EA, $F6, $DF, $21
	db $5C, $68, $18, $EC, $3E, $01, $EA, $F5, $DF, $21, $64, $68
	db $7E, $EA, $F6, $DF, $21, $61, $68, $18, $DB, $3E, $02, $EA
	db $F5, $DF, $21, $69, $68, $7E, $EA, $F6, $DF, $21, $66, $68
	db $18, $CA, $21, $F4, $DF, $34, $2A, $FE, $09, $28, $C4, $FE
	db $13, $28, $D1, $FE, $17, $28, $DE, $FE, $20, $28, $17, $2A
	db $FE, $00, $C8, $FE, $01, $28, $05, $FE, $02, $28, $05, $C9
	db $34, $34, $18, $02, $35, $35, $7E, $E0, $1D, $C9, $AF, $EA
	db $F1, $DF, $E0, $1A, $21, $BF, $DF, $CB, $BE, $21, $9F, $DF
	db $CB, $BE, $21, $AF, $DF, $CB, $BE, $21, $CF, $DF, $CB, $BE
	db $FA, $E9, $DF, $FE, $05, $28, $05, $21, $E9, $6E, $18, $2A
	db $21, $C9, $6E, $18, $25, $E5, $EA, $F1, $DF, $21, $BF, $DF
	db $CB, $FE, $AF, $EA, $F4, $DF, $EA, $F5, $DF, $EA, $F6, $DF
	db $E0, $1A, $21, $9F, $DF, $CB, $FE, $21, $AF, $DF, $CB, $FE
	db $21, $CF, $DF, $CB, $FE, $E1, $CD, $98, $69, $C9, $F5, $1D
	db $FA, $71, $DF, $12, $1C, $F1, $1C, $12, $1D, $AF, $12, $1C
	db $1C, $12, $1C, $12, $7B, $FE, $E5, $28, $09, $FE, $F5, $28
	db $13, $FE, $FD, $28, $16, $C9, $C5, $0E, $10, $06, $05, $18
	db $13, $C5, $0E, $16, $06, $04, $18, $0C, $C5, $0E, $1A, $06
	db $05, $18, $05, $C5, $0E, $20, $06, $04, $2A, $E2, $0C, $05
	db $20, $FA, $C1, $C9, $1C, $EA, $71, $DF, $1C, $3D, $CB, $27
	db $4F, $06, $00, $09, $4E, $23, $46, $69, $60, $7C, $C9, $D5
	db $6B, $62, $34, $2A, $BE, $20, $03, $2D, $AF, $77, $D1, $C9
	db $C5, $0E, $30, $2A, $E2, $0C, $79, $FE, $40, $20, $F8, $C1
	db $C9, $AF, $EA, $E1, $DF, $EA, $E9, $DF, $EA, $F1, $DF, $EA
	db $F9, $DF, $EA, $9F, $DF, $EA, $AF, $DF, $EA, $BF, $DF, $EA
	db $CF, $DF, $3E, $FF, $E0, $25, $3E, $03, $EA, $78, $DF, $3E
	db $08, $E0, $12, $E0, $17, $E0, $21, $3E, $80, $E0, $14, $E0
	db $19, $E0, $23, $AF, $E0, $10, $E0, $1A, $C9, $11, $E0, $DF
	db $1A, $A7, $28, $0C, $21, $9F, $DF, $CB, $FE, $21, $80, $64
	db $CD, $78, $69, $E9, $1C, $1A, $A7, $28, $07, $21, $90, $64
	db $CD, $7C, $69, $E9, $C9, $11, $F8, $DF, $1A, $A7, $28, $0C
	db $21, $CF, $DF, $CB, $FE, $21, $A0, $64, $CD, $78, $69, $E9
	db $1C, $1A, $A7, $28, $07, $21, $A8, $64, $CD, $7C, $69, $E9
	db $C9, $CD, $A5, $69, $C9, $21, $E8, $DF, $2A, $A7, $C8, $FE
	db $FF, $28, $F2, $77, $47, $21, $B0, $64, $E6, $1F, $CD, $7C
	db $69, $CD, $13, $6B, $CD, $3C, $6A, $C9, $FA, $E9, $DF, $A7
	db $C8, $21, $BE, $6A, $3D, $28, $06, $23, $23, $23, $23, $18
	db $F7, $2A, $EA, $78, $DF, $2A, $EA, $76, $DF, $2A, $EA, $79
	db $DF, $2A, $EA, $7A, $DF, $AF, $EA, $75, $DF, $EA, $77, $DF
	db $C9, $FA, $E9, $DF, $A7, $28, $3D, $21, $75, $DF, $FA, $78
	db $DF, $FE, $01, $28, $37, $FE, $03, $28, $2F, $34, $2A, $BE
	db $20, $33, $2D, $36, $00, $2C, $2C, $34, $FA, $79, $DF, $CB
	db $46, $CA, $8F, $6A, $FA, $7A, $DF, $47, $FA, $F1, $DF, $A7
	db $28, $04, $CB, $D0, $CB, $F0, $FA, $F9, $DF, $A7, $28, $04
	db $CB, $D8, $CB, $F8, $78, $E0, $25, $C9, $3E, $FF, $18, $F9
	db $FA, $79, $DF, $18, $DE, $FA, $F9, $DF, $A7, $20, $F1, $FA
	db $F1, $DF, $A7, $20, $EB, $C9, $01, $24, $EF, $56, $01, $00
	db $E5, $00, $01, $20, $FD, $00, $01, $20, $DE, $F7, $03, $18
	db $7F, $F7, $03, $18, $F7, $7F, $03, $48, $DF, $5B, $01, $18
	db $DB, $E7, $01, $00, $FD, $F7, $03, $20, $7F, $F7, $01, $20
	db $ED, $F7, $01, $20, $ED, $F7, $01, $20, $ED, $F7, $01, $20
	db $ED, $F7, $01, $20, $ED, $F7, $01, $20, $EF, $F7, $01, $20
	db $EF, $F7, $2A, $4F, $7E, $47, $0A, $12, $1C, $03, $0A, $12
	db $C9, $2A, $12, $1C, $2A, $12, $C9, $CD, $C7, $69, $AF, $EA
	db $75, $DF, $EA, $77, $DF, $11, $80, $DF, $06, $00, $2A, $12
	db $1C, $CD, $0D, $6B, $11, $90, $DF, $CD, $0D, $6B, $11, $A0
	db $DF, $CD, $0D, $6B, $11, $B0, $DF, $CD, $0D, $6B, $11, $C0
	db $DF, $CD, $0D, $6B, $21, $90, $DF, $11, $94, $DF, $CD, $02
	db $6B, $21, $A0, $DF, $11, $A4, $DF, $CD, $02, $6B, $21, $B0
	db $DF, $11, $B4, $DF, $CD, $02, $6B, $21, $C0, $DF, $11, $C4
	db $DF, $CD, $02, $6B, $01, $10, $04, $21, $92, $DF, $36, $01
	db $79, $85, $6F, $05, $20, $F8, $AF, $EA, $9E, $DF, $EA, $AE
	db $DF, $EA, $BE, $DF, $C9, $E5, $AF, $E0, $1A, $6B, $62, $CD
	db $98, $69, $E1, $18, $2A, $CD, $B9, $6B, $CD, $CE, $6B, $5F
	db $CD, $B9, $6B, $CD, $CE, $6B, $57, $CD, $B9, $6B, $CD, $CE
	db $6B, $4F, $2C, $2C, $73, $2C, $72, $2C, $71, $2D, $2D, $2D
	db $2D, $E5, $21, $70, $DF, $7E, $E1, $FE, $03, $28, $CA, $CD
	db $B9, $6B, $C3, $5E, $6C, $D5, $2A, $5F, $3A, $57, $13, $7B
	db $22, $7A, $32, $D1, $C9, $D5, $2A, $5F, $3A, $57, $13, $13
	db $18, $F1, $2A, $4F, $3A, $47, $0A, $47, $C9, $E1, $18, $2C
	db $FA, $70, $DF, $FE, $03, $20, $10, $FA, $B8, $DF, $CB, $7F
	db $28, $09, $7E, $FE, $06, $20, $04, $3E, $40, $E0, $1C, $E5
	db $7D, $C6, $09, $6F, $7E, $A7, $20, $DD, $7D, $C6, $04, $6F
	db $CB, $7E, $20, $D5, $E1, $CD, $67, $6D, $2D, $2D, $C3, $39
	db $6D, $2D, $2D, $2D, $2D, $CD, $C5, $6B, $7D, $C6, $04, $5F
	db $54, $CD, $02, $6B, $FE, $00, $28, $1F, $FE, $FF, $28, $04
	db $2C, $C3, $5C, $6C, $2D, $E5, $CD, $C5, $6B, $CD, $CE, $6B
	db $5F, $CD, $B9, $6B, $CD, $CE, $6B, $57, $E1, $7B, $22, $7A
	db $32, $18, $D5, $21, $E9, $DF, $36, $00, $CD, $A5, $69, $C9
	db $21, $E9, $DF, $7E, $A7, $C8, $3E, $01, $EA, $70, $DF, $21
	db $90, $DF, $2C, $2A, $A7, $CA, $04, $6C, $35, $C2, $D8, $6B
	db $2C, $2C, $CD, $CE, $6B, $FE, $00, $CA, $09, $6C, $FE, $9D
	db $CA, $89, $6B, $E6, $F0, $FE, $A0, $20, $1A, $78, $E6, $0F
	db $4F, $06, $00, $E5, $11, $81, $DF, $1A, $6F, $13, $1A, $67
	db $09, $7E, $E1, $2D, $22, $CD, $B9, $6B, $CD, $CE, $6B, $78
	db $4F, $06, $00, $CD, $B9, $6B, $FA, $70, $DF, $FE, $04, $CA
	db $BC, $6C, $E5, $7D, $C6, $05, $6F, $5D, $54, $2C, $2C, $79
	db $FE, $01, $28, $0F, $36, $00, $21, $02, $6E, $09, $2A, $12
	db $1C, $7E, $12, $E1, $C3, $D3, $6C, $36, $01, $E1, $18, $17
	db $E5, $11, $C6, $DF, $21, $94, $6E, $09, $2A, $12, $1C, $7B
	db $FE, $CB, $20, $F8, $0E, $20, $21, $C4, $DF, $18, $2E, $E5
	db $FA, $70, $DF, $FE, $01, $28, $21, $FE, $02, $28, $19, $0E
	db $1A, $FA, $BF, $DF, $CB, $7F, $20, $05, $AF, $E2, $3E, $80
	db $E2, $0C, $2C, $2C, $2C, $2C, $2A, $5F, $16, $00, $18, $15
	db $0E, $16, $18, $05, $0E, $10, $3E, $00, $0C, $2C, $2C, $2C
	db $3A, $A7, $20, $4F, $2A, $5F, $2C, $2A, $57, $E5, $2C, $2C
	db $2A, $A7, $28, $02, $1E, $01, $2C, $2C, $36, $00, $2C, $7E
	db $E1, $CB, $7F, $20, $13, $7A, $E2, $0C, $7B, $E2, $0C, $2A
	db $E2, $0C, $7E, $F6, $80, $E2, $7D, $F6, $05, $6F, $CB, $86
	db $E1, $2D, $3A, $32, $2D, $11, $70, $DF, $1A, $FE, $04, $28
	db $09, $3C, $12, $11, $10, $00, $19, $C3, $52, $6C, $21, $9E
	db $DF, $34, $21, $AE, $DF, $34, $21, $BE, $DF, $34, $C9, $06
	db $00, $E5, $E1, $2C, $18, $AC, $78, $CB, $3F, $6F, $26, $00
	db $19, $5E, $C9, $E5, $7D, $C6, $06, $6F, $7E, $E6, $0F, $28
	db $18, $EA, $71, $DF, $FA, $70, $DF, $0E, $13, $FE, $01, $28
	db $0E, $0E, $18, $FE, $02, $28, $08, $0E, $1D, $FE, $03, $28
	db $02, $E1, $C9, $2C, $2A, $5F, $7E, $57, $D5, $7D, $C6, $04
	db $6F, $46, $FA, $71, $DF, $FE, $01, $18, $09, $FE, $03, $18
	db $00, $21, $FF, $FF, $18, $1C, $11, $CB, $6D, $CD, $5E, $6D
	db $CB, $40, $20, $02, $CB, $33, $7B, $E6, $0F, $CB, $5F, $28
	db $06, $26, $FF, $F6, $F0, $18, $02, $26, $00, $6F, $D1, $19
	db $7D, $E2, $0C, $7C, $E2, $18, $BE, $00, $00, $00, $00, $00
	db $00, $10, $00, $0F, $00, $00, $11, $00, $0F, $F0, $01, $12
	db $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF
	db $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01
	db $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10
	db $FF, $EF, $00, $0F, $2C, $00, $9C, $00, $06, $01, $6B, $01
	db $C9, $01, $23, $02, $77, $02, $C6, $02, $12, $03, $56, $03
	db $9B, $03, $DA, $03, $16, $04, $4E, $04, $83, $04, $B5, $04
	db $E5, $04, $11, $05, $3B, $05, $63, $05, $89, $05, $AC, $05
	db $CE, $05, $ED, $05, $0A, $06, $27, $06, $42, $06, $5B, $06
	db $72, $06, $89, $06, $9E, $06, $B2, $06, $C4, $06, $D6, $06
	db $E7, $06, $F7, $06, $06, $07, $14, $07, $21, $07, $2D, $07
	db $39, $07, $44, $07, $4F, $07, $59, $07, $62, $07, $6B, $07
	db $73, $07, $7B, $07, $83, $07, $8A, $07, $90, $07, $97, $07
	db $9D, $07, $A2, $07, $A7, $07, $AC, $07, $B1, $07, $B6, $07
	db $BA, $07, $BE, $07, $C1, $07, $C4, $07, $C8, $07, $CB, $07
	db $CE, $07, $D1, $07, $D4, $07, $D6, $07, $D9, $07, $DB, $07
	db $DD, $07, $DF, $07, $00, $00, $00, $00, $00, $C0, $A1, $00
	db $3A, $00, $C0, $B1, $00, $29, $01, $C0, $61, $00, $3A, $00
	db $C0, $12, $34, $45, $67, $9A, $BC, $DE, $FE, $98, $7A, $B7
	db $BE, $A8, $76, $54, $31, $01, $23, $44, $55, $67, $88, $9A
	db $BB, $A9, $88, $76, $55, $44, $33, $22, $11, $01, $23, $45
	db $67, $89, $AB, $CD, $EF, $FE, $DC, $BA, $98, $76, $54, $32
	db $10, $A1, $82, $23, $34, $45, $56, $67, $78, $89, $9A, $AB
	db $BC, $CD, $64, $32, $10, $11, $23, $56, $78, $99, $98, $76
	db $67, $9A, $DF, $FE, $C9, $85, $42, $11, $31, $02, $04, $08
	db $10, $20, $40, $0C, $18, $30, $05, $00, $01, $03, $05, $0A
	db $14, $28, $50, $0F, $1E, $3C, $03, $06, $0C, $18, $30, $60
	db $12, $24, $48, $08, $10, $00, $07, $0E, $1C, $38, $70, $15
	db $2A, $54, $04, $08, $10, $20, $40, $80, $18, $30, $60, $04
	db $09, $12, $24, $48, $90, $1B, $36, $6C, $0C, $18, $04, $0A
	db $14, $28, $50, $A0, $1E, $3C, $78, $00, $0E, $6F, $F9, $7C
	db $FF, $7C, $11, $7D, $21, $7D, $00, $05, $6F, $48, $7E, $44
	db $7E, $4A, $7E, $4C, $7E, $00, $0E, $6F, $3B, $76, $33, $76
	db $41, $76, $63, $76, $00, $F9, $6E, $00, $76, $FC, $75, $02
	db $76, $00, $00, $00, $0E, $6F, $4C, $71, $42, $71, $56, $71
	db $62, $71, $00, $0E, $6F, $C6, $72, $B8, $72, $D4, $72, $02
	db $73, $00, $0E, $6F, $08, $70, $FA, $6F, $00, $00, $00, $00
	db $00, $05, $6F, $9D, $7E, $91, $7E, $A9, $7E, $B5, $7E, $00
	db $0E, $6F, $28, $7C, $24, $7C, $2A, $7C, $2C, $7C, $00, $0E
	db $6F, $00, $00, $00, $7A, $00, $00, $00, $00, $00, $0E, $6F
	db $00, $00, $26, $7A, $2A, $7A, $00, $00, $00, $0E, $6F, $73
	db $7A, $6F, $7A, $75, $7A, $00, $00, $00, $0E, $6F, $DF, $7A
	db $E3, $7A, $E5, $7A, $E7, $7A, $00, $0E, $6F, $65, $7B, $6B
	db $7B, $6F, $7B, $73, $7B, $00, $0E, $6F, $6C, $78, $76, $78
	db $7E, $78, $86, $78, $00, $2B, $6F, $43, $75, $4B, $75, $51
	db $75, $00, $00, $00, $0E, $6F, $8D, $75, $95, $75, $9B, $75
	db $00, $00, $16, $70, $34, $70, $16, $70, $4D, $70, $93, $70
	db $FF, $FF, $FA, $6F, $62, $70, $74, $70, $62, $70, $85, $70
	db $F4, $70, $FF, $FF, $08, $70, $9D, $74, $00, $41, $A2, $44
	db $4C, $56, $4C, $42, $4C, $44, $4C, $3E, $4C, $3C, $4C, $44
	db $4C, $56, $4C, $42, $4C, $44, $4C, $3E, $4C, $3C, $4C, $00
	db $44, $4C, $44, $3E, $4E, $48, $42, $48, $42, $3A, $4C, $44
	db $3E, $4C, $48, $44, $42, $3E, $3C, $34, $3C, $42, $4C, $48
	db $00, $44, $4C, $44, $3E, $4E, $48, $42, $48, $42, $3A, $52
	db $48, $4C, $52, $4C, $44, $3A, $42, $A8, $44, $00, $9D, $64
	db $00, $41, $A3, $26, $3E, $3C, $26, $2C, $34, $3E, $36, $34
	db $3E, $2C, $34, $00, $26, $3E, $30, $22, $3A, $2C, $1E, $36
	db $30, $A2, $34, $36, $34, $30, $2C, $2A, $00, $A3, $26, $3E
	db $30, $22, $3A, $2A, $2C, $34, $34, $2C, $22, $14, $00, $A2
	db $52, $4E, $4C, $48, $44, $42, $44, $48, $4C, $44, $48, $4E
	db $4C, $4E, $A3, $52, $42, $A2, $44, $48, $A3, $4C, $48, $4C
	db $56, $50, $A2, $56, $5A, $A3, $5C, $5A, $A2, $56, $52, $50
	db $4C, $50, $4A, $A8, $4C, $A7, $52, $A1, $56, $58, $A3, $56
	db $A2, $52, $4E, $52, $4C, $4E, $48, $A7, $56, $A1, $5A, $5C
	db $A3, $5A, $A2, $56, $54, $56, $50, $54, $4C, $5A, $54, $4C
	db $54, $5A, $60, $66, $54, $64, $54, $60, $54, $A3, $5C, $A2
	db $60, $5C, $5A, $5C, $A1, $56, $5A, $A4, $56, $A2, $01, $00
	db $A2, $34, $3A, $44, $3A, $30, $3A, $34, $3A, $2C, $3A, $2A
	db $3A, $2C, $3A, $44, $3A, $30, $3A, $34, $3A, $2C, $3A, $2A
	db $3A, $2C, $34, $2C, $26, $3E, $38, $32, $38, $2A, $38, $32
	db $38, $A3, $34, $42, $2A, $A2, $34, $3A, $42, $3A, $30, $3A
	db $2E, $34, $26, $34, $2E, $34, $A8, $30, $A2, $32, $38, $2A
	db $38, $32, $38, $A8, $34, $A3, $34, $2A, $24, $1C, $20, $24
	db $2C, $30, $34, $A8, $26, $00, $68, $71, $68, $71, $AE, $71
	db $FF, $FF, $42, $71, $CB, $71, $CB, $71, $1D, $72, $FF, $FF
	db $4C, $71, $3A, $72, $3A, $72, $7F, $72, $7F, $72, $FF, $FF
	db $56, $71, $A3, $72, $FF, $FF, $62, $71, $9D, $84, $00, $81
	db $A3, $52, $A2, $48, $4A, $A3, $4E, $A2, $4A, $48, $A3, $44
	db $A2, $44, $4A, $A3, $52, $A2, $4E, $4A, $A7, $48, $A2, $4A
	db $A3, $4E, $52, $A3, $4A, $44, $44, $01, $A2, $01, $A3, $4E
	db $A2, $54, $A3, $5C, $A2, $58, $54, $A7, $52, $A2, $4A, $A3
	db $52, $A2, $4E, $4A, $A3, $48, $A2, $48, $4A, $A3, $4E, $52
	db $A3, $4A, $44, $44, $01, $00, $9D, $50, $00, $81, $A4, $3A
	db $32, $36, $30, $A4, $32, $2C, $A8, $2A, $A3, $01, $A4, $3A
	db $32, $36, $30, $A3, $32, $3A, $A4, $44, $42, $01, $00, $9D
	db $43, $00, $81, $A3, $48, $A2, $42, $44, $48, $A1, $52, $4E
	db $A2, $44, $42, $A7, $3A, $A2, $44, $4A, $01, $A2, $48, $44
	db $A1, $42, $42, $A2, $3A, $42, $44, $A3, $48, $4A, $A3, $44
	db $3A, $3A, $01, $A2, $1E, $A3, $3C, $A2, $44, $4A, $A1, $4A
	db $4A, $A2, $48, $44, $A7, $40, $A2, $3A, $40, $A1, $44, $40
	db $A2, $3C, $3A, $42, $3A, $42, $44, $48, $42, $4A, $42, $A1
	db $44, $4A, $3A, $01, $A3, $3A, $3A, $01, $00, $9D, $30, $00
	db $81, $A4, $32, $2C, $30, $2A, $2C, $22, $A4, $22, $A3, $30
	db $01, $A4, $32, $2C, $30, $2A, $A3, $2C, $32, $A4, $3A, $36
	db $01, $00, $9D, $C9, $6E, $20, $A2, $22, $3A, $22, $3A, $22
	db $3A, $22, $3A, $2C, $44, $2C, $44, $2C, $44, $2C, $44, $2A
	db $42, $2A, $42, $22, $3A, $22, $3A, $2C, $44, $2C, $44, $2C
	db $44, $30, $32, $36, $1E, $01, $1E, $01, $1E, $2C, $24, $1A
	db $32, $01, $32, $1A, $28, $28, $01, $30, $48, $01, $48, $01
	db $3A, $01, $42, $2C, $3A, $2C, $3A, $A3, $2C, $01, $00, $9D
	db $C9, $6E, $20, $A2, $44, $52, $44, $52, $44, $52, $44, $52
	db $42, $52, $42, $52, $42, $52, $42, $52, $44, $52, $44, $52
	db $44, $52, $44, $52, $42, $52, $42, $52, $A4, $01, $00, $A2
	db $01, $06, $01, $06, $01, $A1, $06, $06, $A2, $01, $06, $01
	db $06, $01, $06, $01, $06, $06, $06, $00, $0B, $73, $3F, $73
	db $67, $73, $67, $73, $C9, $73, $FF, $FF, $B8, $72, $08, $73
	db $3C, $73, $8E, $73, $8E, $73, $4B, $74, $FF, $FF, $C6, $72
	db $1F, $73, $53, $73, $B5, $73, $B5, $73, $B5, $73, $B5, $73
	db $B5, $73, $B5, $73, $C0, $74, $DE, $74, $DE, $74, $DE, $74
	db $EE, $74, $FE, $74, $FE, $74, $0E, $75, $0E, $75, $1E, $75
	db $1E, $75, $0E, $75, $2E, $75, $FF, $FF, $D4, $72, $33, $73
	db $FF, $FF, $02, $73, $A5, $01, $00, $9D, $62, $00, $80, $A2
	db $3A, $A1, $3A, $3A, $A2, $30, $30, $3A, $A1, $3A, $3A, $A2
	db $30, $30, $00, $9D, $E9, $6E, $A0, $A2, $3A, $A1, $3A, $3A
	db $A2, $30, $30, $3A, $A1, $3A, $3A, $A2, $30, $30, $00, $A2
	db $06, $A1, $06, $06, $A2, $06, $06, $00, $A5, $01, $00, $9D
	db $32, $00, $80, $A2, $3A, $A1, $3A, $3A, $A2, $30, $30, $3A
	db $A1, $3A, $3A, $A2, $30, $30, $00, $9D, $E9, $6E, $A0, $A2
	db $3A, $A1, $3A, $3A, $A2, $30, $30, $3A, $A1, $3A, $3A, $A2
	db $30, $30, $00, $9D, $82, $00, $80, $A2, $3A, $48, $52, $50
	db $52, $A1, $48, $48, $A2, $4A, $44, $48, $A1, $40, $40, $A2
	db $44, $3E, $40, $A1, $3A, $3A, $A2, $3E, $38, $3A, $30, $32
	db $38, $3A, $30, $32, $3E, $00, $9D, $53, $00, $40, $A2, $30
	db $40, $40, $44, $40, $A1, $3E, $40, $A2, $44, $3E, $40, $A1
	db $38, $3A, $A2, $3E, $38, $3A, $A1, $2E, $30, $A2, $38, $30
	db $30, $28, $2C, $2C, $30, $28, $2C, $38, $00, $9D, $E9, $6E
	db $A0, $A2, $3A, $A1, $3A, $3A, $A2, $30, $30, $3A, $A1, $3A
	db $3A, $A2, $30, $30, $00, $A8, $3A, $A2, $3E, $38, $A8, $3A
	db $A3, $3E, $A2, $40, $A1, $40, $40, $A2, $44, $3E, $40, $A1
	db $40, $40, $A2, $44, $3E, $A8, $40, $A3, $44, $A2, $48, $A1
	db $48, $48, $A2, $4A, $44, $48, $A1, $48, $48, $A2, $4A, $44
	db $A8, $48, $A3, $4C, $A2, $4E, $A1, $4E, $4E, $A2, $4E, $4E
	db $52, $4E, $4E, $4C, $4E, $A1, $4E, $4E, $A2, $4E, $4E, $52
	db $4E, $4E, $4C, $4E, $A1, $4E, $4E, $A2, $4E, $4E, $4C, $A1
	db $4C, $4C, $A2, $4C, $4C, $4A, $A1, $4A, $4A, $A2, $4A, $44
	db $3E, $40, $44, $36, $44, $A1, $40, $40, $A2, $36, $A3, $40
	db $A1, $36, $3A, $A2, $36, $30, $44, $A1, $40, $40, $A2, $36
	db $A3, $40, $A1, $36, $3A, $A2, $36, $2E, $A5, $36, $A8, $01
	db $A3, $38, $00, $A8, $30, $A2, $30, $30, $A8, $30, $A3, $36
	db $A5, $01, $A8, $01, $A3, $3E, $A2, $40, $A1, $40, $40, $A2
	db $44, $3E, $40, $A1, $40, $40, $A2, $44, $3E, $A8, $36, $A3
	db $3A, $A2, $3E, $A1, $40, $44, $A2, $3E, $44, $48, $48, $48
	db $3A, $3E, $A1, $40, $44, $A2, $3E, $44, $46, $46, $46, $3A
	db $3E, $A1, $40, $44, $A2, $3E, $44, $3A, $A1, $3E, $40, $A2
	db $3A, $40, $3A, $A1, $3E, $40, $A2, $3E, $3E, $2C, $3A, $3E
	db $26, $30, $A1, $30, $30, $A2, $30, $A3, $30, $A1, $30, $34
	db $A2, $30, $28, $2E, $A1, $2E, $2E, $A2, $2E, $A3, $2E, $A1
	db $2E, $32, $A2, $2E, $28, $A5, $26, $A8, $01, $A3, $2C, $00
	db $A2, $3A, $A1, $3A, $3A, $A2, $32, $2C, $3A, $A1, $3A, $3A
	db $A2, $38, $30, $3A, $A1, $3A, $3A, $A2, $32, $2C, $3A, $A1
	db $3A, $3A, $A2, $2C, $1E, $00, $A2, $28, $A1, $40, $28, $A2
	db $1E, $36, $28, $A1, $40, $28, $A2, $1E, $36, $00, $A2, $28
	db $A1, $40, $28, $A2, $1E, $36, $28, $A1, $40, $28, $A2, $2C
	db $44, $00, $A2, $1E, $A1, $36, $1E, $A2, $1E, $36, $28, $A1
	db $40, $28, $A2, $28, $40, $00, $A2, $1E, $A1, $36, $1E, $A2
	db $1E, $36, $1E, $A1, $36, $1E, $A2, $1E, $36, $00, $A2, $22
	db $A1, $3A, $22, $A2, $22, $3A, $22, $A1, $3A, $22, $A2, $22
	db $3A, $00, $A2, $1E, $A1, $36, $1E, $A2, $1E, $36, $1E, $A1
	db $36, $1E, $A2, $A4, $3E, $00, $36, $3E, $44, $A4, $44, $57
	db $75, $62, $75, $FF, $FF, $45, $75, $5E, $75, $FF, $FF, $4B
	db $75, $7C, $75, $FF, $FF, $51, $75, $9D, $20, $00, $81, $AA
	db $01, $00, $9D, $70, $00, $81, $A2, $42, $32, $38, $42, $46
	db $34, $3C, $46, $4A, $38, $42, $4A, $4C, $3C, $42, $4C, $46
	db $34, $3C, $46, $40, $2E, $34, $40, $00, $9D, $E9, $6E, $21
	db $A8, $42, $A3, $2A, $A8, $42, $A3, $2A, $A8, $42, $A3, $2A
	db $00, $A1, $75, $AC, $75, $FF, $FF, $8F, $75, $A8, $75, $FF
	db $FF, $95, $75, $EE, $75, $FF, $FF, $9B, $75, $9D, $20, $00
	db $81, $AA, $01, $00, $9D, $70, $00, $81, $A2, $4C, $42, $50
	db $42, $54, $42, $50, $42, $56, $42, $54, $42, $50, $42, $54
	db $42, $4C, $42, $50, $42, $54, $42, $50, $42, $56, $42, $54
	db $42, $50, $42, $54, $42, $5A, $46, $56, $46, $54, $46, $50
	db $46, $4E, $46, $50, $46, $54, $46, $50, $46, $50, $3E, $4C
	db $3E, $4C, $3E, $4A, $3E, $4A, $3E, $46, $3E, $4A, $3E, $50
	db $3E, $00, $9D, $E9, $6E, $21, $A5, $4C, $4A, $46, $42, $38
	db $3E, $42, $42, $00, $04, $76, $00, $00, $14, $76, $23, $76
	db $9D, $B2, $00, $80, $A2, $60, $5C, $60, $5C, $60, $62, $60
	db $5C, $A4, $60, $00, $9D, $92, $00, $80, $A2, $52, $4E, $52
	db $4E, $52, $54, $52, $4E, $A4, $52, $9D, $E9, $6E, $20, $A2
	db $62, $60, $62, $60, $62, $66, $62, $60, $A3, $62, $01, $6F
	db $76, $69, $77, $69, $77, $00, $00, $BF, $76, $AA, $77, $3C
	db $78, $0C, $77, $EB, $77, $EB, $77, $F5, $77, $EB, $77, $EB
	db $77, $FE, $77, $F5, $77, $EB, $77, $EB, $77, $FE, $77, $F5
	db $77, $07, $78, $11, $78, $FE, $77, $F5, $77, $EB, $77, $5B
	db $77, $5B, $77, $1A, $78, $1A, $78, $1A, $78, $1A, $78, $9D
	db $C3, $00, $80, $A2, $3C, $3E, $3C, $3E, $38, $50, $A3, $01
	db $A2, $3C, $3E, $3C, $3E, $38, $50, $A3, $01, $A2, $01, $48
	db $01, $46, $01, $42, $01, $46, $A1, $42, $46, $A2, $42, $42
	db $38, $A3, $3C, $01, $A2, $3E, $42, $3E, $42, $3C, $54, $A3
	db $01, $A2, $3E, $42, $3E, $42, $3C, $54, $A3, $01, $A2, $01
	db $56, $01, $54, $01, $54, $01, $50, $A2, $01, $A1, $50, $54
	db $A2, $50, $4E, $A3, $50, $01, $00, $9D, $74, $00, $80, $A2
	db $36, $38, $36, $38, $2E, $3E, $A3, $01, $A2, $36, $38, $36
	db $38, $2E, $3E, $A3, $01, $A2, $01, $36, $01, $36, $01, $32
	db $01, $36, $36, $32, $32, $30, $A3, $36, $01, $A2, $38, $3C
	db $38, $3C, $36, $4E, $A3, $01, $A2, $38, $3C, $38, $3C, $36
	db $4E, $A3, $01, $A2, $01, $50, $01, $4E, $01, $46, $01, $46
	db $A2, $01, $A1, $48, $4E, $A2, $48, $46, $A3, $40, $01, $00
	db $9D, $E9, $6E, $20, $A2, $48, $46, $48, $46, $3E, $20, $A3
	db $01, $A2, $48, $46, $48, $46, $3E, $20, $A3, $01, $A2, $2E
	db $3C, $2E, $24, $24, $24, $24, $3C, $2A, $3E, $2A, $3E, $A6
	db $2E, $A3, $01, $A1, $01, $A2, $48, $46, $48, $46, $2E, $2E
	db $A3, $01, $A2, $48, $46, $48, $46, $2E, $2E, $A3, $01, $A2
	db $2A, $3C, $2A, $3C, $2E, $3E, $2E, $3E, $2E, $42, $2E, $42
	db $A6, $38, $A3, $01, $A1, $01, $00, $A8, $01, $A2, $06, $0B
	db $A8, $01, $A2, $06, $0B, $A5, $01, $01, $00, $9D, $C5, $00
	db $80, $A1, $46, $4A, $A4, $46, $A2, $01, $A3, $50, $A8, $4A
	db $A3, $01, $A1, $42, $46, $A4, $42, $A2, $01, $A3, $4E, $A1
	db $4E, $50, $A4, $46, $A7, $01, $A1, $40, $46, $A4, $40, $A2
	db $01, $A3, $46, $A1, $46, $4A, $A4, $42, $A7, $01, $A1, $36
	db $38, $A4, $36, $A2, $01, $A3, $3C, $A7, $42, $A4, $40, $A2
	db $01, $00, $9D, $84, $00, $41, $A1, $40, $42, $A4, $40, $A2
	db $01, $A3, $40, $A8, $42, $A3, $01, $A1, $3C, $40, $A4, $3C
	db $A2, $01, $A3, $3C, $A1, $3C, $40, $A4, $40, $A7, $01, $A1
	db $36, $32, $A4, $2E, $A2, $01, $A3, $40, $A1, $36, $38, $A4
	db $32, $A7, $01, $A1, $2E, $32, $A4, $2E, $A2, $01, $A3, $2A
	db $A7, $30, $A4, $2E, $A2, $01, $00, $A2, $38, $38, $01, $38
	db $38, $38, $01, $38, $00, $2E, $2E, $01, $2E, $2E, $2E, $01
	db $2E, $00, $2A, $2A, $01, $2A, $2A, $2A, $01, $2A, $00, $A2
	db $38, $38, $01, $38, $36, $36, $01, $36, $00, $32, $32, $01
	db $32, $2E, $2E, $01, $2E, $00, $A2, $06, $0B, $01, $06, $06
	db $0B, $01, $06, $06, $0B, $01, $06, $06, $0B, $01, $06, $06
	db $0B, $01, $06, $06, $0B, $01, $06, $06, $0B, $01, $06, $01
	db $0B, $01, $0B, $00, $9D, $66, $00, $81, $A7, $58, $5A, $A3
	db $58, $A7, $5E, $A4, $5A, $A2, $01, $A7, $50, $54, $A3, $58
	db $A7, $5A, $A4, $58, $A2, $01, $A7, $50, $A3, $4E, $A7, $4E
	db $58, $54, $A3, $4A, $A7, $5A, $5E, $A3, $5A, $A7, $54, $A4
	db $50, $A2, $01, $00, $8E, $78, $11, $79, $8E, $78, $96, $79
	db $00, $00, $AD, $78, $38, $79, $AD, $78, $BA, $79, $D5, $78
	db $5E, $79, $D5, $78, $DD, $79, $FE, $78, $84, $79, $FE, $78
	db $84, $79, $9D, $D1, $00, $80, $A2, $5C, $A1, $5C, $5A, $A2
	db $5C, $5C, $56, $52, $4E, $56, $A2, $52, $A1, $52, $50, $A2
	db $52, $52, $4C, $48, $44, $A1, $4C, $52, $00, $9D, $B2, $00
	db $80, $A2, $52, $A1, $52, $52, $A2, $52, $A1, $52, $52, $A2
	db $44, $A1, $44, $44, $A2, $44, $01, $4C, $A1, $4C, $4C, $A2
	db $4C, $A1, $4C, $4C, $A2, $3A, $A1, $3A, $3A, $A2, $3A, $01
	db $00, $9D, $E9, $6E, $20, $A2, $5C, $A1, $5C, $5C, $A2, $5C
	db $A1, $5C, $5C, $A2, $4E, $A1, $52, $52, $A2, $56, $01, $A2
	db $5C, $A1, $5C, $5C, $A2, $5C, $A1, $5C, $5C, $A2, $44, $A1
	db $48, $48, $A2, $4C, $01, $00, $A2, $06, $A7, $01, $A2, $0B
	db $0B, $0B, $01, $A2, $06, $A7, $01, $A2, $0B, $0B, $0B, $01
	db $00, $A2, $48, $A1, $48, $52, $A2, $44, $A1, $44, $52, $A2
	db $42, $A1, $42, $52, $A2, $48, $A1, $48, $52, $A2, $4C, $A1
	db $4C, $52, $A2, $44, $A1, $44, $52, $A2, $48, $44, $A1, $48
	db $52, $56, $5A, $00, $3A, $A1, $3A, $3A, $A2, $3A, $A1, $3A
	db $3A, $A2, $3A, $A1, $3A, $3A, $A2, $3A, $A1, $3A, $3A, $A2
	db $3A, $A1, $3A, $3A, $A2, $3A, $A1, $3A, $3A, $A2, $36, $A1
	db $36, $36, $A2, $36, $01, $00, $48, $A1, $48, $48, $A2, $48
	db $A1, $48, $48, $A2, $48, $A1, $48, $48, $A2, $48, $A1, $48
	db $48, $A2, $44, $A1, $44, $44, $A2, $44, $A1, $44, $44, $A2
	db $42, $A1, $42, $42, $A2, $42, $01, $00, $A2, $01, $0B, $01
	db $0B, $01, $0B, $01, $0B, $01, $0B, $01, $0B, $01, $0B, $0B
	db $01, $00, $A2, $48, $A1, $48, $52, $A2, $44, $A1, $44, $52
	db $A2, $42, $A1, $42, $52, $A2, $48, $A1, $48, $52, $A2, $4C
	db $A1, $4C, $52, $A2, $48, $A1, $48, $52, $A2, $44, $52, $A3
	db $5C, $00, $3A, $A1, $3A, $3A, $A2, $3A, $A1, $3A, $3A, $A2
	db $3A, $A1, $3A, $3A, $A2, $3A, $A1, $3A, $3A, $A2, $3A, $A1
	db $3A, $3A, $A2, $3A, $A1, $3A, $3A, $A2, $01, $3A, $A3, $4C
	db $00, $48, $A1, $48, $48, $A2, $48, $A1, $48, $48, $A2, $48
	db $A1, $48, $48, $A2, $48, $A1, $48, $48, $A2, $44, $A1, $44
	db $44, $A2, $44, $A1, $44, $44, $A2, $01, $4C, $A3, $44, $00
	db $04, $7A, $00, $00, $9D, $C2, $00, $40, $A2, $5C, $A1, $5C
	db $5A, $A2, $5C, $5C, $56, $52, $4E, $56, $A2, $52, $A1, $52
	db $50, $A2, $52, $52, $4C, $48, $A1, $44, $42, $A2, $44, $A4
	db $01, $00, $2C, $7A, $00, $00, $4B, $7A, $9D, $C2, $00, $80
	db $A2, $5C, $A1, $5C, $5A, $A2, $5C, $5C, $56, $52, $4E, $56
	db $A2, $52, $A1, $52, $50, $A2, $52, $4C, $44, $52, $A3, $5C
	db $A4, $01, $00, $9D, $E9, $6E, $20, $A2, $5C, $A1, $5C, $5C
	db $A2, $5C, $A1, $5C, $5C, $A2, $4E, $52, $56, $01, $A2, $5C
	db $A1, $5C, $5C, $A2, $5C, $A1, $5C, $5C, $A2, $52, $4C, $44
	db $01, $A5, $01, $77, $7A, $00, $00, $96, $7A, $B4, $7A, $9D
	db $C2, $00, $80, $A2, $5C, $A1, $5C, $5A, $A2, $5C, $5C, $56
	db $52, $4E, $56, $A2, $52, $A1, $52, $50, $A2, $52, $4C, $44
	db $52, $A3, $5C, $A4, $01, $00, $9D, $C2, $00, $40, $A2, $4E
	db $A1, $4E, $52, $A2, $56, $4E, $A3, $48, $48, $A2, $4C, $A1
	db $4C, $4A, $A2, $4C, $44, $34, $4C, $A3, $4C, $A5, $01, $00
	db $9D, $E9, $6E, $20, $A2, $5C, $A1, $5C, $5C, $A2, $5C, $A1
	db $5C, $5C, $A2, $4E, $52, $A1, $56, $56, $A2, $56, $A2, $5C
	db $A1, $5C, $5C, $A2, $5C, $A1, $5C, $5C, $A2, $52, $4C, $A1
	db $44, $44, $A2, $01, $A5, $01, $00, $E9, $7A, $00, $00, $08
	db $7B, $25, $7B, $4F, $7B, $9D, $C2, $00, $80, $A2, $5C, $A1
	db $5C, $5A, $A2, $5C, $5C, $56, $52, $4E, $56, $A2, $52, $A1
	db $52, $50, $A2, $52, $4C, $44, $52, $A3, $5C, $A4, $01, $00
	db $9D, $B2, $00, $80, $A2, $4E, $A1, $4E, $52, $A2, $56, $4E
	db $A3, $48, $48, $A2, $4C, $A1, $4C, $4A, $A2, $4C, $44, $34
	db $4C, $A3, $4C, $A5, $01, $9D, $E9, $6E, $20, $A2, $5C, $A1
	db $5C, $5C, $A2, $5C, $A1, $5C, $5C, $4E, $56, $5C, $56, $4E
	db $44, $3E, $44, $A2, $5C, $A1, $5C, $5C, $A2, $5C, $A1, $5C
	db $5C, $52, $4C, $44, $4C, $5C, $01, $A2, $01, $A5, $01, $A2
	db $0B, $0B, $0B, $0B, $A2, $0B, $0B, $0B, $01, $A2, $0B, $0B
	db $0B, $0B, $A2, $0B, $0B, $0B, $01, $A5, $01, $77, $7B, $CE
	db $7B, $00, $00, $96, $7B, $F2, $7B, $A8, $7B, $02, $7C, $BB
	db $7B, $12, $7C, $9D, $D1, $00, $80, $A2, $5C, $A1, $5C, $5A
	db $A2, $5C, $5C, $56, $52, $4E, $56, $A2, $52, $A1, $52, $50
	db $A2, $52, $52, $4C, $48, $44, $A1, $4C, $52, $00, $A2, $52
	db $A7, $01, $A2, $44, $44, $44, $01, $4C, $A7, $01, $A2, $3A
	db $3A, $3A, $01, $00, $A2, $5C, $A7, $01, $A2, $4E, $52, $56
	db $01, $A2, $5C, $A7, $01, $A2, $44, $48, $4C, $01, $00, $A2
	db $06, $A7, $01, $A2, $0B, $0B, $0B, $01, $A2, $06, $A7, $01
	db $A2, $0B, $0B, $0B, $01, $00, $A2, $48, $A1, $48, $52, $A2
	db $44, $A1, $44, $52, $A2, $42, $A1, $42, $52, $A2, $48, $A1
	db $48, $52, $A2, $4C, $A1, $4C, $52, $A2, $48, $A1, $48, $52
	db $A2, $5C, $52, $A3, $5C, $00, $01, $3A, $01, $3A, $01, $3A
	db $01, $3A, $01, $3A, $01, $3A, $01, $3A, $A3, $34, $01, $48
	db $01, $48, $01, $48, $01, $48, $01, $44, $01, $44, $01, $4C
	db $A3, $44, $A2, $01, $0B, $01, $0B, $01, $0B, $01, $0B, $01
	db $0B, $01, $0B, $A2, $01, $0B, $0B, $01, $2E, $7C, $00, $00
	db $63, $7C, $97, $7C, $CB, $7C, $9D, $B3, $00, $80, $A6, $52
	db $A1, $50, $A6, $52, $A1, $50, $A6, $52, $A1, $48, $A3, $01
	db $A6, $4C, $A1, $4A, $A6, $4C, $A1, $4A, $A6, $4C, $A1, $42
	db $A3, $01, $A6, $3E, $A1, $42, $A6, $44, $A1, $48, $A6, $4C
	db $A1, $50, $A6, $52, $A1, $56, $A6, $52, $A1, $6A, $00, $9D
	db $93, $00, $C0, $A6, $42, $A1, $40, $A6, $42, $A1, $40, $A6
	db $42, $A1, $42, $A3, $01, $A6, $3A, $A1, $38, $A6, $3A, $A1
	db $38, $A6, $3A, $A1, $3A, $A3, $01, $A6, $38, $A1, $38, $A6
	db $3A, $A1, $3E, $A6, $42, $A1, $44, $A6, $48, $A1, $4C, $A6
	db $42, $A1, $42, $9D, $E9, $6E, $A0, $A6, $48, $A1, $46, $A6
	db $48, $A1, $46, $A6, $48, $A1, $52, $A3, $01, $A6, $44, $A1
	db $42, $A6, $44, $A1, $42, $A6, $44, $A1, $4C, $A3, $01, $A6
	db $48, $A1, $3A, $A6, $3E, $A1, $42, $A6, $44, $A1, $48, $A6
	db $4C, $A1, $50, $A6, $52, $A1, $3A, $A6, $0B, $A1, $06, $A6
	db $0B, $A1, $06, $A6, $0B, $A1, $06, $A3, $01, $A6, $0B, $A1
	db $06, $A6, $0B, $A1, $06, $A6, $0B, $A1, $06, $A3, $01, $A6
	db $0B, $A1, $06, $A6, $0B, $A1, $06, $A6, $0B, $A1, $06, $A3
	db $01, $A6, $0B, $A1, $06, $2E, $7D, $FF, $FF, $01, $7D, $29
	db $7D, $35, $7D, $5B, $7D, $82, $7D, $5B, $7D, $A4, $7D, $C6
	db $7D, $FF, $FF, $03, $7D, $3B, $7D, $6C, $7D, $93, $7D, $6C
	db $7D, $B5, $7D, $07, $7E, $FF, $FF, $13, $7D, $3E, $7D, $41
	db $7D, $FF, $FF, $23, $7D, $9D, $60, $00, $81, $00, $9D, $20
	db $00, $81, $AA, $01, $00, $A3, $01, $50, $54, $58, $00, $A5
	db $01, $00, $A5, $01, $00, $A3, $01, $06, $01, $06, $01, $A2
	db $06, $06, $A3, $01, $06, $A3, $01, $06, $01, $06, $01, $A2
	db $06, $06, $01, $01, $06, $06, $00, $A7, $5A, $A2, $5E, $A7
	db $5A, $A2, $58, $A7, $58, $A2, $54, $A7, $58, $A2, $54, $00
	db $9D, $C9, $6E, $20, $A2, $5A, $62, $68, $70, $5A, $62, $68
	db $70, $5A, $64, $66, $6C, $5A, $64, $66, $6C, $00, $A7, $54
	db $A2, $50, $A7, $54, $A2, $50, $A7, $50, $A2, $4C, $A7, $4A
	db $A2, $50, $00, $58, $5E, $64, $6C, $58, $5E, $64, $6C, $50
	db $54, $58, $5E, $50, $58, $5E, $64, $00, $A7, $54, $A2, $50
	db $A7, $54, $A2, $50, $A7, $50, $A2, $4C, $A7, $4A, $A2, $46
	db $00, $58, $5E, $64, $6C, $58, $5E, $64, $6C, $50, $54, $58
	db $5E, $50, $58, $5E, $64, $00, $A7, $4A, $A2, $4C, $A7, $4A
	db $A2, $46, $A7, $46, $A2, $44, $A7, $46, $A2, $4A, $A7, $4C
	db $A2, $50, $A7, $4C, $A2, $4A, $A7, $4A, $A2, $46, $A7, $4A
	db $A2, $4C, $A7, $50, $A2, $4E, $A7, $50, $A2, $52, $A7, $58
	db $A2, $54, $A7, $5A, $A2, $54, $A7, $52, $A2, $50, $A7, $4C
	db $A2, $4A, $A2, $42, $38, $3C, $4A, $A3, $42, $01, $00, $4A
	db $52, $58, $5E, $4A, $58, $5E, $62, $54, $62, $68, $6C, $54
	db $62, $68, $6C, $46, $4C, $54, $5E, $46, $4C, $54, $5A, $50
	db $58, $5E, $64, $50, $5E, $64, $6C, $4A, $50, $58, $5E, $4A
	db $58, $5E, $62, $4E, $54, $5A, $62, $4E, $54, $5A, $66, $50
	db $58, $5E, $64, $50, $5E, $64, $68, $A8, $5A, $A3, $01, $00
	db $4E, $7E, $00, $00, $5E, $7E, $6D, $7E, $7D, $7E, $9D, $B1
	db $00, $80, $A7, $01, $A1, $5E, $5E, $A6, $68, $A1, $5E, $A4
	db $68, $00, $9D, $91, $00, $80, $A7, $01, $A1, $54, $54, $A6
	db $5E, $A1, $58, $A4, $5E, $9D, $E9, $6E, $20, $A7, $01, $A1
	db $4E, $4E, $A6, $58, $A1, $50, $A3, $58, $01, $A7, $01, $A1
	db $06, $06, $A6, $0B, $A1, $06, $A0, $06, $06, $06, $06, $06
	db $06, $06, $06, $A3, $01, $BB, $7E, $28, $7F, $BB, $7E, $73
	db $7F, $FF, $FF, $91, $7E, $E5, $7E, $4F, $7F, $E5, $7E, $96
	db $7F, $FF, $FF, $9D, $7E, $FB, $7E, $61, $7F, $FB, $7E, $AE
	db $7F, $FF, $FF, $A9, $7E, $11, $7F, $FF, $FF, $B5, $7E, $9D
	db $82, $00, $80, $A2, $54, $A1, $54, $54, $54, $4A, $46, $4A
	db $A2, $54, $A1, $54, $54, $54, $58, $5C, $58, $A2, $54, $A1
	db $54, $54, $58, $54, $52, $54, $A1, $58, $5C, $58, $5C, $A2
	db $58, $A1, $56, $58, $00, $9D, $62, $00, $80, $A2, $01, $44
	db $01, $40, $01, $44, $01, $46, $01, $44, $01, $44, $01, $40
	db $01, $40, $00, $9D, $E9, $6E, $20, $A2, $54, $54, $4A, $52
	db $54, $54, $4A, $58, $54, $54, $52, $54, $4E, $54, $4A, $52
	db $00, $A2, $06, $0B, $06, $0B, $06, $0B, $06, $0B, $06, $0B
	db $06, $0B, $06, $A1, $0B, $0B, $06, $A2, $0B, $A1, $06, $00
	db $A2, $5E, $A1, $5E, $5E, $5E, $54, $50, $54, $A2, $5E, $A1
	db $5E, $5E, $5E, $62, $66, $62, $A2, $5E, $A1, $5E, $5C, $A2
	db $58, $A1, $58, $54, $A1, $52, $54, $52, $54, $A2, $52, $A1
	db $4E, $52, $00, $A2, $01, $46, $01, $4A, $01, $46, $01, $4A
	db $01, $46, $01, $46, $01, $46, $01, $46, $00, $A2, $46, $54
	db $54, $54, $46, $54, $54, $54, $46, $54, $52, $58, $44, $52
	db $4A, $58, $00, $A2, $62, $A1, $62, $62, $62, $5E, $5A, $5E
	db $A2, $62, $A1, $62, $62, $62, $5E, $5A, $5E, $A2, $62, $A1
	db $4A, $4E, $A2, $52, $A1, $4A, $5C, $A3, $58, $A1, $54, $A6
	db $6C, $00, $A2, $01, $4A, $01, $4A, $01, $4A, $01, $4A, $01
	db $A1, $46, $46, $A2, $46, $A1, $46, $46, $A3, $46, $A2, $44
	db $01, $00, $A2, $42, $5A, $50, $5A, $42, $5A, $50, $5A, $4A
	db $A1, $52, $52, $A2, $52, $A1, $52, $52, $A3, $52, $A2, $54
	db $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

func_7ff0:
	jp l_64d3


Sound_Init::
	jp $69a5
	db $00, $00, $00, $00, $00, $00, $00, $00, $00
