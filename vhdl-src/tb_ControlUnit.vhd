LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Include your packages
USE work.opcodes.ALL;
USE work.various_constants.ALL;

ENTITY tb_ControlUnit IS
END tb_ControlUnit;

ARCHITECTURE behavior OF tb_ControlUnit IS

    COMPONENT ControlUnit
        PORT (
            CLK : IN STD_LOGIC;
            CMP0 : IN STD_LOGIC;
            OP_Code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            AM : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            Z_Flag : IN STD_LOGIC;

            Address_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            Data_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALU_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALU_Select_2 : OUT STD_LOGIC;
            Reg_Select : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            PC_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            DPCR_Select : OUT STD_LOGIC;

            DPCR_Store : OUT STD_LOGIC;
            PC_Store : OUT STD_LOGIC;
            IR_Load : OUT STD_LOGIC;
            Reg_Store : OUT STD_LOGIC;
            ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DM_LOAD : OUT STD_LOGIC;
            DM_STORE : OUT STD_LOGIC;
            CLR_Z_Flag : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals
    SIGNAL CLK, CMP0, Z_Flag : STD_LOGIC := '0';
    SIGNAL OP_Code : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL AM : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL Address_Select, Data_Select, ALU_Select, PC_Select : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ALU_Select_2, DPCR_Select, DPCR_Store, PC_Store, IR_Load, Reg_Store, DM_LOAD, DM_STORE, CLR_Z_Flag : STD_LOGIC;
    SIGNAL Reg_Select : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ALU_OP : STD_LOGIC_VECTOR(2 DOWNTO 0);

    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- UUT instantiation
    uut: ControlUnit PORT MAP (
        CLK => CLK, CMP0 => CMP0, OP_Code => OP_Code, AM => AM, Z_Flag => Z_Flag,
        Address_Select => Address_Select, Data_Select => Data_Select,
        ALU_Select => ALU_Select, ALU_Select_2 => ALU_Select_2, Reg_Select => Reg_Select,
        PC_Select => PC_Select, DPCR_Select => DPCR_Select, DPCR_Store => DPCR_Store,
        PC_Store => PC_Store, IR_Load => IR_Load, Reg_Store => Reg_Store,
        ALU_OP => ALU_OP, DM_LOAD => DM_LOAD, DM_STORE => DM_STORE,
        CLR_Z_Flag => CLR_Z_Flag
    );

    -- Clock generation
    clk_process: PROCESS
    BEGIN
        WHILE TRUE LOOP
            CLK <= '0'; WAIT FOR clk_period / 2;
            CLK <= '1'; WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
        PROCEDURE test(op: STD_LOGIC_VECTOR(5 DOWNTO 0); am_mode: STD_LOGIC_VECTOR(1 DOWNTO 0); flag: STD_LOGIC := '0') IS
        BEGIN
            OP_Code <= op;
            AM <= am_mode;
            Z_Flag <= flag;
            WAIT FOR clk_period;
        END PROCEDURE;
    BEGIN
        WAIT FOR 20 ns;

        -- Core ALU Instructions
        test(addr, am_immediate);
        test(addr, am_direct);
        test(andr, am_immediate);
        test(orr, am_direct);
        test(subvr, am_inherent);
        test(subr, am_inherent);

        -- Memory Instructions
        test(ldr, am_immediate);
        test(ldr, am_direct);
        test(ldr, am_register);
        test(str, am_immediate);
        test(str, am_direct);
        test(str, am_register);

        -- Branching and Control Flow
        test(jmp, am_immediate);
        test(jmp, am_direct);
        test(sz, am_direct, '1');
        test(clfz, am_inherent);

        -- I/O or system control
        test(datacall, am_register);
        test(datacall2, am_immediate);
        test(present, am_direct);
        test(strpc, am_direct);
        test(ler, am_direct);
        test(lsip, am_direct);
        test(ssvop, am_direct);
        test(ssop, am_direct);
        test(noop, am_inherent);
        test(cer, am_inherent);
        test(seot, am_inherent);
        test(ceot, am_inherent);
        test(max, am_immediate);
        test(sres, am_register);

        -- End simulation
        WAIT;
    END PROCESS;

END behavior;
