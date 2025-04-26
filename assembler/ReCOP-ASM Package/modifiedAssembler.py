import os
import subprocess
import argparse

# Define opcodes that represent jump instructions
JUMP_OPCODES = {"111001", "111000"}  # PRESENT, JMP

def hex16(val):
    return format(val & 0xFFFF, '04X')

def bin_str(hex_val):
    return format(int(hex_val, 16), '016b')

def is_noop(word):
    return word.upper() == "3400"

def is_jump_instruction(word):
    binary = bin_str(word)
    opcode = binary[2:8]  # Skip AM bits
    return opcode in JUMP_OPCODES

def assemble_and_patch_mif(asm_file, output_mif=None, assembler="mrasm.exe", original_mif="rawOutput.mif"):
    if not os.path.exists(assembler):
        print(f"Assembler not found at: {assembler}")
        return

    if output_mif is None:
        output_mif = os.path.splitext(asm_file)[0] + "_patched.mif"

    # Run the assembler
    subprocess.run([assembler, asm_file], capture_output=True)

    if not os.path.exists(original_mif):
        print(f"❌ Error: {original_mif} not found.")
        return

    # Read MIF contents
    with open(original_mif, "r") as f:
        lines = f.readlines()

    try:
        content_start = next(i for i, line in enumerate(lines) if "CONTENT" in line)
        begin_index = next(i for i, line in enumerate(lines) if "BEGIN" in line and i > content_start)
        end_index = next(i for i, line in enumerate(lines) if "END;" in line and i > begin_index)
    except StopIteration:
        print("❌ Error: MIF format is invalid.")
        return

    header = lines[:begin_index + 1]
    content_lines = lines[begin_index + 1:end_index]
    footer = lines[end_index:]

    # Parse memory content lines
    addr_line_map = {}
    for line in content_lines:
        if ':' not in line or line.strip().startswith('['):
            continue
        parts = line.strip().split(':')
        addr = int(parts[0].strip(), 16)
        data = parts[1].strip().strip(';').upper()
        addr_line_map[addr] = data

    # Group words into full instructions (1 or 2 words)
    instruction_map = {}
    i = 0
    keys = sorted(addr_line_map.keys())
    while i < len(keys):
        addr = keys[i]
        word1 = addr_line_map[addr]
        if is_noop(word1):
            instruction_map[addr] = (word1,)
            i += 1
        else:
            if i + 1 < len(keys):
                word2 = addr_line_map[keys[i + 1]]
                instruction_map[addr] = (word1, word2)
                i += 2
            else:
                instruction_map[addr] = (word1,)
                i += 1

    # Build original ➡ padded address map
    original_to_padded = {}
    padded_instructions = []
    padded_addr = 0
    jump_fixups = {}  # padded address ➡ original jump target

    for old_addr in sorted(instruction_map.keys()):
        instr = instruction_map[old_addr]
        original_to_padded[old_addr] = padded_addr
        if len(instr) == 2:
            original_to_padded[old_addr + 1] = padded_addr + 1

        # Write first word
        padded_instructions.append((padded_addr, instr[0]))
        padded_addr += 1

        # Handle NOOP
        if is_noop(instr[0]):
            padded_instructions.append((padded_addr, "0000"))
            padded_addr += 1

        # Handle 2nd word
        elif len(instr) == 2:
            if is_jump_instruction(instr[0]):
                old_target = int(instr[1], 16)
                jump_fixups[padded_addr] = old_target
                padded_instructions.append((padded_addr, "TO_BE_FIXED"))
            else:
                padded_instructions.append((padded_addr, instr[1]))
            padded_addr += 1

    # Apply jump target fixups
    for i, (addr, word) in enumerate(padded_instructions):
        if word == "TO_BE_FIXED":
            old_target = jump_fixups[addr]
            new_target = original_to_padded.get(old_target, old_target)
            padded_instructions[i] = (addr, hex16(new_target))

    # Optional debug map output
    print("\n--- Address Map (Original ➡ Padded) ---")
    for orig in sorted(original_to_padded):
        print(f"Original {orig:04X} ➡ Padded {original_to_padded[orig]:04X}")

    # Write final MIF
    with open(output_mif, "w") as f:
        f.writelines(header)
        for addr, word in padded_instructions:
            f.write(f"\t\t{format(addr, 'X')}\t:{word};\n")
        f.writelines(footer)

    print(f"\n✅ Patched MIF created: {output_mif}")

# Entry point
def main():
    parser = argparse.ArgumentParser(description="Patch MIF by padding NOOPs and fixing jump targets.")
    parser.add_argument("asm_file", help="Path to input .asm file")
    parser.add_argument("output_mif", nargs="?", help="Optional output .mif file name")
    args = parser.parse_args()

    assemble_and_patch_mif(args.asm_file, args.output_mif)

if __name__ == "__main__":
    main()
