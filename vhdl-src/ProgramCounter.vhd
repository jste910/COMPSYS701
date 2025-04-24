LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ProgramCounter IS
    PORT (
        Rx             : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
        RandomBlueLine : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
        Adder_Out      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input c
        PC_SEL         : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  -- Selector
        CLK            : IN  STD_LOGIC;                     -- Clock signal
        PC             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)  -- 16-bit output
    );
END ENTITY ProgramCounter;

ARCHITECTURE behavior OF ProgramCounter IS
BEGIN
    PROCESS (CLK)
        VARIABLE PC_var : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        IF rising_edge(CLK) THEN
            CASE PC_SEL IS
                WHEN "00" => -- PC = Rx + 1
                    PC_var := std_logic_vector(unsigned(Rx) + to_unsigned(1, Rx'length));
                WHEN "01" => -- PC = RandomBlueLine
                    PC_var := RandomBlueLine;
                WHEN "10" => -- PC = Adder_Out
                    PC_var := Adder_Out;
                WHEN OTHERS => -- Default case
                    PC_var := (OTHERS => '0'); -- Set to zero or some default value
            END CASE;
            PC <= PC_var;
        END IF;
    END PROCESS;
END ARCHITECTURE behavior;
