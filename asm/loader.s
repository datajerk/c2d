;loader.s
;
; moves itself to another page memory,
; then reads binary from disk using params at end,
; then jumps to binary
;

; apple params/vectors

warm	=	$FF69		; back to monitor
bell	=	$FBDD		; ding
preg	=	$48		; mon p reg

; dos params/vectors

rwtsprm	=	$B7E8		; looked at dos 3.3 disk, not using $3E3 to find
rwts	=	$B7B5		; rwts jsr

; vars

stage1	=	$800
;stage2	=	$B600		; overwrite track 0/sector 0, not needed any more?
stage2	=	$300		; $300 looks open
;;;run time
trkcnt	=	$00		; track counter
segcnt	=	$01		; loop var
buffer	=	$02		; MSB of RWTS buffer
secnum	=	$03		; loop var
trknum	=	$04		; loop var


start:
        .org	stage1

grcheck:
	lda	*+(gr-loader)+(moved-grcheck)
	beq	init
	lda	#0		; GR mode
	sta	$C050
	sta	$C053
init:
	lda	#1		; read(1)/write(2) command
	ldy	#$0C		; offset in RWTS
	sta	rwtsprm,y	; write it to RWTS

	lda	#0		; buffer LSB
	ldy	#8		; offset in RWTS
	sta	rwtsprm,y	; write it to RWTS

	lda	#2
	sta	trknum		; start with track 2

	ldx	#0		; move code to stage2
move:
	lda	moved,x
	sta	loader,x
	inx
	;bne	move		; move 256 bytes
	bpl	move		; move 128 bytes
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
