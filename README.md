# Ultrasound-HS-SR04-BPA-DEL26-
FPGA-based ultrasonic distance meter using HC-SR04 sensor, echo timing with counters, and 7-segment display (Verilog, Nexys A7-50T).
# Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T

This project is developed for the **Digital Electronics** course at **Brno University of Technology** in the academic year **2025/26**.

## Project Topic

**6. Ultrasound HS-SR04**

The goal of this project is to measure distance using the **HC-SR04 / HS-SR04 ultrasonic sensor** and display the measured value on the **seven-segment display** of the **Nexys A7-50T FPGA board**.

The design is implemented in **Verilog** using a **hierarchical structure** and reuses standard course modules such as `counter`, `debounce`, `bin2seg`, and `display_driver`, together with new project-specific modules for ultrasonic triggering, echo measurement, and distance conversion.

---

## Problem Description

The ultrasonic sensor measures distance by transmitting a short ultrasonic pulse and receiving its echo reflected from an object. The FPGA generates a trigger pulse, measures the duration of the echo signal, and converts this measured pulse width into a distance-related value. The result is then shown on the onboard seven-segment display.

This project combines:
- digital timing generation,
- pulse-width measurement,
- synchronous sequential design,
- display driving,
- modular Verilog design,
- FPGA implementation on real hardware.

---

## Project Objectives

After completing the project, the system should be able to:

- generate a correct trigger pulse for the ultrasonic sensor,
- detect and measure the width of the echo pulse,
- calculate or approximate the measured distance,
- display the measured value on the Nexys A7 seven-segment display,
- support reset and optional user control using push buttons,
- operate reliably on the Nexys A7-50T FPGA board.

---

## Roles (Architecture Phase)

- Malekimoghaddam Niloofar  
  System architecture, top-level design, documentation

- Onaran Yusuf Çetin  
  Sensor interface, echo capture, simulation and testbench

## Hardware Platform

- **FPGA board:** Digilent Nexys A7-50T
- **Sensor:** HC-SR04 / HS-SR04 ultrasonic distance sensor
- **Display:** Onboard 7-segment display
- **Inputs:** Push buttons for reset / optional control
- **Clock:** 100 MHz onboard oscillator

> Note: External sensor connections must respect FPGA I/O voltage limits. Proper level shifting or safe interfacing is required for the sensor signals. So we will use level shifter for the project. 

---

## Planned Design Structure

The project follows a **hierarchical design** approach.

### Top-level module
- `ultrasonic_top`

### Reused course modules
- `counter`
- `debounce`
- `bin2seg`
- `display_driver`
- `clk_en` (if needed)

### New project-specific modules
- `hs_sr04_trigger`
- `hs_sr04_echo_capture`
- `distance_converter`
- `measurement_control` *(optional, depending on final architecture)*

---

## Block Diagram

The preliminary architecture of the project is:

