#include <p18f4520.h>

//this program uses a HSC12 proto-board to control an external circuit

// Configuration bits settings:

#pragma	config	OSC	= HS								// Oscillator selection,HS Oscillator
#pragma	config	FCMEN	= OFF							// Fail Safe clock monitor
#pragma	config	IESO	= OFF							// Internal/External Osc. Monitor
#pragma	config	PWRT  	= ON							// Power up Timer
#pragma	config	BOREN	= OFF							// Brown out Reset disabled
#pragma config  WDT		= OFF							//
//#pragma 	CONFIG	WDT		= ON, WDTPS = 128			// Watch dog postscaler
#pragma	config	MCLRE	= ON							// MCLR Enable
#pragma	config	STVREN	= ON							// Stack Overflow on
#pragma	config	LVP		= OFF							// Low voltage ICSP
#pragma	config	DEBUG	= OFF							// Back Ground Debugger Disable
#pragma	config	CP0		= OFF							// Code protection Block 0
#pragma	config	CP1		= OFF							// Code Protection Block 1
#pragma	config	CP2		= OFF							// Code Protection Block 2
#pragma	config	CPB		= OFF							// Boot Block code protection
#pragma	config	CPD		= OFF							// Data EEPROM Code Protection
#pragma	config	WRT0	= OFF							// Write Protection Block 0
#pragma	config	WRT1	= OFF							// Write Protection Block 1
#pragma	config	WRT2	= OFF							// Write Protection Block 2
#pragma	config	WRTB	= OFF							// Boot Block Write Protection
#pragma	config	WRTC	= OFF							// Configuration Register Write Protection
#pragma	config	WRTD	= OFF							// Data EEPROM Write Protection
#pragma	config	EBTR0	= OFF							// Table Read Protection Block 0
#pragma	config	EBTR1	= OFF							// Table Read Protection Block1
#pragma	config	EBTR2	= OFF							// Table Read Protection Block2
#pragma	config	EBTRB	= OFF							// Boot Block Table Read Protection


void PicInit(void);
void delay(void);
void DataTx(void);
void high_isr(void);
void low_isr(void);

#pragma udata INT_RAM
char ichar;
char RxFlag;
unsigned int count1=0;
unsigned int count2 = 0;
int i=0;
int var=0x01;
int portVal=0x00;
int counter=0;
#pragma udata

//********************************************************
void main(void)
{

  PicInit();				//To initialize all the Peripherals(Ports,Timers,ADC,UART etc.,)

  INTCONbits.GIEH = 1;		//Enabling High Priority Interrupts
  INTCONbits.GIEL = 1;		//Enabling Low Priority Interrupts
  
  //PIE1bits.RCIE = 1;
  
  T0CONbits.TMR0ON=1;  

  RxFlag = 0;
  ichar = 0x55;

  /* Light up the LEDs */
  PORTB = 0x00;				// Initially, all the LEDs(connected to PORB) are off.
  PORTD = 0x00;
  PORTC = 0x00;

  while(1)
  {
	if (RxFlag != 1)
	{
		PORTB = 0xFF;
		PORTD = 0xFF;
		//PORTC = 0xFF;
		portVal = 0xFF;
		var = 0x01;
		delay();
		
		//clockwise LEDs on (PORTB)
		for(i=0; i<=7; i++)
		{
			PORTB = PORTB - var;
			var = var * 2;
			delay();
		}
	
		//clockwise LEDs on (PORTD)	
		for(i=0; i<=7; i++)
		{
			portVal = portVal / 2;
			PORTD = portVal;
			delay();
		}
		
		PORTB = 0xFF;
		PORTD = 0xFF;
		portVal = 0xFF;
		var = 0x01;
		delay();
	
		//counter-clockwise LEDs off (PORTD)
		for(i=0; i<=7; i++)
		{
			portVal = portVal - var;
			PORTD = portVal;
			var = var * 2;
			delay();
		}
	
		//counter-clockwise LEDs off (PORTB)
		for(i=0; i<=7; i++)
		{
			PORTB = PORTB / 2;
			delay();
		}
	}
	else
	{
		PORTB = ichar;
		PORTD = ichar;

		if (PORTAbits.RA0)
	 	{
			RxFlag = 0;
		}
	}
  }
}
//**********************************************************
//Following are the Interrupt Service Routine(ISR)

//High Priority ISR

#pragma code high_vector = 0x08
void Interrupt_at_high_vector(void)
{
 _asm 
 goto high_isr
 _endasm
}

//**********************************************************
#pragma code

#pragma interrupt high_isr save=PROD,section(".tmpdata")

void  high_isr(void)
{
	if(PIE1bits.RCIE && PIR1bits.RCIF)
	{
		//RxFlag = 1;
		if(RCSTAbits.OERR)//Overrun error
		{
			RCSTAbits.CREN = 0;
			RCSTAbits.CREN = 1;
		}
		else if(RCSTAbits.FERR)//framming Error
		{
			ichar = RCREG;
		}
		else
		{
			ichar = RCREG;
			RxFlag = 1;
		}
		PIR1bits.RCIF = 0; //clear the flag
	}
	
	else if(INTCONbits.TMR0IE && INTCONbits.TMR0IF) //check if overflow is from TMR0 ISR
	{
		counter++;	//increment overflow counter
		
		if((counter % 15) == 0)	// every 15 interrupts is equal to approx. 1s with 1MHz clock and 256 prescale
		{
			PORTCbits.RC0 ^= 1;	//switch LED state every 1 second

			if(counter == 45)	//45 interrupts is equal to approx. 3s with 1MHz clock and 256 prescale
			{
				PORTCbits.RC1 ^= 1; //switch buzzer state every 3 seconds
				counter = 0;	//reset counter after one cycle
			}
		}
		
		INTCONbits.TMR0IF = 0; //clear flag
	}
}

//***********************************************************
//Low Priority ISR

#pragma code low_vector = 0x18
void interrupt_at_low_vector(void)
{
 _asm
 goto low_isr
 _endasm
}
//***********************************************************

#pragma code

#pragma interruptlow low_isr save=PROD,section(".tmpdata")

void low_isr(void)
{
  


}
/////////////////////////////////////////////////////////////
void DataTx(void)
{
 TXREG = ichar;
 while(TXSTAbits.TRMT);

 return;
} 
////////////////////////////////////////////////////////////////////////////
void delay(void)
{
  unsigned int m,n,q;
  count1 = count2 = 64;

  for(m = 0; m <= count1; m++)
  {
     for(n = 0; n <= count2; n++)
     {
        q= 5;
     }
	 if (PORTAbits.RA0)
	 {
		//ichar = 0x55;
		DataTx();
	 }
  }
 return;
}
  
///////////////////////////////////////////////////////////////////////////
void PicInit(void)
{
//Initialize the PIC as per the hardware design.Some of these might...
//be changed by the C18 Compiler library routines called later.

//Oscillator Configurations......................................................
 OSCCON = 0b00000000;

//Interrupts.....................................................................
//Following are the Registers along with the control bits related to Interrupt Mechanism.
//For almost all peripherals, there is a interrupt mechanism. For each interrupt, three(3) bits
//need to be taken care. They are, 1) Interrupt Enable Bit(IE), 2) Interrupt Priority Bit(IP) and 
// 3) Interrupt Flag Bit(IF).
 
RCONbits.IPEN = 1; // Enable interrupt priorities.

INTCONbits.GIEH = 1;
INTCONbits.GIEL = 1;
INTCONbits.TMR0IE = 1;
INTCONbits.INT0IE = 0;
INTCONbits.RBIE = 0;
INTCONbits.TMR0IF = 0;
INTCONbits.INT0IF = 0;
INTCONbits.RBIF = 0;

INTCON2bits.RBPU = 0;
INTCON2bits.INTEDG0 = 0;
INTCON2bits.INTEDG1 = 0;
INTCON2bits.INTEDG2 = 0;
INTCON2bits.TMR0IP = 1;//TMR0 low priority, all others high
INTCON2bits.RBIP = 0;

INTCON3bits.INT2IP = 0;
INTCON3bits.INT1IP = 0;
INTCON3bits.INT2IE = 0;
INTCON3bits.INT1IE = 0;
INTCON3bits.INT2IF = 0;
INTCON3bits.INT1IF = 0;

PIR1bits.PSPIF = 0;
PIR1bits.ADIF = 0;
PIR1bits.RCIF = 0;
PIR1bits.TXIF = 0;
PIR1bits.SSPIF = 0;
PIR1bits.CCP1IF = 0;
PIR1bits.TMR2IF = 0;
PIR1bits.TMR1IF = 0;

PIR2bits.CMIF = 0;
PIR2bits.EEIF = 0;
PIR2bits.BCLIF = 0;
PIR2bits.LVDIF = 0;
PIR2bits.CCP2IF = 0;


PIE1bits.PSPIE = 0;
PIE1bits.ADIE = 0;
PIE1bits.RCIE = 1;	
PIE1bits.TXIE = 0;
PIE1bits.SSPIE = 0;
PIE1bits.CCP1IE = 0;
PIE1bits.TMR2IE = 0;
PIE1bits.TMR1IE = 0;

PIE2bits.CMIE = 0;
PIE2bits.EEIE = 0;
PIE2bits.BCLIE = 0;
PIE2bits.LVDIE = 0;
PIE2bits.TMR3IE = 0;
PIE2bits.CCP2IE = 0;


IPR1bits.PSPIP = 1;
IPR1bits.ADIP = 0;
IPR1bits.RCIP = 1;	
IPR1bits.TXIP = 0;
IPR1bits.SSPIP = 0;
IPR1bits.CCP1IP = 0;
IPR1bits.TMR2IP = 0;
IPR1bits.TMR1IP = 0;

IPR2bits.CMIP = 0;
IPR2bits.EEIP = 0;
IPR2bits.BCLIP = 0;
IPR2bits.LVDIP = 0;
IPR2bits.TMR3IP = 0;
IPR2bits.CCP2IP = 0;


//I/O Ports
//Following are the Registers along with the control bits related to I/O PORTs.
//For each PORT(A,B,C,D & E), there are 2 Registers. 1) TRIS(Data direction) and 2) PORT register.
//Through TRIS, We determine the direction(either input(1) or output(0)). And we write to the PORT or Read
//from the PORT. 

TRISA = 0b01111111;  
PORTA = 0b00000000; 
TRISA = 0b00000011; 	//RA0, RA1 as inputs, the rest as outputs


TRISB = 0b11111111;
PORTB = 0b00000000;
TRISB = 0b00000000;		//All the pins in PORTB has configured as outputs.


TRISC = 0b11111111; 
PORTC = 0b00000000; 
TRISC = 0b11111100; 	//RC7(Rx) AND RC6(Tx)		

TRISD = 0b11111111; 
PORTD = 0b00000000; 
TRISD = 0b00000000; 

TRISE = 0b11111111; 
PORTE = 0b00000000; 
TRISE = 0b11111111; 

 
//USART Configurations
//Following are the Registers related to USART

 TXSTA   = 0x26;
 RCSTA   = 0x90;
 BAUDCON = 0x00;
 SPBRG   = 0x19;

//USART Error flags

 RCSTAbits.CREN = 0;
 RCSTAbits.CREN = 1;
 RCSTAbits.FERR = 0;
 RCSTAbits.OERR = 0;

//TIMER0 Module(8BIT,INT,1:128)....................................

T0CON = 0b11000111; // 0x56
TMR0L = 0b00000000; // 0x00
TMR0H = 0b00000000; // 0x00
T0CONbits.TMR0ON = 1;

//TIMER1 Module ..................................................

T1CON = 0b00000000; // 0x00
TMR1L = 0b00000000; // 0x00
TMR1H = 0b00000000; // 0x00
T1CONbits.TMR1ON = 0;

//TIMER2 Module ..................................................

T2CON = 0b00000000; // 0x00
TMR2 = 0b00000000; // 0x00
PR2 = 0b11111111; // 0xFF
T2CONbits.TMR2ON = 0;

//TIMER3 Module ..................................................

T3CON = 0b00000000; // 0x00
TMR3L = 0b00000000; // 0x00
TMR3H = 0b00000000; // 0x00
T3CONbits.TMR3ON = 0;

//Capture/Compare/PWM (CCP) modules ..............................
// These will be initialized by the appropriate C18 library functions.

CCPR1L = 0b00000000; // 0x00
CCPR1H = 0b00000000; // 0x00
CCP1CON = 0b00000000; // 0x00

CCPR2L = 0b00000000; // 0x00
CCPR2H = 0b00000000; // 0x00
CCP2CON = 0b00000000; // 0x00

// Data sheet Chapter 17. Master Synchronous Serial Port (MSSP) Module ...................
// Configure for I2C operation.
SSPCON1 = 0b00101000; // 0x28
SSPADD  = 0b00110110; // 0x36 = 54
SSPSTAT = 0b10000000; // 0x80
SSPCON2 = 0b00000000; // 0x00

// Data sheet Chapter 19. 10-bit Analog-To-Digital (A/D) module ..........................
// ADC is not used. Pins will be standard digital inputs (or outputs).

ADCON0 = 0b00000000; // 0x00
ADCON1 = 0b00001111; // 0x0F
ADCON2 = 0b00000000; // 0x00

//Comparator module ..............................................
// Comparators are not used. Pins will be standard digital inputs (or outputs).

CMCON = 0b00000111; // 0x07

//Comparator Voltage Reference ...................................
// Comparators are not used. Pins will be standard digital inputs (or outputs).

CVRCON = 0b00000000; // 0x00

//Low-Voltage Detect .............................................
LVDCON = 0b00000000; // 0x00


WDTCON = 0b00000000; // 0x00
}