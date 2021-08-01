defmodule Pospago do
  @moduledoc """
  Módulo de regras de negócio de assinaturas pós-pagas.
  """
  defstruct custo: 0

  @custo_minuto 1.40

  @spec ligar(binary, any, any) :: {:error, binary} | {:ok, <<_::64, _::_*8>>}
  @doc """
  Efetua ligação por assinatura pós-paga

  ## Parâmetros

  - numero (string): número da assinante.
  - data (string): data da ligação.
  - duracao (integer): duração da chamada.

  ## Exemplos

      iex> Pospago.ligar("123", "2021-04-04T13:21:21", 2)
      {:ok, "Duração da chamada: 2 minutos"}

      iex> Pospago.ligar("123", "2021-05-04T13:21:21", 2)
      {:error, "Assinante deve pagar fatura do mês anterior"}

      iex> Pospago.ligar("-1", "2021-04-04T13:21:21", 2)
      {:error, "Assinante não encontrado"}
  """
  def ligar(numero, data, duracao) do
    with %Assinante{} = assinante <- Assinante.buscar(numero, :pos_pago),
          :ok <- em_divida?(assinante, data) do
      plano_atualizado = %Pospago{custo: assinante.plano.custo + duracao * @custo_minuto}
      assinante_atualizado = %Assinante{assinante | plano: plano_atualizado}

      Chamada.registrar(assinante_atualizado, data, duracao)

      {:ok, "Duração da chamada: #{duracao} minutos"}
    end
  end

  defp em_divida?(assinante, data) do
    chamadas_mes = filtrar_mes_ano(assinante.chamadas, data.month, data.year)
    if Enum.empty?(chamadas_mes) and assinante.plano.custo != 0 do
      {:error, "Assinante deve pagar fatura do mês anterior"}
    else
      :ok
    end
  end

  @spec gerar_extrato(binary, binary) ::
          {:error, binary}
          | {:ok, %Assinante{chamadas: list, cpf: any, nome: any, numero: any, plano: %Pospago{}}}
  @doc """
  Gera extrato do mês de assinatura pré-paga

  ## Parâmetros

  - data (string): data da ligação.
  - numero (string): número da assinante.

  ## Exemplos

      iex> Pospago.gerar_extrato("2021-04-04T13:21:21", "123")
      {:ok, %Assinante{chamadas: [], cpf: "123", nome: "Nome", numero: "123", plano: %Pospago{custo: 10}}

      iex> Pospago.gerar_extrato("2021-04-04T13:21:21", "-1")
      {:error, "Assinante não encontrado"}
  """
  def gerar_extrato(data, numero) do
    mes = data.month
    ano = data.year
    with %Assinante{} = assinante <- Assinante.buscar(numero, :pos_pago) do
      chamadas_mes = filtrar_mes_ano(assinante.chamadas, mes, ano)
      custo =
        chamadas_mes
        |> Enum.map(&(&1.duracao))
        |> Enum.sum()
        |> Kernel.*(@custo_minuto)

      assinante_atualizado = %Assinante{assinante | plano: %Pospago{custo: custo}, chamadas: chamadas_mes}

      {:ok, assinante_atualizado}
    end
  end

  defp filtrar_mes_ano(lista, mes, ano), do: Enum.filter(lista, &(&1.data.month == mes and &1.data.year == ano))

  @spec pagar_fatura(binary) :: {:error, binary} | {:ok, <<_::184>>}
  @doc """
  Paga fatura corrente

  ## Parâmetros

  - numero (string): número da assinante.

  ## Exemplos

      iex> Pospago.pagar_fatura("12345678910")
      {:ok, "Fatura paga com sucesso"}

      iex> Pospago.pagar_fatura("-1")
      {:error, "Assinante não encontrado"}
  """
  def pagar_fatura(numero) do
    with %Assinante{} = assinante <- Assinante.buscar(numero, :pos_pago) do
      assinante_atualizado = %Assinante{assinante | plano: %Pospago{custo: 0}}

      Assinante.atualizar(assinante.numero, assinante_atualizado)

      {:ok, "Fatura paga com sucesso"}
    end
  end
end
