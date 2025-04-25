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
    SIGNAL TEMP_Reg_Store : STD_LOGIC := '0';
BEGIN

    PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            -- Default values each clock cycle
            Address_Select <= "00";
            Data_Select <= "00";
            ALU_Select <= "00";
            ALU_Select_2 <= '0';
            Reg_Select <= "000";
            PC_Select <= "00";
            DPCR_Select <= '0';

            IR_Load <= '0';
            ALU_OP <= "100";
            DM_LOAD <= '0';
            DM_STORE <= '0';
            
            DPCR_Store <= '0';
            PC_Store <= '0';
            Reg_Store <= '0';
            CLR_Z_Flag <= '0';


            CASE FSM_STATE IS
                WHEN "00" =>
                    -- Instruction Fetch
                    IR_Load <= '1';

                    -- Incriment PC by 2
                    PC_Select <= "00";
                    PC_Store <= '1';

                    
                    FSM_STATE <= "01"; -- Move to decode

                WHEN "01" =>
                    -- Instruction Decode / Register Access

                    -- If the Instruction requires an immediate value incriment PC and fetch it
                    IF (AM = am_immediate) THEN
                        PC_Select <= "00";
                        PC_Store <= '1';
                    END IF;


                    -- Complete Simple Instructions
                    CASE OP_Code IS
                        WHEN clfz =>
                            CLR_Z_Flag <= '1';

                        WHEN cer =>
                            NULL;

                        WHEN ceot =>
                            NULL;

                        WHEN seot =>
                            NULL;

                        WHEN ler =>
                            Reg_Store <= '1';
                            Reg_Select <= "001";

                        WHEN lsip =>
                            Reg_Store <= '1';
                            Reg_Select <= "010";

                        WHEN noop =>
                            NULL; 
                    END CASE;

                WHEN "10" =>
                    -- Instruction Decode

                    -- Used 
                    TEMP_Reg_Store <= '0';


                    -- BEHOLD THE CASE STATEMENT!
                    -- THE TOWER OF BABBLE DOESN'T COME CLOSE
                    CASE OP_Code IS
                        WHEN andr =>
                            TEMP_Reg_Store <= '1';
                            ALU_OP <= alu_and;
                            IF (AM = am_immediate) THEN

                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;
                        WHEN orr =>
                            TEMP_Reg_Store <= '1';
                            ALU_OP <= alu_or;
                            IF (AM = am_immediate) THEN
                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;

                        WHEN addr =>
                            TEMP_Reg_Store <= '1';
                            ALU_OP <= alu_add;
                            IF (AM = am_immediate) THEN
                                ALU_Select <= "00";
                            ELSE
                                ALU_Select <= "01";
                            END IF;

                        WHEN subvr =>
                            TEMP_Reg_Store <= '1';
                            ALU_OP <= alu_sub;
                            ALU_Select <= "00";
                            ALU_Select_2 <= '0';

                        WHEN subr =>
                            ALU_OP <= alu_sub;
                            ALU_Select <= "00";
                            ALU_Select_2 <= '1';

                        WHEN ldr =>
                            TEMP_Reg_Store <= '1';
                            CASE AM IS
                                WHEN am_immediate =>
                                    Reg_Select <= "100";
                                WHEN am_register =>
                                    Reg_Select <= "011";
                                    DM_LOAD <= '1';
                                    Address_Select <= "10";
                                WHEN am_direct =>
                                    Reg_Select <= "011";
                                    DM_LOAD <= '1';
                                    Address_Select <= "00";
                                WHEN OTHERS =>
                                    -- do nothing 
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
                                    -- do nothing     
                            END CASE;

                        WHEN jmp =>
                            PC_Store <= '1';
                            IF (AM = am_immediate) THEN
                                PC_Select <= "00";
                            ELSE
                                PC_Select <= "10";
                            END IF;
                        WHEN present =>
                            NULL;

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
                            NULL;

                        WHEN ssop =>
                            NULL;

                        WHEN max =>
                            ALU_OP <= alu_max;
                            Reg_Store <= '1';
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

                    FSM_STATE <= "00"; -- Go back to fetch

                WHEN "11" =>
                    -- You can implement more execution/mem stages here if needed
                    FSM_STATE <= "00";

                WHEN OTHERS =>
                    -- DO nothing need this for 
            END CASE;
        END IF;
    END PROCESS;
END behavior;