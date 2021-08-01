defmodule Chamada do
  @moduledoc """
  Módulo de chamada
  """
  defstruct data: nil, duracao: nil

  @spec registrar(%Assinante{}, binary, integer) ::
          {:error, any} | {:ok, binary}
  @doc """
  Registra chamada

  ## Parâmetros

  - assinante (%Assinante{}): assinante da chamada.
  - data (string): data da chamada.
  - duracao (integer): duração da chamada.

  ## Exemplos

      iex> Chamada.registrar(%Assinante{nome: "Fulano", cpf: "123", numero: "123", plano: %Prepago{creditos: 10, recargas: []}}, "2021-04-04T13:21:21", 10)
      {:ok, "Número: "123" | Data/Hora: "2021-04-04T13:21:21" | Duração: 10"}

      iex> Chamada.registrar(%Assinante{nome: "FulanoFake", cpf: "-123", numero: "-123", plano: %Prepago{creditos: 10, recargas: []}}, "2021-04-04T13:21:21", 10)
      {:error, "Assinante não encontrado"}
  """
  def registrar(assinante, data, duracao) do
    chamadas = assinante.chamadas ++ [%__MODULE__{data: data, duracao: duracao}]

    Assinante.atualizar(assinante.numero, %{assinante | chamadas: chamadas})
    |> case do
      {:ok, _message} ->
        {:ok, "Número: #{assinante.numero} | Data/Hora: #{data} | Duração: #{duracao}"}

      {:error, message} ->
        {:error, message}
    end
  end
end
