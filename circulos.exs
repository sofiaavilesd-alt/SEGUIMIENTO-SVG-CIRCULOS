defmodule Circulos do
  @moduledoc """
 
  Uso:
    elixir circulos.exs                      -> pregunta los datos por teclado
    elixir circulos.exs 10 15                -> 10 círculos, reducción de 15
    elixir circulos.exs 10 15 arcoiris       -> con estilo (lineas | alternado | arcoiris)
  """

  @radio_inicial 200
  @margen 20

  # ---------------------------------------------------------------
  # FUNCIÓN RECURSIVA PRINCIPAL
  # Recibe: centro (cx, cy), radio, círculos que faltan (n),
  #         reducción del radio, estilo e índice del círculo actual.
  # Devuelve el texto SVG de todos los círculos.
  # ---------------------------------------------------------------

  # CASO BASE 1: ya no faltan círculos por dibujar
  def circulos(_cx, _cy, _radio, 0, _reduccion, _estilo, _i), do: ""

  # CASO BASE 2: el radio ya no es positivo (evita círculos inválidos)
  def circulos(_cx, _cy, radio, _n, _reduccion, _estilo, _i) when radio <= 0, do: ""

  # CASO RECURSIVO: dibuja el círculo actual y llama a sí misma
  # con un círculo más pequeño, mismo centro y n - 1.
  def circulos(cx, cy, radio, n, reduccion, estilo, i) do
    actual = dibujar_circulo(cx, cy, radio, estilo, i)
    siguiente_radio = radio - reduccion

    actual <> circulos(cx, cy, siguiente_radio, n - 1, reduccion, estilo, i + 1)
  end

  # ---------------------------------------------------------------
  # Estilos (formas de mostrar la figura)
  # ---------------------------------------------------------------

  # Solo contornos
  defp dibujar_circulo(cx, cy, r, :lineas, _i) do
    """
      <circle cx="#{cx}" cy="#{cy}" r="#{r}" fill="none" stroke="#252525" stroke-width="2"/>
    """
  end

  # Relleno alternando dos colores (efecto diana)
  defp dibujar_circulo(cx, cy, r, :alternado, i) do
    color = if rem(i, 2) == 0, do: "#c67474", else: "#ffffff"

    """
      <circle cx="#{cx}" cy="#{cy}" r="#{r}" fill="#{color}" stroke="#252525" stroke-width="1.5"/>
    """
  end

  # Relleno con colores del arcoíris (el tono cambia con el índice)
  defp dibujar_circulo(cx, cy, r, :arcoiris, i) do
    tono = rem(i * 30, 360)

    """
      <circle cx="#{cx}" cy="#{cy}" r="#{r}" fill="hsl(#{tono}, 70%, 55%)" stroke="#ffffff" stroke-width="1"/>
    """
  end

  # ---------------------------------------------------------------
  # Generación del archivo
  # ---------------------------------------------------------------
  def generar(cantidad, reduccion, estilo \\ :lineas, archivo \\ "circulos.svg") do
    radio = @radio_inicial
    lado = 2 * (radio + @margen)
    centro = radio + @margen

    cuerpo = circulos(centro, centro, radio, cantidad, reduccion, estilo, 0)

    svg = """
    <svg xmlns="http://www.w3.org/2000/svg"
         width="#{lado}" height="#{lado}"
         viewBox="0 0 #{lado} #{lado}">
      <rect width="100%" height="100%" fill="white"/>
    #{cuerpo}</svg>
    """

    File.write!(archivo, svg)
    IO.puts("Imagen creada: #{archivo} (#{cantidad} círculos, reducción #{reduccion}, estilo #{estilo})")
  end

  # ---------------------------------------------------------------
  # Entrada del usuario
  # ---------------------------------------------------------------
  def main(args) do
    case args do
      [c, r, e] ->
        generar(a_numero(c, 10), a_numero(r, 15), a_estilo(e))

      [c, r] ->
        generar(a_numero(c, 10), a_numero(r, 15))

      _ ->
        c = IO.gets("Cantidad de círculos [10]: ") |> a_numero(10)
        r = IO.gets("Reducción del radio [15]: ") |> a_numero(15)
        e = IO.gets("Estilo (lineas/alternado/arcoiris) [lineas]: ") |> a_estilo()
        generar(c, r, e)
    end
  end

  defp a_numero(texto, defecto) do
    case texto |> to_string() |> String.trim() |> Float.parse() do
      {n, _} when n > 0 -> if n == trunc(n), do: trunc(n), else: n
      _ -> defecto
    end
  end

  defp a_estilo(texto) do
    case texto |> to_string() |> String.trim() do
      "alternado" -> :alternado
      "arcoiris" -> :arcoiris
      _ -> :lineas
    end
  end
end

Circulos.main(System.argv())

