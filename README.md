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
