defmodule Assinante do
  @moduledoc """
  Módulo de assinante para cadastrar assinantes por tipos: "pre_pago" ou "pos_pago" (Ver `cadastrar/4`).
  Busca assinante pelo número (`buscar/1`) e adicionalmente por plano (`buscar/2`). Exibe lista de todos assinantes
  e assinantes por plano.

  Nota: é necessário executar `Telefonia.iniciar/0` antes de efetivar qualquer operação neste módulo.
  """
  defstruct nome: nil, numero: nil, cpf: nil, plano: nil

  @assinantes %{
    pre_pago: "pre.txt",
    pos_pago: "pos.txt"
  }

  @spec assinantes_pre :: [%Assinante{}]
  @doc """
  Lista assinantes de plano pré-pago.

  ## Exemplos

      iex> Assinante.assinantes_pre()
      [%Assinante{}]
  """
  def assinantes_pre, do: ler("pre.txt")

  @spec assinantes_pos :: [%Assinante{}]
  @doc """
  Lista assinantes de plano pós-pago.

  ## Exemplos

      iex> Assinante.assinantes_pos()
      [%Assinante{}]
  """
  def assinantes_pos, do: ler("pos.txt")

  @spec assinantes :: [%Assinante{}]
  @doc """
  Lista assinantes.

  ## Exemplos

      iex> Assinante.assinantes()
      [%Assinante{}]
  """
  def assinantes, do: ler("pre.txt") ++ ler("pos.txt")

  defp filtro(lista, numero), do: Enum.find(lista, {:error, "Assinante não encontrado"}, &(&1.numero == numero))

  @spec buscar(binary(), :pos_pago | :pre_pago) :: {:error, binary()} | %Assinante{}

  @doc """
  Busca assinante pelo número, especificando o tipo de plano ou não.

  ## Parâmetros

  - numero (string): do número da pessoa.
  - plano (atom): opcional :pre_pago ou :pos_pago. Se não especificado, procurá em ambas fontes de dados.

  ## Exemplos

      iex> Assinante.buscar("123")
      %Assinante{}

      iex> Assinante.buscar("123", :pre_pago)
      %Assinante{}

      iex> Assinante.buscar("123", :pos_pago)
      %Assinante{}

      iex> Assinante.buscar("-1")
      {:error, "Assinante não encontrado"}
  """
  def buscar(numero, :pre_pago), do: filtro(assinantes_pre(), numero)
  def buscar(numero, :pos_pago), do: filtro(assinantes_pos(), numero)

  @spec buscar(binary()) :: false | %Assinante{}

  @doc """
  Busca assinante pelo número em todos planos.

  ## Parâmetros

  - numero (string): do número da pessoa.

  ## Exemplos

      iex> Assinante.buscar("123")
      %Assinante{}

      iex> Assinante.buscar("-1")
      {:error, "Assinante não encontrado"}
  """
  def buscar(numero), do: filtro(assinantes(), numero)

  @spec cadastrar(binary(), binary(), binary(), atom()) :: {:error, <<_::296>>} | {:ok, <<_::64, _::_*8>>}
  @doc """
  Cadastra assinante com número ainda não registrado nas fontes de dados.

  ## Parâmetros

  - nome (string): do nome da pessoa.
  - numero (string): do número da pessoa.
  - cpf (string): de 11 dígitos do CPF da pessoa.
  - plano (atom): opcional, pode ser :pre_pago ou :pos_pago, por padrão :pre_pago.

  ## Exemplos

      iex> Assinante.cadastrar("Rodrigo", "123", "12345678910", :pre_pago)
      {:ok, "Assinante (123 - pre_pago) cadastrado com sucesso"}

      iex> Assinante.cadastrar("Rodrigo", "123", "12345678910", :pos_pago)
      {:error, "Já existe assinante com este número"}

      iex> Assinante.cadastrar("Rodrigo", "1234", "12345678910", :pre_pago)
      {:ok, "Assinante (1234 - pre_pago) cadastrado com sucesso"}
  """
  def cadastrar(nome, numero, cpf, plano \\ :pre_pago) do
    case buscar(numero) do
      {:error, _message} ->
        [%__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano} | ler(@assinantes[plano]) ]
        |> :erlang.term_to_binary()
        |> escrever(@assinantes[plano])

        {:ok, "Assinante (#{numero} - #{Atom.to_string(plano)}) cadastrado com sucesso"}

      _assinante ->
        {:error, "Já existe assinante com este número"}
    end
  end

  defp escrever(lista_assinantes, arquivo_plano) do
    File.write!(arquivo_plano, lista_assinantes)
  end

  defp ler(arquivo_plano) do
    File.read!(arquivo_plano)
    |> :erlang.binary_to_term
  end

  def excluir(numero) do

  end
end
