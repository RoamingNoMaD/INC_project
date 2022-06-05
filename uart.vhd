-- uart.vhd: UART controller - receiving part
-- Author(s): János László Vasík (xvasik05)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
	signal CTR1 	: std_logic_vector(4 downto 0);
	signal CTR2 	: std_logic_vector(3 downto 0);
	signal CTR1_EN 	: std_logic;
	signal READ_D  	: std_logic;
	signal VLD	   	: std_logic;
begin
	FSM: entity work.UART_FSM(behavioral)
	port map(
		CLK 		=> CLK,
		RST			=> RST,
		INP 		=> DIN,
		CTR1 		=> CTR1,
		CTR1_EN		=> CTR1_EN,
		READ_D 		=> READ_D,
		ALL_READ 	=> CTR2(3),
		VLD			=> VLD
	);
	DOUT_VLD <= VLD;
	process (CLK) begin
		if rising_edge(CLK) then
			if RST = '1' then
				CTR1 <= "00000";
				CTR2 <= "0000";
			else
				if CTR1_EN = '1' then 
					CTR1 <= CTR1 + 1;
				else 
					CTR1 <= "00000";
				end if;
				if READ_D = '1' and (to_integer(unsigned(CTR1)) >= 16) then
					DOUT(to_integer(unsigned(CTR2))) <= DIN;
					CTR2 <= CTR2 + 1;
					CTR1 <= "00001";
				end if;
				if READ_D = '0' then 
					CTR2 <= "0000";
				end if;
			end if; 
		end if;
	end process;
end behavioral;
