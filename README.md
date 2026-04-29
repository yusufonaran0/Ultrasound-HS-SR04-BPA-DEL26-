# Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T

This project was developed for the **Digital Electronics** course at **Brno University of Technology (2025/26)**.

The objective is to design and implement a **fully synchronous FPGA-based ultrasonic distance measurement system** using the **HS-SR04 ultrasonic sensor** on the **Nexys A7-50T FPGA board**, following a **modular and hierarchical Verilog design methodology**.

---

## System Principle

The system operates based on the **time-of-flight (ToF)** principle.

After receiving a trigger pulse, the ultrasonic sensor emits a sound wave. This wave reflects from an object and returns to the sensor, generating an echo signal whose width is proportional to the distance.

The distance is calculated as:

d = (v × t) / 2

Where v ≈ 343 m/s and t is the echo duration. The FPGA measures t in clock cycles and converts it into centimeters.

---

## System Architecture

The design is fully synchronous and operates using a **single 100 MHz clock domain**.

The system is divided into four subsystems:

**Control Unit**  
Implemented in `measurement_control` as an FSM. Handles trigger generation, sequencing and hold mode.

**Measurement Unit**  
- `hs_sr04_trigger`: generates 10 µs pulse  
- `sr04_echo_capture`: measures echo pulse width  

**Data Processing Unit**  
- `distance_converter`: converts cycles to centimeters  

**Output Unit**  
- `display_driver`: multiplexed 7-segment display  
- `buzzer_control`: distance-based acoustic feedback  
- LEDs: system status  

---

## Module Interconnection

The system data flow is:

measurement_control → hs_sr04_trigger → sr04_echo_capture → distance_converter → display_driver / buzzer_control

Signal behavior:

- `start_trigger` starts measurement  
- `echo_done` completes measurement  
- `echo_count` carries measured time  
- `distance_cm` stores computed distance  
- `valid_meas` indicates valid result  
- `hold` freezes output  

---

## Top-Level Module Interface

### ultrasonic_top

| Signal | Direction | Width | Description |
|--------|----------|-------|------------|
| clk | input | 1 | 100 MHz system clock |
| btnu | input | 1 | Reset |
| btnd | input | 1 | Hold button |
| echo | input | 1 | Echo signal |
| trig | output | 1 | Trigger |
| buzzer | output | 1 | Buzzer |
| seg | output | 7 | 7-segment cathodes |
| an | output | 8 | 7-segment anodes |
| dp | output | 1 | Decimal point |
| led | output | 4 | Status LEDs |

---

## Module Overview

| Module | Description | Source |
|--------|------------|--------|
| bin2seg | Binary to 7-segment decoder | vivado/ultrasonic_1.srcs/sources_1/new/bin2seg.v |
| clk_en | Clock enable generator | vivado/ultrasonic_1.srcs/sources_1/new/clk_en.v |
| counter | Synchronous counter | vivado/ultrasonic_1.srcs/sources_1/new/counter.v |
| debounce | Button debouncing | vivado/ultrasonic_1.srcs/sources_1/new/debounce.v |
| hs_sr04_trigger | Trigger generator | vivado/ultrasonic_1.srcs/sources_1/new/hs_sr04_trigger.v |
| sr04_echo_capture | Echo measurement | vivado/ultrasonic_1.srcs/sources_1/new/sr04_echo_capture.v |
| distance_converter | Distance calculation | vivado/ultrasonic_1.srcs/sources_1/new/distance_converter.v |
| measurement_control | FSM controller | vivado/ultrasonic_1.srcs/sources_1/new/measurement_control.v |
| display_driver | 7-segment driver | vivado/ultrasonic_1.srcs/sources_1/new/display_driver.v |
| buzzer_control | Buzzer logic | vivado/ultrasonic_1.srcs/sources_1/new/buzzer_control.v |
| ultrasonic_top | Top-level module | vivado/ultrasonic_1.srcs/sources_1/new/ultrasonic_top.v |

---

## Schematics

### Top-Level Schematic
![Top-Level](images/schematics_top_level_ver3.png)

### Physical Wiring
![Physical](images/physical_schematics.jpeg)

---

## Simulation

Since Vivado was not always available on the personal machine, an online EDA simulator was used during development.

EDA simulation testbenches are available in:
eda_simulation_tb_codes/

All modules were tested individually using the EDA simulator.

Afterwards, all modules were re-simulated in Vivado, and the full system was verified at the top level.

### Top-Level Simulation (Vivado)
![Top-Level Simulation](images/top_level_vivado_waveforms.jpeg)

Console output:

echo_count  = 5801  
raw_dist    = 1  
stored_dist = 1  
valid_meas  = 1  
led         = 0101  
PASS: ultrasonic_top measured 1 cm correctly  
PASS: hold mode active  

---

## Hardware Considerations

The ultrasonic sensor operates at 5V while FPGA uses 3.3V.

A level shifting interface is required for the echo signal.

---

## LED Indicators

| LED | Function |
|-----|---------|
| LED0 | Measurement active |
| LED1 | Hold mode active |
| LED2 | Valid measurement |
| LED3 | Timeout detected |

---

## Project Progress

### Week 1
- System architecture defined  
- Initial schematic created  
- Project structure planned  

### Week 2
- All modules implemented  

### Week 3
- Module simulations completed  
- Top-level integration verified  
- Bitstream generated  
- FPGA programmed  

---

## FPGA Implementation

The design was synthesized and implemented in Vivado.

Bitstream was successfully generated and uploaded.

Due to time constraints, full hardware testing with connected components was not completed.

![FPGA](images/week_3_physical.jpeg)

---

## Design Features

- Fully synchronous design  
- Single clock domain  
- No inferred latches  
- Modular architecture  
- Clean separation of datapath and control  

---

## Testbenches

EDA testbenches: eda_simulation_tb_codes/  
Vivado testbenches: vivado/ultrasonic_1.srcs/sim_1/new/

---

## Conclusion

The project successfully demonstrates a complete FPGA-based ultrasonic distance measurement system.

All modules were verified individually, and full system integration was validated through top-level simulation.
