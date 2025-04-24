-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;


ENTITY ProgramCounter IS

    PORT (
        Rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
        RandomBlueLine : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
        Adder_Out : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
        PC_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- 16-bit input b
    );

END ENTITY ProgramCounter;
ARCHITECTURE behavior OF ProgramCounter IS

BEGIN

    PROCESS (PC_SEL, Rx, RandomBlueLine, Adder_Out)
    variable PC_var : natural range 0 to 5 := 0;

    BEGIN
        CASE PC_SEL IS
            WHEN "00" => -- PC = PC + 1
                PC_var := Rx + 1;
            WHEN "01" => -- PC = RandomBlueLine
                PC_var := RandomBlueLine;
            WHEN "10" => -- PC = Adder_Out
                PC_var := Adder_Out;
            WHEN OTHERS => -- Default case
                PC_var := (OTHERS => '0'); -- Set to zero or some default value
        END CASE;
        PC <= PC_var;
    END PROCESS;
END behavior;