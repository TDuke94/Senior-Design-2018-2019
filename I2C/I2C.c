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
    msp430_i2c_enable();
    //msp430_int_init();
    msp430_clock_init(12000000L, 2);

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

static void gyro_data_ready_cb(void)
{
    hal.new_gyro = 1;
}

/*
 * IMU Startup Poll
 *
 * Verify the IMUs expected are present and ready for communication
 */
void IMU_Startup_Poll(void)
{
    unsigned char address, reg, data, accel_fsr, more;
    unsigned short gyro_rate, gyro_fsr, compass_fsr;
    int Status;
    unsigned long timestamp;

    struct int_param_s parameters;

    IMU_Data output;

    address = IMU_ADDRESS_1;
    reg = IMU_REGISTER_1;

    data = 0x00;

    // verify initialized to 0
    SlaveCount = 0;
    SwitchCount = 0;

    parameters.cb = gyro_data_ready_cb;
    parameters.pin = INT_PIN_P20;
    parameters.lp_exit = INT_EXIT_LPM0;
    parameters.active_low = 1;

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
        mpu_read_fifo(output.gyro, output.accel, &timestamp, INV_XYZ_GYRO|INV_XYZ_ACCEL, &more);

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
