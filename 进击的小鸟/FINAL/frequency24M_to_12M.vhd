library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity frequency24M_to_12M is
	port(
		clk24M: in std_logic;
		clk12M: out std_logic
	);
end;

architecture ft of frequency24M_to_12M is 

signal clk12MHz_temp: std_logic:= '1';

begin
	
	clk12M <= clk12MHz_temp;
	
	process(clk24M)
	begin
		if (clk24M'event and clk24M = '1') then
				clk12MHz_temp <= not clk12MHz_temp;
		end if;
	end process;

end ft;
	