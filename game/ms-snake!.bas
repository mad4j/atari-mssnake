/*
 * Ms Snake!
 * an Atari 2600 remake of the famous Snake game
 * 
 * Daniele Olmisani <daniele.olmisani@gmail.com>
 * Luca Olmisani <olmisani.luca@gmail.com>
 * Maria Segnalini <maria.segnalini@gmail.com>
 */

    ; use PAL colors
    set tv pal

    ; use 32KB ROM (8 banks) with Super Chip RAM
    set romsize 32kSC

    ; TODO: verify if needed
    set smartbranching on
    
    ; remove horizontal scan lines
    set kernel_options no_blank_lines

    ; use inlined random for fast bank switching
    set optimization inlinerand

    ; rationale:
    ; random numbers can slow down bank-switched games.
    ; This will speed things up.

    ; use 24 rows playfiled
    const pfres = 24

    ; use ALARMCLOCK font for score digits
    const fontstyle = 4 ; ALARMCLOCK

    ; use meangful names for directions values
    const NORTH = %00000000
    const EAST  = %01010101
    const SOUTH = %10101010
    const WEST  = %11111111 

    ; max snake lngth
    const MAX_LEN = 192

    ; all-purpose bits for various jobs
    dim bits = z
    dim bits0_DebounceReset = z
    dim bits1_DebounceFireButton = z
    dim bits2_GameOverFlag = z

    dim _Master_Counter = s
    dim _Frame_Counter = c

    ; how fast ms-snake is running?
    dim speed = s
 	dim counter = c

    ; position of food
    dim foodX = a
    dim foodY = b

    ; position of ms-snake head
    dim headX = x
    dim headY = y

    ; direction of ms-snake head
    dim headDir = d

    ; grown of ms-snake
    dim grown = g

    ; length of ms-snake
    dim length = l

    ; position of ms-snake tail
    dim tailX = i
    dim tailY = j

    ; start/end index of ms-snake body directions
    dim tailEnd = k
    dim tailStart = h

    ; read/write array of ms-snake body directions
    dim directions = var0

    ; rationale:
    ; with SuperChip RAM the playfield is moved on the extra
    ; space leaving default allocated RAM (var0 - var47) free
    ; for application purposes

    ; activate game sounds
    dim eat_sound = f
    dim crash_sound = f

    dim shakescreen = m
    dim shaking_effect = n



/**
 * Game initializaion
 * clear game internal state and in/out registers
 */

_GameInit

    ; mute volume of both sound channels
    AUDV0 = 0 : AUDV1 = 0

    ; clears 25 of the normal 26 variables
    ; last variable (named 'z') used for all-purposes bits
    for temp5 = 0 to 24 : a[temp5] = 0 : next

    ; clear 7 of the 8 All_Purpose_01 bits
    ; bit 2 is not cleared because bits2_GameOverFlag{2}
    ; is used to control how the program is reset.
    bits = bits & %00000100

    ; TODO: clear also SC registers!

    ; skip title screen if game has been played and player
    ; presses fire button or reset switch at the end of the game
    if bits2_GameOverFlag{2} then goto _MainLoopSetup bank2


_TitleScreenSetup

    scorecolor = $2C

    player0x = 0
    player0y = 0
    
    ; debounce the reset switch
    bits0_DebounceReset{0} = 1

    ; rationale:
    ; the reset switch becomes inactive if it hasn't been
    ; released after entering a different segment of the
    ; program. 
    ; It does double duty sometimes by debouncing
    ; the fire button too.


_TitleScreenLoop

    gosub titledrawscreen bank4

    ; set correct color values in main loop
    ;COLUPF = $DC
    ;COLUBK = $00

    ; rationale
    ; pluggable mini-kernels should modify pre-configured colors

    ; static visualization: nothing else to do
    ;drawscreen

    ; no button pressed then clear debounce bit
    if !switchreset && !joy0fire then bits0_DebounceReset{0} = 0 : goto _SkipTitleResetFire

    ; debounce bit active, then remain on the title screen
    if bits0_DebounceReset{0} then goto _SkipTitleResetFire

    ; button pressed and debounce bit deactivated, then start the game
    goto _MainLoopSetup bank2

    ; rationale:
    ; bank switching and long pressure of console buttons may cause
    ; bouncing effect that results in jumping intermediate screens

_SkipTitleResetFire

    ; return at the beginning of the loop
    goto _TitleScreenLoop


/**
  * START OF BANK 2
  * ---------------
  */

    bank 2

_MainLoopSetup

    ; reset bouncing bits
    bits0_DebounceReset{0} = 1
    bits1_DebounceFireButton{1} = 1
    bits2_GameOverFlag{2} = 0

    ; deactivate sounds
    eat_sound=0
    crash_sound=0

    ; dummy food position
    foodX=0 : foodY=0

    ; ms-sanke head starting position
    headX = 5 : headY = 5

    ; ms-sanke head starting direction
    headDir = EAST

    ; ms-snake initial length
    length=1

    ; ms-snake initial grown
    grown=2

    tailStart = 0 : tailEnd = 0

    tailX = headX-1 : tailY = headY
    directions[tailStart] = headDir

    score = 0


    ; initial ms-snake speed (one step every 'speed' frames)
    speed = 0
    counter = 0

    ; clear the play field
    pfclear

    ; draw game play field
    pfhline 0 0 31 on
    pfhline 0 22 31 on
    pfvline 0 1 21 on
    pfvline 31 1 21 on

    player0:
    %01100000
    %11110000
    %11110000
    %01100000
    %00000000
    %00000000
    %00000000
    %00000000
end

_MainLoop

    COLUP0 = $20
    COLUP1 = $60

    bits1_DebounceFireButton{1} = 0

    drawscreen

    ; if the reset switch is not pressed, turn off debounce and skip this section
    if !switchreset then bits0_DebounceReset{0} = 0 : goto _SkipMainReset

    ; if the reset switch hasn`t been released, skip this section
    if bits0_DebounceReset{0} then goto _SkipMainReset

    ; clear the game over bit so the title screen will appear
    bits2_GameOverFlag{2} = 0

    ; reset pressed appropriately. Restart the program.
    goto _GameInit bank1


_SkipMainReset

    ; check to see if the game is over
    if bits2_GameOverFlag{2} then goto _GameOverSetup bank3

    COLUPF = $52
    COLUBK = $00

    pfpixel headX headY on
    if grown=0 then pfpixel tailX tailY off

    if foodX=0 && foodY=0 then gosub _UpdateFood bank3
    ; pfpixel foodX foodY on

    if eat_sound=0 then goto _SkipSound1
    AUDV0 = 8 : AUDC0 = 4 : AUDF0 = 19
    eat_sound = eat_sound-1
_SkipSound1
    if !eat_sound then AUDV0 = 0

    counter = counter+1
    if counter > speed then gosub _UpdateSnake bank3

    if headX=foodX && headY=foodY then gosub _UpdateEat bank3    

    if joy0up then headDir=NORTH
    if joy0down then headDir=SOUTH
    if joy0left then headDir=WEST
    if joy0right then headDir=EAST    

    goto _MainLoop

    
    bank 3

    data MASKS
    %00000011, %00001100, %00110000, %11000000
end    

_UpdateSnake
    counter=0
    
    if grown>0 then grown=grown-1 : length=length+1 else gosub _UpdateTail

    speed = (MAX_LEN-length)/32

    gosub _UpdateHead

    ; rationale:
    ; update the tail before the head in order to save one memory location
    ; in this way, when MAX_LEN is reached, the location freed by tail
    ; will be occupied by the head

    ; score = score+1
    return

_UpdateHead
    if headDir = NORTH then headY = headY-1
    if headDir = EAST then headX = headX+1
    if headDir = SOUTH then headY = headY+1
    if headDir = WEST then headX = headX-1

    tailStart=tailStart+1
    if tailStart=MAX_LEN then tailStart=0

    temp1 = tailStart / 4
    temp2 = tailStart & %00000011

    temp3 = headDir & MASKS[temp2]

    directions[temp1] = directions[temp1] & (MASKS[temp2] ^ %11111111)
    directions[temp1] = directions[temp1] | temp3

    if headX=foodX && headY=foodY then goto _SkipCollisionCheck
    if pfread(headX, headY) then bits2_GameOverFlag{2} = 1

_SkipCollisionCheck
    return

_UpdateTail

    temp1 = tailEnd / 4
    temp2 = tailEnd & %00000011

    temp3 = directions[temp1] & MASKS[temp2]

    if temp3 = NORTH & MASKS[temp2] then tailY = tailY-1
    if temp3 = EAST & MASKS[temp2] then tailX = tailX+1
    if temp3 = SOUTH & MASKS[temp2] then tailY = tailY+1
    if temp3 = WEST & MASKS[temp2] then tailX = tailX-1

    tailEnd=tailEnd+1
    if tailEnd=MAX_LEN then tailEnd=0

    return

_UpdateFood

    ; new food position
    foodX = (rand&31)
    foodY = (rand&23)
    
    ; last playfield line is not visible
    if foodY = 23 then goto _UpdateFood

    ; check if (foodX, foodY) is free
    if pfread(foodX,foodY) then goto _UpdateFood

    temp5 = foodX*4+17
    player0x = temp5

    temp5 = foodY*4+4
    player0y = temp5

    return

_UpdateEat
    score=score+1

    ; no more grown if MAX_LEN will be reached
    if length+grown = MAX_LEN then goto _SkipGrownIncrement
    
    ; increment ms-snake length
    grown=grown+1

    ; rationale:
    ; new increment will be added to any previous increment
    ; not yet completed 

_SkipGrownIncrement

    eat_sound = 6

    foodX=0 : foodY=0

    return


   rem  ****************************************************************
   rem  ****************************************************************
   rem  *
   rem  *  Game Over Setup
   rem  *
   rem  `
_GameOverSetup

    playfield:
    .XXXXXX.XXXXXX.XXXXXXXXXX.XXXXX.
    .XX.....XX..XX.XX..XX..XX.XX....
    .XX.XXX.XXXXXX.XX..XX..XX.XXXX..
    .XX..XX.XX..XX.XX..XX..XX.XX....
    .XXXXXX.XX..XX.XX..XX..XX.XXXXX.
    ................................
    ...XXXXXX.XX..XX.XXXXX.XXXXXX...
    ...XX..XX.XX..XX.XX....XX..XX...
    ...XX..XX.XX..XX.XXXX..XXXXX....
    ...XX..XX.XX..XX.XX....XX..XX...
    ...XXXXXX...XX...XXXXX.XX..XX...
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
    ................................
end

    player0x = 0
    player0y = 0

    ; debounce the reset switch.
    bits0_DebounceReset{0} = 1
    
    ; activate crash sound
    crash_sound=8

    ; activate shake effect
    shaking_effect = 25

_GameOverLoop

    COLUPF = $6C
    COLUBK = $00

    if crash_sound=0 then goto _SkipSound2
    AUDV0 = 8 : AUDC0 = 3 : AUDF0 = 19
    crash_sound = crash_sound-1
_SkipSound2
    if !crash_sound then AUDV0 = 0

    _Master_Counter = _Master_Counter + 1

    if shaking_effect = 0 then goto _SkipShake
    shakescreen = shakescreen+32
    shaking_effect = shaking_effect-1
_SkipShake

   rem  ````````````````````````````````````````````````````````````````
   rem  `  The master counter resets every 2 seconds.
   rem  `
   if _Master_Counter < 120 then goto _Skip20Counter

   _Master_Counter = 0


   rem  ````````````````````````````````````````````````````````````````
   rem  `  The frame counter increments every 2 seconds.
   rem  `
   _Frame_Counter = _Frame_Counter + 1

   rem  ````````````````````````````````````````````````````````````````
   rem  `  If _Frame_Counter reaches 10 (20 seconds), the program resets
   rem  `  and goes to the title screen.
   rem  `
   if _Frame_Counter = 5 then bits2_GameOverFlag{2} = 0 : goto _GameInit bank1


_Skip20Counter


    drawscreen

    if !switchreset && !joy0fire then bits0_DebounceReset{0} = 0 : goto _SkipGameOverReset

    if bits0_DebounceReset{0} then goto _SkipGameOverReset

    goto _GameInit bank1


_SkipGameOverReset

    goto _GameOverLoop


    bank 4

    asm
    include "titlescreen/asm/titlescreen.asm"
end

    bank 5

    bank 6

    bank 7

    bank 8
