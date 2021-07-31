defmodule ChamadaTest do
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

  describe "registro de chamada " do
    test "válida", %{ass_pre: ass_pre} do
      horario = DateTime.utc_now()

      assert Chamada.registrar(ass_pre, horario, 3) ==
               {:ok, "Número: #{ass_pre.numero} | Data/Hora: #{horario} | Duração: 3"}
    end
  end
end
