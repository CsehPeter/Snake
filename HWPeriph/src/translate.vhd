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

entity translate is
generic
(
	C_SLV_DWIDTH : integer := 32
);
port
(
	clk : in std_logic;
	rst : in std_logic;

	din : in std_logic_vector((C_SLV_DWIDTH - 1) downto 0);
	cmd : out std_logic;

	en : in std_logic;
	cnt : out std_logic_vector(5 downto 0);
	ready : out std_logic;
	valid : in std_logic
);
end translate;

architecture rtl of translate is

type translate_fsm_type is (IDLE, TRANSLATE, SHIFT);
signal fsm : translate_fsm_type := IDLE;

type shr_type is array (17 downto 0) of std_logic_vector(8 downto 0);
signal shr : shr_type := (others => (others => '0'));

--type draw_reg_type is array (1 downto 0) of std_logic_vector(8 downto 0);
--signal draw_reg : draw_reg_type := (others => (others => '0'));

signal draw_reg : std_logic_vector(8 downto 0) := (others => '0');

signal shift_cntr : integer range 0 to 18 := 0;

signal fetch_ready : std_logic := '0';
signal ack : std_logic := '0';

begin

proc_fetch : process(clk)
begin
	
end process proc_fetch;

proc_shift : process(clk)
begin

end process proc_shift;

end architecture rtl;