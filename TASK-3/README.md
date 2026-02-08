# Task 3 – Multi-register GPIO Control IP

## Objective of Task‑3

The main objective of this task is to:

* Extend a basic GPIO IP into a **multi‑register, memory‑mapped peripheral**
* Implement **direction control, data registers, and readback logic**
* Integrate the IP cleanly into an existing RISC‑V SoC
* Validate complete **software → hardware → signal** interaction using simulation
* Hardware validation

## Key Features of the GPIO Control IP

The GPIO Control IP allows software to:

* Configure each GPIO pin as **input or output**
* Write output values to GPIO pins
* Read back the current GPIO pin state

The IP is accessed entirely through **memory‑mapped registers** and follows the same bus protocol used by existing SoC peripherals.

---

## Repository Structure

The repository is organized to clearly separate RTL, firmware, and documentation:

```
Task-3/
├── RTL/
│   ├── riscv.v              # SoC top-level integration
│   ├── gpio_reg_bank        # Multi-register GPIO Control IP     
│   ├── gpio_reg_tb.v        # testbench code
└── README.md                # Task-3 documentation
```

## Task Flow Summary

The work is divided into five structured steps:

1. **Study and planning** of the required GPIO functionality
2. **RTL implementation** of a multi‑register GPIO IP
3. **SoC integration** and address decoding
4. **Software‑based validation** using simulation

Each step is described below in the same order in which it was executed.

## Step 1 – Study and Plan (Mandatory)

This step focused entirely on **design planning**, without writing any RTL or software.

### Planning Goals

* Review the GPIO IP developed in Task‑2
* Understand how the CPU accesses peripherals via memory‑mapped I/O
* Define a **clear register map** for the new GPIO IP
* Decide how direction control and readback should behave

### Register Map Definition

The GPIO Control IP uses the following fixed register map:

| Offset | Register  | Description                               |
| -----: | --------- | ----------------------------------------- |
|   0x00 | GPIO_DATA_OFF | Output data register (R/W)                |
|   0x04 | GPIO_DIR_OFF  | Direction control (1 = output, 0 = input) |
|   0x08 | GPIO_READ_OFF | GPIO pin readback (Read‑only)             |

All registers are:

* 32‑bit wide
* Word‑aligned
* Accessed via standard load/store instructions

### Behavior Definition

* **GPIO_DATA_OFF**: Stores output values written by software
* **GPIO_DIR_OFF**: Controls per‑pin direction
* **GPIO_READ_OFF**: Returns pin state (output value for outputs, pin input for inputs)

Reset behavior was defined early so that all GPIO pins default safely to **input mode**.

---

## Step 2 – Implement Multi‑Register GPIO RTL (Mandatory)

In this step, the planned register map was converted into **clean, synthesizable RTL** inside `gpio_reg_bank.v`.

### Design Approach

* Each writable register is implemented using synchronous logic
* Address **offset decoding** is done using lower address bits
* Read logic is purely combinational
* No unintended latches are inferred

### Address Offset Decoding

Lower address bits are used to select registers:

* `00` → GPIO_DATA_OFF
* `01` → GPIO_DIR_OFF
* `10` → GPIO_READ_OFF

This approach is simple, scalable, and commonly used in real designs.

### GPIO Readback Logic

Readback behavior combines direction and data logic so that:

* Output pins reflect driven values
* Input pins reflect external pin state

This allows mixed input/output usage across GPIO pins.

At the end of this step, the GPIO IP was functionally complete and ready for SoC integration.

---

## Step 3 – Integrate GPIO IP into the SoC (Mandatory)

This step connected the GPIO Control IP to the existing RISC‑V SoC.

### Integration Tasks

* Assign a dedicated **base address** to the GPIO IP
* Decode addresses inside the SoC
* Route bus signals correctly to the GPIO IP
* Add GPIO read data into the SoC read multiplexer
* Optionally connect GPIO outputs to LEDs

Only the SoC top‑level file (`riscv.v`) was modified during this step.

After integration, the CPU can access the GPIO IP exactly like any other memory‑mapped peripheral.

---

## Step 4 – Software Validation (Mandatory)

This step validates the **entire system end‑to‑end** using real software running on the RISC‑V CPU.

![img1](https://github.com/user-attachments/assets/111aee91-ce1c-435f-909f-40f2ae9cf9d8)

![img2](https://github.com/user-attachments/assets/cb873ee6-d701-41fa-9f96-32212ace3034)

<img width="798" height="560" alt="Screenshot from 2026-02-04 14-18-10" src="https://github.com/user-attachments/assets/3eb6e4d2-f7d3-4642-adb3-5933a2154c4e" />


![img3](https://github.com/user-attachments/assets/0a572d9f-0f00-49d4-8aac-f1846ae30375)

![img4](https://github.com/user-attachments/assets/ea60b077-6e3c-4e7b-9cc6-6ad899ec0d89)

![img5](https://github.com/user-attachments/assets/9834cffb-a280-4ccd-97cb-1af0a7b0a022)


### Validation Strategy

A C program (`gpio_test.c`) is used to:

1. Configure GPIO directions
2. Write values to GPIO_DATA
3. Read GPIO_READ
4. Print results via UART

### What Is Verified

* Correct register offset decoding
* Correct direction control behavior
* Correct output driving
* Correct readback values
* Correct CPU‑to‑GPIO bus interaction


## Submission Summary

This submission includes:

* Multi‑register GPIO Control IP RTL
* Register map and behavior explanation
* SoC integration description
* Software test program
* Simulation‑based validation evidence

## Conclusion

Task‑3 strengthened my understanding of:

* Register‑level peripheral design
* Memory‑mapped I/O
* Software–hardware contracts
* Multi‑register IP implementation
* End‑to‑end SoC validation

This task closely reflects real industry‑style peripheral development and prepares the foundation for more advanced IPs such as timers, PWMs, and interrupt‑driven peripherals.

