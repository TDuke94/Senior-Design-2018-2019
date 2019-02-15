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
#include "HAL_PMM.h"
#include "hal_outputs.h"
#include "msp430_interrupt.h"

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

struct rx_s {
    unsigned char header[3];
    unsigned char cmd;
};

struct hal_s {
    unsigned char lp_accel_mode;
    unsigned char sensors;
    unsigned char dmp_on;
    unsigned char wait_for_tap;
    volatile unsigned char new_gyro;
    unsigned char motion_int_mode;
    unsigned long no_dmp_hz;
    unsigned long next_pedo_ms;
    unsigned long next_temp_ms;
    unsigned long next_compass_ms;
    unsigned int report;
    unsigned short dmp_features;
    struct rx_s rx;
};

struct hal_s hal = {0};

struct platform_data_s {
    signed char orientation[9];
};

static struct platform_data_s gyro_pdata = {
    .orientation = { 1, 0, 0,
                     0, 1, 0,
                     0, 0, 1}
};

static struct platform_data_s compass_pdata = {
    .orientation = { 0, 1, 0,
                     1, 0, 0,
                     0, 0,-1}
};

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

    mpu_set_sensors(INV_XYZ_GYRO | INV_XYZ_ACCEL | INV_XYZ_COMPASS);

    mpu_configure_fifo(INV_XYZ_GYRO | INV_XYZ_ACCEL);
    mpu_set_sample_rate(1000);

    mpu_set_compass_sample_rate(1000 / 10);

    mpu_get_sample_rate(&gyro_rate);
    mpu_get_gyro_fsr(&gyro_fsr);
    mpu_get_accel_fsr(&accel_fsr);
    mpu_get_compass_fsr(&compass_fsr);

    while (1)
    {
        mpu_get_accel_reg(output.gyro, &timestamp);
        mpu_get_gyro_reg(output.accel, &timestamp);
        mpu_get_compass_reg(output.mag, &timestamp);

        // next set of bytes is raw data from IMU
        for (i = 0; i < 3; i++)
        {
            outArray[(2 * i)] = output.gyro[i] >> 8;
            outArray[(2 * i) + 1] = (output.gyro[i] & 0xff);
            outArray[(2 * i) + 6] = output.accel[i] >> 8;
            outArray[(2 * i) + 7] = (output.accel[i] & 0xff);
            outArray[(2 * i) + 12] = output.mag[i] >> 8;
            outArray[(2 * i) + 13] = (output.mag[i] & 0xff);
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
