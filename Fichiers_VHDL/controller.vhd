LIBRARY ieee;
LIBRARY std;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS
	PORT(
	
		OP         : IN std_logic_vector(5 downto 0); -- port d'entrée main decodeur
		Funct      : IN std_logic_vector(5 downto 0); -- port d'entrée ALU decodeur
		
		-- ports de sorties main decodeur
		MemtoReg   : OUT std_logic;
		MemWrite   : OUT std_logic;
		MemRead    : OUT std_logic;
		Branch     : OUT std_logic;
		AluSrc     : OUT std_logic;
		RegDst     : OUT std_logic;
		RegWrite   : OUT std_logic;
		Jump       : OUT std_logic;
		
		-- port de sortie ALU decodeur
		AluControl : OUT std_logic_vector(3 downto 0)	
		
	);
END; -- CONTROLLER

ARCHITECTURE structure_interne OF controller IS

	SIGNAL AluControl_i : std_logic_vector(3 downto 0);
	SIGNAL ALUOp        : std_logic_vector(1 downto 0);
	
BEGIN

	-- Logique Main Decoder
	RegWrite <= '1' WHEN OP = "000000" ELSE   -- R-Type
					'1' WHEN OP = "100011" ELSE   -- Lw
					'0' WHEN OP = "101011" ELSE   -- Sw
					'0' WHEN OP = "000100" ELSE   -- Beq
					'1' WHEN OP = "001000" ELSE   -- Addi
					'0' WHEN OP = "000010" ELSE   -- Jump
					'0';
	
	RegDst   <= '1' WHEN OP = "000000" ELSE
					'0' WHEN OP = "100011" ELSE
					'-' WHEN OP = "101011" ELSE
					'X' WHEN OP = "000100" ELSE
					'0' WHEN OP = "001000" ELSE
					'X' WHEN OP = "000010" ELSE
					'0';
					
	AluSrc	<= '0' WHEN OP = "000000" ELSE
					'1' WHEN OP = "100011" ELSE
					'1' WHEN OP = "101011" ELSE
					'0' WHEN OP = "000100" ELSE
					'1' WHEN OP = "001000" ELSE
					'X' WHEN OP = "000010" ELSE
					'0';
					
	Branch   <= '0' WHEN OP = "000000" ELSE
					'0' WHEN OP = "100011" ELSE
					'0' WHEN OP = "101011" ELSE
					'1' WHEN OP = "000100" ELSE
					'0' WHEN OP = "001000" ELSE
					'X' WHEN OP = "000010" ELSE
					'0';
					
	MemRead  <= '0' WHEN OP = "000000" ELSE
					'1' WHEN OP = "100011" ELSE
					'0' WHEN OP = "101011" ELSE
					'0' WHEN OP = "000100" ELSE
					'0' WHEN OP = "001000" ELSE
					'0' WHEN OP = "000010" ELSE
					'0';
					
	MemWrite <= '0' WHEN OP = "000000" ELSE
					'0' WHEN OP = "100011" ELSE
					'1' WHEN OP = "101011" ELSE
					'0' WHEN OP = "000100" ELSE
					'0' WHEN OP = "001000" ELSE
					'0' WHEN OP = "000010" ELSE
					'0';
					
	MemtoReg <= '0' WHEN OP = "000000" ELSE
					'1' WHEN OP = "100011" ELSE
					'X' WHEN OP = "101011" ELSE
					'X' WHEN OP = "000100" ELSE
					'0' WHEN OP = "001000" ELSE
					'X' WHEN OP = "000010" ELSE
					'0';
					
	ALUOp    <= "10" WHEN OP = "000000" ELSE
					"00" WHEN OP = "100011" ELSE
					"00" WHEN OP = "101011" ELSE
					"01" WHEN OP = "000100" ELSE
					"00" WHEN OP = "001000" ELSE
					"XX" WHEN OP = "000010" ELSE
					"00";
					
	Jump     <= '0' WHEN OP = "000000" ELSE
					'0' WHEN OP = "100011" ELSE
					'0' WHEN OP = "101011" ELSE
					'0' WHEN OP = "000100" ELSE
					'0' WHEN OP = "001000" ELSE
					'1' WHEN OP = "000010" ELSE
					'0';

	-- Logique ALU Decoder
	alu_decoder : PROCESS(Funct, ALUOp)
	BEGIN
		
		IF (ALUOp = "00") THEN
		
			AluControl_i <= "0010";              -- ADD
			
		ELSE
		
			IF(Funct = "100000") THEN
				
				AluControl_i <= "0010";           -- ADD
				
			ELSIF (Funct = "100010") THEN
			
				AluControl_i <= "0110";           -- SUB
			
			ELSIF (Funct = "100100") THEN
			
				AluControl_i <= "0010";           -- AND
			
			ELSIF (Funct = "100101") THEN
			
				AluControl_i <= "0001";           -- OR
			
			ELSIF (Funct = "101010") THEN
				
				AluControl_i <= "0111";           -- SLT
				
			ELSE
			
				AluControl_i <= "XXXX";           -- Don't Care
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	AluControl <= AluControl_i;
	
END structure_interne;