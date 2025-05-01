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
        DPRR_IRQ : IN STD_LOGIC; 

        -- OUTPUTS DATA FLOW
        Address_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        Data_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_Select_2 : OUT STD_LOGIC;
        Reg_Select : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        PC_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- OUTPUTS MIAN CONTROL
        PC_Store : OUT STD_LOGIC;
        IM_Store : OUT STD_LOGIC;
        IR_Load : OUT STD_LOGIC;
        Reg_Store : OUT STD_LOGIC;
        ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DM_LOAD : OUT STD_LOGIC;
        DM_STORE : OUT STD_LOGIC;

        -- OUTPUTS IO / REG CONTROL
        
        Z_Clear : OUT STD_LOGIC;
        ER_Clear : OUT STD_LOGIC;
        EOT_Clear : OUT STD_LOGIC;
        EOT_Set : OUT STD_LOGIC;
        SVOP_Set : OUT STD_LOGIC;
        SOP_Set : OUT STD_LOGIC;

        -- DP SIGNALS
        DPCR_Store : OUT STD_LOGIC;
        DPCR_Select : OUT STD_LOGIC;
        DPCR_Clear : OUT STD_LOGIC;
        DPRR_Write : OUT STD_LOGIC;
        DPRR_IRQ_Clear : OUT STD_LOGIC;
        DPRR_RES_Write : OUT STD_LOGIC

    );
END ENTITY ControlUnit;

ARCHITECTURE behavior OF ControlUnit IS
    SIGNAL FSM_STATE : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL DPRR_IRQ_EN : STD_LOGIC := '0';
BEGIN
    PROCESS (CLK, Reset)
    BEGIN
        IF Reset = '1' THEN
            FSM_STATE <= "000";
        ELSIF rising_edge(CLK) THEN
            -- Default values each clock cycle
            Address_Select <= "00";
            Data_Select <= "00";
            ALU_Select <= "00";
            ALU_Select_2 <= '0';
            Reg_Select <= "000";
            PC_Select <= "00";
            
            PC_Store <= '0';
            IM_Store <= '0';
            IR_Load <= '0';
            Reg_Store <= '0';
            ALU_OP <= "100";
            
            DM_LOAD <= '0';
            DM_STORE <= '0';
            Z_Clear <= '0';
            ER_Clear <= '0';
            EOT_Clear <= '0';
            EOT_Set <= '0';
            SVOP_Set <= '0';
            SOP_Set <= '0';

            DPCR_Store <= '0';
            DPCR_Select <= '0';
            DPRR_Write <= '0';
            DPRR_IRQ_Clear <= '0';

            CASE FSM_STATE IS
                WHEN "000" =>
                    -- Inital state
                    FSM_STATE <= "001";

                WHEN "001" =>
                    -- Instruction Fetch
                    IR_Load <= '1';

                    -- Increment PC by 2
                    PC_Select <= "00";
                    PC_Store <= '1';
                    
                    IF (DPRR_IRQ = '1') AND (DPRR_IRQ_EN = '1') THEN
                        FSM_STATE <= "101"; -- Handle Datacall interupt
                    ELSE
                        FSM_STATE <= "010"; -- Go intrustion Decode
                    END IF;

                WHEN "010" =>
                    -- Instruction Decode / Register Access

                    -- If the Instruction requires an immediate value Increment PC and fetch it
                    IF (AM = am_immediate OR AM = am_direct) THEN
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
                        FSM_STATE <= "001"; -- Inhearent instruction is finished
                    ELSIF (OP_Code = ler OR OP_Code = lsip) THEN
                        FSM_STATE <= "001"; -- Simp Register write finished
                    ELSE
                        FSM_STATE <= "011"; -- Go to Execute / Mem
                    END IF;

                WHEN "011" =>
                    -- Execute / Memory access

                    -- Assume that we wont be doing a writeback 
                    FSM_STATE <= "001";

                    -- BEHOLD THE CASE STATEMENT!
                    CASE OP_Code IS
                        WHEN andr =>
                            FSM_STATE <= "100";
                            ALU_OP <= alu_and;
                            IF (AM = am_immediate) THEN
                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;
                        WHEN orr =>
                            FSM_STATE <= "100";
                            ALU_OP <= alu_or;
                            IF (AM = am_immediate) THEN
                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;

                        WHEN addr =>
                            FSM_STATE <= "100";
                            ALU_OP <= alu_add;
                            IF (AM = am_immediate) THEN
                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;

                        WHEN subvr =>
                            FSM_STATE <= "100";
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
                                    FSM_STATE <= "001";
                                    Reg_Store <= '1';
                                    Reg_Select <= "100";
                                WHEN am_register =>
                                    FSM_STATE <= "100";
                                    DM_LOAD <= '1';
                                    Address_Select <= "10";
                                WHEN am_direct =>
                                    FSM_STATE <= "100";
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
                                PC_Select <= "01";
                            ELSE
                                PC_Select <= "10";
                            END IF;

                        WHEN present =>
                            FSM_STATE <= "100";

                        WHEN datacall =>
                            -- Non Blocking
                            DPCR_Store <= '1';
                            DPRR_RES_Write <= '1';
                            DPRR_IRQ_EN <= '1';
                            IF (AM = am_immediate) THEN
                                DPCR_Select <= '1';
                            ELSE
                                DPCR_Select <= '0';
                            END IF;

                        WHEN datacall2 =>
                            -- Blocking
                            -- IDK the the compliler even makes this code tbh
                            DPCR_Store <= '1';
                            DPCR_Select <= '1';
                            DPRR_RES_Write <= '1';
                            DPRR_IRQ_EN <= '1';
                            -- goto blocking state
                            -- Doesn't currently work
                            --FSM_STATE <= "110";

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
                            FSM_STATE <= "100";
                            ALU_OP <= alu_max;
                            ALU_Select <= "00";
                            ALU_Select_2 <= '1';

                        WHEN strpc =>
                            DM_STORE <= '1';
                            Address_Select <= "00";
                            Data_Select <= "10";

                        WHEN OTHERS =>
                            NULL;
                    END CASE;

                WHEN "100" =>
                    -- Writeback Stage

                    IF (OP_Code = present) THEN
                        --  do the Branch is needed
                        PC_Select <= "01";
                        IF (CMP0 = '1') THEN
                            PC_Store <= '1';
                        ELSE
                            PC_Store <= '0';
                        END IF;
                    ELSIF (OP_Code = ldr) THEN
                        Reg_Select <= "011";
                        Reg_Store <= '1';
                        IF (AM = am_register) THEN
                            Address_Select <= "10";
                        ELSE
                            Address_Select <= "00";
                        END IF;
                    ELSE
                        Reg_Store <= '1';
                        IF (AM = am_immediate) THEN
                            ALU_Select <= "00";
                        ELSE
                            ALU_Select <= "01";
                        END IF;
                        CASE OP_Code IS
                            WHEN andr =>
                                ALU_OP <= alu_and;
                            WHEN orr =>
                                ALU_OP <= alu_or;
                            WHEN addr =>
                                ALU_OP <= alu_add;
                            WHEN subvr =>
                                ALU_OP <= alu_sub;
                            WHEN max =>
                                ALU_OP <= alu_max;
                                ALU_Select_2 <= '1';
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    END IF;


                    FSM_STATE <= "001";

                WHEN "101" =>
                    -- DATACALL mini interupt
                    DPCR_Clear <= '1';

                    DPRR_Write <= '1';
                    DPRR_IRQ_Clear <= '1';
                    DPRR_RES_Write <= '0';
                    DPRR_IRQ_EN <= '0';

                    -- go back to the decode stage
                    FSM_STATE <= "010";

                WHEN "110" =>
                    -- SPINLOCK for blocking datacalls
                    -- Doesn't exit for some reason
                    IF (DPRR_IRQ = '1') THEN
                        FSM_STATE <= "101";
                    ELSE
                        FSM_STATE <= "110";
                    END IF;
                    
                WHEN "111" =>
                    -- HALT
                    -- STOP RIGHT THERE CRIMINAL SCUM YOU HAVE VIOLATED THE LAW!
                    FSM_STATE <= "111";

                WHEN OTHERS =>
                    -- This shouldn't happen
                    NULL;
            END CASE;
        END IF;
    END PROCESS;
END behavior;