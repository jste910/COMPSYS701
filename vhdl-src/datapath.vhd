-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

USE IEEE.numeric_std.ALL;

USE work.recop_types.ALL;
USE work.various_constants.ALL;
ENTITY datapath IS
    -- no io?
END ENTITY datapath;
ARCHITECTURE behavior OF datapath IS

    COMPONENT ProgramCounter
        PORT (
            Rx             : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
            Immediate      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
            PC_SEL         : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  -- Selector
            PC_SET         : IN  STD_LOGIC;                     -- Latch the value
            CLK            : IN  STD_LOGIC;                     -- Clock signal
            PC             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)  -- 16-bit output
        );
    END COMPONENT;

    COMPONENT program_mem_module
        port (
            clk					: in  std_logic;
            rst					: in  std_logic;
            address				: in  std_logic_vector(14 downto 0);
            IM_Store			: in  std_logic;
            IR_Load				: in  std_logic;
            immediate_reg		: out std_logic_vector(15 downto 0);
            instr_header_reg	: out std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    COMPONENT ControlUnit
        PORT (
            -- INPUTS
            CLK : IN STD_LOGIC;
            CMP0 : IN STD_LOGIC;
            OP_Code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            AM : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            Z_Flag : IN STD_LOGIC;

            -- OUTPUTS DATA FLOW
            Address_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            Data_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALU_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALU_Select_2 : OUT STD_LOGIC;
            Reg_Select : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            PC_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            DPCR_Select : OUT STD_LOGIC;

            -- OUTPUTS MIAN CONTROL
            PC_Store : OUT STD_LOGIC;
            IM_Store : OUT STD_LOGIC;
            IR_Load : OUT STD_LOGIC;
            Reg_Store : OUT STD_LOGIC;
            ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DM_LOAD : OUT STD_LOGIC;
            DM_STORE : OUT STD_LOGIC;

            -- OUTPUTS IO / REG CONTROL
            DPCR_Store : OUT STD_LOGIC;
            Z_Clear : OUT STD_LOGIC;
            ER_Clear : OUT STD_LOGIC;
            EOT_Clear : OUT STD_LOGIC;
            EOT_Set : OUT STD_LOGIC;
            SVOP_Set : OUT STD_LOGIC;
            SOP_Set : OUT STD_LOGIC;
        );
    END COMPONENT;

    COMPONENT regfile
        PORT (
            clk : IN bit_1;
            init : IN bit_1;
            -- control signal to allow data to write into Rz
            ld_r : IN bit_1;
            -- Rz and Rx select signals
            sel_z : IN INTEGER RANGE 0 TO 15;
            sel_x : IN INTEGER RANGE 0 TO 15;
            -- register data outputs
            rx : OUT bit_16;
            rz : OUT bit_16;
            -- select signal for input data to be written into Rz
            rf_input_sel : IN bit_3;
            -- input data
            ir_operand : IN bit_16;
            dm_out : IN bit_16;
            aluout : IN bit_16;
            rz_max : IN bit_16;
            sip_hold : IN bit_16;
            er_temp : IN bit_1;
            -- R7 for writing to lower byte of dpcr
            r7 : OUT bit_16;
            dprr_res : IN bit_1;
            dprr_res_reg : IN bit_1;
            dprr_wren : IN bit_1
        );

    END COMPONENT;

    COMPONENT comparator
        PORT (
            a : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
            b : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
            compare : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ArithmaticLogicUnit
        PORT (
            clk : IN bit_1;
            z_flag : OUT bit_1;
            -- ALU operation selection
            alu_operation : IN bit_3;
            -- operand selection
            alu_op1_sel : IN bit_2;
            alu_op2_sel : IN bit_1;
            alu_carry : IN bit_1; --WARNING: carry in currently is not used
            alu_result : OUT bit_16 := X"0000";
            -- operands
            rx : IN bit_16;
            rz : IN bit_16;
            ir_operand : IN bit_16;
            -- flag control signal
            clr_z_flag : IN bit_1;
            reset : IN bit_1;
            ALU_SELECT : IN bit_2
        );
    END COMPONENT;

    COMPONENT DataMemoryModule
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

    END COMPONENT;

    COMPONENT recop_pll
        PORT (
            inclk0 : IN STD_LOGIC := '0';
            c0 : OUT STD_LOGIC
        );
    END COMPONENT;

    -- TOP LEVEL CONTROL
    SIGNAL INPUT_CLK : STD_LOGIC;
    SIGNAL PROCESSOR_CLK : STD_LOGIC;
    SIGNAL RESET : STD_LOGIC;
    
    
    -- DATA SIGNALS
    SIGNAL PROGRAM_COUNTER : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL RZ : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RX : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL R7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL IMMEDIATE : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL INSTRUCTION : STD_LOGIC(7 DOWNTO 0);
    SIGNAL ALU_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";


    --


    SIGNAL COMPARE_OUTPUT : STD_LOGIC;
    SIGNAL PROGRAM_SELECT : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL REG_MAX : STD_LOGIC_VECTOR(15 DOWNTO 0) := "1111111111111111";
    

    SIGNAL DATAM_LOAD : STD_LOGIC;
    SIGNAL DATAM_STORE : STD_LOGIC;
    SIGNAL DATAM_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL INSTRUCTION_STORE : STD_LOGIC;
    SIGNAL INSTRUCTION_LOAD : STD_LOGIC;
    SIGNAL INSTRUCTION_REG_LOAD : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL IR_LOAD : STD_LOGIC;
    SIGNAL ADDRESS_SELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL DATA_SELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL Arithmatic_SELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL REGISTER_SELECT : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL STORE_REGISTER : STD_LOGIC;
    
    SIGNAL ALU_OP_CODE : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL REGISTER7 : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL Environment_Read : STD_LOGIC;
    SIGNAL Environment_Write : STD_LOGIC;
    SIGNAL Environment_Clear : STD_LOGIC;
    SIGNAL EoT : STD_LOGIC;
    SIGNAL EoT_Write : STD_LOGIC;
    SIGNAL EoT_Clear : STD_LOGIC;
    SIGNAL SVOPLINE : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL SVOP_WRITE : STD_LOGIC;
    SIGNAL SIP : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL SIP_REG : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL SOP_LINE : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL SOP_WRITE : STD_LOGIC;
    SIGNAL dprr_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL RESULT_WRITE_ENABLE : STD_LOGIC;
    SIGNAL RESULT : STD_LOGIC;
    SIGNAL IRQ_WRITE_ENABLE : STD_LOGIC;
    SIGNAL IRQ_CLEAR_ENABLE : STD_LOGIC;
    SIGNAL dpcr_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";
    SIGNAL instruction_register : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL dpcr_lsb_sel : STD_LOGIC;
    SIGNAL dpcr_wr : STD_LOGIC;
    SIGNAL temporary_environment : STD_LOGIC;
    SIGNAL dprr_result : STD_LOGIC;
    SIGNAL dprr_res_reg : STD_LOGIC;
    SIGNAL dprr_wren : STD_LOGIC;
    SIGNAL sip_reg_hold : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL REGFILE_INIT : STD_LOGIC;
    SIGNAL LOAD_REG : STD_LOGIC;
    SIGNAL Rz_integer : INTEGER := 1;
    SIGNAL Rx_integer : INTEGER := 0; -- Register select for Rz and Rx
    SIGNAL rf_input_sel : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"; -- Select signal for input data to be written into Rz
    SIGNAL INSTRUCTION_REG : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL AL_Z_FLAG : STD_LOGIC := '0'; -- ALU zero flag
    SIGNAL ALU_OP1_SEL : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- ALU operand selection
    SIGNAL ALU_OP2_SEL : STD_LOGIC; -- ALU operand selection
    SIGNAL ALU_CARRY : STD_LOGIC := '0'; -- ALU carry in
    SIGNAL CLR_Z_FLAG : STD_LOGIC := '0'; -- ALU clear zero flag
    SIGNAL ALU_RESULT : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000"; -- ALU result
    SIGNAL ALU_OPERATION : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"; -- ALU operation selection
BEGIN

    PC : ProgramCounter
    PORT MAP(
        Rx => RX,
        Immediate => IMMEDIATE, 
        PC_SEL => PROGRAM_SELECT,
        PC_SET => PROGRAM_SET,
        CLK => PROCESSOR_CLK,
        PC => PROGRAM_COUNTER 
    );

    IM : program_mem_module
    PORT MAP(
        clk => PROCESSOR_CLK,
        rst => RESET,
        address => PROGRAM_COUNTER(14 DOWNTO 0), --the adress is only 15 bits wide for some reason
        IM_Store => IM_STORE,
        IR_Load => IR_LOAD,
        immediate_reg => IMMEDIATE,
        instr_header_reg => INSTRUCTION
    );

    CU : ControlUnit
    PORT MAP(
        -- INPUTS
        CLK => PROCESSOR_CLK,
        CMP0 => COMPARE_OUTPUT,
        OP_Code => INSTRUCTION(13 DOWNTO 8),
        AM => INSTRUCTION(15 DOWNTO 14),
        Z_Flag => AL_Z_FLAG,

        -- OUTPUTS DATA FLOW
        Address_Select => ADDRESS_SELECT,
        Data_Select => DATA_SELECT,
        ALU_Select => ALU_OP1_SEL,
        ALU_Select_2 => ALU_OP2_SEL,
        Reg_Select => REGISTER_SELECT,
        PC_Select => PROGRAM_SELECT,
        DPCR_Select 

        -- OUTPUTS MIAN CONTROL
        PC_Store => PC_STORE,
        IM_Store => IM_STORE,
        IR_Load => IR_LOAD,
        Reg_Store => STORE_REGISTER,
        ALU_OP => ALU_OPERATION,
        DM_LOAD => DATAM_LOAD,
        DM_STORE => DATAM_STORE,
        
        -- OUTPUTS IO / REG CONTROL
        DPCR_Store => DPCR_STORE,
        Z_Clear => Z_CLEAR,
        ER_Clear => ER_CLEAR,
        EOT_Clear => EOT_CLEAR,
        EOT_Set => EOT_SET,
        SVOP_Set => SVOP_SET,
        SOP_Set => SOP_SET
    );


    
    reg : regfile
    PORT MAP(
        clk => PROCESSOR_CLK,
        init => REGFILE_INIT,
        -- control signal to allow data to write into Rz
        ld_r => LOAD_REG,
        -- Rz and Rx select signals
        sel_z => Rz_integer,
        sel_x => Rx_integer,
        -- register data outputs
        rx => RX_LINE,
        rz => RZ_LINE,
        -- select signal for input data to be written into Rz
        rf_input_sel => REGISTER_SELECT,
        -- input data
        ir_operand => INSTRUCTION_REG,
        dm_out => DATAM_OUTPUT,
        aluout => ALU_RESULT,
        rz_max => REG_MAX,
        sip_hold => sip_reg_hold,
        er_temp => temporary_environment,
        -- R7 for writing to lower byte of dpcr
        r7 => REGISTER7,
        dprr_res => dprr_result,
        dprr_res_reg => dprr_res_reg,
        dprr_wren => dprr_wren
    );

    COMP : comparator
    PORT MAP(
        a => RZ,
        b => "0000000000000000",
        compare => COMPARE_OUTPUT
    );

    Alu : arithmaticlogicunit
    PORT MAP(
        clk => PROCESSOR_CLK,
        z_flag => AL_Z_FLAG,
        -- ALU operation selection
        alu_operation => ALU_OPERATION,
        -- operand selection
        alu_op1_sel => ALU_OP1_SEL,
        alu_op2_sel => ALU_OP2_SEL,
        alu_carry => ALU_CARRY, --WARNING: carry in currently is not used
        alu_result => ALU_RESULT,
        -- operands
        rx => RX,
        rz => RZ,
        ir_operand => instruction_register,
        -- flag control signal
        clr_z_flag => CLR_Z_FLAG,
        reset => RESET_ALU,
        ALU_SELECT => Arithmatic_SELECT
    );

    DMM : DataMemoryModule
    PORT MAP(
        Address_SEL => ADDRESS_SELECT,
        Data_SEL => DATA_SELECT,
        Immediate => IMMEDIATE,
        Rz => RZ,
        Rx => RX,
        PC => PROGRAM_COUNTER,
        DM_LOAD => DATAM_LOAD,
        DM_STORE => DATAM_STORE,
        DM_CLK => PROCESSOR_CLK,
        DM_OUT => DATAM_OUTPUT
    );

    CLOCK : recop_pll
    PORT MAP
    (
        inclk0 => INPUT_CLK,
        c0 => PROCESSOR_CLK
    );

    INPUT_CLK <= NOT INPUT_CLK; -- setup a temp clock

END behavior;