library ieee;
use ieee.std_logic_1164.all;
-- Un pulso de reloj cada 10 ms. Todas las FSM usan CLOCK_50, sin relojes nuevos.
entity base_tiempo_fisica is
    generic (CICLOS_TICK : positive := 500000);
    port (reloj, reinicio : in std_logic; tick : out std_logic);
end;
architecture rtl of base_tiempo_fisica is
    signal cuenta : integer range 0 to CICLOS_TICK-1 := 0;
begin
    process(reloj, reinicio)
    begin
        if reinicio='1' then cuenta<=0; tick<='0';
        elsif rising_edge(reloj) then
            tick<='0';
            if cuenta=CICLOS_TICK-1 then cuenta<=0; tick<='1';
            else cuenta<=cuenta+1; end if;
        end if;
    end process;
end;
