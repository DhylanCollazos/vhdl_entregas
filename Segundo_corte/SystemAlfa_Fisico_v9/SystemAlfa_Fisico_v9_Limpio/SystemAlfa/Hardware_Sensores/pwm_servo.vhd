library ieee;
use ieee.std_logic_1164.all;
-- 50 Hz; ancho configurado en microsegundos y tomado al inicio de cada trama.
entity pwm_servo is
    generic (CICLOS_US : positive := 50);
    port (reloj, reinicio, habilitar : in std_logic;
          ancho_us : in integer range 1000 to 2000;
          salida : out std_logic);
end;
architecture rtl of pwm_servo is
    signal subcuenta : integer range 0 to CICLOS_US-1 := 0;
    signal microsegundos : integer range 0 to 19999 := 0;
    signal ancho_guardado : integer range 1000 to 2000 := 1500;
begin
    process(reloj, reinicio)
    begin
        if reinicio='1' then subcuenta<=0; microsegundos<=0; ancho_guardado<=1500;
        elsif rising_edge(reloj) then
            if habilitar='0' then subcuenta<=0; microsegundos<=0;
            elsif subcuenta=CICLOS_US-1 then
                subcuenta<=0;
                if microsegundos=19999 then microsegundos<=0;
                else microsegundos<=microsegundos+1; end if;
            else subcuenta<=subcuenta+1; end if;
            if microsegundos=0 and subcuenta=0 then ancho_guardado<=ancho_us; end if;
        end if;
    end process;
    salida <= '1' when habilitar='1' and reinicio='0' and microsegundos<ancho_guardado else '0';
end;
