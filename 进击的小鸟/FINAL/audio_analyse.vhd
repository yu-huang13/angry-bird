library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity audio_analyse is
	generic (width : integer := 24); 
	port(
		data_in: in std_logic_vector (width - 1 downto 0);
		ready: in std_logic;
		readylr: in std_logic;
		grade_out: out std_logic_vector (3 downto 0);
		
		up: out std_logic;
		shoot: out std_logic;
		clk_operate: in std_logic
	);
end;

architecture aa of audio_analyse is

component complement_to_true is
	generic (width : integer := 24); 
	port(
		complement_code: in std_logic_vector (width - 1 downto 0);
		true_code: out std_logic_vector (width - 1 downto 0)
	);
end component;


type state is (no_voice, has_voice);
signal cur_state: state:= no_voice;

signal counter_get_max: integer range 0 to 4600:= 0;
signal data_com: std_logic_vector (width - 1 downto 0);
signal data_true: std_logic_vector (width - 1 downto 0);
signal max_data: std_logic_vector (width - 2 downto 0) := "00000000000000000000000";
signal max_data_out : std_logic_vector (width - 2 downto 0);
signal grade: std_logic_vector (3 downto 0);

signal up_temp, shoot_temp: std_logic;

shared variable times : integer range 0 to 7 := 0;

begin
	process (ready)
	begin
		if (ready'event and ready = '1') and (readylr = '0') then
			data_com <= data_in;
			if (data_true(width - 2 downto 0) > max_data) then 
				max_data <= data_true(width - 2 downto 0);
			end if;
			counter_get_max <= counter_get_max + 1;
			if (counter_get_max > 459) then 
				max_data_out <= max_data;
				max_data <= "00000000000000000000000";
				counter_get_max <= 0;
			end if;
		end if;
	end process;
	
	process (max_data_out)
	begin 
		if (max_data_out < "1" & "0000000000000000000") then 
			grade <= "0000";
		elsif(max_data_out < "10" & "0000000000000000000") then
			grade <= "0001";
		elsif(max_data_out < "11" & "0000000000000000000") then
			grade <= "0010";
		elsif(max_data_out < "100" & "0000000000000000000") then
			grade <= "0011";
		elsif(max_data_out < "101" & "0000000000000000000") then
			grade <= "0100";
		elsif(max_data_out < "110" & "0000000000000000000") then
			grade <= "0101";
		elsif(max_data_out < "111" & "0000000000000000000") then
			grade <= "0110";
		elsif(max_data_out < "1000" & "0000000000000000000") then
			grade <= "0111";
		elsif(max_data_out < "1001" & "0000000000000000000") then
			grade <= "1000";
		elsif(max_data_out < "1010" & "0000000000000000000") then
			grade <= "1001";
		elsif(max_data_out < "1011" & "0000000000000000000") then
			grade <= "1010";
		elsif(max_data_out < "1100" & "0000000000000000000") then
			grade <= "1011";
		elsif(max_data_out < "1101" & "0000000000000000000") then
			grade <= "1100";
		elsif(max_data_out < "1110" & "0000000000000000000") then
			grade <= "1101";
		elsif(max_data_out < "1111" & "0000000000000000000") then
			grade <= "1110";
		else 
			grade <= "1111";
		end if;
	end process;
	
	grade_out <= grade;
	
	process (grade)
	begin
		times := times + 1;
		if (grade > "0110") then 
			shoot_temp <= '1';
		elsif grade > "0001" then 
			up_temp <= '1';
		end if;
		
		if (times > 2) then --涓婂崌娌
			times := 0;
			up <= up_temp;
			shoot <= shoot_temp;
			up_temp <= '0';
			shoot_temp <= '0';
		else
			
		end if;
	end process;
	
	c1: complement_to_true port map (data_com, data_true);
end aa;



