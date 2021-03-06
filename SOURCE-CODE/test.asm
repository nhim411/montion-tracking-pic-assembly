    LIST P=18F4520
#INCLUDE <P18F4520.INC>
    CONFIG OSC=HS
    CONFIG MCLRE = OFF
    
    CBLOCK 0X20
CHUC
DONVI
BIEN1
BIEN2
COUNT1
W_SAVE
STATUS_SAVE
    ENDC
ORG 0X00
GOTO MAIN
;;;;;;;;;;;;CHUONG TRINH NGAT;;;;;;;;;;;;;;;;;
ORG 0X10
    BTFSC INTCON,1
    GOTO NGAT_RB0   ;NGAT INT0
    BTFSC INTCON3,0
    GOTO NGAT_RB1   ;NGAT INT1
    BTFSC INTCON3,1
    GOTO NGAT_RB2   ;NGAT INT2
    RETFIE
;;;;;;;;;;;;CHUONG TRINH CHINH;;;;;;;;;;;;;;;;
ORG 0X50                    ;DIA CHI BAT DAU CHUONG TRINH CHINH
MAIN
    CLRF TRISD	;CAU HINH PORTD LA OUTPUT
    CLRF TRISC	;CAU HINH PORTC LA OUTPUT
    CLRF TRISA	;CAU HINH PORTA LA OUTPUT
    MOVLW 0X07
    MOVWF TRISB	;CAU HINH RB<2:0> LA OUTPUT
    MOVLW 0X0F
    MOVWF ADCON1    ;CAU HINH AN<12:0> LA Digital I/O
    MOVLW 0X07
    MOVWF CMCON	;CAU HINH COMPARATORS LA DIGITAL INPUT
    BSF INTCON,7    ;CHO PHEP DUNG NGAT
    BSF INTCON,4    ;CHO PHEP DUNG NGAT NGOAI INT0
    BSF INTCON3,3   ;CHO PHEP DUNG NGAT NGOAI INT1
    BSF INTCON3,4   ;CHO PHEP DUNG NGAT NGOAI INT2
    BCF INTCON2,7   ;TREO PORT B LEN DUONG
    BCF INTCON2,6   ;NGAT O SUON XUONG
    BSF T0CON,7	;CHO PHEP TIMER0 HOAT DONG
    BCF T0CON,6	;SU DUNG BO DEM 16-BIT
    BCF T0CON,5	;SU DUNG NGUON DAO DONG BEN NGOAI
    BCF T0CON,3	;CHO PHEP GAN TY LE CHIA VO TIMER
    BSF T0CON,2	;CHON GIA TRI Prescale value (TY LE CHIA)LA 1:32
    BCF T0CON,1
    BCF T0CON,0
    CLRF START	;KHOI TAO START LA 0X00
    SETF ENABLE	;KHOI TAO ENABLE LA 0XFF
    CLRF CHUC	;KHOI TAO CHUC LA 0X00
    CLRF DONVI	;KHOI TAO DONVI LA 0X00
    CLRF ENABLE1    ;KHOI TAO ENABLE1 LA 0X00
    
NAM1
    CLRF     CHUC
NAM2
    CLRF     DONVI
NAM3
    MOVLW 0XFF
    CPFSEQ START
    CALL     OFF
    CPFSEQ START
    
    CALL     MALED               ;CALL MALED PROGRAM
    CALL     QUETLED             ;CALL QUETLED PROGRAM
    CALL     TANGDONVI           ;CALL TANGDONVI PROGRAM
    CALL    SANGDEN
    
    GOTO     NAM3
    CALL     MALED               ;CALL MALED PROGRAM
    CALL     QUETLED             ;CALL QUETLED PROGRAM
    CALL     SANGDEN           
    MOVF     DONVI,0
    XORLW    D'20'               ;SO SANH DON VI VOI 10
    BTFSS    STATUS,Z
    GOTO     NAM3
    INCF     CHUC
    INCF     CHUC
    MOVF     CHUC,0
    XORLW    D'20'
    BTFSS    STATUS,Z
    GOTO     NAM2
    GOTO     NAM1
    
;;;;;;;;;;;;CHO CT NGAT;;;;;;;;;;;;;;;;
    HERE
    GOTO HERE
    ORG 0X200
    
    OFF	;CHUONG TRINH SE CHAY NEU MOI BAT DAU CHUA BAM NUT START
MOVLW    0X00
MOVWF    PORTC
BCF      PORTD,0
BCF      PORTD,1
BCF      PORTD,2
RETURN
    
MALED                      ;CHUONG TRINH GAN MA LED 7 DOAN CHO THANH GHI DONVI7 VA CHUC7
MOVF     DONVI,0
CALL     BANGMA
MOVWF    BIEN1
MOVF     CHUC,0
CALL     BANGMA
MOVWF    BIEN2
RETURN

BANGMA                     ;CHUONG TRINH MA LED 7 DOAN ANOT CHUNG
ADDWF    PCL,1             ;PCL LA CON TRO DIA CHI CHUONG TRINH
RETLW    0xC0
RETLW    0xF9
RETLW    0xA4
RETLW    0xB0
RETLW    0x99
RETLW    0x92
RETLW    0x82
RETLW    0xF8
RETLW    0x80
RETLW    0x90

QUETLED                    ;CHUONG TRINH HIEN THI LED 7 DOAN
MOVLW    0X01
MOVWF    PORTA
MOVF     BIEN2,0          ;DISPLAY DONVI7 ON PORTD (7 SEG LED)
MOVWF    PORTC
CALL     DELAY
MOVLW    0X02
MOVWF    PORTA
MOVF     BIEN2,0           ;DISPLAY CHUC7 ON PORTD (7 SEG LED)
MOVWF    PORTC
CALL     DELAY
RETURN

DELAY                      ;DELAY 1ms
NOP
DELAY1
DECFSZ   COUNT1,1
GOTO     DELAY1
DECFSZ   COUNT2,1
GOTO     DELAY1
RETURN

CAP_NHAT    ;TANG CHUC,DONVI DE HIEN THI SO DEM TIEP THEO
    INCF DONVI
    INCF DONVI
    MOVF DONVI,0
    XORLW D'20'
    BTFSS STATUS,Z
    GOTO THOAT
    CLRF DONVI
    INCF CHUC
    INCF CHUC
    MOVF CHUC,0
    XORLW D'20'
    BTFSS STATUS,Z
    RETURN
    
SANGDEN	;SANG DEN CANH BAO
    BCF STATUS,C
    MOVLW D'2'
    SUBWF CHUC,0
    BTFSS STATUS,C
    GOTO SANG0	;0<CHUC<10
    BCF STATUS,C
    MOVLW D'4'
    SUBWF CHUC,0 
    BTFSS STATUS,C
    GOTO SANG1	;10<CHUC<20
    BCF STATUS,C
    MOVLW D'6'	
    SUBWF CHUC,0
    BTFSS STATUS,C
    GOTO SANG2	;30<CHUC<40
    BCF STATUS,C
    MOVLW D'8'
    SUBWF CHUC,0
    BTFSS STATUS,C
    GOTO SANG3	;40<CHUC<99
    RETURN

SANG0
    BCF PORTD,0
    BCF PORTD,1
    BCF PORTD,2
    RETURN

SANG1
    BSF PORTD,0
    BCF PORTD,1
    BCF PORTD,2
    RETURN

SANG2
    BCF PORTD,0
    BSF PORTD,1
    BCF PORTD,2
    RETURN

SANG3
    BCF PORTD,0
    BCF PORTD,1
    BSF PORTD,2
    RETURN