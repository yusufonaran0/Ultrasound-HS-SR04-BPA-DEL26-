# Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T

This project is developed for the **Digital Electronics** course at **Brno University of Technology (2025/26)**.

The objective of this project is to design and implement a **fully synchronous FPGA-based ultrasonic distance measurement system** using the **HC-SR04 / HS-SR04 sensor** on the **Nexys A7-50T board**, following a **modular and hierarchical Verilog design methodology**.

The system performs real-time distance measurement by generating a trigger signal, capturing the returning echo pulse, and converting the measured time interval into a distance value, which is displayed on the onboard **multiplexed 7-segment display**.

---

## System Principle

The ultrasonic sensor operates based on the **time-of-flight (ToF)** principle.

1. A **10 µs trigger pulse** is applied to the sensor.
2. The sensor emits an ultrasonic burst (≈40 kHz).
3. The signal is reflected from an object and received back.
4. The sensor outputs a digital **echo signal**, whose pulse width is proportional to the travel time of the wave.

The measured time \( t \) is related to distance \( d \) by:

\[
d = \frac{v_{sound} \cdot t}{2}
\]

where:
- \( v_{sound} \approx 343 \, \text{m/s} \)
- division by 2 accounts for the round trip

In this implementation, the FPGA measures the **echo pulse width in clock cycles**, and the result is scaled to produce a distance representation suitable for display.

---

## System Architecture

The design follows a **hierarchical RTL architecture**, where each subsystem is implemented as an independent module and integrated in the top-level entity `ultrasonic_top`.

The architecture is divided into three main subsystems:

### 1. Control Subsystem

The control logic is responsible for:
- system initialization,
- measurement triggering,
- user interaction handling,
- synchronization of data flow between modules.

Push buttons are processed using a **debounce module**, eliminating metastability and mechanical bouncing effects. The processed signals are used to generate control signals such as:
- `start_meas`
- `hold_en`
- `reset`

The control unit ensures that:
- measurements are periodically triggered,
- results are latched during hold mode,
- invalid states are avoided.

---

### 2. Measurement Subsystem

This subsystem interfaces directly with the ultrasonic sensor and performs precise timing measurement.

#### Trigger Generator (`hs_sr04_trigger`)
- Generates a **10 µs pulse** using a counter-based timing mechanism.
- Operates synchronously with the system clock (100 MHz).
- Ensures correct sensor activation timing.

#### Echo Capture (`hs_sr04_echo_capture`)
- Detects rising and falling edges of the echo signal.
- Measures pulse width using a **high-resolution counter**.
- Includes timeout protection to avoid system blocking when no echo is received.

The measured value is represented as:
\[
\text{echo\_count} = \frac{t_{echo}}{T_{clk}}
\]

where \( T_{clk} = 10 \, \text{ns} \) (100 MHz clock).

---

### 3. Data Processing and Output Subsystem

#### Distance Converter (`distance_converter`)
- Converts raw counter values into scaled distance units.
- Uses integer arithmetic to approximate physical distance without floating-point operations.
- Designed to balance accuracy and FPGA resource usage.

#### Display Driver (`display_driver + bin2seg`)
- Implements **time-multiplexed control** of the 8-digit 7-segment display.
- Converts binary values into segment patterns.
- Ensures flicker-free visualization using a clock enable module.

#### Buzzer Control (`buzzer_control`)
- Generates an audible signal whose frequency or repetition rate depends on measured distance.
- Implements a **proximity-based alert mechanism**, similar to automotive parking sensors.
- Closer objects produce higher frequency beeping.

#### LED Indicators
- Provide real-time system status:
  - measurement active
  - hold mode active
  - echo detected
  - error/timeout indication

---

## Timing and Synchronization

All modules operate under a **single global clock (100 MHz)**, ensuring synchronous behavior.

Key design considerations:
- no combinational feedback loops,
- no unintended latch inference,
- all state changes occur on clock edges,
- proper reset handling across all modules.

Clock enable signals (`clk_en`) are used to derive slower timing domains without introducing multiple clocks.

---

## Hardware Considerations

- The FPGA operates at **3.3V logic**, while the ultrasonic sensor requires **5V supply**.
- The echo signal must be safely interfaced using a **level shifter or voltage divider**.
- Trigger signal from FPGA is compatible with sensor input logic.

Incorrect voltage interfacing may damage the FPGA and must be handled carefully.

---

## Implementation Methodology

The project strictly follows a structured FPGA development flow:

1. RTL design using Verilog
2. Functional simulation (testbenches for each module)
3. RTL schematic verification
4. Synthesis and resource analysis
5. Timing verification
6. Bitstream generation
7. Hardware testing on Nexys A7

Simulation is prioritized to validate:
- timing correctness,
- edge detection,
- counter behavior,
- system stability.

---

## Design Challenges

Key challenges addressed in this project include:

- Accurate pulse-width measurement at high clock frequency
- Reliable edge detection under asynchronous input conditions
- Avoiding metastability and glitches
- Designing efficient integer-based distance conversion
- Ensuring flicker-free multi-digit display
- Synchronizing multiple interacting modules

---

## Authors

- Malekimoghaddam Niloofar  
- Onaran Yusuf Çetin  

---

## Conclusion

This project demonstrates a complete **real-time embedded measurement system implemented on FPGA**, integrating:

- precise digital timing,
- sensor interfacing,
- synchronous system design,
- modular hardware architecture,
- and user interaction mechanisms.

The final system is robust, scalable, and fully compliant with FPGA design best practices, providing both functional correctness and engineering-level implementation quality.



## Block Diagram

![Block Diagram](top_level_schematics.png)



