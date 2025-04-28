LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY datapath_tb IS
END ENTITY datapath_tb;

ARCHITECTURE behavior OF datapath_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT datapath
    PORT (
        INPUT_CLK       : IN  STD_LOGIC;
        PROCESSOR_CLK   : OUT STD_LOGIC;
        RESET           : IN  STD_LOGIC;
        INIT            : IN  STD_LOGIC := '1';
        
        -- Exposed data signals for monitoring
        PROGRAM_COUNTER : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RZ              : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RX              : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        R7              : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IMMEDIATE       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        INSTRUCTION     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ALU_OUTPUT      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DATAM_OUT       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIP             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ER              : OUT STD_LOGIC
    );
    END COMPONENT;

    -- Testbench signals
    SIGNAL INPUT_CLK       : STD_LOGIC := '0';
    SIGNAL PROCESSOR_CLK   : STD_LOGIC;
    SIGNAL RESET           : STD_LOGIC := '0';
    SIGNAL INIT            : STD_LOGIC := '1';
    
    -- Exposed data signals
    SIGNAL PROGRAM_COUNTER : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RZ              : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RX              : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL R7              : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL IMMEDIATE       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL INSTRUCTION     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ALU_OUTPUT      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL DATAM_OUT       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL SIP             : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ER              : STD_LOGIC;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: datapath
    PORT MAP (
        INPUT_CLK       => INPUT_CLK,
        PROCESSOR_CLK   => PROCESSOR_CLK,
        RESET           => RESET,
        INIT            => INIT,
        PROGRAM_COUNTER => PROGRAM_COUNTER,
        RZ              => RZ,
        RX              => RX,
        R7              => R7,
        IMMEDIATE       => IMMEDIATE,
        INSTRUCTION     => INSTRUCTION,
        ALU_OUTPUT      => ALU_OUTPUT,
        DATAM_OUT       => DATAM_OUT,
        SIP             => SIP,
        ER              => ER
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
