library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity frequency100M_to_20K is
	port(
		clk100M: in std_logic;
		clk20K: out std_logic
	);
end;

architecture fre of frequency100M_to_20K is

signal clk_20KHz_temp: std_logic;
signal clk_20KHz_counter: integer range 0 to 2500:= 0; --2500

begin
	
	clk20K <= clk_20KHz_temp;
	
	process(clk100M)--分频
	begin
		if (clk100M'event and clk100M = '1') then
			if (clk_20KHz_counter < 2499) then --2499
				clk_20KHz_counter <= clk_20KHz_counter + 1;
			else
				clk_20KHz_temp <= not clk_20KHz_temp;
				clk_20KHz_counter <= 0;
			end if;
		end if;
	end process;
	
	
end fre;