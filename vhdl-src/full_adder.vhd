-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY full_adder IS
    PORT (
        a : IN STD_LOGIC;
        b : IN STD_LOGIC;
        carry_in : IN STD_LOGIC;
        sum : OUT STD_LOGIC;
        carry_out : OUT STD_LOGIC
    );
END ENTITY full_adder;
ARCHITECTURE behavior OF full_adder IS
    Component half_adder
        PORT (
            a : IN STD_LOGIC;
            b : IN STD_LOGIC;
            sum : OUT STD_LOGIC;
            carry_out : OUT STD_LOGIC
        );
    END COMPONENT;
    signal sum1 : STD_LOGIC;
    signal carry1 : STD_LOGIC;
    signal carry2 : STD_LOGIC;
BEGIN
    HA1: half_adder PORT MAP (a, b, sum1, carry1);
    HA2: half_adder PORT MAP (sum1, carry_in, sum, carry2);
    carry_out <= carry1 OR carry2;
END behavior;