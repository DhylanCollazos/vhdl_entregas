library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity lector_tcs3200_TB is end entity;
architecture prueba of lector_tcs3200_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal iniciar, entrada, s0, s1, s2, s3, lista, valida, ocupado : std_logic := '0';
    signal color, color_prueba : std_logic_vector(1 downto 0);
    signal rojo, verde, azul : std_logic_vector(15 downto 0);
    signal valida_prueba : std_logic;
    signal caso : natural range 0 to 4 := 0;
    signal terminar : boolean := false;
begin
    reloj <= not reloj after 10 ns when not terminar else '0';
    DUT: entity work.lector_tcs3200
        generic map (VENTANA_CICLOS => 100, ASENTAMIENTO_CICLOS => 10)
        port map (reloj,reinicio,iniciar,entrada,s0,s1,s2,s3,color,rojo,verde,azul,lista,valida,ocupado);
    -- Umbrales SINTETICOS solo para probar el algoritmo; NO son calibracion fisica.
    DUT_ALGORITMO: entity work.lector_tcs3200
        generic map (VENTANA_CICLOS => 100, ASENTAMIENTO_CICLOS => 10,
                     CLASIFICACION_HABILITADA => true,
                     BASE_NEGRA_ROJO => 0, BASE_NEGRA_VERDE => 0, BASE_NEGRA_AZUL => 0,
                     GANANCIA_ROJO_Q5 => 32, GANANCIA_VERDE_Q5 => 32, GANANCIA_AZUL_Q5 => 32,
                     SENAL_MINIMA => 3)
        port map (reloj,reinicio,iniciar,entrada,open,open,open,open,color_prueba,
                  open,open,open,open,valida_prueba,open);
    process(reloj)
        variable fase : natural := 0;
        variable periodo : positive := 10;
        variable anterior : std_logic_vector(1 downto 0) := "00";
        variable filtro : std_logic_vector(1 downto 0);
    begin
        if falling_edge(reloj) then
            filtro := s2 & s3;
            periodo := 20;
            if filtro = "01" then periodo := 25; end if;
            if (caso=0 and filtro="00") or (caso=1 and filtro="11") or
               (caso=2 and filtro="01") or caso=3 then periodo := 10; end if;
            if filtro /= anterior or fase >= periodo-1 then fase := 0;
            else fase := fase+1; end if;
            anterior := filtro;
            if caso=4 then entrada <= '0';
            elsif fase < periodo/2 then entrada <= '1'; else entrada <= '0'; end if;
        end if;
    end process;
    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until rising_edge(reloj); wait for 1 ns; end loop;
        end procedure;
        procedure muestra(c : natural; r,g,b : natural; codigo : std_logic_vector(1 downto 0)) is
        begin
            caso <= c; ciclos(30); iniciar <= '1';
            wait until ocupado = '1' for 1 us;
            assert ocupado = '1' and s2='0' and s3='0' severity failure;
            wait until s2='1' and s3='1' for 3 us;
            assert s2='1' and s3='1' report "Falta filtro verde" severity failure;
            wait until s2='0' and s3='1' for 3 us;
            assert s2='0' and s3='1' report "Falta filtro azul" severity failure;
            wait until lista='1' for 3 us; wait for 1 ns;
            assert lista='1' report "Falta pulso final TCS" severity failure;
            assert to_integer(unsigned(rojo))=r and to_integer(unsigned(verde))=g and
                   to_integer(unsigned(azul))=b report "Conteos RGB incorrectos" severity failure;
            assert color="00" and valida='0' report "Clasifica sin calibracion" severity failure;
            assert color_prueba=codigo report "Algoritmo sintetico incorrecto" severity failure;
            if codigo="00" then assert valida_prueba='0' severity failure;
            else assert valida_prueba='1' severity failure; end if;
            assert s0='1' and s1='0' report "Escala no es 20 por ciento" severity failure;
            ciclos(1); assert lista='0' report "Pulso lista demasiado largo" severity failure;
            ciclos(400); assert ocupado='0' and lista='0' report "Orden sostenida repite medicion" severity failure;
            iniciar <= '0'; ciclos(5);
        end procedure;
    begin
        ciclos(5); reinicio <= '0'; ciclos(5);
        muestra(0,10,5,4,"01"); muestra(1,5,10,4,"10");
        muestra(2,5,5,10,"11"); muestra(3,10,10,10,"00");
        muestra(4,0,0,0,"00");
        iniciar <= '1'; ciclos(40); reinicio <= '1'; ciclos(5);
        iniciar <= '0'; reinicio <= '0'; ciclos(5);
        assert ocupado='0' and lista='0' and rojo=x"0000" and verde=x"0000" and azul=x"0000"
            report "Reset durante medicion incorrecto" severity failure;
        report "OK: TCS3200, filtros RGB, conteos, calibracion, empates, reset y orden sostenida" severity note;
        terminar <= true; wait;
    end process;
end architecture;
