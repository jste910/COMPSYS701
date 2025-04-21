-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY ControlUnit IS

    PORT (
        Address_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Address select for the instruction memory
        Data_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Data select for the data memory
        ALU_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        Reg_Select : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register select for the register file
        PC_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        CMP0 : IN STD_LOGIC;
        MysteriousGreenLine : IN STD_LOGIC; -- Control signal for the instruction memory
        IM_Store : OUT STD_LOGIC; -- Control signal for the instruction memory
        IM_Load : OUT STD_LOGIC; -- Control signal for the instruction memory
        IR_Load : OUT STD_LOGIC; -- Control signal for the instruction memory
        Register_Store : IN STD_LOGIC; -- Control signal for the register file
        ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- ALU operation code
        DM_LOAD : OUT STD_LOGIC; -- Control signal for the data memory load
        DM_STORE : OUT STD_LOGIC -- Control signal for the data memory store
    );

END ENTITY ControlUnit;
ARCHITECTURE behavior OF ControlUnit IS

BEGIN -- no idea what this module does
    Address_Select <= "00";
    Data_Select <= "00";
    ALU_Select <= "00";
    Reg_Select <= "000";
    PC_Select <= "00";
    IM_Store <= '0';
    IM_Load <= '0';
    IR_Load <= '0';
    ALU_OP <= "000";
    DM_LOAD <= '0';
    DM_STORE <= '0';

END behavior;