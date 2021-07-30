defmodule AssinanteTest do
  @moduledoc false
  use ExUnit.Case
  doctest Assinante

  setup_all do
    Telefonia.iniciar()
    Assinante.cadastrar("Rodrigo", "123", "123")
    Assinante.cadastrar("Rodrigo", "121", "123", :pos_pago)

    ass_pre = Assinante.buscar("123")
    ass_pos = Assinante.buscar("121")

    on_exit(fn ->
      File.rm!("pos.txt")
      File.rm!("pre.txt")
    end)

    %{ass_pre: ass_pre, ass_pos: ass_pos}
  end

  describe "estrutura " do
    test "@assinantes" do
      assert %Assinante{nome: "teste", numero: "teste", cpf: "nil", plano: :pre_pago}.nome == "teste"
    end
  end

  describe "cadastro " do
    test "válido conta pre-paga" do
      message = "Assinante (1234 - pre_pago) cadastrado com sucesso"
      assert Assinante.cadastrar("Rodrigo", "1234", "123") == {:ok, message}
    end

    test "valido conta pos-paga" do
      message = "Assinante (1214 - pos_pago) cadastrado com sucesso"
      assert Assinante.cadastrar("Rodrigo", "1214", "121", :pos_pago) == {:ok, message}
    end

    test "inválido número existente" do
      assert Assinante.cadastrar("Rodrigo", "121", "121") == {:error, "Já existe assinante com este número"}
    end
  end

  describe "ler " do
    test "assinantes pré-pago" do
      pre = File.read!("pre.txt") |> :erlang.binary_to_term()
      assert pre == Assinante.assinantes_pre()
    end

    test "assinantes pos-pago" do
      pos = File.read!("pos.txt") |> :erlang.binary_to_term()
      assert pos == Assinante.assinantes_pos()
    end

    test "todos assinantes" do
      pos = File.read!("pos.txt") |> :erlang.binary_to_term()
      pre = File.read!("pre.txt") |> :erlang.binary_to_term()
      all = pre ++ pos
      assert all == Assinante.assinantes()
    end
  end

  describe "buscar número " do
    test "pré-pago", %{ass_pre: ass} do
      assert ass == Assinante.buscar(ass.numero, :pre_pago)
    end
    test "pos-pago", %{ass_pos: ass} do
      assert ass == Assinante.buscar(ass.numero, :pos_pago)
    end
    test "geral", %{ass_pos: ass} do
      assert ass == Assinante.buscar(ass.numero)
    end
    test "inexistente" do
      assert false == Assinante.buscar("-1")
    end
  end

  describe "excluir assinante " do
    test "com sucesso" do
      assinante = Assinante.cadastrar("Excluido", "123321", "123")
      mensagem = "Assinante (#{assinante.numero}) excluído com sucesso"
      assert Assinante.excluir(assinante.numero) == {:ok, mensagem}
    end

    test "com falha" do
      assert Assinante.excluir("-1") == {:error, "Assinante não encontrado"}
    end
  end
end
