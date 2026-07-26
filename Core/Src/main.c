/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define SI5351_I2C_ADDRESS    (0x60U << 1)

/*
 * Heterodyne verification test — Si5351 CLK0 = 10 MHz LO.
 *
 * Connect:
 *   Function generator 15 MHz sine  →  AD831 RF input
 *   Si5351 CLK0 10 MHz              →  AD831 LO input
 *   AD831 output                    →  Oscilloscope (no filter)
 *
 * Expected mixer products:
 *   Difference:  15 - 10 =  5 MHz
 *   Sum:         15 + 10 = 25 MHz
 *
 * Decisive shift test: change RF to 14 MHz → products move to 4 / 24 MHz.
 */

volatile HAL_StatusTypeDef si5351_init_status;
volatile uint8_t si5351_device_status;
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
I2C_HandleTypeDef hi2c1;

/* USER CODE BEGIN PV */
volatile uint8_t i2c_detected_addresses[16];
volatile uint8_t i2c_detected_count = 0;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_I2C1_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
static HAL_StatusTypeDef Si5351_WriteRegister(uint8_t reg,
                                               uint8_t value)
{
    return HAL_I2C_Mem_Write(&hi2c1,
                             SI5351_I2C_ADDRESS,
                             reg,
                             I2C_MEMADD_SIZE_8BIT,
                             &value,
                             1,
                             HAL_MAX_DELAY);
}

static HAL_StatusTypeDef Si5351_ReadRegister(uint8_t reg,
                                              uint8_t *value)
{
    return HAL_I2C_Mem_Read(&hi2c1,
                            SI5351_I2C_ADDRESS,
                            reg,
                            I2C_MEMADD_SIZE_8BIT,
                            value,
                            1,
                            HAL_MAX_DELAY);
}

static HAL_StatusTypeDef Si5351_Init10MHz(void)
{
    HAL_StatusTypeDef status;

    /*
     * Disable all clock outputs while changing the PLL and
     * MultiSynth configuration.
     */
    status = Si5351_WriteRegister(3, 0xFF);
    if (status != HAL_OK)
    {
        return status;
    }

    /*
     * Power down CLK0, CLK1 and CLK2 output drivers.
     */
    for (uint8_t reg = 16; reg <= 18; reg++)
    {
        status = Si5351_WriteRegister(reg, 0x80);
        if (status != HAL_OK)
        {
            return status;
        }
    }

    /*
     * Register 15:
     * Select the onboard crystal as the PLLA reference.
     */
    status = Si5351_WriteRegister(15, 0x00);
    if (status != HAL_OK)
    {
        return status;
    }

    /*
     * PLLA configuration:
     * 25 MHz crystal x 32 = 800 MHz  (integer mode).
     *
     * P1 = 128(32) - 512 = 3584 = 0x0E00
     * P2 = 0
     * P3 = 1
     */
    const uint8_t plla_registers[8] =
    {
        0x00, /* Reg 26: P3[15:8]        = 0x00 */
        0x01, /* Reg 27: P3[7:0]         = 0x01 */
        0x00, /* Reg 28: P1[17:16]       = 0x00 */
        0x0E, /* Reg 29: P1[15:8]        = 0x0E */
        0x00, /* Reg 30: P1[7:0]         = 0x00 */
        0x00, /* Reg 31: P3/P2 upper bits= 0x00 */
        0x00, /* Reg 32: P2[15:8]        = 0x00 */
        0x00  /* Reg 33: P2[7:0]         = 0x00 */
    };

    for (uint8_t i = 0; i < 8; i++)
    {
        status = Si5351_WriteRegister((uint8_t)(26 + i),
                                      plla_registers[i]);
        if (status != HAL_OK)
        {
            return status;
        }
    }

    /*
     * MultiSynth0 configuration:
     * 800 MHz / 80 = 10 MHz  (integer mode).
     *
     * P1 = 128(80) - 512 = 9728 = 0x2600
     * P2 = 0
     * P3 = 1
     */
    const uint8_t ms0_registers[8] =
    {
        0x00, /* Reg 42: P3[15:8]             = 0x00 */
        0x01, /* Reg 43: P3[7:0]              = 0x01 */
        0x00, /* Reg 44: R divider = 1, P1[17:16] = 0 */
        0x26, /* Reg 45: P1[15:8]             = 0x26 */
        0x00, /* Reg 46: P1[7:0]              = 0x00 */
        0x00, /* Reg 47: P3/P2 upper bits     = 0x00 */
        0x00, /* Reg 48: P2[15:8]             = 0x00 */
        0x00  /* Reg 49: P2[7:0]              = 0x00 */
    };

    for (uint8_t i = 0; i < 8; i++)
    {
        status = Si5351_WriteRegister((uint8_t)(42 + i),
                                      ms0_registers[i]);
        if (status != HAL_OK)
        {
            return status;
        }
    }

    /*
     * CLK0 control:
     * - output powered up;
     * - MultiSynth0 integer mode (MS_INT bit 6 = 1);
     * - PLLA selected;
     * - output not inverted;
     * - MultiSynth0 selected as source;
     * - 8 mA drive strength.
     * 0x4F = 0100_1111
     */
    status = Si5351_WriteRegister(16, 0x4F);
    if (status != HAL_OK)
    {
        return status;
    }

    /*
     * Keep unused CLK1 and CLK2 outputs powered down.
     */
    status = Si5351_WriteRegister(17, 0x80);
    if (status != HAL_OK)
    {
        return status;
    }

    status = Si5351_WriteRegister(18, 0x80);
    if (status != HAL_OK)
    {
        return status;
    }

    /*
     * Reset PLLA and PLLB after writing the new configuration.
     */
    status = Si5351_WriteRegister(177, 0xAC);
    if (status != HAL_OK)
    {
        return status;
    }

    HAL_Delay(10);

    /*
     * Enable CLK0 only:
     * bit 0 = 0 enables CLK0;
     * all remaining output-disable bits stay high.
     */
    return Si5351_WriteRegister(3, 0xFE);
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_I2C1_Init();
  /* USER CODE BEGIN 2 */
  HAL_Delay(20);

  si5351_init_status = Si5351_Init10MHz();

  HAL_Delay(100);

  Si5351_ReadRegister(0, (uint8_t *)&si5351_device_status);
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE3);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief I2C1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_I2C1_Init(void)
{

  /* USER CODE BEGIN I2C1_Init 0 */

  /* USER CODE END I2C1_Init 0 */

  /* USER CODE BEGIN I2C1_Init 1 */

  /* USER CODE END I2C1_Init 1 */
  hi2c1.Instance = I2C1;
  hi2c1.Init.ClockSpeed = 100000;
  hi2c1.Init.DutyCycle = I2C_DUTYCYCLE_2;
  hi2c1.Init.OwnAddress1 = 0;
  hi2c1.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
  hi2c1.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
  hi2c1.Init.OwnAddress2 = 0;
  hi2c1.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
  hi2c1.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
  if (HAL_I2C_Init(&hi2c1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN I2C1_Init 2 */

  /* USER CODE END I2C1_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
