---------------------------------------------------------------------------------------
-- Company: 	BME
-- Engineer: 	Cseh Peter (DM5HMB), Limbay Bence (E2JT1E)
-- 
-- Create Date: 2017.10.29
-- Design Name: lcd
-- Module Name: spi
---------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

entity spi is
port
(
	clk : in std_logic;
	rst : in std_logic;

	--SPI signals
	sdcard_csn : out std_logic;
	flash_csn : out std_logic;
	lcd_csn : out std_logic;
	sck : out std_logic;
	mosi : out std_logic;
	miso : out std_logic;

	--Inner signals
	empty : in std_logic;
	rd : out std_logic;
	din : in std_logic_vector(8 downto 0);
	
	--Stat signal
	sh : out std_logic
);
end spi;

architecture rtl of spi is



signal fsm_cntr : integer range 0 to 7 := 0;

type spi_fsm_type is (IDLE, READ1, READ2, SHIFT);
signal fsm : spi_fsm_type := IDLE;

signal cmd_reg : std_logic_vector(7 downto 0) := (others => '0');
signal mode_reg : std_logic := '0';

signal sck_wire : std_logic := '0';

signal cont_send : std_logic := '0';

signal shift_end : std_logic := '0';

signal send_cntr : std_logic_vector(4 downto 0) := (others => '0'); --0 to 20

signal rise : std_logic := '0';
signal fall : std_logic := '0';

begin

---------------------------------------------------------------------------------------
--	Drive unused spi channel with HIGH
---------------------------------------------------------------------------------------
sdcard_csn <= '1';
flash_csn <= '1';

---------------------------------------------------------------------------------------
--	Clock divider for sck, and send signals
---------------------------------------------------------------------------------------
proc_clk_div : process(clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			send_cntr <= (others => '0');
		else
			case fsm is
				when SHIFT =>
                if(cont_send = '1' and to_integer(unsigned(send_cntr)) = 18) then
                    send_cntr <= "00010";
                else
                    if(to_integer(unsigned(send_cntr)) = 20) then
                        send_cntr <= (others => '0');
                    else
                        send_cntr <= std_logic_vector(unsigned(send_cntr) + 1);
                    end if;
                end if;
				when others => send_cntr <= (others => '0');
			end case;
		end if;
	end if;
end process proc_clk_div;

rise <= '1' when send_cntr(0) = '0' else '0';
fall <= '1' when send_cntr(0) = '1' else '0';

---------------------------------------------------------------------------------------
--	Finite State Machine
---------------------------------------------------------------------------------------
sck <= sck_wire;

sh <= '1' when (fsm = SHIFT) else '0';

proc_fsm : process(clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			fsm <= IDLE;
		else
			case fsm is

				--IDLE STATE
				when IDLE =>

					if(empty = '0') then --IDLE -> SHIFT
						rd <= '1';
						fsm <= READ1;
					else
						rd <= '0';
					end if;

					lcd_csn <= '1';
					mosi <= '0';
					miso <= '0';
					sck_wire <= '0';
					
				when READ1 =>
				
					lcd_csn <= '1';
					mosi <= '0';
					miso <= '0';
					sck_wire <= '0';
					
					rd <= '0';

					fsm <= READ2;
					
				when READ2 =>
				
					lcd_csn <= '1';
					mosi <= '0';
					miso <= '0';
					sck_wire <= '0';
					
					rd <= '0';
					cmd_reg <= din(7 downto 0);
					mode_reg <= din(8);
					
					fsm_cntr <= 7;
					fsm <= SHIFT;

				--SHIFT STATE
				when SHIFT =>

					if(to_integer(unsigned(send_cntr)) < 1) then
						lcd_csn <= '0';
						mosi <= '0';
						miso <= '0';
						sck_wire <= '0';
					else
					   
                       --SCK vezérlés
                        if(to_integer(unsigned(send_cntr)) < 18) then
                            if(rise = '1') then
                              sck_wire <= '1';
                            end if;
                            if(fall = '1') then
                              sck_wire <= '0';
                            end if;
						end if;
						
						--MOSI & MISO
						if(fall = '1' and to_integer(unsigned(send_cntr)) < 19) then
						  mosi <= cmd_reg(7);
						  cmd_reg <= cmd_reg(6 downto 0) & '0';
						  
                            if(to_integer(unsigned(send_cntr)) = 15) then
                                miso <= mode_reg;
                            else
                                miso <= '0';
                            end if;
						end if;
						
						if(to_integer(unsigned(send_cntr)) = 16 and empty = '0') then
                            cont_send <= '1';
                            rd <= '1';
						end if;
						if(to_integer(unsigned(send_cntr)) = 17 and cont_send = '1') then
                            cont_send <= '1';
                            rd <= '0';
                        end if;
                        if(to_integer(unsigned(send_cntr)) = 18 and cont_send = '1') then
                            cont_send <= '0';
                            rd <= '0';
                            cmd_reg <= din(7 downto 0);
                            mode_reg <= din(8);
                            
                            
                        end if;
                        
                        if(to_integer(unsigned(send_cntr)) = 19) then
                            fsm <= IDLE;
                        end if;
						
					end if;

				when others => fsm <= IDLE;
			end case;
		end if;
	end if;
end process proc_fsm;

end rtl;