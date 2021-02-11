# StoneAccountApi

O projeto foi desenvolvido com elixir e phoenix, seguindo os padrões do framework.

# Seções

  - [Geral](#geral)
  - [Consumindo a api](#consumindo-a-api)
  - [Rodando o projeto localmente](#rodando-o-projeto-localmente)

# Geral

## Informações pessoais

  - *Nome*: Vinicius Valente
  - *Email*: viniciusgaiavalente@gmail.com
  - *Telefone*: (91) 98441-8961

## Acessando o endpoint publico

A api foi hospedada via gigaelixir e está disponível publicamente no endpoint:
  - [https://masculine-defiant-widgeon.gigalixirapp.com](https://masculine-defiant-widgeon.gigalixirapp.com)

A documentação da api pode ser encontrada em:
  - [Documentação Detalhada](#consumindo-a-api)
  - [Documentação basica online](https://documenter.getpostman.com/view/6961668/TW77fNc3)

Para facilitar o processo de testes foram incluídos dentro da pasta '/documentation' 2 arquivos, um para importar uma coleção pronta para uso no [Postman](https://www.postman.com/) e outra no [Insomnia](https://insomnia.rest/)

## Diagrama de UseCase

A api foi construida afim de atender as demandas apresentadas, estando elas, traduzidas no diagrama de usecase a baixo:

![](./documentation/use_cases_conta_stone.png)

# Consumindo a api

Aqui vc encontra instruções detalhadas e como consumir a api corretamente

Valores monetários são recebidos como inteiros positivos representando a quantidade de centavos do valor da transação a ser realizada.

Entretanto os valores monetários são retornados em 3 campos:

  - precise: o valor em centavos
  - decimal: o valor decimal
  - display: o valor formatado para exibição


Veja abaixo a lista de todos os endpoints disponiveis:

  - [Criando uma conta](#criando-uma-conta)
  - [Logando em uma conta existente](#logando-em-uma-conta-existente)
  - [Vizualizando as informações da sua conta](#vizualizando-as-informações-da-sua-conta)
  - [Transferindo dinheiro](#transferindo-dinheiro)
  - [Sacando dinheiro](#sacando-dinheiro)
  - [Relatorio do dia](#relatorio-do-dia)
  - [Relatorio do mes](#relatorio-do-mes)
  - [Relatorio do ano](#relatorio-do-ano)
  - [Transferindo dinheiro](#transferindo-dinheiro)


## Criando uma conta

Para começar a consumir a api primeiro crie uma conta pelo endpoint

  - (POST) https://masculine-defiant-widgeon.gigalixirapp.com/api/accounts/signup

Headers necessários:

```
Content-Type: application/json
```

Exemplo de json a ser enviado (você pode substituir o campo de email por um email real para receber emails em outras funcionalidades):

```json
{
  "account": {
    "password": "senha_de_exemplo",
    "holder": {
      "birthdate": "2014-04-17T14:00:00Z",
      "name": "Nome de Exemplo",
      "email": "examplo@email.com"
    }
  }
}
```

A resposta será retornada nesse formato:

```json
{
  "account": {
    "balance": {
      "decimal": "1000",
      "display": "R$1.000,00",
      "precise": 100000
    },
    "holder": {
      "birthdate": "2014-04-17T14:00:00",
      "email": "email@email.com",
      "id": "f3df55a2-d0cc-47f4-98e0-276038e19196",
      "name": "Nome de Exemplo"
    },
    "id": "95864a62-4624-4434-a910-845489eb58fd",
    "number": 1
  },
  "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzdG9uZV9hY2NvdW50X2FwaSIsImV4cCI6MTYxNTQ3MDkwNywiaWF0IjoxNjEzMDUxNzA3LCJpc3MiOiJzdG9uZV9hY2NvdW50X2FwaSIsImp0aSI6IjE1MDBkMTExLTUxNjItNGQ0Yi1iNDZhLTNiZWU3NWVjN2MyYyIsIm5iZiI6MTYxMzA1MTcwNiwic3ViIjoiOTU4NjRhNjItNDYyNC00NDM0LWE5MTAtODQ1NDg5ZWI1OGZkIiwidHlwIjoiYWNjZXNzIn0.UEjuTw7KVJpA7GxBg8h-l7PHkjxaLoVJ3JmfR-rWBLJAHuq5XmTTXFXi3lgSubBYZEJw1BedVNF8mTIU3D8i3w"
}
```

Se atente ao número de sua conta (campo ‘number’), pois ele será importante nas operações futuras.

Com o conteúdo do campo 'token' você tem acesso as funcionalidades que requerem autenticação

## Logando em uma conta existente

Após a expiração do token é necessário fazer o login novamente pelo endpoint:

  - (GET) https://masculine-defiant-widgeon.gigalixirapp.com/api/accounts/signin

Passe a conta na qual vc esta tentando logar e a sua senha no cabeçalho de authorization no formato Basic Auth (numero:senha)

Formato da resposta esperada:

```json
{
  "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzdG9uZV9hY2NvdW50X2FwaSIsImV4cCI6MTYxNTM0Mjc2OCwiaWF0IjoxNjEyOTIzNTY4LCJpc3MiOiJzdG9uZV9hY2NvdW50X2FwaSIsImp0aSI6IjU3NzFkMDZhLTYxN2YtNDVkMS04YzNkLWZmYTM4MzFmMzA1NiIsIm5iZiI6MTYxMjkyMzU2Nywic3ViIjoiOTBlNjhjZTUtOTNlOC00ZmQ2LWFlYjMtOTM3N2Q5YTM1ZTM4IiwidHlwIjoiYWNjZXNzIn0.RI243j1caMRKrLoF81ImGBSllWd9UXvP0oHvrPfOEOC46kYRIhvQ2CGEmnv2Ic6EIc5GK712-NExAHuc4TnEcw"
}
```

## Vizualizando as informações da sua conta

Para visualizar as informações da sua conta acesse o endpoint a seguir, passando o token de autenticação no cabeçalho de authorization como bearer token e passando a conta que deseja acessar como o parâmetro ':numero' do path:

  - (GET) https://masculine-defiant-widgeon.gigalixirapp.com/api/accounts/:numero

A conta será retornada no formato:

```json
{
  "balance": {
    "decimal": "1000",
    "display": "R$1.000,00",
    "precise": 100000
  },
  "holder": {
    "birthdate": "2014-04-17T14:00:00",
    "email": "email@email.com",
    "id": "e4320aab-0c8c-43ef-9cd0-30f955f14662",
    "name": "Nome de Exemplo"
  },
  "id": "90e68ce5-93e8-4fd6-aeb3-9377d9a35e38",
  "number": 1
}
```

## Transferindo dinheiro

Para realizar uma transferencia use o endpoint:

  - (POST) https://masculine-defiant-widgeon.gigalixirapp.com/api/trasnference

Passe token de autenticação no cabeçalho de authorization como bearer token.

Demais headers necessários:

```
Content-Type: application/json
```


Exemplo de json de requisição:

```json
{
	"origin": 1,
	"destination": 3,
	"value": 5000
}
```

Exemplo de json de resposta:

```json
{
  "result": {
    "balance": {
      "decimal": "500.0",
      "display": "R$500,00",
      "precise": 50000
    },
    "destination": 3,
    "origin": 1,
    "value": 5000
  }
}
```

## Sacando dinheiro

Para realizar um saque use o endpoint:

  - (POST) https://masculine-defiant-widgeon.gigalixirapp.com/api/withdraw

Passe token de autenticação no cabeçalho de authorization como bearer token.

Demais headers necessários:

```
Content-Type: application/json
```

Exemplo de json de requisição:

```json
{
	"origin": 1,
	"value": 5000
}
```

Exemplo de json de resposta:

```json
{
  "result": {
    "balance": {
      "decimal": "550.0",
      "display": "R$550,00",
      "precise": 55000
    },
    "origin": 1,
    "value": 5000
  }
}
```

## Backoffice

Todos os serviços a seguir são referentes ao backoffice, para realizar as chamadas ao backoffice, insira no cabeçalho de authorization no formato basic (username:password) as informações:

  - username: admin
  - password: 1234


## Relatorio do dia

  - (GET) https://masculine-defiant-widgeon.gigalixirapp.com/api/backoffice/report/day

Exemplo de json de resposta:

```json
{
  "total_transactions": "R$250,00"
}
```

## Relatorio do mes

  - (GET) https://masculine-defiant-widgeon.gigalixirapp.com/api/backoffice/report/month

Exemplo de json de resposta:

```json
{
  "total_transactions": "R$250,00"
}
```

## Relatorio do ano

  - (GET) https://masculine-defiant-widgeon.gigalixirapp.com/api/backoffice/report/year

Exemplo de json de resposta:

```json
{
  "total_transactions": "R$250,00"
}
```

## Lista detalhada de transferencias

  - (GET) https://masculine-defiant-widgeon.gigalixirapp.com/api/backoffice/transferences

Exemplo de json de resposta:

```json
{
  "data": [
    {
      "destination_id": "3195c6ab-201a-4755-aac8-26e9b1f654d7",
      "destination_new_balance": "R$1.050,00",
      "destination_old_balance": "R$1.000,00",
      "id": "424b46b9-5887-4f79-9d48-4c29be4a4d98",
      "origin_id": "0fb418aa-95a9-4dbb-bd97-83429f2b2450",
      "origin_new_balance": "R$850,00",
      "origin_old_balance": "R$900,00",
      "value": "R$50,00"
    },
    {
      "destination_id": "3195c6ab-201a-4755-aac8-26e9b1f654d7",
      "destination_new_balance": "R$1.100,00",
      "destination_old_balance": "R$1.050,00",
      "id": "5fac0236-006d-4af2-b5ec-ba95aba6eed9",
      "origin_id": "0fb418aa-95a9-4dbb-bd97-83429f2b2450",
      "origin_new_balance": "R$800,00",
      "origin_old_balance": "R$850,00",
      "value": "R$50,00"
    },
    {
      "destination_id": "3195c6ab-201a-4755-aac8-26e9b1f654d7",
      "destination_new_balance": "R$1.150,00",
      "destination_old_balance": "R$1.100,00",
      "id": "818c5bb7-a193-433b-a1f7-494e70a0e493",
      "origin_id": "0fb418aa-95a9-4dbb-bd97-83429f2b2450",
      "origin_new_balance": "R$750,00",
      "origin_old_balance": "R$800,00",
      "value": "R$50,00"
    }
  ]
}
```

## Lista detalhada de saques

  - (GET) https://masculine-defiant-widgeon.gigalixirapp.com/api/backoffice/withdraws

Exemplo de json de resposta:

```json
{
  "data": [
    {
      "account_id": "90e68ce5-93e8-4fd6-aeb3-9377d9a35e38",
      "id": "e7958ff2-59c0-4c4e-9cc3-3591a658c0bf",
      "new_balance": "R$950,00",
      "old_balance": "R$1.000,00",
      "value": "R$50,00"
    },
    {
      "account_id": "90e68ce5-93e8-4fd6-aeb3-9377d9a35e38",
      "id": "17fdc7e9-469f-4fa7-a280-50cb8481216d",
      "new_balance": "R$900,00",
      "old_balance": "R$950,00",
      "value": "R$50,00"
    },
    {
      "account_id": "90e68ce5-93e8-4fd6-aeb3-9377d9a35e38",
      "id": "b175777c-66e0-4645-910d-93cb76d677b2",
      "new_balance": "R$850,00",
      "old_balance": "R$900,00",
      "value": "R$50,00"
    },
    {
      "account_id": "90e68ce5-93e8-4fd6-aeb3-9377d9a35e38",
      "id": "93281253-3ff0-4d47-bb8e-c7adc51b0398",
      "new_balance": "R$700,00",
      "old_balance": "R$750,00",
      "value": "R$50,00"
    },
    {
      "account_id": "90e68ce5-93e8-4fd6-aeb3-9377d9a35e38",
      "id": "135efa76-ac4a-48e6-a09b-9504e4ab9942",
      "new_balance": "R$600,00",
      "old_balance": "R$650,00",
      "value": "R$50,00"
    },
    {
      "account_id": "90e68ce5-93e8-4fd6-aeb3-9377d9a35e38",
      "id": "101a5c75-742e-46c3-9865-098a253e3486",
      "new_balance": "R$550,00",
      "old_balance": "R$600,00",
      "value": "R$50,00"
    }
  ]
}
```

# Rodando o projeto localmente

Para executar esse projeto você precisa instalar e configurar corretamente o elixir e o phoenix framework na sua maquina. Caso ainda não tenha feito o processo, siga os seguintes passos descritos em:

  - [Instalando o Elixir](https://elixir-lang.org/install.html).
  - [Instalando o Phoenix](https://hexdocs.pm/phoenix/installation.html).

Com tudo instalado rode o comando 'mix deps.get' dentro da pasta do projeto:

```bash
cd bill_splitter/
mix deps.get
```

Para que a aplicação funcione corretamente é necessário configurar algumas variáveis de ambiente:

```.env
DATABASE_URL=url de conexão com o banco de dados
PORT=porta onde a api será exposta
MAILGUN API_KEY=configuração específica do serviço de envio de emails 'mailgun'
MAILGUN DOMAIN=configuração específica do serviço de envio de emails 'mailgun'
MAILGUN_BASE_URI=configuração específica do serviço de envio de emails 'mailgun'
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