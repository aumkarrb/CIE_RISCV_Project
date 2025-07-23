<img width="587" height="192" alt="image" src="https://github.com/user-attachments/assets/aabdd860-26f7-4f30-b642-f26b1af02ce8" />     
<img width="200" height="192" alt="image" src="https://github.com/user-attachments/assets/911a636c-8c4d-42ee-b59f-7115c0d33ebc" />



# CIE Silicon RISC-V Project

### RISC-V K-Nearest Neighbors Accelerator for Image Recognition on FPGA 


# Introduction:

The rapid growth of machine learning (ML) applications demands efficient hardware accelerators to meet performance and power constraints. Field-Programmable Gate Arrays (FPGAs) offer a flexible platform for implementing custom processors tailored to ML workloads. This 6-month final-year engineering project proposes the design, implementation, and verification of a RISC-V processor based on the PicoRV32 core, enhanced with custom instructions (MADD for matrix addition, VDOT for vector dot product, and MDIST for Euclidean distance) to accelerate a K-Nearest Neighbors (KNN) classifier for recognizing 8x8 grayscale images (e.g., MNIST digit subset). The project targets the Arty A7-100T FPGA (Xilinx XC7A100T-1CSG324C) using Vivado 2024.2 and leverages an existing PicoRV32 setup (Verilog RTL, testbench, and firmware).
The team of 8 students will develop a complete system, starting with environment setup and RISC-V fundamentals, followed by RTL design, firmware development, pipelining, DMA, DDR3 interfacing, and optimization. Without external PMOD modules, the system will use onboard slide switches, buttons, LEDs, and UART (via USB) for input/output. The project will demonstrate a 5–10x execution speedup of the hardware-accelerated KNN classifier compared to a software-only implementation, showcasing results via UART and LEDs. This initiative will provide hands-on experience in VLSI design, RISC-V architecture, FPGA prototyping, and ML acceleration, preparing students for careers in embedded systems and hardware design.

 # Objectives:

The project aims to achieve the following: 

 1. Environment Setup and Learning: Install Vivado, RISC-V toolchain, and master RISC-V ISA (RV32I), FPGA design flow, and PicoRV32 architecture.
 2. Custom Instruction Accelerator: Implement MADD, VDOT, and MDIST instructions to accelerate KNN distance calculations.
 3. ML Application: Develop a KNN classifier for 8x8 image recognition, quantifying hardware vs. software execution speedup.
 4. System Enhancements: Integrate 3-stage pipelining, DMA, UART, and DDR3 memory, using onboard switches, buttons, and LEDs for interaction.
 5. Optimization and Verification: Optimize timing, power, and FPGA resource usage; verify functionality through simulation and hardware prototyping.
 6. Demonstration and Documentation: Showcase speedup in a live demo (UART/LED output) and deliver comprehensive reports and presentations.

# Contributors

1. Aumkar Ranjan Behura 
2. Lasya Hedge
3. Mallikarjun Yeshlur 
4. Omkar Sastry N R
5. Rakesh Patil
6. Shashwath R Kedilaya
7. Shubhang S 
8. Tanish A Shet

# Industrial Mentors 
1. Prof. Kuldeep Simha 
2. Prof. Radhakrishnan "Rad" Mahalikudi

# Special Thanks to:- 
1. Prof. Madhukar Narasimha 
2. Prof. Sathya Prasad 
3. Prof. Tarun R 

<img width="300" height="400" alt="image" src="https://github.com/user-attachments/assets/10efc56d-dc69-4604-832e-ed3fd930ce60" />



