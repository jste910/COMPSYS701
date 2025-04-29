# MRASM Assembler

## Overview

This project includes an assembler executable, `mrasm.exe`, which can be used to assemble assembly language source files (`.asm` files).

## How to Use

### 1. Navigate to the Assembler Directory

Open a terminal or command prompt and navigate to the following directory in our provided zip file:
`COMPSYS701\assembler\Assembler` 

### 2. Run the Assembler

To assemble an assembly file, run the following command:
`./mrasm.exe test.asm` 

This will assemble the `test.asm` file.


### 3. Assemble a Different File

To assemble a different file, simply replace `test.asm` with the name of your `.asm` source file. For example:

`./mrasm.exe yourFile.asm` 


### 4. Output 
There will be a `rawOutput.hex` and `rawOutput.mif` files generated. The contents of the `.mif` file should be copied into the `program.mif` file inside the folder for the specific board you are using. 

