# Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T

This project was developed as part of the **BPA-DEL (Digital Electronics)** course at Brno University of Technology in the 2025/2026 academic year by Yusuf Çetin ONARAN and  Niloofar Malekimoghaddam. The goal of the project is to design and implement a real-time distance measurement system using an ultrasonic sensor on an FPGA platform.

The system utilizes the **HS-SR04 ultrasonic sensor** to measure the distance to an object based on the Time-of-Flight (ToF) principle. The measured distance is processed on the **Nexys A7-50T FPGA**, displayed on 7-segment displays, and used to control a buzzer for proximity indication. The design follows a modular and fully synchronous architecture implemented in Verilog.



## Background: Time-of-Flight Principle

Time-of-Flight (ToF) is a distance measurement method based on calculating the travel time of a wave between a transmitter and a receiver. In ultrasonic sensing systems, high-frequency sound waves are emitted, reflected from an object, and received back by the sensor.

The HC-SR04 ultrasonic module operates using this principle. It emits an ultrasonic pulse at approximately 40 kHz and measures the time required for the echo signal to return.

The fundamental relationship used for distance calculation is:

Distance formula:

    distance = (v × t) / 2

where:
- v = speed of sound
- t = echo round-trip time

The division by 2 is required because the signal travels to the object and back.

In this project, the FPGA measures the duration of the ECHO signal in clock cycles. Given a system clock frequency of 100 MHz:

The measured time is derived from the echo counter value:

    t = echo_count / (100 × 10^6)

Based on this, the distance can be approximated in centimeters as:

    distance_cm ≈ echo_count / 5800

This approximation is used in the `distance_converter` module for efficient hardware implementation.

### Ultrasonic Measurement Principle

<p align="center">
  <img src="images/ultrasonic_sensing_principle.png" width="600"/>
</p>
This figure [1] illustrates the propagation of ultrasonic waves from the sensor to an object and back. The distance is calculated based on the time difference between the transmitted and received signals.


### HC-SR04 Timing Diagram

<p align="center">
  <img src="images/ultrasonic_timing_principle.jpg" width="600"/>
</p>

The timing diagram [2] shows the required 10 µs trigger pulse and the corresponding echo pulse width, which directly encodes the measured distance.

This method provides a simple, low-cost, and robust solution for real-time distance measurement in embedded systems. 


## Project Description

The objective of this project is to design and implement a real-time distance measurement system using the **HS-SR04 ultrasonic sensor** and an FPGA platform.

The system operates by generating a trigger pulse, capturing the duration of the returned echo signal, and converting this time measurement into distance using a hardware-efficient approximation. The computed distance is then displayed on the **7-segment display** of the Nexys A7-50T board.

In addition to distance visualization, the system includes a **buzzer control mechanism** that provides proximity-based feedback, where the buzzer frequency increases as the measured distance decreases. A **hold function** is also implemented using a debounced push-button input, allowing the user to freeze the last valid measurement on the display. 



The design follows a **modular and hierarchical architecture**, where each functional block (trigger generation, echo capture, distance conversion, display control, and system control) is implemented as an independent Verilog module. The entire system is designed using a **single synchronous clock domain (100 MHz)**, avoiding the use of derived clocks and preventing unintended latch inference.

All modules are verified through simulation before integration, and the complete system is synthesized and implemented on the FPGA, ensuring correct operation in both simulation and real hardware.

## System Architecture and Dataflow

The system is designed using a modular and hierarchical architecture. The following block diagram illustrates the high-level structure and signal flow between modules.

<p align="center">
  <img src="images/schematics_top_level_ver3.png" width="700"/>
</p>

This diagram presents a simplified view of the system, focusing on the main functional blocks and their interactions.


The view of internal signal connections and synthesized logic, the Vivado-generated dataflow schematic is shown below.

<p align="center">
  <img src="images/dataflow_schematics_vivado.jpeg" width="700"/>
</p>

The overall dataflow of the system is as follows:

1. **Trigger Generation**  
   The `hs_sr04_trigger` module generates a 10 µs pulse.

2. **Echo Capture**  
   The `sr04_echo_capture` module measures echo duration using a counter.

3. **Distance Conversion**  
   The `distance_converter` computes distance in centimeters.

4. **Control Logic**  
   The `measurement_control` module coordinates the process.

5. **Output Stage**  
   - `display_driver` → 7-segment output  
   - `buzzer_control` → audio feedback  
   - `debounce` → stable button input


## Module Interconnection

This section describes the signal-level connections between modules and how data propagates through the system during operation.

At the core of the design is a synchronous pipeline driven by the 100 MHz system clock. All modules operate within the same clock domain to ensure timing consistency and avoid metastability issues.

### Signal Flow Overview

The interconnection between modules follows a structured sequence:

1. **Trigger Control Path**
   - The `measurement_control` module generates the `start_trigger` signal.
   - This signal is connected to the `hs_sr04_trigger` module.
   - The trigger module outputs a `trig` pulse to the ultrasonic sensor and asserts a `trigger_done` signal upon completion.

2. **Echo Measurement Path**
   - The ultrasonic sensor returns an `echo` signal.
   - This signal is fed into the `sr04_echo_capture` module.
   - The module measures the duration of the echo pulse and produces:
     - `echo_count[31:0]` → raw measurement value  
     - `echo_done` → indicates successful measurement  
     - `echo_timeout` → indicates no echo received within time limit  

3. **Distance Calculation Path**
   - The `echo_count[31:0]` signal is passed to the `distance_converter` module.
   - The converter computes the distance in centimeters:
     - `distance_cm[15:0]`

4. **Control Feedback Loop**
   - The `measurement_control` module receives:
     - `trigger_done`
     - `echo_done`
     - `echo_timeout`
   - Based on these signals, it transitions between measurement states and controls the measurement cycle.

5. **Data Latching and Hold Function**
   - The `debounce` module processes the push-button input (`btnd`) to eliminate noise.
   - The debounced signal (`hold_active`) determines whether the displayed value should be updated or frozen.
   - A register stage stores the last valid `distance_cm` value when hold is active.

6. **Output Stage**
   - The `distance_cm[15:0]` signal is distributed to:
     - `display_driver` → drives `seg[6:0]`, `an[7:0]`, `dp`
     - `buzzer_control` → generates `buzzer` output based on distance thresholds

### Design Characteristics

- **Single Clock Domain:**  
  All modules are synchronized using the same clock signal (`clk`), avoiding clock domain crossing issues.

- **Handshake-Based Control:**  
  The system uses control signals (`trigger_done`, `echo_done`, `echo_timeout`) to ensure proper sequencing of operations.

- **Modular Design:**  
  Each module is independent and testable, enabling easier debugging and simulation.

- **Pipeline Dataflow:**  
  Data flows sequentially from measurement → processing → output without unnecessary feedback loops.

This structured interconnection ensures reliable operation, clear signal propagation, and maintainable system design.


## Top-Level Interface

The `ultrasonic_top` module represents the top-level entity of the system. It connects the FPGA board inputs/outputs with all internal modules.

### Port Description

| Signal Name | Direction | Width | Description |
|------------|----------|-------|------------|
| `clk`      | Input    | 1     | 100 MHz system clock |
| `btnu`     | Input    | 1     | Reset button (active-high) |
| `btnd`     | Input    | 1     | Hold button (freeze displayed value) |
| `echo`     | Input    | 1     | Echo signal from HC-SR04 sensor |
| `trig`     | Output   | 1     | Trigger pulse to HC-SR04 sensor |
| `seg[6:0]` | Output   | 7     | 7-segment display segments (active-low) |
| `an[7:0]`  | Output   | 8     | 7-segment display digit enable (active-low) |
| `dp`       | Output   | 1     | Decimal point (not used, kept inactive) |
| `buzzer`   | Output   | 1     | Audio feedback output |
| `led[3:0]` | Output   | 4     | Status/debug LEDs |

### Interface Description

- **Clock Input (`clk`)**  
  The entire system operates synchronously using the onboard 100 MHz clock of the Nexys A7-50T FPGA.

- **Control Inputs (`btnu`, `btnd`)**  
  - `btnu` resets the system and initializes all modules.  
  - `btnd` activates the hold function, freezing the displayed distance.

- **Ultrasonic Sensor Interface (`trig`, `echo`)**  
  - `trig` sends a 10 µs pulse to start measurement.  
  - `echo` receives the reflected signal from the object.

- **Display Outputs (`seg`, `an`, `dp`)**  
  These signals drive the 8-digit 7-segment display using time-multiplexing.

- **Buzzer Output (`buzzer`)**  
  Generates sound based on distance thresholds (closer object → faster beeping).

- **LED Outputs (`led`)**  
  Used for debugging and indicating system states (e.g., measuring, valid data, hold mode).

### Design Note

All external signals are mapped to FPGA pins using the provided `.xdc` constraints file:

- [nexys.xdc](vivado/ultrasonic_1.srcs/constrs_1/new/nexys.xdc)

This ensures correct physical mapping between the FPGA and external peripherals on the Nexys A7-50T board. 

 
