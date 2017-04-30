;bar.s
;
; moves itself to another page memory,
; then reads binary from disk using params at end,
; then jumps to binary
;

; apple params/vectors

warm	=	$FF69		; back to monitor
bell	=	$FBDD		; ding
preg	=	$48		; mon p reg
ch	=	$24		; cursor horizontal
movecur	=	$FB5B		; move cursor to ch,a
cout	=	$FDED		; character out sub

; dos params/vectors

rwtsprm	=	$B7E8		; looked at dos 3.3 disk, not using $3E3 to find
rwts	=	$B7B5		; rwts jsr

; vars

stage1	=	$800
stage2	=	$300		; $300 looks open
invsp	=	$20		; inverse space for draw
trkcnt	=	$00		; track counter
segcnt	=	$01		; loop var
buffer	=	$02		; MSB of RWTS buffer
secnum	=	$03		; loop var
trknum	=	$04		; loop var
barcnt	=	$05		; bar counter
barptr	=	$06		; bar pointer


        .org	stage1

grcheck:
	lda	*+(gr-loader)+(moved-grcheck)
	beq	text
	lda	#0		; GR mode
	sta	$C050
	sta	$C053
text:

init:
	lda	#0		; reset pointer and counter
	sta	barcnt
	sta	barptr

	lda	#1		; read(1)/write(2) command
	ldy	#$0C		; offset in RWTS
	sta	rwtsprm,y	; write it to RWTS

	lda	#0		; buffer LSB
	ldy	#8		; offset in RWTS
	sta	rwtsprm,y	; write it to RWTS

	lda	#2
	sta	trknum		; start with track 2

start:
	ldx	#0		; move code to stage2
move:
	lda	moved,x
	sta	loader,x
	inx
	cpx	#$D0
	bne	move		; move 208 bytes
	jmp	loader

moved:
	.org	stage2

loader:
	lda	loadpage	; where to dump the tracks
	sta	buffer

	ldx	lasttrack
	dex			; because data starts at track 2
	dex
	stx	trkcnt		; number of complete and partial tracks

;;;begin track loop
trkloop:
	lda	trknum		; track number
	ldy	#4		; offset in RWTS
	sta	rwtsprm,y	; write it to RWTS

;;;begin sector loop (16), backwards is faster, much faster
	lda	trkcnt		; check if last track
	bne	fulltrack	; if not then full track
	lda	lastsector	; if so, get last sector number
	bpl	subtrack
fulltrack:
	lda	#$F
subtrack:
	sta	secnum
secloop:
	lda	secnum		; sector number
	ldy	#5		; offset in RWTS
	sta	rwtsprm,y	; write it to RWTS

	lda	buffer		; buffer MSB
	clc
	adc	secnum		; compute page load address
	ldy	#9		; offset in RWTS
	sta	rwtsprm,y	; write it to RWTS

	ldy	#<rwtsprm	; load rwts paramlist B7E8
	lda	#>rwtsprm
	jsr	rwts		; do it!
	bcs	diskerror
	lda	#0
	sta	preg		; fix p reg so mon is happy

;;;draw code
	inc	barcnt		; sectors read
	ldx	barptr		; get current pointer value
	lda	bar,x
	cmp	barcnt		; is bar,x = barcnt?
	bne	nodraw		; if bar,x = barcnt draw bar
	lda	barptr		; get position
	;clc
	;adc	#5		; indent

	; new version, no rom calls, just poke to screen
	clc			; clear carry
	adc	rowlsb		; add the text page row lsb
	sta	screen+1	; store that in self mod code
	lda	rowmsb		; get text page row msb
	sta	screen+2	; store that in self mod code
	lda	#invsp		; load block char
screen:
	sta	$400		; write out char

	; old version, rom calls, cout will scroll windows on 40x24
	;sta	ch
	;lda	row		; row 19
	;jsr	movecur
	;lda	#invsp
	;jsr	cout

	inc	barptr		; move pointer to next bar position
nodraw:
;;;end draw code

	dec	secnum
	bpl	secloop
;;;end sector loop

	lda	buffer		; buffer += $10
	clc
	adc	#$10
	sta	buffer

	inc	trknum		; next track
	dec	trkcnt		;
	bpl	trkloop		; 0, all done with tracks
;;;end track loop

done:
	jmp	(nextjump)	; down with load, run it

diskerror:
	jmp	warm

lasttrack:
	.org	*+1
lastsector:
	.org	*+1
loadpage:
	.org	*+1
nextjump:
	.org	*+2
gr:
	.org	*+1
row:
	.org	*+1
rowlsb:
	.org	*+1
rowmsb:
	.org	*+1
bar:
	.org	*+40
end:
