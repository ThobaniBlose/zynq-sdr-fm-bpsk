# ZedModem: FPGA FM Demodulator and BPSK Transmitter

This repository contains two communication-system prototypes implemented on
the Avnet MiniZed Zynq-7007S development board:

- a receive-only low-intermediate-frequency FM demodulator;
- a digital single-carrier BPSK transmitter.

The designs were developed in Verilog and integrated using AMD Vivado 2024.2.

---

## Project Status

### FM Receiver

The FPGA FM processing chain was implemented, simulated and tested in hardware
using controlled low-IF inputs.

The implemented chain includes:

```text
XADC sampling → ADC centring → I/Q mixing → I/Q low-pass filtering
    → phase extraction → phase differencing → de-emphasis
    → audio filtering → decimation
```

Hardware testing confirmed:

- an effective XADC sample rate of approximately 192.31 kS/s;
- a digital receiver centre frequency of approximately 48.08 kHz;
- correct analogue biasing within the MiniZed XADC input range;
- frequency discrimination for inputs above and below the centre frequency;
- relative tracking of different applied FM modulation frequencies.

The complete 101.3 MHz antenna-to-baseband path was not demonstrated. The RF
preselector and intended 101.25 MHz local oscillator still require further
tuning and characterisation.

### BPSK Transmitter

The BPSK transmitter was implemented, simulated and validated on the MiniZed.

The design includes:

- a 10 MHz digital carrier generator;
- symbol timing;
- a PRBS-7 binary data source;
- BPSK modulation using carrier inversion;
- a MiniZed hardware top-level interface.

Oscilloscope measurements confirmed the two carrier phase states and phase
reversals at data transitions. An external RC low-pass filter was also tested
to reduce the higher-frequency harmonics of the FPGA square-wave output.

---

## Repository Structure

```
zynq-sdr-fm-bpsk/
├── ZedModem_FM_Demod/              FM receiver Vivado project
├── ZedModem_BPSK/                  BPSK transmitter Vivado project
├── FM_Demodulation_Golden_Measure.m
├── generate_fm_adc_test.m
├── analyse_verilog_audio.m
├── ZedModem_FM_Demod/adc_samples.txt
├── adc_input_u12.txt
├── adc_expected_s13.txt
├── demod_expected_s16.txt
├── .gitignore
└── README.md
```

---

## Development Environment

- AMD Vivado 2024.2
- Target FPGA: `xc7z007sclg225-1`
- Development board: Avnet MiniZed Zynq-7007S
- HDL: Verilog
- Numerical support scripts: MATLAB

---

## Opening the Vivado Projects

### FM Receiver

Open:

```
ZedModem_FM_Demod/ZedModem_FM_Demod.xpr
```

The active synthesis top is:

```
system_wrapper_wrapper
```

The selected simulation top is:

```
tb_fm_receiver_audio
```

The hardware constraints are stored in:

```
ZedModem_FM_Demod/ZedModem_FM_Demod.srcs/constrs_1/new/fm_receiver_hardware.xdc
```

### BPSK Transmitter

Open:

```
ZedModem_BPSK/ZedModem_BPSK.xpr
```

The active synthesis top is:

```
system_wrapper
```

The selected simulation top is:

```
tb_bpsk_tx_core
```

The hardware constraints are stored in:

```
ZedModem_BPSK/ZedModem_BPSK.srcs/constrs_1/new/bpsk_minized.xdc
```

---

## Simulation

Both Vivado projects contain module-level and integrated self-checking
testbenches.

Important FM testbenches include:

```
tb_adc_center.v
tb_adc_to_iq.v
tb_nco_mixer.v
tb_fm_demod_atan.v
tb_fm_receiver_audio.v
tb_fm_receiver_file.v
```

Important BPSK testbenches include:

```
tb_carrier_10mhz.v
tb_symbol_timer.v
tb_bpsk_modulator.v
tb_bpsk_tx_core.v
tb_bpsk_tx_top.v
```

The required simulation top can be selected from the Vivado Simulation Sources
hierarchy before running behavioural simulation.

---

## MATLAB Utilities and Test Vectors

The root MATLAB scripts and text files support FM reference testing and
file-driven Verilog simulations.

- `FM_Demodulation_Golden_Measure.m` provides a floating-point FM reference
  model.
- `generate_fm_adc_test.m` generates ADC samples for file-driven simulation.
- `analyse_verilog_audio.m` analyses audio samples produced by the Verilog
  receiver.
- `adc_input_u12.txt`, `adc_expected_s13.txt` and `demod_expected_s16.txt`
  contain test inputs and expected results.
- `ZedModem_FM_Demod/adc_samples.txt` contains ADC samples used by the
  integrated FM file-driven testbench.

Some MATLAB scripts may require their file paths to be adjusted for the local
repository location.

---

## Known Limitations

- The complete FM RF front end has not been fully tuned or characterised.
- The intended 101.25 MHz local oscillator has not been fully verified.
- The FM hardware validation used controlled low-IF signals rather than a
  complete antenna-to-baseband receive chain.
- The BPSK output is a digital FPGA waveform and not a complete over-the-air
  RF transmitter.
- Vivado-managed block-design and IP files should not be manually removed or
  renamed without first regenerating and verifying the projects.

---

## Author

Thobani Blose  
Electrical and Computer Engineering  
University of Cape Town
