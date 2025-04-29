-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY comparator IS
    PORT (
        a : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
        b : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
        compare : OUT STD_LOGIC
    );
END ENTITY comparator;
ARCHITECTURE behavior OF comparator IS

BEGIN
    compare <= '1' WHEN a = b else '0'; -- Compare the two inputs for equality
END behavior;