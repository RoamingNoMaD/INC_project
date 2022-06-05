-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): János László Vasík (xvasik05)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK       : in std_logic;
   RST       : in std_logic;
   INP       : in std_logic;
   CTR1      : in std_logic_vector(4 downto 0);
   ALL_READ  : in std_logic;
   READ_D    : out std_logic;
   CTR1_EN   : out std_logic;
   VLD       : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type currState is (WAIT_START, WAIT_DATA, READ_DATA, WAIT_STOP, VALIDATE);
signal state : currState := WAIT_START;
begin
   READ_D  <= '1' when state = READ_DATA else '0';
   CTR1_EN <= '1' when state = WAIT_DATA or state = WAIT_STOP or state = READ_DATA else '0';
   VLD     <= '1' when state = VALIDATE else '0';
   process (CLK) begin
      if rising_edge(CLK) then
         if RST = '1' then
            state <= WAIT_START;
         else
            case state is
            when WAIT_START=> if INP = '0' then
                                 state <= WAIT_DATA;
                              end if;
            when WAIT_DATA => if (to_integer(unsigned(CTR1)) = 22) then
                                 state <= READ_DATA;
                              end if;
            when READ_DATA => if ALL_READ = '1' then
                                 state <= WAIT_STOP;
                              end if;
            when WAIT_STOP => if (to_integer(unsigned(CTR1)) = 16) then
                                 state <= VALIDATE;
                              end if;
            when VALIDATE  => state <= WAIT_START;
            when others    => null;
            end case;
         end if;
      end if;
   end process;
end behavioral;