library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Ajustes en registros: sobreviven a BUTTON1, se pierden al apagar/configurar.
-- Tiempo en centesimas (10 ms). NO hay tiempos de transporte inventados.
entity ajuste_fisico is
    port (reloj, reinicio_sesion, reinicio_operativo, tick : in std_logic;
          modo_ajuste, permiso, aumentar, disminuir : in std_logic;
          pagina : in integer range 0 to 63;
          velocidad : in integer range 0 to 3;
          porcentaje : out integer range 0 to 100;
          reposo1, desvio1, reposo2, desvio2 : out integer range 1000 to 2000;
          adelanto1, adelanto2 : out integer range 5 to 100;
          llegada1, llegada2, salida_cinta : out integer range 0 to 6000;
          listo, posiciones1, posiciones2, motor_prueba, error_ajuste : out std_logic;
          etapa : out std_logic_vector(3 downto 0);
          valor : out integer range 0 to 65535);
end;

architecture fsm_tres_procesos of ajuste_fisico is
    type tabla_duty is array(0 to 3) of integer range 0 to 100;
    type tabla_tiempo is array(0 to 3) of integer range 0 to 6000;
    type tabla_posicion is array(0 to 3) of integer range 1000 to 2000;
    type tabla_adelanto is array(0 to 1) of integer range 5 to 100;
    type tipo_estado is (ESPERA, MIDE_SERVO1, MIDE_SERVO2, MIDE_SALIDA, FALLO_AJUSTE);
    signal estado, siguiente : tipo_estado := ESPERA;
    signal duty : tabla_duty := (others=>0);
    signal t1,t2,fin : tabla_tiempo := (others=>0);
    signal pos : tabla_posicion := (others=>1500);
    signal avance : tabla_adelanto := (others=>30);
    signal tiempos_validos, posiciones_validas : std_logic_vector(3 downto 0) := "0000";
    signal cuenta, marca1, marca2 : integer range 0 to 6000 := 0;
    signal iniciar, cancelar : std_logic;
begin
    iniciar <= '1' when modo_ajuste='1' and permiso='1' and pagina=7 and
                        aumentar='1' and duty(velocidad)>0 else '0';
    cancelar <= '1' when modo_ajuste='0' or permiso='0' or pagina/=7 or
                         disminuir='1' or reinicio_operativo='1' else '0';
    -- PROCESO 1: estado y datos. Un solo escritor por tabla.
    process(reloj)
        variable idx : integer;
    begin
        if rising_edge(reloj) then
            if reinicio_sesion='1' then
                estado<=ESPERA; duty<=(others=>0); t1<=(others=>0); t2<=(others=>0);
                fin<=(others=>0); pos<=(others=>1500); avance<=(others=>30);
                tiempos_validos<="0000"; posiciones_validas<="0000";
                cuenta<=0; marca1<=0; marca2<=0;
            else
                estado<=siguiente;
                if estado=ESPERA and iniciar='1' and cancelar='0' then
                    cuenta<=0; marca1<=0; marca2<=0; tiempos_validos(velocidad)<='0';
                elsif estado=MIDE_SERVO1 or estado=MIDE_SERVO2 or estado=MIDE_SALIDA then
                    if tick='1' and cuenta<6000 then cuenta<=cuenta+1; end if;
                    if aumentar='1' and cancelar='0' then
                        if estado=MIDE_SERVO1 then marca1<=cuenta;
                        elsif estado=MIDE_SERVO2 then marca2<=cuenta;
                        elsif cuenta>marca2 and marca2>marca1 and
                              marca1>avance(0) and marca2>avance(1) and cuenta<6000 then
                            t1(velocidad)<=marca1; t2(velocidad)<=marca2;
                            fin(velocidad)<=cuenta; tiempos_validos(velocidad)<='1';
                        end if;
                    end if;
                end if;
                if modo_ajuste='1' and reinicio_operativo='0' and estado=ESPERA then
                    if pagina=0 and (aumentar='1' or disminuir='1') then
                        tiempos_validos(velocidad)<='0';
                        if aumentar='1' and duty(velocidad)<=95 then duty(velocidad)<=duty(velocidad)+5;
                        elsif disminuir='1' and duty(velocidad)>=5 then duty(velocidad)<=duty(velocidad)-5; end if;
                    elsif pagina>=1 and pagina<=4 and (aumentar='1' or disminuir='1') then
                        idx:=pagina-1; posiciones_validas(idx)<='1'; tiempos_validos<="0000";
                        if aumentar='1' and pos(idx)<=1975 then pos(idx)<=pos(idx)+25;
                        elsif disminuir='1' and pos(idx)>=1025 then pos(idx)<=pos(idx)-25; end if;
                    elsif (pagina=5 or pagina=6) and (aumentar='1' or disminuir='1') then
                        idx:=pagina-5; tiempos_validos<="0000";
                        if aumentar='1' and avance(idx)<=95 then avance(idx)<=avance(idx)+5;
                        elsif disminuir='1' and avance(idx)>=10 then avance(idx)<=avance(idx)-5; end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    -- PROCESO 2: transiciones del cronometro de calibracion.
    process(estado,iniciar,cancelar,cuenta,aumentar,marca1,marca2,avance)
    begin
        siguiente<=estado;
        if cancelar='1' then siguiente<=ESPERA;
        else
            case estado is
                when ESPERA => if iniciar='1' then siguiente<=MIDE_SERVO1; end if;
                when MIDE_SERVO1 =>
                    if cuenta=6000 then siguiente<=FALLO_AJUSTE;
                    elsif aumentar='1' then
                        if cuenta>avance(0) then siguiente<=MIDE_SERVO2;
                        else siguiente<=FALLO_AJUSTE; end if;
                    end if;
                when MIDE_SERVO2 =>
                    if cuenta=6000 then siguiente<=FALLO_AJUSTE;
                    elsif aumentar='1' then
                        if cuenta>marca1 and cuenta>avance(1) then siguiente<=MIDE_SALIDA;
                        else siguiente<=FALLO_AJUSTE; end if;
                    end if;
                when MIDE_SALIDA =>
                    if cuenta=6000 then siguiente<=FALLO_AJUSTE;
                    elsif aumentar='1' then
                        if cuenta>marca2 then siguiente<=ESPERA; else siguiente<=FALLO_AJUSTE; end if;
                    end if;
                when FALLO_AJUSTE => null;
            end case;
        end if;
    end process;
    -- PROCESO 3: salidas de prueba; ninguna escribe conteos ni historial.
    process(estado,modo_ajuste,permiso,pagina,cuenta,duty,velocidad,pos,avance,t1,t2,fin)
    begin
        motor_prueba<='0'; error_ajuste<='0'; etapa<="0000"; valor<=0;
        if modo_ajuste='1' and permiso='1' then
            if pagina=0 or estado=MIDE_SERVO1 or estado=MIDE_SERVO2 or estado=MIDE_SALIDA then motor_prueba<='1'; end if;
        end if;
        case estado is
            when MIDE_SERVO1=>etapa<="0001";
            when MIDE_SERVO2=>etapa<="0010";
            when MIDE_SALIDA=>etapa<="0011";
            when FALLO_AJUSTE=>etapa<="1111"; error_ajuste<='1';
            when others=>null;
        end case;
        case pagina is
            when 0=>valor<=duty(velocidad);
            when 1 to 4=>valor<=pos(pagina-1);
            when 5 to 6=>valor<=avance(pagina-5)*10; -- ms
            when 7=>valor<=cuenta; -- centesimas
            when 12=>valor<=t1(velocidad);
            when 13=>valor<=t2(velocidad);
            when 14=>valor<=fin(velocidad);
            when others=>null;
        end case;
    end process;
    porcentaje<=duty(velocidad);
    reposo1<=pos(0); desvio1<=pos(1); reposo2<=pos(2); desvio2<=pos(3);
    adelanto1<=avance(0); adelanto2<=avance(1);
    llegada1<=t1(velocidad); llegada2<=t2(velocidad); salida_cinta<=fin(velocidad);
    posiciones1<=posiciones_validas(0); posiciones2<=posiciones_validas(2);
    listo<='1' when tiempos_validos(velocidad)='1' and posiciones_validas="1111" and
                   pos(0)/=pos(1) and pos(2)/=pos(3) and duty(velocidad)>0 else '0';
end;
