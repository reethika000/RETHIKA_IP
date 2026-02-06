# Design & Integration of a Memory-Mapped GPIO IP

## Task Objective

The objective of this task is to:

* Design a **32‑bit memory‑mapped GPIO output IP**
* Integrate it into an existing RISC‑V SoC
* Access it using software running on the CPU
* Prove correctness through **simulation‑based validation**



## Task Flow Overview
1. **Study the existing SoC architecture**
2. **Design the GPIO IP as a standalone RTL block**
3. **Integrate the GPIO IP into the SoC**
4. **Validate functionality using simulation**

Each step builds directly on the previous one and mirrors a real SoC development flow.

## Step 1 – Understanding the Existing SoC

This step involves **analysis only**. No RTL is modified here.

### Goals of This Step

* Understand how the CPU communicates with memory and peripherals
* Identify where **address decoding** is performed
* Study how existing peripherals (LED, UART) are implemented
* Learn how read and write transactions occur on the bus

### Key Observations

* The CPU interacts with the system only through a **memory interface**
* All peripherals are accessed using **memory‑mapped IO**
* Address bit‑based decoding is used to distinguish RAM and IO space
* Simple peripherals such as LEDs provide a reference for GPIO design

This understanding ensures that the new IP follows the **same protocol and timing assumptions** as the rest of the SoC.


## Step 2 – GPIO IP RTL Design

In this step, a new RTL module named `gpio_ip.v` is created.


### GPIO IP Requirements

* One 32‑bit register
* Writing updates the GPIO output
* Reading returns the last written value
* Fully synchronous design
* Compatible with existing SoC bus signals

### Interface Summary

The GPIO IP connects to the system using:

* Clock and active‑low reset
* Write enable and read enable signals
* Write data and byte write mask
* Read data output
* GPIO output signal

### Internal Design Choice

* A single 32‑bit register stores GPIO state
* Byte‑wise write masking is supported
* Readback is combinational for simplicity

This separation allows the IP to be verified independently before SoC integration.

---

## Step 3 – SoC Integration

Once the GPIO IP is verified at the module level, it is integrated into the SoC top‑level.

### Integration Actions

* Instantiate the GPIO IP inside the SoC
* Allocate a **new IO address slot** for GPIO
* Connect CPU bus signals to the GPIO IP
* Include GPIO read data in the IO read multiplexer

### Address Mapping

* GPIO is mapped into the IO address space
* A dedicated word‑aligned address is assigned
* Software uses this address to access the GPIO register

After this step, the GPIO IP becomes a **fully accessible peripheral** from the CPU’s perspective.

---

## Step 4 – Simulation‑Based Validation

Simulation is the **primary proof of correctness** for this task.

### Software Test Program

A small C program is executed on the RISC‑V CPU that:

* Writes a known value to the GPIO register
* Reads back the same register
* Prints the read value using UART

This confirms correct **write**, **storage**, and **readback** behavior.

### Simulation Flow

* Firmware is compiled into a memory image
* RTL simulation is run using a simulator
* UART output is observed in the terminal
* Waveforms are inspected using GTKWave

### What Is Verified

* Correct address decoding for GPIO
* Proper assertion of read/write control signals
* Correct update of GPIO register
* Correct data returned on CPU reads

Simulation results confirm that the GPIO behaves exactly as specified.

---

## Step 5 – Hardware Validation (Optional)

This step is performed only if an FPGA board is available.

### Hardware Validation Overview

* The same RTL design is synthesized
* GPIO output is connected to onboard LEDs
* The same software test is executed
* LED behavior and UART output are observed

Hardware behavior matches simulation, providing additional confidence.

---

## Submission Summary

This submission includes:

* GPIO IP RTL implementation
* Description of SoC integration
* Simulation output / waveform evidence
* Explanation of address mapping and validation

All mandatory requirements of **Task‑2** have been completed successfully.

---

## Conclusion

This task provided hands‑on experience with:

* Memory‑mapped peripheral design
* RTL IP development
* SoC‑level integration
* Software‑hardware interaction
* Simulation‑driven verification

The GPIO IP was designed, integrated, and validated following industry‑style design practices while maintaining originality in documentation and explanation.

---

**Status**: Task‑2 completed
