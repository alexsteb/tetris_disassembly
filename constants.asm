; Initializing
SP_INIT  EQU $cfff ; Initial location of Stack Pointer

; Screen constants
SCREEN_HEIGHT EQU 144  ; Visible Pixels before VBlank
SCREEN_WIDTH  EQU 160  ; Visible Pixels before HBlank
LCDC_ON       EQU $80  ; Turn LCDC on

; Sound constants
SOUND_ON   EQU $80
USE_ALL_CHANNELS   EQU $FF ; Set all audio channels to both output terminals (stereo)
MASTER_VOLUME_MAX  EQU $77 ; Set both output terminals to highest volume
ENVELOPE_NO_SOUND  EQU $08 ; Sets an envelope to no sound and direction to "increase"

; RAM constants
rSOUND1     EQU $dfe1 ; (Set whenever a new sound is about to be played)
rSOUND2     EQU $dfe9 ; ?
rSOUND3     EQU $dff1 ; ?
rSOUND4     EQU $dff9 ; ?
rSOUND5     EQU $df9f ; ?
rSOUND6     EQU $dfaf ; ?
rSOUND7     EQU $dfbf ; ?
rSOUND8     EQU $dfcf ; ?
rSOUND9     EQU $df78 ; ?

; Hardware registers
rMBC        EQU $2000 ; MBC Controller - Select ROM bank 0 (not needed in Tetris)
rJOYP       EQU $ff00 ; Joypad (R/W)
rSB         EQU $ff01 ; Serial transfer data (R/W)
rSC         EQU $ff02 ; Serial Transfer Control (R/W)
rSC_ON    EQU 7
rSC_CGB   EQU 1
rSC_CLOCK EQU 0
rDIV        EQU $ff04 ; Divider Register (R/W)
rTIMA       EQU $ff05 ; Timer counter (R/W)
rTMA        EQU $ff06 ; Timer Modulo (R/W)
rTAC        EQU $ff07 ; Timer Control (R/W)
rTAC_ON        EQU 2
rTAC_4096_HZ   EQU 0
rTAC_262144_HZ EQU 1
rTAC_65536_HZ  EQU 2
rTAC_16384_HZ  EQU 3
rIF         EQU $ff0f ; Interrupt Flag (R/W)
rNR10       EQU $ff10 ; Channel 1 Sweep register (R/W)
rNR11       EQU $ff11 ; Channel 1 Sound length/Wave pattern duty (R/W)
rNR12       EQU $ff12 ; Channel 1 Volume Envelope (R/W)
rNR13       EQU $ff13 ; Channel 1 Frequency lo (Write Only)
rNR14       EQU $ff14 ; Channel 1 Frequency hi (R/W)
rNR21       EQU $ff16 ; Channel 2 Sound Length/Wave Pattern Duty (R/W)
rNR22       EQU $ff17 ; Channel 2 Volume Envelope (R/W)
rNR23       EQU $ff18 ; Channel 2 Frequency lo data (W)
rNR24       EQU $ff19 ; Channel 2 Frequency hi data (R/W)
rNR30       EQU $ff1a ; Channel 3 Sound on/off (R/W)
rNR31       EQU $ff1b ; Channel 3 Sound Length
rNR32       EQU $ff1c ; Channel 3 Select output level (R/W)
rNR33       EQU $ff1d ; Channel 3 Frequency's lower data (W)
rNR34       EQU $ff1e ; Channel 3 Frequency's higher data (R/W)
rNR41       EQU $ff20 ; Channel 4 Sound Length (R/W)
rNR42       EQU $ff21 ; Channel 4 Volume Envelope (R/W)
rNR43       EQU $ff22 ; Channel 4 Polynomial Counter (R/W)
rNR44       EQU $ff23 ; Channel 4 Counter/consecutive; Initial (R/W)
rNR50       EQU $ff24 ; Channel control / ON-OFF / Volume (R/W)
rNR51       EQU $ff25 ; Selection of Sound output terminal (R/W)
rNR52       EQU $ff26 ; Sound on/off
rLCDC       EQU $ff40 ; LCD Control (R/W)

rLCDC_STAT  EQU $ff41 ; LCDC Status (R/W)
rSCY        EQU $ff42 ; Scroll Y (R/W)
rSCX        EQU $ff43 ; Scroll X (R/W)
rLY         EQU $ff44 ; LCDC Y-Coordinate (R)
rLYC        EQU $ff45 ; LY Compare (R/W)
rDMA        EQU $ff46 ; DMA Transfer and Start Address (W)
rBGP        EQU $ff47 ; BG Palette Data (R/W)
rOBP0       EQU $ff48 ; Object Palette 0 Data (R/W)
rOBP1       EQU $ff49 ; Object Palette 1 Data (R/W)
rWY         EQU $ff4a ; Window Y Position (R/W)
rWX         EQU $ff4b ; Window X Position minus 7 (R/W)
rIE         EQU $ffff ; Interrupt Enable (R/W)

; RAM variables
rPAUSED          EQU $df7f ; 00 = normal / paused, 01 = pause pressed, 02 = unpause pressed
rPAUSE_CHIME     EQU $df7e ; 00 = normal, 11 = final value in pause menu after countdown, 30 = initial value when pause pressed 

; HRAM variables
rBUTTON_DOWN     EQU $ff80 ; Buttons currently pressed (lower nibble = buttons, higher nibble = directional keys)
rBUTTON_HIT      EQU $ff81 ; Buttons pressed for the first time

rUNKNOWN1        EQU $ffa4 ; probably unused
rGAME_TYPE       EQU $ffc0 ; $37 = Type A, $77 = Type B
rMUSIC_TYPE      EQU $ffc1 ; $1c = Music A, $1d = Music B, $1e = Music C, $1f = Music off
rMUSIC_COUNTDOWN EQU $ffc6 ; countdown for title screen music - until demo game starts playing
rGAME_STATUS     EQU $ffe1 ; See table below:
    ; $00 = in-game (both game types)
    ; $01 = shortly before game over screen
    ; $02 = !rocket launch 4
    ; $03 = !rocket launch 5
    ; $04 = game over screen
    ; $05 = type B winning chime
    ; $06 = shortly before title screen
    ; $07 = title screen
    ; $08 = shortly before game type selection
    ; $09 = nothing
    ; $0a = shortly before in-game
    ; $0b = showing score (type B)
    ; $0c = !leads to 02
    ; $0d = game lost animation (screen filling with bricks)
    ; $0e = game type selection (top screen)
    ; $0f = music selection (bottom screen)
    ; $10 = shortly before choose level (type A)
    ; $11 = choose level (type A)
    ; $12 = shortly before choose level (type B)
    ; $13 = choose level (type B)
    ; $14 = select "high" / initial random block height (type B)
    ; $15 = enter hiscore name (type A & B)
    ; $16 = !shortly before "Mario vs. Luigi" screen
    ; $17 = !"Mario vs. Luigi" screen
    ; $18 = !shortly before "Mario vs. Luigi" gameplay
    ; $19 = !"Mario vs. Luigi" gameplay
    ; $1A = !before 1B
    ; $1B = !before Luigi won
    ; $1C = !also before 1B
    ; $1D = !shortly before Luigi won screen
    ; $1E = !shortly before Luigi lost screen
    ; $1F = !before 16
    ; $20 = !Luigi won screen
    ; $21 = !Luigi lost screen
    ; $22 = !Congratulations animation 1 
    ; $23 = !leads to 05 (maybe during serial conn)
    ; $24 = initial value copyright screen (very short)
    ; $25 = copyright screen during first countdown
    ; $26 = !rocket launch init
    ; $27 = !rocket launch 1
    ; $28 = !rocket launch 2
    ; $29 = !rocket launch 3
    ; $2A = !before 2B
    ; $2B = !before 16
    ; $2C = !rocket launch 6
    ; $2D = !rocket launch 7
    ; $2E = !rocket launch b1
    ; $2F = !rocket launch b2
    ; $30 = !rocket launch b3
    ; $31 = !rocket launch b4
    ; $32 = !rocket launch b5
    ; $33 = !rocket launch b6
    ; $34 = !shortly before rocket launch b
    ; $35 = copyright screen during second countdown

rUNKNOWN2       EQU $ffe4 ; ?

; Variable value constants:
GAME_TYPE_A     EQU   $37
GAME_TYPE_B     EQU   $77

MUSIC_TYPE_A    EQU   $1c
MUSIC_TYPE_B    EQU   $1d
MUSIC_TYPE_C    EQU   $1e
MUSIC_TYPE_OFF  EQU   $1f

MENU_IN_GAME          EQU   $00
MENU_GAME_OVER_INIT   EQU   $01
MENU_GAME_OVER        EQU   $04
MENU_TYPE_B_WON       EQU   $05
MENU_TITLE_INIT       EQU   $06
MENU_TITLE            EQU   $07
MENU_SELECT_TYPE_INIT EQU   $08
MENU_IN_GAME_INIT     EQU   $0a
MENU_SCORE_B          EQU   $0b
MENU_LOST_ANIM        EQU   $0d
MENU_SELECT_TYPE      EQU   $0e
MENU_SELECT_MUSIC     EQU   $0f
MENU_LEVEL_A_INIT     EQU   $10
MENU_LEVEL_A          EQU   $11
MENU_LEVEL_B_INIT     EQU   $12
MENU_LEVEL_B          EQU   $13
MENU_HIGH_B           EQU   $14
MENU_HISCORE          EQU   $15
MENU_COPYRIGHT_INIT   EQU   $24
MENU_COPYRIGHT_1      EQU   $25
MENU_COPYRIGHT_2      EQU   $35
MENU_ROCKET_1_INIT    EQU   $26
MENU_ROCKET_1A        EQU   $27
MENU_ROCKET_1B        EQU   $28
MENU_ROCKET_1C        EQU   $29
MENU_ROCKET_1D        EQU   $02
MENU_ROCKET_1E        EQU   $03
MENU_ROCKET_1F        EQU   $2C
MENU_ROCKET_1G        EQU   $2D
MENU_ROCKET_2_INIT    EQU   $34
MENU_ROCKET_2A        EQU   $2E
MENU_ROCKET_2B        EQU   $2F
MENU_ROCKET_2C        EQU   $30
MENU_ROCKET_2D        EQU   $31
MENU_ROCKET_2E        EQU   $32
MENU_ROCKET_2F        EQU   $33
MENU_CELEBRATE        EQU   $22
MENU_VS_INIT          EQU   $16
MENU_VS_MODE          EQU   $17
MENU_VS_GAME_INIT     EQU   $18
MENU_VS_GAME          EQU   $19
MENU_LUIGI_WON_INIT   EQU   $1d
MENU_LUIGI_LOST_INIT  EQU   $1e
MENU_LUIGI_WON        EQU   $20
MENU_LUIGI_LOST       EQU   $21



                             
rCOUNT_UP        EQU $ffe2 ; Counts from $00 to $FF (once per VBlank?) - various uses 
 

