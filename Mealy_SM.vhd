library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Mealy_SM IS PORT
(
	 clk_input, rst_n, pb3, pb2, extender_out			: IN std_logic;
	 XGT, XEQ, XLT, YGT, YEQ, YLT 						: IN std_logic;
	 extender, error											: OUT std_logic;
	 converted_state   										: OUT std_logic_vector(1 downto 0)
);
END ENTITY;
 

ARCHITECTURE SM OF Mealy_SM IS
 

TYPE STATE_NAMES IS (S0, S1, S2, S3, S4); 
	-- S0 defines x and y both not moving
	-- S1 defines x not moving and y moving
	-- S2 defines x moving and y not moving
	-- S3 defines x and y both moving
	-- S4 defines the error case 
			
SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES

BEGIN


 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock

BEGIN
	IF (rst_n = '0') THEN
		current_state <= S0;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	


-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (pb3, pb2, XEQ, YEQ, current_state) 

BEGIN
     CASE current_state IS
	  
         WHEN S0 =>	
				IF(extender_out = '1' AND ((pb3 = '1' AND XEQ = '0') OR (pb2 = '1' AND YEQ = '0'))) THEN
					next_state <= S4;
				ELSIF((pb3 = '0' AND pb2 = '1' AND YEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '1' AND YEQ = '0')) THEN
					next_state <= S1;
				ELSIF((pb3 = '1' AND pb2 = '0' AND XEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '1')) THEN
					next_state <= S2;
				ELSIF(pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '0') THEN
					next_state <= S3;		
				ELSE 
					next_state <= S0;
				END IF;
				
         WHEN S1 =>	
				IF((pb3 = '0' AND pb2 = '1' AND YEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '1' AND YEQ = '0')) THEN
					next_state <= S1;
				ELSIF((pb3 = '1' AND pb2 = '0' AND XEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '1')) THEN
					next_state <= S2;
				ELSIF(pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '0') THEN
					next_state <= S3;
				ELSE
					next_state <= S0;
				END IF;
				
         WHEN S2 =>		
				IF((pb3 = '0' AND pb2 = '1' AND YEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '1' AND YEQ = '0')) THEN
					next_state <= S1;
				ELSIF((pb3 = '1' AND pb2 = '0' AND XEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '1')) THEN
					next_state <= S2;
				ELSIF(pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '0') THEN
					next_state <= S3;
				ELSE
					next_state <= S0;
				END IF;
				
         WHEN S3 =>	
				IF((pb3 = '0' AND pb2 = '1' AND YEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '1' AND YEQ = '0')) THEN
					next_state <= S1;
				ELSIF((pb3 = '1' AND pb2 = '0' AND XEQ = '0') OR (pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '1')) THEN
					next_state <= S2;
				ELSIF(pb3 = '1' AND pb2 = '1' AND XEQ = '0' AND YEQ = '0') THEN
					next_state <= S3;
				ELSE
					next_state <= S0;
				END IF;
				
			WHEN S4 =>
				IF(extender_out = '0') THEN
					next_state <= S0;
				ELSE
					next_state <= S4;
				END IF;

 		END CASE;

 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (XEQ, YEQ, current_state) 

-- OUTPUTS:
-- converted_state: outputs the current state as a 2 bit binary vector 
-- extender: the extender enable signal
-- error: boolean value representing our error case


BEGIN
     CASE current_state IS

         WHEN S0 =>	
				converted_state <= "00"; 
				IF(XEQ = '1' AND YEQ = '1') THEN
					extender <= '1';
					error <= '0';
				ELSE
					extender <= '0';
					error <= '0';
				END IF;
			
         WHEN S1 =>		
				extender <= '0';	
				error <= '0';			
				converted_state <= "01";
				
         WHEN S2 =>		
				extender <= '0';
				error <= '0';
				converted_state <= "10";
				
         WHEN S3 =>		
				extender <= '0';
				error <= '0';
				converted_state <= "11";
				
			WHEN OTHERS =>
				error <= '1';
				extender <= '1';
				converted_state <= "00";

	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;