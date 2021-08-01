defmodule PospagoTest do
  @moduledoc false
  use ExUnit.Case

  setup_all do
    Telefonia.iniciar()
    Assinante.cadastrar("Rodrigo", "121", "123", :pos_pago)
    Assinante.cadastrar("Rodrigo", "122", "123", :pos_pago)
    Assinante.cadastrar("Rodrigo", "123", "123", :pos_pago)
    Assinante.cadastrar("Rodrigo", "124", "123", :pos_pago)
    assinante_4 = Assinante.buscar("124", :pos_pago)
    Assinante.atualizar("124", %{assinante_4 | plano: %Pospago{custo: 10}})

    on_exit(fn ->
      File.rm!("pos.txt")
      File.rm!("pre.txt")
    end)
  end

  test "estrutura Pospago" do
    assert %Pospago{custo: 10}.custo == 10
  end

  describe "ligação" do
    test "válida" do
      assinante = Assinante.buscar("121", :pos_pago)
      assert Pospago.ligar(assinante.numero, DateTime.utc_now(), 5) ==
               {:ok, "Duração da chamada: 5 minutos"}
    end

    test "com assinante inadimplente" do
      assinante = Assinante.buscar("124", :pos_pago)
      assert Pospago.ligar(assinante.numero, DateTime.utc_now(), 5) == {:error, "Assinante deve pagar fatura do mês anterior"}
    end

    test "com número inexistente" do
      assert Pospago.ligar("-1", DateTime.utc_now(), 11) ==
               {:error, "Assinante não encontrado"}
    end
  end

  describe "impressão de contas " do
    test "válida" do
      fst_data = DateTime.utc_now()
      assinante_1 = Assinante.buscar("122", :pos_pago)
      Pospago.ligar(assinante_1.numero, fst_data, 1)
      days_in_month = Date.days_in_month(fst_data)
      {:ok, assinante_1_extrato} = Pospago.gerar_extrato(fst_data, assinante_1.numero)

      assert assinante_1_extrato.numero == assinante_1.numero
      assert assinante_1_extrato.plano.custo == 1.40
      assert Enum.count(assinante_1_extrato.chamadas) == 1

      scd_data = DateTime.add(fst_data, 86_400 * days_in_month, :second)
      assinante_2 = Assinante.buscar("123", :pos_pago)
      Pospago.ligar(assinante_2.numero, scd_data, 3)
      Pospago.ligar(assinante_2.numero, scd_data, 6)

      {:ok, assinante_2_extrato} = Pospago.gerar_extrato(scd_data, assinante_2.numero)

      assert assinante_2_extrato.numero == assinante_2.numero
      assert assinante_2_extrato.plano.custo == (3 + 6) * 1.40
      assert Enum.count(assinante_2_extrato.chamadas) == 2
    end
  end
end
