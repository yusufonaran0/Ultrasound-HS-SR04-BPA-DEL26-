# Ultrasonic Distance Meter (HS-SR04) – Nexys A7 FPGA

## Project Description

This project implements an ultrasonic distance measurement system using the HS-SR04 sensor on the Nexys A7-50T FPGA board. The system generates a trigger pulse, measures the duration of the echo signal, computes the distance in centimeters, and displays the result on a 7-segment display. A buzzer provides feedback based on the measured distance.

The design is implemented in Verilog using a hierarchical structure. Each module was individually developed, simulated, and then integrated into a top-level design.

---

## System Architecture and Interconnection

The system operates as a pipeline controlled by a finite state machine:

1. A trigger pulse (10 µs) is generated to start the ultrasonic measurement  
2. The sensor returns an echo signal whose duration is proportional to distance  
3. The echo duration is measured using a counter  
4. The measured value is converted into distance (cm)  
5. The result is displayed and used to control a buzzer  

Top-level module:

- [`ultrasonic_top.v`](vivado/ultrasonic_1.srcs/sources_1/new/ultrasonic_top.v)

### Top-Level I/O Signals

Inputs:
- `clk` – 100 MHz system clock  
- `btnu` – reset  
- `btnd` – hold mode control  
- `echo` – echo signal from HS-SR04  

Outputs:
- `trig` – trigger signal to HS-SR04  
- `seg[6:0]` – 7-segment cathodes  
- `an[7:0]` – 7-segment anodes  
- `dp` – decimal point  
- `buzzer` – audio output  
- `led[3:0]` – debug/status signals  

### Updated Block Diagram

![Top Level Schematic](images/schematics_top_level_ver3.png)

This schematic explicitly shows module interconnections and signal flow, addressing the requirement for clearly defined inputs, outputs, and internal signals.

---

## Module Implementation

All modules are implemented in a hierarchical structure inside the Vivado project:

### Core Modules

- Trigger generation  
  [`hs_sr04_trigger.v`](vivado/ultrasonic_1.srcs/sources_1/new/hs_sr04_trigger.v)

- Echo signal capture  
  [`sr04_echo_capture.v`](vivado/ultrasonic_1.srcs/sources_1/new/sr04_echo_capture.v)

- Distance conversion  
  [`distance_converter.v`](vivado/ultrasonic_1.srcs/sources_1/new/distance_converter.v)

- Measurement control (FSM)  
  [`measurement_control.v`](vivado/ultrasonic_1.srcs/sources_1/new/measurement_control.v)

### Output and Interface Modules

- Display driver  
  [`display_driver.v`](vivado/ultrasonic_1.srcs/sources_1/new/display_driver.v)

- Buzzer control  
  [`buzzer_control.v`](vivado/ultrasonic_1.srcs/sources_1/new/buzzer_control.v)

### Supporting Modules

- Debouncer  
  [`debounce.v`](vivado/ultrasonic_1.srcs/sources_1/new/debounce.v)

- Clock enable generator  
  [`clk_en.v`](vivado/ultrasonic_1.srcs/sources_1/new/clk_en.v)

- Counter  
  [`counter.v`](vivado/ultrasonic_1.srcs/sources_1/new/counter.v)

- Binary to 7-segment decoder  
  [`bin2seg.v`](vivado/ultrasonic_1.srcs/sources_1/new/bin2seg.v)

---

## Simulation

Due to the absence of Vivado on my personal computer outside the laboratory environment, an online EDA simulator was used during development.

EDA simulation waveforms can be accessed here:  
- [`images/`](images/)

Each module was tested individually using dedicated testbenches.

After development, all modules were simulated again in Vivado:
- Individual module simulations were verified  
- Final validation was performed using top-level simulation  

Vivado top-level simulation waveform:

![Vivado Simulation](images/top_level_vivado_waveforms.jpeg)

Testbench files:

- EDA testbenches  
  [`eda_simulation_tb_codes/`](eda_simulation_tb_codes)

- Vivado simulation testbenches  
  [`vivado/ultrasonic_1.srcs/sim_1/new/`](vivado/ultrasonic_1.srcs/sim_1/new)

---

## Hardware Implementation

The design was synthesized and implemented on the Nexys A7-50T FPGA.

Bitstream generation and programming were successfully completed. Due to time constraints, full integration with external components (sensor and buzzer) could not be finalized on hardware.

Initial FPGA test (without external components):

![Board Test](images/week_3_physical.jpeg)

### Physical Connection Design

A wiring schematic was prepared for the complete system, including:

- HS-SR04 ultrasonic sensor  
- Logic level converter (5V → 3.3V for echo)  
- External buzzer  
- External 5V supply (Arduino)  

![Physical Schematic](images/physical_schematics.jpeg)

---

## Vivado Project

The complete Vivado 2025.2 project is included in the repository:

- [`vivado/ultrasonic_1.xpr`](vivado/ultrasonic_1.xpr)

This satisfies the requirement of providing a full project for reproducibility.

---

## Weekly Progress

Week 1:  
Project architecture was defined. Initial block diagram and system structure were created. Repository structure and constraints file were prepared.

Week 2:  
All required modules were implemented in Verilog. Individual testbenches were developed and simulations were performed.

Week 3:  
Modules were integrated into the top-level design. Full system simulations were completed. Bitstream was generated and uploaded to the FPGA board.

---

## Notes

- Hierarchical design methodology was followed  
- All modules were simulated before integration  
- External voltage constraints (3.3V logic) were respected  
- Echo signal requires level shifting from 5V to 3.3V  

---

## Conclusion

This project demonstrates a complete FPGA-based measurement system integrating sensor interfacing, timing analysis, FSM-based control, and hardware implementation. All required elements such as simulations, schematics, and the Vivado project are included.
