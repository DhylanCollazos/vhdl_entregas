library ieee;
use ieee.std_logic_1164.all;
entity pwm_fisico_TB is end;
architecture prueba of pwm_fisico_TB is
    signal clk:std_logic:='0';signal fin:boolean:=false;
    signal reset,habilitar:std_logic:='0';signal m,a,b,s:std_logic;
    signal duty:integer range 0 to 100:=0;signal ancho:integer range 1000 to 2000:=1500;
begin
    clk<=not clk after 500 ns when not fin else '0';
    U_M:entity work.control_motor_l298n generic map(100) port map(clk,reset,habilitar,duty,m,a,b);
    U_S:entity work.pwm_servo generic map(1) port map(clk,reset,habilitar,ancho,s);
    process
        variable altos:integer;variable t:time;
    begin
        reset<='1';wait for 10 us;reset<='0';habilitar<='1';
        for valor in 0 to 4 loop
            duty<=valor*25;wait for 300 us;altos:=0;
            for i in 1 to 100 loop wait until falling_edge(clk);if m='1' then altos:=altos+1;end if;end loop;
            assert altos=valor*25 report "Duty PWM incorrecto" severity failure;
        end loop;
        for valor in 0 to 2 loop
            ancho<=1000+valor*500;wait for 40 ms;
            wait until rising_edge(s);t:=now;wait until falling_edge(s);
            assert now-t=(1000+valor*500)*1 us report "Ancho servo incorrecto" severity failure;
        end loop;
        habilitar<='0';wait for 1 ns;assert m='0' and s='0' report "No deshabilita salidas" severity failure;
        habilitar<='1';wait for 1 ms;reset<='1';wait for 1 ns;
        assert m='0' and s='0' report "Reset no corta pulsos" severity failure;
        report "OK: PWM motor 0/25/50/75/100 y servo 1000/1500/2000 us" severity note;fin<=true;wait;
    end process;
end;
