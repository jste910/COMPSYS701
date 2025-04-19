-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY InstructionModule IS

    PORT (
        IM_Store : IN STD_LOGIC;
        IM_Load : IN STD_LOGIC;
        IR_Load : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
        MysteriousGreenLine : OUT STD_LOGIC;
        RandomBlueLine : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rx_Set : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rz_Set : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );

END ENTITY InstructionModule;
ARCHITECTURE behavior OF InstructionModule IS

BEGIN -- no idea what this module does so filling with blanks
    PROCESS (IM_Store, IM_Load, IR_Load, PC)
    BEGIN
        MysteriousGreenLine <= '0'; -- Default value
        RandomBlueLine <= (others => '0'); -- Default value
        Rx_Set <= (others => '0'); -- Default value
        Rz_Set <= (others => '0'); -- Default value
    END PROCESS;

END behavior;