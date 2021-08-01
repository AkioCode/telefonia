defmodule RecargaTest do
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

  test "estrutura Recarga" do
    assert %Recarga{data: DateTime.utc_now(), creditos: 10}.creditos == 10
  end

  describe "registro de recarga " do
    test "válida", %{ass_pre: ass_pre} do
      horario = DateTime.utc_now()

      assert Recarga.registrar(horario, 30, ass_pre.numero) ==
               {:ok, "(#{horario}) Recarga de 30 crédito(s) para #{ass_pre.numero}"}
    end

    test "com créditos inválidos", %{ass_pre: ass_pre} do
      horario = DateTime.utc_now()

      assert Recarga.registrar(horario, -1, ass_pre.numero) ==
               {:error, "Quantidade de créditos deve ser maior que 0"}
    end

    test "sem usuário existente" do
      horario = DateTime.utc_now()

      assert Recarga.registrar(horario, 30, -1) ==
               {:error, "Assinante não encontrado"}
    end
  end
end
