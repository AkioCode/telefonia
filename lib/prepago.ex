defmodule Prepago do
  @moduledoc """
  Módulo de regras de negócio de assinaturas pré-pagas.
  """
  defstruct saldo: 10, recargas: []
  @preco_minuto 1.45

  def ligar(numero, data, duracao) do
    assinante = Assinante.buscar(numero, :pre_pago)
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

  defp calcular_custo(duracao), do: duracao * @preco_minuto

  defp descontar(saldo, custo), do: saldo - custo
end
