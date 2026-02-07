# Commercial-Grade Timer IP (VSDSquadron)

## What This IP Does

The Timer IP is a **hardware countdown timer** that is configured by software and then runs independently inside the FPGA fabric. Once enabled, it counts down from a programmed value and generates a **timeout event**, which can be used to trigger LEDs or other hardware behavior.



Typical use cases include:

* Generating fixed delays in embedded software
* Creating periodic heartbeat or status indicators
* Driving LEDs or simple hardware events
* Demonstrating hardware‑driven timing (without software delay loops)

---

## Key Capabilities

* 32‑bit down‑counter controlled via memory‑mapped registers
* Standard RISC‑V load/store programming model
* Supports both **one‑shot** and **auto‑reload (periodic)** operation
* Timeout flag with **write‑1‑to‑clear** semantics
* Fully synchronous and reset‑safe design
* Verified using RTL simulation and VSDSquadron FPGA hardware

### Known Constraints

* No interrupt output (software must poll status)
* Only one timer instance per SoC
* Timing resolution depends on the system clock frequency

# BLOCK DIAGRAM 

<img width="1536" height="1024" alt="blc dia" src="https://github.com/user-attachments/assets/3863e8ac-6047-43ab-9125-966956c9132d" />


## Logical Block View

```
RISC‑V CPU Bus
      |
      v
 Address & Register Decode
      |
      v
 Timer Counter / Control Logic
      |
      v
 Timeout Flag & Output Signal
```

This logical view shows how software configuration flows through register decoding into the hardware counter and status logic.

---

## Package Layout

```
TIMER_IP/timer_ip/
├── rtl/        # TIMER  RTL source
├── software/   # Example C program
├── snaps/      # clear screenshots of results
└── README.md   # Top‑level overview (this file)
```




## Integration Steps

1. Add the contents of the `rtl/` directory to your SoC project
2. Instantiate the Timer IP in the SoC top‑level module
3. Allocate a peripheral base address for the Timer
4. Connect the timeout output to an LED or internal signal
5. Build and program the FPGA
6. Run the example software provided in `software/`

After configuration, the timer will operate fully in hardware.

---

## Example Software Behavior

The supplied example software demonstrates:

* Programming the timer load value
* Enabling periodic mode
* Monitoring the timeout status flag
* Clearing the timeout condition

The example is designed to run directly on the VSDSquadron RISC‑V system without modification.

---

## Validation and Expected Results

### Simulation
## RESULTS 
![pic_1](https://github.com/user-attachments/assets/747c6d26-622f-4b47-9a11-bc5a6f3b5221)

<img width="798" height="600" alt="pic_2" src="https://github.com/user-attachments/assets/f8d10851-540a-4665-84a9-570282c217f8" />

![pic_3](https://github.com/user-attachments/assets/80d72dfe-0e43-4baa-af5d-38ae12a9380d)





* CPU writes to timer registers are visible on the bus
* Countdown value decreases correctly
* Timeout flag asserts when the counter expires
* Hardware‑driven signals respond as expected

### FPGA Hardware

* On‑board LED toggles periodically
* Blink rate matches the configured timer value
* Operation is stable across resets

---

## Limitations and Notes

* Polling‑based status checking only
* Single‑channel timer design
* Assumes a fixed system clock provided by the SoC

These characteristics are documented to ensure predictable integration.

---

## License

This Timer IP package is released for **educational and open‑source use** within the VSDSquadron FPGA ecosystem.

