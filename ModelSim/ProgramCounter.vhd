LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ProgramCounter IS
    PORT (
        Rx             : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
        Immediate      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
        PC_SEL         : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  -- Selector
        PC_SET         : IN  STD_LOGIC;                     -- Latch the value
        CLK            : IN  STD_LOGIC;                     -- Clock signal
        PC             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)  -- 16-bit output
    );
END ENTITY ProgramCounter;

ARCHITECTURE behavior OF ProgramCounter IS
    SIGNAL PC_SIG : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
BEGIN
    PROCESS (CLK)
    BEGIN
        IF falling_edge(CLK) THEN
            IF PC_SET = '1' THEN
                CASE PC_SEL IS
                    WHEN "00" => -- PC = PC + 2
                    PC_SIG <= std_logic_vector(unsigned(PC_SIG) + 1);
                    WHEN "01" => -- PC = Immediate
                        PC_SIG <= Immediate;
                    WHEN "10" => -- PC = Rx
                        PC_SIG <= Rx;
                    WHEN OTHERS => -- Default case
                        PC_SIG <= X"0000";
                END CASE;
            END IF;
        END IF;
    END PROCESS;
    PC <= PC_SIG;
END ARCHITECTURE behavior;
