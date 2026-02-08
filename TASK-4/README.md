# Task 4 – Timer Peripheral IP  Development

## Task Objective

The objective of Task‑4 is to:

* Design a **realistic Timer peripheral IP**
* Expose it as a **memory‑mapped register block**
* Integrate it cleanly into an existing RISC‑V SoC
* Control and observe it using **C firmware**
* Prove correctness through **simulation** and **FPGA hardware**

Unlike GPIO‑based tasks, the Timer IP operates **autonomously in hardware** once configured, which reflects how real SoC peripherals behave.

---

## What This Task Demonstrates

This task demonstrates several core SoC concepts:

* Register‑based peripheral design
* Hardware–software contracts
* Address decoding and bus integration
* Autonomous hardware operation
* Event‑driven behavior (timeout)
* End‑to‑end validation (software → RTL → signals → hardware)
  

## Repository Structure

The project is organized to separate RTL, firmware, and constraints clearly:

```
basicRISCV/
├── RTL/
│   ├── riscv.v            # SoC top-level with Timer integration
│   ├── TIMER.v         # Timer peripheral (Task‑4)
│   ├── gpio_reg_ip.v     # Existing GPIO IP
└── README.md
```



## Design Overview of the Timer IP

The Timer IP is implemented as a **memory‑mapped peripheral** with a small set of control and status registers. Software programs the timer once, after which the hardware runs independently and generates **timeout events**.

The timeout event is used to drive LED toggling, demonstrating real hardware‑driven behavior rather than software delay loops.

---

## Register Map

The Timer IP exposes four 32‑bit registers:

| Offset | Register | Access | Description             |
| -----: | -------- | ------ | ----------------------- |
|   0x00 | CFG      | R/W    | Enable and mode control |
|   0x04 | RELOAD   | R/W    | Countdown start value   |
|   0x08 | COUNT    | R      | Current counter value   |
|   0x0C | STATUS   | R/W    | Timeout flag (W1C)      |

### Register Behavior Summary

* **CFG**

  * Bit 0: Enable timer
  * Bit 1: Periodic mode (auto‑reload)

* **RELOAD**

  * Initial value loaded into the counter

* **COUNT**

  * Decrements every clock cycle when enabled

* **STATUS**

  * Bit 0 set when timeout occurs
  * Writing `1` clears the timeout flag

All registers are word‑aligned and accessed using standard load/store instructions.

---

## Step 1 – Timer IP RTL Design

In this step, the Timer IP was designed as a **self‑contained RTL module**.

### Key Design Decisions

* Fully synchronous logic
* Explicit reset behavior
* Registered timeout pulse (one‑cycle wide)
* Support for one‑shot and periodic modes
* No hard‑coded delays or software‑driven toggling

Once enabled, the timer counts down autonomously and asserts a timeout signal when the counter reaches zero.

---

## Step 2 – Memory Mapping and Addressing

The Timer IP was assigned a **dedicated base address** in the SoC peripheral region:

```
TIMER_BASE = 0x2000_1000
```

All register accesses are relative to this base address. Address decoding is handled at the SoC level using upper address bits to avoid conflicts with RAM, GPIO, and UART.

---

## Step 3 – SoC Integration

The Timer IP was instantiated inside the SoC top module and connected to:

* System clock and reset
* CPU address and data buses
* Read‑data multiplexer
* Hardware event routing logic

The timeout output from the Timer IP is used to toggle LED state inside the SoC, demonstrating how peripheral‑generated events can affect system behavior without CPU polling.

---

## Step 4 – Firmware Control

A dedicated C program configures and starts the Timer IP.

### Firmware Responsibilities

* Program the RELOAD register
* Enable the timer in periodic mode
* Poll the STATUS register
* Clear timeout events

Once configured, the CPU does **not** manually control LED timing. All blinking is driven by the hardware timer.

This cleanly separates **software configuration** from **hardware execution**.

---

## Step 5 – Simulation‑Based Verification

![pic1](https://github.com/user-attachments/assets/1cfe96e3-1a80-4a3f-afcd-2afc3fbd7f06)

![pic2](https://github.com/user-attachments/assets/7a5fcbd1-1e49-45df-b08b-4bdcd029f234)

![pic3](https://github.com/user-attachments/assets/5ffeb4a7-d332-4a27-b4bb-b2ba5faf3187)

![pic5](https://github.com/user-attachments/assets/ffb6ed1a-aafc-4efb-8098-89dba84c73ca)

![pic5](https://github.com/user-attachments/assets/372f251c-c1eb-4f6c-88e7-7ef03d0d7249)


### Verified Through Simulation

* Correct register writes from CPU
* Proper address decoding for Timer IP
* Countdown behavior of VALUE register
* One‑cycle timeout pulse generation
* LED toggling driven by timeout events

GTKWave waveforms were inspected to confirm signal‑level behavior across the entire data path.


## Results and Observations

* The Timer IP behaves as a true autonomous peripheral
* Software interaction is limited to configuration and status handling
* Address decoding correctness is critical for stable operation
* Registered timeout pulses simplify both simulation and hardware use
* Hardware‑driven timing is fundamentally different from software‑driven delays

---

## Learning Outcomes

Through Task‑4, I gained hands‑on experience with:

* Real peripheral IP ownership
* Timer‑based hardware design
* Memory‑mapped register interfaces
* SoC‑level integration challenges
* Software‑hardware co‑design

## Conclusion

Task‑4 successfully demonstrates the complete lifecycle of a real SoC peripheral—from RTL design to software control and hardware validation. The Timer IP operates correctly as an autonomous hardware block and integrates cleanly into the RISC‑V SoC.

