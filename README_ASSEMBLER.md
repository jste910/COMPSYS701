# Beta Assembler

## Overview

This project includes an assembler executable, `mrasm.exe`, which can be used to assemble assembly language source files (`.asm` files).

This project includes an assembler `betaAssembler.py`, which can be used to assemble assembly language source files (`.asm` files). This assembler can be verified through the MrASM assembler

### Options
| Command | Action |
| - | - |
|-h|find the help command|
|-i|specify the input file|
|-o|specify the output file|
|--keepHex|keep the rawOutput.hex from MrASM (not generated if using --noverify)|
|--noverify|don't verify the output|


## How to Use

### 1. Navigate to the Assembler Directory

Open a terminal or command prompt and navigate to the following directory in our provided zip file:
`COMPSYS701\assembler` 

### 2. Run the Assembler

To assemble an assembly file, run the following command:
`python betaAssembler.py -f led.asm`

This will assemble the `led.asm` file.

### 3. Assemble a Different File

To assemble a different file, simply replace `test.asm` with the name of your `.asm` source file. For example:

`python betaAssembler.py -f yourfile.asm`

### 4. Output 
There will be a .mif file generated with the same name as the input unless -o was specified. The contents of the .mif file should be copied into the `program.mif` file inside the folder for the specific board you are using.
