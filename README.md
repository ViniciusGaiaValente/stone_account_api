# StoneAccountApi

## Sobre

O projeto foi desenvolvido com elixir e phoenix, seguindo os padrões do framework.

## Informações pessoais

  - *Nome*: Vinicius Valente
  - *Email*: viniciusgaiavalente@gmail.com
  - *Telefone*: (91) 98441-8961

## Acessando o endpoint publico

A api foi hospedada via gigaelixir e está disponível publicamente no endpoint:
  - [https://masculine-defiant-widgeon.gigalixirapp.com](https://masculine-defiant-widgeon.gigalixirapp.com).

A documentação da api pode ser encontrada em:
  - [Documentação da api](https://documenter.getpostman.com/view/6961668/TW77fNc3)

Para facilitar o processo de testes foram incluídos dentro da pasta /documentação 2 arquivos, um para importar uma coleção pronta para uso no [Postman](https://www.postman.com/) e outra no [Insomnia](https://insomnia.rest/)

## Rodando o projeto localmente

Para executar esse projeto você precisa instalar e configurar corretamente o elixir e o phoenix framework na sua maquina. Caso ainda não tenha feito o processo, siga os seguintes passos descritos em:

  - [Instalando o Elixir](https://elixir-lang.org/install.html).
  - [Instalando o Phoenix](https://hexdocs.pm/phoenix/installation.html).

Com tudo instalado rode o comando 'mix deps.get' dentro da pasta do projeto:

```bash
cd bill_splitter/
mix deps.get
```

### Banco de dados

Esse projeto foi configurado para utilizar o banco de dados postgres, porém outros bancos de dados suportados pelo Ecto funcionarão normalmente (MySQL, MSSQL).

Insira as informações do banco de dados que deseja utilizar no arquivo **config/dev.exs**:

```elixir
config :stone_account_api, StoneAccountApi.Repo,
    username: "postgres",
    password: "postgres",
    database: "stone_account_api_dev",
    hostname: "localhost",
    show_sensitive_data_on_connection_error: true,
    pool_size: 10
```

Caso ainda náo tenha um banco de dados postgres pronto para uso, você pode configura-lo facilmente utilizando o docker.
 - Para instalar o docker siga os seguintes passos descritos em: [Instalando o Docker](https://docs.docker.com/engine/install/).

Com o docker instalado faça o pull da imagem do postgres:

```bash
docker pull postgres
```

E então rode o comando a seguir:

```bash
docker run --name delivery-center-api-db -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=stone_account_api_dev -d postgres
```

Esse comando cria e executa um container contendo um banco de dados postgres já com as configurações pré-existente no arquivo config/dev.exs.

Com o banco de dados online e as informações de conexão inseridas corretamente, rode o seguinte comando para criar o banco de dados:

```bash
mix ecto.create database
```

Depois rode todas as migrations:

```bash
mix ecto.migrate
```

Com isso a API está pronta para ser executada com o comando:

```bash
mix phx.server
```
