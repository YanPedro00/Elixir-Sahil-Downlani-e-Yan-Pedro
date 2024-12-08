#Alunos: Sahil Dowlani, Yan Pedro
defmodule FrequenciaPalavras do
  def ler_arquivos(caminhos_arquivos) do
    caminhos_arquivos
    |> Enum.map(&File.read!/1)
    |> Enum.join(" ")
  end

  def dividir_texto(texto, partes) do
    palavras = String.split(texto, ~r/\W+/)
    Enum.chunk_every(palavras, div(length(palavras), partes), div(length(palavras), partes), [])
  end

  def contar_palavras(palavras) do
    Enum.reduce(palavras, %{}, fn palavra, acumulador ->
      palavra = String.downcase(palavra)
      Map.update(acumulador, palavra, 1, &(&1 + 1))
    end)
  end

  def combinar_contagens(contagens_parciais) do
    Enum.reduce(contagens_parciais, %{}, fn mapa, acumulador ->
      Map.merge(acumulador, mapa, fn _chave, valor1, valor2 -> valor1 + valor2 end)
    end)
  end

  def contagem_concorrente(texto, num_processos) do
    texto
    |> dividir_texto(num_processos)
    |> Enum.map(fn parte ->
      Task.async(fn -> contar_palavras(parte) end)
    end)
    |> Enum.map(&Task.await/1)
    |> combinar_contagens()
  end

  def filtrar_e_ordenar(contagens, frequencia_minima) do
    contagens
    |> Enum.filter(fn {_palavra, contagem} -> contagem >= frequencia_minima end)
    |> Enum.sort_by(fn {_palavra, contagem} -> -contagem end)
  end

  def executar(caminhos_arquivos, num_processos, frequencia_minima) do
    caminhos_arquivos
    |> ler_arquivos()
    |> contagem_concorrente(num_processos)
    |> filtrar_e_ordenar(frequencia_minima)
  end
end

defmodule Script do
  def main do

    args = System.argv()

    case args do
      [frequencia_minima | arquivos] when arquivos != [] ->
        frequencia_minima = String.to_integer(frequencia_minima)
        num_processos = 4

        resultado = FrequenciaPalavras.executar(arquivos, num_processos, frequencia_minima)
        IO.inspect(resultado)

      _ ->
        IO.puts("Uso: elixir script.exs <frequencia_minima> <arquivos...>")
    end
  end
end

Script.main()

