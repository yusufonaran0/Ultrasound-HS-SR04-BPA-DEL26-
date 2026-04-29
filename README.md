# Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T

## Project Overview

This project implements an FPGA-based ultrasound distance meter on the **Digilent Nexys A7-50T** board using the **HS-SR04 ultrasonic sensor**. The system generates a trigger pulse for the sensor, measures the returned echo pulse width, converts the measured time into distance in centimeters, displays the result on the onboard seven-segment display, and drives a buzzer according to proximity.

The project was developed for the **BPA-DEL26 / Digital Electronics** laboratory work and follows a modular design style. The final repository includes:

- the complete Vivado project
- all source modules
- EDA Playground testbench files
- Vivado testbench files
- top-level and module-level simulation evidence
- updated schematic documentation
- physical wiring documentation
- initial hardware implementation evidence

---

## Design Objective

The objective of the design is to build a complete FPGA-based ultrasonic measurement system with the following behavior:

1. Generate a valid **10 µs trigger pulse** for the HS-SR04 sensor.
2. Measure the width of the returned **echo** signal.
3. Convert the measured echo width into **distance in centimeters**.
4. Display the measured value on the **eight-digit seven-segment display** of the Nexys A7.
5. Support a **hold function** using a push-button.
6. Generate a **buzzer output** whose warning speed depends on the measured distance.
7. Provide clear **status indication** using onboard LEDs.

---

## System Functionality

The complete measurement sequence is:

1. The top-level controller requests a new measurement.
2. The trigger generator produces a 10 µs pulse on `trig`.
3. The sensor emits ultrasound and drives the `echo` line high for a time proportional to the target distance.
4. The echo capture module counts the number of FPGA clock cycles while `echo` is high.
5. The measured counter value is converted to distance in centimeters.
6. The latest valid distance is stored and shown on the seven-segment display.
7. The buzzer behavior is updated according to the measured distance.
8. If **hold mode** is active, the displayed result is frozen until hold is released.

---

## Ultrasound Module Description, Functionality, and Interconnection

The ultrasound subsystem is built from several interconnected modules. Their relationship is shown in the updated top-level schematic below.

### Updated Top-Level Schematic

![Updated top-level schematic](images/schematics_top_level_ver3.png)

The updated schematic now includes:

- module input/output names
- key internal signal names
- bus widths for important connections
- clearer interconnection between the top-level and the custom modules

This directly addresses the feedback requesting that module input/output names and interconnections should be made explicit.

---

## Top-Level I/O Interface

The top-level module is [`ultrasonic_top.v`](vivado/ultrasonic_1.srcs/sources_1/new/ultrasonic_top.v).

### Inputs

| Signal | Description |
|---|---|
| `clk` | 100 MHz system clock from Nexys A7 |
| `btnu` | Reset button |
| `btnd` | Hold button |
| `echo` | Echo input from the ultrasonic sensor |

### Outputs

| Signal | Description |
|---|---|
| `trig` | Trigger output to the ultrasonic sensor |
| `buzzer` | Buzzer control output |
| `seg[6:0]` | Seven-segment cathode control lines |
| `an[7:0]` | Seven-segment anode enable lines |
| `dp` | Decimal point control |
| `led[3:0]` | Status LEDs |

### LED Meanings

| LED | Meaning |
|---|---|
| `led[0]` | `w_measuring` |
| `led[1]` | `w_hold_state` |
| `led[2]` | `r_valid_meas` |
| `led[3]` | `w_echo_timeout` |

---

## Internal Module Interconnection

The internal operation of the top-level design is summarized below.

### 1. Button Processing

The `btnd` hold button is processed by the `debounce` module.

- Raw input: `btnd`
- Debounced state: `w_hold_state`

This ensures that button bounce does not cause unstable hold behavior.

### 2. Measurement Sequencing

The `measurement_control` finite state machine controls the overall measurement flow.

It generates:

- `w_start_trigger`
- `w_measuring`
- `w_valid_data`

and observes:

- `w_trigger_done`
- `w_echo_done`
- `w_echo_timeout`
- `w_hold_state`

### 3. Trigger Generation

The `hs_sr04_trigger` module receives `w_start_trigger` and generates:

- `trig`
- `w_trigger_done`

This module is responsible for the 10 µs trigger pulse required by the HS-SR04 sensor.

### 4. Echo Capture

The `sr04_echo_capture` module receives:

- `echo`
- `w_start_trigger`

and generates:

- `w_echo_count[31:0]`
- `w_echo_done`
- `w_echo_timeout`

This is the timing-measurement core of the design.

### 5. Distance Conversion

The `distance_converter` module converts the captured counter value:

- input: `w_echo_count[31:0]`
- output: `w_distance_cm_raw[15:0]`

using the relation:

```text
distance_cm = echo_count / 5800
```

for a 100 MHz system clock.

### 6. Result Storage

The top-level module stores the latest valid measurement into:

- `r_distance_cm`
- `r_valid_meas`

This prevents invalid transient values from being displayed when no valid measurement is available.

### 7. Display Output

The `display_driver` module receives:

- `r_distance_cm`
- `r_valid_meas`
- `w_hold_state`

and drives:

- `seg[6:0]`
- `an[7:0]`
- `dp`

The display shows the measured distance and uses character-based indicators for hold and invalid states.

### 8. Buzzer Output

The `buzzer_control` module receives `r_distance_cm` and generates `w_buzzer_raw`.

At the top level:

```text
buzzer = r_valid_meas ? w_buzzer_raw : 1'b0
```

This means the buzzer is only active when a valid distance measurement exists.

---

## Hardware Connection and Pin Mapping

The board constraints file is:

- [`nexys.xdc`](vivado/ultrasonic_1.srcs/constrs_1/new/nexys.xdc)

### Pmod JA Assignments

| FPGA Signal | Pmod Pin | FPGA Package Pin | External Connection |
|---|---|---|---|
| `trig` | JA1 | `C17` | HS-SR04 `TRIG` |
| `echo` | JA2 | `D18` | HS-SR04 `ECHO` through level converter |
| `buzzer` | JA3 | `E18` | Buzzer input |

### Important Electrical Note

The Nexys A7 uses **3.3 V FPGA I/O**, while the HS-SR04 sensor uses **5 V power** and its `ECHO` signal can reach **5 V**. Therefore:

- `TRIG` is driven from FPGA to the sensor.
- `ECHO` must be passed through a **logic level converter** before being connected to the FPGA input.
- All devices must share a **common ground**.

---

## Physical Wiring Diagram

The physical interconnection between the FPGA board, the sensor, the buzzer, the logic level converter, and the external 5 V supply is documented below.

![Physical wiring schematic](images/physical_schematics.jpeg)

### Physical Connection Summary

| Device | Connection |
|---|---|
| HS-SR04 `VCC` | External 5 V supply |
| HS-SR04 `GND` | Common ground |
| HS-SR04 `TRIG` | Nexys JA1 / `trig` |
| HS-SR04 `ECHO` | Level converter HV side |
| Level converter LV side | Nexys JA2 / `echo` |
| Buzzer input | Nexys JA3 / `buzzer` |
| Buzzer ground | Common ground |
| Arduino `5V` | Sensor + level converter HV supply |
| Nexys `3.3V` | Level converter LV supply |

---

## Repository Structure

```text
Ultrasound-HS-SR04-BPA-DEL26-/
├── eda_simulation_tb_codes/
│   ├── buzzer_control_tb.v
│   ├── display_driver_tb.v
│   ├── distance_converter_tb.v
│   ├── hs_sr04_trigger_tb.v
│   ├── measurement_control_tb.v
│   ├── sr04_echo_capture_tb.v
│   └── ultrasonic_top_tb.v
│
├── images/
│   ├── README.md
│   ├── buzzer_control_eda_waveforms.png
│   ├── display_driver_eda_waveforms.png
│   ├── distance_converter_eda_waveforms.png
│   ├── hs_sr04_trigger_eda_waveforms.png
│   ├── measurement_control_eda_waveforms.png
│   ├── physical_schematics.jpeg
│   ├── schematics_top_level_ver3.png
│   ├── sr04_echo_capture_eda_waveforms.png
│   ├── top_level_eda_waveforms.png
│   ├── top_level_vivado_waveforms.jpeg
│   └── week_3_physical.jpeg
│
├── vivado/
│   ├── ultrasonic_1.srcs/
│   │   ├── constrs_1/new/
│   │   │   └── nexys.xdc
│   │   ├── sim_1/new/
│   │   │   ├── display_driver_tb.v
│   │   │   ├── distance_converter_tb.v
│   │   │   ├── hs_sr04_trigger_tb.v
│   │   │   ├── measurement_control_tb.v
│   │   │   ├── sr04_echo_capture_tb.v
│   │   │   └── ultrasonic_top_tb.v
│   │   └── sources_1/new/
│   │       ├── bin2seg.v
│   │       ├── buzzer_control.v
│   │       ├── clk_en.v
│   │       ├── counter.v
│   │       ├── debounce.v
│   │       ├── display_driver.v
│   │       ├── distance_converter.v
│   │       ├── hs_sr04_trigger.v
│   │       ├── measurement_control.v
│   │       ├── sr04_echo_capture.v
│   │       └── ultrasonic_top.v
│   └── ultrasonic_1.xpr
│
└── README.md
```

---

## Vivado Project Added to Git

The full Vivado project has been added to the repository, including:

- source files
- simulation files
- constraint file
- project file

### Main Vivado project file

- [`vivado/ultrasonic_1.xpr`](vivado/ultrasonic_1.xpr)

This directly addresses the feedback requesting that the **Vivado project be added to Git**.

---

## Source Modules

All implementation source files are stored under:

- [`vivado/ultrasonic_1.srcs/sources_1/new`](vivado/ultrasonic_1.srcs/sources_1/new)

### Module List

| Module | Description | Source |
|---|---|---|
| `bin2seg` | 4-bit binary to seven-segment decoder | [`bin2seg.v`](vivado/ultrasonic_1.srcs/sources_1/new/bin2seg.v) |
| `buzzer_control` | Distance-dependent buzzer controller | [`buzzer_control.v`](vivado/ultrasonic_1.srcs/sources_1/new/buzzer_control.v) |
| `clk_en` | Clock enable pulse generator | [`clk_en.v`](vivado/ultrasonic_1.srcs/sources_1/new/clk_en.v) |
| `counter` | Generic synchronous counter | [`counter.v`](vivado/ultrasonic_1.srcs/sources_1/new/counter.v) |
| `debounce` | Push-button debounce and edge detection | [`debounce.v`](vivado/ultrasonic_1.srcs/sources_1/new/debounce.v) |
| `display_driver` | Multiplexed seven-segment display controller | [`display_driver.v`](vivado/ultrasonic_1.srcs/sources_1/new/display_driver.v) |
| `distance_converter` | Echo count to centimeter conversion | [`distance_converter.v`](vivado/ultrasonic_1.srcs/sources_1/new/distance_converter.v) |
| `hs_sr04_trigger` | 10 µs trigger pulse generator | [`hs_sr04_trigger.v`](vivado/ultrasonic_1.srcs/sources_1/new/hs_sr04_trigger.v) |
| `measurement_control` | Main measurement-state controller | [`measurement_control.v`](vivado/ultrasonic_1.srcs/sources_1/new/measurement_control.v) |
| `sr04_echo_capture` | Echo pulse width measurement and timeout logic | [`sr04_echo_capture.v`](vivado/ultrasonic_1.srcs/sources_1/new/sr04_echo_capture.v) |
| `ultrasonic_top` | Top-level integration module | [`ultrasonic_top.v`](vivado/ultrasonic_1.srcs/sources_1/new/ultrasonic_top.v) |

---

## Testbench Files

The testbenches used for verification are provided separately for the EDA Playground environment and for the Vivado project environment.

### EDA Playground Testbenches

Stored under:

- [`eda_simulation_tb_codes`](eda_simulation_tb_codes)

| Testbench | Link |
|---|---|
| `buzzer_control_tb.v` | [`buzzer_control_tb.v`](eda_simulation_tb_codes/buzzer_control_tb.v) |
| `display_driver_tb.v` | [`display_driver_tb.v`](eda_simulation_tb_codes/display_driver_tb.v) |
| `distance_converter_tb.v` | [`distance_converter_tb.v`](eda_simulation_tb_codes/distance_converter_tb.v) |
| `hs_sr04_trigger_tb.v` | [`hs_sr04_trigger_tb.v`](eda_simulation_tb_codes/hs_sr04_trigger_tb.v) |
| `measurement_control_tb.v` | [`measurement_control_tb.v`](eda_simulation_tb_codes/measurement_control_tb.v) |
| `sr04_echo_capture_tb.v` | [`sr04_echo_capture_tb.v`](eda_simulation_tb_codes/sr04_echo_capture_tb.v) |
| `ultrasonic_top_tb.v` | [`ultrasonic_top_tb.v`](eda_simulation_tb_codes/ultrasonic_top_tb.v) |

### Vivado Testbenches

Stored under:

- [`vivado/ultrasonic_1.srcs/sim_1/new`](vivado/ultrasonic_1.srcs/sim_1/new)

| Testbench | Link |
|---|---|
| `display_driver_tb.v` | [`display_driver_tb.v`](vivado/ultrasonic_1.srcs/sim_1/new/display_driver_tb.v) |
| `distance_converter_tb.v` | [`distance_converter_tb.v`](vivado/ultrasonic_1.srcs/sim_1/new/distance_converter_tb.v) |
| `hs_sr04_trigger_tb.v` | [`hs_sr04_trigger_tb.v`](vivado/ultrasonic_1.srcs/sim_1/new/hs_sr04_trigger_tb.v) |
| `measurement_control_tb.v` | [`measurement_control_tb.v`](vivado/ultrasonic_1.srcs/sim_1/new/measurement_control_tb.v) |
| `sr04_echo_capture_tb.v` | [`sr04_echo_capture_tb.v`](vivado/ultrasonic_1.srcs/sim_1/new/sr04_echo_capture_tb.v) |
| `ultrasonic_top_tb.v` | [`ultrasonic_top_tb.v`](vivado/ultrasonic_1.srcs/sim_1/new/ultrasonic_top_tb.v) |

---

## Simulations and Verification

### EDA Playground Simulations

Because Vivado was not available on my personal PC outside the laboratory, I used an **online EDA simulator (EDA Playground)** for additional development and verification work outside lab hours. The module-level and top-level EDA simulation outputs can be accessed from the links below.

For a more detailed explanation of the screenshots in the `images` folder, see:

- [`images/README.md`](images/README.md)

Direct links to the EDA waveform images:

- [`buzzer_control_eda_waveforms.png`](images/buzzer_control_eda_waveforms.png)
- [`display_driver_eda_waveforms.png`](images/display_driver_eda_waveforms.png)
- [`distance_converter_eda_waveforms.png`](images/distance_converter_eda_waveforms.png)
- [`hs_sr04_trigger_eda_waveforms.png`](images/hs_sr04_trigger_eda_waveforms.png)
- [`measurement_control_eda_waveforms.png`](images/measurement_control_eda_waveforms.png)
- [`sr04_echo_capture_eda_waveforms.png`](images/sr04_echo_capture_eda_waveforms.png)
- [`top_level_eda_waveforms.png`](images/top_level_eda_waveforms.png)

These simulations were used to validate the behavior of the newly written modules before and during integration.

### Vivado Simulations

In addition to EDA Playground, the design was also simulated in **Vivado**. The new modules were checked in the Vivado project environment, and the **top-level module was finally simulated as an integrated system** before implementation.

The top-level Vivado simulation result is shown below.

![Top-level Vivado waveform](images/top_level_vivado_waveforms.jpeg)

This waveform confirms integrated top-level behavior, including:

- system clock operation
- push-button driven control behavior
- trigger generation
- echo interaction
- LED state changes
- display activity at top level

This directly addresses the feedback requesting that **simulations of the new modules** be added and documented.

---

## Weekly Development Progress

### Week 1

- The overall project idea and hardware goal were defined.
- The first top-level structure and initial project decomposition were planned.
- The first schematic/block-level representation was drafted.
- The general repository structure and implementation strategy were determined.

### Week 2

- The new custom modules were written and refined.
- The top-level integration structure was improved.
- The interconnection between trigger generation, echo capture, control FSM, conversion, display, and buzzer logic was completed.
- The updated schematic was prepared with clearer module-level interconnections and labeled signals.

### Week 3

- The top-level design and the new modules were simulated.
- Additional module-level verification was performed with EDA Playground outside the lab.
- The design was also checked in Vivado.
- The final bitstream was generated.
- The design was programmed onto the Nexys A7 board.
- Due to time limitations during the lab session, full final hardware testing with the connected external sensor and buzzer could not be completed.

---

## Initial Hardware Implementation

The generated bitstream was successfully loaded onto the Nexys A7-50T board. An initial physical check was performed on the board before the complete external sensor setup was connected.

![Initial hardware implementation](images/week_3_physical.jpeg)

At this stage:

- the FPGA design was synthesized and implemented successfully
- the board was programmed successfully
- the design could be observed running on the Nexys board
- full final sensor+buzzer integrated test could not be completed in the lab session because of limited remaining time

---

## Current Status

At the current repository stage, the project includes:

- complete HDL source code
- full Vivado project
- board constraints
- updated schematic with module I/O labels
- physical interconnection documentation
- EDA and Vivado testbench files
- EDA simulation evidence
- Vivado top-level simulation evidence
- initial hardware implementation evidence

The design is therefore documented not only at the code level, but also at the system, simulation, and hardware-verification levels.

---

## Conclusion

This project demonstrates a complete modular FPGA implementation of an ultrasonic distance meter using the HS-SR04 sensor on the Nexys A7-50T platform. The system was designed hierarchically, verified at module and top-level stages, and implemented on hardware. The repository has been organized to include the Vivado project, simulations, schematics, physical wiring information, and implementation evidence in a form suitable for laboratory documentation and evaluation.
