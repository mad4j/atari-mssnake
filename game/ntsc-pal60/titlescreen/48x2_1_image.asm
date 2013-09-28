
 ;*** The height of the displayed data...
bmp_48x2_1_window = 9

 ;*** The height of the bitmap data. This can be larger than 
 ;*** the displayed data height, if you're scrolling or animating 
 ;*** the data...
bmp_48x2_1_height = 9

   if >. != >[.+(bmp_48x2_1_height)]
      align 256
   endif
 BYTE 0 ; leave this here!


 ;*** The color of each line in the bitmap, in reverse ordar...
bmp_48x2_1_colors 
	BYTE $94
	BYTE $96
	BYTE $98
	BYTE $9A
	BYTE $9C
	BYTE $9D
	BYTE $9E
	BYTE $9C
	BYTE $9A
	BYTE $98

 ifnconst bmp_48x2_1_PF1
bmp_48x2_1_PF1
 endif
        BYTE %00000000
 ifnconst bmp_48x2_1_PF2
bmp_48x2_1_PF2
 endif
        BYTE %00000000
 ifnconst bmp_48x2_1_background
bmp_48x2_1_background
 endif
        BYTE $00

   if >. != >[.+bmp_48x2_1_height]
      align 256
   endif


bmp_48x2_1_00
	BYTE %00000000
	BYTE %00001100
	BYTE %00001100
	BYTE %00001100
	BYTE %00001101
	BYTE %00001110
	BYTE %00001110
	BYTE %00001100
	BYTE %00000000
	BYTE %00001110

   if >. != >[.+(bmp_48x2_1_height)]
      align 256
   endif

bmp_48x2_1_01
	BYTE %00000000
	BYTE %01101110
	BYTE %01100010
	BYTE %01100100
	BYTE %01101000
	BYTE %11101110
	BYTE %11100000
	BYTE %01100000
	BYTE %00000000
	BYTE %11101110

   if >. != >[.+(bmp_48x2_1_height)]
      align 256
   endif

bmp_48x2_1_02
	BYTE %00000000
	BYTE %00111101
	BYTE %00000101
	BYTE %00000101
	BYTE %00011001
	BYTE %00100001
	BYTE %00100000
	BYTE %00111100
	BYTE %00000000
	BYTE %00100001

   if >. != >[.+(bmp_48x2_1_height)]
      align 256
   endif

bmp_48x2_1_03
	BYTE %00000000
	BYTE %00101001
	BYTE %00101111
	BYTE %00101001
	BYTE %01101001
	BYTE %10100110
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %10100110

   if >. != >[.+(bmp_48x2_1_height)]
      align 256
   endif

bmp_48x2_1_04
	BYTE %00000000
	BYTE %01010111
	BYTE %01010100
	BYTE %01100110
	BYTE %01010100
	BYTE %01010111
	BYTE %01000000
	BYTE %00000000
	BYTE %00000000
	BYTE %01010111

   if >. != >[.+(bmp_48x2_1_height)]
      align 256
   endif

bmp_48x2_1_05
	BYTE %00000000
	BYTE %00100000
	BYTE %00100000
	BYTE %00000000
	BYTE %00100000
	BYTE %00100000
	BYTE %00100000
	BYTE %00100000
	BYTE %00000000
	BYTE %00100000

