# Ultrasonic Distance Meter using HS-SR04 (FPGA - Nexys A7)

## Project Overview

This project was developed for the **Digital Electronics course (BPA-DEL), Spring 2025/26**, at **Brno University of Technology**.

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
``` 
The display_driver module drives the multiplexed 8-digit 7-segment display. It receives the stored distance value and displays the result using active-low segment and anode outputs.

The buzzer_control module creates a proximity alert. Larger distances keep the buzzer off or slow, while shorter distances increase the warning rate. Very close distances result in continuous buzzer activation.

## Top-Level Module I/O Description

### Inputs

| Signal | Description |
|------|------------|
| clk | 100 MHz system clock |
| btnu | Reset signal, active high |
| btnd | Hold mode button |
| echo | Echo signal from ultrasonic sensor |

### Outputs

| Signal | Description |
|------|------------|
| trig | Trigger signal to ultrasonic sensor |
| buzzer | Buzzer output |
| seg[6:0] | 7-segment display cathodes |
| an[7:0] | 7-segment display anodes |
| dp | Decimal point |
| led[3:0] | Status indicators |

### LED Mapping

| LED | Meaning |
|-----|--------|
| LED0 | Measuring active |
| LED1 | Hold mode active |
| LED2 | Valid measurement |
| LED3 | Timeout occurred |

## Module Implementation

All modules are implemented inside the Vivado project and connected hierarchically.

| Module | Function | Source |
|---|---|---|
| ultrasonic_top | Top-level integration of all modules and external FPGA I/O | ultrasonic_top.v |
| hs_sr04_trigger | Generates 10 µs trigger pulse for the ultrasonic sensor | hs_sr04_trigger.v |
| sr04_echo_capture | Measures echo pulse duration and detects timeout | sr04_echo_capture.v |
| distance_converter | Converts measured echo cycles to distance in centimeters | distance_converter.v |
| measurement_control | FSM controlling trigger, echo waiting, hold mode, and valid-data generation | measurement_control.v |
| display_driver | Drives the multiplexed 8-digit 7-segment display | display_driver.v |
| buzzer_control | Generates distance-based buzzer warning behavior | buzzer_control.v |
| debounce | Removes mechanical button noise from the hold button | debounce.v |
| clk_en | Generates slower clock-enable pulses from the 100 MHz clock | clk_en.v |
| counter | Parameterized synchronous counter used by display scanning and timing logic | counter.v |
| bin2seg | Converts 4-bit binary values to 7-segment display patterns | bin2seg.v |

## Simulation

Initial simulations were performed using an online EDA simulator because Vivado was not available on my personal computer outside the laboratory. These simulations were used for module-level debugging and verification before lab integration.

Detailed EDA simulation waveform screenshots are documented here:

images/README.md

The Vivado project also contains simulation testbenches for the new modules:

vivado/ultrasonic_1.srcs/sim_1/new/

EDA testbench source files are available here:

eda_simulation_tb_codes/

After module-level verification, the complete top-level design was simulated in Vivado.

## Top-Level Vivado Simulation

This simulation verifies that the integrated design generates the trigger signal, receives the echo response, updates status LEDs, and drives display-related outputs at the top level.

## Hardware Implementation

The complete Vivado 2025.2 project is included in the repository:

vivado/ultrasonic_1.xpr

The constraint file is available here:

nexys.xdc

The design was synthesized, implemented, and the bitstream was generated successfully. The bitstream was loaded onto the Nexys A7-50T FPGA board.

## Initial FPGA Test Without External Components

This test confirms that the FPGA configuration was loaded and the top-level design was active on the board. Due to time limitations, the external HS-SR04 sensor and buzzer could not be fully tested during the same lab session.

## Physical Connection Plan

The HS-SR04 sensor uses 5 V power, while Nexys A7 FPGA I/O uses 3.3 V logic. Therefore, the echo signal must be level shifted before entering the FPGA.

## Physical Wiring Schematic

| Connection | Description |
|---|---|
| Nexys JA1 / trig | Connected to HS-SR04 TRIG |
| HS-SR04 ECHO | Connected to level converter high-voltage side |
| Level converter low-voltage output | Connected to Nexys JA2 / echo |
| Nexys JA3 / buzzer | Connected to buzzer signal input |
| Arduino 5 V | Used as 5 V supply for HS-SR04 and high-voltage side of level converter |
| Nexys 3.3 V | Used for low-voltage side of level converter |
| Common GND | Shared between Nexys, Arduino, sensor, level converter, and buzzer |

The most important electrical constraint is that the 5 V ECHO output of the HS-SR04 must not be connected directly to the FPGA input pin.

## Weekly Progress

### Week 1
The project topic and system requirements were analyzed. The basic measurement principle of the HS-SR04 sensor was reviewed. The initial module hierarchy was planned, the first block diagram was created, and the repository/project organization was prepared.

### Week 2
The main custom Verilog modules were implemented. The trigger generation, echo capture, distance conversion, measurement control FSM, display driver, and buzzer logic were developed. The schematic was improved to show module-level interconnections more clearly.

### Week 3
The modules were tested using EDA Playground and Vivado simulations. The top-level module was integrated and simulated. The Vivado project was completed, synthesis and implementation were run, and the bitstream was generated. The FPGA was programmed successfully, but full testing with the external sensor and buzzer was not completed due to limited lab time.

## Project Status

| Requirement | Status |
|---|---|
| Module input/output names in schematic | Completed |
| Vivado project added to Git | Completed |
| Simulations of new modules | Completed and documented |
| Ultrasound module description | Completed |
| Ultrasound module functionality | Completed |
| Ultrasound module interconnection | Completed |
| Top-level Vivado simulation | Completed |
| Initial FPGA implementation | Completed |
| Full hardware test with sensor and buzzer | Planned / not completed due to time limitation |

## Conclusion

This project implements a hierarchical FPGA-based ultrasonic distance meter for the Nexys A7-50T board. The system includes trigger generation, echo timing measurement, distance conversion, FSM-based control, display output, buzzer feedback, and hardware constraints.

The repository now contains the updated schematic, Vivado project, source files, testbenches, simulation screenshots, physical wiring plan, and initial hardware implementation evidence. This provides a complete technical record of the design process and directly addresses the latest project feedback.
