LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

USE work.opcodes.ALL; -- Import the opcodes package
USE work.various_constants.ALL;

ENTITY tb_ControlUnit IS
END tb_ControlUnit;

ARCHITECTURE behavior OF tb_ControlUnit IS

    COMPONENT ControlUnit
        PORT (
            -- INPUTS
            CLK : IN STD_LOGIC;
            Reset : IN STD_LOGIC;
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

            -- OUTPUTS MAIN CONTROL
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
            STATE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals
    SIGNAL CLK, CMP0, Z_Flag : STD_LOGIC := '0';
    SIGNAL OP_Code : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL AM : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL Address_Select, Data_Select, ALU_Select, PC_Select : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ALU_Select_2, DPCR_Select, DPCR_Store, Z_Clear, ER_Clear, EOT_Clear : STD_LOGIC;
    SIGNAL IM_Store, IR_Load, Reg_Store, DM_LOAD, DM_STORE : STD_LOGIC;
    SIGNAL Reg_Select, STATE : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ALU_OP : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EOT_Set, SVOP_Set, SOP_Set, PC_Store : STD_LOGIC;

    -- Define arrays for OP_Code and AM
    TYPE op_code_array_t IS ARRAY (0 TO 30) OF STD_LOGIC_VECTOR(5 DOWNTO 0);
    TYPE am_array_t IS ARRAY (0 TO 30) OF STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- Declare program memory signals (OP_Code and AM arrays)
    SIGNAL op_codes : op_code_array_t := (
        andr, -- LDR
        andr, -- LDR
        orr, -- AND
        orr, -- OR
        addr, -- SUBV
        addr, -- SUB
        subvr, -- JMP
        subr, -- JMP
        ldr, -- SZ
        ldr, -- CER
        ldr,
        str,
        str,
        str,
        jmp,
        jmp,
        present,
        datacall,
        datacall2,
        sz,
        clfz,
        cer,
        ceot,
        seot,
        ler,
        ssvop,
        lsip,
        ssop,
        noop,
        max,
        strpc
    );

    SIGNAL am_modes : am_array_t := (
        am_immediate, -- Immediate
        am_register, -- Direct
        am_immediate, -- Immediate
        am_register, -- Direct
        am_immediate, -- Immediate
        am_register, -- Direct
        am_immediate, -- Immediate
        am_immediate, -- Immediate
        am_immediate, -- Immediate
        am_register, -- Direct
        am_direct, 
        am_immediate, -- Immediate
        am_register, -- Direct
        am_direct, 
        am_immediate, -- Immediate
        am_register, -- Direct
        am_immediate, -- Immediate
        am_register, -- Direct
        am_immediate, -- Immediate
        am_immediate, -- Immediate
        am_inherent,
        am_inherent,
        am_inherent,
        am_inherent,
        am_register,
        am_register,
        am_register,
        am_register,
        am_inherent,
        am_immediate, -- Immediate
        am_direct
    );

    SIGNAL instruction_pointer : INTEGER := 0; -- Pointer to the current instruction in program memory

    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- UUT instantiation
    uut : ControlUnit PORT MAP(
        CLK => CLK, Reset => '0', CMP0 => CMP0, OP_Code => OP_Code, AM => AM, Z_Flag => Z_Flag,
        Address_Select => Address_Select, Data_Select => Data_Select,
        ALU_Select => ALU_Select, ALU_Select_2 => ALU_Select_2, Reg_Select => Reg_Select,
        PC_Select => PC_Select, DPCR_Select => DPCR_Select, DPCR_Store => DPCR_Store,
        PC_Store => PC_Store, IM_Store => IM_Store, IR_Load => IR_Load, Reg_Store => Reg_Store,
        ALU_OP => ALU_OP, DM_LOAD => DM_LOAD, DM_STORE => DM_STORE,
        Z_Clear => Z_Clear, ER_Clear => ER_Clear, EOT_Clear => EOT_Clear,
        EOT_Set => EOT_Set, SVOP_Set => SVOP_Set, SOP_Set => SOP_Set,
        STATE => STATE
    );

    -- Clock generation
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            CLK <= '0';
            WAIT FOR clk_period / 2;
            CLK <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus process to fetch instructions
    stim_proc : PROCESS
        VARIABLE i : INTEGER := 0;
    BEGIN
        -- Initial values for OP_Code and AM
        OP_Code <= (OTHERS => '0'); -- Default values
        AM <= (OTHERS => '0');

        -- Fetch instructions from program memory
        -- WAIT FOR 20 ns;

        WHILE TRUE LOOP
            IF IR_Load = '1' THEN
                -- Fetch the opcode and addressing mode from the arrays
                OP_Code <= op_codes(i);
                AM <= am_modes(i);
                instruction_pointer <= i + 1;
                i := i + 1;
            END IF;
            WAIT FOR clk_period;
        END LOOP;

        -- End simulation
        WAIT;
    END PROCESS;

END behavior;