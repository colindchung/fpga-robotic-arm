library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Magnitude comparator of 2 four-bit inputs

entity Compx4 is port(
	
	input_A 	: in std_logic_vector(3 downto 0);
	input_B 	: in std_logic_vector(3 downto 0);
	AGTB		: out std_logic;	-- Is A greater than B?
	AEQB		: out std_logic;	-- Is A equal to B?
	ALTB		: out std_logic	-- Is A less than B?
);
end Compx4;

architecture Dataflow of Compx4 is
--
-- Components Used
------------------------------------------------------------------- 
	component Compx1 port ( 		-- one-bit comparator component
		input_a 	: in std_logic;
		input_b 	: in std_logic;
		agtb		: out std_logic;
		aeqb		: out std_logic;
		altb		: out std_logic
		
	);
	end component;

-- Each signal representing the comparison possibilities of a single bit.

	signal A3GTB3		: std_logic;   -- Is most significant bit of A greater than that of B?
	signal A3EQB3		: std_logic;	-- etc...
	signal A3LTB3		: std_logic;
	signal A2GTB2		: std_logic;
	signal A2EQB2		: std_logic;
	signal A2LTB2		: std_logic;
	signal A1GTB1		: std_logic;
	signal A1EQB1		: std_logic;
	signal A1LTB1		: std_logic;
	signal A0GTB0		: std_logic;
	signal A0EQB0		: std_logic;
	signal A0LTB0		: std_logic; 	-- Is the least significant bit of A less than that of B?

-- Here the circuit begins
begin

	-- Instantiate a one-bit comparator component for each bit in the 4 bit inputs
	INST1: Compx1 port map(input_A(3), input_B(3), A3GTB3, A3EQB3, A3LTB3);	-- First bit
	INST2: Compx1 port map(input_A(2), input_B(2), A2GTB2, A2EQB2, A2LTB2); -- Second bit
	INST3: Compx1 port map(input_A(1), input_B(1), A1GTB1, A1EQB1, A1LTB1); -- Third bit
	INST4: Compx1 port map(input_A(0), input_B(0), A0GTB0, A0EQB0, A0LTB0); -- Fourth bit
	
	-- Output Initializations
	-- Logical statements to compute the greater value
	AGTB <= A3GTB3 OR (A3EQB3 AND A2GTB2) OR (A3EQB3 AND A2EQB2 AND A1GTB1) OR (A3EQB3 AND A2EQB2 AND A1EQB1 AND A0GTB0); 
	ALTB <= A3LTB3 OR (A3EQB3 AND A2LTB2) OR (A3EQB3 AND A2EQB2 AND A1LTB1) OR (A3EQB3 AND A2EQB2 AND A1EQB1 AND A0LTB0);
	AEQB <= A3EQB3 AND A2EQB2 AND A1EQB1 AND A0EQB0;
				 
end architecture Dataflow; 