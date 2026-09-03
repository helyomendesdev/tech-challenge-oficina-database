# ADR-002 — Execução do Amazon RDS em Subnets Privadas

**Status:** Aceito  

## Contexto

O banco de dados PostgreSQL armazena informações persistentes da aplicação.

Por se tratar de um componente que não deve ser exposto diretamente à internet, é necessário definir uma estratégia de rede adequada.

A infraestrutura principal utiliza uma VPC dedicada contendo:

- Subnets públicas;
- Subnets privadas;
- Recursos do Amazon EKS;
- Recursos de banco de dados.

O Amazon RDS precisa ser provisionado dentro da VPC e utilizar subnets apropriadas.

## Decisão

A instância Amazon RDS PostgreSQL será executada utilizando subnets privadas.

A configuração utiliza um `DB Subnet Group` composto por subnets privadas localizadas em diferentes Availability Zones.

A instância também será configurada com:

publicly_accessible = false

## Justificativa

O banco de dados não precisa receber conexões diretamente da internet.

A aplicação executada no Amazon EKS será responsável por acessar o banco através da rede privada da VPC.

A utilização de subnets privadas reduz a superfície de exposição da infraestrutura.

## Consequências

### Positivas

O banco não possui acesso público direto;
Redução da superfície de ataque;
Comunicação interna entre aplicação e banco;
Melhor isolamento de rede;
Arquitetura mais adequada para workloads de banco de dados.

### Negativas

O acesso administrativo ao banco exige mecanismos adicionais;
Ferramentas locais não podem acessar diretamente o banco pela internet;
Debug e manutenção podem exigir conexão através de recursos internos da VPC.

## Arquitetura

```text
                    VPC
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
   Public Subnets            Private Subnets
        │                         │
        │                         │
   NAT Gateway                Amazon EKS
                                  │
                                  │ PostgreSQL
                                  ▼
                             Amazon RDS
```

## Alternativas consideradas

### RDS público

Vantagens:

Facilidade para acesso administrativo;
Facilidade para desenvolvimento.

Desvantagens:

Maior exposição do banco;
Maior superfície de ataque;
Exige regras de segurança adicionais.

### RDS privado

Vantagens:

Maior isolamento;
Sem exposição pública direta;
Comunicação interna com o EKS.

Desvantagens:

Acesso administrativo mais complexo.

## Decisão final

O Amazon RDS PostgreSQL será executado em subnets privadas e não será publicamente acessível.
