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
end
