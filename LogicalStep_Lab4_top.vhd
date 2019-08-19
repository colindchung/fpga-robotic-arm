
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50		: in	std_logic;
	rst_n			: in	std_logic;
	pb				: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
	
----------------------------------------------------------------------------------------------------
	CONSTANT	SIM												: boolean := FALSE; 	-- set to TRUE for simulation runs otherwise keep at 0.
   CONSTANT CLK_DIV_SIZE									: integer := 26;    -- size of vectors for the counters
   SIGNAL 	Main_CLK											: std_logic; 			-- main clock to drive sequencing of State Machine
	SIGNAL 	bin_counter										: unsigned(CLK_DIV_SIZE-1 downto 0); -- := to_unsigned(0,CLK_DIV_SIZE); -- reset binary counter to zero
	SIGNAL 	extender_en, grappler_en					: std_logic;
	SIGNAL   extender_out, bidir_en, left_right 		: std_logic;
	SIGNAL 	XEQ, XGT, XLT, YEQ, YGT, YLT				: std_logic;
	SIGNAL	XCurrent, YCurrent							: std_logic_vector(3 downto 0);
	SIGNAL 	XDisplay, YDisplay							: std_logic_vector(3 downto 0);
	SIGNAL 	moore_display 									: std_logic_vector(3 downto 0);
	SIGNAL 	seg7_X, seg7_Y									: std_logic_vector(6 downto 0);
	SIGNAL 	converted_state 								: std_logic_Vector(1 downto 0);
	SIGNAL 	error												: std_logic;
	
----------------------------------------------------------------------------------------------------
component Bidir_shift_reg port
(
	CLK				: in std_logic := '0';
	RESET_n			: in std_logic := '0';
	CLK_EN			: in std_logic := '0';
	LEFT0_RIGHT1	: in std_logic := '0';
	REG_BITS			: out std_logic_vector(3 downto 0)
);
end component;

component U_D_Bin_Counter8bit port
(
	CLK				: in std_logic := '0';
	RESET_n			: in std_logic := '0';
	CLK_EN			: in std_logic := '0';
	UP1_DOWN0		: in std_logic := '0';
	COUNTER_BITS	: out std_logic_vector(3 downto 0)
);
end component;

component Compx4 port
(
	input_A 	: in std_logic_vector(3 downto 0);
	input_B 	: in std_logic_vector(3 downto 0);
	AGTB		: out std_logic;	-- Is A greater than B?
	AEQB		: out std_logic;	-- Is A equal to B?
	ALTB		: out std_logic	-- Is A less than B?
);
end component;

component SevenSegment port
(   
	error		:  in  std_logic;
   hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed  
   sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end component;

component segment7_mux port 
(
	clk		: in std_logic := '0';
	DIN2		: in std_logic_vector(6 downto 0);
	DIN1		: in std_logic_vector(6 downto 0);
	DOUT		: out std_logic_vector(6 downto 0);
	DIG2		: out std_logic;
	DIG1		: out std_logic
);
end component;

component Mealy_SM port
(
	clk_input, rst_n, pb3, pb2, extender_out		: in std_logic;
	XGT, XEQ, XLT, YGT, YEQ, YLT 						: in std_logic;
	extender, error										: out std_logic;
	converted_state   									: out std_logic_vector(1 downto 0)
 );
end component;

component MOORE_SM1 port
(
	CLK		     								: in  std_logic := '0';
	RESET_n      								: in  std_logic := '0';
	EXTENDED										: in  std_logic;
	pb 											: in std_logic;
	display										: in std_logic_vector(3 downto 0) ;
	GRAP_ON			   						: out std_logic;
	extender_out, enable, left_right 	: out std_logic
);
end component;

component MotionControl port
(
	pb											: in std_logic;
	sw 										: in std_logic_vector(3 downto 0);
	current_state							: in std_logic_vector(1 downto 0);
	current_count							: in std_logic_vector(3 downto 0);
	toDisplay								: out std_logic_vector(3 downto 0)
);
end component;

component MOORE_SM2 port
(
	 CLK		     		: in  std_logic;
	 RESET_n      		: in  std_logic;
	 GRAP_BUTTON		: in  std_logic;
	 GRAP_ENBL			: in  std_logic;
	 GRAP_ON			   : out std_logic
);
end component;

BEGIN

-- Instantiations

INST_Mealy: Mealy_SM port map(Main_clk, rst_n, NOT pb(3), NOT pb(2), extender_out, XGT, XEQ, XLT, YGT, YEQ, YLT, extender_en, error, converted_state);
INST_Display_SevenSeg: segment7_mux port map(clkin_50, seg7_X, seg7_Y, seg7_data, seg7_char1, seg7_char2);

INST_Moore_1 : MOORE_SM1 port map(Main_Clk, rst_n, extender_en, NOT pb(1), moore_display, grappler_en, extender_out, bidir_en, left_right);
INST_Moore_2 : MOORE_SM2 port map(Main_Clk, rst_n, NOT pb(0), grappler_en, leds(3)); 
INST_BIDIR_SHIFT : Bidir_shift_reg port map(Main_Clk, rst_n, bidir_en, left_right, moore_display);

INST_XMotion : MotionControl port map(NOT pb(3), sw(7 downto 4), converted_state, XCurrent, XDisplay);
INST_YMotion : MotionControl port map(NOT pb(2), sw(3 downto 0), converted_state, YCurrent, YDisplay);

INST_X_Up_Down_Counter: U_D_Bin_Counter8bit port map(Main_Clk, rst_n, NOT XEQ AND (NOT pb(3)), XGT, XCurrent);
INST_X_Comparator: Compx4 port map(sw(7 downto 4), XCurrent, XGT, XEQ, XLT);
INST_X_Seg7: SevenSegment port map(Main_Clk AND error, XDisplay, seg7_X);

INST_Y_Up_Down_Counter: U_D_Bin_Counter8bit port map(Main_Clk, rst_n, NOT YEQ AND (NOT pb(2)), YGT, YCurrent);
INST_Y_Comparator: Compx4 port map(sw(3 downto 0), YCurrent, YGT, YEQ, YLT);
INST_Y_Seg7: SevenSegment port map(Main_Clk AND error, YDisplay, seg7_Y);

-- LED Assignment

leds(0) <= error;
leds(7 downto 4) <= moore_display;

-- CLOCKING GENERATOR WHICH DIVIDES THE INPUT CLOCK DOWN TO A LOWER FREQUENCY

BinCLK: PROCESS(clkin_50, rst_n) is
   BEGIN
		IF (rising_edge(clkin_50)) THEN -- binary counter increments on rising clock edge
         bin_counter <= bin_counter + 1;
      END IF;
   END PROCESS;

Clock_Source:
				Main_Clk <= 
				clkin_50 when sim = TRUE else			-- for simulations only
				std_logic(bin_counter(23));			-- for real FPGA operation
					
---------------------------------------------------------------------------------------------------

END SimpleCircuit;
