library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity wm8731_controller is
	generic (width : integer := 24);
	port(
		clk100M, clk24M, rst: in std_logic;
		
		i2c_sclk: out std_logic;
		i2c_sdat: inout std_logic;
		
		MCLK: out std_logic;
		BCLK: in std_logic;
		ADCLRC: in std_logic;
		ADCDAT: in std_logic;
	
		grade_display: out std_logic_vector (6 downto 0);
		
		up: out std_logic; --1代表上升
		shoot: out std_logic; --1代表发炮
		clk_operate: in std_logic
	);
end;

architecture wc of wm8731_controller is

component i2c_controller is
	port(
		clk100M: in std_logic;
		clk20K, rst: in std_logic;
		
		i2c_sclk: out std_logic;
		i2c_sdat: inout std_logic;
		
		tr_run: in std_logic;
		tr_end: out std_logic
	);
end component;

component i2s_to_parallel is
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
end component;

component audio_analyse is
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
end component;

component decoder is
port(
	input: in std_logic_vector (3 downto 0);
	output: out std_logic_vector (6 downto 0)
);
end component;

component frequency100M_to_20K is
	port(
		clk100M: in std_logic;
		clk20K: out std_logic
	);
end component;

component frequency24M_to_12M is
	port(
		clk24M: in std_logic;
		clk12M: out std_logic
	);
end component;

type state is (start, set, transmit_audio);
signal cur_state, next_state: state:= start;

signal start_transmit_audio: std_logic := '0';
signal start_set: std_logic := '0';
signal set_end: std_logic := '0';

signal data: std_logic_vector (width - 1 downto 0);
signal ready, readylr: std_logic;

signal grade : std_logic_vector(3 downto 0);

signal clk20K: std_logic;
signal clk12M: std_logic;

begin
	
	process (clk100M, rst)
	begin
		if (rst = '0') then 
			cur_state <= start;
		elsif clk100M'event and clk100M = '1' then
			cur_state <= next_state;
		end if;
	end process;
	
	process (cur_state)
	begin
		case cur_state is
			when start => 
				next_state <= set;
				start_transmit_audio <= '0';
				start_set <= '0';
					
			when set => 
				start_transmit_audio <= '0';
				start_set <= '1';
				if (set_end = '1') then 
					next_state <= transmit_audio;
				else
					next_state <= set;
				end if;
					
			when transmit_audio => 
				start_transmit_audio <= '1';
				next_state <= transmit_audio;
					
		end case;
	end process;
	
	MCLK <= clk12M;
	
	c1: frequency100M_to_20K port map (clk100M, clk20K);
	c2: frequency24M_to_12M port map (clk24M, clk12M);
	
	u1: i2c_controller port map(clk100M, clk20K, rst, i2c_sclk, i2c_sdat, start_set, set_end);
	u2: i2s_to_parallel port map (BCLK, ADCLRC, ADCDAT, rst, start_transmit_audio, data, ready, readylr);
	u3: audio_analyse port map (data, ready, readylr, grade, up, shoot, clk_operate);
	
	
	d4: decoder port map (grade, grade_display);
	
end wc;




