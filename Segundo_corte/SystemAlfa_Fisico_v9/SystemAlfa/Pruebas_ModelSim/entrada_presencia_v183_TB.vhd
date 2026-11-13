library ieee;
use ieee.std_logic_1164.all;

entity entrada_presencia_v183_TB is
    generic (BAJO : boolean := true; FILTRO : positive := 5);
end entity;

architecture prueba of entrada_presencia_v183_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal pieza : std_logic := '1';
    signal entrada, presencia, pulso : std_logic;
    signal eventos : natural := 0;
    signal terminar : boolean := false;
begin
    reloj <= not reloj after 10 ns when not terminar else '0';
    entrada <= not pieza when BAJO else pieza;
    DUT: entity work.entrada_presencia_v183
        generic map (CICLOS_ESTABLES => FILTRO, ACTIVO_BAJO => BAJO)
        port map (reloj, reinicio, entrada, presencia, pulso);

    process(reloj, reinicio)
        variable anterior : std_logic := '0';
    begin
        if reinicio = '1' then
            eventos <= 0; anterior := '0';
        elsif rising_edge(reloj) then
            assert not (pulso = '1' and anterior = '1')
                report "El evento dura mas de un ciclo" severity failure;
            if pulso = '1' then eventos <= eventos + 1; end if;
            anterior := pulso;
        end if;
    end process;

    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until falling_edge(reloj); end loop;
        end procedure;
    begin
        ciclos(4); reinicio <= '0'; ciclos(30);
        assert eventos = 0 report "Pieza al arrancar genero un evento falso" severity failure;
        pieza <= '0'; ciclos(30);
        assert presencia = '0' severity failure;
        if FILTRO > 1 then
            pieza <= '1'; ciclos(1); pieza <= '0'; ciclos(30);
            assert eventos = 0 report "No filtro una perturbacion corta" severity failure;
        end if;
        pieza <= '1'; ciclos(30);
        assert presencia = '1' and eventos = 1 report "Primera pieza incorrecta" severity failure;
        ciclos(80);
        assert eventos = 1 report "Repite eventos con la pieza sostenida" severity failure;
        if FILTRO > 1 then
            pieza <= '0'; ciclos(1); pieza <= '1'; ciclos(30);
            assert eventos = 1 and presencia = '1' report "Retiro breve rearma el sensor" severity failure;
        end if;
        pieza <= '0'; ciclos(30); pieza <= '1'; ciclos(30);
        assert eventos = 2 report "No reconocio la segunda pieza" severity failure;
        reinicio <= '1'; ciclos(4); reinicio <= '0'; ciclos(30);
        assert eventos = 0 report "Reset con pieza produjo evento" severity failure;
        pieza <= '0'; ciclos(30); pieza <= '1'; ciclos(30);
        assert eventos = 1 report "No rearmo despues del reset y retiro" severity failure;
        report "OK: V183, polaridad, arranque ocupado, rebotes, retencion y reset" severity note;
        terminar <= true; wait;
    end process;
end architecture;
