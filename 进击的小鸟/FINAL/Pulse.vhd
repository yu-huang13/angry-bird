library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Pulse is
	port (
		clk_h : in std_logic; -- of high frequency
		clk_l : in std_logic; -- of low frequency
		-- take care: the difference between clk_h and clk_l must be large enough
		clk_out : out std_logic
	);
end Pulse;

architecture struc of Pulse is
	signal last : std_logic := '0';
begin
	process(clk_h)
	begin
		if clk_h'event and clk_h = '1' then
			if last = '0' and clk_l = '1' then
				clk_out <= '1';
			else
				clk_out <= '0';
			end if;
			last <= clk_l;
		end if;
	end process;

end struc;