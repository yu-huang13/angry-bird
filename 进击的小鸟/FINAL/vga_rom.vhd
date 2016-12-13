library ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;

entity vga_rom is
port(
	FPGAC_Ram_Data : in std_logic_vector(31 downto 0);
	FPGAE_RamAdd : out std_logic_vector(20 downto 0);
	FPGAC_RamRW : out std_logic_vector(1 downto 0);

	clk_0,reset: in std_logic;
	hs,vs: out STD_LOGIC;
	x,y:out integer range 0 to 1023;
	cate: in integer range 0 to 7;
	posx, posy: in integer range 0 to 1023;
	r,g,b: out STD_LOGIC_vector(2 downto 0)
);
end vga_rom;

architecture vga_rom of vga_rom is

component vga640480 is
	 port(
			--address		:		  out	STD_LOGIC_VECTOR(13 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			clk25       :		  out std_logic; 
			q		    :		  in STD_LOGIC_vector(8 downto 0);
			clk_0       :         in  STD_LOGIC; --100M时锟斤拷锟斤拷锟斤拷
			hs,vs       :         out STD_LOGIC; --锟斤拷同锟斤拷锟斤拷锟斤拷同锟斤拷锟脚猴拷
			x,y 		: 		  out integer;
			r,g,b       :         out STD_LOGIC_vector(2 downto 0)
	  );
end component;

component digital_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END component;


signal clk25: std_logic;
signal q_tmp: std_logic_vector(8 downto 0);

constant bird_height : integer := 57;
constant bird_width : integer := 76;
constant bullet_height : integer := 36;
constant bullet_width : integer := 31;
constant boss_bullet_height : integer := 22;
constant boss_bullet_width : integer := 28;
constant cloud_height : integer := 70;
constant cloud_width : integer := 72;


constant boss_height : integer := 68;
constant boss_width : integer := 70;



constant gameover_height : integer := 328;
constant gameover_width : integer := 591; 
constant bang_height : integer := 43;
constant bang_width : integer := 44;
constant start_height : integer := 220;
constant start_width : integer := 494;

constant picWidth : integer := 1086;

signal cnt : integer := 0;

constant addressWidth : integer := 19; -- 21;
signal address_tmp: std_logic_vector(18 downto 0);

begin

--address_tmp <= conv_std_logic_vector((y-10) * 140 + x, 14);
--process(clk25)
--begin
--	if (clk25'event and clk25 = '1') then
--		cnt <= cnt + 1;
--		if (cnt = 2500000) then 
--			cnt <= 0;
--			birdPos <= birdPos + 1;
--			if (birdPos = 480) then 
--				birdPos <= 0;
--			end if;
--		end if;
--	end if;
--end process;

--process(clk25, x, y)
--begin
--	if (clk25'event and clk25 = '1') then
--		if (y >= birdPos and y < birdPos + birdHeight and x < birdWidth) then 
--				address_tmp <= conv_std_logic_vector((y - birdPos) * picWidth + x, 14);
--		elsif (y >= bulletPosY and y < bulletPosY + bulletHeight and x >= bulletPosX and x < bulletPosX + bulletWidth) then 
--				address_tmp <= conv_std_logic_vector((y - bulletPosY) * picWidth + (x - bulletPosX + birdWidth), 14);
--		else
--				address_tmp <= (others => '0');
--		end if;
--	end if;
--end process;

process(clk25, posx, posy)
begin
	if (clk25'event and clk25 = '1') then
		if (cate = 0) then -- bird 
			address_tmp <= conv_std_logic_vector(posy * picWidth + posx, addressWidth);
		elsif (cate = 1) then -- shit
			address_tmp <= conv_std_logic_vector(posy * picWidth + (posx + 78), addressWidth);
		elsif (cate = 2) then -- egg
			address_tmp <= conv_std_logic_vector((posy + 36) * picWidth + (posx + 77), addressWidth);
		elsif (cate = 3) then -- cloud
			address_tmp <= conv_std_logic_vector(posy * picWidth + (posx + 112), addressWidth);
		elsif (cate = 4) then -- boss
			address_tmp <= conv_std_logic_vector(posy * picWidth + (posx + 185), addressWidth);
		elsif (cate = 5) then -- gameover
			address_tmp <= conv_std_logic_vector(posy * picWidth + (posx + 495), addressWidth);
		elsif (cate = 6) then -- bang
			address_tmp <= conv_std_logic_vector((posy + 58) * picWidth + posx, addressWidth);
		elsif (cate = 7) then -- start
			address_tmp <= conv_std_logic_vector((posy + 107) * picWidth + posx, addressWidth);
		else
			address_tmp <= (others => '0');
		end if;
	end if;
end process;



u1: vga640480 port map(
						--address=>address_tmp, 
						reset=>reset, 
						clk25=>clk25, 
						q=>q_tmp, 
						x => x,
						y => y,
						clk_0=>clk_0, 
						hs=>hs, vs=>vs, 
						r=>r, g=>g, b=>b
					);

----------------------SRAM-----------------------	
FPGAC_RamRW <= "11";

process(clk25)
begin
	if (clk25'event and clk25 = '1') then
		FPGAE_RamAdd <= "00" & address_tmp;
		q_tmp <= FPGAC_Ram_Data(8 downto 0);
	end if;
end process;

-----------------------ROM--------------------------
--u2: digital_rom port map(	
--						address=>address_tmp, 
--						clock=>clk25, 
--						q=>q_tmp
--					);


end vga_rom;

