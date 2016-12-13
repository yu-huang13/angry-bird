library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity decoder is
port(
	input: in std_logic_vector (3 downto 0);
	output: out std_logic_vector (6 downto 0)
);
end;

architecture de of decoder is
begin
	process(input)
	begin
		case input is
			when "0000" => output <= "0111111";--0
			when "0001" => output <= "0000011";--1
			when "0010" => output <= "1101101";--2
			when "0011" => output <= "1001111";--3
			when "0100" => output <= "1010011";--4
			when "0101" => output <= "1011110";--5
			when "0110" => output <= "1111110";--6
			when "0111" => output <= "0000111";--7
			when "1000" => output <= "1111111";--8
			when "1001" => output <= "1011111";--9
			when "1010" => output <= "1110111";--10 A
			when "1011" => output <= "1111010";--11 B
			when "1100" => output <= "0111100";--12 C
			when "1101" => output <= "1101011";--13 D
			when "1110" => output <= "1111100";--14 E
			when "1111" => output <= "1110100";--15 F
		end case;
	end process;
	
end de;