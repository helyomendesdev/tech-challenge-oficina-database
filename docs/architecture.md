# Arquitetura da Database

## 1. Visão geral

A camada de banco de dados do projeto **Tech Challenge Oficina** utiliza **Amazon RDS com PostgreSQL** como banco de dados relacional principal da aplicação.

O RDS é provisionado por Terraform e executado em uma infraestrutura privada dentro da VPC criada para o projeto.

A aplicação executada no Amazon EKS acessa o banco de dados por meio da rede privada da VPC, utilizando o PostgreSQL na porta `5432`.

```text
                    AWS VPC
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Private Subnet A                    Private Subnet B       │
│  ┌──────────────────┐               ┌──────────────────┐    │
│  │                  │               │                  │    │
│  │    EKS Node      │               │    EKS Node      │    │
│  │       │          │               │       │          │    │
│  │       ▼          │               │       ▼          │    │
│  │  Django Pod      │               │  Django Pod      │    │
│  │                  │               │                  │    │
│  └────────┬─────────┘               └────────┬─────────┘    │
│           │                                  │              │
│           └──────────────┬───────────────────┘              │
│                          │                                  │
│                          │ PostgreSQL :5432                 │
│                          ▼                                  │
│                 ┌──────────────────┐                        │
│                 │                  │                        │
│                 │  Amazon RDS      │                        │
│                 │  PostgreSQL      │                        │
│                 │                  │                        │
│                 └──────────────────┘                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 2. Componentes

A arquitetura da database é composta principalmente pelos seguintes componentes:

| Componente           | Responsabilidade                                   |
| -------------------- | -------------------------------------------------- |
| Amazon RDS           | Hospedar o banco PostgreSQL                        |
| PostgreSQL           | Persistência dos dados da aplicação                |
| DB Subnet Group      | Definir as subnets privadas utilizadas pelo RDS    |
| Security Group       | Controlar o acesso ao PostgreSQL                   |
| Parameter Group      | Configurar parâmetros específicos do PostgreSQL    |
| Performance Insights | Monitorar desempenho do banco                      |
| CloudWatch Logs      | Disponibilizar logs do PostgreSQL                  |
| `pg_stat_statements` | Coletar estatísticas de execução das queries       |
| `monitoring_user`    | Usuário utilizado para monitoramento               |
| `oficina_auth`       | Usuário com permissões restritas para autenticação |

## 3. Amazon RDS PostgreSQL

O banco de dados é executado utilizando Amazon RDS com PostgreSQL.

Configurações principais:

```text
Engine: PostgreSQL
Versão: 17.11
Instância: db.t3.small
Storage: 20 GB
Storage Type: gp3
Encryption: habilitada
Publicly Accessible: false
Backup Retention: 7 dias
```

A utilização do RDS elimina a necessidade de executar e administrar diretamente o PostgreSQL dentro do Kubernetes.

Essa decisão também mantém a camada de persistência independente do ciclo de vida do cluster EKS.

## 4. Rede

O RDS é executado em **subnets privadas**.

O `DB Subnet Group` utiliza as subnets privadas fornecidas pela infraestrutura do repositório `tech-challenge-oficina-k8s`.

```text
tech-challenge-oficina-k8s
        │
        ├── VPC
        │
        ├── Private Subnet A
        │
        └── Private Subnet B
                │
                ▼
tech-challenge-oficina-database
                │
                ▼
        RDS Subnet Group
                │
                ▼
        Amazon RDS PostgreSQL
```

O RDS possui:

```hcl
publicly_accessible = false
```

Portanto, o banco não possui acesso direto pela Internet.

## 5. Controle de acesso

O acesso ao RDS é controlado por Security Group.

A regra principal permite conexões TCP na porta `5432` somente a partir do Security Group utilizado pelos recursos do EKS.

```text
EKS
 │
 │ TCP 5432
 ▼
RDS Security Group
 │
 ▼
Amazon RDS PostgreSQL
```

Não é permitido acesso aberto ao banco por:

```text
0.0.0.0/0
```

Essa configuração reduz a superfície de exposição do banco de dados.

## 6. Usuários do PostgreSQL

A arquitetura utiliza usuários com responsabilidades diferentes.

### `oficina_admin`

Usuário administrativo utilizado pelo RDS e pelas operações de administração do banco.

É o usuário responsável, entre outras atividades, pela criação das estruturas necessárias ao banco.

### `oficina_auth`

Usuário dedicado ao serviço de autenticação.

Possui permissões restritas e deve possuir somente os acessos necessários para sua finalidade.

Atualmente, o usuário possui acesso de leitura à tabela:

```text
atendimento_cliente
```

Não deve possuir permissões administrativas ou de escrita desnecessárias.

### `monitoring_user`

Usuário dedicado às atividades de monitoramento do PostgreSQL.

Possui permissões necessárias para leitura das informações utilizadas na observabilidade do banco, incluindo:

* `CONNECT`;
* `USAGE` no schema `public`;
* `SELECT` nas tabelas necessárias;
* `pg_monitor`.

As credenciais desses usuários não devem ser armazenadas diretamente no código-fonte.

## 7. Observabilidade

A arquitetura utiliza diferentes mecanismos para acompanhar o desempenho e o comportamento do PostgreSQL.

### Performance Insights

O Performance Insights é habilitado para auxiliar na análise do desempenho do banco e identificação de consultas ou cargas que possam impactar a instância.

### CloudWatch Logs

Os logs do PostgreSQL são exportados para o Amazon CloudWatch.

Isso permite centralizar informações relevantes para diagnóstico e acompanhamento do banco.

### `pg_stat_statements`

A extensão:

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

é utilizada para coletar estatísticas sobre a execução das consultas PostgreSQL.

O parâmetro:

```text
pg_stat_statements.track = all
```

permite acompanhar as consultas executadas no banco.

### Parâmetros adicionais

O Parameter Group customizado também configura:

```text
log_min_duration_statement = 1000
track_io_timing = 1
```

Dessa forma, consultas com duração igual ou superior a 1 segundo podem ser identificadas nos logs, auxiliando na investigação de problemas de desempenho.

## 8. Criptografia e backups

O armazenamento do RDS utiliza criptografia:

```hcl
storage_encrypted = true
```

O banco também possui retenção de backups configurada para:

```text
7 dias
```

Os backups permitem recuperar dados em caso de falhas ou necessidade de restauração.

A configuração atual também utiliza:

```hcl
copy_tags_to_snapshot = true
```

para manter as tags associadas aos snapshots.

### Configuração específica do ambiente acadêmico

O ambiente atual utiliza:

```hcl
deletion_protection = false
skip_final_snapshot = true
```

Essas configurações facilitam o ciclo de criação e destruição da infraestrutura durante o desenvolvimento no AWS Academy.

Elas **não devem ser consideradas configurações ideais para um ambiente produtivo**.

## 9. Parameter Group

O PostgreSQL utiliza um Parameter Group customizado criado pelo Terraform.

Entre os parâmetros configurados estão:

```text
shared_preload_libraries = pg_stat_statements
log_min_duration_statement = 1000
pg_stat_statements.track = all
track_io_timing = 1
```

O uso de um Parameter Group próprio permite que as configurações relevantes do banco sejam versionadas junto à infraestrutura.

A configuração de `shared_preload_libraries` utiliza:

```text
apply_method = pending-reboot
```

pois a alteração requer reinicialização da instância para entrar em vigor.

## 10. Integração com o EKS

A comunicação entre a aplicação e o banco ocorre pela rede privada.

O fluxo é:

```text
Django Pod
    │
    │ TCP 5432
    ▼
EKS Node / VPC
    │
    ▼
RDS Security Group
    │
    ▼
Amazon RDS PostgreSQL
```

O banco não depende do Kubernetes para seu ciclo de vida.

Caso os pods sejam recriados ou o cluster EKS seja atualizado, os dados permanecem armazenados no RDS.

## 11. Integração entre repositórios

A infraestrutura é dividida em diferentes repositórios.

### Kubernetes / infraestrutura

`tech-challenge-oficina-k8s`

Responsável por:

* VPC;
* Subnets;
* EKS;
* ECR;
* ALB;
* Security Groups relacionados à infraestrutura Kubernetes;
* Recursos Kubernetes;
* Outputs utilizados pelos demais repositórios.

### Database

`tech-challenge-oficina-database`

Responsável por:

* RDS PostgreSQL;
* DB Subnet Group;
* Security Group do RDS;
* Parameter Group;
* Configurações de monitoramento;
* Scripts SQL;
* Usuários e permissões específicas do banco.

### Aplicação

`tech-challenge-oficina`

Responsável por:

* Aplicação Django;
* Docker;
* CI/CD;
* Configuração da aplicação;
* Código de acesso ao banco.

### Autenticação

`tech-challenge-oficina-auth`

Responsável por:

* API Gateway;
* Lambda;
* Fluxo de autenticação;
* Integração do serviço de autenticação com o banco.

## 12. Fluxo completo

Considerando a arquitetura geral do projeto, o fluxo de uma requisição da aplicação pode ser representado da seguinte forma:

```text
Cliente
   │
   │ HTTPS
   ▼
API Gateway
   │
   │ VPC Link
   ▼
Internal ALB
   │
   │ HTTP :30080
   ▼
EKS
   │
   ▼
Django Pod
   │
   │ PostgreSQL :5432
   ▼
Amazon RDS PostgreSQL
```

O fluxo de autenticação possui integração específica com o serviço de autenticação:

```text
Cliente
   │
   │ HTTPS
   ▼
API Gateway
   │
   ├──────────────► Lambda Auth
   │                    │
   │                    │ PostgreSQL :5432
   │                    ▼
   │              Amazon RDS
   │
   └──────────────► Aplicação
```

## 13. Segurança

As principais medidas de segurança da camada de database são:

* RDS não acessível publicamente;
* RDS em subnets privadas;
* Acesso ao PostgreSQL controlado por Security Group;
* Porta `5432` restrita aos recursos autorizados;
* Criptografia do armazenamento;
* Usuários PostgreSQL separados por responsabilidade;
* Princípio do menor privilégio;
* Credenciais fora do código-fonte;
* Backups habilitados;
* Logs do PostgreSQL enviados ao CloudWatch.

## 14. Limitações conhecidas

A infraestrutura é executada em um ambiente **AWS Academy**, que possui restrições de permissões e serviços.

Algumas funcionalidades que dependem de permissões IAM específicas podem não estar disponíveis nesse ambiente.

Um exemplo é o **Enhanced Monitoring do RDS**, que não foi implementado devido às restrições de IAM do ambiente acadêmico.

Essas limitações estão documentadas no:

[ADR-010 — Limitações do AWS Academy](./adrs/ADR-010-limitacoes-do-aws-academy.md)

## 15. ADRs relacionados

As decisões arquiteturais desta camada estão documentadas nos seguintes ADRs:

* [ADR-001 — Utilização do Amazon RDS com PostgreSQL](./adrs/ADR-001-utilizacao-amazon-rds-postgresql.md)
* [ADR-002 — RDS em subnets privadas](./adrs/ADR-002-rds-em-subnets-privadas.md)
* [ADR-003 — Acesso ao RDS restrito ao EKS](./adrs/ADR-003-acesso-rds-restrito-ao-eks.md)
* [ADR-004 — Criptografia e backups do RDS](./adrs/ADR-004-criptografia-e-backups-do-rds.md)
* [ADR-005 — Monitoramento e observabilidade do PostgreSQL](./adrs/ADR-005-monitoramento-e-observabilidade-do-postgresql.md)
* [ADR-006 — Usuário dedicado para monitoramento](./adrs/ADR-006-usuario-dedicado-monitoramento.md)
* [ADR-007 — Usuário restrito para autenticação](./adrs/ADR-007-usuario-restrito-para-autenticacao.md)
* [ADR-008 — Parameter Group customizado](./adrs/ADR-008-parameter-group-customizado.md)
* [ADR-009 — Integração entre repositórios](./adrs/ADR-009-integracao-entre-repositorios.md)
* [ADR-010 — Limitações do AWS Academy](./adrs/ADR-010-limitacoes-do-aws-academy.md)
