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
This figure illustrates the propagation of ultrasonic waves from the sensor to an object and back. The distance is calculated based on the time difference between the transmitted and received signals.


### HC-SR04 Timing Diagram

<p align="center">
  <img src="images/ultrasonic_timing_principle.jpg" width="600"/>
</p>

The timing diagram shows the required 10 µs trigger pulse and the corresponding echo pulse width, which directly encodes the measured distance.

This method provides a simple, low-cost, and robust solution for real-time distance measurement in embedded systems. 


## Project Description

The objective of this project is to design and implement a real-time distance measurement system using the **HS-SR04 ultrasonic sensor** and an FPGA platform.

The system operates by generating a trigger pulse, capturing the duration of the returned echo signal, and converting this time measurement into distance using a hardware-efficient approximation. The computed distance is then displayed on the **7-segment display** of the Nexys A7-50T board.

In addition to distance visualization, the system includes a **buzzer control mechanism** that provides proximity-based feedback, where the buzzer frequency increases as the measured distance decreases. A **hold function** is also implemented using a debounced push-button input, allowing the user to freeze the last valid measurement on the display. 



The design follows a **modular and hierarchical architecture**, where each functional block (trigger generation, echo capture, distance conversion, display control, and system control) is implemented as an independent Verilog module. The entire system is designed using a **single synchronous clock domain (100 MHz)**, avoiding the use of derived clocks and preventing unintended latch inference.

All modules are verified through simulation before integration, and the complete system is synthesized and implemented on the FPGA, ensuring correct operation in both simulation and real hardware.
