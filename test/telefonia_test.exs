defmodule TelefoniaTest do
  @moduledoc false
  use ExUnit.Case
  doctest Telefonia

  setup_all do
    Telefonia.iniciar()

    on_exit(fn ->
      File.rm!("pos.txt")
      File.rm!("pre.txt")
    end)
  end

  test "cadastrar assinante" do
    assert {:ok, _message} = Telefonia.cadastrar_assinante("Rodrigo", "123", "123", :pre_pago)
  end
end
