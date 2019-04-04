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
 */

#include "msp430f5529.h"
#include "driverlib.h"
#include "msp430_i2c.h"
#include "msp430_clock.h"
#include "inv_mpu.h"
#include "msp430_interrupt.h"
#include "usci_b_spi.h"

#ifndef NULL
#define NULL 0
#endif

#define SPICLK      500000
#define MUX_ADDRESS 0x77

uint8_t transmitData = 0x00, receiveData = 0x00;

typedef unsigned char uint_8t;

typedef struct IMU_Data
{
    short accel[3];
    short gyro[3];
    short mag[3];
} IMU_Data;

// function prototypes
void ClockInit(void);
void Pin_Init(void);
void SPI_Init(void);
void IMU_Startup_Poll(void);
void IMU_Loop(void);
void sendByteSPI(uint8_t data);
void shortToBytes(short in_s, unsigned char bytes[2]);
void sendShortSPI(short input);
void pollIMU(IMU_Data *data, int index);

#define ACCEL_ON        (0x01)
#define GYRO_ON         (0x02)
#define COMPASS_ON      (0x04)

#define SLAVE_NUMBER 10

#define BOARD_INDEX     3
#define J2_INDEX        2

void main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    // Initialize I/O Pins
    Pin_Init();

    // Initialize I2C as receiver
    msp430_clock_init(20000000L, 2);
    msp430_i2c_enable();
    SPI_Init();

    // Verify IMU Comm
    IMU_Startup_Poll();

    // failure moding
    if ( 1 != 1 )
    {
        // nothing for now
    }
}

/*
 * Pin Initialize
 *
 * Set Up required Pins for inputs/outputs etc.
 */
void Pin_Init(void)
{
    P3SEL |= (BIT1 | BIT0);
    GPIO_setAsOutputPin
    (
        GPIO_PORT_P1,
        GPIO_PIN2
    );

    GPIO_setAsOutputPin
    (
        GPIO_PORT_P6,
        GPIO_PIN0 + GPIO_PIN1 + GPIO_PIN2 + GPIO_PIN3
    );

    GPIO_setOutputHighOnPin(
        GPIO_PORT_P1,
        GPIO_PIN2
        );

    GPIO_setAsPeripheralModuleFunctionInputPin
    (
        GPIO_PORT_P4,
        GPIO_PIN0 + GPIO_PIN1 + GPIO_PIN2 + GPIO_PIN3
    );
}

void SPI_Init(void)
{
    int returnValue;

    USCI_B_SPI_initMasterParam param = {0};
    param.selectClockSource = USCI_B_SPI_CLOCKSOURCE_SMCLK;
    param.clockSourceFrequency = UCS_getSMCLK();
    param.desiredSpiClock = SPICLK;
    param.msbFirst = USCI_B_SPI_MSB_FIRST;
    param.clockPhase = USCI_B_SPI_PHASE_DATA_CHANGED_ONFIRST_CAPTURED_ON_NEXT;
    param.clockPolarity = USCI_B_SPI_CLOCKPOLARITY_INACTIVITY_HIGH;
    returnValue =  USCI_B_SPI_initMaster(USCI_B1_BASE, &param);

    if (STATUS_FAIL == returnValue){
        return;
    }

    USCI_B_SPI_enable(USCI_B1_BASE);

    //Now with SPI signals initialized, reset slave
    GPIO_setOutputLowOnPin(
        GPIO_PORT_P1,
        GPIO_PIN2
        );
}

volatile int count = 0;
volatile int goodCount = 0;

/*
 * IMU Startup Poll
 *
 * Verify the IMUs expected are present and ready for communication
 */
void IMU_Startup_Poll(void)
{
    unsigned char address, reg, data;
    unsigned short gyro_rate;
    volatile int Status, i, j, index;
    unsigned long timestamp;

    unsigned char outArray[6];

    IMU_Data output;

    address = 0x08;

    j = msp430_i2c_write(0x77, 0, 1, &address);

    Status = mpu_init(NULL);
    //if (Status) return;

    address = 0x04;

    j = msp430_i2c_write(0x77, 0, 1, &address);



    Status = mpu_init(NULL);

    while (1)
    {
        pollIMU(&output, BOARD_INDEX);

        //pollIMU(&output, J2_INDEX);

        if (output.accel[0] == 0 || output.accel[1] == 0 || output.accel[2] == 0)
            count++;
        else
            goodCount++;

        // next set of bytes is raw data from IMU
        /*for (i = 0; i < 3; i++)
        {
            outArray[(2 * i)]       = output.gyro[i] >> 8;
            outArray[(2 * i) + 1]   = (output.gyro[i] & 0xff);
            outArray[(2 * i) + 6]   = output.accel[i] >> 8;
            outArray[(2 * i) + 7]   = (output.accel[i] & 0xff);
            outArray[(2 * i) + 12]  = output.mag[i] >> 8;
            outArray[(2 * i) + 13]  = (output.mag[i] & 0xff);
        }*/

        // Transmit over SPI
        GPIO_setOutputLowOnPin
        (
            GPIO_PORT_P1,
            GPIO_PIN2
        );

        gyro_rate = 1250;

        address = 'A';
        sendByteSPI(address);
        sendByteSPI(address);

        sendShortSPI(output.accel[0]);
        sendShortSPI(output.accel[1]);
        sendShortSPI(output.accel[2]);

        GPIO_setOutputHighOnPin
        (
            GPIO_PORT_P1,
            GPIO_PIN2
        );

        if(0 >= SLAVE_NUMBER)
        {
            // We have spoken to all of the IMUs
            break;
        }
    }
}

/*
 * Polls a single IMU
 *
 * polls a single IMU for data
 */
void pollIMU(IMU_Data *data, int index)
{
    unsigned char reg;

    reg = (1 << index);

    msp430_i2c_write(MUX_ADDRESS, 0, 1, &reg);

    mpu_get_accel_reg(data->accel, NULL);
    mpu_get_gyro_reg(data->gyro, NULL);
}

void sendShortSPI(short input)
{
    unsigned char splitShort[2];
    unsigned char output;

    shortToBytes(input, splitShort);

    output = splitShort[1];
    sendByteSPI(output);
    output = splitShort[0];
    sendByteSPI(output);
}

void shortToBytes(short in_s, unsigned char bytes[2])
{
    union {
        short s;
        unsigned char c[2];
    }U;

    U.s = in_s;
    bytes[0] = U.c[0];
    bytes[1] = U.c[1];
}

void sendByteSPI(uint8_t data)
{
    // don't send without
    while (!USCI_B_SPI_getInterruptStatus(USCI_B1_BASE, USCI_B_SPI_TRANSMIT_INTERRUPT)) ;

    USCI_B_SPI_transmitData(USCI_B1_BASE, data);
}

#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=USCI_B1_VECTOR
__interrupt
#elif defined(__GNUC__)
__attribute__((interrupt(USCI_B0_VECTOR)))
#endif
void USCI_B1_ISR (void)
{
    switch (__even_in_range(UCB1IV,4)){
        //Vector 2 - RXIFG
        case 2:
            //USCI_A0 TX buffer ready?

            break;
        case 4:
            // USCI_B1 TXIFG???

        default: break;
    }
}
