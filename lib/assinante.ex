defmodule Assinante do
  @moduledoc false
  defstruct nome: nil, numero: nil, cpf: nil

  def cadastrar(nome, numero, cpf) do
    [%__MODULE__{nome: nome, numero: numero, cpf: cpf} | ler() ]
    |> :erlang.term_to_binary()
    |> escrever()
  end

  defp escrever(lista_assinantes) do
    File.write!("assinantes.txt", lista_assinantes)
  end

  defp ler() do
    File.read!("assinantes.txt")
    |> :erlang.binary_to_term
  end
end
