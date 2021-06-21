# FPGA MIPS Processor

## Summary

This project was the culmination of everything we learned in ECEGR 2220 Microprocessor Design class. We created a (stripped-down) single-cycle MIPS processor in VHDL. It was limited to the MIPS instructions: `add`, `sub`, `and`, `or`, `addi`, `lw`, `sw`, `beq`, `j`, `sll`, and `srl`.

## How to run

Roughly follow the instructions on [Intel's website](https://software.intel.com/content/www/us/en/develop/articles/how-to-program-your-first-fpga-device.html)

- Install Quartus Prime Lite
- Start a new Quartus project for your FPGA
- Add the files in the GitHub repo to your project
- Set MIPS.vhd as the Top-Level Entity by right-clicking the file
- Start compilation (Ctrl+L)
- Go to Tools → Programmer, and click Auto Detect
- Click on the JTAG chain for the FPGA (not the HPS)
- Click Add File and select output_files/MIPS.sof
- Delete the redundant option in the list that does not have the file
- Click Start
