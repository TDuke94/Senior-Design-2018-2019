/*
 * I2C functionality on the MSP430 device v0.0
 *
 * Overview Structure:
 *  Initialization
 *      S-BIT
 *      I2C Internal Initialization
 *      FZYNC Clock Initialization
 *      Establish I2C Slaves
 *      Establish Comm with Zynq
 *
 *  Interrupt - Common
 *      Poll I2C Slaves
 *      Write to Zynq
 *
 *  Interrupt - FSYNC
 *      5 Hz
 *      Pull GPIO Pin Up, wait shortly, pull GPIO Down
 */

#include <msp430.h>

#include "driverlib.h"

// function prototypes
void ClockInit(void);
void PinInit(void);
void I2CTXInit(void);
void I2CRXInit(void);
void SBIT(void);
void IMUStartupPoll(void);
void ZynqStartupPoll(void);

volatile unsigned char TXData;

/*
 * Constants:
 *      IMU Address: 110100x (define x as 0, tied to ground)
 *      I2C Switches
 *      SlaveCounter
 *      Slave Number
 */
uint_8t IMU_ADDRESS = 0x68; // maybe make this #define
uint_8t I2C_Switch_Address[] = {0x00};
uint_8t TXByteCtr;
uint_8t txData[] {0x00}
uint_8t SlaveCount = 0;
uint_8t SwitchCount = 0;
uint_8t ModeFlag = 0;

#define RX_MODE_FLAG 0
#define TX_MODE_FLAG 1
#define SLAVE_NUMBER 10
#define CS_SMCLK_DESIRED_FREQUENCY_IN_KHZ   1000
#define CS_SMCLK_FLLREF_RATIO   30

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	// Initialize Clock
	ClockInit();

	// Initialize I/O Pins
	PinInit();

	// Initialize I2C as receiver
	I2CRXInit();

	// perform SBIT
	SBIT();

	// Verify IMU Comm
	IMU_Startup_Poll();

	// failure moding
	if( 1 != 1 )
	{
	    // nothing for now
	}

	// Initialized Zynq Comm - This is a spin wait
	Zynq_Startup_Poll();
}

/*
 * Clock Startup
 *
 * This contains all of the core functionality for clock startup
 *
 * Code is used from the TI example for initialization of euxci b as master of several slaves
 */
void ClockInit(void)
{
    //Set Ratio and Desired MCLK Frequency  and initialize DCO
    CS_initFLLSettle(
            CS_SMCLK_DESIRED_FREQUENCY_IN_KHZ,
            CS_SMCLK_FLLREF_RATIO
            );

    //Set SMCLK = DCO with frequency divider of 1
    CS_initClockSignal(
            CS_SMCLK,
            CS_DCOCLKDIV_SELECT,
            CS_CLOCK_DIVIDER_1
            );

    //Set MCLK = DCO with frequency divider of 1
    CS_initClockSignal(
            CS_MCLK,
            CS_DCOCLKDIV_SELECT,
            CS_CLOCK_DIVIDER_1
            );
}

/*
 * Pin Initialize
 *
 * Set Up required Pins for inputs/outputs etc.
 */
void PinInit(void)
{
    // I2C Pins
    GPIO_setAsPeripheralModuleFunctionInputPin(
            GPIO_PORT_P4,
            GPIO_PIN1 + GPIO_PIN2,
            GPIO_PRIMARY_MODULE_FUNCTION
            );

    // FSYNC Pins
    GPIO_setAsPeripheralModuleFunctionOutputPin(
            GPIO_PORT_P6,
            GPIO_PIN0,
            GPIO_PRIMARY_MODULE_FUNCTION
            );

    // line stolen from euxci_b_I2C example 1 not entirely sure of function
    // is called in ISR for some reason, not sure entirely of it's role in overall functionality
    GPIO_setAsOutputPin(
        GPIO_PORT_P1,
        GPIO_PIN0
    );

    //
    PMM_unlockLPM5();
}

/*
 * I2C Transmit Initialization Function
 *
 * Code is used from the TI example for initialization of euxci b as master of several slaves
 *
 */
void I2CTXInit(void)
{
    EUSCI_B_I2C_initMasterParam param = {0};
    param.selectClockSource = EUSCI_B_I2C_CLOCKSOURCE_SMCLK;
    param.i2cClk = CS_getSMCLK();
    param.dataRate = EUSCI_B_I2C_SET_DATA_RATE_400KBPS;
    param.byteCounterThreshold = 0;
    param.autoSTOPGeneration = EUSCI_B_I2C_NO_AUTO_STOP;
    EUSCI_B_I2C_initMaster(EUSCI_B0_BASE, &param);

    //Set Master in receive mode
    EUSCI_B_I2C_setMode(EUSCI_B0_BASE,
                    EUSCI_B_I2C_TRANSMIT_MODE
                    );

    //Enable I2C Module to start operations
    EUSCI_B_I2C_enable(EUSCI_B0_BASE);

    EUSCI_B_I2C_clearInterrupt(EUSCI_B0_BASE,
                EUSCI_B_I2C_TRANSMIT_INTERRUPT0 +
                EUSCI_B_I2C_NAK_INTERRUPT
                );

    //Enable master Receive interrupt
    EUSCI_B_I2C_enableInterrupt(EUSCI_B0_BASE,
                    EUSCI_B_I2C_TRANSMIT_INTERRUPT0 +
                    EUSCI_B_I2C_NAK_INTERRUPT
                  );

    // set the flag to TX to ensure mode set correctly
    ModeFlag = TX_MODE_FLAG;
}

/*
 * I2C Recieve Initialization
 *
 * Code is substantively used from example
 */
void I2CRXInit(void)
{
    EUSCI_B_I2C_initMasterParam param = {0};
    param.selectClockSource = EUSCI_B_I2C_CLOCKSOURCE_SMCLK;
    param.i2cClk = CS_getSMCLK();
    param.dataRate = EUSCI_B_I2C_SET_DATA_RATE_400KBPS;
    param.byteCounterThreshold = 1;
    param.autoSTOPGeneration = EUSCI_B_I2C_SEND_STOP_AUTOMATICALLY_ON_BYTECOUNT_THRESHOLD;
    EUSCI_B_I2C_initMaster(EUSCI_B0_BASE, &param);

    //Specify slave address
    EUSCI_B_I2C_setSlaveAddress(EUSCI_B0_BASE,
        SLAVE_ADDRESS
        );

    //Set Master in receive mode
    EUSCI_B_I2C_setMode(EUSCI_B0_BASE,
        EUSCI_B_I2C_RECEIVE_MODE
        );

    //Enable I2C Module to start operations
    EUSCI_B_I2C_enable(EUSCI_B0_BASE);

    EUSCI_B_I2C_clearInterrupt(EUSCI_B0_BASE,
        EUSCI_B_I2C_RECEIVE_INTERRUPT0 +
        EUSCI_B_I2C_BYTE_COUNTER_INTERRUPT +
        EUSCI_B_I2C_NAK_INTERRUPT
        );

    //Enable master Receive interrupt
    EUSCI_B_I2C_enableInterrupt(EUSCI_B0_BASE,
        EUSCI_B_I2C_RECEIVE_INTERRUPT0 +
        EUSCI_B_I2C_BYTE_COUNTER_INTERRUPT +
        EUSCI_B_I2C_NAK_INTERRUPT
        );

    // set the flat to ensure mode set correctly
    ModeFlag = RX_MODE_FLAG;
}

/*
 * Startup Built-In-Test
 *
 * This test verifies functionality of the MSP430 device upon startup
 */
void SBIT(void)
{
    // Tests Go Here
}

/*
 * IMU Startup Poll
 *
 * Verify the IMUs expected are present and ready for communication
 */
void IMUStartupPoll(void)
{
    // verify initialized to 0
    SlaveCount = 0;
    SwitchCount = 0;

    while (1)
    {
        // Select Switch
        EUSCI_B_I2C_setSlaveAddress(EUSCI_B0_BASE,
                        I2C_Switch_Address[SwitchCount]
                        );



        while ( EUSCI_B_I2C_SENDING_STOP == EUSCI_B_I2C_masterIsStopSent(EUSCI_B0_BASE) )
        {
            ;// do nothing
        }

        if(SlaveCount >= SLAVE_NUMBER)
        {
            // We have spoken to all of the IMUs
            break;
        }
    }
}

/*
 * Establish initial comm with Zynq
 *
 * Spin Wait Until Successful Comm Established
 */
void ZynqStartupPoll(void)
{
    //
}

/*
 * ISR provided in TI example
 *
 * I2C ISR used for data transmisison
 */

#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=USCI_B0_VECTOR
__interrupt
#elif defined(__GNUC__)
__attribute__((interrupt(USCI_B0_VECTOR)))
#endif
void USCIB0_ISR(void)
{
    switch(__even_in_range(UCB0IV, USCI_I2C_UCBIT9IFG))
    {
        case USCI_NONE:             // No interrupts break;
            break;
        case USCI_I2C_UCALIFG:      // Arbitration lost
            break;
        case USCI_I2C_UCNACKIFG:    // NAK received (master only)
            // Resend START if NAK'd
            if (ModeFlag == TX_MODE_FLAG) // NAK was for send
                EUSCI_B_I2C_masterSendStart(EUSCI_B0_BASE);
            else // NAK was for receive
                EUSCI_B_I2C_masterReceiveStart(EUSCI_B0_BASE);
            break;
        case USCI_I2C_UCSTTIFG:     // START condition detected with own address (slave mode only)
            break;
        case USCI_I2C_UCSTPIFG:     // STOP condition detected (master & slave mode)
            break;
        case USCI_I2C_UCRXIFG3:     // RXIFG3
            break;
        case USCI_I2C_UCTXIFG3:     // TXIFG3
            break;
        case USCI_I2C_UCRXIFG2:     // RXIFG2
            break;
        case USCI_I2C_UCTXIFG2:     // TXIFG2
            break;
        case USCI_I2C_UCRXIFG1:     // RXIFG1
            break;
        case USCI_I2C_UCTXIFG1:     // TXIFG1
            break;
        case USCI_I2C_UCRXIFG0:     // RXIFG0
            // Get RX data
            RXData = EUSCI_B_I2C_masterReceiveSingle(EUSCI_B0_BASE);

            if (++count >= RXCOUNT)
            {
                count = 0;
                __bic_SR_register_on_exit(CPUOFF); // Exit LPM0
            }
            break;
        case USCI_I2C_UCTXIFG0:     // TXIFG0
            // Check TX byte counter
            if (TXByteCtr)
            {
                EUSCI_B_I2C_masterSendMultiByteNext(EUSCI_B0_BASE,
                    TXData[SlaveFlag]);
                // Decrement TX byte counter
                TXByteCtr--;
            }
            else
            {
                EUSCI_B_I2C_masterSendMultiByteStop(EUSCI_B0_BASE);
                // Exit LPM0
                __bic_SR_register_on_exit(CPUOFF);
            }
            break;
        case USCI_I2C_UCBCNTIFG:    // Byte count limit reached (UCBxTBCNT)
            GPIO_toggleOutputOnPin(
                GPIO_PORT_P1,
                GPIO_PIN0
                );
            break;
        case USCI_I2C_UCCLTOIFG:    // Clock low timeout - clock held low too long
            break;
        case USCI_I2C_UCBIT9IFG:    // Generated on 9th bit of a transmit (for debugging)
            break;
        default:
            break;
  }
}
