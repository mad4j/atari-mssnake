; The batari Basic score kernel
; This minikernel is not under the same license as the rest of the 
; titlescreen code. Refer to the bB license before you use this in
; a non-bB program.

draw_score_display

 lax score+2
 jsr miniscorepointerset
 sty scorepointers+5
 stx scorepointers+2
 lax score+1
 jsr miniscorepointerset
 sty scorepointers+4
 stx scorepointers+1
 lax score
 jsr miniscorepointerset
 sty scorepointers+3
 stx scorepointers

 lda scorepointers+1
 sta temp1

 lda scorepointers+3
 sta temp3


 sta HMCLR
 tsx
 stx stack1 
 ;ldx #$10
 ldx #$20
 stx HMP0

 ldx #0
 sta WSYNC
 STx GRP0
 STx GRP1 ; seems to be needed because of vdel

 lda scorepointers+5
 sta temp5,x
 lda #>miniscoretable
 sta scorepointers+1
 sta scorepointers+3
 sta scorepointers+5,x
 sta temp2,x
 sta temp4,x
 sta temp6,x


                LDY #7
                STA RESP0
                STA RESP1


        LDA #$03
        STA NUSIZ0
        STA NUSIZ1,x
        STA VDELP0
        STA VDELP1
        ;LDA #$20
        LDA #$30
        STA HMP1
               LDA scorecolor 
                STA HMOVE ; cycle 73 ?
 ifconst score_kernel_fade
	and score_kernel_fade
 endif

                STA COLUP0
                STA COLUP1
 ifconst scorefade
		STA stack2 ; scorefade
 endif
 lda  (scorepointers),y
 sta  GRP0
 lda  (scorepointers+8),y
 sta WSYNC
 sleep 2
 jmp beginscoreloop

 if ((<*)>$d4)
 align 256 ; kludge that potentially wastes space!  should be fixed!
 endif

scoreloop2
 ifconst scorefade
   lda stack2
   sta COLUP0
   sta COLUP1
 else
   sleep 9
 endif
 lda  (scorepointers),y     ;+5  68  204
 sta  GRP0            ;+3  71  213      D1     --      --     --
 lda  (scorepointers+$8),y  ;+5   5   15
 ; cycle 0
beginscoreloop
 sta  GRP1            ;+3   8   24      D1     D1      D2     --
 lda  (scorepointers+$6),y  ;+5  13   39
 sta  GRP0            ;+3  16   48      D3     D1      D2     D2
 lax  (scorepointers+$2),y  ;+5  29   87
 txs
 lax  (scorepointers+$4),y  ;+5  36  108

 ifconst scorefade
 dec stack2
 else
 sleep 5
 endif
 sleep 2

 lda  (scorepointers+$A),y  ;+5  21   63 DIGIT 6
 stx  GRP1            ;+3  44  132      D3     D3      D4     D2!
 tsx
 stx  GRP0            ;+3  47  141      D5     D3!     D4     D4
 sta  GRP1            ;+3  50  150      D5     D5      D6     D4!

 sty  GRP0            ;+3  53  159      D4*    D5!     D6     D6
 dey
 bpl  scoreloop2           ;+2  60  180


 ldx stack1 
 txs
 ldy temp1
 sty scorepointers+1

        LDA #0   
        sta PF1
        STA GRP0
        STA GRP1
        STA VDELP0
        STA VDELP1
        STA NUSIZ0
        STA NUSIZ1

 ldy temp3
 sty scorepointers+3

 ldy temp5
 sty scorepointers+5
 rts

miniscorepointerset
 and #$0F
 asl
 asl
 asl
 adc #<miniscoretable
 tay
 txa
 and #$F0
 lsr
 adc #<miniscoretable
 tax
 rts

