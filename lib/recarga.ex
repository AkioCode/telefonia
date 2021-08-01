defmodule Recarga do
  @moduledoc """
  Módulo de recarga
  """

  defstruct data: nil, creditos: nil

  @spec registrar(binary, number, binary) :: {:error, binary} | {:ok, binary}
  @doc """
  Registra recarga de créditos de número

  ## Parâmetros

  - data (string): data da recarga.
  - creditos (string): quantidade de créditos da recarga.
  - numero (string): número da recarga.

  ## Exemplos

      iex> Recarga.registrar("2021-08-01 03:55:39.818360Z", "30", "12345678910")
      {:ok, "(2021-08-01 03:55:39.818360Z) Recarga de 30 crédito(s) para 12345678910"}

      iex> Recarga.registrar("2021-08-01 03:55:39.818360Z", "1234", "-1")
      {:error, "Assinante não encontrado"}

      iex> Recarga.registrar("2021-08-01 03:55:39.818360Z", "0", "12345678910")
      {:error, "Quantidade de créditos deve ser maior que 0"}
  """
  def registrar(data, creditos, numero) do
    if creditos <= 0 do
      {:error, "Quantidade de créditos deve ser maior que 0"}
    else
      with  %Assinante{} = assinante <- Assinante.buscar(numero, :pre_pago),
            plano = assinante.plano,
            plano_atualizado = %Prepago{plano | saldo: plano.saldo + creditos, recargas: [%__MODULE__{data: data, creditos: creditos} | plano.recargas]},
            {:ok, _message} <- Assinante.atualizar(numero, %{plano: plano_atualizado}) do

        {:ok, "(#{data}) Recarga de #{creditos} crédito(s) para #{numero}"}
      else
        {:error, message} ->
          {:error, message}
      end
    end
  end
end
