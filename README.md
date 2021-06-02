# tetris_disassembly
Disassembly of Tetris for the Gameboy.

compiles to the official Tetris (World) GB ROM.

To-dos:
- finish code annotation
- annotate data sections (and solve discrepancies)
- make $FF sections in the beginning prettier. (are they actually necessary? I just put them, to have 1:1 parity to the official ROM)

Simply use RGBDS: 

Linux:
```
  rgbasm -o main.o main.asm
  rgblink -o tetris.gb main.o
```

Windows:
```
  rgbasm.exe -o main.o main.asm
  rgblink.exe -o tetris.gb main.o
```
