defmodule Assinante do
  @moduledoc false
  defstruct nome: nil, numero: nil, cpf: nil, plano: nil

  @assinantes %{
    pre_pago: "pre.txt",
    pos_pago: "pos.txt"
  }

  def assinantes_pre, do: ler("pre.txt")
  def assinantes_pos, do: ler("pos.txt")

  def assinantes, do: ler("pre.txt") ++ ler("pos.txt")

  defp filtro(lista, numero), do: Enum.find(lista, false, &(&1.numero == numero))

  def buscar(numero, :pre_pago), do: filtro(assinantes_pre(), numero)
  def buscar(numero, :pos_pago), do: filtro(assinantes_pos(), numero)
  def buscar(numero), do: filtro(assinantes(), numero)

  def cadastrar(nome, numero, cpf, plano \\ :pre_pago) do
    case buscar(numero) do
      false ->
        [%__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano} | ler(@assinantes[plano]) ]
        |> :erlang.term_to_binary()
        |> escrever(@assinantes[plano])

        {:ok, "Assinante (#{numero} - #{Atom.to_string(plano)}) cadastrado com sucesso"}

      _assinante ->
        {:error, "Já existe assinante com este número"}
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
