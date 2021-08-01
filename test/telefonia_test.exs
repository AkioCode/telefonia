defmodule TelefoniaTest do
  @moduledoc false
  use ExUnit.Case
  doctest Telefonia

  setup_all do
    Telefonia.iniciar()

    Telefonia.cadastrar_assinante("Rodrigo", "121", "123", :pre_pago)
    Telefonia.cadastrar_assinante("Rodrigo", "122", "123", :pre_pago)
    Telefonia.cadastrar_assinante("Rodrigo", "123", "123", :pos_pago)
    Telefonia.cadastrar_assinante("Rodrigo", "124", "123", :pos_pago)

    on_exit(fn ->
      File.rm!("pos.txt")
      File.rm!("pre.txt")
    end)
  end

  test "cadastrar assinante" do
    assert {:ok, _message} = Telefonia.cadastrar_assinante("Rodrigo", "120", "123", :pre_pago)
  end

  test "listar assinantes pré-pagos" do
    assert Telefonia.listar_assinantes_pre() == Assinante.assinantes_pre()
  end

  test "listar assinantes pós-pagos" do
    assert Telefonia.listar_assinantes_pos() == Assinante.assinantes_pos()
  end

  test "listar assinantes" do
    assert Telefonia.listar_assinantes() == Assinante.assinantes()
  end

  test "buscar assinante" do
    assert Telefonia.buscar_assinante("121") == Assinante.buscar("121")
  end

  test "buscar assinante pré-pago" do
    assert Telefonia.buscar_assinante("121", :pre_pago) == Assinante.buscar("121", :pre_pago)
  end

  test "buscar assinante pós-pago" do
    assert Telefonia.buscar_assinante("123", :pos_pago) == Assinante.buscar("123", :pos_pago)
  end

  test "ligar" do
    numero_pre_pago = "121"
    numero_pos_pago = "123"
    data = DateTime.utc_now()
    duracao = 2

    Telefonia.ligar(numero_pre_pago, data, duracao)
    Telefonia.ligar(numero_pos_pago, data, duracao)

    assinante_pre = Telefonia.buscar_assinante("121", :pre_pago)
    assinante_pos = Telefonia.buscar_assinante("123", :pos_pago)

    assert %Assinante{
      numero: "121",
      nome: "Rodrigo",
      cpf: "123",
      plano: %Prepago{
        saldo: 7.1,
        recargas: []
        },
      chamadas: [%Chamada{data: data, duracao: 2}]} = assinante_pre

    assert %Assinante{
      numero: "123",
      nome: "Rodrigo",
      cpf: "123",
      plano: %Pospago{
        custo: 2.8
        },
      chamadas: [%Chamada{data: data, duracao: 2}]} = assinante_pos

  end

  test "recarregar créditos" do
    numero = "120"
    creditos = 30
    data = DateTime.utc_now()

    assert Telefonia.recarregar_creditos(data, creditos, numero) == Recarga.registrar(data, creditos, numero)
  end

  test "pagar fatura" do
    numero_pos = "124"

    assert Telefonia.pagar_fatura(numero_pos) == Pospago.pagar_fatura(numero_pos)
  end

  test "gerar extrato" do
    data = DateTime.utc_now()
    data_dias_mes = Date.days_in_month(data)
    data_antes = DateTime.add(data, -86_400 * data_dias_mes, :second)
    data_depois = DateTime.add(data, 86_400 * data_dias_mes, :second)
    numero_pre = "122"
    numero_pos = "124"

    Telefonia.ligar(numero_pre, data, 1)
    Telefonia.ligar(numero_pre, data, 3)
    Telefonia.ligar(numero_pre, data, 2)

    Telefonia.ligar(numero_pos, data_antes, 12)
    Telefonia.pagar_fatura(numero_pos)
    Telefonia.ligar(numero_pos, data, 5)
    Telefonia.ligar(numero_pos, data, 10)
    Telefonia.ligar(numero_pos, data, 15)
    Telefonia.pagar_fatura(numero_pos)
    Telefonia.ligar(numero_pos, data_depois, 17)

    {:ok, extrato_pre} = Prepago.gerar_extrato(data, numero_pre)
    chamadas_pre =
      extrato_pre.chamadas
      |> Enum.map_join(",\n ", &("Duração: #{&1.duracao}, Data: #{DateTime.to_iso8601(&1.data)}"))
    recargas =
      extrato_pre.plano.recargas
      |> Enum.map_join(",\n ", &("Créditos: #{&1.creditos}, Data: #{DateTime.to_iso8601(&1.data)}"))

    assert Telefonia.gerar_extrato(data, numero_pre) ==
      """
      #############################################
      Assinatura pré-paga
      Nome: #{extrato_pre.nome}
      Número: #{extrato_pre.numero}
      Total de chamadas: #{Enum.count(extrato_pre.chamadas)}
      Chamadas: #{chamadas_pre}
      Total de recargas: #{Enum.count(extrato_pre.plano.recargas)}
      Recargas: #{recargas}
      #############################################
      """

    {:ok, extrato_pos} = Pospago.gerar_extrato(data, numero_pos)
    chamadas_pos =
      extrato_pos.chamadas
      |> Enum.map_join(",\n ", &("Duração: #{&1.duracao}, Data: #{DateTime.to_iso8601(&1.data)}"))

    assert Telefonia.gerar_extrato(data, numero_pos) ==
      """
      #############################################
      Assinatura pós-paga
      Nome: #{extrato_pos.nome}
      Número: #{extrato_pos.numero}
      Total de chamadas: #{Enum.count(extrato_pos.chamadas)}
      Chamadas: #{chamadas_pos}
      #############################################
      """

  end
end
