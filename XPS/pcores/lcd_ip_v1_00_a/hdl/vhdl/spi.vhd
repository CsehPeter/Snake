---------------------------------------------------------------------------------------
-- Company: 	BME
-- Engineer: 	Cseh PÃ©ter (DM5HMB), Limbay Bence (E2JT1E)
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
	valid : in std_logic;
	ready : out std_logic;
	cmd : in std_logic_vector(7 downto 0);
	mode : in std_logic
);
end spi;

architecture rtl of spi is

signal send_cntr : integer range 0 to 1 := 0;

signal fsm_cntr : integer range 0 to 7 := 0;

type spi_fsm_type is (IDLE, SHIFT);
signal fsm : spi_fsm_type := IDLE;

signal cmd_reg : std_logic_vector(7 downto 0) := (others => '0');
signal mode_reg : std_logic := '0';

signal sck_wire : std_logic := '0';

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
			send_cntr <= 0;
		else
			case fsm is
				when IDLE => send_cntr <= 0;
				when SHIFT =>
					if(send_cntr = 0) then
						send_cntr <= 1;
					else
						send_cntr <= 0;
					end if;
				when others => send_cntr <= 0;
			end case;
		end if;
	end if;
end process proc_clk_div;

---------------------------------------------------------------------------------------
--	Finite State Machine
---------------------------------------------------------------------------------------
proc_fsm : process(clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			fsm <= IDLE;
		else
			case fsm is

				--IDLE STATE
				when IDLE =>

					if(valid = '1') then --IDLE -> SHIFT
						cmd_reg <= cmd;
						mode_reg <= mode;
						lcd_csn <= '0';
						ready <= '0';
						fsm_cntr <= 7;
						fsm <= SHIFT;
					else
						ready <= '1';
						lcd_csn <= '1';
					end if;

					mosi <= '0';
					miso <= '0';
					sck_wire <= '0';

				--SHIFT STATE
				when SHIFT =>
					if(send_cntr = 1 and fsm_cntr = 0) then --SHIFT -> IDLE
						lcd_csn <= '1';
						sck_wire <= '0';
						miso <= mode_reg;
						ready <= '1';
						fsm <= IDLE;
					else
						lcd_csn <= '0';
						sck_wire <= not(sck_wire);
						ready <= '0';
					end if;

					if(send_cntr = 1) then
						mosi <= cmd_reg(7);
						cmd_reg <= cmd_reg(6 downto 0) & '0';

						fsm_cntr <= fsm_cntr - 1;
					end if;

				when others => fsm <= IDLE;
			end case;
		end if;
	end if;
end process proc_fsm;

sck <= sck_wire;

end rtl;