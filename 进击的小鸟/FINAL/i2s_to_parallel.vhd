library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity i2s_to_parallel is
generic (width : integer := 24);
port(
	BCLK: in std_logic;
	ADCLRC: in std_logic;
	ADCDAT: in std_logic;
	
	rst: in std_logic;
	start: in std_logic;
	data_out: out std_logic_vector (width - 1 downto 0); 
	ready: out std_logic;--ready = '1'代表准备好数据
	readylr: out std_logic -- 0为左, 1为r
);
end;

architecture itp of i2s_to_parallel is
signal current_lr: std_logic;
signal reg: std_logic_vector(width - 1 downto 0);
signal counter: integer range 0 to width - 1;
begin
	
	process(rst, BCLK)
	begin
		if(rst = '0' or start = '0') then 
			current_lr <= ADCLRC;
			reg <= (others => '0');
			ready <= '0';
		elsif (BCLK'event and BCLK = '1') then
			if (current_lr /= ADCLRC) then
				data_out <= reg;
				readylr <= current_lr;
				current_lr <= ADCLRC;
				ready <= '1';
			else
				ready <= '0';
				reg <= reg(width - 2 downto 0) & ADCDAT;
			end if;
		end if;
	end process;
end itp;



