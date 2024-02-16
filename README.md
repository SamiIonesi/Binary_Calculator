# Binary_Calculator
<p align="center">
  <img src="https://github.com/SamiIonesi/Binary_Calculator/assets/150432462/824ea96d-a472-42b3-af60-eb583f58e506" width="800" height="250">
</p>

This project shows the operation of a binary calculator. It performs a chosen operation in binary based on two operands and displays the data on the serial and also shows its verification with UVM.

## How does it work?
<p align="center">
  <img src="https://github.com/SamiIonesi/Binary_Calculator/assets/150432462/6d090b9c-a41e-4cd3-ab02-bf0543b50660" width="700" height="400">
</p>
<p align = "center">
  Block Scheme
</p>

It has two modes of operation:

Mode 0: 
- Transmission of data directly on the serial from the ALU

Mode 1:
- Serial transmission of data from memory
- Writing data to memory

You can ses the full documentation on this [link](https://github.com/SamiIonesi/Binary_Calculator/blob/main/Binary_Calculator_Documentation.pdf).

## Instructions
This repository contains two folders:
- **Modules** folder contain all the module that is present in the project and also the final module in witch is included the [Binary Claculator](https://github.com/SamiIonesi/Binary_Calculator/tree/main/Modules/Binary_Calculator). Each of this modules include a folder for Vivado Project and also a txt file in witch you can see the projec online on EDA Playground.

  Ex.: For ALU we have a folder for [Vivado Project](https://github.com/SamiIonesi/Binary_Calculator/tree/main/Modules/ALU/ALU) and also a [txt file](https://github.com/SamiIonesi/Binary_Calculator/blob/main/Modules/ALU/Link_EDAPlayground.txt) where we can see the [link](https://edaplayground.com/x/MFMV) to EDA Playground.

- **Verification** folder have three folder in witch we can see the scripts for verification of a mode and also the txt file with the link to EDA playground.

  Ex.: Mode0 Verification have the [scripts](https://github.com/SamiIonesi/Binary_Calculator/tree/main/Verification/Verification_Mode0) and also the [txt file](https://github.com/SamiIonesi/Binary_Calculator/blob/main/Verification/Verification_Mode0/Verification_Mode0.txt) with the [link](https://edaplayground.com/x/Hjv5) to EDA Playground.

## Installing
If you want to work on this project and see it localy to you're computer, first of all you'll need to install Vivado on you're computer following this [link](https://www.xilinx.com/developer/products/vivado.html), but if you prefer to work and see it online, for each modules and verification part you have a txt file that have the link to the EDA Playground with contain the code for each components and also the testbanchs. 
