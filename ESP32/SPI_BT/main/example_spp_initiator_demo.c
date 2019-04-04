/* SPI Slave example, receiver (uses SPI Slave driver to communicate with sender)

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "freertos/queue.h"

#include "lwip/sockets.h"
#include "lwip/dns.h"
#include "lwip/netdb.h"
#include "lwip/igmp.h"

#include "esp_wifi.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_event_loop.h"
#include "nvs_flash.h"
#include "soc/rtc_cntl_reg.h"
#include "rom/cache.h"
#include "driver/spi_slave.h"
#include "esp_log.h"
#include "esp_spi_flash.h"


#include <stdbool.h>

#include "nvs.h"
#include "nvs_flash.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_bt.h"
#include "esp_bt_main.h"
#include "esp_gap_bt_api.h"
#include "esp_bt_device.h"
#include "esp_spp_api.h"

#include "time.h"
#include "sys/time.h"

#define SPP_TAG "SPP_ACCEPTOR_DEMO"
#define SPP_SERVER_NAME "SPP_SERVER"
#define EXCAMPLE_DEVICE_NAME "ESP_SPP_ACCEPTOR"
#define SPP_SHOW_DATA 0
#define SPP_SHOW_SPEED 1
#define TRUE 1
#define FALSE 0
#define SPP_SHOW_MODE SPP_SHOW_DATA    /*Choose show mode: show data or speed*/

static const esp_spp_mode_t esp_spp_mode = ESP_SPP_MODE_CB;

static struct timeval time_new, time_old;
static long data_num = 0;

static const esp_spp_sec_t sec_mask = ESP_SPP_SEC_NONE;
static const esp_spp_role_t role_slave = ESP_SPP_ROLE_SLAVE;

uint32_t handle;

uint32_t writeAvailable;

static void print_speed(void)
{
    float time_old_s = time_old.tv_sec + time_old.tv_usec / 1000000.0;
    float time_new_s = time_new.tv_sec + time_new.tv_usec / 1000000.0;
    float time_interval = time_new_s - time_old_s;
    float speed = data_num * 8 / time_interval / 1000.0;
    ESP_LOGI(SPP_TAG, "speed(%fs ~ %fs): %f kbit/s" , time_old_s, time_new_s, speed);
    data_num = 0;
    time_old.tv_sec = time_new.tv_sec;
    time_old.tv_usec = time_new.tv_usec;
}

static void esp_spp_cb(esp_spp_cb_event_t event, esp_spp_cb_param_t *param)
{
    char buf[1024];
    //char spp_data[256];
   uint8_t spp_data[100];
	
	
    switch (event) {
    case ESP_SPP_INIT_EVT:
       // ESP_LOGI(SPP_TAG, "ESP_SPP_INIT_EVT");
        esp_bt_dev_set_device_name(EXCAMPLE_DEVICE_NAME);
        esp_bt_gap_set_scan_mode(ESP_BT_SCAN_MODE_CONNECTABLE_DISCOVERABLE);
        esp_spp_start_srv(sec_mask,role_slave, 0, SPP_SERVER_NAME);

        break;
    case ESP_SPP_DISCOVERY_COMP_EVT:
        ESP_LOGI(SPP_TAG, "ESP_SPP_DISCOVERY_COMP_EVT");
        break;
    case ESP_SPP_OPEN_EVT:
		
        ESP_LOGI(SPP_TAG, "ESP_SPP_OPEN_EVT");

        break;
    case ESP_SPP_CLOSE_EVT:
        ESP_LOGI(SPP_TAG, "ESP_SPP_CLOSE_EVT");
        break;
    case ESP_SPP_START_EVT:
        ESP_LOGI(SPP_TAG, "ESP_SPP_START_EVT");
	 // esp_spp_write(param->write.handle, 20, (uint8_t *)buf);
        break;
    case ESP_SPP_CL_INIT_EVT:
        ESP_LOGI(SPP_TAG, "ESP_SPP_CL_INIT_EVT");
		// esp_spp_write(param->write.handle, 20, (uint8_t *)buf);
        break;
    case ESP_SPP_DATA_IND_EVT:
#if (SPP_SHOW_MODE == SPP_SHOW_DATA)

	//	if(3==3)  //param->data_ind.len > 2 &&
	//	{

			for(int i = 0; i < 999; i++)
				buf[i] = 'H';

			esp_spp_write(param->write.handle, 1000, (uint8_t *)buf);
     //   }
      //  else {
       //     esp_log_buffer_hex("",param->data_ind.data,param->data_ind.len);
			

    //    }
#else
        gettimeofday(&time_new, NULL);
        data_num += param->data_ind.len;
        if (time_new.tv_sec - time_old.tv_sec >= 3) {
            print_speed();
        }
#endif
        break;
    case ESP_SPP_CONG_EVT:
        ESP_LOGI(SPP_TAG, "ESP_SPP_CONG_EVT");
		if (param->cong.cong == 0)
		{
			spp_data[0] = 0;
			spp_data[1] = 0;
			esp_spp_write (param->cong.handle, 2, spp_data);
		}
        break;
    case ESP_SPP_WRITE_EVT:
		writeAvailable = TRUE;
        break;
    case ESP_SPP_SRV_OPEN_EVT:
        ESP_LOGI(SPP_TAG, "ESP_SPP_SRV_OPEN_EVT");
		{
			handle = param->open.handle;
			writeAvailable = FALSE;
		}
        break;
    default:
        break;
    }
}

/*
SPI receiver (slave) example.

This example is supposed to work together with the SPI sender. It uses the standard SPI pins (MISO, MOSI, SCLK, CS) to 
transmit data over in a full-duplex fashion, that is, while the master puts data on the MOSI pin, the slave puts its own
data on the MISO pin.

This example uses one extra pin: GPIO_HANDSHAKE is used as a handshake pin. After a transmission has been set up and we're
ready to send/receive data, this code uses a callback to set the handshake pin high. The sender will detect this and start
sending a transaction. As soon as the transaction is done, the line gets set low again.
*/

/*
Pins in use. The SPI Master can use the GPIO mux, so feel free to change these if needed.
*/
#define GPIO_HANDSHAKE 2
#define GPIO_MISO 13
/////////////////////////////

/* Real Setup Pins
*/
#define GPIO_MOSI 27
#define GPIO_SCLK 15
#define GPIO_CS 14


//Main application
void app_main()
{	
	handle = NULL;
	
	writeAvailable = TRUE;
	esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK( ret );


    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    if (esp_bt_controller_init(&bt_cfg) != ESP_OK) {
        ESP_LOGE(SPP_TAG, "%s initialize controller failed\n", __func__);
        return;
    }

    if (esp_bt_controller_enable(ESP_BT_MODE_CLASSIC_BT) != ESP_OK) {
        ESP_LOGE(SPP_TAG, "%s enable controller failed\n", __func__);
        return;
    }

    if (esp_bluedroid_init() != ESP_OK) {
        ESP_LOGE(SPP_TAG, "%s initialize bluedroid failed\n", __func__);
        return;
    }

    if (esp_bluedroid_enable() != ESP_OK) {
        ESP_LOGE(SPP_TAG, "%s enable bluedroid failed\n", __func__);
        return;
    }

    if (esp_spp_register_callback(esp_spp_cb) != ESP_OK) {
        ESP_LOGE(SPP_TAG, "%s spp register failed\n", __func__);
        return;
    }

    if (esp_spp_init(esp_spp_mode) != ESP_OK) {
        ESP_LOGE(SPP_TAG, "%s spp init failed\n", __func__);
        return;
    }
	
	
	printf("this is just the start of the program");
    int n=0;
    //esp_err_t ret;

    //Configuration for the SPI bus
    spi_bus_config_t buscfg={
        .mosi_io_num=GPIO_MOSI,
        .miso_io_num=GPIO_MISO,
        .sclk_io_num=GPIO_SCLK
    };

    //Configuration for the SPI slave interface
    spi_slave_interface_config_t slvcfg={
        .mode=0,
        .spics_io_num=GPIO_CS,
        .queue_size=3,
        .flags=0,
		.post_setup_cb=NULL,
		.post_trans_cb=NULL

    };

    gpio_set_pull_mode(GPIO_MOSI, GPIO_PULLUP_ONLY);
    gpio_set_pull_mode(GPIO_SCLK, GPIO_PULLUP_ONLY);
    gpio_set_pull_mode(GPIO_CS, GPIO_PULLUP_ONLY);

    //Initialize SPI slave interface
    ret=spi_slave_initialize(HSPI_HOST, &buscfg, &slvcfg, 1);
    assert(ret==ESP_OK);

    char sendbuf[21]="";
    char recvbuf[21]="";
    memset(recvbuf, 0, 21);
    spi_slave_transaction_t t;
    memset(&t, 0, sizeof(t));

    while(1) {
        //Clear receive buffer, set send buffer to something sane
        memset(recvbuf, 0xA5, 21);
        //sprintf(sendbuf, "This is the receiver, sending data for transmission number %04d.", n);

		
		//printf("\nwhat exactly is going on here\n");
        //Set up a transaction of 128 bytes to send/receive
        t.length=20*8;
        t.tx_buffer=sendbuf;
        t.rx_buffer=recvbuf;
        /* This call enables the SPI slave interface to send/receive to the sendbuf and recvbuf. The transaction is
        initialized by the SPI master, however, so it will not actually happen until the master starts a hardware transaction
        by pulling CS low and pulsing the clock etc. In this specific example, we use the handshake line, pulled up by the
        .post_setup_cb callback that is called as soon as a transaction is ready, to let the master know it is free to transfer
        data.
        */
		//printf("\ntim is suspect\n");
        
		ret=spi_slave_transmit(HSPI_HOST, &t, portMAX_DELAY);
		//for(int i =0; i < 24;i++)
		//recvbuf[i] = 'A';
		
		char outbuf[28];
		
		if (recvbuf[0] != 'A') continue;
		if (recvbuf[1] != 'A') continue;
		printf("%x\t", recvbuf[0]);
		printf("%x\t", recvbuf[1]);
		printf("%x\t", recvbuf[2]);
		printf("%x\t", recvbuf[3]);
		printf("%x\t", recvbuf[4]);
		printf("%x\t", recvbuf[5]);
		printf("%x\t", recvbuf[6]);
		printf("%x\t", recvbuf[7]);
		printf("%x\n", recvbuf[8]);
		sprintf(outbuf,"%s", recvbuf);
		// we can remove the A now that we have the thing we expect.
		
        //spi_slave_transmit does not return until the master has done a transmission, so by here we have sent our data and
        //received data from the master. Print it.
       // printf("%s\n", recvbuf);
		// fixed this by removing a watchdog time clock interrrupt. the bt connection stays on now.
	  if(handle)
	   {
		  // while(writeAvailable != TRUE); // spin wait
				esp_spp_write(handle , 28, (uint8_t *)recvbuf);
		   
		   printf("getting stuffs\n");
	   }
        n++;
		//else
			// if the connectionn is ever lost with the handle:
			// - make the handle null
			// - try and restablish/ re-initializethe bluetooth connection
			
		//	esp_spp_register_callback(esp_spp_cb);
		// 
			
			
		//for (int i = 0; i < 100; i++)
		//{} // stall
    }

}


