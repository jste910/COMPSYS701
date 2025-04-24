-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

USE work.opcodes.ALL;
USE work.various_constants.ALL;

ENTITY ControlUnit IS
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

        -- OUTPUTS DATA CONTROL
        DPCR_Store : OUT STD_LOGIC;
        PC_Store : OUT STD_LOGIC;
        IR_Load : OUT STD_LOGIC;
        Reg_Store : OUT STD_LOGIC;
        ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DM_LOAD : OUT STD_LOGIC;
        DM_STORE : OUT STD_LOGIC;
        CLR_Z_Flag : OUT STD_LOGIC
    );
END ENTITY ControlUnit;

ARCHITECTURE behavior OF ControlUnit IS
    SIGNAL FSM_STATE : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";

    SIGNAL New_Address_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL New_Data_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL New_ALU_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL New_ALU_Select_2 : STD_LOGIC := '0';
    SIGNAL New_Reg_Select : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL New_PC_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL New_DPCR_Select : STD_LOGIC := '0';
    SIGNAL New_DPCR_Store : STD_LOGIC := '0';
    SIGNAL New_PC_Store : STD_LOGIC := '0';
    SIGNAL New_IR_Load : STD_LOGIC := '0';
    SIGNAL New_Reg_Store : STD_LOGIC := '0';
    SIGNAL New_ALU_OP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
    SIGNAL New_DM_LOAD : STD_LOGIC := '0';
    SIGNAL New_DM_STORE : STD_LOGIC := '0';
    SIGNAL New_CLR_Z_Flag : STD_LOGIC := '0';
BEGIN

    PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            -- Default values each clock cycle
            New_Address_Select <= "00";
            New_Data_Select <= "00";
            New_ALU_Select <= "00";
            New_ALU_Select_2 <= '0';
            New_Reg_Select <= "000";
            New_PC_Select <= "00";
            New_IR_Load <= '0';
            New_ALU_OP <= "100";
            New_DM_LOAD <= '0';
            New_DM_STORE <= '0';
            New_DPCR_Select <= '0';
            New_DPCR_Store <= '0';
            New_PC_Store <= '0';
            New_Reg_Store <= '0';
            New_CLR_Z_Flag <= '0';


            CASE FSM_STATE IS
                WHEN "00" =>
                    -- Instruction Fetch
                    New_PC_Select <= "00";
                    New_PC_Store <= '1';
                    New_IR_Load <= '1';
                    FSM_STATE <= "01"; -- Move to decode

                WHEN "01" =>
                    -- Instruction Decode / Register Access

                    CASE OP_Code IS
                        WHEN clfz =>
                            New_CLR_Z_Flag <= '1';

                        WHEN cer =>
                            NULL;

                        WHEN ceot =>
                            NULL;

                        WHEN seot =>
                            NULL;

                        WHEN ler =>
                            New_Reg_Store <= '1';
                            New_Reg_Select <= "001";

                        WHEN lsip =>
                            New_Reg_Store <= '1';
                            New_Reg_Select <= "010";

                        WHEN noop =>
                            NULL; 
                    END CASE;

                WHEN "10" =>
                    -- Instruction Decode
                    TEMP_Reg_Store <= '0';
                    CASE OP_Code IS
                        WHEN andr =>
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_and;
                            IF (AM = am_immediate) THEN

                                New_ALU_Select <= "00";
                            ELSE
                                New_ALU_Select <= "01";
                            END IF;
                        WHEN orr =>
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_or;
                            IF (AM = am_immediate) THEN
                                New_ALU_Select <= "00";
                            ELSE
                                New_ALU_Select <= "01";
                            END IF;

                        WHEN addr =>
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_add;
                            IF (AM = am_immediate) THEN
                                New_ALU_Select <= "00";
                            ELSE
                                New_ALU_Select <= "01";
                            END IF;

                        WHEN subvr =>
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_sub;
                            New_ALU_Select <= "00";
                            New_ALU_Select_2 <= '0';

                        WHEN subr =>
                            New_ALU_OP <= alu_sub;
                            New_ALU_Select <= "00";
                            New_ALU_Select_2 <= '1';

                        WHEN ldr =>
                            TEMP_Reg_Store <= '1';
                            CASE AM IS
                                WHEN am_immediate =>
                                    New_Reg_Select <= "100";
                                WHEN am_register =>
                                    New_Reg_Select <= "011";
                                    New_DM_LOAD <= '1';
                                    New_Address_Select <= "10";
                                WHEN am_direct =>
                                    New_Reg_Select <= "011";
                                    New_DM_LOAD <= '1';
                                    New_Address_Select <= "00";
                                WHEN OTHERS =>
                                    -- do nothing 
                            END CASE;

                        WHEN str =>
                            New_DM_STORE <= '1';
                            CASE AM IS
                                WHEN am_immediate =>
                                    New_Address_Select <= "01";
                                    New_Data_Select <= "00";
                                WHEN am_register =>
                                    New_Address_Select <= "01";
                                    New_Data_Select <= "01";
                                WHEN am_direct =>
                                    New_Address_Select <= "00";
                                    New_Data_Select <= "01";
                                WHEN OTHERS =>
                                    -- do nothing     
                            END CASE;

                        WHEN jmp =>
                            New_PC_Store <= '1';
                            IF (AM = am_immediate) THEN
                                New_PC_Select <= "00";
                            ELSE
                                New_PC_Select <= "10";
                            END IF;
                        WHEN present =>
                            NULL;

                        WHEN datacall =>
                            New_DPCR_Store <= '1';
                            New_DPCR_Select <= '0';

                        WHEN datacall2 =>
                            New_DPCR_Store <= '1';
                            New_DPCR_Select <= '1';

                        WHEN sz =>
                            New_PC_Select <= "01";
                            IF (Z_Flag = '1') THEN
                                New_PC_Store <= '1';
                            ELSE
                                New_PC_Store <= '0';
                            END IF;

                        WHEN ssvop =>
                            NULL;

                        WHEN ssop =>
                            NULL;

                        WHEN max =>
                            New_ALU_OP <= alu_max;
                            New_Reg_Store <= '1';
                            New_Reg_Select <= "010";
                            New_ALU_Select <= "00";
                            New_ALU_Select_2 <= '1';

                        WHEN strpc =>
                            New_DM_STORE <= '1';
                            New_Address_Select <= "00";
                            New_Data_Select <= "10";

                        WHEN OTHERS =>
                            NULL;
                    END CASE;

                    FSM_STATE <= "00"; -- Go back to fetch

                WHEN "11" =>
                    -- You can implement more execution/mem stages here if needed
                    FSM_STATE <= "00";

                WHEN OTHERS =>
                    -- DO nothing need this for 
            END CASE;
        END IF;
    END PROCESS;

    -- Output assignments
    Address_Select <= New_Address_Select;
    Data_Select <= New_Data_Select;
    ALU_Select <= New_ALU_Select;
    ALU_Select_2 <= New_ALU_Select_2;
    Reg_Select <= New_Reg_Select;
    PC_Select <= New_PC_Select;
    DPCR_Select <= New_DPCR_Select;
    DPCR_Store <= New_DPCR_Store;
    PC_Store <= New_PC_Store;
    IR_Load <= New_IR_Load;
    Reg_Store <= New_Reg_Store OR TEMP_Reg_Store;
    ALU_OP <= New_ALU_OP;
    DM_LOAD <= New_DM_LOAD;
    DM_STORE <= New_DM_STORE;
    CLR_Z_Flag <= New_CLR_Z_Flag;

END behavior;