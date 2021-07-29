defmodule Assinante do
  @moduledoc false
  defstruct nome: nil, numero: nil, cpf: nil, plano: nil

  @assinantes %{
    pre_pago: "pre.txt",
    pos_pago: "pos.txt"
  }

  defp buscar(numero, plano) do
    ler("pre.txt") ++ ler("pos.txt")
    |> Enum.find_value(false, fn assinante -> assinante.numero == numero end)
  end

  def cadastrar(nome, numero, cpf, plano \\ :pre_pago) do
    case buscar(numero, plano) do
      true ->
        {:error, "Já existe assinante com esse número"}

      false ->
        [%__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano} | ler(@assinantes[plano]) ]
        |> :erlang.term_to_binary()
        |> escrever(@assinantes[plano])

        {:ok, "Assinante (#{numero} - #{Atom.to_string(plano)}) cadastrado com sucesso"}
    end
  end

  defp escrever(lista_assinantes, arquivo_plano) do
    File.write!(arquivo_plano, lista_assinantes)
  end

  defp ler(arquivo_plano) do
    File.read!(arquivo_plano)
    |> :erlang.binary_to_term
  end
end
