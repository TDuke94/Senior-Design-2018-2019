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
#include "ICM20948.h"

#ifndef NULL
#define NULL 0
#endif

#define SPICLK      500000
#define MUX_ADDRESS 0x77
#define IMU_ADDRESS 0x68
#define COMPASS_ADDRESS 0x0C

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
void setupTimer(void);
void enableBypass(void);
void testFunction(void);

#define ACCEL_ON        (0x01)
#define GYRO_ON         (0x02)
#define COMPASS_ON      (0x04)

#define SLAVE_NUMBER 10

#define BOARD_INDEX     3
#define J2_INDEX        2
#define J3_INDEX        1
#define J4_INDEX        0
#define J5_INDEX        6
#define J6_INDEX        5

unsigned char timerFlag;
unsigned char flagCount;

void main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    // Initialize I/O Pins
    Pin_Init();

    // Initialize I2C as receiver
    msp430_clock_init(20000000L, 2);
    msp430_i2c_enable();
    SPI_Init();
    setupTimer();

    // Verify IMU Comm
    IMU_Startup_Poll();

    // failure moding
    if ( 1 != 1 )
    {
        // nothing for now
    }
}

void setupTimer(void)
{
    unsigned long smclk;
    TA0CTL = TASSEL_2 | ID_3 | MC_1 | TACLR;
    TA0CTL &= ~TAIFG;

    timerFlag = 0;
    flagCount = 0;

    /*
     * SMCLK = 20,000,000
     * SMCLK / 8 = 2,500,000
     */
    TA0CCR0 = 8000;

    TA0CTL |= TAIE;
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
    GPIO_setOutputLowOnPin
    (
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
    unsigned char address, reg;
    volatile int Status, i, j, index;

    IMU_Data output[5];

    // Initialize Board IMU
    index = BOARD_INDEX;
    reg = (1 << index);
    msp430_i2c_write(MUX_ADDRESS, 0, 1, &reg);
    Status = mpu_init(NULL);

    // Initialize J3 IMU
    index = J3_INDEX;
    reg = (1 << index);
    msp430_i2c_write(MUX_ADDRESS, 0, 1, &reg);
    Status = mpu_init(NULL);

    // Initialize J4 IMU
    index = J4_INDEX;
    reg = (1 << index);
    msp430_i2c_write(MUX_ADDRESS, 0, 1, &reg);
    Status = mpu_init(NULL);

    // Initialize J5 IMU
    index = J5_INDEX;
    reg = (1 << index);
    msp430_i2c_write(MUX_ADDRESS, 0, 1, &reg);
    Status = mpu_init(NULL);

    // Initialize J6 IMU
    index = J6_INDEX;
    reg = (1 << index);
    msp430_i2c_write(MUX_ADDRESS, 0, 1, &reg);
    Status = mpu_init(NULL);

    _enable_interrupts();

    while (1)
    {
        while (timerFlag == 0); // wait

        timerFlag = 0;

        pollIMU(output, BOARD_INDEX);
        //pollIMU(output + 1, J2_INDEX);
        // :'(
        pollIMU(output + 1, J3_INDEX);
        pollIMU(output + 2, J4_INDEX);
        pollIMU(output + 3, J5_INDEX);
        pollIMU(output + 4, J6_INDEX);

        address = 'A';
        sendByteSPI(address);

        sendByteSPI(address);
        sendShortSPI(output[0].accel[0]);
        sendShortSPI(output[0].accel[1]);
        sendShortSPI(output[0].accel[2]);

        sendByteSPI(address);
        sendShortSPI(output[1].accel[0]);
        sendShortSPI(output[1].accel[1]);
        sendShortSPI(output[1].accel[2]);

        sendByteSPI(address);
        sendShortSPI(output[2].accel[0]);
        sendShortSPI(output[2].accel[1]);
        sendShortSPI(output[2].accel[2]);

        sendByteSPI(address);
        sendShortSPI(output[3].accel[0]);
        sendShortSPI(output[3].accel[1]);
        sendShortSPI(output[3].accel[2]);

        sendByteSPI(address);
        sendShortSPI(output[4].accel[0]);
        sendShortSPI(output[4].accel[1]);
        sendShortSPI(output[4].accel[2]);
    }
}

void testFunction(void)
{

}

void enableBypass(void)
{
    int index;

    unsigned char reg;

    // change multiplexer
    index = 2;
    reg = (1 << index);
    msp430_i2c_write(MUX_ADDRESS, 0, 1, &reg);

    // set IMU into Bypass I2C mode

    // verify user bank is 0
    reg = 0x00;
    msp430_i2c_write(IMU_ADDRESS, 0x7F, 1, &reg);
    msp430_delay_ms(10);

    // set bypass_en - reg: 0x0f, value 0x02
    reg = 0x02;
    msp430_i2c_write(IMU_ADDRESS, 0x0f, 1, &reg);

    // set i2c master enable OFF - bank: 0, reg: 0x03, value: 0x00
    reg = 0x00;
    msp430_i2c_write(IMU_ADDRESS, 0x03, 1, &reg);
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

#pragma vector=TIMER0_A1_VECTOR
__interrupt void TIMERA0_ISR (void)
{
    flagCount++;
    if (flagCount == 2)
    {
        flagCount = 0;
        timerFlag = 1;
    }
    TA0CTL &= ~TAIFG;
}
