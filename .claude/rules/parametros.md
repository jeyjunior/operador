# Parâmetros: padrão parametro.json

Se a operação precisar de um arquivo de parâmetros, ele se chama `parametro.json`, fica em `operacao/parametros/` e tem esta forma:

```json
{
  "<NomeDaEmpresa>": {
    "ApiKey": "",
    "ApiSecret": ""
  },
  "Banco": {
    "Senha": ""
  }
}
```

- Um objeto por empresa ou serviço externo, com o nome dela (ex.: `GatewayPagamento`, `ServicoEmail`). `ApiKey` e `ApiSecret` são os nomes padrão; outras propriedades do mesmo serviço entram no mesmo objeto (ex.: `Passphrase`).
- `Banco` guarda a senha do banco; outras informações de conexão entram no mesmo objeto.
- Quem preenche é o usuário. Você não lê nem grava esse arquivo.
