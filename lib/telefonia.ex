defmodule Telefonia do
  @moduledoc """
  Módulo de telefonia.
  """
  def iniciar do
    File.write!("pre.txt", :erlang.term_to_binary([]))
    File.write!("pos.txt", :erlang.term_to_binary([]))
  end

  @spec cadastrar_assinante(binary, binary, binary, atom) ::
          {:error, <<_::296>>} | {:ok, <<_::64, _::_*8>>}
  def cadastrar_assinante(nome, numero, cpf, plano) do
    Assinante.cadastrar(nome, numero, cpf, plano)
  end

  def listar_assinantes, do: Assinante.assinantes()

  def listar_assinantes_pre, do: Assinante.assinantes_pre()

  def listar_assinantes_pos, do: Assinante.assinantes_pos()

  def buscar_assinante(numero), do: Assinante.buscar(numero)

  def buscar_assinante(numero, :pre_pago), do: Assinante.buscar(numero, :pre_pago)

  def buscar_assinante(numero, :pos_pago), do: Assinante.buscar(numero, :pos_pago)

  def ligar(numero, data, duracao) do
    with %Assinante{} = assinante <- buscar_assinante(numero) do
      case assinante.plano.__struct__ do
        Prepago -> Prepago.ligar(numero, data, duracao)
        Pospago -> Pospago.ligar(numero, data, duracao)
      end
    end
  end

  def recarregar_creditos(data, creditos, numero), do: Recarga.registrar(data, creditos, numero)

  def pagar_fatura(numero), do: Pospago.pagar_fatura(numero)

  def gerar_extrato(data, numero) do
    with %Assinante{} = assinante <- buscar_assinante(numero) do
      case assinante.plano.__struct__ do
        Prepago ->
          {:ok, extrato} = Prepago.gerar_extrato(data, numero)
          chamadas =
            extrato.chamadas
            |> Enum.map_join(",\n ", &("Duração: #{&1.duracao}, Data: #{DateTime.to_iso8601(&1.data)}"))
            recargas =
              extrato.plano.recargas
              |> Enum.map_join(",\n ", &("Créditos: #{&1.creditos}, Data: #{DateTime.to_iso8601(&1.data)}"))

          """
          #############################################
          Assinatura pré-paga
          Nome: #{assinante.nome}
          Número: #{numero}
          Total de chamadas: #{Enum.count(extrato.chamadas)}
          Chamadas: #{chamadas}
          Total de recargas: #{Enum.count(extrato.plano.recargas)}
          Recargas: #{recargas}
          #############################################
          """

        Pospago ->
          {:ok, extrato} = Pospago.gerar_extrato(data, numero)
          chamadas =
            extrato.chamadas
            |> Enum.map_join(",\n ", &("Duração: #{&1.duracao}, Data: #{DateTime.to_iso8601(&1.data)}"))

          """
          #############################################
          Assinatura pós-paga
          Nome: #{assinante.nome}
          Número: #{numero}
          Total de chamadas: #{Enum.count(extrato.chamadas)}
          Chamadas: #{chamadas}
          #############################################
          """
      end
    end
  end
end
