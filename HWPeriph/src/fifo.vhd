---------------------------------------------------------------------------------------
-- Company: 	BME
-- Engineer: 	Cseh PÃ©ter (DM5HMB), Limbay Bence (E2JT1E)
-- 
-- Create Date: 2017.10.29
-- Design Name: lcd
-- Module Name: fifo
---------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity fifo is
generic
(
	DEPTH : integer := 36;
	WIDTH : integer := 9
);
port
(
	clk : in std_logic;
	rst : in std_logic;

	din : in std_logic_vector((WIDTH - 1) downto 0);
	dout : out std_logic_vector((WIDTH - 1) downto 0);

	rd : in std_logic;
	wr : in std_logic;

	empty : out std_logic;
	full : out std_logic
);
end fifo;

architecture rtl of fifo is

type mem_type is array ((DEPTH - 1) downto 0) of std_logic_vector((WIDTH - 1) downto 0);
signal mem : mem_type := (others => (others => '0'));

signal cnt : integer range 0 to DEPTH := 0;

signal rd_pt : integer range 0 to (DEPTH - 1) := 0;
signal wr_pt : integer range 0 to (DEPTH - 1) := 0;

signal op : std_logic_vector(1 downto 0);

begin


proc_fifo : process(clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			dout <= (others => '0');
			empty <= '1';
			full <= '0';

			rd_pt <= 0;
			wr_pt <= 0;
			cnt <= 0;
		else
				--ONLY READ
				if(rd = '1' and wr = '0') then

					if(cnt = 1) then --EMPTY
						empty <= '1';
					end if;

					full <= '0'; --FULL

					if(cnt > 0) then
						cnt <= cnt - 1;	--COUNT

						if(rd_pt = (DEPTH - 1)) then --READ POINTER
							rd_pt <= 0;
						else
							rd_pt <= rd_pt + 1;	
						end if;
					end if;

					dout <= mem(rd_pt); --READ DATA
					
                end if;
	
				--ONLY WRITE
				if(wr = '1' and rd = '0') then

					if(cnt = (DEPTH - 1)) then --FULL
						full <= '1';
					end if;

					empty <= '0'; --EMPTY

					if(cnt < DEPTH) then
						cnt <= cnt + 1;	--COUNT

						if(wr_pt = (DEPTH - 1)) then --WRITE POINTER
							wr_pt <= 0;
						else
							wr_pt <= wr_pt + 1;
						end if;

						mem(wr_pt) <= din;	--WRITE DATA
					end if;
                end if;

				--BOTH READ AND WRITE
				if(wr = '1' and rd = '1') then

					mem(wr_pt) <= din;	--WRITE DATA
					dout <= mem(rd_pt);	--READ DATA

					if(rd_pt = (DEPTH - 1)) then --READ POINTER
						rd_pt <= 0;
					else
						rd_pt <= rd_pt + 1;	
					end if;

					if(wr_pt = (DEPTH - 1)) then --WRITE POINTER
						wr_pt <= 0;
					else
						wr_pt <= wr_pt + 1;
					end if;
					
                end if;

		end if;
	end if;
end process proc_fifo;

end rtl;