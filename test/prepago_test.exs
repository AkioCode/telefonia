defmodule PrepagoTest do
  @moduledoc false
  use ExUnit.Case

  setup_all do
    Telefonia.iniciar()
    Assinante.cadastrar("Rodrigo", "121", "123", :pre_pago)
    Assinante.cadastrar("Rodrigo", "122", "123", :pre_pago)
    Assinante.cadastrar("Rodrigo", "123", "123", :pre_pago)

    assinantes = Assinante.assinantes_pre()

    on_exit(fn ->
      File.rm!("pos.txt")
      File.rm!("pre.txt")
    end)

    %{assinantes: assinantes}
  end

  test "estrutura Prepago" do
    assert %Prepago{saldo: 10, recargas: []}.saldo == 10
  end

  describe "ligação" do
    test "com saldo suficiente", %{assinantes: assinantes} do
      assinante = Enum.at(assinantes, 0)
      assert Prepago.ligar(assinante.numero, DateTime.utc_now(), 3) ==
               {:ok, "Custo da chamada: 4.35. Saldo atual: 5.65"}
    end

    test "sem saldo suficiente", %{assinantes: assinantes} do
      assinante = Enum.at(assinantes, 0)
      assert Prepago.ligar(assinante.numero, DateTime.utc_now(), 11) ==
               {:error, "Você não tem saldo suficiente, que pena! 😈"}
    end

    test "com número inexistente" do
      assert Prepago.ligar("-1", DateTime.utc_now(), 11) ==
               {:error, "Assinante não encontrado"}
    end
  end

  describe "impressão de contas " do
    test "válida", %{assinantes: assinantes} do
      fst_data = DateTime.utc_now()
      assinante_1 = Enum.at(assinantes, 1)
      Recarga.registrar(fst_data, 10, assinante_1.numero)
      Prepago.ligar(assinante_1.numero, fst_data, 1)
      days_in_month = Date.days_in_month(fst_data)
      {:ok, assinante_1_extrato} = Prepago.gerar_extrato(fst_data, assinante_1.numero)

      assert assinante_1_extrato.numero == assinante_1.numero
      assert Enum.count(assinante_1_extrato.chamadas) == 1
      assert Enum.count(assinante_1_extrato.plano.recargas) == 1
      assert assinante_1_extrato.plano.saldo == 10

      scd_data = DateTime.add(fst_data, 86_400 * days_in_month, :second)
      assinante_2 = Enum.at(assinantes, 1)
      Recarga.registrar(scd_data, 20, assinante_2.numero)
      Prepago.ligar(assinante_2.numero, scd_data, 3)
      Prepago.ligar(assinante_2.numero, scd_data, 6)

      {:ok, assinante_2_extrato} = Prepago.gerar_extrato(scd_data, assinante_2.numero)

      assert assinante_2_extrato.numero == assinante_2.numero
      assert Enum.count(assinante_2_extrato.chamadas) == 2
      assert Enum.count(assinante_2_extrato.plano.recargas) == 1
      assert assinante_2_extrato.plano.saldo == 20
    end
  end
end
