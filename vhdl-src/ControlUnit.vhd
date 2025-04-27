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

        -- DEBUG UTIL
        STATE : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY ControlUnit;

ARCHITECTURE behavior OF ControlUnit IS
    SIGNAL FSM_STATE : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
BEGIN
    PROCESS (CLK, Reset)
    BEGIN
        IF Reset = '1' THEN
            FSM_STATE <= "00";
        ELSIF rising_edge(CLK) THEN
            -- Default values each clock cycle
            Address_Select <= "00";
            Data_Select <= "00";
            ALU_Select <= "00";
            ALU_Select_2 <= '0';
            Reg_Select <= "000";
            PC_Select <= "00";
            DPCR_Select <= '0';

            PC_Store <= '0';
            IM_Store <= '0';
            IR_Load <= '0';
            Reg_Store <= '0';
            ALU_OP <= "100";
            
            DM_LOAD <= '0';
            DM_STORE <= '0';
            
            DPCR_Store <= '0';
            Z_Clear <= '0';
            ER_Clear <= '0';
            EOT_Clear <= '0';
            EOT_Set <= '0';
            SVOP_Set <= '0';
            SOP_Set <= '0';

            CASE FSM_STATE IS
                WHEN "00" =>
                    -- Instruction Fetch
                    IR_Load <= '1';

                    -- Increment PC by 2
                    PC_Select <= "00";
                    PC_Store <= '1';
                    
                    FSM_STATE <= "01"; -- Move to decode

                WHEN "01" =>
                    -- Instruction Decode / Register Access

                    -- If the Instruction requires an immediate value Increment PC and fetch it
                    IF (AM = am_immediate OR AM = am_direct) vb THEN
                        IM_Store <= '1'; -- Store immediate

                        PC_Select <= "00"; -- Increment PC
                        PC_Store <= '1';
                    END IF;
                    
                    -- Complete Inherent Instructions
                    CASE OP_Code IS
                        WHEN clfz =>
                            Z_Clear <= '1';

                        WHEN cer =>
                            ER_Clear <= '1';

                        WHEN ceot =>
                            EOT_Clear <= '1';

                        WHEN seot =>
                            EOT_Set <= '1';

                        WHEN ler =>
                            Reg_Store <= '1';
                            Reg_Select <= "001";

                        WHEN lsip =>
                            Reg_Store <= '1';
                            Reg_Select <= "010";

                        WHEN noop =>
                            NULL;
                        WHEN OTHERS =>
                            NULL;
                    END CASE;

                    IF (AM = am_inherent) THEN
                        FSM_STATE <= "00"; -- Inhearent instruction is finished 
                    ELSE
                        FSM_STATE <= "10"; -- Go to Execute / Mem
                    END IF;

                WHEN "10" =>
                    -- Execute / Memory access

                    -- Assume that we wont be doing a writeback 
                    FSM_STATE <= "00";

                    -- BEHOLD THE CASE STATEMENT!
                    CASE OP_Code IS
                        WHEN andr =>
                            FSM_STATE <= "11";
                            ALU_OP <= alu_and;
                            IF (AM = am_immediate) THEN

                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;
                        WHEN orr =>
                            FSM_STATE <= "11";
                            ALU_OP <= alu_or;
                            IF (AM = am_immediate) THEN
                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;

                        WHEN addr =>
                            FSM_STATE <= "11";
                            ALU_OP <= alu_add;
                            IF (AM = am_immediate) THEN
                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;

                        WHEN subvr =>
                            FSM_STATE <= "11";
                            ALU_OP <= alu_sub;
                            ALU_Select <= "00";
                            ALU_Select_2 <= '0';

                        WHEN subr =>
                            ALU_OP <= alu_sub;
                            ALU_Select <= "00";
                            ALU_Select_2 <= '1';

                        WHEN ldr =>
                            CASE AM IS
                                WHEN am_immediate =>
                                    FSM_STATE <= "00";
                                    Reg_Store <= '1';
                                    Reg_Select <= "011";
                                WHEN am_register =>
                                    FSM_STATE <= "11";
                                    DM_LOAD <= '1';
                                    Address_Select <= "10";
                                WHEN am_direct =>
                                    FSM_STATE <= "11";
                                    DM_LOAD <= '1';
                                    Address_Select <= "00";
                                WHEN OTHERS =>
                                    NULL; -- do nothing 
                            END CASE;

                        WHEN str =>
                            DM_STORE <= '1';
                            CASE AM IS
                                WHEN am_immediate =>
                                    Address_Select <= "01";
                                    Data_Select <= "00";
                                WHEN am_register =>
                                    Address_Select <= "01";
                                    Data_Select <= "01";
                                WHEN am_direct =>
                                    Address_Select <= "00";
                                    Data_Select <= "01";
                                WHEN OTHERS =>
                                    NULL; -- do nothing     
                            END CASE;

                        WHEN jmp =>
                            PC_Store <= '1';
                            IF (AM = am_immediate) THEN
                                PC_Select <= "00";
                            ELSE
                                PC_Select <= "10";
                            END IF;

                        WHEN present =>
                            NULL; -- Wait for comparitor

                        WHEN datacall =>
                            DPCR_Store <= '1';
                            DPCR_Select <= '0';

                        WHEN datacall2 =>
                            DPCR_Store <= '1';
                            DPCR_Select <= '1';

                        WHEN sz =>
                            PC_Select <= "01";
                            IF (Z_Flag = '1') THEN
                                PC_Store <= '1';
                            ELSE
                                PC_Store <= '0';
                            END IF;

                        WHEN ssvop =>
                            SVOP_Set <= '1';

                        WHEN ssop =>
                            SOP_Set <= '1';

                        WHEN max =>
                            FSM_STATE <= "11";
                            ALU_OP <= alu_max;
                            Reg_Select <= "010";
                            ALU_Select <= "00";
                            ALU_Select_2 <= '1';

                        WHEN strpc =>
                            DM_STORE <= '1';
                            Address_Select <= "00";
                            Data_Select <= "10";

                        WHEN OTHERS =>
                            NULL;
                    END CASE;

                WHEN "11" =>
                    -- Writeback Stage

                    IF (OP_Code = present) THEN
                        --  do the Branch is needed
                        PC_Select <= "01";
                        IF (CMP0 = '1') THEN
                            PC_Store <= '1';
                        ELSE
                            PC_Store <= '0';
                        END IF;
                    ELSE
                        Reg_Store <= '1';
                        IF OP_CODE = ldr THEN
                            Reg_Select <= "011";
                        END IF;
                    END IF;


                    FSM_STATE <= "00";

                WHEN OTHERS =>
                    -- This shouldn't happen
            END CASE;
        END IF;
    END PROCESS;
    STATE <= FSM_STATE;
END behavior;