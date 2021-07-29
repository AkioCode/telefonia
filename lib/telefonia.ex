defmodule Telefonia do
  @moduledoc false
  def cadastrar_assinante(nome, numero, cpf) do
    Assinante.cadastrar(nome, numero, cpf)
  end
end
