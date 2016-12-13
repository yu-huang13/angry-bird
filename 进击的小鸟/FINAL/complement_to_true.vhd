library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity complement_to_true is
	generic (width : integer := 24); 
	port(
		complement_code: in std_logic_vector (width - 1 downto 0);
		true_code: out std_logic_vector (width - 1 downto 0)
	);
end;

architecture ctt of complement_to_true is
signal temp: std_logic_vector (width - 1 downto 0);
begin
	process (complement_code)
	begin
		if (complement_code(width - 1) = '0') then
			true_code <= complement_code;
		else
			temp <= complement_code - 1;
			true_code <= temp(width - 1) & (not temp(width - 2 downto 0));
		end if;
	end process;
	
end ctt;
	