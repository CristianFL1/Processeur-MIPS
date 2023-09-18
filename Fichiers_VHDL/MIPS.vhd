LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MIPS IS
	PORT(
		
		Clk		   : IN std_logic;
		Reset		   : IN std_logic;
		
		-- ports d'entrée MIPS
		Instruction : IN std_logic_vector(31 downto 0);
		readData    : IN std_logic_vector(31 downto 0);
		
		-- port de sortie MIPS
		MemReadOut  : OUT std_logic;
		MemWriteOut : OUT std_logic;
		PC          : OUT std_logic_vector(31 downto 0);
		AluResult   : OUT std_logic_vector(31 downto 0);
		WriteData   : OUT std_logic_vector(31 downto 0)
	
	);
END; -- MIPS

ARCHITECTURE structure_interne OF MIPS IS
		
		-- signaux internes pour la connexion entre l'unite de controle et le datapath
		SIGNAL MemtoReg_int	 : std_logic;
		SIGNAL MemWrite_int	 : std_logic;
		SIGNAL MemRead_int 	 : std_logic;
		SIGNAL Branch_int  	 : std_logic;
		SIGNAL AluSrc_int  	 : std_logic;
		SIGNAL RegDst_int  	 : std_logic;
		SIGNAL RegWrite_int	 : std_logic;
		SIGNAL Jump_int    	 : std_logic;
		SIGNAL AluControl_int : std_logic_vector(3 downto 0);
		
		
BEGIN

	-- Instance de l'unité de controle
	controller : ENTITY work.controller(structure_interne)
				  PORT MAP (
				  
					-- Entrees
				  
					OP         => Instruction(31 downto 26),
					Funct      => Instruction(5 downto 0),
					 
					-- Sorties
					
					MemtoReg   => MemtoReg_int,
					MemWrite   => MemWrite_int,
					MemRead    => MemRead_int,
					Branch     => Branch_int,
					AluSrc     => AluSrc_int,
					RegDst     => RegDst_int,
					RegWrite   => RegWrite_int,
					Jump       => Jump_int,
					
					AluControl => AluControl_int
				  
				  );
	
	-- Instance du datapath
	datapath : ENTITY work.datapath(structure_interne)
				  PORT MAP (
					
					--Entrees
					
					Clk        => Clk,
					Reset      => Reset,
					
					MemToReg   => MemtoReg_int,
					MemWrite   => MemWrite_int,
					MemRead    => MemRead_int,
					Branch     => Branch_int,
					AluSrc     => AluSrc_int,
					RegDst     => RegDst_int,
					RegWrite   => RegWrite_int,
					Jump       => Jump_int,
					             
					AluControl => AluControl_int,
					
					Instruction => Instruction,
					ReadData    => readData,
					
					-- Sorties
					
					MemReadOut  => MemReadOut,
					MemWriteOut => MemWriteOut,
					PC          => PC,
					AluResult   => AluResult,
					WriteData   => WriteData
				  
				  );
	
END structure_interne;