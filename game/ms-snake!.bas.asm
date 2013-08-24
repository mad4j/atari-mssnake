 processor 6502
 include "vcs.h"
 include "macro.h"
 include "2600basic.h"
 include "2600basic_variable_redefs.h"
 ifconst bankswitch
  if bankswitch == 8
     ORG $1000
     RORG $D000
  endif
  if bankswitch == 16
     ORG $1000
     RORG $9000
  endif
  if bankswitch == 32
     ORG $1000
     RORG $1000
  endif
 else
   ORG $F000
 endif
 repeat 256
 .byte $ff
 repend
game
.L00 ;  set tv pal

.L01 ;  set romsize 32kSC

.L02 ;  set smartbranching on

.L03 ;  set kernel_options no_blank_lines

.L04 ;  set optimization inlinerand

.
 ; 

.
 ; 

.L05 ;  const pfres  =  24

.L06 ;  const fontstyle  =  4

.L07 ;  const NORTH  =  %00000000

.L08 ;  const EAST  =  %01010101

.L09 ;  const SOUTH  =  %10101010

.L010 ;  const WEST  =  %11111111

.L011 ;  const MAX_LEN  =  192

.L012 ;  dim bits  =  z

.L013 ;  dim bits0_DebounceReset  =  z

.L014 ;  dim bits1_DebounceFireButton  =  z

.L015 ;  dim bits2_GameOverFlag  =  z

.
 ; 

.L016 ;  dim _Master_Counter  =  s

.L017 ;  dim _Frame_Counter  =  c

.L018 ;  dim speed  =  s

.L019 ;  dim counter  =  c

.L020 ;  dim foodX  =  a

.L021 ;  dim foodY  =  b

.L022 ;  dim headX  =  x

.L023 ;  dim headY  =  y

.L024 ;  dim headDir  =  d

.L025 ;  dim grown  =  g

.L026 ;  dim length  =  l

.L027 ;  dim tailX  =  i

.L028 ;  dim tailY  =  j

.L029 ;  dim tailEnd  =  k

.L030 ;  dim tailStart  =  h

.L031 ;  dim directions  =  var0

.
 ; 

.
 ; 

.
 ; 

.L032 ;  dim eatSound  =  f

.L033 ;  dim crashSound  =  f

.
 ; 

.L034 ;  dim shakescreen  =  m

.L035 ;  dim shaking_effect  =  n

.
 ; 

.
 ; 

.
 ; 

.
 ; 

._GameInit
 ; _GameInit

.L036 ;  AUDV0  =  0  :  AUDV1  =  0

	LDA #0
	STA AUDV0
	STA AUDV1
.
 ; 

.L037 ;  for temp5  =  0 to 24  :  a[temp5]  =  0  :  next

	LDA #0
	STA temp5
.L037fortemp5
	LDA #0
	LDX temp5
	STA a,x
	LDA temp5
	CMP #24
	INC temp5
 if ((* - .L037fortemp5) < 127) && ((* - .L037fortemp5) > -128)
	bcc .L037fortemp5
 else
	bcs .0skipL037fortemp5
	jmp .L037fortemp5
.0skipL037fortemp5
 endif
.
 ; 

.
 ; 

.L038 ;  bits  =  bits  &  %00000100

	LDA bits
	AND #%00000100
	STA bits
.
 ; 

.L039 ;  if bits2_GameOverFlag{2} then goto _MainLoopSetup bank2

	LDA bits2_GameOverFlag
	AND #4
	BEQ .skipL039
.condpart0
 sta temp7
 lda #>(._MainLoopSetup-1)
 pha
 lda #<(._MainLoopSetup-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #2
 jmp BS_jsr
.skipL039
.
 ; 

.
 ; 

._TitleScreenSetup
 ; _TitleScreenSetup

.
 ; 

.L040 ;  scorecolor  =  $2C

	LDA #$2C
	STA scorecolor
.
 ; 

.L041 ;  player0x  =  0

	LDA #0
	STA player0x
.L042 ;  player0y  =  0

	LDA #0
	STA player0y
.L043 ;  bits0_DebounceReset{0}  =  1

	LDA bits0_DebounceReset
	ORA #1
	STA bits0_DebounceReset
.
 ; 

.
 ; 

.
 ; 

.
 ; 

.
 ; 

.
 ; 

.
 ; 

._TitleScreenLoop
 ; _TitleScreenLoop

.
 ; 

.L044 ;  gosub titledrawscreen bank4

 sta temp7
 lda #>(ret_point1-1)
 pha
 lda #<(ret_point1-1)
 pha
 lda #>(.titledrawscreen-1)
 pha
 lda #<(.titledrawscreen-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #4
 jmp BS_jsr
ret_point1
.
 ; 

.
 ; 

.
 ; 

.
 ; 

.L045 ;  if !switchreset  &&  !joy0fire then bits0_DebounceReset{0}  =  0  :  goto _SkipTitleResetFire

 lda #1
 bit SWCHB
	BEQ .skipL045
.condpart1
 bit INPT4
	BPL .skip1then
.condpart2
	LDA bits0_DebounceReset
	AND #254
	STA bits0_DebounceReset
 jmp ._SkipTitleResetFire

.skip1then
.skipL045
.L046 ;  if bits0_DebounceReset{0} then goto _SkipTitleResetFire

	LDA bits0_DebounceReset
	LSR
	BCC .skipL046
.condpart3
 jmp ._SkipTitleResetFire

.skipL046
.L047 ;  goto _MainLoopSetup bank2

 sta temp7
 lda #>(._MainLoopSetup-1)
 pha
 lda #<(._MainLoopSetup-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #2
 jmp BS_jsr
.
 ; 

.
 ; 

.
 ; 

._SkipTitleResetFire
 ; _SkipTitleResetFire

.L048 ;  goto _TitleScreenLoop

 jmp ._TitleScreenLoop

.
 ; 

.
 ; 

.
 ; 

.L049 ;  bank 2

 echo "    ",[(start_bank1 - *)]d , "bytes of ROM space left in bank 1")
 ORG $1FF4-bscode_length
 RORG $1FF4-bscode_length
start_bank1 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ORG $1FFC
 RORG $1FFC
 .word start_bank1
 .word start_bank1
 ORG $2000
 RORG $3000
 repeat 256
 .byte $ff
 repend
.
 ; 

._MainLoopSetup ; _MainLoopSetup bits0_DebounceReset{0}  =  1

	LDA bits0_DebounceReset
	ORA #1
	STA bits0_DebounceReset
.L050 ;  bits1_DebounceFireButton{1}  =  1

	LDA bits1_DebounceFireButton
	ORA #2
	STA bits1_DebounceFireButton
.L051 ;  bits2_GameOverFlag{2}  =  0

	LDA bits2_GameOverFlag
	AND #251
	STA bits2_GameOverFlag
.L052 ;  eatSound = 0

	LDA #0
	STA eatSound
.L053 ;  crashSound = 0

	LDA #0
	STA crashSound
.L054 ;  foodX = 0  :  foodY = 0

	LDA #0
	STA foodX
	STA foodY
.L055 ;  headX  =  5  :  headY  =  5

	LDA #5
	STA headX
	STA headY
.L056 ;  headDir  =  EAST

	LDA #EAST
	STA headDir
.L057 ;  length = 1

	LDA #1
	STA length
.L058 ;  grown = 2

	LDA #2
	STA grown
.
 ; 

.L059 ;  tailStart  =  0  :  tailEnd  =  0

	LDA #0
	STA tailStart
	STA tailEnd
.
 ; 

.L060 ;  tailX  =  headX - 1  :  tailY  =  headY

	LDA headX
	SEC
	SBC #1
	STA tailX
	LDA headY
	STA tailY
.L061 ;  directions[tailStart]  =  headDir

	LDA headDir
	LDX tailStart
	STA directions,x
.
 ; 

.L062 ;  score  =  0

	LDA #$00
	STA score+2
	LDA #$00
	STA score+1
	LDA #$00
	STA score
.L063 ;  speed  =  0

	LDA #0
	STA speed
.L064 ;  counter  =  0

	LDA #0
	STA counter
.L065 ;  pfclear

	LDA #0
 sta temp7
 lda #>(ret_point2-1)
 pha
 lda #<(ret_point2-1)
 pha
 lda #>(pfclear-1)
 pha
 lda #<(pfclear-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point2
.L066 ;  pfhline 0 0 31 on

	LDA #31
	STA temp3
	LDA #0
	LDY #0
	LDX #0
 sta temp7
 lda #>(ret_point3-1)
 pha
 lda #<(ret_point3-1)
 pha
 lda #>(pfhline-1)
 pha
 lda #<(pfhline-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point3
.L067 ;  pfhline 0 22 31 on

	LDA #31
	STA temp3
	LDA #0
	LDY #22
	LDX #0
 sta temp7
 lda #>(ret_point4-1)
 pha
 lda #<(ret_point4-1)
 pha
 lda #>(pfhline-1)
 pha
 lda #<(pfhline-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point4
.L068 ;  pfvline 0 1 21 on

	LDA #21
	STA temp3
	LDA #0
	LDY #1
	LDX #0
 sta temp7
 lda #>(ret_point5-1)
 pha
 lda #<(ret_point5-1)
 pha
 lda #>(pfvline-1)
 pha
 lda #<(pfvline-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point5
.L069 ;  pfvline 31 1 21 on

	LDA #21
	STA temp3
	LDA #31
	LDY #1
	LDX #0
 sta temp7
 lda #>(ret_point6-1)
 pha
 lda #<(ret_point6-1)
 pha
 lda #>(pfvline-1)
 pha
 lda #<(pfvline-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point6
.
 ; 

.L070 ;  player0:

	LDA #<playerL070_0
	STA player0pointerlo
	LDA #>playerL070_0
	STA player0pointerhi
	LDA #7
	STA player0height
.
 ; 

._MainLoop
 ; _MainLoop

.
 ; 

.L071 ;  COLUP0  =  $20

	LDA #$20
	STA COLUP0
.
 ; 

.L072 ;  bits1_DebounceFireButton{1}  =  0

	LDA bits1_DebounceFireButton
	AND #253
	STA bits1_DebounceFireButton
.
 ; 

.L073 ;  drawscreen

 sta temp7
 lda #>(ret_point7-1)
 pha
 lda #<(ret_point7-1)
 pha
 lda #>(drawscreen-1)
 pha
 lda #<(drawscreen-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point7
.L074 ;  if !switchreset then bits0_DebounceReset{0}  =  0  :  goto _SkipMainReset

 lda #1
 bit SWCHB
	BEQ .skipL074
.condpart4
	LDA bits0_DebounceReset
	AND #254
	STA bits0_DebounceReset
 jmp ._SkipMainReset

.skipL074
.L075 ;  if bits0_DebounceReset{0} then goto _SkipMainReset

	LDA bits0_DebounceReset
	LSR
	BCC .skipL075
.condpart5
 jmp ._SkipMainReset

.skipL075
.L076 ;  bits2_GameOverFlag{2}  =  0

	LDA bits2_GameOverFlag
	AND #251
	STA bits2_GameOverFlag
.L077 ;  goto _GameInit bank1

 sta temp7
 lda #>(._GameInit-1)
 pha
 lda #<(._GameInit-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #1
 jmp BS_jsr
.
 ; 

.
 ; 

._SkipMainReset
 ; _SkipMainReset

.L078 ;  if bits2_GameOverFlag{2} then goto _GameOverSetup bank3

	LDA bits2_GameOverFlag
	AND #4
	BEQ .skipL078
.condpart6
 sta temp7
 lda #>(._GameOverSetup-1)
 pha
 lda #<(._GameOverSetup-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #3
 jmp BS_jsr
.skipL078
.
 ; 

.L079 ;  COLUPF  =  $52

	LDA #$52
	STA COLUPF
.L080 ;  COLUBK  =  $00

	LDA #$00
	STA COLUBK
.
 ; 

.L081 ;  pfpixel headX headY on

	LDA headX
	LDY headY
	LDX #0
 sta temp7
 lda #>(ret_point8-1)
 pha
 lda #<(ret_point8-1)
 pha
 lda #>(pfpixel-1)
 pha
 lda #<(pfpixel-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point8
.L082 ;  if grown = 0 then pfpixel tailX tailY off

	LDA grown
	CMP #0
     BNE .skipL082
.condpart7
	LDA tailX
	LDY tailY
	LDX #1
 sta temp7
 lda #>(ret_point9-1)
 pha
 lda #<(ret_point9-1)
 pha
 lda #>(pfpixel-1)
 pha
 lda #<(pfpixel-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point9
.skipL082
.
 ; 

.L083 ;  if foodX = 0  &&  foodY = 0 then gosub _UpdateFood bank3

	LDA foodX
	CMP #0
     BNE .skipL083
.condpart8
	LDA foodY
	CMP #0
     BNE .skip8then
.condpart9
 sta temp7
 lda #>(ret_point10-1)
 pha
 lda #<(ret_point10-1)
 pha
 lda #>(._UpdateFood-1)
 pha
 lda #<(._UpdateFood-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #3
 jmp BS_jsr
ret_point10
.skip8then
.skipL083
.L084 ;  if eatSound = 0 then goto _SkipSound1

	LDA eatSound
	CMP #0
     BNE .skipL084
.condpart10
 jmp ._SkipSound1

.skipL084
.L085 ;  AUDV0  =  8  :  AUDC0  =  4  :  AUDF0  =  19

	LDA #8
	STA AUDV0
	LDA #4
	STA AUDC0
	LDA #19
	STA AUDF0
.L086 ;  eatSound  =  eatSound - 1

	DEC eatSound
._SkipSound1
 ; _SkipSound1

.L087 ;  if !eatSound then AUDV0  =  0

	LDA eatSound
	BNE .skipL087
.condpart11
	LDA #0
	STA AUDV0
.skipL087
.
 ; 

.L088 ;  counter  =  counter + 1

	INC counter
.L089 ;  if counter  >  speed then gosub _UpdateSnake bank3

	LDA speed
	CMP counter
     BCS .skipL089
.condpart12
 sta temp7
 lda #>(ret_point11-1)
 pha
 lda #<(ret_point11-1)
 pha
 lda #>(._UpdateSnake-1)
 pha
 lda #<(._UpdateSnake-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #3
 jmp BS_jsr
ret_point11
.skipL089
.
 ; 

.L090 ;  if headX = foodX  &&  headY = foodY then gosub _UpdateEat bank3

	LDA headX
	CMP foodX
     BNE .skipL090
.condpart13
	LDA headY
	CMP foodY
     BNE .skip13then
.condpart14
 sta temp7
 lda #>(ret_point12-1)
 pha
 lda #<(ret_point12-1)
 pha
 lda #>(._UpdateEat-1)
 pha
 lda #<(._UpdateEat-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #3
 jmp BS_jsr
ret_point12
.skip13then
.skipL090
.
 ; 

.L091 ;  if joy0up then headDir = NORTH

 lda #$10
 bit SWCHA
	BNE .skipL091
.condpart15
	LDA #NORTH
	STA headDir
.skipL091
.L092 ;  if joy0down then headDir = SOUTH

 lda #$20
 bit SWCHA
	BNE .skipL092
.condpart16
	LDA #SOUTH
	STA headDir
.skipL092
.L093 ;  if joy0left then headDir = WEST

 bit SWCHA
	BVS .skipL093
.condpart17
	LDA #WEST
	STA headDir
.skipL093
.L094 ;  if joy0right then headDir = EAST

 bit SWCHA
	BMI .skipL094
.condpart18
	LDA #EAST
	STA headDir
.skipL094
.
 ; 

.L095 ;  goto _MainLoop

 jmp ._MainLoop

.
 ; 

.
 ; 

.
 ; 

.L096 ;  bank 3

 echo "    ",[(start_bank2 - *)]d , "bytes of ROM space left in bank 2")
 ORG $2FF4-bscode_length
 RORG $3FF4-bscode_length
start_bank2 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ORG $2FFC
 RORG $3FFC
 .word start_bank2
 .word start_bank2
 ORG $3000
 RORG $5000
 repeat 256
 .byte $ff
 repend
.
 ; 

.L097 ;  data MASKS

	JMP .skipL097
MASKS
	.byte     %00000011, %00001100, %00110000, %11000000

.skipL097
.
 ; 

._UpdateSnake
 ; _UpdateSnake

.L098 ;  counter = 0

	LDA #0
	STA counter
.
 ; 

.L099 ;  if grown > 0 then grown = grown - 1  :  length = length + 1 else gosub _UpdateTail

	LDA #0
	CMP grown
     BCS .skipL099
.condpart19
	DEC grown
	INC length
 jmp .skipelse0
.skipL099
 jsr ._UpdateTail

.skipelse0
.
 ; 

.L0100 ;  speed  =   ( MAX_LEN - length )  / 32

; complex statement detected
	LDA #MAX_LEN
	SEC
	SBC length
	lsr
	lsr
	lsr
	lsr
	lsr
	STA speed
.
 ; 

.L0101 ;  gosub _UpdateHead

 jsr ._UpdateHead

.
 ; 

.
 ; 

.
 ; 

.L0102 ;  return

	tsx
	lda 2,x ; check return address
	eor #(>*) ; vs. current PCH
	and #$E0 ;  mask off all but top 3 bits
	beq *+5 ; if equal, do normal return
	JMP BS_return
	RTS
.
 ; 

._UpdateHead
 ; _UpdateHead

.L0103 ;  if headDir  =  NORTH then headY  =  headY - 1

	LDA headDir
	CMP #NORTH
     BNE .skipL0103
.condpart20
	DEC headY
.skipL0103
.L0104 ;  if headDir  =  EAST then headX  =  headX + 1

	LDA headDir
	CMP #EAST
     BNE .skipL0104
.condpart21
	INC headX
.skipL0104
.L0105 ;  if headDir  =  SOUTH then headY  =  headY + 1

	LDA headDir
	CMP #SOUTH
     BNE .skipL0105
.condpart22
	INC headY
.skipL0105
.L0106 ;  if headDir  =  WEST then headX  =  headX - 1

	LDA headDir
	CMP #WEST
     BNE .skipL0106
.condpart23
	DEC headX
.skipL0106
.
 ; 

.L0107 ;  tailStart = tailStart + 1

	INC tailStart
.L0108 ;  if tailStart = MAX_LEN then tailStart = 0

	LDA tailStart
	CMP #MAX_LEN
     BNE .skipL0108
.condpart24
	LDA #0
	STA tailStart
.skipL0108
.
 ; 

.L0109 ;  temp1  =  tailStart  /  4

	LDA tailStart
	lsr
	lsr
	STA temp1
.L0110 ;  temp2  =  tailStart  &  %00000011

	LDA tailStart
	AND #%00000011
	STA temp2
.
 ; 

.L0111 ;  temp3  =  headDir  &  MASKS[temp2]

	LDA headDir
	LDX temp2
	AND MASKS,x
	STA temp3
.
 ; 

.L0112 ;  directions[temp1]  =  directions[temp1]  &   ( MASKS[temp2]  ^  %11111111 ) 

; complex statement detected
	LDX temp1
	LDA directions,x
	PHA
	LDX temp2
	LDA MASKS,x
	EOR #%11111111
	TSX
	INX
	TXS
	AND $00,x
	LDX temp1
	STA directions,x
.L0113 ;  directions[temp1]  =  directions[temp1]  |  temp3

	LDX temp1
	LDA directions,x
	ORA temp3
	LDX temp1
	STA directions,x
.
 ; 

.L0114 ;  if headX = foodX  &&  headY = foodY then goto _SkipCollisionCheck

	LDA headX
	CMP foodX
     BNE .skipL0114
.condpart25
	LDA headY
	CMP foodY
     BNE .skip25then
.condpart26
 jmp ._SkipCollisionCheck

.skip25then
.skipL0114
.L0115 ;  if pfread ( headX ,  headY )  then bits2_GameOverFlag{2}  =  1

	LDA headX
	LDY headY
 sta temp7
 lda #>(ret_point13-1)
 pha
 lda #<(ret_point13-1)
 pha
 lda #>(pfread-1)
 pha
 lda #<(pfread-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point13
	BNE .skipL0115
.condpart27
	LDA bits2_GameOverFlag
	ORA #4
	STA bits2_GameOverFlag
.skipL0115
.
 ; 

._SkipCollisionCheck
 ; _SkipCollisionCheck

.L0116 ;  return

	tsx
	lda 2,x ; check return address
	eor #(>*) ; vs. current PCH
	and #$E0 ;  mask off all but top 3 bits
	beq *+5 ; if equal, do normal return
	JMP BS_return
	RTS
.
 ; 

._UpdateTail
 ; _UpdateTail

.
 ; 

.L0117 ;  temp1  =  tailEnd  /  4

	LDA tailEnd
	lsr
	lsr
	STA temp1
.L0118 ;  temp2  =  tailEnd  &  %00000011

	LDA tailEnd
	AND #%00000011
	STA temp2
.
 ; 

.L0119 ;  temp3  =  directions[temp1]  &  MASKS[temp2]

	LDX temp1
	LDA directions,x
	LDX temp2
	AND MASKS,x
	STA temp3
.
 ; 

.L0120 ;  if temp3  =  NORTH  &  MASKS[temp2] then tailY  =  tailY - 1

; complex condition detected
	LDA #NORTH
	LDX temp2
	AND MASKS,x
  PHA
  TSX
  PLA
	LDA temp3
	CMP  1,x
     BNE .skipL0120
.condpart28
	DEC tailY
.skipL0120
.L0121 ;  if temp3  =  EAST  &  MASKS[temp2] then tailX  =  tailX + 1

; complex condition detected
	LDA #EAST
	LDX temp2
	AND MASKS,x
  PHA
  TSX
  PLA
	LDA temp3
	CMP  1,x
     BNE .skipL0121
.condpart29
	INC tailX
.skipL0121
.L0122 ;  if temp3  =  SOUTH  &  MASKS[temp2] then tailY  =  tailY + 1

; complex condition detected
	LDA #SOUTH
	LDX temp2
	AND MASKS,x
  PHA
  TSX
  PLA
	LDA temp3
	CMP  1,x
     BNE .skipL0122
.condpart30
	INC tailY
.skipL0122
.L0123 ;  if temp3  =  WEST  &  MASKS[temp2] then tailX  =  tailX - 1

; complex condition detected
	LDA #WEST
	LDX temp2
	AND MASKS,x
  PHA
  TSX
  PLA
	LDA temp3
	CMP  1,x
     BNE .skipL0123
.condpart31
	DEC tailX
.skipL0123
.
 ; 

.L0124 ;  tailEnd = tailEnd + 1

	INC tailEnd
.L0125 ;  if tailEnd = MAX_LEN then tailEnd = 0

	LDA tailEnd
	CMP #MAX_LEN
     BNE .skipL0125
.condpart32
	LDA #0
	STA tailEnd
.skipL0125
.
 ; 

.L0126 ;  return

	tsx
	lda 2,x ; check return address
	eor #(>*) ; vs. current PCH
	and #$E0 ;  mask off all but top 3 bits
	beq *+5 ; if equal, do normal return
	JMP BS_return
	RTS
.
 ; 

._UpdateFood
 ; _UpdateFood

.L0127 ;  foodX  =   ( rand & 31 ) 

; complex statement detected
        lda rand
        lsr
 ifconst rand16
        rol rand16
 endif
        bcc *+4
        eor #$B4
        sta rand
 ifconst rand16
        eor rand16
 endif
	AND #31
	STA foodX
.L0128 ;  foodY  =   ( rand & 23 ) 

; complex statement detected
        lda rand
        lsr
 ifconst rand16
        rol rand16
 endif
        bcc *+4
        eor #$B4
        sta rand
 ifconst rand16
        eor rand16
 endif
	AND #23
	STA foodY
.L0129 ;  if foodY  =  23 then goto _UpdateFood

	LDA foodY
	CMP #23
     BNE .skipL0129
.condpart33
 jmp ._UpdateFood

.skipL0129
.L0130 ;  if pfread ( foodX , foodY )  then goto _UpdateFood

	LDA foodX
	LDY foodY
 sta temp7
 lda #>(ret_point14-1)
 pha
 lda #<(ret_point14-1)
 pha
 lda #>(pfread-1)
 pha
 lda #<(pfread-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point14
	BNE .skipL0130
.condpart34
 jmp ._UpdateFood

.skipL0130
.
 ; 

.L0131 ;  temp5  =  foodX * 4 + 17

; complex statement detected
	LDA foodX
	asl
	asl
	CLC
	ADC #17
	STA temp5
.L0132 ;  player0x  =  temp5

	LDA temp5
	STA player0x
.
 ; 

.L0133 ;  temp5  =  foodY * 4 + 4

; complex statement detected
	LDA foodY
	asl
	asl
	CLC
	ADC #4
	STA temp5
.L0134 ;  player0y  =  temp5

	LDA temp5
	STA player0y
.
 ; 

.L0135 ;  return

	tsx
	lda 2,x ; check return address
	eor #(>*) ; vs. current PCH
	and #$E0 ;  mask off all but top 3 bits
	beq *+5 ; if equal, do normal return
	JMP BS_return
	RTS
.
 ; 

._UpdateEat
 ; _UpdateEat

.L0136 ;  score = score + 1

	SED
	CLC
	LDA score+2
	ADC #$01
	STA score+2
	LDA score+1
	ADC #$00
	STA score+1
	LDA score
	ADC #$00
	STA score
	CLD
.L0137 ;  if length + grown  =  MAX_LEN then goto _SkipGrownIncrement

; complex condition detected
	LDA length
	CLC
	ADC grown
	CMP #MAX_LEN
     BNE .skipL0137
.condpart35
 jmp ._SkipGrownIncrement

.skipL0137
.L0138 ;  grown = grown + 1

	INC grown
.
 ; 

.
 ; 

.
 ; 

._SkipGrownIncrement
 ; _SkipGrownIncrement

.
 ; 

.L0139 ;  eatSound  =  6

	LDA #6
	STA eatSound
.
 ; 

.L0140 ;  foodX = 0  :  foodY = 0

	LDA #0
	STA foodX
	STA foodY
.
 ; 

.L0141 ;  return

	tsx
	lda 2,x ; check return address
	eor #(>*) ; vs. current PCH
	and #$E0 ;  mask off all but top 3 bits
	beq *+5 ; if equal, do normal return
	JMP BS_return
	RTS
.
 ; 

.
 ; 

.L0142 ;  rem  ****************************************************************

.L0143 ;  rem  ****************************************************************

.L0144 ;  rem  *

.L0145 ;  rem  *  Game Over Setup

.L0146 ;  rem  *

.L0147 ;  rem  `

._GameOverSetup
 ; _GameOverSetup

.
 ; 

.L0148 ;  playfield:

  ifconst pfres
	  ldx #(24>pfres)*(pfres*pfwidth-1)+(24<=pfres)*95
  else
	  ldx #47
  endif
	jmp pflabel0
PF_data0
	.byte %01111110, %10111111, %11111111, %01111101
	.byte %01100000, %10110011, %10011001, %00001101
	.byte %01101110, %10111111, %10011001, %00111101
	.byte %01100110, %10110011, %10011001, %00001101
	.byte %01111110, %10110011, %10011001, %01111101
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00011111, %11001101, %01111101, %00011111
	.byte %00011001, %11001101, %01100001, %00011001
	.byte %00011001, %11001101, %01111001, %00001111
	.byte %00011001, %11001101, %01100001, %00011001
	.byte %00011111, %00110001, %01111101, %00011001
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
pflabel0
	lda PF_data0,x
	sta playfield-128,x
	dex
	bpl pflabel0
.L0149 ;  player0x  =  0  :  player0y  =  0

	LDA #0
	STA player0x
	STA player0y
.L0150 ;  bits0_DebounceReset{0}  =  1

	LDA bits0_DebounceReset
	ORA #1
	STA bits0_DebounceReset
.L0151 ;  crashSound = 8

	LDA #8
	STA crashSound
.L0152 ;  shaking_effect  =  25

	LDA #25
	STA shaking_effect
.
 ; 

._GameOverLoop
 ; _GameOverLoop

.L0153 ;  COLUPF  =  $6C  :  COLUBK  =  $00

	LDA #$6C
	STA COLUPF
	LDA #$00
	STA COLUBK
.
 ; 

.L0154 ;  if crashSound = 0 then goto _SkipSound2

	LDA crashSound
	CMP #0
     BNE .skipL0154
.condpart36
 jmp ._SkipSound2

.skipL0154
.
 ; 

.L0155 ;  AUDV0  =  8  :  AUDC0  =  3  :  AUDF0  =  19

	LDA #8
	STA AUDV0
	LDA #3
	STA AUDC0
	LDA #19
	STA AUDF0
.L0156 ;  crashSound  =  crashSound - 1

	DEC crashSound
.
 ; 

._SkipSound2
 ; _SkipSound2

.L0157 ;  if !crashSound then AUDV0  =  0

	LDA crashSound
	BNE .skipL0157
.condpart37
	LDA #0
	STA AUDV0
.skipL0157
.
 ; 

.L0158 ;  _Master_Counter  =  _Master_Counter  +  1

	INC _Master_Counter
.L0159 ;  if shaking_effect  =  0 then goto _SkipShake

	LDA shaking_effect
	CMP #0
     BNE .skipL0159
.condpart38
 jmp ._SkipShake

.skipL0159
.L0160 ;  shakescreen  =  shakescreen + 32

	LDA shakescreen
	CLC
	ADC #32
	STA shakescreen
.L0161 ;  shaking_effect  =  shaking_effect - 1

	DEC shaking_effect
.
 ; 

._SkipShake
 ; _SkipShake

.
 ; 

.L0162 ;  rem  ````````````````````````````````````````````````````````````````

.L0163 ;  rem  `  The master counter resets every 2 seconds.

.L0164 ;  rem  `

.L0165 ;  if _Master_Counter  <  120 then goto _Skip20Counter

	LDA _Master_Counter
	CMP #120
     BCS .skipL0165
.condpart39
 jmp ._Skip20Counter

.skipL0165
.
 ; 

.L0166 ;  _Master_Counter  =  0

	LDA #0
	STA _Master_Counter
.
 ; 

.
 ; 

.L0167 ;  rem  ````````````````````````````````````````````````````````````````

.L0168 ;  rem  `  The frame counter increments every 2 seconds.

.L0169 ;  rem  `

.L0170 ;  _Frame_Counter  =  _Frame_Counter  +  1

	INC _Frame_Counter
.
 ; 

.L0171 ;  rem  ````````````````````````````````````````````````````````````````

.L0172 ;  rem  `  If _Frame_Counter reaches 10 (20 seconds), the program resets

.L0173 ;  rem  `  and goes to the title screen.

.L0174 ;  rem  `

.L0175 ;  if _Frame_Counter  =  5 then bits2_GameOverFlag{2}  =  0  :  goto _GameInit bank1

	LDA _Frame_Counter
	CMP #5
     BNE .skipL0175
.condpart40
	LDA bits2_GameOverFlag
	AND #251
	STA bits2_GameOverFlag
 sta temp7
 lda #>(._GameInit-1)
 pha
 lda #<(._GameInit-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #1
 jmp BS_jsr
.skipL0175
.
 ; 

.
 ; 

._Skip20Counter
 ; _Skip20Counter

.
 ; 

.
 ; 

.L0176 ;  drawscreen

 sta temp7
 lda #>(ret_point15-1)
 pha
 lda #<(ret_point15-1)
 pha
 lda #>(drawscreen-1)
 pha
 lda #<(drawscreen-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #8
 jmp BS_jsr
ret_point15
.
 ; 

.L0177 ;  if !switchreset  &&  !joy0fire then bits0_DebounceReset{0}  =  0  :  goto _SkipGameOverReset

 lda #1
 bit SWCHB
	BEQ .skipL0177
.condpart41
 bit INPT4
	BPL .skip41then
.condpart42
	LDA bits0_DebounceReset
	AND #254
	STA bits0_DebounceReset
 jmp ._SkipGameOverReset

.skip41then
.skipL0177
.
 ; 

.L0178 ;  if bits0_DebounceReset{0} then goto _SkipGameOverReset

	LDA bits0_DebounceReset
	LSR
	BCC .skipL0178
.condpart43
 jmp ._SkipGameOverReset

.skipL0178
.
 ; 

.L0179 ;  goto _GameInit bank1

 sta temp7
 lda #>(._GameInit-1)
 pha
 lda #<(._GameInit-1)
 pha
 lda temp7
 pha
 txa
 pha
 ldx #1
 jmp BS_jsr
.
 ; 

.
 ; 

._SkipGameOverReset
 ; _SkipGameOverReset

.
 ; 

.L0180 ;  goto _GameOverLoop

 jmp ._GameOverLoop

.
 ; 

.
 ; 

.
 ; 

.L0181 ;  bank 4

 echo "    ",[(start_bank3 - *)]d , "bytes of ROM space left in bank 3")
 ORG $3FF4-bscode_length
 RORG $5FF4-bscode_length
start_bank3 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ORG $3FFC
 RORG $5FFC
 .word start_bank3
 .word start_bank3
 ORG $4000
 RORG $7000
 repeat 256
 .byte $ff
 repend
.
 ; 

.L0182 ;  asm

    include "titlescreen/asm/titlescreen.asm"

.
 ; 

.L0183 ;  bank 5

 echo "    ",[(start_bank4 - *)]d , "bytes of ROM space left in bank 4")
 ORG $4FF4-bscode_length
 RORG $7FF4-bscode_length
start_bank4 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ORG $4FFC
 RORG $7FFC
 .word start_bank4
 .word start_bank4
 ORG $5000
 RORG $9000
 repeat 256
 .byte $ff
 repend
.
 ; 

.L0184 ;  bank 6

 echo "    ",[(start_bank5 - *)]d , "bytes of ROM space left in bank 5")
 ORG $5FF4-bscode_length
 RORG $9FF4-bscode_length
start_bank5 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ORG $5FFC
 RORG $9FFC
 .word start_bank5
 .word start_bank5
 ORG $6000
 RORG $B000
 repeat 256
 .byte $ff
 repend
.
 ; 

.L0185 ;  bank 7

 echo "    ",[(start_bank6 - *)]d , "bytes of ROM space left in bank 6")
 ORG $6FF4-bscode_length
 RORG $BFF4-bscode_length
start_bank6 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ORG $6FFC
 RORG $BFFC
 .word start_bank6
 .word start_bank6
 ORG $7000
 RORG $D000
 repeat 256
 .byte $ff
 repend
.
 ; 

.L0186 ;  bank 8

 echo "    ",[(start_bank7 - *)]d , "bytes of ROM space left in bank 7")
 ORG $7FF4-bscode_length
 RORG $DFF4-bscode_length
start_bank7 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ORG $7FFC
 RORG $DFFC
 .word start_bank7
 .word start_bank7
 ORG $8000
 RORG $F000
 repeat 256
 .byte $ff
 repend
; This is a 2-line kernel!
kernel
 sta WSYNC
 lda #255
 sta TIM64T

 lda #1
 sta VDELBL
 sta VDELP0
 ldx ballheight
 inx
 inx
 stx temp4
 lda player1y
 sta temp3

 ifconst shakescreen
   jsr doshakescreen
 else
   ldx missile0height
   inx
 endif

 inx
 stx stack1

 lda bally
 sta stack2

 lda player0y
 ldx #0
 sta WSYNC
 stx GRP0
 stx GRP1
 stx PF1L
 stx PF2
 stx CXCLR
 ifconst readpaddle
   stx paddle
 else
   sleep 3
 endif

 sta temp2,x

 ;store these so they can be retrieved later
 ifnconst pfres
   ldx #128-44+(4-pfwidth)*12
 else
   ldx #132-pfres*pfwidth
 endif

 dec player0y

 lda missile0y
 sta temp5
 lda missile1y
 sta temp6

 lda playfieldpos
 sta temp1
 
 ifconst pfrowheight
 lda #pfrowheight+2
 else
 ifnconst pfres
   lda #10
 else
   lda #(96/pfres)+2 ; try to come close to the real size
 endif
 endif
 clc
 sbc playfieldpos
 sta playfieldpos
 jmp .startkernel

.skipDrawP0
 lda #0
 tay
 jmp .continueP0

.skipDrawP1
 lda #0
 tay
 jmp .continueP1

.kerloop ; enter at cycle 59??

continuekernel
 sleep 2
continuekernel2
 lda ballheight
 
 ifconst pfres
 ldy playfield+pfres*pfwidth-132,x
 sty PF1L ;3
 ldy playfield+pfres*pfwidth-131-pfadjust,x
 sty PF2L ;3
 ldy playfield+pfres*pfwidth-129,x
 sty PF1R ; 3 too early?
 ldy playfield+pfres*pfwidth-130-pfadjust,x
 sty PF2R ;3
 else
 ldy playfield-48+pfwidth*12+44-128,x
 sty PF1L ;3
 ldy playfield-48+pfwidth*12+45-128-pfadjust,x ;4
 sty PF2L ;3
 ldy playfield-48+pfwidth*12+47-128,x ;4
 sty PF1R ; 3 too early?
 ldy playfield-48+pfwidth*12+46-128-pfadjust,x;4
 sty PF2R ;3
 endif

 ; should be playfield+$38 for width=2

 dcp bally
 rol
 rol
; rol
; rol
goback
 sta ENABL 
.startkernel
 lda player1height ;3
 dcp player1y ;5
 bcc .skipDrawP1 ;2
 ldy player1y ;3
 lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
			; so it doesn't cross a page boundary!

.continueP1
 sta GRP1 ;3

 ifnconst player1colors
   lda missile1height ;3
   dcp missile1y ;5
   rol;2
   rol;2
   sta ENAM1 ;3
 else
   lda (player1color),y
   sta COLUP1
 ifnconst playercolors
   sleep 7
 else
   lda.w player0colorstore
   sta COLUP0
 endif
 endif

 ifconst pfres
 lda playfield+pfres*pfwidth-132,x 
 sta PF1L ;3
 lda playfield+pfres*pfwidth-131-pfadjust,x 
 sta PF2L ;3
 lda playfield+pfres*pfwidth-129,x 
 sta PF1R ; 3 too early?
 lda playfield+pfres*pfwidth-130-pfadjust,x 
 sta PF2R ;3
 else
 lda playfield-48+pfwidth*12+44-128,x ;4
 sta PF1L ;3
 lda playfield-48+pfwidth*12+45-128-pfadjust,x ;4
 sta PF2L ;3
 lda playfield-48+pfwidth*12+47-128,x ;4
 sta PF1R ; 3 too early?
 lda playfield-48+pfwidth*12+46-128-pfadjust,x;4
 sta PF2R ;3
 endif 
; sleep 3

 lda player0height
 dcp player0y
 bcc .skipDrawP0
 ldy player0y
 lda (player0pointer),y
.continueP0
 sta GRP0

 ifnconst no_blank_lines
 ifnconst playercolors
   lda missile0height ;3
   dcp missile0y ;5
   sbc stack1
   sta ENAM0 ;3
 else
   lda (player0color),y
   sta player0colorstore
   sleep 6
 endif
   dec temp1
   bne continuekernel
 else
   dec temp1
   beq altkernel2
 ifconst readpaddle
   ldy currentpaddle
   lda INPT0,y
   bpl noreadpaddle
   inc paddle
   jmp continuekernel2
noreadpaddle
   sleep 2
   jmp continuekernel
 else
 ifnconst playercolors 
 ifconst PFcolors
   txa
   tay
   lda (pfcolortable),y
 ifnconst backgroundchange
   sta COLUPF
 else
   sta COLUBK
 endif
   jmp continuekernel
 else
 ifconst kernelmacrodef
   kernelmacro
 else
   sleep 12
 endif
 endif
 else
   lda (player0color),y
   sta player0colorstore
   sleep 4
 endif
   jmp continuekernel
 endif
altkernel2
   txa
   sbx #256-pfwidth
   bmi lastkernelline
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
   jmp continuekernel
 endif

altkernel

 ifconst PFmaskvalue
   lda #PFmaskvalue
 else
   lda #0
 endif
 sta PF1L
 sta PF2


 ;sleep 3

 ;28 cycles to fix things
 ;minus 11=17

; lax temp4
; clc
 txa
 sbx #256-pfwidth

 bmi lastkernelline

 ifconst PFcolorandheight
   ifconst pfres
     ldy playfieldcolorandheight-131+pfres*pfwidth,x
   else
     ldy playfieldcolorandheight-87,x
   endif
 ifnconst backgroundchange
   sty COLUPF
 else
   sty COLUBK
 endif
   ifconst pfres
     lda playfieldcolorandheight-132+pfres*pfwidth,x
   else
     lda playfieldcolorandheight-88,x
   endif
   sta.w temp1
 endif
 ifconst PFheights
   lsr
   lsr
   tay
   lda (pfheighttable),y
   sta.w temp1
 endif
 ifconst PFcolors
   tay
   lda (pfcolortable),y
 ifnconst backgroundchange
   sta COLUPF
 else
   sta COLUBK
 endif
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
 endif
 ifnconst PFcolorandheight
 ifnconst PFcolors
 ifnconst PFheights
 ifnconst no_blank_lines
 ; read paddle 0
 ; lo-res paddle read
  ; bit INPT0
  ; bmi paddleskipread
  ; inc paddle0
;donepaddleskip
   sleep 10
 ifconst pfrowheight
   lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
 endif
 endif
 endif
 endif
 

 lda ballheight
 dcp bally
 sbc temp4


 jmp goback


 ifnconst no_blank_lines
lastkernelline
 ifnconst PFcolors
   sleep 10
 else
   ldy #124
   lda (pfcolortable),y
   sta COLUPF
 endif

 ifconst PFheights
 ldx #1
 sleep 4
 else
 ldx playfieldpos
 sleep 3
 endif

 jmp enterlastkernel

 else
lastkernelline
 
 ifconst PFheights
 ldx #1
 sleep 5
 else
   ldx playfieldpos
 sleep 4
 endif

   cpx #1
   bne .enterfromNBL
   jmp no_blank_lines_bailout
 endif

 if ((<*)>$d5)
 align 256
 endif
 ; this is a kludge to prevent page wrapping - fix!!!

.skipDrawlastP1
 sleep 2
 lda #0
 jmp .continuelastP1

.endkerloop ; enter at cycle 59??
 
 nop

.enterfromNBL
 ifconst pfres
 ldy.w playfield+pfres*pfwidth-4
 sty PF1L ;3
 ldy.w playfield+pfres*pfwidth-3-pfadjust
 sty PF2L ;3
 ldy.w playfield+pfres*pfwidth-1
 sty PF1R ; possibly too early?
 ldy.w playfield+pfres*pfwidth-2-pfadjust
 sty PF2R ;3
 else
 ldy.w playfield-48+pfwidth*12+44
 sty PF1L ;3
 ldy.w playfield-48+pfwidth*12+45-pfadjust
 sty PF2L ;3
 ldy.w playfield-48+pfwidth*12+47
 sty PF1R ; possibly too early?
 ldy.w playfield-48+pfwidth*12+46-pfadjust
 sty PF2R ;3
 endif

enterlastkernel
 lda ballheight

; tya
 dcp bally
; sleep 4

; sbc stack3
 rol
 rol
 sta ENABL 

 lda player1height ;3
 dcp player1y ;5
 bcc .skipDrawlastP1
 ldy player1y ;3
 lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
			; so it doesn't cross a page boundary!

.continuelastP1
 sta GRP1 ;3

 ifnconst player1colors
   lda missile1height ;3
   dcp missile1y ;5
 else
   lda (player1color),y
   sta COLUP1
 endif

 dex
 ;dec temp4 ; might try putting this above PF writes
 beq endkernel


 ifconst pfres
 ldy.w playfield+pfres*pfwidth-4
 sty PF1L ;3
 ldy.w playfield+pfres*pfwidth-3-pfadjust
 sty PF2L ;3
 ldy.w playfield+pfres*pfwidth-1
 sty PF1R ; possibly too early?
 ldy.w playfield+pfres*pfwidth-2-pfadjust
 sty PF2R ;3
 else
 ldy.w playfield-48+pfwidth*12+44
 sty PF1L ;3
 ldy.w playfield-48+pfwidth*12+45-pfadjust
 sty PF2L ;3
 ldy.w playfield-48+pfwidth*12+47
 sty PF1R ; possibly too early?
 ldy.w playfield-48+pfwidth*12+46-pfadjust
 sty PF2R ;3
 endif

 ifnconst player1colors
   rol;2
   rol;2
   sta ENAM1 ;3
 else
 ifnconst playercolors
   sleep 7
 else
   lda.w player0colorstore
   sta COLUP0
 endif
 endif
 
 lda.w player0height
 dcp player0y
 bcc .skipDrawlastP0
 ldy player0y
 lda (player0pointer),y
.continuelastP0
 sta GRP0



 ifnconst no_blank_lines
   lda missile0height ;3
   dcp missile0y ;5
   sbc stack1
   sta ENAM0 ;3
   jmp .endkerloop
 else
 ifconst readpaddle
   ldy currentpaddle
   lda INPT0,y
   bpl noreadpaddle2
   inc paddle
   jmp .endkerloop
noreadpaddle2
   sleep 4
   jmp .endkerloop
 else ; no_blank_lines and no paddle reading
 pla
 pha ; 14 cycles in 4 bytes
 pla
 pha
 ; sleep 14
 jmp .endkerloop
 endif
 endif


;  ifconst donepaddleskip
;paddleskipread
 ; this is kind of lame, since it requires 4 cycles from a page boundary crossing
 ; plus we get a lo-res paddle read
; bmi donepaddleskip
;  endif

.skipDrawlastP0
 sleep 2
 lda #0
 jmp .continuelastP0

 ifconst no_blank_lines
no_blank_lines_bailout
 ldx #0
 endif

endkernel
 ; 6 digit score routine
 stx PF1
 stx PF2
 stx PF0
 clc

 ifconst pfrowheight
 lda #pfrowheight+2
 else
 ifnconst pfres
   lda #10
 else
   lda #(96/pfres)+2 ; try to come close to the real size
 endif
 endif

 sbc playfieldpos
 sta playfieldpos
 txa

 ifconst shakescreen
   bit shakescreen
   bmi noshakescreen2
   ldx #$3D
noshakescreen2
 endif

   sta WSYNC,x

;                STA WSYNC ;first one, need one more
 sta REFP0
 sta REFP1
                STA GRP0
                STA GRP1
 ;               STA PF1
   ;             STA PF2
 sta HMCLR
 sta ENAM0
 sta ENAM1
 sta ENABL

 lda temp2 ;restore variables that were obliterated by kernel
 sta player0y
 lda temp3
 sta player1y
 ifnconst player1colors
   lda temp6
   sta missile1y
 endif
 ifnconst playercolors
 ifnconst readpaddle
   lda temp5
   sta missile0y
 endif
 endif
 lda stack2
 sta bally

 ifconst no_blank_lines
 sta WSYNC
 endif

 lda INTIM
 clc
 ifnconst vblank_time
 adc #43+12+87
 else
 adc #vblank_time+12+87
 endif
; sta WSYNC
 sta TIM64T

 ifconst minikernel
 jsr minikernel
 endif

 ; now reassign temp vars for score pointers

; score pointers contain:
; score1-5: lo1,lo2,lo3,lo4,lo5,lo6
; swap lo2->temp1
; swap lo4->temp3
; swap lo6->temp5
 ifnconst noscore
 lda scorepointers+1
; ldy temp1
 sta temp1
; sty scorepointers+1

 lda scorepointers+3
; ldy temp3
 sta temp3
; sty scorepointers+3


 sta HMCLR
 tsx
 stx stack1 
 ldx #$E0
 stx HMP0

               LDA scorecolor 
                STA COLUP0
                STA COLUP1
 ifconst pfscore
 lda pfscorecolor
 sta COLUPF
 endif
 sta WSYNC
 ldx #0
                STx GRP0
                STx GRP1 ; seems to be needed because of vdel

 lda scorepointers+5
; ldy temp5
 sta temp5,x
; sty scorepointers+5
 lda #>scoretable
 sta scorepointers+1
 sta scorepointers+3
 sta scorepointers+5
 sta temp2
 sta temp4
 sta temp6
                LDY #7
        STY VDELP0
                STA RESP0
                STA RESP1


        LDA #$03
        STA NUSIZ0
        STA NUSIZ1
        STA VDELP1
        LDA #$F0
        STA HMP1
 lda  (scorepointers),y
 sta  GRP0
                STA HMOVE ; cycle 73 ?
 jmp beginscore


 if ((<*)>$d4)
 align 256 ; kludge that potentially wastes space!  should be fixed!
 endif

loop2
 lda  (scorepointers),y     ;+5  68  204
 sta  GRP0            ;+3  71  213      D1     --      --     --
 ifconst pfscore
 lda.w pfscore1
 sta PF1
 else
 sleep 7
 endif
 ; cycle 0
beginscore
 lda  (scorepointers+$8),y  ;+5   5   15
 sta  GRP1            ;+3   8   24      D1     D1      D2     --
 lda  (scorepointers+$6),y  ;+5  13   39
 sta  GRP0            ;+3  16   48      D3     D1      D2     D2
 lax  (scorepointers+$2),y  ;+5  29   87
 txs
 lax  (scorepointers+$4),y  ;+5  36  108
 sleep 3

 ifconst pfscore
 lda pfscore2
 sta PF1
 else
 sleep 6
 endif

 lda  (scorepointers+$A),y  ;+5  21   63
 stx  GRP1            ;+3  44  132      D3     D3      D4     D2!
 tsx
 stx  GRP0            ;+3  47  141      D5     D3!     D4     D4
 sta  GRP1            ;+3  50  150      D5     D5      D6     D4!
 sty  GRP0            ;+3  53  159      D4*    D5!     D6     D6
 dey
 bpl  loop2           ;+2  60  180

 ldx stack1 
 txs
; lda scorepointers+1
 ldy temp1
; sta temp1
 sty scorepointers+1

                LDA #0   
 sta PF1
               STA GRP0
                STA GRP1
        STA VDELP0
        STA VDELP1;do we need these
        STA NUSIZ0
        STA NUSIZ1

; lda scorepointers+3
 ldy temp3
; sta temp3
 sty scorepointers+3

; lda scorepointers+5
 ldy temp5
; sta temp5
 sty scorepointers+5
 endif ;noscore
 LDA #%11000010
 sta WSYNC
 STA VBLANK
 RETURN

 ifconst shakescreen
doshakescreen
   bit shakescreen
   bmi noshakescreen
   sta WSYNC
noshakescreen
   ldx missile0height
   inx
   rts
 endif

start
 sei
 cld
 ldy #0
 lda $D0
 cmp #$2C               ;check RAM location #1
 bne MachineIs2600
 lda $D1
 cmp #$A9               ;check RAM location #2
 bne MachineIs2600
 dey
MachineIs2600
 ldx #0
 txa
clearmem
 inx
 txs
 pha
 bne clearmem
 sty temp1
 ifnconst multisprite
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifconst pfres
 lda #(96/pfres)
 else
 lda #8
 endif
 endif
 sta playfieldpos
 endif
 ldx #5
initscore
 lda #<scoretable
 sta scorepointers,x 
 dex
 bpl initscore
 lda #1
 sta CTRLPF
 ora INTIM
 sta rand

 ifconst multisprite
   jsr multisprite_setup
 endif

 ifnconst bankswitch
   jmp game
 else
   lda #>(game-1)
   pha
   lda #<(game-1)
   pha
   pha
   pha
   ldx #1
   jmp BS_jsr
 endif
; playfield drawing routines
; you get a 32x12 bitmapped display in a single color :)
; 0-31 and 0-11

pfclear ; clears playfield - or fill with pattern
 ifconst pfres
 ldx #pfres*pfwidth-1
 else
 ldx #47-(4-pfwidth)*12 ; will this work?
 endif
pfclear_loop
 ifnconst superchip
 sta playfield,x
 else
 sta playfield-128,x
 endif
 dex
 bpl pfclear_loop
 RETURN
 
setuppointers
 stx temp2 ; store on.off.flip value
 tax ; put x-value in x 
 lsr
 lsr
 lsr ; divide x pos by 8 
 sta temp1
 tya
 asl
 if pfwidth=4
  asl ; multiply y pos by 4
 endif ; else multiply by 2
 clc
 adc temp1 ; add them together to get actual memory location offset
 tay ; put the value in y
 lda temp2 ; restore on.off.flip value
 rts

pfread
;x=xvalue, y=yvalue
 jsr setuppointers
 lda setbyte,x
 and playfield,y
 eor setbyte,x
; beq readzero
; lda #1
; readzero
 RETURN

pfpixel
;x=xvalue, y=yvalue, a=0,1,2
 jsr setuppointers

 ifconst bankswitch
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon_r  ; if "on" go to on
 lsr
 bcs pixeloff_r ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixelon_r
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixeloff_r
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN

 else
 jmp plotpoint
 endif

pfhline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 jmp noinc
keepgoing
 inx
 txa
 and #7
 bne noinc
 iny
noinc
 jsr plotpoint
 cpx temp3
 bmi keepgoing
 RETURN

pfvline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 sty temp1 ; store memory location offset
 inc temp3 ; increase final x by 1 
 lda temp3
 asl
 if pfwidth=4
   asl ; multiply by 4
 endif ; else multiply by 2
 sta temp3 ; store it
 ; Thanks to Michael Rideout for fixing a bug in this code
 ; right now, temp1=y=starting memory location, temp3=final
 ; x should equal original x value
keepgoingy
 jsr plotpoint
 iny
 iny
 if pfwidth=4
   iny
   iny
 endif
 cpy temp3
 bmi keepgoingy
 RETURN

plotpoint
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon  ; if "on" go to on
 lsr
 bcs pixeloff ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
  ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixelon
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixeloff
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts

setbyte
 ifnconst pfcenter
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 endif
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
pfscroll ;(a=0 left, 1 right, 2 up, 4 down, 6=upup, 12=downdown)
 bne notleft
;left
 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
leftloop
 lda playfield-1,x
 lsr

 ifconst superchip
 lda playfield-2,x
 rol
 sta playfield-130,x
 lda playfield-3,x
 ror
 sta playfield-131,x
 lda playfield-4,x
 rol
 sta playfield-132,x
 lda playfield-1,x
 ror
 sta playfield-129,x
 else
 rol playfield-2,x
 ror playfield-3,x
 rol playfield-4,x
 ror playfield-1,x
 endif

 txa
 sbx #4
 bne leftloop
 RETURN

notleft
 lsr
 bcc notright
;right

 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
rightloop
 lda playfield-4,x
 lsr
 ifconst superchip
 lda playfield-3,x
 rol
 sta playfield-131,x
 lda playfield-2,x
 ror
 sta playfield-130,x
 lda playfield-1,x
 rol
 sta playfield-129,x
 lda playfield-4,x
 ror
 sta playfield-132,x
 else
 rol playfield-3,x
 ror playfield-2,x
 rol playfield-1,x
 ror playfield-4,x
 endif
 txa
 sbx #4
 bne rightloop
  RETURN

notright
 lsr
 bcc notup
;up
 lsr
 bcc onedecup
 dec playfieldpos
onedecup
 dec playfieldpos
 beq shiftdown 
 bpl noshiftdown2 
shiftdown
  ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif

 sta playfieldpos
 lda playfield+3
 sta temp4
 lda playfield+2
 sta temp3
 lda playfield+1
 sta temp2
 lda playfield
 sta temp1
 ldx #0
up2
 lda playfield+4,x
 ifconst superchip
 sta playfield-128,x
 lda playfield+5,x
 sta playfield-127,x
 lda playfield+6,x
 sta playfield-126,x
 lda playfield+7,x
 sta playfield-125,x
 else
 sta playfield,x
 lda playfield+5,x
 sta playfield+1,x
 lda playfield+6,x
 sta playfield+2,x
 lda playfield+7,x
 sta playfield+3,x
 endif
 txa
 sbx #252
 ifconst pfres
 cpx #(pfres-1)*4
 else
 cpx #44
 endif
 bne up2

 lda temp4
 
 ifconst superchip
 ifconst pfres
 sta playfield+pfres*4-129
 lda temp3
 sta playfield+pfres*4-130
 lda temp2
 sta playfield+pfres*4-131
 lda temp1
 sta playfield+pfres*4-132
 else
 sta playfield+47-128
 lda temp3
 sta playfield+46-128
 lda temp2
 sta playfield+45-128
 lda temp1
 sta playfield+44-128
 endif
 else
 ifconst pfres
 sta playfield+pfres*4-1
 lda temp3
 sta playfield+pfres*4-2
 lda temp2
 sta playfield+pfres*4-3
 lda temp1
 sta playfield+pfres*4-4
 else
 sta playfield+47
 lda temp3
 sta playfield+46
 lda temp2
 sta playfield+45
 lda temp1
 sta playfield+44
 endif
 endif
noshiftdown2
 RETURN


notup
;down
 lsr
 bcs oneincup
 inc playfieldpos
oneincup
 inc playfieldpos
 lda playfieldpos

  ifconst pfrowheight
 cmp #pfrowheight+1
 else
 ifnconst pfres
   cmp #9
 else
   cmp #(96/pfres)+1 ; try to come close to the real size
 endif
 endif

 bcc noshiftdown 
 lda #1
 sta playfieldpos

 ifconst pfres
 lda playfield+pfres*4-1
 sta temp4
 lda playfield+pfres*4-2
 sta temp3
 lda playfield+pfres*4-3
 sta temp2
 lda playfield+pfres*4-4
 else
 lda playfield+47
 sta temp4
 lda playfield+46
 sta temp3
 lda playfield+45
 sta temp2
 lda playfield+44
 endif

 sta temp1

 ifconst pfres
 ldx #(pfres-1)*4
 else
 ldx #44
 endif
down2
 lda playfield-1,x
 ifconst superchip
 sta playfield-125,x
 lda playfield-2,x
 sta playfield-126,x
 lda playfield-3,x
 sta playfield-127,x
 lda playfield-4,x
 sta playfield-128,x
 else
 sta playfield+3,x
 lda playfield-2,x
 sta playfield+2,x
 lda playfield-3,x
 sta playfield+1,x
 lda playfield-4,x
 sta playfield,x
 endif
 txa
 sbx #4
 bne down2

 lda temp4
 ifconst superchip
 sta playfield-125
 lda temp3
 sta playfield-126
 lda temp2
 sta playfield-127
 lda temp1
 sta playfield-128
 else
 sta playfield+3
 lda temp3
 sta playfield+2
 lda temp2
 sta playfield+1
 lda temp1
 sta playfield
 endif
noshiftdown
 RETURN
;standard routines needed for pretty much all games
; just the random number generator is left - maybe we should remove this asm file altogether?
; repositioning code and score pointer setup moved to overscan
; read switches, joysticks now compiler generated (more efficient)

randomize
	lda rand
	lsr
 ifconst rand16
	rol rand16
 endif
	bcc noeor
	eor #$B4
noeor
	sta rand
 ifconst rand16
	eor rand16
 endif
	RETURN
drawscreen
 ifconst debugscore
   ldx #14
   lda INTIM ; display # cycles left in the score

 ifconst mincycles
 lda mincycles 
 cmp INTIM
 lda mincycles
 bcc nochange
 lda INTIM
 sta mincycles
nochange
 endif

;   cmp #$2B
;   bcs no_cycles_left
   bmi cycles_left
   ldx #64
   eor #$ff ;make negative
cycles_left
   stx scorecolor
   and #$7f ; clear sign bit
   tax
   lda scorebcd,x
   sta score+2
   lda scorebcd1,x
   sta score+1
   jmp done_debugscore   
scorebcd
 .byte $00, $64, $28, $92, $56, $20, $84, $48, $12, $76, $40
 .byte $04, $68, $32, $96, $60, $24, $88, $52, $16, $80, $44
 .byte $08, $72, $36, $00, $64, $28, $92, $56, $20, $84, $48
 .byte $12, $76, $40, $04, $68, $32, $96, $60, $24, $88
scorebcd1
 .byte 0, 0, 1, 1, 2, 3, 3, 4, 5, 5, 6
 .byte 7, 7, 8, 8, 9, $10, $10, $11, $12, $12, $13
 .byte $14, $14, $15, $16, $16, $17, $17, $18, $19, $19, $20
 .byte $21, $21, $22, $23, $23, $24, $24, $25, $26, $26
done_debugscore
 endif

 ifconst debugcycles
   lda INTIM ; if we go over, it mucks up the background color
;   cmp #$2B
;   BCC overscan
   bmi overscan
   sta COLUBK
   bcs doneoverscan
 endif

 
overscan
 lda INTIM ;wait for sync
 bmi overscan
doneoverscan
;do VSYNC
 lda #2
 sta WSYNC
 sta VSYNC
 STA WSYNC
 STA WSYNC
 lsr
 STA WSYNC
 STA VSYNC
 sta VBLANK
 ifnconst overscan_time
 lda #37+128
 else
 lda #overscan_time+128
 endif
 sta TIM64T

 ifconst legacy
 if legacy < 100
 ldx #4
adjustloop
 lda player0x,x
 sec
 sbc #14 ;?
 sta player0x,x
 dex
 bpl adjustloop
 endif
 endif
 if ((<*)>$e9)&&((<*)<$fa)
 repeat ($fa-(<*))
 nop
 repend
 endif
  sta WSYNC
  ldx #4
  SLEEP 3
HorPosLoop       ;     5
  lda player0x,X  ;+4   9
  sec           ;+2  11
DivideLoop
  sbc #15
  bcs DivideLoop;+4  15
  sta temp1,X    ;+4  19
  sta RESP0,X   ;+4  23
  sta WSYNC
  dex
  bpl HorPosLoop;+5   5
                ;     4

  ldx #4
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 18

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 32

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 46

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 60

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 74

  sta WSYNC
 
  sta HMOVE     ;+3   3


 ifconst legacy
 if legacy < 100
 ldx #4
adjustloop2
 lda player0x,x
 clc
 adc #14 ;?
 sta player0x,x
 dex
 bpl adjustloop2
 endif
 endif




;set score pointers
 lax score+2
 jsr scorepointerset
 sty scorepointers+5
 stx scorepointers+2
 lax score+1
 jsr scorepointerset
 sty scorepointers+4
 stx scorepointers+1
 lax score
 jsr scorepointerset
 sty scorepointers+3
 stx scorepointers

vblk
; run possible vblank bB code
 ifconst vblank_bB_code
   jsr vblank_bB_code
 endif
vblk2
 LDA INTIM
 bmi vblk2
 jmp kernel
 

    .byte $80,$70,$60,$50,$40,$30,$20,$10,$00
    .byte $F0,$E0,$D0,$C0,$B0,$A0,$90
repostable

scorepointerset
 and #$0F
 asl
 asl
 asl
 adc #<scoretable
 tay 
 txa
; and #$F0
; lsr
 asr #$F0
 adc #<scoretable
 tax
 rts
;bB.asm
; bB.asm file is split here
 if (<*) > (<(*+8))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL070_0
	.byte     %01100000
	.byte     %11110000
	.byte     %11110000
	.byte     %01100000
	.byte     %00000000
	.byte     %00000000
	.byte     %00000000
	.byte     %00000000
       echo "    ",[(scoretable - *)]d , "bytes of ROM space left in bank 8")
 
 
 ; feel free to modify the score graphics - just keep each digit 8 highj
 ; and keep the conditional compilation stuff intact

scorelength = (LENDEC+LENHEX+LENSPACE+LENDOLLAR+LENPOUND+LENMRHAPPY+LENMRSAD+LENCOPYRIGHT+LENFUJI+LENHEART+LENDIAMOND+LENSPADE+LENCLUB+LENCOLON+LENBLOCK+LENUNDERLINE+LENARISIDE+LENARIFACE) 

 ifconst ROM2k
   ORG $F7FC-scorelength
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2FE4-scorelength-bscode_length
       RORG $FFE4-scorelength-bscode_length
     endif
     if bankswitch == 16
       ORG $4FE4-scorelength-bscode_length
       RORG $FFE4-scorelength-bscode_length
     endif
     if bankswitch == 32
       ORG $8FE4-scorelength-bscode_length
       RORG $FFE4-scorelength-bscode_length
     endif
   else
     ORG $FFEC-scorelength
   endif
 endif

NOFONT = 0
STOCK = 1 	;_FONTNAME
NEWCENTURY = 2	;_FONTNAME
WHIMSEY = 3	;_FONTNAME
ALARMCLOCK = 4	;_FONTNAME
HANDWRITTEN = 5 ;_FONTNAME
INTERRUPTED = 6 ;_FONTNAME
TINY = 7	;_FONTNAME
RETROPUTER = 8	;_FONTNAME
CURVES = 9	;_FONTNAME
HUSKY = 10	;_FONTNAME
SNAKE = 11	;_FONTNAME
PLOK = 13	;_FONTNAME

SYMBOLS = 0 	;_FONTNAME 

; ### setup some defaults
 ifnconst fontstyle
fontstyle = STOCK
 endif

scoretable

 if fontstyle == STOCK

LENDEC = 80

       ;byte %00000000 ; STOCK

       .byte %00111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %01111110 ; STOCK
       .byte %00011000 ; STOCK
       .byte %00011000 ; STOCK
       .byte %00011000 ; STOCK
       .byte %00011000 ; STOCK
       .byte %00111000 ; STOCK
       .byte %00011000 ; STOCK
       .byte %00001000 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %01111110 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %00111100 ; STOCK
       .byte %00000110 ; STOCK
       .byte %00000110 ; STOCK
       .byte %01000110 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00111100 ; STOCK
       .byte %01000110 ; STOCK
       .byte %00000110 ; STOCK
       .byte %00000110 ; STOCK
       .byte %00011100 ; STOCK
       .byte %00000110 ; STOCK
       .byte %01000110 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00001100 ; STOCK
       .byte %00001100 ; STOCK
       .byte %01111110 ; STOCK
       .byte %01001100 ; STOCK
       .byte %01001100 ; STOCK
       .byte %00101100 ; STOCK
       .byte %00011100 ; STOCK
       .byte %00001100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00111100 ; STOCK
       .byte %01000110 ; STOCK
       .byte %00000110 ; STOCK
       .byte %00000110 ; STOCK
       .byte %00111100 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01111110 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01111100 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100010 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00110000 ; STOCK
       .byte %00110000 ; STOCK
       .byte %00110000 ; STOCK
       .byte %00011000 ; STOCK
       .byte %00001100 ; STOCK
       .byte %00000110 ; STOCK
       .byte %01000010 ; STOCK
       .byte %00111110 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %00111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00111100 ; STOCK
       .byte %01000110 ; STOCK
       .byte %00000110 ; STOCK
       .byte %00111110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

 ifconst fontcharsHEX 
LENHEX = 48

       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01111110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %01111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %00111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100110 ; STOCK
       .byte %00111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %01111100 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01100110 ; STOCK
       .byte %01111100 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %01111110 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01111100 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01111110 ; STOCK

       ;byte %00000000 ; STOCK

       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01111100 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01100000 ; STOCK
       .byte %01111110 ; STOCK

       ;byte %00000000 ; STOCK
       ;byte %00000000 ; STOCK
       ;byte %00000000 ; STOCK
       ;byte %00000000 ; STOCK

 else
LENHEX = 0
 endif ; fontcharsHEX 
 endif ; STOCK

 if fontstyle == NEWCENTURY
LENDEC = 80
       ;byte %00000000 ; NEWCENTURY

       .byte %00111100 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %00100100 ; NEWCENTURY
       .byte %00100100 ; NEWCENTURY
       .byte %00100100 ; NEWCENTURY
       .byte %00011000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %01111110 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %00100000 ; NEWCENTURY
       .byte %00011100 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00011100 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %01111100 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00111100 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00011100 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00111110 ; NEWCENTURY
       .byte %00100010 ; NEWCENTURY
       .byte %00100010 ; NEWCENTURY
       .byte %00010010 ; NEWCENTURY
       .byte %00010010 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %01111100 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %01111100 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01111000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %00111100 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01111100 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %00110000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %00010000 ; NEWCENTURY
       .byte %00010000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00001000 ; NEWCENTURY
       .byte %00000100 ; NEWCENTURY
       .byte %00000100 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00011110 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %00111100 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %00111100 ; NEWCENTURY
       .byte %00100100 ; NEWCENTURY
       .byte %00100100 ; NEWCENTURY
       .byte %00011000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %00111100 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00000010 ; NEWCENTURY
       .byte %00001110 ; NEWCENTURY
       .byte %00010010 ; NEWCENTURY
       .byte %00010010 ; NEWCENTURY
       .byte %00001100 ; NEWCENTURY

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; NEWCENTURY

       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01111100 ; NEWCENTURY
       .byte %01000100 ; NEWCENTURY
       .byte %01000100 ; NEWCENTURY
       .byte %00111000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %01111100 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01111100 ; NEWCENTURY
       .byte %01000100 ; NEWCENTURY
       .byte %01000100 ; NEWCENTURY
       .byte %01111000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %00111100 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %00111000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %01111100 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000010 ; NEWCENTURY
       .byte %01000100 ; NEWCENTURY
       .byte %01000100 ; NEWCENTURY
       .byte %01111000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %01111110 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01111100 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01111000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY

       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01111100 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01000000 ; NEWCENTURY
       .byte %01111000 ; NEWCENTURY

       ;byte %00000000 ; NEWCENTURY
       ;byte %00000000 ; NEWCENTURY
       ;byte %00000000 ; NEWCENTURY
       ;byte %00000000 ; NEWCENTURY

 else
LENHEX = 0
 endif ; fontcharsHEX 
 endif ; NEWCENTURY

 if fontstyle == WHIMSEY
LENDEC = 80
       ;byte %00000000 ; WHIMSEY

       .byte %00111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %00011000 ; WHIMSEY
       .byte %00011000 ; WHIMSEY
       .byte %00011000 ; WHIMSEY
       .byte %01111000 ; WHIMSEY
       .byte %00011000 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111000 ; WHIMSEY
       .byte %00111100 ; WHIMSEY
       .byte %00001110 ; WHIMSEY
       .byte %01100110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %00111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01101110 ; WHIMSEY
       .byte %00001110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY
       .byte %00011100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %00011100 ; WHIMSEY
       .byte %00011100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01011100 ; WHIMSEY
       .byte %01011100 ; WHIMSEY
       .byte %00011100 ; WHIMSEY
       .byte %00011100 ; WHIMSEY
       .byte %00011100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %00111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01101110 ; WHIMSEY
       .byte %00001110 ; WHIMSEY
       .byte %01111100 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01111110 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %00111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01111100 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %00111110 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %01111000 ; WHIMSEY
       .byte %01111000 ; WHIMSEY
       .byte %01111000 ; WHIMSEY
       .byte %00111100 ; WHIMSEY
       .byte %00011100 ; WHIMSEY
       .byte %00001110 ; WHIMSEY
       .byte %00001110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %00111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %00111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %00000110 ; WHIMSEY
       .byte %00111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; WHIMSEY

       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %01111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01111100 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %00111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %00111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %01111100 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01110110 ; WHIMSEY
       .byte %01111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01111110 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01111100 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY

       .byte %01110000 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01111100 ; WHIMSEY
       .byte %01110000 ; WHIMSEY
       .byte %01111100 ; WHIMSEY

       ;byte %00000000 ; WHIMSEY
       ;byte %00000000 ; WHIMSEY
       ;byte %00000000 ; WHIMSEY
       ;byte %00000000 ; WHIMSEY

 else
LENHEX = 0
 endif ; fontcharsHEX

 endif ; WHIMSEY

 if fontstyle == ALARMCLOCK
LENDEC = 80

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00000000 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00000000 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00000000 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK


 ifconst fontcharsHEX 
LENHEX = 48
       ;byte %00000000 ; ALARMCLOCK


       .byte %00000000 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %01000010 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000010 ; ALARMCLOCK
       .byte %00000000 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK

       .byte %00000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %01000000 ; ALARMCLOCK
       .byte %00111100 ; ALARMCLOCK

       ;byte %00000000 ; ALARMCLOCK
       ;byte %00000000 ; ALARMCLOCK
       ;byte %00000000 ; ALARMCLOCK
       ;byte %00000000 ; ALARMCLOCK

 else
LENHEX = 0
 endif ; fontcharsHEX
 endif ; ALARMCLOCK

 if fontstyle == HANDWRITTEN
LENDEC = 80

       ;byte %00000000 ; HANDWRITTEN

       .byte %00110000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00010000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %01110000 ; HANDWRITTEN
       .byte %01001100 ; HANDWRITTEN
       .byte %01000000 ; HANDWRITTEN
       .byte %00100000 ; HANDWRITTEN
       .byte %00011000 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00100010 ; HANDWRITTEN
       .byte %00011100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00110000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00011000 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00100010 ; HANDWRITTEN
       .byte %00011100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00010000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %01111000 ; HANDWRITTEN
       .byte %01000100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00000010 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00110000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00011000 ; HANDWRITTEN
       .byte %00100000 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00010000 ; HANDWRITTEN
       .byte %00101000 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00011000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %00000110 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00010000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00000100 ; HANDWRITTEN
       .byte %00110010 ; HANDWRITTEN
       .byte %00001110 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00110000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01000100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00011100 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001010 ; HANDWRITTEN
       .byte %00000110 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00010000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN
       .byte %00011100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001100 ; HANDWRITTEN

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; HANDWRITTEN

       .byte %00110110 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001110 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %11110000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01000100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00111100 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00110000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01000000 ; HANDWRITTEN
       .byte %00100000 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00010100 ; HANDWRITTEN
       .byte %00001000 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %01111000 ; HANDWRITTEN
       .byte %01000100 ; HANDWRITTEN
       .byte %01000100 ; HANDWRITTEN
       .byte %00100100 ; HANDWRITTEN
       .byte %00100010 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %00110000 ; HANDWRITTEN
       .byte %01001000 ; HANDWRITTEN
       .byte %01000000 ; HANDWRITTEN
       .byte %00100000 ; HANDWRITTEN
       .byte %00011000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN

       .byte %01000000 ; HANDWRITTEN
       .byte %01000000 ; HANDWRITTEN
       .byte %01000000 ; HANDWRITTEN
       .byte %00100000 ; HANDWRITTEN
       .byte %00111000 ; HANDWRITTEN
       .byte %00010000 ; HANDWRITTEN
       .byte %00010010 ; HANDWRITTEN
       .byte %00001100 ; HANDWRITTEN

       ;byte %00000000 ; HANDWRITTEN
       ;byte %00000000 ; HANDWRITTEN
       ;byte %00000000 ; HANDWRITTEN
       ;byte %00000000 ; HANDWRITTEN

 else
LENHEX = 0
 endif ; fontcharsHEX
 endif ; HANDWRITTEN

 if fontstyle == INTERRUPTED
LENDEC = 80

       ;byte %00000000 ; INTERRUPTED

       .byte %00110100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %00110100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %00111100 ; INTERRUPTED
       .byte %00000000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00111000 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %01101110 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %00110000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00001100 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %01000110 ; INTERRUPTED
       .byte %00111100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %01111100 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %01110110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %01110100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %01110110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %01111100 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %01111100 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01101110 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %00101100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01101100 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %00110000 ; INTERRUPTED
       .byte %00011100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %00011000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00011000 ; INTERRUPTED
       .byte %00011100 ; INTERRUPTED
       .byte %00001110 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00000000 ; INTERRUPTED
       .byte %01111110 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %00110100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %00110100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %00110100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %00111000 ; INTERRUPTED
       .byte %00001100 ; INTERRUPTED
       .byte %00000110 ; INTERRUPTED
       .byte %00110110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %00110100 ; INTERRUPTED

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; INTERRUPTED

       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01110110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %00111100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %01110100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01110100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01110100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %00101100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %00101100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %01111100 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01100110 ; INTERRUPTED
       .byte %01101100 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %01111110 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01101110 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01101110 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED

       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01101110 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01100000 ; INTERRUPTED
       .byte %01101110 ; INTERRUPTED

       ;byte %00000000 ; INTERRUPTED
       ;byte %00000000 ; INTERRUPTED
       ;byte %00000000 ; INTERRUPTED
       ;byte %00000000 ; INTERRUPTED

 else
LENHEX = 0
 endif ; fontcharsHEX
 endif ; INTERRUPTED


 if fontstyle == TINY
LENDEC = 80

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00101000 ; TINY
       .byte %00101000 ; TINY
       .byte %00101000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00010000 ; TINY
       .byte %00010000 ; TINY
       .byte %00010000 ; TINY
       .byte %00010000 ; TINY
       .byte %00010000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00001000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00001000 ; TINY
       .byte %00111000 ; TINY
       .byte %00001000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00001000 ; TINY
       .byte %00001000 ; TINY
       .byte %00111000 ; TINY
       .byte %00101000 ; TINY
       .byte %00101000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00001000 ; TINY
       .byte %00111000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00101000 ; TINY
       .byte %00111000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00001000 ; TINY
       .byte %00001000 ; TINY
       .byte %00001000 ; TINY
       .byte %00001000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00101000 ; TINY
       .byte %00111000 ; TINY
       .byte %00101000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00001000 ; TINY
       .byte %00001000 ; TINY
       .byte %00111000 ; TINY
       .byte %00101000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00101000 ; TINY
       .byte %00101000 ; TINY
       .byte %00111000 ; TINY
       .byte %00101000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00110000 ; TINY
       .byte %00101000 ; TINY
       .byte %00110000 ; TINY
       .byte %00101000 ; TINY
       .byte %00110000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00100000 ; TINY
       .byte %00100000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00110000 ; TINY
       .byte %00101000 ; TINY
       .byte %00101000 ; TINY
       .byte %00101000 ; TINY
       .byte %00110000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00111000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY

       .byte %00000000 ; TINY
       .byte %00100000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00100000 ; TINY
       .byte %00111000 ; TINY
       .byte %00000000 ; TINY
       .byte %00000000 ; TINY

       ;byte %00000000 ; TINY
       ;byte %00000000 ; TINY
       ;byte %00000000 ; TINY
       ;byte %00000000 ; TINY

 else
LENHEX = 0

 endif ; fontcharsHEX
 endif ; TINY

 if fontstyle == RETROPUTER
LENDEC = 80

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %00111000 ; RETROPUTER
       .byte %00111000 ; RETROPUTER
       .byte %00111000 ; RETROPUTER
       .byte %00111000 ; RETROPUTER
       .byte %00011000 ; RETROPUTER
       .byte %00011000 ; RETROPUTER
       .byte %00011000 ; RETROPUTER
       .byte %00011000 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01100000 ; RETROPUTER
       .byte %01100000 ; RETROPUTER
       .byte %01100000 ; RETROPUTER
       .byte %00111110 ; RETROPUTER
       .byte %00000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %00000110 ; RETROPUTER
       .byte %00000110 ; RETROPUTER
       .byte %00111110 ; RETROPUTER
       .byte %00000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %00001100 ; RETROPUTER
       .byte %00001100 ; RETROPUTER
       .byte %00001100 ; RETROPUTER
       .byte %01111110 ; RETROPUTER
       .byte %01000100 ; RETROPUTER
       .byte %01000100 ; RETROPUTER
       .byte %01000100 ; RETROPUTER
       .byte %00000100 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %00000110 ; RETROPUTER
       .byte %00000110 ; RETROPUTER
       .byte %01111100 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01111100 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %00001100 ; RETROPUTER
       .byte %00001100 ; RETROPUTER
       .byte %00001100 ; RETROPUTER
       .byte %00001100 ; RETROPUTER
       .byte %00000100 ; RETROPUTER
       .byte %00000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01000110 ; RETROPUTER
       .byte %01111110 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %00000110 ; RETROPUTER
       .byte %00000110 ; RETROPUTER
       .byte %00000110 ; RETROPUTER
       .byte %00000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000  ; RETROPUTER

       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111100 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100000 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111100 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111100 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01111110 ; RETROPUTER
       .byte %01100010 ; RETROPUTER
       .byte %01100000 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01111100 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER

       .byte %01100000 ; RETROPUTER
       .byte %01100000 ; RETROPUTER
       .byte %01100000 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01111100 ; RETROPUTER
       .byte %01000000 ; RETROPUTER
       .byte %01000010 ; RETROPUTER
       .byte %01111110 ; RETROPUTER

       ;byte %00000000 ; RETROPUTER
       ;byte %00000000 ; RETROPUTER
       ;byte %00000000 ; RETROPUTER
       ;byte %00000000 ; RETROPUTER

 else
LENHEX = 0
 endif ; fontcharsHEX
 endif ; RETROPUTER

 if fontstyle == CURVES

LENDEC = 80

       ;byte %00000000 ; CURVES

       .byte %00111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %00011000 ; CURVES
       .byte %00011000 ; CURVES
       .byte %00011000 ; CURVES
       .byte %00011000 ; CURVES
       .byte %00011000 ; CURVES
       .byte %00011000 ; CURVES
       .byte %01111000 ; CURVES
       .byte %01110000 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %01111110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111100 ; CURVES
       .byte %00111110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %01111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00001110 ; CURVES
       .byte %00111100 ; CURVES
       .byte %00111100 ; CURVES
       .byte %00001110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %00000110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %00111110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %01111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111100 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111110 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %00111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111100 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111110 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %00000110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %00111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111100 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %01111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00000110 ; CURVES
       .byte %00111110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111100 ; CURVES

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; CURVES

       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %01111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111100 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %00111110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111110 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %01111100 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01100110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01111100 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %00111110 ; CURVES
       .byte %01111110 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111100 ; CURVES
       .byte %01111100 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111110 ; CURVES

       ;byte %00000000 ; CURVES

       .byte %01100000 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111100 ; CURVES
       .byte %01111100 ; CURVES
       .byte %01100000 ; CURVES
       .byte %01111110 ; CURVES
       .byte %00111110 ; CURVES

       ;byte %00000000 ; CURVES
       ;byte %00000000 ; CURVES
       ;byte %00000000 ; CURVES
       ;byte %00000000 ; CURVES

 else
LENHEX = 0
 endif ; fontcharsHEX 
 endif ; CURVES


 if fontstyle == HUSKY

LENDEC = 80

       ;byte %00000000 ; HUSKY

       .byte %01111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %01111100 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %01111110 ; HUSKY
       .byte %00001110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111100 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %00001110 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %00001110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111100 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %00011100 ; HUSKY
       .byte %00011100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11011100 ; HUSKY
       .byte %11011100 ; HUSKY
       .byte %00011100 ; HUSKY
       .byte %00011100 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %00001110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %01111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %01111110 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00111000 ; HUSKY
       .byte %00011100 ; HUSKY
       .byte %00001110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %01111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %01111100 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %01111100 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %00001110 ; HUSKY
       .byte %01111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %01111100 ; HUSKY

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; HUSKY

       .byte %11101110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %01111100 ; HUSKY
       .byte %00111000 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111100 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %01111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11110000 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11110000 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %01111110 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11111000 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11101110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111100 ; HUSKY
       .byte %11111000 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY

       ;byte %00000000 ; HUSKY

       .byte %11100000 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11100000 ; HUSKY
       .byte %11111110 ; HUSKY
       .byte %11111110 ; HUSKY

       ;byte %00000000 ; HUSKY
       ;byte %00000000 ; HUSKY
       ;byte %00000000 ; HUSKY
       ;byte %00000000 ; HUSKY

 else
LENHEX = 0
 endif ; fontcharsHEX 
 endif ; HUSKY


 if fontstyle == SNAKE

LENDEC = 80

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %00111000 ; SNAKE
       .byte %00101000 ; SNAKE
       .byte %00001000 ; SNAKE
       .byte %00001000 ; SNAKE
       .byte %00001000 ; SNAKE
       .byte %00001000 ; SNAKE
       .byte %00001000 ; SNAKE
       .byte %00111000 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01100010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %00001110 ; SNAKE
       .byte %00001010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01100110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01100010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %00000110 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %01100010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %00001110 ; SNAKE
       .byte %00001010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %00000010 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE


 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; SNAKE

       .byte %01100110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01111100 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111100 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01111100 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01111110 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01000110 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01111000 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE

       .byte %01000000 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01111000 ; SNAKE
       .byte %01000000 ; SNAKE
       .byte %01000010 ; SNAKE
       .byte %01111110 ; SNAKE

       ;byte %00000000 ; SNAKE
       ;byte %00000000 ; SNAKE
       ;byte %00000000 ; SNAKE
       ;byte %00000000 ; SNAKE

 else
LENHEX = 0
 endif ; fontcharsHEX 
 endif ; SNAKE

 if fontstyle == PLOK
LENDEC = 80

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00111000 ; PLOK
       .byte %01100100 ; PLOK
       .byte %01100010 ; PLOK
       .byte %01100010 ; PLOK
       .byte %00110110 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00010000 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00011000 ; PLOK
       .byte %00111000 ; PLOK
       .byte %00011000 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00001110 ; PLOK
       .byte %01111110 ; PLOK
       .byte %00011000 ; PLOK
       .byte %00001100 ; PLOK
       .byte %00000110 ; PLOK
       .byte %00111100 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00111100 ; PLOK
       .byte %01101110 ; PLOK
       .byte %00001110 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00000110 ; PLOK
       .byte %01111100 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00011000 ; PLOK
       .byte %01111110 ; PLOK
       .byte %01101100 ; PLOK
       .byte %00100100 ; PLOK
       .byte %00110000 ; PLOK
       .byte %00110000 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00111100 ; PLOK
       .byte %01001110 ; PLOK
       .byte %00011100 ; PLOK
       .byte %01100000 ; PLOK
       .byte %01111100 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00111100 ; PLOK
       .byte %01000110 ; PLOK
       .byte %01101100 ; PLOK
       .byte %01110000 ; PLOK
       .byte %00111000 ; PLOK
       .byte %00010000 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00111100 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00001100 ; PLOK
       .byte %00000110 ; PLOK
       .byte %01111110 ; PLOK
       .byte %00110000 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00111100 ; PLOK
       .byte %01001110 ; PLOK
       .byte %01101110 ; PLOK
       .byte %00111100 ; PLOK
       .byte %01100100 ; PLOK
       .byte %00111000 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00011000 ; PLOK
       .byte %00001100 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00100110 ; PLOK
       .byte %01001110 ; PLOK
       .byte %00111100 ; PLOK
       .byte %00000000 ; PLOK

 ifconst fontcharsHEX 
LENHEX = 48

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %01100010 ; PLOK
       .byte %01100110 ; PLOK
       .byte %01111110 ; PLOK
       .byte %00101100 ; PLOK
       .byte %00101000 ; PLOK
       .byte %00110000 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %01111100 ; PLOK
       .byte %00110010 ; PLOK
       .byte %00110110 ; PLOK
       .byte %00111100 ; PLOK
       .byte %00110110 ; PLOK
       .byte %01111100 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %00111100 ; PLOK
       .byte %01100110 ; PLOK
       .byte %01100000 ; PLOK
       .byte %01100100 ; PLOK
       .byte %00101110 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %01111100 ; PLOK
       .byte %00110010 ; PLOK
       .byte %00110010 ; PLOK
       .byte %00110110 ; PLOK
       .byte %01111100 ; PLOK
       .byte %01111000 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %01111110 ; PLOK
       .byte %00110000 ; PLOK
       .byte %00111000 ; PLOK
       .byte %00111100 ; PLOK
       .byte %00110000 ; PLOK
       .byte %01111110 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK

       .byte %00000000 ; PLOK
       .byte %01100000 ; PLOK
       .byte %01100000 ; PLOK
       .byte %00111000 ; PLOK
       .byte %00100000 ; PLOK
       .byte %01111110 ; PLOK
       .byte %00011100 ; PLOK
       .byte %00000000 ; PLOK

       ;byte %00000000 ; PLOK
       ;byte %00000000 ; PLOK
       ;byte %00000000 ; PLOK
       ;byte %00000000 ; PLOK


 else
LENHEX = 0
 endif ; fontcharsHEX
 endif ; PLOK




 if fontstyle == NOFONT
LENDEC = 0
LENHEX = 0
 endif ; NOFONT


; ### any characters that aren't font specific follow... 

 ifconst fontcharSPACE
LENSPACE = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS
 else
LENSPACE = 0
 endif ; fontcharSPACE

 ifconst fontcharDOLLAR
LENDOLLAR = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00000000 ; SYMBOLS
       .byte %00010000 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %00010010 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %10010000 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %00010000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENDOLLAR = 0
 endif ; fontcharDOLLAR

 ifconst fontcharPOUND
LENPOUND = 8
       ;byte %00000000 ; SYMBOLS

       .byte %01111110 ; SYMBOLS
       .byte %01000000 ; SYMBOLS
       .byte %00100000 ; SYMBOLS
       .byte %00100000 ; SYMBOLS
       .byte %01111000 ; SYMBOLS
       .byte %00100000 ; SYMBOLS
       .byte %00100010 ; SYMBOLS
       .byte %00011100 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENPOUND = 0
 endif ; fontcharPOUND


 ifconst fontcharMRHAPPY
LENMRHAPPY = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00111100 ; SYMBOLS
       .byte %01100110 ; SYMBOLS
       .byte %01011010 ; SYMBOLS
       .byte %01111110 ; SYMBOLS
       .byte %01111110 ; SYMBOLS
       .byte %01011010 ; SYMBOLS
       .byte %01111110 ; SYMBOLS
       .byte %00111100 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENMRHAPPY = 0
 endif ; fontcharMRHAPPY

 ifconst fontcharMRSAD
LENMRSAD = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00111100 ; SYMBOLS
       .byte %01011010 ; SYMBOLS
       .byte %01100110 ; SYMBOLS
       .byte %01111110 ; SYMBOLS
       .byte %01111110 ; SYMBOLS
       .byte %01011010 ; SYMBOLS
       .byte %01111110 ; SYMBOLS
       .byte %00111100 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENMRSAD = 0
 endif ; fontcharMRSAD


 ifconst fontcharCOPYRIGHT
LENCOPYRIGHT = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00000000 ; SYMBOLS
       .byte %00111000 ; SYMBOLS
       .byte %01000100 ; SYMBOLS
       .byte %10111010 ; SYMBOLS
       .byte %10100010 ; SYMBOLS
       .byte %10111010 ; SYMBOLS
       .byte %01000100 ; SYMBOLS
       .byte %00111000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENCOPYRIGHT = 0
 endif ; fontcharCOPYRIGHT


 ifconst fontcharFUJI
LENFUJI = 16

       ;byte %00000000 ; ** these commented-out blanks are for the preview generation program

       .byte %01110000 ; SYMBOLS
       .byte %01111001 ; SYMBOLS
       .byte %00011101 ; SYMBOLS
       .byte %00001101 ; SYMBOLS
       .byte %00001101 ; SYMBOLS
       .byte %00001101 ; SYMBOLS
       .byte %00001101 ; SYMBOLS
       .byte %00000000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

       .byte %00001110 ; SYMBOLS
       .byte %10011110 ; SYMBOLS
       .byte %10111000 ; SYMBOLS
       .byte %10110000 ; SYMBOLS
       .byte %10110000 ; SYMBOLS
       .byte %10110000 ; SYMBOLS
       .byte %10110000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENFUJI = 0
 endif ; fontcharFUJI


 ifconst fontcharHEART
LENHEART = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00010000 ; SYMBOLS
       .byte %00111000 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %11111110 ; SYMBOLS
       .byte %11111110 ; SYMBOLS
       .byte %11101110 ; SYMBOLS
       .byte %01000100 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENHEART = 0
 endif ; fontcharHEART

 ifconst fontcharDIAMOND
LENDIAMOND = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00010000 ; SYMBOLS
       .byte %00111000 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %11111110 ; SYMBOLS
       .byte %11111110 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %00111000 ; SYMBOLS
       .byte %00010000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENDIAMOND = 0
 endif ; fontcharDIAMOND

 ifconst fontcharSPADE
LENSPADE = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00111000 ; SYMBOLS
       .byte %00010000 ; SYMBOLS
       .byte %01010100 ; SYMBOLS
       .byte %11111110 ; SYMBOLS
       .byte %11111110 ; SYMBOLS
       .byte %01111100 ; SYMBOLS
       .byte %00111000 ; SYMBOLS
       .byte %00010000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENSPADE = 0
 endif ; fontcharSPADE

 ifconst fontcharCLUB
LENCLUB = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00111000 ; SYMBOLS
       .byte %00010000 ; SYMBOLS
       .byte %11010110 ; SYMBOLS
       .byte %11111110 ; SYMBOLS
       .byte %11010110 ; SYMBOLS
       .byte %00111000 ; SYMBOLS
       .byte %00111000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENCLUB = 0
 endif ; fontcharCLUB


 ifconst fontcharCOLON
LENCOLON = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00000000 ; SYMBOLS
       .byte %00011000 ; SYMBOLS
       .byte %00011000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00011000 ; SYMBOLS
       .byte %00011000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENCOLON = 0
 endif ; fontcharCOLON


 ifconst fontcharBLOCK
LENBLOCK = 8

       ;byte %00000000 ; SYMBOLS

       .byte %11111111 ; SYMBOLS
       .byte %11111111 ; SYMBOLS
       .byte %11111111 ; SYMBOLS
       .byte %11111111 ; SYMBOLS
       .byte %11111111 ; SYMBOLS
       .byte %11111111 ; SYMBOLS
       .byte %11111111 ; SYMBOLS
       .byte %11111111 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENBLOCK = 0
 endif ; fontcharBLOCK

 ifconst fontcharUNDERLINE
LENUNDERLINE = 8

       ;byte %00000000 ; SYMBOLS

       .byte %11111111 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS
       .byte %00000000 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENUNDERLINE = 0
 endif ; fontcharUNDERLINE

 ifconst fontcharARISIDE
LENARISIDE = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00000000 ; SYMBOLS
       .byte %00101010 ; SYMBOLS
       .byte %00101010 ; SYMBOLS
       .byte %00101100 ; SYMBOLS
       .byte %01111111 ; SYMBOLS
       .byte %00110111 ; SYMBOLS
       .byte %00000010 ; SYMBOLS
       .byte %00000001 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS

 else
LENARISIDE = 0
 endif ; fontcharARISIDE

 ifconst fontcharARIFACE
LENARIFACE = 8
       ;byte %00000000 ; SYMBOLS

       .byte %00001000 ; SYMBOLS
       .byte %00011100 ; SYMBOLS
       .byte %00111110 ; SYMBOLS
       .byte %00101010 ; SYMBOLS
       .byte %00011100 ; SYMBOLS
       .byte %01010100 ; SYMBOLS
       .byte %00100100 ; SYMBOLS
       .byte %00000010 ; SYMBOLS

       ;byte %00000000 ; SYMBOLS


 else
LENARIFACE = 0
 endif ; fontcharARIRACE

       ;byte %00000000 ; SYMBOLS
       ;byte %00000000 ; SYMBOLS
       ;byte %00000000 ; SYMBOLS
       ;byte %00000000 ; SYMBOLS

scoretableend

 ifconst ROM2k
   ORG $F7FC
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 16
       ORG $4FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 32
       ORG $8FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
   else
     ORG $FFFC
   endif
 endif
; every bank has this stuff at the same place
; this code can switch to/from any bank at any entry point
; and can preserve register values
; note: lines not starting with a space are not placed in all banks
;
; line below tells the compiler how long this is - do not remove
;size=32
begin_bscode
 ldx #$ff
 ifconst FASTFETCH ; using DPC+
 stx FASTFETCH
 endif 
 txs
 lda #>(start-1)
 pha
 lda #<(start-1)
 pha
BS_return
 pha
 txa
 pha
 tsx
 lda 4,x ; get high byte of return address
 rol   
 rol
 rol
 rol
 and #bs_mask ;1 3 or 7 for F8/F6/F4
 tax
 inx
BS_jsr
 lda bankswitch_hotspot-1,x
 pla
 tax
 pla
 rts
 if ((* & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
   echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
   echo "Change to",[(*-begin_bscode+1)&$FF]d,"and try again."
 endif
 ifconst bankswitch
   if bankswitch == 8
     ORG $2FFC
     RORG $FFFC
   endif
   if bankswitch == 16
     ORG $4FFC
     RORG $FFFC
   endif
   if bankswitch == 32
     ORG $8FFC
     RORG $FFFC
   endif
 else
   ifconst ROM2k
     ORG $F7FC
   else
     ORG $FFFC
   endif
 endif
 .word start
 .word start
