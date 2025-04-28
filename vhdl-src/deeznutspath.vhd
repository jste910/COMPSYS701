-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

USE IEEE.numeric_std.ALL;

USE work.recop_types.ALL;
USE work.various_constants.ALL;
ENTITY deeznutspath IS
    PORT (
        -- IO only for test benching and clock
        -- Test bench outputs
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

END ENTITY deeznutspath;
ARCHITECTURE behavior OF deeznutspath IS

    COMPONENT ProgramCounter
        PORT (
            Rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
            Immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
            PC_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Selector
            PC_SET : IN STD_LOGIC; -- Latch the value
            CLK : IN STD_LOGIC; -- Clock signal
            PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- 16-bit output
        );
    END COMPONENT;

    COMPONENT program_mem_module
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
            IM_Store : IN STD_LOGIC;
            IR_Load : IN STD_LOGIC;
            immediate_reg : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            instr_header_reg : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ControlUnit
        PORT (
            -- INPUTS
            CLK : IN STD_LOGIC;
            CMP0 : IN STD_LOGIC;
            Reset : IN STD_LOGIC;
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
            SOP_Set : OUT STD_LOGIC
        );
    END COMPONENT;

    -- COMPONENT regfile
    --     PORT (
    --         clk : IN bit_1;
    --         init : IN bit_1;
    --         -- control signal to allow data to write into Rz
    --         ld_r : IN bit_1;
    --         -- Rz and Rx select signals
    --         sel_z : IN bit_4;
    --         sel_x : IN bit_4;
    --         -- register data outputs
    --         rx : OUT bit_16;
    --         rz : OUT bit_16;
    --         -- select signal for input data to be written into Rz
    --         rf_input_sel : IN bit_3;
    --         -- input data
    --         ir_operand : IN bit_16;
    --         dm_out : IN bit_16;
    --         aluout : IN bit_16;
    --         sip_hold : IN bit_16;
    --         er_temp : IN bit_1;
    --         -- R7 for writing to lower byte of dpcr
    --         r7 : OUT bit_16;
    --         dprr_res : IN bit_1;
    --         dprr_res_reg : IN bit_1;
    --         dprr_wren : IN bit_1

    --     );
    -- END COMPONENT;

    -- COMPONENT comparator
    --     PORT (
    --         a : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input a
    --         b : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input b
    --         compare : OUT STD_LOGIC
    --     );
    -- END COMPONENT;

    -- COMPONENT ALU
    --     PORT (
    --         clk : IN bit_1;
    --         z_flag : OUT bit_1;
    --         -- ALU operation selection
    --         alu_operation : IN bit_3;
    --         -- operand selection
    --         alu_op1_sel : IN bit_2;
    --         alu_op2_sel : IN bit_1;
    --         alu_carry : IN bit_1; --WARNING: carry in currently is not used
    --         alu_result : OUT bit_16 := X"0000";
    --         -- operands
    --         rx : IN bit_16;
    --         rz : IN bit_16;
    --         ir_operand : IN bit_16;
    --         -- flag control signal
    --         clr_z_flag : IN bit_1;
    --         reset : IN bit_1
    --     );
    -- END COMPONENT;

    -- COMPONENT Registers
    --     PORT (
    --         clk : IN bit_1;
    --         reset : IN bit_1;
    --         dpcr : OUT bit_32;
    --         r7 : IN bit_16;
    --         rx : IN bit_16;
    --         ir_operand : IN bit_16;
    --         dpcr_lsb_sel : IN bit_1;
    --         dpcr_wr : IN bit_1;
    --         -- environment ready and set and clear signals
    --         er : OUT bit_1;
    --         er_wr : IN bit_1;
    --         er_clr : IN bit_1;
    --         -- end of thread and set and clear signals
    --         eot : OUT bit_1;
    --         eot_wr : IN bit_1;
    --         eot_clr : IN bit_1;
    --         -- svop and write enable signal
    --         svop : OUT bit_16;
    --         svop_wr : IN bit_1;
    --         -- sip souce and registered outputs
    --         sip_r : OUT bit_16;
    --         sip : IN bit_16;
    --         -- sop and write enable signal
    --         sop : OUT bit_16;
    --         sop_wr : IN bit_1;
    --         -- dprr, irq (dprr(1)) set and clear signals and result source and write enable signal
    --         dprr : OUT bit_2;
    --         irq_wr : IN bit_1;
    --         irq_clr : IN bit_1;
    --         result_wen : IN bit_1;
    --         result : IN bit_1
    --     );
    -- END COMPONENT;

    -- COMPONENT DataMemoryModule
    --     PORT (
    --         Address_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Address selection signal
    --         Data_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Data selection signal
    --         Immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
    --         Rz : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
    --         Rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
    --         PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data input
    --         DM_LOAD : IN STD_LOGIC; -- Data memory load signal
    --         DM_STORE : IN STD_LOGIC; -- Data memory store signal
    --         DM_CLK : IN STD_LOGIC; -- Data memory clock signal
    --         DM_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Data memory output
    --     );

    -- END COMPONENT;

    -- COMPONENT recop_pll
    --     PORT (
    --         inclk0 : IN STD_LOGIC := '0';
    --         c0 : OUT STD_LOGIC
    --     );
    -- END COMPONENT;

    -- OVERALL SIGNALS
    SIGNAL PROCESSOR_CLK : STD_LOGIC;
    SIGNAL RESET : STD_LOGIC;

    -- DATA SIGNALS
    SIGNAL PROGRAM_COUNTER : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL RZ : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RX : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL R7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL IMMEDIATE : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL INSTRUCTION : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ALU_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL DATAM_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL SIP : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL ER : STD_LOGIC := '0';

    -- MEMORY CONTROL SIGNALS
    SIGNAL ADDRESS_SELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL DATA_SELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL DATAM_LOAD : STD_LOGIC;
    SIGNAL DATAM_STORE : STD_LOGIC;

    -- ALU CONTROL SIGNALS
    SIGNAL ALU_OPERATION : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"; -- ALU operation selection
    SIGNAL ALU_OP1_SEL : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- ALU operand selection
    SIGNAL ALU_OP2_SEL : STD_LOGIC; -- ALU operand selection
    SIGNAL ALU_Z_FLAG : STD_LOGIC; -- ALU zero flag
    SIGNAL CLR_Z_FLAG : STD_LOGIC; -- ALU clear zero flag   

    -- INSTRUCTION / PROGRAM COUNTER CONTROL
    SIGNAL IR_LOAD : STD_LOGIC;
    SIGNAL IM_STORE : STD_LOGIC;
    SIGNAL PROGRAM_SELECT : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL PROGRAM_SET : STD_LOGIC;

    -- REGISTER CONTROL SIGNALS
    SIGNAL SVOP_SET : STD_LOGIC;
    SIGNAL SOP_SET : STD_LOGIC;
    SIGNAL ER_CLEAR : STD_LOGIC;
    SIGNAL EOT_SET : STD_LOGIC;
    SIGNAL EOT_CLEAR : STD_LOGIC;
    SIGNAL DPCR_WRITE : STD_LOGIC;
    SIGNAL DPCR_SELECT : STD_LOGIC;
    SIGNAL REGISTER_SELECT : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL REGISTER_STORE : STD_LOGIC;

    -- OTHER CONTROL SIGNALS    
    SIGNAL COMPARE_OUTPUT : STD_LOGIC;
BEGIN
    --UPDATE test bench signals
    PROGRAM_COUNTER_output <= PROGRAM_COUNTER;
    RZ_output <= RZ;
    RX_output <= RX;
    R7_output <= R7;
    IMMEDIATE_output <= IMMEDIATE;
    INSTRUCTION_output <= INSTRUCTION;
    ALU_OUTPUT_output <= ALU_OUTPUT;
    DATAM_OUT_output <= DATAM_OUT;
    SIP_output <= SIP;
    ER_output <= ER;
    PROCESSOR_CLK <= INPUT_CLK;

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
        Z_Flag => ALU_Z_FLAG,

        -- OUTPUTS DATA FLOW
        Address_Select => ADDRESS_SELECT,
        Data_Select => DATA_SELECT,
        ALU_Select => ALU_OP1_SEL,
        ALU_Select_2 => ALU_OP2_SEL,
        Reg_Select => REGISTER_SELECT,
        PC_Select => PROGRAM_SELECT,
        DPCR_Select => DPCR_SELECT,

        -- OUTPUTS MIAN CONTROL
        PC_Store => PROGRAM_SET,
        IM_Store => IM_STORE,
        IR_Load => IR_LOAD,
        Reg_Store => REGISTER_STORE,
        ALU_OP => ALU_OPERATION,
        DM_LOAD => DATAM_LOAD,
        DM_STORE => DATAM_STORE,

        -- OUTPUTS IO / REG CONTROL
        DPCR_Store => DPCR_WRITE,
        Z_Clear => CLR_Z_FLAG,
        ER_Clear => ER_CLEAR,
        EOT_Clear => EOT_CLEAR,
        EOT_Set => EOT_SET,
        SVOP_Set => SVOP_SET,
        SOP_Set => SOP_SET,
        RESET => '0'
    );

    -- REGF : regfile
    -- PORT MAP(
    --     clk => PROCESSOR_CLK,
    --     init => RESET,
    --     ld_r => REGISTER_STORE,
    --     sel_z => INSTRUCTION(7 DOWNTO 4),
    --     sel_x => INSTRUCTION(3 DOWNTO 0),
    --     rx => RX,
    --     rz => RZ,
    --     rf_input_sel => REGISTER_SELECT,
    --     ir_operand => IMMEDIATE,
    --     dm_out => DATAM_OUT,
    --     aluout => ALU_OUTPUT,
    --     sip_hold => SIP,
    --     er_temp => ER,
    --     r7 => R7,
    --     dprr_res => '0',
    --     dprr_res_reg => '0',
    --     dprr_wren => '0'
    -- );

    -- COMP : comparator
    -- PORT MAP(
    --     a => RZ,
    --     b => "0000000000000000",
    --     compare => COMPARE_OUTPUT
    -- );

    -- definitelyTheALU : ALU -- Dawg why is it named this
    -- PORT MAP(
    --     clk => PROCESSOR_CLK,
    --     z_flag => ALU_Z_FLAG,
    --     -- ALU operation selection
    --     alu_operation => ALU_OPERATION,
    --     -- operand selection
    --     alu_op1_sel => ALU_OP1_SEL,
    --     alu_op2_sel => ALU_OP2_SEL,
    --     alu_carry => '0',
    --     alu_result => ALU_OUTPUT,
    --     -- operands
    --     rx => RX,
    --     rz => RZ,
    --     ir_operand => IMMEDIATE,
    --     -- flag control signal
    --     clr_z_flag => CLR_Z_FLAG,
    --     reset => RESET
    -- );

    -- REG : Registers
    -- PORT MAP(
    --     clk => PROCESSOR_CLK,
    --     reset => RESET,
    --     -- INPUT
    --     r7 => R7,
    --     rx => RX,
    --     ir_operand => IMMEDIATE,
    --     -- DPCR
    --     dpcr => OPEN,
    --     dpcr_lsb_sel => DPCR_SELECT,
    --     dpcr_wr => DPCR_WRITE,
    --     -- ER
    --     er => ER,
    --     er_wr => '0', -- I dont get why ER has a write signal, I though it was event capture
    --     er_clr => ER_CLEAR,
    --     -- EOT
    --     eot => OPEN, -- no clue where to pipe this
    --     eot_wr => EOT_SET,
    --     eot_clr => EOT_CLEAR,
    --     -- SVOP
    --     svop => OPEN, -- add mapping to 7seg
    --     svop_wr => SVOP_SET,
    --     -- SOP
    --     sop => OPEN, -- add mapping to LEDs
    --     sop_wr => SOP_SET,
    --     -- SIP
    --     sip => X"0000", -- Need to map to switchs
    --     sip_r => SIP,
    --     -- DPRR / IRQ <! The 5 signals below are needed to be implemented>
    --     dprr => OPEN,
    --     irq_wr => '0',
    --     irq_clr => '0',
    --     result_wen => '0',
    --     result => '0'
    -- );

    -- DMM : DataMemoryModule
    -- PORT MAP(
    --     Address_SEL => ADDRESS_SELECT,
    --     Data_SEL => DATA_SELECT,
    --     Immediate => IMMEDIATE,
    --     Rz => RZ,
    --     Rx => RX,
    --     PC => PROGRAM_COUNTER,
    --     DM_LOAD => DATAM_LOAD,
    --     DM_STORE => DATAM_STORE,
    --     DM_CLK => PROCESSOR_CLK,
    --     DM_OUT => DATAM_OUT
    -- );

    -- CLOCK : recop_pll
    -- PORT MAP
    -- (
    --     inclk0 => INPUT_CLK,
    --     c0 => PROCESSOR_CLK
    -- );

END behavior;