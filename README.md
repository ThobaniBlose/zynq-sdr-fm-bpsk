# ZedModem — Zynq SDR FM & BPSK Radio Modem

A two-stage software-defined radio project built on the Xilinx Zynq-7000 FPGA platform. Stage 1 implements a complete FM receiver that demodulates a low-IF FM signal from an ADC and outputs audio via PWM. Stage 2 implements a BPSK transmitter targeting a 433 MHz RF module on the MiniZed board.

All signal processing runs in the FPGA programmable logic (PL), with the ARM processor (PS) supplying the clock and reset via the Zynq PS7 block design.

---

## Project Structure

```
zynq-sdr-fm-bpsk/
├── ZedModem_FM_Demod/        # Stage 1: FM receiver Vivado project (ZedBoard)
├── ZedModem_BPSK/            # Stage 2: BPSK transmitter Vivado project (MiniZed)
├── minized_433_tx_test/      # 433 MHz RF hardware smoke-test project
├── FM_Demodulation_Golden_Measure.m   # MATLAB golden reference model
├── generate_fm_adc_test.m    # Generates ADC test vectors for simulation
├── analyse_verilog_audio.m   # Analyses recovered audio from simulation
├── adc_input_u12.txt         # 12-bit unsigned ADC input test vectors
├── adc_expected_s13.txt      # Expected centred ADC output
└── demod_expected_s16.txt    # Expected FM demodulator output (MATLAB reference)
```

---

## Stage 1 — FM Receiver (ZedBoard / Zynq-7010)

### Signal Chain

```
ADC (12-bit) → DC offset removal → NCO mixer (DDC to baseband)
    → 2-tap I/Q LPF → CORDIC atan2 phase → Phase differentiator
    → De-emphasis filter (50 µs) → Audio FIR LPF (15 kHz)
    → 4× decimator → PWM audio output
```

### Key Modules

| Module | Description |
|--------|-------------|
| `adc_center.v` | Removes the 2048 DC offset from the 12-bit unsigned ADC code |
| `nco_mixer.v` | Multiplies the ADC signal by a digital LO (I×cos, Q×sin) to downconvert |
| `iq_lpf_2tap.v` | Simple 2-tap averaging filter on the I and Q channels |
| `atan2_phase.v` | Wraps the Xilinx CORDIC IP to compute instantaneous phase |
| `phase_difference.v` | FM discriminator — subtracts consecutive phase values |
| `deemphasis_filter.v` | IIR first-order de-emphasis (α = 0.905, τ = 50 µs) |
| `audio_lpf_fir.v` | 63-tap symmetric FIR low-pass filter at 15 kHz |
| `audio_decimator.v` | Drops sample rate from 200 kS/s to 50 kS/s (÷4) |
| `audio_pwm.v` | Converts 16-bit audio samples to a 1-bit PWM output |
| `fm_receiver_hardware_top.v` | Top-level module connecting XADC sampler to the full receive chain |

### Top-Level Integration

The `system_wrapper` block design connects the ARM PS7 (FCLK_CLK0 at 50 MHz) to `fm_receiver_hardware_top`. An inverter converts the active-low PS reset to the active-high reset the PL expects. The XADC differential analog inputs (VAUXP1/VAUXN1) and PWM audio output are exposed as top-level ports.

### MATLAB Golden Model

`FM_Demodulation_Golden_Measure.m` generates a simulated FM signal, runs the full demodulation pipeline in floating point, and exports test vectors used to verify the Verilog implementation. It checks RMSE, max error, and correlation against the reference.

### Simulation

Every module has a self-checking testbench. The file-driven testbench `tb_adc_to_fm_demod_file.v` feeds `adc_input_u12.txt` through the full demodulator and compares each output sample against `demod_expected_s16.txt`.

---

## Stage 2 — BPSK Transmitter (MiniZed / Zynq-7007S)

### Signal Chain

```
10 MHz carrier (square wave) + PRBS-7 bit stream
    → BPSK modulator (0° / 180° phase keying)
    → bpsk_tx_top → 433 MHz RF module
```

### Key Modules

| Module | Description |
|--------|-------------|
| `carrier_10mhz.v` | Generates a 10 MHz square wave by dividing the 100 MHz clock ÷10 |
| `symbol_timer.v` | Pulses `symbol_tick` every 1000 clock cycles (100 kbaud default) |
| `bpsk_prbs7_source.v` | 7-bit LFSR producing a 127-bit PRBS-7 sequence (x⁷ + x⁶ + 1) |
| `bpsk_modulator.v` | Bit=1 passes carrier unchanged; Bit=0 inverts it (180° phase shift) |
| `bpsk_tx_core.v` | Assembles carrier, timer, bit source, and modulator into one core |
| `bpsk_tx_top.v` | Hardware top level exposing only `clk`, `rst`, and `bpsk_out` |

### 433 MHz RF Smoke Test

`minized_433_tx_test/` is a standalone Vivado project used to verify the RF hardware path before adding BPSK modulation. It generates a 1 Hz square wave from the PS clock and routes it to the 433 MHz module data pin (R8). A receiver picking up the 1 Hz toggle confirms the RF chain is functional.

### MiniZed Pin Assignments

| Signal | Pin | Standard |
|--------|-----|----------|
| `bpsk_out` | P8 (Arduino IO1) | LVCMOS33 |
| `bit_debug` | R8 (Arduino IO0) | LVCMOS33 |
| `vauxp1` | F13 | XADC analog |
| `vauxn1` | F14 | XADC analog |

An ILA debug core captures `carrier`, `current_bit`, `symbol_tick`, and `bpsk_internal` for live observation in Vivado Hardware Manager.

---

## Branch Structure

| Branch | Purpose |
|--------|---------|
| `main` | Latest stable merged work |
| `master` | Stage 1 FM receiver history |
| `stage2-bpsk` | Stage 2 BPSK transmitter development |

**Tag:** `stage1-fm-validated` marks the final verified state of the FM receiver before Stage 2 began.

---

## Tools & Requirements

- **Vivado 2024.2** (Xilinx/AMD)
- **MATLAB** (for golden model and test vector generation)
- Target boards: ZedBoard (Zynq-7010) for FM, MiniZed (Zynq-7007S) for BPSK
- Simulation: Vivado XSim (all testbenches are self-checking with pass/fail output)

---

## How to Open the Projects

1. Clone the repo:
   ```bash
   git clone https://github.com/ThobaniBlose/zynq-sdr-fm-bpsk.git
   ```
2. Open Vivado 2024.2
3. **File → Open Project** and navigate to either:
   - `ZedModem_FM_Demod/ZedModem_FM_Demod.xpr` for the FM receiver
   - `ZedModem_BPSK/ZedModem_BPSK.xpr` for the BPSK transmitter
4. Vivado will regenerate any IP outputs automatically

---

## Author

**Thobani Blose** — University of Cape Town  
[github.com/ThobaniBlose](https://github.com/ThobaniBlose)
