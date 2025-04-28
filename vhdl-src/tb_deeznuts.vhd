LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_deezuts IS
END ENTITY tb_deezuts;

ARCHITECTURE behavior OF tb_deezuts IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT deeznutspath
        PORT (
            PROGRAM_COUNTER_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            RZ_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            RX_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            R7_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            IMMEDIATE_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            INSTRUCTION_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            ALU_OUTPUT_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            DATAM_OUT_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            SIP_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            ER_output : OUT STD_LOGIC;
            -- Input signalsj 
            INPUT_CLK : IN STD_LOGIC
        );
    END COMPONENT;

    -- Testbench signals
    SIGNAL INPUT_CLK : STD_LOGIC := '0';
    -- Exposed data signals
    SIGNAL PROGRAM_COUNTER_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RZ_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RX_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL R7_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL IMMEDIATE_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL INSTRUCTION_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ALU_OUTPUT_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL DATAM_OUT_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL SIP_output : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ER_output : STD_LOGIC;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : deeznutspath
    PORT MAP(
        PROGRAM_COUNTER_output => PROGRAM_COUNTER_output,
        RZ_output => RZ_output,

        RX_output => RX_output,
        R7_output => R7_output,
        IMMEDIATE_output => IMMEDIATE_output,-- : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        INSTRUCTION_output => INSTRUCTION_output, -- OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ALU_OUTPUT_output => ALU_OUTPUT_output, --  OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DATAM_OUT_output => DATAM_OUT_output, -- : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIP_output => SIP_output, --: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ER_output => ER_output, --: OUT STD_LOGIC;
        INPUT_CLK => INPUT_CLK

    );

    -- Clock generation process
    CLK_PROCESS : PROCESS
    BEGIN
        -- Generate a clock signal with a period of 20 ns
        INPUT_CLK <= '0';
        WAIT FOR 10 ns;
        INPUT_CLK <= '1';
        WAIT FOR 10 ns;
    END PROCESS CLK_PROCESS;

    -- No other stimulus, just let the clock run
    -- The signals will be driven by the UUT based on internal logic
    -- Wait for the simulation to end

END ARCHITECTURE behavior;