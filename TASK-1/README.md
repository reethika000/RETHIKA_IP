# RISC-V System Synthesis & Environment Configuration

# TASK-1: Toolchain Validation and Firmware Bring-up

# OBJECTIVE
The primary goal of this phase was to architect a stable Linux-based development environment for RISC-V ISA exploration. This involved verifying the cross-compilation toolchain, ensuring functional parity between C-source code and RISC-V binaries, and validating firmware execution via high-level simulators—all prior to physical FPGA deployment.

# Project Environment
To maintain consistency and reproducibility, the entire workflow was executed within a cloud-integrated Linux environment.
# Infrastructure: 
GitHub Codespaces (Cloud Instance)
#OS Kernel: 
Linux (Ubuntu-based)
# Primary IDE: 
VS Code with Integrated Terminal
# Graphical Interface: 
noVNC Web Terminal (for visual output verification)

# Task cycle
## 1. Toolchain Integrity Check
Before beginning development, the system was audited to ensure all necessary binaries were present in the system
### Compiler: 
riscv64-unknown-elf-gcc (Cross-compiler for translating C to RISC-V)
### HDL Tooling: 
iverilog (For future RTL simulation)
### Simulation: 
spike (RISC-V ISA Simulator)

## 2. Algorithmic Verification (C to RISC-V)
A mathematical algorithm (Summation of Integers) was used as a benchmark to test the compilation flow.
### Workflow: 
1. Authored source code in sum1toN.c. 2. Cross-compiled into an executable ELF file using the RISC-V GCC toolchain. 3. Simulated execution using the Spike ISA Simulator with the Proxy Kernel (pk).
### Iteration:
The code was modified (increasing the summation limit) to verify that the environment handles re-compilation and behavioral changes accurately.


## 3. VSDFPGA Firmware Architecture
The final stage involved building the official VSDFPGA firmware to generate hardware-ready artifacts.
### Build System:
Utilized make to automate the generation.
### Simulator Validation: 
The firmware was executed in a loop within the Spike simulator, successfully rendering the ASCII-based VSD logo. This confirmed that the firmware logic is sound and ready for memory-mapped I/O integration.

# COMMANDS USED 
```bash
   riscv64-unknown-elf-gcc --version
   iverilog -V
   spike --help

```

# RISC-V Reference Program Compilation and Execution

```bash
riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c  
spike pk sum1ton.o
```
# ouput
```bash
sum from 1 to 9 is 45
```

<img width="1920" height="1200" alt="Screenshot 2025-12-18 165659" src="https://github.com/user-attachments/assets/0d447bd3-88e3-43e3-9165-30fdbf320895" />

## Program is changed 
```bash
riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c  
spike pk sum1ton.o
```
output
```bash
sum from 1 to 6 is 21
```
<img width="1920" height="1200" alt="Screenshot 2025-12-18 165659" src="https://github.com/user-attachments/assets/89bb5e77-8ded-4ad1-a200-842250b0e31b" />

## Commands used 
```bash
git clone https://github.com/vsdip/vsdfpga_labs.git  
cd vsdfpga_labs/basicRISCV/Firmware
riscv_logo.bram.hex
riscv64-unknown-elf-gcc -o riscv_logo.o riscv_logo.c  
spike pk riscv_logo.o
```
<img width="1920" height="1200" alt="Screenshot 2025-12-18 180614" src="https://github.com/user-attachments/assets/0b93b41c-353b-4ca4-a0bc-524550b4d13d" />


## OUTPUT
```bash
LEARN TO THINK LIKE A CHIP  
VSDSQUADRON FPGA MINI  
BRINGS RISC-V TO VSD CLASSROOM
```


## Architectural Insights (Understanding Check)

# Summary of Verification
# Environment Setup: 
Toolchain and simulators are correctly configured and path-verified.
# Functional Simulation: 
Spike simulator successfully handles complex RISC-V binary execution.
# Workflow Readiness:
Multi-repository synchronization and firmware generation are fully operational.

 ## Understanding Check

# 1. Where is the RISC-V program located?
The RISC-V program is located at samples directory as sum1ton.c
vsd-riscv2/samples/sum1ton.c
and can edited and executed many times using gedit sum1ton.c

# 2. How is the program compiled and loaded into memory?
The program is compiled using compiler riscv64-unknown-elf-gcc sum1ton.c -o sum1ton.o
This converts sum1ton.c into RISC-V ELF executable.
pk(proxy kernel) loads the program into memory
and executed it using spike with the proxy kernel spike pk sum1ton.o

# 3. How does the RISC-V core access memory and memory-mapped IO?
The RISC-V core accesses program and data memory using standard load/store instructions. Memory-mapped I/O, such as console output,is accessed through system calls (ecall),which are intercepted by spike and handled by pk to produce output on host system

# 4.  Where would a new FPGA IP block logically integrate?
A new FPGA IP block would be integrated inside the RTL level ,connected to the RISC-V core through the Soc interconnect
vsd-riscv2/samples/vsdfpga_labs/basicRISCv/RTL


## Reference Resources
# Repository Reference:
# vsd-riscv2
https://github.com/vsdip/vsd-riscv2

# vsdfpga_labs
https://github.com/vsdip/vsdfpga_labs
