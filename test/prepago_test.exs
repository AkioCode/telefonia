defmodule PrepagoTest do
  @moduledoc false
  use ExUnit.Case

  setup_all do
    Telefonia.iniciar()
    Assinante.cadastrar("Rodrigo", "123", "123", :pre_pago)
    Assinante.cadastrar("Rodrigo", "121", "123", :pos_pago)

    ass_pre = Assinante.buscar("123")
    ass_pos = Assinante.buscar("121")

    on_exit(fn ->
      File.rm!("pos.txt")
      File.rm!("pre.txt")
    end)

    %{ass_pre: ass_pre, ass_pos: ass_pos}
  end

  describe "ligação " do
    test "com saldo suficiente" do
      assert Prepago.ligar("123", DateTime.utc_now(), 3) ==
               {:ok, "Custo da chamada: 4.35. Saldo atual: 5.65"}
    end

    test "sem saldo suficiente" do
      assert Prepago.ligar("123", DateTime.utc_now(), 11) ==
               {:error, "Você não tem saldo suficiente, que pena! 😈"}
    end
  end
end
