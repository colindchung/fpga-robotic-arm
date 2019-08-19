library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MotionControl is port
(
	pb											: in std_logic;
	sw 										: in std_logic_vector(3 downto 0);
	current_state							: in std_logic_vector(1 downto 0);
	current_count							: in std_logic_vector(3 downto 0);
	toDisplay								: out std_logic_vector(3 downto 0)
);
end entity;


architecture Structural of MotionControl is

signal input : std_logic_Vector(2 downto 0);


begin

input <= current_state & pb;

   with input select						  
	toDisplay 				    <= sw when "000",
									  	 sw when "001",
										 sw when "010",
									  	 current_count when "011",
										 sw when "100",
									  	 current_count when "101",
										 sw when "110",
									  	 current_count when others;
	
end architecture Structural; 