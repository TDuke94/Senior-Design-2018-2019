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

#include "msp430f5529.h"
#include "driverlib.h"
#include "msp430_i2c.h"

typedef unsigned char uint_8t;

// function prototypes
void ClockInit(void);
void Pin_Init(void);
void I2C_Init(void);
void SBIT(void);
void IMU_Startup_Poll(void);
void Zynq_Startup_Poll(void);

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
uint_8t txData[] = {0x00};
uint_8t SlaveCount = 0;
uint_8t SwitchCount = 0;

/*
 * Constants for Addresses
 */
#define IMU_ADDRESS_1 0xD0
#define IMU_REGISTER_1 0x3D
#define ZYNQ_ADDRESS 0xE0
#define ZYNQ_REGISTER 0x0C

#define SLAVE_NUMBER 10
#define CS_SMCLK_DESIRED_FREQUENCY_IN_KHZ   1000
#define CS_SMCLK_FLLREF_RATIO   30

void main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    // Initialize I/O Pins
    Pin_Init();

    // Initialize I2C as receiver
    //I2C_Init();
    msp430_i2c_enable();

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
 * Pin Initialize
 *
 * Set Up required Pins for inputs/outputs etc.
 */
void Pin_Init(void)
{
    P3SEL |= (BIT1 | BIT0);
}

/*
 * I2C Transmit Initialization Function
 *
 * Code is used from the TI example for initialization of euxci b as master of several slaves
 *
 */
void I2C_Init(void)
{
    // reset state
    UCB0CTLW0 |= 0x01;

    // (UCMode 3:I2C) (Master Mode) (UCSSEL 1:ACLK, 2,3:SMCLK)
    //UCB0CTLW0 |= UCMODE_3 | UCMST | UCSSEL_3;
    UCB0CTLW0 |= 0x0FC0;

    // Clock divider = 8  (SMCLK @ 1.048 MHz / 8 = 131 KHz)
    UCB0BRW = 8;

    // Exit the reset mode
    UCB0CTLW0 ^= 0x01;
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
void IMU_Startup_Poll(void)
{
    char address, reg;
    int data;

    address = ZYNQ_ADDRESS;
    reg = ZYNQ_REGISTER;

    data = 0x00;

    // verify initialized to 0
    SlaveCount = 0;
    SwitchCount = 0;

    while (1)
    {
        msp430_i2c_read(address, reg, 1, data);

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
void Zynq_Startup_Poll(void)
{
    //
}
