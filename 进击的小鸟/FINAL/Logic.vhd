library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Logic is
	port (
		FPGAC_Ram_Data : in std_logic_vector(31 downto 0);
		FPGAE_RamAdd : out std_logic_vector(20 downto 0);
		FPGAC_RamRW : out std_logic_vector(1 downto 0);
		
		clk24M: in std_logic;
		i2c_sclk: out std_logic;
		i2c_sdat: inout std_logic;
		MCLK: out std_logic;
		BCLK: in std_logic;
		ADCLRC: in std_logic;
		ADCDAT: in std_logic;
		grade_display: out std_logic_vector (6 downto 0);
	
		seg2 : out std_logic_vector(6 downto 0);
		
		clk, reset: in std_logic;
		hs, vs: out STD_LOGIC;
		r, g, b: out STD_LOGIC_vector(2 downto 0)
	);
end Logic;

architecture struc of Logic is
	
	component vga_rom is
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
	end component;

	--sound
	component wm8731_controller is
		port(
			clk100M, clk24M, rst: in std_logic;
		
			i2c_sclk: out std_logic;
			i2c_sdat: inout std_logic;
		
			MCLK: out std_logic;
			BCLK: in std_logic;
			ADCLRC: in std_logic;
			ADCDAT: in std_logic;
	
			grade_display: out std_logic_vector (6 downto 0);
		
			up: out std_logic; --1???锟斤拷锟斤拷锟斤拷??锟斤拷??????
			shoot: out std_logic; --1???锟斤拷锟斤拷锟斤拷??锟斤拷???????
			clk_operate: in std_logic
		);
	end component;
	
	-- CLK
	component clockDivision is
	port (
		in_clk : in std_logic;
		clk_m25, clk_s24 : out std_logic;
		pulse_s24_min2, pulse_s24_s2, pulse_s24_s3, pulse_s191_s24 : out std_logic
	);
	end component;
	
	signal clk_m25, clk_s24 : std_logic;
	signal pulse_s24_min2, pulse_s24_s2, pulse_s24_s3, pulse_s191_s24 : std_logic;
	-- end CLK
	
	signal sound1, sound2 : std_logic;
	
	signal vga_x, vga_y : integer range 0 to 1023;
	signal pix_type : integer range 0 to 7; -- 0-empty,1-bird,2-bullet,3-cloud 
	signal pix_x, pix_y : integer range 0 to 1023;
	
	signal plane_pos : std_logic_vector(8 downto 0);
	constant max_plane_pos : integer := 400;
	constant min_plane_pos : integer := 10;
	constant plane_h : integer := 5;
	
	constant max_plane_speed : integer := 15;
	constant delta_plane_speed : integer := 3;
	constant plane_fall_speed : integer := 7;
	shared variable plane_up_speed : integer range 0 to 15 := 0;
	
	shared variable clouds_exist : std_logic_vector(7 downto 0) := "00000000";
	signal clouds_vertical : std_logic_vector(71 downto 0);
	signal clouds_horizontal : std_logic_vector(79 downto 0);
	constant cloud_gen_pos : integer := 540;
	
	constant bird_height : integer := 57;
	constant bird_width : integer := 76;
	constant bullet_height : integer := 36;
	constant bullet_width : integer := 31;
	constant cloud_height : integer := 70;
	constant cloud_width : integer := 72;
	
	shared variable bullets_exist : std_logic_vector(7 downto 0) := "00000000";
	signal bullets_vertical : std_logic_vector(71 downto 0);
	signal bullets_horizontal : std_logic_vector(79 downto 0);
	constant bullet_gen_pos : integer := plane_h + bird_width;
	
	constant bang_pos : integer := (bird_height - bullet_height) / 2;
	
	constant border_left : integer := 10;
	constant border_right : integer := 620;
	procedure Disappear( h : in std_logic_vector(9 downto 0); width_of_role : in integer; dis : out bit ) is
	begin
		if h < CONV_STD_LOGIC_VECTOR(border_left, 10) or h > CONV_STD_LOGIC_VECTOR(border_right - width_of_role, 10) then
			dis := '1';
		else
			dis := '0';
		end if;
	end Disappear;
	
	constant allowed_bias : integer := 10;
	procedure Hit (v1, v2 : in std_logic_vector(8 downto 0);
				h1, h2 : in std_logic_vector(9 downto 0);
				height1, width1, height2, width2 : in integer; cross : out bit ) is
	variable inf, sup : std_logic_vector(8 downto 0);
	begin
		if v2 + allowed_bias < height1 then
			inf := "000000000";
		else
			inf := v2 + allowed_bias - height1;
		end if;
		sup := v2 + height2 - allowed_bias;
		cross := '0';
		if h2 > h1 and h2 - h1 < CONV_STD_LOGIC_VECTOR(width1, 10) then
			if v1 < sup and v1 > inf then
				cross := '1';
			end if;
		end if;
	end Hit;
	
	constant prime : integer := 337;
	shared variable basenum : integer range 0 to 511 := 0; 
	constant random_threshold : integer := 102;

	procedure Random(gen : out bit) is
	begin
		basenum := (basenum + prime) MOD 128;
		if basenum < random_threshold then
			gen := '1';
		else
			gen := '0';
		end if;
	end Random;
	
	procedure distRandom(dist : out integer range 0 to 127) is
	begin
		basenum := (basenum + prime) MOD 128;
		dist := 128 - basenum;
	end distRandom;
	
	-- A new BOSS is waiting !!!
	
	shared variable killed_clouds_sum : integer := 0;
	type stats is (s4, s0, s1, s2, s3);
	signal state : stats := s4;
	shared variable dead_time : integer := 0;
	
	signal boss_exist : std_logic := '0';
	signal boss_pos : std_logic_vector(8 downto 0) := CONV_STD_LOGIC_VECTOR(200, 9);
	constant boss_h : integer := 540;
	constant boss_speed : integer := 5;
	
	constant boss_height : integer := 68;
	constant boss_width : integer := 70;
	constant boss_bullet_height : integer := 22;
	constant boss_bullet_width : integer := 28;

	constant boss_bang_pos : integer := (boss_height - boss_bullet_height) / 2;
	
	shared variable boss_bullets_exist : std_logic_vector(7 downto 0) := "00000000";
	signal boss_bullets_vertical : std_logic_vector(71 downto 0);
	signal boss_bullets_horizontal : std_logic_vector(79 downto 0);
	constant boss_bullet_gen_pos : integer := boss_h - boss_bullet_width;
	
	-- end the part of the new BOSS
	constant bomb_continue_time : integer := 12;
	shared variable bomb_time : integer := 0;
	shared variable bomb_exist : bit := '0';
	signal bomb_vertical : std_logic_vector(8 downto 0);
	signal bomb_horizontal : std_logic_vector(9 downto 0);
	
	constant bomb_height : integer := 43;
	constant bomb_width : integer := 44;
	
	constant gameover_height : integer := 328;
	constant gameover_width : integer := 591;
	
	constant start_height : integer := 220;
	constant start_width : integer := 494;
	
begin
	u0 : clockDivision port map(clk, 
		clk_m25, clk_s24, 
		pulse_s24_min2, pulse_s24_s2, pulse_s24_s3, pulse_s191_s24
	);
	u1: vga_rom port map(
		FPGAC_Ram_Data, FPGAE_RamAdd, FPGAC_RamRW,
		clk, reset,
		hs, vs,
		vga_x, vga_y,
		pix_type,
		pix_x, pix_y,
		r,g,b
	);
	
	u2: wm8731_controller port map(
		clk, clk24M, reset,
		i2c_sclk, i2c_sdat,
		
		MCLK, BCLK,
		ADCLRC, ADCDAT,
	
		grade_display,
		
		sound1, sound2, pulse_s191_s24
	);
	
	process(clk_s24, pulse_s24_min2, pulse_s24_s2, pulse_s24_s3)
		variable min_pos, max_pos : std_logic_vector(8 downto 0);
		variable dist : integer range 0 to 127;
		variable i, j : integer range 0 to 7;
		variable dis : bit;
	begin
		if clk_s24' event and clk_s24 = '0' then --move every 1/24s
			
			if bomb_exist = '1' then
				bomb_time := bomb_time + 1;
				if bomb_time > bomb_continue_time then
					bomb_exist := '0';
					bomb_time := 0;
				end if;
			end if;
			
			if state = s0 or state = s3 then
				if state = s0 and killed_clouds_sum > 2 then
					state <= s3;
					boss_exist <= '1';
					boss_bullets_exist := "00000000";
				elsif state = s3 and boss_exist = '0' then
					state <= s0;
					boss_bullets_exist := "00000000";
					killed_clouds_sum := 0;
				end if;
			
				if state = s3 and boss_exist = '1' then
				-- the moving of boss
					if plane_pos > boss_pos then
						if plane_pos - boss_pos < CONV_STD_LOGIC_VECTOR(boss_speed, 9) then
							boss_pos <= plane_pos;
						else
							boss_pos <= boss_pos + CONV_STD_LOGIC_VECTOR(boss_speed, 9);
						end if;
					elsif plane_pos < boss_pos then
						if boss_pos - plane_pos < CONV_STD_LOGIC_VECTOR(boss_speed, 9) then
							boss_pos <= plane_pos;
						else
							boss_pos <= boss_pos - CONV_STD_LOGIC_VECTOR(boss_speed, 9);
						end if;
					end if;
				-- bullets of boss
					if pulse_s24_s2 = '1' then
--						if ( plane_pos > boss_pos and plane_pos - boss_pos < CONV_STD_LOGIC_VECTOR(bullet_height, 9) )
--							or ( plane_pos < boss_pos and boss_pos - plane_pos < CONV_STD_LOGIC_VECTOR(bullet_height, 9) ) then
							dis := '1';
							for i in 0 to 7 loop
								if dis = '1' and boss_bullets_exist(i) = '0' then
									boss_bullets_exist(i) := '1';
									dis := '0';
									boss_bullets_horizontal(i * 10 + 9 downto i * 10) <= CONV_STD_LOGIC_VECTOR(boss_bullet_gen_pos, 10);
									boss_bullets_vertical(i * 9 + 8 downto i * 9) <= boss_pos + boss_bang_pos;
								end if;
							end loop;
--						end if;
					end if;
				-- end of boss
				end if;
			
				-- collision of the player and clouds
				for i in 0 to 7 loop
					if clouds_exist(i) = '1' then
						Hit( plane_pos, clouds_vertical(i * 9 + 8 downto i * 9),
							CONV_STD_LOGIC_VECTOR(plane_h, 10), clouds_horizontal(i * 10 + 9 downto i * 10),
							bird_height, bird_width, cloud_height, cloud_width, dis );
						if dis = '1' then
							state <= s1;
							dead_time := 0;
							boss_bullets_exist := "00000000";
						end if; -- dis = '1'
					end if;
				end loop; -- i
				
				for i in 0 to 7 loop
					if boss_bullets_exist(i) = '1' then
						Disappear( boss_bullets_horizontal(i * 10 + 9 downto i * 10), boss_bullet_width, dis );
						if dis = '1' then
							boss_bullets_exist(i) := '0';
						else
							boss_bullets_horizontal(i * 10 + 9 downto i * 10) <= boss_bullets_horizontal(i * 10 + 9 downto i * 10) - "01000";
						end if;
					end if;
				end loop;
				
				-- collision of the player and boss' bullets
				for i in 0 to 7 loop
					if boss_bullets_exist(i) = '1' then
						Hit( plane_pos, boss_bullets_vertical(i * 9 + 8 downto i * 9),
							CONV_STD_LOGIC_VECTOR(plane_h, 10), boss_bullets_horizontal(i * 10 + 9 downto i * 10),
							bird_height, bird_width, boss_bullet_height, boss_bullet_width, dis );
						if dis = '1' then
							boss_bullets_exist := "00000000";
							state <= s1;
							dead_time := 0;
							
							bomb_time := 0;
							bomb_exist := '1';
							bomb_vertical <= plane_pos;
							bomb_horizontal <= CONV_STD_LOGIC_VECTOR(plane_h, 10);
							
						end if; -- dis = '1'
					end if;
				end loop; -- i
				
				--the moving of the plane
				if sound1 = '1' then --up
					plane_up_speed := max_plane_speed;
				elsif plane_up_speed > 0 then
					plane_up_speed := plane_up_speed - delta_plane_speed;
				end if;
			
				min_pos := CONV_STD_LOGIC_VECTOR(min_plane_pos, 9) + CONV_STD_LOGIC_VECTOR(plane_up_speed, 9) - CONV_STD_LOGIC_VECTOR(plane_fall_speed, 9);
				max_pos := CONV_STD_LOGIC_VECTOR(max_plane_pos, 9) + CONV_STD_LOGIC_VECTOR(plane_up_speed, 9) - CONV_STD_LOGIC_VECTOR(plane_fall_speed, 9);
			
				if plane_pos < min_pos then
					plane_pos <= CONV_STD_LOGIC_VECTOR(min_plane_pos, 9);
				elsif plane_pos > max_pos then
					plane_pos <= CONV_STD_LOGIC_VECTOR(max_plane_pos, 9);
				else
					plane_pos <= plane_pos + CONV_STD_LOGIC_VECTOR(plane_fall_speed, 9) - CONV_STD_LOGIC_VECTOR(plane_up_speed, 9);
				end if;
				-- end of the moving of the plane
				
				-- moving
--				for i in 0 to 7 loop
--					if boss_bullets_exist(i) = '1' then
--						
--					end if;
--				end loop;
				
				for i in 0 to 7 loop
					if bullets_exist(i) = '1' then
						Hit( bullets_vertical(i * 9 + 8 downto i * 9), boss_pos,
							bullets_horizontal(i * 10 + 9 downto i * 10), CONV_STD_LOGIC_VECTOR(boss_h, 10),
							bullet_height, bullet_width, boss_height, boss_width, dis );
						if dis = '1' then
							bullets_exist(i) := '0';
							boss_exist <= '0';
						end if; -- dis = '1'
					end if; -- bullets = '1'
				end loop; -- i
				-- end of the collision of the player and clouds
			elsif state = s1 then --
				dead_time := dead_time + 1;
				if dead_time > 50 then
					state <= s2;
					dead_time := 0;
				end if;
				boss_bullets_exist := "00000000";
				for j in 0 to 7 loop
					boss_bullets_horizontal(j * 10 + 9 downto j * 10) <= CONV_STD_LOGIC_VECTOR(boss_bullet_gen_pos, 10);
				end loop;
			elsif state = s4 then
				if sound2 = '1' then
					state <= s0;
					boss_bullets_exist := "00000000";
				end if;
			else
				if sound1 = '1' or sound2 = '1' then
					state <= s0;
					boss_bullets_exist := "00000000";
				end if;
			end if;

		-- whether any bullet or cloud had moved out of the border
			for i in 0 to 7 loop
				if bullets_exist(i) = '1' then
					Disappear( bullets_horizontal(i * 10 + 9 downto i * 10), bullet_width, dis );
					if dis = '1' then
						bullets_exist(i) := '0';
					end if;
				end if;
			end loop;
			for i in 0 to 7 loop
				if clouds_exist(i) = '1' then
					Disappear( clouds_horizontal(i * 10 + 9 downto i * 10), cloud_width, dis );
					if dis = '1' then
						clouds_exist(i) := '0';
					end if;
				end if;
			end loop;
		-- end of the moving out of bullets and clouds
		
		-- collision of bullets and clouds
			for i in 0 to 7 loop
				if clouds_exist(i) = '1' then
					for j in 0 to 7 loop
						if clouds_exist(i) = '1' and bullets_exist(j) = '1' then
							Hit( bullets_vertical(j * 9 + 8 downto j * 9), clouds_vertical(i * 9 + 8 downto i * 9),
								bullets_horizontal(j * 10 + 9 downto j * 10), clouds_horizontal(i * 10 + 9 downto i * 10),
								bullet_height, bullet_width, cloud_height, cloud_width, dis );
							if dis = '1' then
								clouds_exist(i) := '0';
								bullets_exist(j) := '0';
								killed_clouds_sum := killed_clouds_sum + 1;
							end if; -- dis = '1'
						end if; -- clouds = '1' and bullets = '1'
					end loop; -- j
				end if; -- clouds = '1'
			end loop; -- i
		-- end of collision
		
		-- moving 
			for i in 0 to 7 loop
				if bullets_exist(i) = '1' then
					bullets_horizontal(i * 10 + 9 downto i * 10) <= bullets_horizontal(i * 10 + 9 downto i * 10) + "100";
				end if;
			end loop;
			
			for i in 0 to 7 loop
				if clouds_exist(i) = '1' then
					clouds_horizontal(i * 10 + 9 downto i * 10) <= clouds_horizontal(i * 10 + 9 downto i * 10) - "100";
				end if;
			end loop;
		-- end of moving
			
			if state = s0 or state = s3 then
				if pulse_s24_s3 = '1' and sound2 = '1' then
					dis := '1';
					for i in 0 to 7 loop
						if dis = '1' and bullets_exist(i) = '0' then
							bullets_exist(i) := '1';
							dis := '0';
							bullets_horizontal(i * 10 + 9 downto i * 10) <= CONV_STD_LOGIC_VECTOR(bullet_gen_pos, 10);
							bullets_vertical(i * 9 + 8 downto i * 9) <= plane_pos + bang_pos;
						end if;
					end loop;
				end if;
			
				if pulse_s24_min2 = '1' then
					Random(dis);
					for i in 0 to 7 loop
						if dis = '1' and clouds_exist(i) = '0' then
							distRandom(dist);
							clouds_exist(i) := '1';
							dis := '0';
							
							clouds_horizontal(i * 10 + 9 downto i * 10) <= CONV_STD_LOGIC_VECTOR(cloud_gen_pos, 10);
							
							if plane_pos + CONV_STD_LOGIC_VECTOR(dist, 9) < CONV_STD_LOGIC_VECTOR(64, 9) + CONV_STD_LOGIC_VECTOR(min_plane_pos, 9) then
								clouds_vertical(i * 9 + 8 downto i * 9) <= CONV_STD_LOGIC_VECTOR(min_plane_pos, 9);
							elsif plane_pos > CONV_STD_LOGIC_VECTOR(64, 9) + CONV_STD_LOGIC_VECTOR(max_plane_pos, 9) - CONV_STD_LOGIC_VECTOR(dist, 9) then
								clouds_vertical(i * 9 + 8 downto i * 9) <= CONV_STD_LOGIC_VECTOR(max_plane_pos, 9);
							else
								clouds_vertical(i * 9 + 8 downto i * 9) <= plane_pos + CONV_STD_LOGIC_VECTOR(dist, 9) - CONV_STD_LOGIC_VECTOR(64, 9);
							end if;
						
						end if;
					end loop;
				end if;
			end if;
			
		end if; --soundClk
		
	end process;
	
	process(clk_m25)
		variable dx, dy : integer range 0 to 1023;
		variable dpix_type : integer range 0 to 8;
	begin
		if clk_m25'event and clk_m25 = '0' then
			dpix_type := 0;
			
			if state = s4 then
				dpix_type := 8;
				if vga_x < 73 or vga_x > 565 or vga_y < 130 or vga_y > 350 then
					pix_x <= 0; pix_y <= 0;
				else
					pix_x <= vga_x - 73; pix_y <= vga_y - 130;
				end if;
			end if;
			
			if state = s2 then
				dpix_type := 6;
				if vga_x < 24 or vga_x > 613 or vga_y < 76 or vga_y > 402 then
					pix_x <= 0; pix_y <= 0;
				else
					pix_x <= vga_x - 24; pix_y <= vga_y - 76;
				end if;
			end if;
			
			-- check order 1 2 3
			if state = s0 or state = s3 then
				if dpix_type = 0 then
					dx := vga_x - plane_h;
					dy := vga_y - CONV_INTEGER(plane_pos);
					if 0 <= dx and dx < bird_width and 0 <= dy and dy < bird_height then
						dpix_type := 1;
						pix_x <= dx; pix_y <= dy;
					end if;
				end if;
			end if;
			
				if state = s3 then
					if dpix_type = 0 then
						dx := vga_x - boss_h;
						dy := vga_y - CONV_INTEGER(boss_pos);
						if 0 <= dx and dx < boss_width and 0 <= dy and dy < boss_height then
							dpix_type := 5;
							pix_x <= dx; pix_y <= dy;
						end if;
					end if;
				end if;
			
				if dpix_type = 0 then
					for i in 0 to 7 loop
						if dpix_type = 0 and boss_bullets_exist(i) = '1' then
							if vga_x > CONV_INTEGER( boss_bullets_horizontal(i * 10 + 9 downto i * 10) ) and vga_y > CONV_INTEGER( boss_bullets_vertical(i * 9 + 8 downto i * 9) ) then
								dx := vga_x - CONV_INTEGER( boss_bullets_horizontal(i * 10 + 9 downto i * 10) );
								dy := vga_y - CONV_INTEGER( boss_bullets_vertical(i * 9 + 8 downto i * 9) );
								if dx <= boss_bullet_width and dy <= boss_bullet_height then
									dpix_type := 3;
									pix_x <= dx; pix_y <= dy;
								end if;
							end if;
						end if;
					end loop;
				end if;
		
				if dpix_type = 0 then
					for i in 0 to 7 loop
						if dpix_type = 0 and bullets_exist(i) = '1' then
							dx := vga_x - CONV_INTEGER( bullets_horizontal(i * 10 + 9 downto i * 10) );
							dy := vga_y - CONV_INTEGER( bullets_vertical(i * 9 + 8 downto i * 9) );
							if 0 <= dx and dx <= bullet_width and 0 <= dy and dy <= bullet_height then
								dpix_type := 2;
								pix_x <= dx; pix_y <= dy;
							end if;
						end if;
					end loop;
				end if;
		
				if dpix_type = 0 then
					for i in 0 to 7 loop
						if dpix_type = 0 and clouds_exist(i) = '1' then
							dx := vga_x - CONV_INTEGER( clouds_horizontal(i * 10 + 9 downto i * 10) );
							dy := vga_y - CONV_INTEGER( clouds_vertical(i * 9 + 8 downto i * 9) );
							if 0 <= dx and dx <= cloud_width and 0 <= dy and dy <= cloud_height then
								dpix_type := 4;
								pix_x <= dx; pix_y <= dy;
							end if;
						end if;
					end loop;
				end if;
			
				if dpix_type = 0 and bomb_exist = '1' then
					if vga_x > CONV_INTEGER(bomb_horizontal) and vga_y > CONV_INTEGER(bomb_vertical) then
						dx := vga_x - CONV_INTEGER(bomb_horizontal);
						dy := vga_y - CONV_INTEGER(bomb_vertical);
						if dx <= bomb_width and dy <= bomb_height then
							dpix_type := 7;
							pix_x <= dx; pix_y <= dy;
						end if;
					end if;
				end if;
		
			if dpix_type = 0 then
				pix_type <= 0;
				pix_x <= 0; pix_y <= 0;
			else
				pix_type <= dpix_type - 1;
			end if;
			
		end if;
	end process;
	
	process(state)
	begin
		case state is 
			when s0 => seg2 <= "0111111";
			when s1 => seg2 <= "0000011";
			when s2 => seg2 <= "1101101";
			when s3 => seg2 <= "1001111";
			when others => seg2 <= "0000000";
		end case;
	end process;
	
end struc;