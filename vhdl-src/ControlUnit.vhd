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
        CMP0 : IN STD_LOGIC; -- compare == 0
        OP_Code : IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- OP code
        AM : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Adressing Mode
        Z_Flag : IN STD_LOGIC;
        -- OUTPUTS DATA FLOW
        Address_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Address select for the instruction memory
        Data_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Data select for the data memory
        ALU_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_Select_2 : OUT STD_LOGIC;
        Reg_Select : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register select for the register file
        PC_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        DPCR_Select : OUT STD_LOGIC;
        -- OUPUTS DATA CONTROL
        DPCR_Store : OUT STD_LOGIC;
        PC_Store : OUT STD_LOGIC; --Control signal to update the program counter
        IR_Load : OUT STD_LOGIC; -- Control signal for the instruction memory
        Reg_Store : OUT STD_LOGIC; -- Control signal for the register file
        ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- ALU operation code
        DM_LOAD : OUT STD_LOGIC; -- Control signal for the data memory load
        DM_STORE : OUT STD_LOGIC; -- Control signal for the data memory store
        CLR_Z_Flag : OUT STD_LOGIC;
    );

END ENTITY ControlUnit;
ARCHITECTURE behavior OF ControlUnit IS
    signal FSM_STATE : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";    -- FSM state used for a multicycle implimentation

    signal New_Address_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; 
    signal New_Data_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    signal New_ALU_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    signal New_ALU_Select_2 : STD_LOGIC := '0';
    signal New_Reg_Select : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    signal New_PC_Select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    signal New_DPCR_Select : STD_LOGIC := '0';
    signal New_DPCR_Store : STD_LOGIC := '0';
    signal New_PC_Store : STD_LOGIC := '0';
    signal New_IR_Load : STD_LOGIC := '0';
    signal New_Reg_Store : STD_LOGIC := '0';
    signal TEMP_Reg_Store : STD_LOGIC := '0';
    signal New_ALU_OP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
    signal New_DM_LOAD : STD_LOGIC := '0';
    signal New_DM_STORE : STD_LOGIC := '0';
    signal New_CLR_Z_Flag : STD_LOGIC := '0';
BEGIN 

    process(CLK)
    begin
        if rising_edge(CLK) then

            New_Address_Select <= "00";
            New_Data_Select <= "00";
            New_ALU_Select <= "00";
            New_Reg_Select <= "000";
            New_PC_Select <= "00";
            New_IM_Store <= '0';
            New_IM_Load <= '0';
            New_IR_Load <= '0';
            New_ALU_OP <= "100";
            New_DM_LOAD <= '0';
            New_DM_STORE <= '0';
            case FSM_STATE is
                when "00" =>
                    -- Instruction Fetch
                    New_PC_Select <= "00";
                    New_PC_Store <= '1';
                    New_IR_Load <= '1';
                when "01" =>
                    -- Instruction Decode
                    -- BEHOLD THE MONOLITH!
                    case OP_Code is
                        when andr => 
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_and;
                            New_ALU_Select <= "00" when (AM = am_immediate) else "01";
                        when orr =>
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_or;
                            New_ALU_Select <= "00" when (AM = am_immediate) else "01";
                        when addr =>
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_add;
                            New_ALU_Select <= "00" when (AM = am_immediate) else "01";
                        when subvr => 
                            TEMP_Reg_Store <= '1';
                            New_ALU_OP <= alu_sub;
                            New_ALU_Select <= "00";
                            New_ALU_Select_2 <= '0';
                        when subr =>
                            New_ALU_OP <= alu_sub;
                            New_ALU_Select <= "00";
                            New_ALU_Select_2 <= '1';
                        when ldr =>
                            TEMP_Reg_Store <= '1';
                            case AM is
                                when am_immediate =>
                                    New_Reg_Select <= "100";
                                when am_register =>
                                    New_Reg_Select <= "011";
                                    New_DM_LOAD <= '1';
                                    New_Address_Select <= "10";
                                when am_direct =>
                                    New_Reg_Select <= "011";
                                    New_DM_LOAD <= '1';
                                    New_Address_Select <= "00";
                            end case;
                        when str =>
                            New_DM_STORE <= '1';
                            case AM is
                                when am_immediate =>
                                    New_Address_Select <= "01";
                                    New_Data_Select <= "00";
                                when am_register =>
                                    New_Address_Select <= "01";
                                    New_Data_Select <= "01";
                                when am_direct =>
                                    New_Address_Select <= "00";
                                    New_Data_Select <= "01";
                            end case;
                        when jmp =>
                            New_PC_Store <= '1';
                            New_PC_Select <= "01" when (AM = am_immediate) else "10";
                        when present =>
                                -- Do nothing till the next cycle
                        when datacall =>
                            New_DPCR_Store <= '1';
                            New_DPCR_Select <= '0';
                        when datacall2 =>
                            New_DPCR_Store <= '1';
                            New_DPCR_Select <= '1';
                        when sz =>
                            New_PC_Select <= "01";
                            New_PC_Store <= '1' when Z_Flag else '0';
                        when clfz =>
                            New_CLR_Z_Flag <= '1';
                        when cer => 

                        when ceot =>

                        when seot =>

                        when ler =>
                            New_Register_Store <= '1';
                            New_Reg_Select <= "001";
                        when ssvop =>
                                
                        when lsip =>
                            New_Register_Store <= '1';
                            New_Reg_Select <= "010";
                        when ssop =>

                        when noop =>
                            -- Do nothing
                        when max =>
                            New_ALU_OP <= alu_max;
                            New_Register_Store <= '1';
                            New_Reg_Select <= "010";
                            New_ALU_Select <= "00";
                            New_ALU_Select_2 <= '1';
                        when strpc =>
                            New_DM_STORE <= '1';
                            New_Address_Select <= "00";
                            New_Data_Select <= "10";
                        when others =>
                                -- Do nothing I guess???
                                -- Shouldn't happen but who knows
                    end case;
                when "10" =>
                    
            end case;
        end if;
    end process;
    
    Address_Select <= "00";
    Data_Select <= "00";
    ALU_Select <= "00";
    ALU_Select_2 <= '0';
    Reg_Select <= "000";
    PC_Select <= "00";
    IR_Load <= '0';
    Reg_Store <= '0';
    ALU_OP <= "000";
    DM_LOAD <= '0';
    DM_STORE <= '0';

END behavior;