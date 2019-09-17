library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY MOORE_SM1 IS PORT 
(
	 CLK		     								: in  std_logic := '0';
	 RESET_n      								: in  std_logic := '0';
	 EXTENDED									: in  std_logic;
	 pb											: in 	std_logic;
	 display										: in 	std_logic_vector(3 downto 0) ;
	 GRAP_ON			   						: out std_logic;
	 extender_out, enable, left_right 	: out std_logic
);
END ENTITY;

ARCHITECTURE SM OF MOORE_SM1 IS

-- list all the STATES  
   TYPE STATES IS (S0, S1, S2, S3);  

-- S0: state which defines the extender as fully retracted
-- S1: state which defines the extender in the process of extending
-- S2: state which defines the extender as fully extended
-- S3: state which defines the extender in the process of retracting	

   SIGNAL current_state, next_state			:  STATES;       -- current_state, next_state signals are of type STATES

	
BEGIN

-- STATE MACHINE: MOORE Type

REGISTER_SECTION: PROCESS(CLK, RESET_n, next_state) -- creates sequential logic to store the state. The rst_n is used to asynchronously clear the register
   BEGIN
		IF (RESET_n = '0') THEN
	         current_state <= S0;
		ELSIF (rising_edge(CLK)) then
				current_state <= next_state; -- on the rising edge of clock the current state is updated with next state
		END IF;
   END PROCESS;
	

 TRANSITION_LOGIC: PROCESS(display, current_state) -- logic to determine next state. 
   BEGIN
     CASE current_state IS
	 
			WHEN S0 =>	
		      IF (pb = '1' AND EXTENDED = '1') THEN 
               next_state <= S1;
				ELSE
               next_state <= S0;
            END IF;
				
			WHEN S1 =>		
            IF (display = "1111" AND EXTENDED = '1') THEN 
               next_state <= S2;
				ELSE
               next_state <= S1;
            END IF;
				
			WHEN S2 =>		
            IF (pb = '1' AND EXTENDED = '1') THEN 
               next_state <= S3;
				ELSE
               next_state <= S2;
            END IF;
				
			WHEN S3 =>		
            IF (display = "0000" AND EXTENDED = '1') THEN 
               next_state <= S0;
				ELSE
               next_state <= S3;
            END IF;
					
 		END CASE;
		
 END PROCESS;

 MOORE_DECODER: PROCESS(current_state) 			-- logic to determine outputs from state machine states
 
 -- Outputs:
 -- GRAP_ON: Grappler enable signal
 -- extender_out: Whether or not the extender is partially out, for error case
 -- enable: Whether the Bidirectional Shift Register should be enabled
 -- left_right: Direction of Bidirectional Shift Register
 
 BEGIN
	
     CASE current_state IS
	  
			WHEN s0 =>
				GRAP_ON <= '0';
				extender_out <= '0';
				enable <= '0';
				left_right <= '1';
				
			WHEN s1 =>
				GRAP_ON <= '0';
				extender_out <= '1';
				enable <= '1';
				left_right <= '1';
				
			WHEN s2 =>
				GRAP_ON <= '1';
				extender_out <= '1';
				enable <= '0';
				left_right <= '0';
	  
			WHEN OTHERs =>		
				GRAP_ON	<= '0';
				extender_out <= '1';
				enable <= '1';
				left_right <= '0';
						 
		END CASE;

 END PROCESS;

END SM;
