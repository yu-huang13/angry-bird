library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity i2c_controller is
	port(
		clk100M: in std_logic;
		clk20K, rst: in std_logic;
		
		i2c_sclk: out std_logic;
		i2c_sdat: inout std_logic;
		
		tr_run: in std_logic;
		tr_end: out std_logic
	);
end;

architecture ic of i2c_controller is

signal step: std_logic_vector(7 downto 0);
signal ack1, ack2, ack3: std_logic;
signal ack: std_logic;

signal index: integer range 0 to 15;
signal data: std_logic_vector (23 downto 0);
signal set_data: std_logic_vector(15 downto 0);

begin
	
	process (clk20K)
	begin
		if (tr_run = '1') then 
			if (clk20K'event and clk20K = '1') then 
				case step is
					when X"00" => i2c_sclk <= '1'; i2c_sdat <= '1'; tr_end <= '0'; step <= X"01"; 
					when X"01" => i2c_sclk <= '1'; i2c_sdat <= '0'; step <= 	X"02"; 
					
					when X"02" => i2c_sclk <= '0'; i2c_sdat <= data(23); step <= X"03"; 
					when X"03" => i2c_sclk <= '1'; step <= X"04"; 								
					when X"04" => i2c_sclk <= '0'; i2c_sdat <= data(22); step <= X"05"; 
					when X"05" => i2c_sclk <= '1'; step <= X"06"; 								
					when X"06" => i2c_sclk <= '0'; i2c_sdat <= data(21); step <= X"07"; 
					when X"07" => i2c_sclk <= '1'; step <= X"08"; 								
					when X"08" => i2c_sclk <= '0'; i2c_sdat <= data(20); step <= X"09"; 
					when X"09" => i2c_sclk <= '1'; step <= X"0A"; 								
					when X"0A" => i2c_sclk <= '0'; i2c_sdat <= data(19); step <= X"0B"; 
					when X"0B" => i2c_sclk <= '1'; step <= X"0C"; 								
					when X"0C" => i2c_sclk <= '0'; i2c_sdat <= data(18); step <= X"0D";
					when X"0D" => i2c_sclk <= '1'; step <= X"0E"; 								
					when X"0E" => i2c_sclk <= '0'; i2c_sdat <= data(17); step <= X"0F";
					when X"0F" => i2c_sclk <= '1'; step <= X"10"; 								
					when X"10" => i2c_sclk <= '0'; i2c_sdat <= data(16); step <= X"11"; 
					when X"11" => i2c_sclk <= '1'; step <= X"12";								
					when X"12" => i2c_sclk <= '0'; i2c_sdat <= 'Z'; step <= X"13";       
					when X"13" => i2c_sclk <= '1'; ack1 <= i2c_sdat; step <= X"14";
									  
					
					when X"14" => i2c_sclk <= '0'; i2c_sdat <= data(15); step <= X"15"; 
					when X"15" => i2c_sclk <= '1'; step <= X"16";
					when X"16" => i2c_sclk <= '0'; i2c_sdat <= data(14); step <= X"17";
					when X"17" => i2c_sclk <= '1'; step <= X"18";
					when X"18" => i2c_sclk <= '0'; i2c_sdat <= data(13); step <= X"19";
					when X"19" => i2c_sclk <= '1'; step <= X"1A";
					when X"1A" => i2c_sclk <= '0'; i2c_sdat <= data(12); step <= X"1B";
					when X"1B" => i2c_sclk <= '1'; step <= X"1C";
					when X"1C" => i2c_sclk <= '0'; i2c_sdat <= data(11); step <= X"1D";
					when X"1D" => i2c_sclk <= '1'; step <= X"1E";
					when X"1E" => i2c_sclk <= '0'; i2c_sdat <= data(10); step <= X"1F";
					when X"1F" => i2c_sclk <= '1'; step <= X"20";
					when X"20" => i2c_sclk <= '0'; i2c_sdat <= data(9); step <= X"21";
					when X"21" => i2c_sclk <= '1'; step <= X"22";
					when X"22" => i2c_sclk <= '0'; i2c_sdat <= data(8); step <= X"23";
					when X"23" => i2c_sclk <= '1'; step <= X"24";
					when X"24" => i2c_sclk <= '0'; i2c_sdat <= 'Z'; step <= X"25";
					when X"25" => i2c_sclk <= '1'; ack2 <= i2c_sdat; step <= X"26";
									  
					
					when X"26" => i2c_sclk <= '0'; i2c_sdat <= data(7); step <= X"27"; 
					when X"27" => i2c_sclk <= '1'; step <= X"28";
					when X"28" => i2c_sclk <= '0'; i2c_sdat <= data(6); step <= X"29";
					when X"29" => i2c_sclk <= '1'; step <= X"2A";
					when X"2A" => i2c_sclk <= '0'; i2c_sdat <= data(5); step <= X"2B";
					when X"2B" => i2c_sclk <= '1'; step <= X"2C";
					when X"2C" => i2c_sclk <= '0'; i2c_sdat <= data(4); step <= X"2D";
					when X"2D" => i2c_sclk <= '1'; step <= X"2E";
					when X"2E" => i2c_sclk <= '0'; i2c_sdat <= data(3); step <= X"2F";
					when X"2F" => i2c_sclk <= '1'; step <= X"30";
					when X"30" => i2c_sclk <= '0'; i2c_sdat <= data(2); step <= X"31";
					when X"31" => i2c_sclk <= '1'; step <= X"32";
					when X"32" => i2c_sclk <= '0'; i2c_sdat <= data(1); step <= X"33";
					when X"33" => i2c_sclk <= '1'; step <= X"34";
					when X"34" => i2c_sclk <= '0'; i2c_sdat <= data(0); step <= X"35";
					when X"35" => i2c_sclk <= '1'; step <= X"36";
					when X"36" => i2c_sclk <= '0'; i2c_sdat <= 'Z'; step <= X"37";
					when X"37" => i2c_sclk <= '1'; ack3 <= i2c_sdat; step <= X"38";
									  
					
					when X"38" => i2c_sclk <= '0'; step <= X"39"; 							  
					when X"39" => i2c_sdat <= '0'; step <= X"3A";
					when X"3A" => i2c_sclk <= '1'; i2c_sdat <= '0'; step <= X"3B";
					when X"3B" => i2c_sclk <= '1'; i2c_sdat <= '1';  
										if (ack1 = '0') and (ack2 = '0') and (ack3 = '0') then 
											index <= index + 1;
										end if;
										if (index < 9) then 
											step <= X"00";
										else 
											step <= X"3C";
										end if;
									
					when X"3C" => i2c_sclk <= '1'; i2c_sdat <= '1'; tr_end <= '1'; step <= X"3C";
					
					when others => i2c_sclk <= '1'; i2c_sdat <= '1';  --should never happaned
				end case;
			end if;
		else
			step <= X"00";
			tr_end <= '0';
		end if;
		
  end process;
  
	data <= X"34" & set_data;
	
	--myself
	with index select 
		set_data <= X"001F" when 0,
						X"021F" when 1,
						X"0479" when 2,
						X"0679" when 3,
						X"0810" when 4,
						X"0A06" when 5,
						X"0C00" when 6,
						X"0E4A" when 7,
						X"1000" when 8,
						X"1201" when 9,
						X"ABCD" when others; --should never happened
						
				
end ic;


	