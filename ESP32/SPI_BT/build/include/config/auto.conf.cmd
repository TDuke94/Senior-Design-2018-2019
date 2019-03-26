deps_config := \
	/home/dgdan/esp/esp-idf/components/app_trace/Kconfig \
	/home/dgdan/esp/esp-idf/components/aws_iot/Kconfig \
	/home/dgdan/esp/esp-idf/components/bt/Kconfig \
	/home/dgdan/esp/esp-idf/components/driver/Kconfig \
	/home/dgdan/esp/esp-idf/components/esp32/Kconfig \
	/home/dgdan/esp/esp-idf/components/esp_adc_cal/Kconfig \
	/home/dgdan/esp/esp-idf/components/esp_http_client/Kconfig \
	/home/dgdan/esp/esp-idf/components/ethernet/Kconfig \
	/home/dgdan/esp/esp-idf/components/fatfs/Kconfig \
	/home/dgdan/esp/esp-idf/components/freertos/Kconfig \
	/home/dgdan/esp/esp-idf/components/heap/Kconfig \
	/home/dgdan/esp/esp-idf/components/libsodium/Kconfig \
	/home/dgdan/esp/esp-idf/components/log/Kconfig \
	/home/dgdan/esp/esp-idf/components/lwip/Kconfig \
	/home/dgdan/esp/esp-idf/components/mbedtls/Kconfig \
	/home/dgdan/esp/esp-idf/components/nvs_flash/Kconfig \
	/home/dgdan/esp/esp-idf/components/openssl/Kconfig \
	/home/dgdan/esp/esp-idf/components/pthread/Kconfig \
	/home/dgdan/esp/esp-idf/components/spi_flash/Kconfig \
	/home/dgdan/esp/esp-idf/components/spiffs/Kconfig \
	/home/dgdan/esp/esp-idf/components/tcpip_adapter/Kconfig \
	/home/dgdan/esp/esp-idf/components/vfs/Kconfig \
	/home/dgdan/esp/esp-idf/components/wear_levelling/Kconfig \
	/home/dgdan/esp/esp-idf/components/bootloader/Kconfig.projbuild \
	/home/dgdan/esp/esp-idf/components/esptool_py/Kconfig.projbuild \
	/home/dgdan/esp/esp-idf/components/partition_table/Kconfig.projbuild \
	/home/dgdan/esp/esp-idf/Kconfig

include/config/auto.conf: \
	$(deps_config)

ifneq "$(IDF_CMAKE)" "n"
include/config/auto.conf: FORCE
endif

$(deps_config): ;
