defmodule Assinante do
  @moduledoc false
  defstruct nome: nil, numero: nil, cpf: nil, plano: nil

  @assinantes %{
    pre_pago: "pre.txt",
    pos_pago: "pos.txt"
  }

  def cadastrar(nome, numero, cpf, plano \\ :pre_pago) do
    [%__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano} | ler(@assinantes[plano]) ]
    |> :erlang.term_to_binary()
    |> escrever(@assinantes[plano])
  end

  defp escrever(lista_assinantes, arquivo_plano) do
    File.write!(arquivo_plano, lista_assinantes)
  end

  defp ler(arquivo_plano) do
    File.read!(arquivo_plano)
    |> :erlang.binary_to_term
  end
end
