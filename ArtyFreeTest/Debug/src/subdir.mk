################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/DataManager.c \
../src/QueueTest.c \
../src/dispatch.c \
../src/main.c \
../src/talky.c 

OBJS += \
./src/DataManager.o \
./src/QueueTest.o \
./src/dispatch.o \
./src/main.o \
./src/talky.o 

C_DEPS += \
./src/DataManager.d \
./src/QueueTest.d \
./src/dispatch.d \
./src/main.d \
./src/talky.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: SDSCC Compiler'
	sdscc -Wall -O0 -g -I"../src" -IC:\Users\TimothyDuke\workspace\Arty_Z7_20\export\Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp -c -fmessage-length=0 -MT"$@" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<" -sds-sys-config FreeRTOS -sds-proc FreeRTOS -sds-pf "C:\Users\TimothyDuke\workspace\Arty_Z7_20\export\Arty_Z7_20"
	@echo 'Finished building: $<'
	@echo ' '


