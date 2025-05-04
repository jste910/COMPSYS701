import subprocess
import argparse
import os

def binToHex(b): # b probably is a string
    bLookup = {'0000': '0', '0001': '1', '0010': '2', '0011': '3', '0100': '4', '0101': '5', '0110': '6', '0111': '7', '1000': '8', '1001': '9', '1010': 'A', '1011': 'B', '1100': 'C', '1101': 'D', '1110': 'E', '1111': 'F'}
    if len(b) % 4 != 0:
        print("Error: Not enough bits")
        return "XXXX"
    h = ""
    for i in range(0, len(b), 4):
        sub = b[i:i+4]
        if sub in bLookup:
            h += bLookup[sub]
    return h

def hextobin(hx): # hex is a string
    # convert hex to binary with a padding so it is always a multiple of 4
    b=""
    for c in hx:
        b += bin(int(c, 16))[2:].zfill(4) # convert to binary and pad with 0s
    return b

def dectobin(dec):
    # convert decimal to binary with a padding so it is always a multiple of 4
    binary = f"{dec:b}"
    pad_length = (4 - (len(binary) % 4)) % 4
    return "0" * pad_length + binary

def modifyParts(parts, lookup):
    bLookup = {"0" : "0000","1" : "0001","2" : "0010","3" : "0011","4" : "0100","5" : "0101","6" : "0110","7" : "0111","8" : "1000","9" : "1001","10" : "1010","11" : "1011","12" : "1100","13" : "1101","14" : "1110","15" : "1111"} # dec to bin
    instruction = "X"
    address = "XX"
    rString = ""
    # find the last
    p = parts[-1]
    if p[0] == "R": # Register
        address = "11"
    elif p[0] == "#": # Immediate
        address = "01"
    elif p[0] == "$": # Direct
        address = "10"
    elif p in ['CLFZ', "CER", "CEOT", "SEOT", 'NOOP']: # Inherent
        address = "00"
    else:
        if p in lookup: # Lookup table
            address = "01" # Immediate (idk)
        else:
            address = "XX"

    if parts[0] == "AND":
        instruction = "001000"
        # remaing parts
        if parts[-1][0] == "#": # is an immediate value
            # we have Rz, Rx #immediate
            # Rz is 1 and Rx is 2
            rString = bLookup[parts[1][1:]] + bLookup[parts[2][1:]] + dectobin(int(parts[-1][1:])).rjust(16, "0")
        else: # We have a Register
            # we have Rz Rz Rx
            rString = bLookup[parts[-2][1:]] + bLookup[parts[-1][1:]]

    if parts[0] == "OR":
        instruction = "001100"
        # remaing parts
        if parts[-1][0] == "#": # is an immediate value
            # we have Rz, Rx #immediate
            # Rz is 1 and Rx is 2
            rString = bLookup[parts[1][1:]] + bLookup[parts[2][1:]] + dectobin(int(parts[-1][1:])).rjust(16, "0")
        else: # We have a Register
            # we have Rz Rz Rx
            rString = bLookup[parts[-2][1:]] + bLookup[parts[-1][1:]]
    if parts[0] == "ADD":
        instruction = "111000"
        # remaing parts
        if parts[-1][0] == "#": # is an immediate value
            # we have Rz, Rx #immediate
            # Rz is 1 and Rx is 2
            rString = bLookup[parts[1][1:]] + bLookup[parts[2][1:]] + dectobin(int(parts[-1][1:])).rjust(16, "0")
        else: # We have a Register
            # we have Rz Rz Rx
            rString = bLookup[parts[-2][1:]] + bLookup[parts[-1][1:]]
    if parts[0] == "SUBV":
        instruction = "000011"
        rString = bLookup[parts[1][1:]] + bLookup[parts[2][1:]] + dectobin(int(parts[-1][1:])).rjust(16, "0")

    if parts[0] == "SUB":
        instruction = "000100"
        rString = bLookup[parts[1][1:]] + dectobin(int(parts[-1][1:])).rjust(20, "0")
    if parts[0] == "LDR":
        instruction = "000000"
        # remaing parts
        if parts[-1][0] == "#": # is an immediate value
            # we have Rz #immediate
            # Rz is 1 and Rx is 2
            rString = bLookup[parts[1][1:]] + dectobin(int(parts[-1][1:])).rjust(20, "0")
        elif parts[-1][0] == "$": # is a direct value
            rString = bLookup[parts[1][1:]] + hextobin((parts[-1][1:])).rjust(20, "0")
        else: # We have a Register
            # we have Rz Rx
            rString = bLookup[parts[-2][1:]] + bLookup[parts[-1][1:]]
    if parts[0] == "STR":
        instruction = "000010"
        if parts[-1][0] == "#": # is an immediate value
            # we have Rz #immediate
            # Rz is 1 and Rx is 2
            rString = bLookup[parts[1][1:]] + dectobin(int(parts[-1][1:])).rjust(20, "0")
        elif parts[-1][0] == "$": # is a direct value
            rString = "0000" + bLookup[parts[1][1:]] + hextobin((parts[-1][1:])).rjust(16, "0")
        else: # We have a Register
            # we have Rz Rx
            rString = bLookup[parts[-2][1:]] + bLookup[parts[-1][1:]]
    if parts[0] == "JMP":
        instruction = "011000"
        if parts[-1][0].islower(): # is an immediate value
            # we have Rz #immediate
            rString = hextobin(str(lookup[parts[-1]])).rjust(24, "0")
        else: # register
            rString = "0000" + bLookup[parts[-1][1:]]
    if parts[0] == "PRESENT":
        instruction = "011100"
        rString = bLookup[parts[1][1:]] + hextobin(str(lookup[parts[-1]])).rjust(20, "0")
    if parts[0] == "DATACALL":
        instruction = "101000"
        rString = "0000" + bLookup[parts[1][1:]]
        if parts[-1][0] == "#":
            instruction = "101001"
            rString += dectobin(int(parts[-1][1:])).rjust(16, "0")
    if parts[0] == "SZ":
        instruction = "010100"
        rString = hextobin(str(lookup[parts[-1]])).rjust(24, "0")
    if parts[0] == "CLFZ":
        instruction = "010000"
        rString = "00000000"
    if parts[0] == "CER":
        instruction = "111100"
        rString = "00000000"
    if parts[0] == "CEOT":
        instruction = "111110"
        rString = "00000000"
    if parts[0] == "SEOT":
        instruction = "111111"
        rString = "00000000"
    if parts[0] == "LER":
        instruction = "110110"
        rString = bLookup[parts[1][1:]] + "0000"
    if parts[0] == "SSVOP":
        instruction = "111011"
        rString = "0000" + bLookup[parts[1][1:]]
    if parts[0] == "LSIP":
        instruction = "110111"
        rString = bLookup[parts[1][1:]] + "0000"
    if parts[0] == "SSOP":
        instruction = "111010"
        rString = "0000" + bLookup[parts[1][1:]]
    if parts[0] == "NOOP":
        instruction = "110100"
        rString = "00000000"
    if parts[0] == "MAX":
        instruction = "011110"
        rString = bLookup[parts[1][1:]] + dectobin(int(parts[-1][1:])).rjust(20, "0")
    if parts[0] == "STRPC":
        instruction = "011101"
        rString = hextobin(parts[-1][1:]).rjust(24, "0")
    if parts[0] == "HALT":
        address = "00"
        instruction = "000110"
        rString = "00000000"

    # get the hex equivalent of the binary string
    ai = binToHex(address + instruction) + binToHex(rString)

    print(parts, ai)
    return ai

def main():

    parser = argparse.ArgumentParser(description = "Beta's Assembler")
    parser.add_argument("-f", "--inputfile", help = "Input file, use r/ for root directory (./COMPSYS701)", type = str, default = "X")
    parser.add_argument("-o", "--outputfile", help = "Output file, use r/ for root directory (./COMPSYS701)", type = str, default = "X") # in case we can manipulate it
    parser.add_argument("--keepHex", help = "Enable this option to keep the hex file", action="store_true") # keep the hex file
    parser.add_argument("--noverify", help = "Enable this option to explicitly skip the verification stage", action="store_true") # keep the hex file
    args = parser.parse_args()

    inputfile = args.inputfile
    outputfile = args.outputfile
    keepHex = args.keepHex # keep the hex file
    noverify = args.noverify # keep the hex file
    root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "COMPSYS701")) # get the root directory

    if inputfile == "X":
        print("Error: No input file specified")
        return

    if inputfile[:2] == "r/":
        inputfile = os.path.join(root, inputfile[2:])
    if outputfile[:2] == "r/":
        outputfile = os.path.join(root, outputfile[2:])
    if outputfile == "X": # didn't specify an output file, we will use the input file name
        outputfile = os.path.join(os.path.dirname(inputfile), os.path.basename(inputfile)[:-4] + ".mif")
    if not os.path.exists(inputfile):
        print(f"Error: Input file {inputfile} does not exist")
        return
    
    print("=============== First Pass ===============")
    lookup = {}
    finallines = []
    with open(inputfile, "r") as file:
        lines = file.readlines()
        idx = 0
        for line in (lines):
            # we need to filter out the commends, empty lines and tabs or spaces
            l = line.strip()
            if l == "" or l[0] == ";" or l == "ENDPROG" or l == "END": # I hope l == "\n" is not needed
                continue # we don't care about endprog
            if l.count(";") > 0: # if there is a comment, we need to remove it
                l = l.split(";")[0] # remove the comment
            # if the line has a lowecase first letter, add it to the lookup table
            if l[0].islower():
                lookup[f"{l}"] = idx
                continue
            print(f"Line {idx} : {l}")
            finallines.append(l) # add to the next pass
            idx+= 1

    print(f"Lookup table: {lookup}")
    print("=============== Second Pass ===============")
    o = []
    for line in finallines: # second pass
        parts = line.strip().split()
        output = modifyParts(parts, lookup)
        o.append(output)

    # writing the .mif file
    with open(f"{outputfile}", "w") as file:
        file.write("WIDTH = 16;\n")
        file.write("DEPTH = 1024;\n\n") # double newline
        file.write("ADDRESS_RADIX = HEX;\n")
        file.write("DATA_RADIX = HEX;\n\n") # double newline
        file.write("CONTENT\n\tBEGIN\n")
        file.write("\t\t[00..3FF]: FFFF;\n")
        c = 0
        for i in range(len(finallines)):
            if len(o[i]) == 4:
                # we have a 4 bit instruction, we need to add the address
                file.write(f"\t\t{c:X}\t:{o[i]};\n")
            elif len(o[i]) == 8:
                # we have a 8 bit instruction
                file.write(f"\t\t{c:X}\t:{o[i][:4]};\n")
                c += 1
                # we need to add the next part
                file.write(f"\t\t{c:X}\t:{o[i][4:]};\n")
            else:
                # issue
                print(f"Error: {o[i]} is not a valid instruction.... Skipping...")
            c += 1

        if o[-1] != "0600":
            # we need to add the last part
            file.write(f"\t\t{c:X}\t:0600;\n")

        file.write("\tEND;\n")
    # end of .mif write

    if noverify:
        print("No verification, skipping mrasm")
        return

    print("===============MR ASM ===============")
    # run mrasm to check the output
    print(f"Running mrasm on {inputfile} with {root}")
    exe = os.path.join(root, "assembler\\mrasm.exe ")
    mrasmcall = exe + args.inputfile.strip().split("/")[-1] # get the path to the file
    # we can add the output file to match
    print(f"Running: {mrasmcall}")
    s = subprocess.run(mrasmcall, stdout = subprocess.PIPE, stderr = subprocess.STDOUT, text=True)
    assembleroutput = open("assemblerOutput.txt", "w")
    assembleroutput.write(s.stdout) # write the output to a file
    assembleroutput.close()
    print("File Written to assemblerOutput.txt")

    found = False
    with open("assemblerOutput.txt", "r") as file:
        lines = file.readlines()
        for line in lines:
            if "  Assembly process complete             |" in line:
                found = True
                break

    if found:
        print("MrASM Assembly process complete")
    else:
        print("MrASM Assembly process failed")
        return

    print("=====================================")
    # because mrasm is junk we need to remove other files that it outputs
    rmlist = [".txt", "debug.lines", "out.txt", "LUT", "mrasm.exe.stackdump"]
    pth = (root + "\\assembler\\")
    for i in rmlist:
        if os.path.exists(pth + i):
            os.remove(i) # remove the file
    if not keepHex:
        if os.path.exists(pth + "rawOutput.hex"):
            os.remove(pth + "rawOutput.hex")
    mrasmoutput = os.path.join(pth, "rawOutput.mif")

    print(f"Comparing {mrasmoutput} and {outputfile}")

    fileright = open(mrasmoutput, "r")
    filecheck = open(outputfile, "r")

    filerightlines = fileright.readlines()
    filechecklines = filecheck.readlines()
    fileright.close()
    filecheck.close()
    error_lines = 0
    warning_lines = 0
    
    for i in range(len(filerightlines)):
        if filerightlines[i] != filechecklines[i]:
            # check the previous instruction
            if i>0: # make sure we don't negative index
                instruction = filechecklines[i-1].strip().split(":")[1][0:2]
                if instruction == "54" or instruction == "5C" or instruction == "58":
                    # if it is one of these it is a jump instruction
                    print("[WARNING]: Instruction involves a keyword, outputs may differ:", end = " ")
                    warning_lines += 1
                elif filerightlines[0:2] == 68: # false datacall
                    print("[WARNING]: MrASM has an incorrect datacall function:", end = " ")
                    warning_lines += 1
                elif filerightlines[i] == "\tEND;\n":
                    print("[WARNING]: End of program was manually inserted:", end = " ")
                    warning_lines += 1
            else:
                error_lines += 1
            print(f"Expected: {filerightlines[i].strip()}", end = "")
            print(f" Got: {filechecklines[i].strip()}", end = "")
            print()
    # summary
    print(f"Errors: {error_lines}")
    print(f"Warnings: {warning_lines}")

if __name__ == "__main__":
    main()
