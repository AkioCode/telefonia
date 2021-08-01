defmodule Telefonia do
  @moduledoc """
  Módulo de telefonia.
  """
  @doc """
  Cria arquivos para armazenamento de assinaturas pré-pagas e pós-pagas
  """
  def iniciar do
    File.write!("pre.txt", :erlang.term_to_binary([]))
    File.write!("pos.txt", :erlang.term_to_binary([]))
  end

  @spec cadastrar_assinante(binary, binary, binary, atom) ::
          {:error, <<_::296>>} | {:ok, <<_::64, _::_*8>>}
  @doc """
  Cadastra assinante em um plano

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
  def cadastrar_assinante(nome, numero, cpf, plano) do
    Assinante.cadastrar(nome, numero, cpf, plano)
  end

  @spec listar_assinantes :: [
    %Assinante{chamadas: binary(), cpf: binary(), nome: binary(), numero: integer(), plano: %Pospago{} | %Prepago{}}
        ]
  @doc """
  Lista assinantes.

  ## Exemplos

      iex> Assinante.assinantes()
      [%Assinante{}]
  """
  def listar_assinantes, do: Assinante.assinantes()

  @spec listar_assinantes_pre :: [
    %Assinante{chamadas: binary(), cpf: binary(), nome: binary(), numero: integer(), plano: %Prepago{}}
        ]
  @doc """
  Lista assinantes de plano pré-pago.

  ## Exemplos

      iex> Assinante.assinantes_pre()
      [%Assinante{}]
  """
  def listar_assinantes_pre, do: Assinante.assinantes_pre()

  @spec listar_assinantes_pos :: [
          %Assinante{chamadas: binary(), cpf: binary(), nome: binary(), numero: integer(), plano: %Pospago{}}
        ]
  @doc """
  Lista assinantes de plano pós-pago.

  ## Exemplos

      iex> Assinante.assinantes_pos()
      [%Assinante{}]
  """
  def listar_assinantes_pos, do: Assinante.assinantes_pos()

  @spec buscar_assinante(binary) ::
          {:error, binary}
          | %Assinante{chamadas: binary(), cpf: binary(), nome: binary(), numero: integer(), plano: %Pospago{} | %Prepago{}}
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
  def buscar_assinante(numero), do: Assinante.buscar(numero)

  @spec buscar_assinante(binary, :pos_pago | :pre_pago) ::
          {:error, binary}
          | %Assinante{chamadas: binary(), cpf: binary(), nome: binary(), numero: integer(), plano: %Pospago{} | %Prepago{}}
  def buscar_assinante(numero, :pre_pago), do: Assinante.buscar(numero, :pre_pago)

  def buscar_assinante(numero, :pos_pago), do: Assinante.buscar(numero, :pos_pago)

  @spec ligar(binary, binary, integer) :: {:error, binary} | {:ok, <<_::64, _::_*8>>}

  @doc """
  Efetua ligação

  ## Parâmetros

  - numero (string): número da assinante.
  - data (string): data da ligação.
  - duracao (integer): duração da chamada.

  ## Exemplos

      iex> Telefonia.ligar("121", "2021-04-04T13:21:21", 2)
      {:ok, "Custo da chamada: 2.90. Saldo atual: 7.10"}

      iex> Telefonia.ligar("121", "2021-04-04T13:21:21", 40)
      {:error, "Você não tem saldo suficiente, que pena! 😈"}

      iex> Telefonia.ligar("123", "2021-04-04T13:21:21", 2)
      {:ok, "Duração da chamada: 2 minutos"}

      iex> Telefonia.ligar("123", "2021-05-04T13:21:21", 2)
      {:error, "Assinante deve pagar fatura do mês anterior"}

      iex> Telefonia.ligar("-1", "2021-04-04T13:21:21", 2)
      {:error, "Assinante não encontrado"}
  """
  def ligar(numero, data, duracao) do
    with %Assinante{} = assinante <- buscar_assinante(numero) do
      case assinante.plano.__struct__ do
        Prepago -> Prepago.ligar(numero, data, duracao)
        Pospago -> Pospago.ligar(numero, data, duracao)
      end
    end
  end

  @spec recarregar_creditos(binary, number, binary) :: {:error, binary} | {:ok, binary}
  @doc """
  Registra recarga de créditos de número

  ## Parâmetros

  - data (string): data da recarga.
  - creditos (string): quantidade de créditos da recarga.
  - numero (string): número da recarga.

  ## Exemplos

      iex> Telefonia.recarregar_creditos("2021-08-01 03:55:39.818360Z", "30", "12345678910")
      {:ok, "(2021-08-01 03:55:39.818360Z) Recarga de 30 crédito(s) para 12345678910"}

      iex> Telefonia.recarregar_creditos("2021-08-01 03:55:39.818360Z", "1234", "-1")
      {:error, "Assinante não encontrado"}

      iex> Telefonia.recarregar_creditos("2021-08-01 03:55:39.818360Z", "0", "12345678910")
      {:error, "Quantidade de créditos deve ser maior que 0"}
  """
  def recarregar_creditos(data, creditos, numero), do: Recarga.registrar(data, creditos, numero)

  @spec pagar_fatura(binary) :: {:error, binary} | {:ok, binary}
  @doc """
  Paga fatura corrente

  ## Parâmetros

  - numero (string): número da assinante.

  ## Exemplos

      iex> Pospago.pagar_fatura("12345678910")
      {:ok, "Fatura paga com sucesso"}

      iex> Pospago.pagar_fatura("-1")
      {:error, "Assinante não encontrado"}
  """
  def pagar_fatura(numero), do: Pospago.pagar_fatura(numero)

  @spec gerar_extrato(binary, binary) :: binary | {:error, binary}
    @doc """
  Gera extrato do mês de assinatura pré-paga

  ## Parâmetros

  - data (string): data da ligação.
  - numero (string): número da assinante.

  ## Exemplos

      iex> Telefonia.gerar_extrato("2021-04-04T13:21:21", "123")
      #############################################
      Assinatura pré-paga
      Nome: "Fulano"
      Número: "123"
      Total de chamadas: 0
      Chamadas:
      Total de recargas: 0
      Recargas:
      #############################################

      iex> Telefonia.gerar_extrato("2021-04-04T13:21:21", "123")
      #############################################
      Assinatura pós-paga
      Nome: "Sicrano"
      Número: "123"
      Total de chamadas: 0
      Chamadas:
      #############################################

      iex> Telefonia.gerar_extrato("2021-04-04T13:21:21", "-1")
      {:error, "Assinante não encontrado"}
  """
  def gerar_extrato(data, numero) do
    with %Assinante{} = assinante <- buscar_assinante(numero) do
      case assinante.plano.__struct__ do
        Prepago ->
          {:ok, extrato} = Prepago.gerar_extrato(data, numero)
          chamadas =
            extrato.chamadas
            |> Enum.map_join(",\n ", &("Duração: #{&1.duracao}, Data: #{DateTime.to_iso8601(&1.data)}"))
          recargas =
            extrato.plano.recargas
            |> Enum.map_join(",\n ", &("Créditos: #{&1.creditos}, Data: #{DateTime.to_iso8601(&1.data)}"))

          """
          #############################################
          Assinatura pré-paga
          Nome: #{assinante.nome}
          Número: #{numero}
          Total de chamadas: #{Enum.count(extrato.chamadas)}
          Chamadas: #{chamadas}
          Total de recargas: #{Enum.count(extrato.plano.recargas)}
          Recargas: #{recargas}
          #############################################
          """

        Pospago ->
          {:ok, extrato} = Pospago.gerar_extrato(data, numero)
          chamadas =
            extrato.chamadas
            |> Enum.map_join(",\n ", &("Duração: #{&1.duracao}, Data: #{DateTime.to_iso8601(&1.data)}"))

          """
          #############################################
          Assinatura pós-paga
          Nome: #{assinante.nome}
          Número: #{numero}
          Total de chamadas: #{Enum.count(extrato.chamadas)}
          Chamadas: #{chamadas}
          #############################################
          """
      end
    end
  end
end
