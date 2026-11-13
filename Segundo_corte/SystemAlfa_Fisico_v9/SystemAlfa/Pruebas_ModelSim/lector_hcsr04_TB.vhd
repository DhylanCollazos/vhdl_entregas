library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lector_hcsr04_TB is end entity;
architecture prueba of lector_hcsr04_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal iniciar, echo, trig, tamano, lista, valida, ocupado : std_logic := '0';
    signal distancia : std_logic_vector(7 downto 0);
    signal terminar : boolean := false;
    signal disparos, resultados : natural := 0;
begin
    -- 1 MHz solo para acelerar simulacion; la placa usa 50 MHz.
    reloj <= not reloj after 500 ns when not terminar else '0';
    DUT: entity work.lector_hcsr04
        generic map (FRECUENCIA_RELOJ_HZ => 1000000)
        port map (reloj, reinicio, iniciar, echo, trig, distancia, tamano, lista, valida, ocupado);
    process(trig)
    begin
        if rising_edge(trig) then disparos <= disparos + 1; end if;
    end process;
    process(reloj)
        variable anterior : std_logic := '0';
    begin
        if rising_edge(reloj) then
            assert not (lista = '1' and anterior = '1') report "Lista dura mas de un ciclo" severity failure;
            if lista = '1' then resultados <= resultados + 1; end if;
            anterior := lista;
        end if;
    end process;
    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until falling_edge(reloj); end loop;
        end procedure;
        procedure orden is
        begin
            iniciar <= '1'; ciclos(1); iniciar <= '0';
        end procedure;
        procedure medir(ancho_us, esperado_cm : natural; valido, grande : std_logic) is
            variable t : time;
            variable prev : natural;
        begin
            ciclos(62000);
            iniciar <= '1';
            wait until trig = '1' for 20 us;
            assert trig = '1' report "No genera TRIG" severity failure;
            t := now;
            wait until trig = '0' for 20 us;
            assert now-t = 10 us report "TRIG no dura 10 us" severity failure;
            iniciar <= '0';
            wait until falling_edge(reloj); ciclos(20);
            if ancho_us > 0 then
                echo <= '1'; wait for ancho_us*1 us; echo <= '0';
            end if;
            wait until lista = '1' for 81000 us;
            assert lista = '1' report "Medicion nunca termina" severity failure;
            wait for 1 ns;
            assert to_integer(unsigned(distancia)) = esperado_cm report "Distancia incorrecta" severity failure;
            assert valida = valido report "Validez incorrecta en limite de distancia" severity failure;
            if valido = '1' then assert tamano = grande report "Tamano incorrecto" severity failure; end if;
            ciclos(3);
            prev := disparos;
            orden; ciclos(100);
            assert disparos = prev report "Acepto disparo antes de 61 ms" severity failure;
        end procedure;
        variable prev : natural;
    begin
        ciclos(4); reinicio <= '0'; ciclos(4);
        medir(23*58,23,'1','1'); medir(25*58,25,'1','1');
        medir(1479,26,'0','0'); -- 25.5 cm: no redondear hacia una clase valida.
        medir(26*58,26,'0','0'); medir(27*58,27,'0','0'); medir(29*58,29,'0','0');
        medir(30*58,30,'1','0'); medir(32*58,32,'1','0');
        medir(2*58,2,'1','1'); medir(58,1,'0','0');
        medir(256*58,255,'0','0'); medir(0,0,'0','0');
        ciclos(62000); echo <= '1'; ciclos(5); prev := disparos;
        iniciar <= '1';
        wait until lista = '1' for 20 us;
        assert lista = '1' and valida = '0' report "No detecto ECHO alto inicial" severity failure;
        ciclos(70000);
        assert disparos = prev report "Repitio la orden sostenida" severity failure;
        iniciar <= '0'; echo <= '0'; ciclos(62000);
        orden;
        wait until trig = '0' for 30 us; ciclos(20); echo <= '1';
        wait until lista = '1' for 41000 us;
        assert lista = '1' and valida = '0' report "Falta timeout de ECHO sostenido" severity failure;
        echo <= '0'; ciclos(4);
        reinicio <= '1'; ciclos(4); reinicio <= '0'; ciclos(4);
        assert ocupado = '0' and valida = '0' and trig = '0' severity failure;
        report "OK: HCSR04, limites, TRIG, intervalo, orden sostenida y timeouts" severity note;
        terminar <= true; wait;
    end process;
end architecture;
