LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- For incrementing A easily

ENTITY ComparatorTestBench IS
END ComparatorTestBench;

ARCHITECTURE Behavioral OF ComparatorTestBench IS
    SIGNAL A : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL B : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL outline : STD_LOGIC := '0'; -- Output of the comparator

    COMPONENT comparator
        PORT (
            a : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
            b : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
            compare : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    -- Instantiate the adder
    DUT : comparator
    PORT MAP(
        a => A, -- 16-bit input a
        b => B, -- 16-bit input b
        compare => outline
    );

    -- Stimulus process
    PROCESS
    BEGIN
        B <= "0000000000000000"; -- Start A at 0
        A <= "0000000000000000"; -- Start A at 0

        -- Let A count upward
        FOR i IN 0 TO 65535 LOOP
            A <= A + 1; -- Increment A by 1
            WAIT FOR 10 ns;
        END LOOP;

        WAIT; -- Stop simulation
    END PROCESS;
END Behavioral;