;---------------------B2D.INC-------------------------
;=====================================================
;"W"yazmacýndaki 0..255 arasý ikili düzendeki sayýnýn, 
;yüzler,onlar ve birler basamaklarýndaki rakamlarýný 
;ayýrmada kullanýlan rutin.Bu rutin çaðýrýlmadan önce 
;basamaklarýna ayýrýlacak sayý "W" yazmacýna yüklenmiþ 
;olmalýdýr.
;=====================================================


;-----------------------------------------------------
b2d
	movwf	SAYI		
	clrf	YUZLER
	clrf	ONLAR
	clrf	BIRLER
	
YuzB
	movlw	.100
	subwf	SAYI,W   	
	btfsc	STATUS,C   	
	goto	YuzlerBasamagi
	
OnB
	movlw	.10
	subwf	SAYI,W
	btfsc	STATUS,C
	goto	OnlarBasamagi

	movf	SAYI,W
	movwf	BIRLER

	return
;-----------------------------------------------------
YuzlerBasamagi	
	incf	YUZLER,1	
	movwf	SAYI
	goto	YuzB
;-----------------------------------------------------
OnlarBasamagi	
	incf	ONLAR,1		
	movwf	SAYI
	goto	OnB
;=====================================================
