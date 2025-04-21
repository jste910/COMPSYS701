-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Adder16Bit IS
    PORT (
        a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        carry_in : IN STD_LOGIC;
        sum : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        carry_out : OUT STD_LOGIC
    );
END ENTITY Adder16Bit;
ARCHITECTURE behavior OF Adder16Bit IS
    Component full_adder
        PORT (
            a : IN STD_LOGIC;
            b : IN STD_LOGIC;
            carry_in : IN STD_LOGIC;
            sum : OUT STD_LOGIC;
            carry_out : OUT STD_LOGIC
        );
    END COMPONENT;

    signal C : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
    
BEGIN
    FULLADDER0 : full_adder PORT MAP (a(0), b(0), carry_in, sum(0), C(0));
    FULLADDER1 : full_adder PORT MAP (a(1), b(1), C(0), sum(1), C(1));
    FULLADDER2 : full_adder PORT MAP (a(2), b(2), C(1), sum(2), C(2));
    FULLADDER3 : full_adder PORT MAP (a(3), b(3), C(2), sum(3), C(3));
    FULLADDER4 : full_adder PORT MAP (a(4), b(4), C(3), sum(4), C(4));
    FULLADDER5 : full_adder PORT MAP (a(5), b(5), C(4), sum(5), C(5));
    FULLADDER6 : full_adder PORT MAP (a(6), b(6), C(5), sum(6), C(6));
    FULLADDER7 : full_adder PORT MAP (a(7), b(7), C(6), sum(7), C(7));
    FULLADDER8 : full_adder PORT MAP (a(8), b(8), C(7), sum(8), C(8));
    FULLADDER9 : full_adder PORT MAP (a(9), b(9), C(8), sum(9), C(9));
    FULLADDER10 : full_adder PORT MAP (a(10), b(10), C(9), sum(10), C(10));
    FULLADDER11 : full_adder PORT MAP (a(11), b(11), C(10), sum(11), C(11));
    FULLADDER12 : full_adder PORT MAP (a(12), b(12), C(11), sum(12), C(12));
    FULLADDER13 : full_adder PORT MAP (a(13), b(13), C(12), sum(13), C(13));
    FULLADDER14 : full_adder PORT MAP (a(14), b(14), C(13), sum(14), C(14));
    FULLADDER15 : full_adder PORT MAP (a(15), b(15), C(14), sum(15), carry_out);
END behavior;