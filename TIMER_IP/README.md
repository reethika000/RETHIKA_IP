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

## USES

* Precise and deterministic timing independent of CPU execution and software jitter
* Periodic event generation for task scheduling and system housekeeping
* Hardware-enforced timeouts to detect software hangs and fault conditions
* Low-power system operation by enabling sleep/idle modes instead of active polling
* Replacement for software delay loops, ensuring reliable and portable timing behavior

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

##  Software Behavior

The supplied example software demonstrates:

* Programming the timer load value
* Enabling periodic mode
* Monitoring the timeout status flag
* Clearing the timeout condition



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

### Timer IP FPGA Synthesis on VSD Squadron FPGA Mini

This project demonstrates the complete RTL-to-hardware FPGA implementation flow of a custom Timer IP on the VSD Squadron FPGA Mini using an open-source iCE40 FPGA toolchain.

## Project Files


├── final_vsd_timer.v        # Timer IP RTL design  
├── top_timer_fpga.v         # FPGA top-level module  
├── vsd_squadron.pcf         # Pin constraint file  
├── timer.json               # Synthesized netlist  
├── timer.asc                # Place & route output  
├── timer.bin                # FPGA bitstream  
└── README.md  

## Target FPGA Platform

- Board: VSD Squadron FPGA Mini  

## FPGA Toolchain Used

- Yosys – RTL synthesis  
- nextpnr-ice40 – Place and route  
- icepack – Bitstream generation  
- iceprog – FPGA programming  



## FPGA Implementation Flow

### Step 1: RTL Synthesis (Yosys)

The RTL design is synthesized into an FPGA-mapped netlist using Yosys.
```bash
yosys -p "
read_verilog final_vsd_timer.v top_timer_fpga.v
synth_ice40 -top top_timer_fpga -json timer.json
"
```
Output:
- timer.json – Synthesized netlist

---

### Step 2: Place and Route (nextpnr)

The synthesized netlist is mapped to physical FPGA resources and pins using the constraint file.
```bash
nextpnr-ice40 \
--up5k \
--package sg48 \
--json timer.json \
--pcf vsd_squadron.pcf \
--asc timer.asc
```
Output:
- timer.asc – Fully placed and routed FPGA design

---

### Step 3: Bitstream Generation (icepack)

```bash
icepack timer.asc timer.bin
```

Output:
- timer.bin – FPGA configuration bitstream

---

### Step 4: FPGA Programming (iceprog)

```bash
iceprog timer.bin
```
Result:
- Timer IP runs on FPGA hardware
- Correct operation verified through LED or timeout output

![finalpic1](https://github.com/user-attachments/assets/966972b7-2bb8-4d89-b6ac-5771a1b5d150)

![finalpic2](https://github.com/user-attachments/assets/dd153a01-4256-4284-8d69-fbbb2df8e129)

<img width="1920" height="975" alt="finalpic3" src="https://github.com/user-attachments/assets/103e7914-a6b5-4142-a05e-4c1131912084" />

![finalpic4](https://github.com/user-attachments/assets/e8670812-1ec3-421f-a81a-ed762f9ca3ef)

![finalpic5](https://github.com/user-attachments/assets/5fe08284-0963-49fb-a6e0-c2d96a5a7517)

![finalpic6](https://github.com/user-attachments/assets/1de9360c-38f2-4be2-9699-1178273d1ae3)

![finalpic7](https://github.com/user-attachments/assets/d608473d-163b-429c-abe7-a909b11bb327)


## FPGA Hardware Video

https://github.com/user-attachments/assets/f72d05fa-cea8-4c21-88aa-012433f23245



## Limitations and Notes

* Polling‑based status checking only
* Single‑channel timer design
* Assumes a fixed system clock provided by the SoC

These characteristics are documented to ensure predictable integration.

---

## License

This Timer IP package is released for **educational and open‑source use** within the VSDSquadron FPGA ecosystem.

