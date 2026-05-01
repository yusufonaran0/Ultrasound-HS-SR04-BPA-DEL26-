# Simulation Results

This section presents the simulation-based verification of the **Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T** project. All custom modules were first tested individually using EDA Playground, and then the complete system was verified through top-level simulations in both EDA Playground and Vivado. The goal of these simulations was to ensure correct functionality before hardware implementation.

<br><br> 

## Module-Level Simulations

Each module was simulated independently to verify its functionality and to isolate potential issues early in the design process.

<br> 

### `hs_sr04_trigger`

![HS-SR04 Trigger Simulation](./hs_sr04_trigger_eda_waveforms.png)

This simulation verifies the generation of the trigger pulse required by the ultrasonic sensor. When `start_meas` is asserted, the module produces a HIGH pulse on `trig` for approximately **10 µs** (1000 clock cycles at 100 MHz).

The simulation confirms:
- correct trigger pulse duration
- proper activation after `start_meas`
- correct assertion of `done` after pulse completion

<br> 


### `sr04_echo_capture`

![SR04 Echo Capture Simulation](./sr04_echo_capture_eda_waveforms.png)

This module measures the duration of the echo signal. The simulation shows:
- detection of the rising edge of `echo`
- counting while `echo` is HIGH (`echo_count`)
- assertion of `echo_done` on falling edge
- timeout protection via `echo_timeout`

This is the core measurement block of the system.

<br>

### `measurement_control`

![Measurement Control Simulation](./measurement_control_eda_waveforms.png)

This module is the main FSM controlling the measurement process. Verified state flow:

IDLE → TRIGGER → WAIT_ECHO → DONE → (repeat / HOLD) 


The simulation confirms:
- correct sequencing of trigger and echo phases
- proper handling of `trigger_done` and `echo_done`
- correct generation of `valid_data`
- stable behavior during hold mode

<br>

### `distance_converter`

![Distance Converter Simulation](./distance_converter_eda_waveforms.png)

This module converts echo pulse duration into distance. Implemented relation:
distance_cm ≈ echo_count / 5800 


The simulation confirms:
- correct integer-based conversion
- consistent mapping between `echo_count` and `distance_cm`

<br>

### `buzzer_control`

![Buzzer Control Simulation](./buzzer_control_eda_waveforms.png)

This module generates distance-based buzzer feedback.

Behavior:
- distance > 100 cm → buzzer OFF
- 50–100 cm → slow beeping
- 20–50 cm → medium beeping
- 5–20 cm → fast beeping
- ≤5 cm → continuous sound

Simulation confirms correct threshold-based response.

<br>

### `display_driver`

![Display Driver Simulation](./display_driver_eda_waveforms.png)

This module controls the multiplexed 7-segment display.

The simulation verifies:
- correct digit scanning via `an[7:0]`
- correct segment output via `seg[6:0]`
- stable display of distance values
- correct behavior for invalid / hold states

<br>

## Top-Level Simulations

After verifying individual modules, the entire system was tested as a whole.

<br>

### `ultrasonic_top` (EDA Playground)

![Top-Level EDA Simulation](./top_level_eda_waveforms.png)

This simulation validates system integration.

Observed behavior:
- measurement cycle starts correctly
- trigger pulse is generated
- echo signal is processed
- outputs (LED, buzzer, display) respond accordingly

<br>

### `ultrasonic_top` (Vivado Simulation)

![Top-Level Vivado Simulation](./top_level_vivado_waveforms.jpeg)

This simulation was performed in Vivado before hardware implementation.

The waveform confirms:
- correct synchronization with system clock
- proper signal interaction between modules
- stable system-level behavior

<br>

## Measurement Interval Adjustment (Observations during implementation)

During simulation, the delay between consecutive measurements was intentionally kept short to speed up waveform observation. However, during hardware implementation:
- first adjusted to **60 ms**
- later increased to approximately **250 ms**

This adjustment was necessary because:
- very frequent triggering caused unstable or noisy readings
- the ultrasonic sensor requires sufficient settling time
- increasing the delay significantly improved measurement stability

This was one of the key practical improvements observed during real hardware testing.

<br><br>

## Summary

The design was verified in multiple stages:

- individual module simulations (EDA Playground)
- integrated system simulation (EDA Playground)
- full design simulation (Vivado)

These steps ensured that the system was functionally correct before moving to FPGA implementation. 




