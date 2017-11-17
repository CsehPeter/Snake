---------------------------------------------------------------------------------------
-- Company: 	BME
-- Engineer: 	Cseh Peter (DM5HMB), Limbay Bence (E2JT1E)
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
	C_NUM_REG : integer := 1;
	C_SLV_DWIDTH : integer := 32
);
port
(
	--Bus signals
	Bus2IP_Clk : in std_logic;
	Bus2IP_Resetn : in std_logic;

	Bus2IP_Data : in std_logic_vector((C_SLV_DWIDTH - 1) downto 0);
	Bus2IP_BE : in std_logic_vector((C_SLV_DWIDTH / 8 - 1) downto 0);
	Bus2IP_RdCE : in std_logic;
	Bus2IP_WrCE : in std_logic;

	IP2Bus_Data : out std_logic_vector((C_SLV_DWIDTH - 1) downto 0);
	IP2Bus_RdAck : out std_logic;
	IP2Bus_WrAck : out std_logic;
	IP2Bus_Error : out std_logic;

	--Inner signals
	cmd : out std_logic_vector(8 downto 0);
	wr : out std_logic;
	full : in std_logic;
	
	--Status signals
	stat_empty : in std_logic;
	stat_spi_busy : in std_logic;
	stat_fifo_neg : in std_logic;
	stat_spi_neg : in Std_logic
);
end bus_if;

architecture rtl of bus_if is

signal clk : std_logic := '0';
signal rst : std_logic := '0';

signal cmd_reg : std_logic_vector((C_SLV_DWIDTH - 1) downto 0) := (others => '0');

begin

---------------------------------------------------------------------------------------
--	Clock and Reset signals
---------------------------------------------------------------------------------------
clk <= Bus2IP_Clk;
rst <= not(Bus2IP_Resetn);

---------------------------------------------------------------------------------------
--	Bus READ
---------------------------------------------------------------------------------------
--proc_read : process(clk)
--begin
--	if(rising_edge(clk)) then
--		if(rst = '1') then
--			IP2Bus_Data <= (others => '0');
--		else
--			if(Bus2IP_RdCE = "1" and Bus2IP_BE = "1111") then
--				IP2Bus_Data <= cmd_reg;
--			end if;
--		end if;	
--	end if;
--end process proc_read;

IP2Bus_Data <= cmd_reg when (Bus2IP_RdCE = '1' and Bus2IP_BE = "1111") else (others => '0');

---------------------------------------------------------------------------------------
--	Bus WRITE
---------------------------------------------------------------------------------------

proc_write : process(clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			cmd_reg <= (others => '0');
		else

			--WRITE BUS
			if(Bus2IP_WrCE = '1' and Bus2IP_BE = "1111") then

				cmd_reg <= Bus2IP_Data;

				if(full = '1') then
					wr <= '0';
				else
					wr<= '1';
				end if;

			--STATUS BITS
			else
				if(full = '1') then --Command Register Status: Unavaible
					cmd_reg(12) <= '0';
				else
					cmd_reg(12) <= '1';
				end if;
				cmd_reg(31) <= stat_empty;
				cmd_reg(30) <= stat_spi_busy;
				cmd_reg(29) <= stat_fifo_neg;
				cmd_reg(28) <= stat_spi_neg;
				wr <= '0';
			end if;
		end if;
	end if;
end process proc_write;

cmd <= cmd_reg(8 downto 0);

---------------------------------------------------------------------------------------
--	Bus ACKnowledge and ERROR signals
---------------------------------------------------------------------------------------
IP2Bus_RdAck <= '1' when (Bus2IP_RdCE = '1' and Bus2IP_BE = "1111") else '0';
IP2Bus_WrAck <= '1' when (Bus2IP_WrCE = '1' and Bus2IP_BE = "1111") else '0';
IP2Bus_Error <= '0';

end rtl;