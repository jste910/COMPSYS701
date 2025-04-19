library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- For incrementing A easily

entity Testbench is
end Testbench;

architecture Behavioral of Testbench is
    signal A    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal B    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal Cin  : STD_LOGIC := '0';
    signal Sum  : STD_LOGIC_VECTOR(15 downto 0);
    signal Cout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');

    component Adder16Bit
        Port (
            a     : in  STD_LOGIC_VECTOR(15 downto 0);
            b     : in  STD_LOGIC_VECTOR(15 downto 0);
            carry_in   : in  STD_LOGIC;
            sum   : out STD_LOGIC_VECTOR(15 downto 0);
            carry_out  : out STD_LOGIC
        );
    end component;
begin
    -- Instantiate the adder
    DUT: Adder16Bit
        port map (
            a => A,
            b => B,
            carry_in => Cin,
            sum => Sum,
            carry_out => Cout(1)
        );

    -- Stimulus process
    process
    begin
        -- Set B to constant 4
        B <= "0000000000000100"; -- decimal 4
        A <= "0000000000000000"; -- Start A at 0

        -- Let A count upward
        for i in 0 to 65535 loop
            A <= A + 1; -- Increment A by 1
            wait for 10 ns;
        end loop;

        wait; -- Stop simulation
    end process;
end Behavioral;
