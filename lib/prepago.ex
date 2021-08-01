defmodule Prepago do
  @moduledoc """
  Módulo de regras de negócio de assinaturas pré-pagas.
  """
  defstruct saldo: 10, recargas: []
  @preco_minuto 1.45

  @spec ligar(binary, binary, integer) :: {:error, binary} | {:ok, binary}
  @doc """
  Efetua ligação por assinatura pré-paga

  ## Parâmetros

  - numero (string): número da assinante.
  - data (string): data da ligação.
  - duracao (integer): duração da chamada.

  ## Exemplos

      iex> Prepago.ligar("123", "2021-04-04T13:21:21", 2)
      {:ok, "Custo da chamada: 2.90. Saldo atual: 7.10"}

      iex> Prepago.ligar("123", "2021-04-04T13:21:21", 40)
      {:error, "Você não tem saldo suficiente, que pena! 😈"}

      iex> Prepago.ligar("-1", "2021-04-04T13:21:21", 2)
      {:error, "Assinante não encontrado"}
  """
  def ligar(numero, data, duracao) do
    with %Assinante{} = assinante <- Assinante.buscar(numero, :pre_pago) do
      custo = calcular_custo(duracao)
      saldo_descontado = descontar(assinante.plano.saldo, custo)

      cond do
        saldo_descontado >= 0 ->
          plano = assinante.plano
          plano = %__MODULE__{plano | saldo: saldo_descontado}
          assinante = %Assinante{assinante | plano: plano}
          Chamada.registrar(assinante, data, duracao)

          {:ok, "Custo da chamada: #{custo}. Saldo atual: #{assinante.plano.saldo}"}
        true ->
          {:error, "Você não tem saldo suficiente, que pena! 😈"}
      end
    end
  end

  defp calcular_custo(duracao), do: duracao * @preco_minuto

  defp descontar(saldo, custo), do: saldo - custo

  @spec gerar_extrato(binary, binary) ::
          {:error, binary}
          | {:ok, %Assinante{chamadas: list, cpf: binary, nome: binary, numero: binary, plano: %Prepago{}}}
  @doc """
  Gera extrato do mês de assinatura pré-paga

  ## Parâmetros

  - data (string): data da ligação.
  - numero (string): número da assinante.

  ## Exemplos

      iex> Prepago.gerar_extrato("2021-04-04T13:21:21", "123")
      {:ok, %Assinante{chamadas: [], cpf: "123", nome: "Nome", numero: "123", plano: %Prepago{creditos: 10, recargas: []}}}

      iex> Prepago.gerar_extrato("2021-04-04T13:21:21", "-1")
      {:error, "Assinante não encontrado"}
  """
  def gerar_extrato(data, numero) do
    with %Assinante{} = assinante <- Assinante.buscar(numero, :pre_pago) do
      mes = data.month
      ano = data.year

      recargas_mes = filtrar_mes_ano(assinante.plano.recargas, mes, ano)
      chamadas_mes = filtrar_mes_ano(assinante.chamadas, mes, ano)
      creditos_total = Enum.reduce(recargas_mes, 0, fn r, acc -> acc + r.creditos end)
      assinante_extrato = %Assinante{assinante | plano: %Prepago{recargas: recargas_mes, saldo: creditos_total}, chamadas: chamadas_mes}

      {:ok, assinante_extrato}
    end
  end

  defp filtrar_mes_ano(lista, mes, ano), do: Enum.filter(lista, &(&1.data.month == mes and &1.data.year == ano))
end
