library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Magnitude comparator of 2 one-bit inputs

entity Compx1 is port(
	
	input_A 	: in std_logic;		
	input_B 	: in std_logic;
	agtb		: out std_logic; -- Is A greater than B?
	aeqb		: out std_logic; -- Is A equal to B?
	altb		: out std_logic  -- Is A less than B?
	
);
end Compx1;

	
architecture Dataflow of Compx1 is

begin

	agtb <= input_A AND (NOT input_B);		-- AB'
	aeqb <= input_A XNOR input_B;				-- A XNOR B
	altb <= (NOT input_A) AND input_B;		-- A'B
					 
end architecture Dataflow; 