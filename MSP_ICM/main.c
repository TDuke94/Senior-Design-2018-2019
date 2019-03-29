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
#include "msp430_clock.h"
#include "inv_mpu.h"
#include "msp430_interrupt.h"

#ifndef NULL
#define NULL 0
#endif

typedef unsigned char uint_8t;

// function prototypes
void ClockInit(void);
void Pin_Init(void);
void SBIT(void);
void IMU_Startup_Poll(void);
void Zynq_Startup_Poll(void);

#define ACCEL_ON        (0x01)
#define GYRO_ON         (0x02)
#define COMPASS_ON      (0x04)

typedef struct IMU_Data
{
    short accel[3];
    short gyro[3];
    short mag[3];
} IMU_Data;

#define ZYNQ_ADDRESS 0x70
#define SLAVE_NUMBER 10

void main(void)
{

    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    // Initialize I/O Pins
    Pin_Init();

    // Initialize I2C as receiver
    msp430_clock_init(20000000L, 2);
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
 * Startup Built-In-Test
 *
 * This test verifies functionality of the MSP430 device upon startup
 */
void SBIT(void)
{
    // Tests Go Here
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
    unsigned char address, reg, accel_fsr, more;
    unsigned short gyro_rate, gyro_fsr, compass_fsr;
    int Status, i;
    unsigned long timestamp;

    unsigned char timeArray[8];
    unsigned char outArray[6];
    unsigned char inArray[5];

    IMU_Data output;

    Status = mpu_init(NULL);
    if (Status) return;

    while (1)
    {
        mpu_get_accel_reg(output.accel, NULL);
        mpu_get_gyro_reg(output.gyro, NULL);
        mpu_get_compass_reg(output.mag, &timestamp);

        if (output.accel[0] == 0 || output.accel[1] == 0 || output.accel[2] == 0)
            count++;
        else
            goodCount++;

        // next set of bytes is raw data from IMU
        for (i = 0; i < 3; i++)
        {
            outArray[(2 * i)]       = output.gyro[i] >> 8;
            outArray[(2 * i) + 1]   = (output.gyro[i] & 0xff);
            outArray[(2 * i) + 6]   = output.accel[i] >> 8;
            outArray[(2 * i) + 7]   = (output.accel[i] & 0xff);
            outArray[(2 * i) + 12]  = output.mag[i] >> 8;
            outArray[(2 * i) + 13]  = (output.mag[i] & 0xff);
        }

        msp430_i2c_write(ZYNQ_ADDRESS, 0, 18, outArray);

        // check a status word
        //msp430_i2c_read(ZYNQ_ADDRESS, 0, 5, inArray);

        if(0 >= SLAVE_NUMBER)
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
