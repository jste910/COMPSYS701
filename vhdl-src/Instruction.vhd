library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity program_mem_module is
	port (
		clk					: in  std_logic;
		rst					: in  std_logic;
		address				: in  std_logic_vector(14 downto 0);
		IM_Store			: in  std_logic;
		IR_Load				: in  std_logic;
		immediate_reg		: out std_logic_vector(15 downto 0);
		instr_header_reg	: out std_logic_vector(15 downto 0)
	);
end program_mem_module;

architecture rtl of program_mem_module is

	signal rom_data			: std_logic_vector(15 downto 0);
	signal immediate_reg_int	: std_logic_vector(15 downto 0);
	signal instr_header_reg_int	: std_logic_vector(15 downto 0);

	-- Component declaration of the prog_mem ROM
	component prog_mem is
		port (
			address	: in  std_logic_vector(14 downto 0);
			clock	: in  std_logic := '1';
			q		: out std_logic_vector(15 downto 0)
		);
	end component;

begin

	-- Instantiate ROM
	prog_mem_inst : prog_mem
		port map (
			address => address,
			clock	=> clk,
			q		=> rom_data
		);

	-- Register loading logic
	process(clk, rst)
	begin
		if rst = '1' then
			immediate_reg_int		<= (others => '0');
			instr_header_reg_int	<= (others => '0');
		elsif rising_edge(clk) then
			if IM_Store = '1' then
				immediate_reg_int <= rom_data;
			end if;

			if IR_Load = '1' then
				instr_header_reg_int <= rom_data;
			end if;
		end if;
	end process;

	-- Output assignments
	immediate_reg		<= immediate_reg_int;
	instr_header_reg	<= instr_header_reg_int;

end rtl;
