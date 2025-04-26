library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity program_mem_module is
	port (
		clk			: in  std_logic;
		rst			: in  std_logic;
		address		: in  std_logic_vector(14 downto 0);
		IM_Store	: in  std_logic;
		IR_Load		: in  std_logic;
		im_reg_out	: out std_logic_vector(15 downto 0);
		ir_reg_out	: out std_logic_vector(15 downto 0)
	);
end program_mem_module;

architecture rtl of program_mem_module is

	signal rom_data	: std_logic_vector(15 downto 0);
	signal im_reg	: std_logic_vector(15 downto 0);
	signal ir_reg	: std_logic_vector(15 downto 0);

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

	-- IM and IR register logic
	process(clk, rst)
	begin
		if rst = '1' then
			im_reg <= (others => '0');
			ir_reg <= (others => '0');
		elsif rising_edge(clk) then
			if IM_Store = '1' then
				im_reg <= rom_data;
			end if;

			if IR_Load = '1' then
				ir_reg <= rom_data;
			end if;
		end if;
	end process;

	im_reg_out <= im_reg;
	ir_reg_out <= ir_reg;

end rtl;
