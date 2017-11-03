---------------------------------------------------------------------------------------
-- Company: 	BME
-- Engineer: 	Cseh PÃ©ter (DM5HMB), Limbay Bence (E2JT1E)
-- 
-- Create Date: 2017.10.29
-- Design Name: lcd
-- Module Name: bus_if
---------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

entity bus_if is
generic
(
	C_NUM_REG : integer := 2;
	C_SLV_DWIDTH : integer := 32
);
port
(
	--Bus signals
	Bus2IP_Clk : in std_logic;
	Bus2IP_Resetn : in std_logic;

	Bus2IP_Data : in std_logic_vector((C_SLV_DWIDTH - 1) downto 0);
	Bus2IP_BE : in std_logic_vector((C_SLV_DWIDTH / 8 - 1) downto 0);
	Bus2IP_RdCE : in std_logic_vector((C_NUM_REG - 1) downto 0);
	Bus2IP_WrCE : in std_logic_vector((C_NUM_REG - 1) downto 0);

	IP2Bus_Data : out std_logic_vector((C_SLV_DWIDTH - 1) downto 0);
	IP2Bus_RdAck : out std_logic;
	IP2Bus_WrAck : out std_logic;
	IP2Bus_Error : out std_logic;

	--Inner signals
	cmd : out std_logic_vector(8 downto 0);

	sel : out std_logic;
	cnt : in std_logic_vector(5 downto 0);

	valid : out std_logic;
	ready : in std_logic;
	draw : out std_logic_vector(31 downto 0)
);
end bus_if;

architecture rtl of bus_if is

signal clk : std_logic := '0';
signal rst : std_logic := '0';

signal cmd_write : std_logic := '0';
signal draw_write : std_logic := '0';
signal bus_write : std_logic := '0';

signal cmd_reg : std_logic_vector((C_SLV_DWIDTH - 1) downto 0) := (others => '0');
signal draw_reg : std_logic_vector((C_SLV_DWIDTH - 1) downto 0) := (others => '0');

begin

---------------------------------------------------------------------------------------
--	Clock and Reset signals
---------------------------------------------------------------------------------------
clk <= Bus2IP_Clk;
rst <= not(Bus2IP_Resetn);

---------------------------------------------------------------------------------------
--	Bus READ
---------------------------------------------------------------------------------------
proc_read : process(clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			IP2Bus_Data <= (others => '0');
		else
			if(Bus2IP_RdCE = "01" and Bus2IP_BE = "1111") then	--Draw Register
				IP2Bus_Data <= draw_reg;
			end if;
			if(Bus2IP_RdCE = "10" and Bus2IP_BE = "1111") then	--Command register
				IP2Bus_Data <= cmd_reg;
			end if;
		end if;	
	end if;
end process proc_read;

---------------------------------------------------------------------------------------
--	Bus WRITE
---------------------------------------------------------------------------------------
cmd_write <= '1' when (Bus2IP_WrCE = "10" and Bus2IP_BE = "1111") else '0';
draw_write <= '1' when (Bus2IP_WrCE = "01" and Bus2IP_BE = "1111") else '0';
bus_write <= '1' when (cmd_write = '1' or draw_write = '1') else '0';

proc_write : process(clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			draw_reg <= (others => '0');
			cmd_reg <= (others => '0');
		else
			--WRITE BUS
			if(bus_write = '1') then
				if(draw_write = '1') then	--Draw Register
					draw_reg <= Bus2IP_Data;
				else
					if(cmd_write = '1') then	--Command register
						cmd_reg <= Bus2IP_Data;
					end if;
				end if;
			--STATUS BITS
			--TODO: Add Error handling
			else
				if(unsigned(cnt) = "00000") then --Draw Register Status: Unavaible
					draw_reg(24) <= '0';
				else
					draw_reg(24) <= '1';
				end if;
				if(to_integer(unsigned(cnt)) > 35)then --Command Register Status: Unavaible
					cmd_reg(12) <= '0';
				else
					cmd_reg(12) <= '1';
				end if;
			end if;
		end if;
	end if;
end process proc_write;

---------------------------------------------------------------------------------------
--	Inner command signal
---------------------------------------------------------------------------------------
cmd <= cmd_reg(8 downto 0);

---------------------------------------------------------------------------------------
--	Inner MUX signals
---------------------------------------------------------------------------------------

--TODO: sel

---------------------------------------------------------------------------------------
--	Inner Draw signal
---------------------------------------------------------------------------------------

--TODO: data, valid, ready

---------------------------------------------------------------------------------------
--	Bus ACKnowledge and ERROR signals
---------------------------------------------------------------------------------------
IP2Bus_RdAck <= '1' when (Bus2IP_RdCE > "00" and Bus2IP_BE = "1111") else '0';
IP2Bus_WrAck <= '1' when (Bus2IP_WrCE > "00" and Bus2IP_BE = "1111") else '0';
IP2Bus_Error <= '0';

end rtl;