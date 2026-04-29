# Ultrasonic Distance Meter using HS-SR04 (FPGA - Nexys A7)

## Project Overview

This project was developed for the **Digital Electronics course (BPA-DEL / BPC-DE1), Spring 2025/26**, at **Brno University of Technology**.

The project implements a complete ultrasonic distance measurement system using the HS-SR04 sensor on a Xilinx Nexys A7-50T FPGA board. The system measures distance, displays the result on a 7-segment display, and provides proximity feedback using a buzzer.

The design follows a hierarchical modular Verilog architecture, where each functional block is implemented as a separate module, individually simulated, and then integrated into the top-level system.

---

## System Architecture and Interconnection

The system is divided into measurement, processing, control, and output stages. The complete design is integrated inside the top-level module `ultrasonic_top`.

### Top-Level Schematic

![Top-Level Schematic](images/schematics_top_level_ver3.png)

The schematic shows the complete hierarchy of the project, including module input/output names, internal signals, bus widths, and the direction of signal flow. It was updated according to the feedback that module input/output names were missing.

The main external inputs are `clk`, `btnu`, `btnd`, and `echo`. The main external outputs are `trig`, `buzzer`, `seg[6:0]`, `an[7:0]`, `dp`, and `led[3:0]`.

The clock signal is distributed to all synchronous modules. The reset signal from `btnu` resets the system. The hold button `btnd` is first passed through the `debounce` module and then used by the measurement controller and display driver. The `echo` signal is captured by the echo measurement module, while the generated `trig` signal is sent to the ultrasonic sensor.

### System Signal Flow

The measurement process follows this sequence:

1. `measurement_control` starts a new measurement by generating `w_start_trigger`.
2. `hs_sr04_trigger` receives `w_start_trigger` and produces a 10 µs `trig` pulse.
3. When the trigger pulse is completed, `hs_sr04_trigger` asserts `w_trigger_done`.
4. `measurement_control` waits for the echo measurement result.
5. `sr04_echo_capture` observes the external `echo` input and measures its pulse width.
6. When echo capture is completed, `sr04_echo_capture` asserts `w_echo_done`.
7. The measured pulse width is transferred as `w_echo_count[31:0]`.
8. `distance_converter` converts `w_echo_count[31:0]` into `w_distance_cm_raw[15:0]`.
9. The top-level register stores the valid measurement as `r_distance_cm[15:0]`.
10. `display_driver` displays the stored distance value on the 7-segment display.
11. `buzzer_control` uses the stored distance value to generate proximity-based buzzer feedback.
12. `led[3:0]` shows debug/status information such as measuring, hold, valid measurement, and timeout.

### Main Internal Signals

| Signal | Width | Source | Destination | Purpose |
|---|---:|---|---|---|
| `w_hold_state` | 1 bit | `debounce` | `measurement_control`, `display_driver` | Debounced hold button state |
| `w_start_trigger` | 1 bit | `measurement_control` | `hs_sr04_trigger`, `sr04_echo_capture` | Starts a new ultrasonic measurement |
| `w_trigger_done` | 1 bit | `hs_sr04_trigger` | `measurement_control` | Indicates that the 10 µs trigger pulse is complete |
| `w_echo_done` | 1 bit | `sr04_echo_capture` | `measurement_control`, `ultrasonic_top` | Indicates that echo pulse measurement is complete |
| `w_echo_timeout` | 1 bit | `sr04_echo_capture` | `measurement_control`, `ultrasonic_top`, `led[3]` | Indicates no valid echo was received before timeout |
| `w_echo_count[31:0]` | 32 bits | `sr04_echo_capture` | `distance_converter` | Raw echo pulse width measured in clock cycles |
| `w_distance_cm_raw[15:0]` | 16 bits | `distance_converter` | `ultrasonic_top` register logic | Converted distance value before storage |
| `r_distance_cm[15:0]` | 16 bits | `ultrasonic_top` register logic | `display_driver`, `buzzer_control` | Stored stable distance value |
| `r_valid_meas` | 1 bit | `ultrasonic_top` register logic | `display_driver`, buzzer enable logic, `led[2]` | Indicates that stored distance is valid |
| `w_measuring` | 1 bit | `measurement_control` | `led[0]` | Shows active measurement status |
| `w_buzzer_raw` | 1 bit | `buzzer_control` | `ultrasonic_top` buzzer gating logic | Raw buzzer output before valid-data gating |

### Functional Block Description

The `debounce` module filters the mechanical noise of the hold button. Its output `w_hold_state` is used instead of the raw button input so that the controller does not react to short bouncing transitions.

The `measurement_control` module is the main FSM of the system. It controls when a measurement starts, waits for trigger completion, waits for echo completion, handles hold mode, and generates status outputs.

The `hs_sr04_trigger` module generates the sensor trigger pulse. At 100 MHz, one clock cycle is 10 ns, so a 10 µs pulse requires 1000 clock cycles.

The `sr04_echo_capture` module measures the high-time of the `echo` input. It uses edge detection and a counter to determine how long the echo signal remains high. It also includes timeout protection so the system cannot get stuck if no echo is received.

The `distance_converter` module converts the raw echo count into centimeters. At 100 MHz, the approximate conversion used is:

```text
distance_cm = echo_count / 5800
