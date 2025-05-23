-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY DataMemoryModule IS
    PORT (
        Address_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Address selection signal
        Data_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Data selection signal
        Immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
        Rz : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
        Rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
        PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
        DM_LOAD : IN STD_LOGIC; -- Data memory load signal
        DM_STORE : IN STD_LOGIC; -- Data memory store signal
        DM_CLK : IN STD_LOGIC; -- Data memory clock signal
        DM_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Data memory output
    );

END ENTITY DataMemoryModule;
ARCHITECTURE behavior OF DataMemoryModule IS

    COMPONENT data_mem
        PORT (
            address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            clock : IN STD_LOGIC;
            data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            wren : IN STD_LOGIC;
            q : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL dataLine : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data line for data memory
    SIGNAL addressLine : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    data_mem_inst : data_mem
    PORT MAP(
        address => addressLine(11 DOWNTO 0), -- I don't get this
        clock => DM_CLK, -- Clock input
        data => dataLine, -- Data input (not sure what should be going here)
        wren => DM_STORE, -- Write enable signal (not sure what should be going here)
        q => DM_OUT -- Data output
    );

    PROCESS(Address_SEL, Data_SEL, Immediate, Rz, Rx, PC)
    BEGIN
        CASE Address_SEL IS
            WHEN "00" => -- Address selection for PC
                addressLine <= Immediate;
            WHEN "01" => -- Address selection for Rz
                addressLine <= Rz;
            WHEN "10" => -- Address selection for Rx
                addressLine <= Rx;
            WHEN OTHERS => -- Default case
                addressLine <= (OTHERS => '0'); -- Set to zero or some default value
        END CASE;
        CASE Data_SEL IS
            WHEN "00" => -- Data selection for Immediate
                dataLine <= Immediate;
            WHEN "01" => -- Data selection for Rx
                dataLine <= Rx;
            WHEN "10" => -- Data selection for PC
                dataLine <= PC;
            WHEN OTHERS => -- Default case
                dataLine <= (OTHERS => '0'); -- Set to zero or some default value
        END CASE;
    END PROCESS;
END behavior;