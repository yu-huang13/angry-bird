library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity singleClkDiv is
	port (
		in_clk, aim_clk : in std_logic;
		out_clk : out std_logic
	);
end singleClkDiv;

architecture struc of singleClkDiv is
begin
	process(in_clk)
	begin
		if in_clk'event and in_clk = '1' then
			out_clk <= not aim_clk;
		end if;
	end process;
end struc; 