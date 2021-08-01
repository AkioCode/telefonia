defmodule Chamada do
  @moduledoc """
  Módulo de chamada
  """
  defstruct data: nil, duracao: nil

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
