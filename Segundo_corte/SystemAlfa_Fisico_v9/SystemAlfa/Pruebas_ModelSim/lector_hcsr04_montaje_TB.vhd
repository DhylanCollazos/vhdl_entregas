library ieee;
use ieee.std_logic_1164.all;
entity lector_hcsr04_montaje_TB is end;
architecture prueba of lector_hcsr04_montaje_TB is
    signal clk:std_logic:='0';signal fin:boolean:=false;
    signal rst,inicio,echo,trig,tamano,lista,valida,ocupado:std_logic:='0';
    signal cm:std_logic_vector(7 downto 0);
begin
    clk<=not clk after 500 ns when not fin else '0';
    U:entity work.lector_hcsr04
        generic map(FRECUENCIA_RELOJ_HZ=>1000000,USAR_VENTANAS_MM=>true,
                    INTERVALO_MINIMO_US=>1000,TIEMPO_MAXIMO_US=>1000)
        port map(clk,rst,inicio,echo,trig,cm,tamano,lista,valida,ocupado);
    process
        procedure medir(ancho:time;v,t:std_logic) is
        begin
            wait for 2 ms;inicio<='1';wait for 1 us;inicio<='0';
            wait until falling_edge(trig);wait for 20 us;
            if ancho>0 us then echo<='1';wait for ancho;echo<='0';end if;
            wait until lista='1' for 2 ms;wait for 1 ns;
            assert lista='1' and valida=v report "Validez incorrecta de ventana fisica" severity failure;
            if v='1' then assert tamano=t report "Tamano fisico incorrecto" severity failure;end if;
            wait until rising_edge(clk);wait until rising_edge(clk);wait for 1 ns;
            assert lista='0' report "Lista dura mas de un ciclo" severity failure;
        end;
    begin
        rst<='1';wait for 10 us;rst<='0';
        medir(110 us,'0','0'); -- Menos de 20 mm.
        medir(116 us,'1','1'); -- 20 mm, grande.
        medir(139 us,'1','1'); -- 24 mm, grande.
        medir(162 us,'1','1'); -- Un poco menos de 28 mm.
        medir(174 us,'0','0'); -- 30 mm, zona dudosa.
        medir(186 us,'1','0'); -- Un poco mas de 32 mm.
        medir(232 us,'1','0'); -- 40 mm, pequena.
        medir(278 us,'1','0'); -- Un poco menos de 48 mm.
        medir(300 us,'0','0'); -- Fuera de ventana pequena.
        medir(348 us,'0','0'); -- Cinta vacia a 60 mm.
        medir(0 us,'0','0');   -- Sin eco, no aceptar cero como grande.
        report "OK: ventanas del montaje, zona dudosa, cinta vacia y timeout" severity note;
        fin<=true;wait;
    end process;
end;
