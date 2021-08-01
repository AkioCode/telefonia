defmodule Pospago do
  @moduledoc """
  Módulo de regras de negócio de assinaturas pós-pagas.
  """
  defstruct custo: 0

  @custo_minuto 1.40

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

      assinante_atualizado = %Assinante{assinante | plano: %Pospago{custo: custo}}

      Assinante.atualizar(assinante.numero, assinante_atualizado)

      {:ok, assinante_atualizado}
    end
  end

  defp filtrar_mes_ano(lista, mes, ano), do: Enum.filter(lista, &(&1.data.month == mes and &1.data.year == ano))
end
