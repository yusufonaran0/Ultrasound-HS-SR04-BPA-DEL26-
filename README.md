# Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T

This project is developed for the **Digital Electronics** course at **Brno University of Technology** in the academic year **2025/26**.

---

## Project Overview

The goal of this project is to design and implement a **real-time distance measurement system** using the **HC-SR04 / HS-SR04 ultrasonic sensor** and an **FPGA-based architecture** on the **Nexys A7-50T board**.

The system performs:
- Generation of a **10 µs trigger pulse**
- Measurement of the **echo pulse width**
- Conversion of measured time into **distance**
- Display of distance on **7-segment display**
- Distance-based **buzzer feedback** (parking sensor behavior)

The design is implemented in **Verilog** using a **hierarchical modular structure**, consistent with the course laboratory methodology.

---

## Problem Description

Ultrasonic distance measurement is based on the **time-of-flight principle**:

1. A short ultrasonic pulse is transmitted  
2. The signal reflects from an object  
3. The echo returns to the sensor  
4. The elapsed time is proportional to distance  

The FPGA:
- generates the trigger signal,
- measures the echo duration,
- converts the result into a distance value,
- and drives visual and audio outputs.

This project integrates:
- digital timing,
- pulse-width measurement,
- synchronous design,
- modular FPGA architecture,
- real hardware interfacing.

---

## System Features

- ✔ Automatic continuous measurement  
- ✔ Push-button control:
  - **Reset (btnu)**
  - **Hold (btnd)** (freeze current value)  
- ✔ Real-time display on 7-segment  
- ✔ Distance-based buzzer feedback  
- ✔ LED indicators for system status  
- ✔ Fully modular Verilog design  

---

## Hardware Platform

- **FPGA board:** Digilent Nexys A7-50T  
- **Sensor:** HC-SR04 / HS-SR04 ultrasonic sensor  
- **Display:** Onboard 7-segment display  
- **Inputs:** Push buttons (reset, hold)  
- **Clock:** 100 MHz onboard oscillator  
- **Output:** Buzzer  

> ⚠️ Note: The ultrasonic sensor uses 5V logic. A **level shifter** must be used for safe FPGA interfacing (3.3V).

---

## System Architecture

The design follows a **hierarchical modular architecture**.

### Top-level module
- `ultrasonic_top`

### Reused course modules
- `counter`
- `debounce`
- `bin2seg`
- `display_driver`
- `clk_en` (if required)

### Custom modules
- `measurement_control` → system control (start / hold / reset)
- `hs_sr04_trigger` → 10 µs trigger generation
- `sr04_echo_capture` → echo pulse width measurement
- `distance_converter` → count → distance conversion
- `buzzer_control` → distance-based audio feedback

---

## Block Diagram

![Block Diagram](https://drive.google.com/file/d/1sXd2ZUvNd_3MqlbyOKLJz7B38QFzU9a_/view?usp=sharing)

---

## Signal Flow Description

### Control Path
- `btnd → debounce → measurement_control`
- `btnu → measurement_control (reset)`

### Measurement Path
- `measurement_control → hs_sr04_trigger → trig`
- `echo → sr04_echo_capture`
- `sr04_echo_capture → distance_converter`

### Output Path
- `distance_converter → display_driver → seg, an, dp`
- `distance_converter → buzzer_control → buzzer`

### Status Output
- `measurement_control → led[3:0]`

---

## Design Methodology

- ✔ Hierarchical design  
- ✔ Separation of control and data paths  
- ✔ Synchronous design (clocked logic)  
- ✔ Reusable modules  
- ✔ Simulation before integration  
- ✔ No latches (verified after synthesis)  

---

## Project Plan

- **Lab 1:** Architecture, block diagram, Git setup  
- **Lab 2:** Module design + testbench  
- **Lab 3:** Integration + synthesis  
- **Lab 4:** Debugging + optimization  
- **Lab 5:** Final demo + defense  

---

## Team Members

- **Malekimoghaddam Niloofar**  
  System architecture, top-level design, documentation  

- **Onaran Yusuf Çetin**  
  Sensor interface, echo capture, simulation and verification  
