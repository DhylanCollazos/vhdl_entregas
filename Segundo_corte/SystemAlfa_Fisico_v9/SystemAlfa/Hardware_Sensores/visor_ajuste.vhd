library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Conversion decimal desplazando un bit por ciclo (doble desplazamiento BCD).
entity visor_ajuste is
    port (reloj : in std_logic; valor : in integer range 0 to 65535;
          hexadecimal : in std_logic; hex0,hex1,hex2,hex3 : out std_logic_vector(6 downto 0));
end;
architecture rtl of visor_ajuste is
    signal binario : unsigned(15 downto 0) := (others=>'0');
    signal bcd : unsigned(19 downto 0) := (others=>'0');
    signal paso : integer range 0 to 16 := 0;
    signal decimal_guardado,hex_guardado : std_logic_vector(15 downto 0) := (others=>'0');
    signal n : std_logic_vector(15 downto 0);
begin
    process(reloj)
        variable ajuste : unsigned(19 downto 0);
    begin
        if rising_edge(reloj) then
            hex_guardado<=std_logic_vector(to_unsigned(valor,16));
            if paso=0 then
                binario<=to_unsigned(valor,16);bcd<=(others=>'0');paso<=1;
            else
                ajuste:=bcd;
                for i in 0 to 4 loop
                    if ajuste(i*4+3 downto i*4)>=5 then
                        ajuste(i*4+3 downto i*4):=ajuste(i*4+3 downto i*4)+3;
                    end if;
                end loop;
                ajuste:=ajuste(18 downto 0)&binario(15);
                bcd<=ajuste;binario<=binario(14 downto 0)&'0';
                if paso=16 then decimal_guardado<=std_logic_vector(ajuste(15 downto 0));paso<=0;
                else paso<=paso+1;end if;
            end if;
        end if;
    end process;
    n <= hex_guardado when hexadecimal='1' else decimal_guardado;
    U0: entity work.decodificador_7segmentos port map(n(3 downto 0),hex0);
    U1: entity work.decodificador_7segmentos port map(n(7 downto 4),hex1);
    U2: entity work.decodificador_7segmentos port map(n(11 downto 8),hex2);
    U3: entity work.decodificador_7segmentos port map(n(15 downto 12),hex3);
end;
