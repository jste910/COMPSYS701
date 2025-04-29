-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY half_adder IS
    PORT (
        a : IN STD_LOGIC;
        b : IN STD_LOGIC;
        sum : OUT STD_LOGIC;
        carry_out : OUT STD_LOGIC
    );
END ENTITY half_adder;
ARCHITECTURE behavior OF half_adder IS
BEGIN
    sum <= a XOR b;
    carry_out <= a AND b;
END behavior;