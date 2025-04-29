## Instructions to Run on FPGA

### 1. Open Quartus Prime 18.1 and select New Project Wizard

Click `next`

Choose the working idrectory as:

COMPSYS701/Quartus/

Name the project and top level entity with the name `701_Quartus`

Click on next


Select Empty Project and click on next

Click on the highlighted 3 dots:

Navigate to:
COMPSYS701/vhdl-src

and select all the .vhd files

Click `Open`

Click on the highlighted 3 dots again

Naviage to COMPSYS701/vhdl-src

select program.mif

Click `Open`

Click `Next`

Select the Device Family appropriately (Either Cyclone IV or Cyclone V)

Find the appropriate board (look online)

Click on `next` until the `next` button can no longer be pushed

Click on Finish

Setting the top level entity:

Go to the project navigator and switch from Hierarchy to Files

In Files, right-click datapath.vhd and select `set as Top-Level entity`

## Import the pin assignments

To import the pin assignments go to Assignments > Import Assignments

select the 3 dots and find the proper pin assignment file for your board

click `ok`

Compile the design by clicking the Blue Triangle at the top or press `Ctrl + L` on your keyboard

This process should take a little bit of time

Once the compilation is successful

Open the programmer (Blue square icon with a rainbow coming out)
![alt text](image.png)

Select `Hardware Setup`

Make sure that the USB Blaster is selected

Press `Close`

Check the `File` to make sure that the .sof is selected (This should be automatically done by Quartus)

Press `Start`

The Progress bar should then progress to 100%

If successful, the Board should show signs of life


The program.mif that was written to the FPGA was initially written in assembly instructions which was then converted into a .mif file.

1) The assembly instructions in file `program.asm`  can be viewed under `COMPSYS701\assembler\ReCOP-ASM Package\program.asm`

2) The .mif file can be viewed under `COMPSYS701\vhdl-src\program.mif`

To write a program, modify program.asm and use the instructions given in the instruction set. It should be written as normal assembly code, however the specific instructions can be found in the `instruction.md` table at the bottom of this file.

use mrasm.exe

use the command `./mrasm.exe program.asm` this command will output the appropriate .mif and a program.mif which will appear in `vhdl-src`

### Updating MIF file without having to recompile on Quartus Prime 18.1

Since the instructions above allows you to write your own assembly code based off the provided instructions below, the .mif file that is generated can also be updated for the Quartus project without needing to be recompiled. The instructions for this are here:

To update the .mif file

Go to:

Processing -> Update Memory Initialization File

If this fails, then go into

Project > Add/Remove Files in Project

Select `program.mif` and click the remove button on the right

Go to the 3 dots, again, 

Navigate to: COMPSYS701/vhdl-src

select program.mif (This one should be the new program.mif)

Attempt to update the .mif again

Processing -> Update Memory Initialization File

Once that has been done, re-program the FPGA using the same method as  earlier