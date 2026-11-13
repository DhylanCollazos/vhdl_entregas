library ieee;
use ieee.std_logic_1164.all;

package paquete_funciones is
    subtype tipo_direccion_rom is std_logic_vector(2 downto 0);
    function formar_direccion(
        color_funcion : std_logic_vector(1 downto 0);
        tamano_funcion : std_logic
    ) return tipo_direccion_rom;
end package paquete_funciones;

package body paquete_funciones is
    function formar_direccion(
        color_funcion : std_logic_vector(1 downto 0);
        tamano_funcion : std_logic
    ) return tipo_direccion_rom is
        variable resultado : tipo_direccion_rom;
    begin
        resultado := color_funcion & tamano_funcion;
        return resultado;
    end function formar_direccion;
end package body paquete_funciones;