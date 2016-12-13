library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clockDivision is
	port (
		in_clk : in std_logic;
		clk_m25, clk_s24 : out std_logic;
		pulse_s24_min2, pulse_s24_s2, pulse_s24_s3, pulse_s191_s24 : out std_logic
	);
end clockDivision;

architecture struc of clockDivision is
	
	component singleClkDiv is
	port (
		in_clk, aim_clk : in std_logic;
		out_clk : out std_logic
	);
	end component;
	
	component Pulse is
		port (
			clk_h, clk_l : in std_logic;
			clk_out : out std_logic
		);
	end component;
	
	signal Mclk : std_logic_vector(5 downto 0) := "000000";
	signal Kclk : std_logic_vector(9 downto 0) := "0000000000";
	signal Sclk : std_logic_vector(10 downto 0) := "00000000000";
	signal Clk  : std_logic_vector(2 downto 0) := "000";
	-- 50M, 25M, 12.5M, 6.25M, 3.13M, 1.56M,
	-- 0.78M, 0.39M, 0.19M, 98k, 49k, 24k, 12k, 6.1k, 3.1k, 1.5k,
	-- 763, 381, 191, 95, 48, 24, 12, 6, 3, 2, 1
	-- 2 4 8
begin
	clk_m25 <= Mclk(4);
	clk_s24 <= Sclk(5);
	
	t0 : Pulse port map(Sclk(5), Sclk(2), pulse_s24_s3);
	t1 : Pulse port map(Sclk(5), Clk(2), pulse_s24_min2);
	t2 : Pulse port map(Sclk(9), Sclk(0), pulse_s191_s24);
	t3 : Pulse port map(Sclk(5), Sclk(0), pulse_s24_s2);
	
	u1 : singleClkDiv port map(in_clk, Mclk(5), Mclk(5));
	u2 : singleClkDiv port map(Mclk(5), Mclk(4), Mclk(4));
	u3 : singleClkDiv port map(Mclk(4), Mclk(3), Mclk(3));
	u4 : singleClkDiv port map(Mclk(3), Mclk(2), Mclk(2));
	u5 : singleClkDiv port map(Mclk(2), Mclk(1), Mclk(1));
	u6 : singleClkDiv port map(Mclk(1), Mclk(0), Mclk(0));
	u7 : singleClkDiv port map(Mclk(0), Kclk(9), Kclk(9));
	u8 : singleClkDiv port map(Kclk(9), Kclk(8), Kclk(8));
	u9 : singleClkDiv port map(Kclk(8), Kclk(7), Kclk(7));
	u10 : singleClkDiv port map(Kclk(7), Kclk(6), Kclk(6));
	u11 : singleClkDiv port map(Kclk(6), Kclk(5), Kclk(5));
	u12 : singleClkDiv port map(Kclk(5), Kclk(4), Kclk(4));
	u13 : singleClkDiv port map(Kclk(4), Kclk(3), Kclk(3));
	u14 : singleClkDiv port map(Kclk(3), Kclk(2), Kclk(2));
	u15 : singleClkDiv port map(Kclk(2), Kclk(1), Kclk(1));
	u16 : singleClkDiv port map(Kclk(1), Kclk(0), Kclk(0));
	u17 : singleClkDiv port map(Kclk(0), Sclk(10), Sclk(10));
	u18 : singleClkDiv port map(Sclk(10), Sclk(9), Sclk(9));
	u19 : singleClkDiv port map(Sclk(9), Sclk(8), Sclk(8));
	u20 : singleClkDiv port map(Sclk(8), Sclk(7), Sclk(7));
	u21 : singleClkDiv port map(Sclk(7), Sclk(6), Sclk(6));
	u22 : singleClkDiv port map(Sclk(6), Sclk(5), Sclk(5));
	u23 : singleClkDiv port map(Sclk(5), Sclk(4), Sclk(4));
	u24 : singleClkDiv port map(Sclk(4), Sclk(3), Sclk(3));
	u25 : singleClkDiv port map(Sclk(3), Sclk(2), Sclk(2));
	u26 : singleClkDiv port map(Sclk(2), Sclk(1), Sclk(1));
	u27 : singleClkDiv port map(Sclk(1), Sclk(0), Sclk(0));
	
	min0 : singleClkDiv port map(Sclk(0), Clk(2), Clk(2));
	min1 : singleClkDiv port map(Clk(2), Clk(1), Clk(1));
	min2 : singleClkDiv port map(Clk(1), Clk(0), Clk(0));
end struc; 
 	
 	 