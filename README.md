# Ultrasound Distance Meter with HS-SR04 on Nexys A7-50T

This project was developed as part of the **BPA-DEL (Digital Electronics)** course at Brno University of Technology in the 2025/2026 academic year by Yusuf Çetin ONARAN and  Niloofar Malekimoghaddam. The goal of the project is to design and implement a real-time distance measurement system using an ultrasonic sensor on an FPGA platform.

The system utilizes the **HS-SR04 ultrasonic sensor** to measure the distance to an object based on the Time-of-Flight (ToF) principle. The measured distance is processed on the **Nexys A7-50T FPGA**, displayed on 7-segment displays, and used to control a buzzer for proximity indication. The design follows a modular and fully synchronous architecture implemented in Verilog.

## Background: Time-of-Flight Principle

Time-of-Flight (ToF) is a distance measurement method based on calculating the travel time of a wave between a transmitter and a receiver. In ultrasonic sensing systems, high-frequency sound waves are emitted, reflected from an object, and received back by the sensor.

The HC-SR04 ultrasonic module operates using this principle. It emits an ultrasonic pulse at approximately 40 kHz and measures the time required for the echo signal to return.

The fundamental relationship used for distance calculation is:

\[
distance = \frac{v \cdot t}{2}
\]

where:

- \( v \) is the speed of sound in air (approximately 343 m/s at 20°C),
- \( t \) is the measured round-trip time of the ultrasonic wave.

The division by 2 is required because the signal travels to the object and back.

In this project, the FPGA measures the duration of the ECHO signal in clock cycles. Given a system clock frequency of 100 MHz:

\[
t = \frac{\text{echo\_count}}{100 \times 10^6}
\]

Combining these equations leads to a simplified implementation formula:

\[
distance_{cm} \approx \frac{\text{echo\_count}}{5800}
\]

This approximation is used in the `distance_converter` module for efficient hardware implementation.

### Ultrasonic Measurement Principle

![Ultrasonic Principle](images/ultrasonic_sensing_principle.png)

### HC-SR04 Timing Diagram

![Ultrasonic Timing](images/ultrasonic_timing_principle.jpg)

The timing diagram shows the required 10 µs trigger pulse and the corresponding echo pulse width, which directly encodes the measured distance.

This method provides a simple, low-cost, and robust solution for real-time distance measurement in embedded systems.
