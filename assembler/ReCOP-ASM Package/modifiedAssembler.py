import subprocess
import os

def assemble_and_patch_mif(asm_file: str, assembler: str = "mrasm.exe", original_mif: str = "rawOutput.mif", patched_mif: str = "patchedOutput.mif"):
    if not os.path.exists(assembler):
        print(f"Assembler not found at: {assembler}")
        return

    # Step 1: Run the assembler
    result = subprocess.run([assembler, asm_file], capture_output=True, text=True)
    if result.returncode != 0:
        print("Assembler failed with return code:", result.returncode)
        print("STDOUT:\n", result.stdout)
        print("STDERR:\n", result.stderr)
        print("Continuing anyway since output seems valid...\n")

    if not os.path.exists(original_mif):
        print(f"Error: {original_mif} not found after assembly.")
        return

    # Step 2: Read original MIF
    with open(original_mif, "r") as f:
        lines = f.readlines()

    try:
        content_start = next(i for i, line in enumerate(lines) if "CONTENT" in line)
        begin_index = next(i for i, line in enumerate(lines) if "BEGIN" in line and i > content_start)
        end_index = next(i for i, line in enumerate(lines) if "END;" in line and i > begin_index)
    except StopIteration:
        print("Error: Unexpected MIF format.")
        return

    header = lines[:begin_index + 1]
    content_lines = lines[begin_index + 1:end_index]
    footer = lines[end_index:]

    # Step 3: Patch content (insert 0000 after every NOOP (3400))
    patched_content = []
    address = 0
    for line in content_lines:
        stripped = line.strip()

        # Keep the default fill line ([00..3FF]: FFFF;)
        if stripped.startswith('[') and 'FFFF' in stripped:
            patched_content.append(line)
            continue

        if not stripped or ':' not in stripped:
            continue  # Skip empty or malformed lines

        addr_str, value = stripped.split(':')
        value = value.strip().strip(';')

        # Add the current instruction line with the correct indentation
        patched_content.append(f"\t\t{format(address, 'X')}\t:{value};\n")
        address += 1

        # Add padding after NOOP (3400)
        if value.upper() == "3400":
            patched_content.append(f"\t\t{format(address, 'X')}\t:0000;\n")
            address += 1

    # Step 4: Write to new patched MIF file
    with open(patched_mif, "w") as f:
        f.writelines(header)
        f.writelines(patched_content)
        f.writelines(footer)

    print(f"✅ Patched MIF created: {patched_mif}")

# Example usage
assemble_and_patch_mif("test.asm")
