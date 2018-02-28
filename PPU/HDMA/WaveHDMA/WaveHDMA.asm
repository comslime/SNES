// SNES Wave HDMA Demo by krom (Peter Lemon):
arch snes.cpu
output "WaveHDMA.sfc", create

macro seek(variable offset) {
  origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
  base offset
}

seek($8000); fill $18000 // Fill Upto $1FFFF (Bank 2) With Zero Bytes
include "LIB/SNES.INC"        // Include SNES Definitions
include "LIB/SNES_HEADER.ASM" // Include Header & Vector Table
include "LIB/SNES_GFX.INC"    // Include Graphics Macros

seek($8000); Start:
  SNES_INIT(SLOWROM) // Run SNES Initialisation Routine

  LoadPAL(BGPal, $00, BGPal.size, 0) // Load Background Palette (BG Palette Uses 256 Colors)
  LoadVRAM(BGTiles, $0000, $8000, 0) // Load Background Tiles To VRAM
  LoadVRAM(BGTiles + $10000, $8000, $6040, 0) // Load Background Tiles To VRAM
  LoadVRAM(BGMap, $F800, BGMap.size, 0) // Load Background Tile Map To VRAM

  // Setup Video
  lda.b #%00001011 // DCBAPMMM: M = Mode, P = Priority, ABCD = BG1,2,3,4 Tile Size
  sta.w REG_BGMODE // $2105: BG Mode 3, Priority 1, BG1 8x8 Tiles

  // Setup BG1 256 Color Background
  lda.b #%11111100  // AAAAAASS: S = BG Map Size, A = BG Map Address
  sta.w REG_BG1SC   // $2107: BG1 32x32, BG1 Map Address = $3F (VRAM Address / $400)
  lda.b #%00000000  // BBBBAAAA: A = BG1 Tile Address, B = BG2 Tile Address
  sta.w REG_BG12NBA // $210B: BG1 Tile Address = $0 (VRAM Address / $1000)

  lda.b #%00000001 // Enable BG1
  sta.w REG_TM // $212C: BG1 To Main Screen Designation

  stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
  stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
  stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
  stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Pos High Byte

  // Load HDMA Table
  lda.b #%00000010   // HMDA: Write 2 Bytes Each Scanline, Repeat A/B-bus Address Twice
  sta.w REG_DMAP0    // $4300: DMA0 DMA/HDMA Parameters
  lda.b #REG_BG1HOFS // $0D: Start At BG1 Horizontal Scroll (X) ($210D)
  sta.w REG_BBAD0    // $4301: DMA0 DMA/HDMA I/O-Bus Address (PPU-Bus AKA B-Bus)
  ldx.w #HDMATable   // HMDA Table Address
  stx.w REG_A1T0L    // $4302: DMA0 DMA/HDMA Table Start Address
  lda.b #0           // HDMA Table Bank
  sta.w REG_A1B0     // $4304: DMA0 DMA/HDMA Table Start Address (Bank)
  lda.b #%00000001   // HDMA Channel Select (Channel 0)
  sta.w REG_HDMAEN   // $420C: Select H-Blank DMA (H-DMA) Channels 

  FadeIN() // Screen Fade In

ldx.w #HDMATable
Loop:
  WaitNMI() // Wait VBlank
  stx.w REG_A1T0L // $4302: DMA0 DMA/HDMA Table Start Address
  inx
  inx
  inx
  cpx.w #HDMATable + (672 * 3)
  bne SkipLoop
  ldx.w #HDMATable
  SkipLoop:
  jmp Loop

HDMATable:
db 1; dw 0
db 1; dw 2
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 1
db 1; dw -1
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw 0
db 1; dw 2
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw -1
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw -1
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 7
db 1; dw 4
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -3
db 1; dw -1
db 1; dw 1
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 7
db 1; dw 5
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -1
db 1; dw 1
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 0
db 1; dw -2
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -2
db 1; dw 1
db 1; dw 3
db 1; dw 6
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 1
db 1; dw -2
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -2
db 1; dw 1
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 6
db 1; dw 3
db 1; dw 1
db 1; dw -2
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -7
db 1; dw -5
db 1; dw -2
db 1; dw 0
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 1
db 1; dw -1
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -8
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw 0
db 1; dw 2
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw -1
db 1; dw -3
db 1; dw -6
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw 0
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw -1
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw -1
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 7
db 1; dw 5
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -1
db 1; dw 1
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 8
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 0
db 1; dw -2
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -1
db 1; dw 1
db 1; dw 3
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 0
db 1; dw -2
db 1; dw -4
db 1; dw -7
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -2
db 1; dw 1
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 1
db 1; dw -2
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -7
db 1; dw -4
db 1; dw -2
db 1; dw 0
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 3
db 1; dw 1
db 1; dw -1
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -7
db 1; dw -5
db 1; dw -2
db 1; dw 0
db 1; dw 2
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 1
db 1; dw -1
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw 0
db 1; dw 2
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw -1
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw -1
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -6
db 1; dw -3
db 1; dw -1
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 7
db 1; dw 5
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -1
db 1; dw 1
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 0
db 1; dw -2
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -2
db 1; dw 1
db 1; dw 3
db 1; dw 6
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 1
db 1; dw -2
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -2
db 1; dw 1
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 6
db 1; dw 3
db 1; dw 1
db 1; dw -2
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -7
db 1; dw -5
db 1; dw -2
db 1; dw 0
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 1
db 1; dw -1
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -8
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw 0
db 1; dw 2
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw -1
db 1; dw -3
db 1; dw -6
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw 0
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw -1
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw -1
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 7
db 1; dw 5
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -1
db 1; dw 1
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 8
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 0
db 1; dw -2
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -1
db 1; dw 1
db 1; dw 3
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 0
db 1; dw -2
db 1; dw -4
db 1; dw -7
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -2
db 1; dw 1
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 1
db 1; dw -2
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -7
db 1; dw -4
db 1; dw -2
db 1; dw 0
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 3
db 1; dw 1
db 1; dw -1
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -7
db 1; dw -5
db 1; dw -2
db 1; dw 0
db 1; dw 3
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 1
db 1; dw -1
db 1; dw -4
db 1; dw -6
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw 0
db 1; dw 2
db 1; dw 5
db 1; dw 7
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw -1
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -5
db 1; dw -3
db 1; dw -1
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 6
db 1; dw 4
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -7
db 1; dw -6
db 1; dw -3
db 1; dw -1
db 1; dw 2
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 8
db 1; dw 7
db 1; dw 5
db 1; dw 2
db 1; dw 0
db 1; dw -3
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -10
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -1
db 1; dw 1
db 1; dw 4
db 1; dw 6
db 1; dw 8
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 0
db 1; dw -2
db 1; dw -5
db 1; dw -7
db 1; dw -8
db 1; dw -9
db 1; dw -10
db 1; dw -10
db 1; dw -9
db 1; dw -8
db 1; dw -6
db 1; dw -4
db 1; dw -2
db 1; dw 1
db 1; dw 3
db 1; dw 6
db 1; dw 7
db 1; dw 9
db 1; dw 10
db 1; dw 10
db 1; dw 10
db 1; dw 9
db 1; dw 7
db 1; dw 5
db 1; dw 3
db 1; dw 1
db 1; dw -2
db 1; dw -4
db 1; dw -6

// Character Data
// BANK 0
insert BGPal, "GFX/BG.pal" // Include BG Palette Data (512 Bytes)
insert BGMap, "GFX/BG.map" // Include BG Map Data (2048 Bytes)
// BANK 1 & 2
seek($18000)
insert BGTiles, "GFX/BG.pic" // Include BG Tile Data (57408 Bytes)