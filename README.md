# Tech Challenge Oficina — Database

Infraestrutura como código responsável pela camada de banco de dados do **Tech Challenge Oficina — Fase 3**, utilizando **Amazon RDS PostgreSQL** provisionado com Terraform.

Este repositório concentra a infraestrutura, configuração e documentação relacionadas ao banco de dados da aplicação.

## Responsabilidade

Este repositório é responsável por:

* Provisionar o Amazon RDS PostgreSQL com Terraform;
* Configurar o DB Subnet Group;
* Configurar o Security Group do RDS;
* Definir parâmetros do PostgreSQL por meio de um Parameter Group customizado;
* Configurar criptografia e backups;
* Configurar recursos de monitoramento e observabilidade do PostgreSQL;
* Criar usuários específicos para diferentes responsabilidades;
* Configurar permissões de acesso ao banco;
* Executar scripts SQL necessários à configuração do banco;
* Disponibilizar outputs necessários para integração com outros repositórios;
* Documentar as decisões arquiteturais relacionadas ao banco de dados.

---

## Arquitetura

A camada de database utiliza **Amazon RDS PostgreSQL** dentro de uma VPC privada.

A aplicação executada no Amazon EKS acessa o RDS pela rede privada utilizando PostgreSQL na porta `5432`.

```text
                    AWS VPC
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  Private Subnet A              Private Subnet B          │
│  ┌─────────────────┐           ┌─────────────────┐       │
│  │    EKS Node     │           │    EKS Node     │       │
│  │       │         │           │       │         │       │
│  │       ▼         │           │       ▼         │       │
│  │   Django Pod    │           │   Django Pod    │       │
│  └────────┬────────┘           └────────┬────────┘       │
│           │                             │                │
│           └──────────────┬──────────────┘                │
│                          │                                │
│                          │ TCP 5432                       │
│                          ▼                                │
│                 ┌──────────────────┐                     │
│                 │                  │                     │
│                 │  Amazon RDS      │                     │
│                 │  PostgreSQL      │                     │
│                 │                  │                     │
│                 └──────────────────┘                     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

O RDS é configurado como **não público**, evitando exposição direta do banco à Internet.

O acesso é controlado por Security Groups, permitindo conexões na porta `5432` somente a partir dos recursos autorizados do EKS.

Para mais detalhes sobre a arquitetura:

* [Documentação da arquitetura](./docs/architecture.md)
* [ADRs](./docs/adrs/README.md)

---

## AWS RDS PostgreSQL

A instância PostgreSQL é provisionada utilizando Terraform.

Configurações principais:

| Configuração         | Valor         |
| -------------------- | ------------- |
| Serviço              | Amazon RDS    |
| Engine               | PostgreSQL    |
| Versão               | 17.11         |
| Instância            | `db.t3.small` |
| Storage              | 20 GB         |
| Storage Type         | gp3           |
| Criptografia         | Habilitada    |
| Acesso público       | Desabilitado  |
| Retenção de backup   | 7 dias        |
| Performance Insights | Habilitado    |
| Logs PostgreSQL      | CloudWatch    |

A utilização do Amazon RDS permite separar a camada de persistência do cluster Kubernetes, reduzindo a responsabilidade operacional sobre o PostgreSQL.

---

## Rede e segurança

O RDS utiliza as **subnets privadas** da VPC criada pela infraestrutura do repositório `tech-challenge-oficina-k8s`.

A comunicação entre a aplicação e o banco ocorre pela rede privada da AWS.

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

O Security Group do RDS não permite acesso aberto pela Internet.

A regra de entrada utiliza o Security Group dos recursos do EKS como origem:

```text
Protocolo: TCP
Porta: 5432
Origem: EKS Security Group
```

Essa abordagem segue o princípio de restringir o acesso ao banco somente aos componentes que realmente precisam se comunicar com ele.

---

## Monitoramento e observabilidade

O PostgreSQL possui configurações específicas para facilitar o monitoramento e a análise de desempenho.

São utilizados:

* **Amazon Performance Insights**;
* **Amazon CloudWatch Logs**;
* `pg_stat_statements`;
* `pg_monitor`;
* PostgreSQL Parameter Group customizado.

A extensão `pg_stat_statements` permite coletar estatísticas sobre a execução das consultas.

Também são utilizados parâmetros como:

```text
log_min_duration_statement = 1000
pg_stat_statements.track = all
track_io_timing = 1
```

Essas configurações auxiliam na identificação de consultas lentas e problemas relacionados ao desempenho do banco.

O **Enhanced Monitoring** não foi implementado no ambiente atual devido às limitações de permissões IAM do AWS Academy.

Essa decisão está documentada no:

[ADR-010 — Limitações do AWS Academy](./docs/adrs/ADR-010-limitacoes-do-aws-academy.md)

---

## Usuários do banco

O banco possui usuários com responsabilidades distintas.

### `oficina_admin`

Usuário administrativo utilizado para operações de administração e configuração do banco.

### `oficina_auth`

Usuário dedicado ao serviço de autenticação.

Possui permissões restritas de acordo com sua finalidade e não deve possuir privilégios administrativos desnecessários.

### `monitoring_user`

Usuário dedicado às atividades de monitoramento do PostgreSQL.

Possui as permissões necessárias para consultar informações utilizadas pela observabilidade do banco.

As credenciais desses usuários **não devem ser armazenadas no código-fonte**.

Senhas e demais informações sensíveis devem ser fornecidas por mecanismos apropriados de gerenciamento de secrets.

---

## Criptografia e backups

O armazenamento do RDS utiliza criptografia:

```hcl
storage_encrypted = true
```

Os backups possuem retenção de **7 dias**.

Também está configurado:

```hcl
copy_tags_to_snapshot = true
```

para preservar as tags associadas aos snapshots.

### Configuração do ambiente acadêmico

Devido ao ciclo de desenvolvimento e testes do projeto no AWS Academy, atualmente são utilizadas:

```hcl
deletion_protection = false
skip_final_snapshot = true
```

Essas configurações facilitam a destruição e recriação da infraestrutura durante o desenvolvimento.

**Essas configurações não devem ser consideradas adequadas para um ambiente produtivo.**

---

## Parameter Group

O PostgreSQL utiliza um Parameter Group customizado criado pelo Terraform.

Entre os parâmetros configurados estão:

```text
shared_preload_libraries = pg_stat_statements
log_min_duration_statement = 1000
pg_stat_statements.track = all
track_io_timing = 1
```

A configuração é versionada junto ao código Terraform, permitindo rastrear alterações realizadas na configuração do PostgreSQL.

---

## Integração com os demais repositórios

O projeto utiliza uma arquitetura distribuída em diferentes repositórios, com responsabilidades separadas.

| Repositório                       | Responsabilidade                                   | Link                                                                        |
| --------------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------- |
| `tech-challenge-oficina`          | Aplicação Backend, Docker, CI/CD e observabilidade | [GitHub](https://github.com/helyomendesdev/tech-challenge-oficina)          |
| `tech-challenge-oficina-k8s`      | VPC, EKS, ECR, ALB, Terraform e Kubernetes         | [GitHub](https://github.com/sophiasussa/tech-challenge-oficina-k8s)         |
| `tech-challenge-oficina-database` | RDS PostgreSQL e configuração do banco             | [GitHub](https://github.com/helyomendesdev/tech-challenge-oficina-database) |
| `tech-challenge-oficina-auth`     | API Gateway, Lambda e autenticação                 | [GitHub](https://github.com/helyomendesdev/tech-challenge-oficina-auth)     |

### Integração com o repositório de Kubernetes

O repositório `tech-challenge-oficina-k8s` é responsável pela infraestrutura de rede e pelo EKS.

Entre os outputs utilizados pelo repositório de database estão:

```text
vpc_id
private_subnet_ids
eks_cluster_security_group_id
```

Essas informações são fornecidas ao Terraform do database por meio de variáveis.

O fluxo de dependência é:

```text
tech-challenge-oficina-k8s
        │
        ├── VPC
        ├── Private Subnets
        └── EKS Security Group
                │
                │ outputs
                ▼
tech-challenge-oficina-database
                │
                ├── RDS
                ├── RDS Security Group
                ├── Parameter Group
                └── DB Subnet Group
```

Essa separação evita que cada repositório precise gerenciar recursos que pertencem à responsabilidade de outro componente.

---

## Estrutura do repositório

```text
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── ...
│
├── sql/
│   ├── auth_user.sql
│   ├── monitoring_user.sql
│   └── ...
│
├── docs/
│   ├── architecture.md
│   └── adrs/
│       ├── README.md
│       ├── ADR-001-utilizacao-amazon-rds-postgresql.md
│       ├── ADR-002-rds-em-subnets-privadas.md
│       ├── ADR-003-acesso-rds-restrito-ao-eks.md
│       ├── ADR-004-criptografia-e-backups-do-rds.md
│       ├── ADR-005-monitoramento-e-observabilidade-do-postgresql.md
│       ├── ADR-006-usuario-dedicado-monitoramento.md
│       ├── ADR-007-usuario-restrito-para-autenticacao.md
│       ├── ADR-008-parameter-group-customizado.md
│       ├── ADR-009-integracao-entre-repositorios.md
│       └── ADR-010-limitacoes-do-aws-academy.md
│
└── README.md
```

A estrutura pode ser expandida conforme novas necessidades de infraestrutura ou documentação forem identificadas.

---

## Terraform

O Terraform é utilizado para provisionar e configurar os recursos do banco.

Entre os principais recursos estão:

```text
aws_db_instance
aws_db_subnet_group
aws_db_parameter_group
aws_security_group
aws_vpc_security_group_ingress_rule
```

Os valores específicos do ambiente, principalmente credenciais e identificadores de infraestrutura, devem ser fornecidos por variáveis.

Exemplo:

```hcl
vpc_id = "vpc-xxxxxxxxxxxxxxxxx"

private_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy"
]

eks_security_group_id = "sg-xxxxxxxxxxxxxxxxx"

db_name           = "oficina"
db_username       = "oficina_admin"
db_password       = "CHANGE_ME"
db_instance_class = "db.t3.small"
```

**Valores reais de senha, tokens ou outras credenciais não devem ser commitados no Git.**

---

## Branches

O fluxo de desenvolvimento utiliza:

* `develop`: integração e homologação;
* `main`: versão estável/produção.

As alterações devem ser realizadas em branches de trabalho e integradas por meio de Pull Requests.

Exemplo:

```text
feature/minha-alteracao
        │
        ▼
     develop
        │
        ▼
      main
```

---

## Documentação arquitetural

As principais decisões relacionadas ao banco estão documentadas utilizando **Architecture Decision Records (ADRs)**.

### ADRs disponíveis

1. [ADR-001 — Utilização do Amazon RDS com PostgreSQL](./docs/adrs/ADR-001-utilizacao-amazon-rds-postgresql.md)
2. [ADR-002 — RDS em subnets privadas](./docs/adrs/ADR-002-rds-em-subnets-privadas.md)
3. [ADR-003 — Acesso ao RDS restrito ao EKS](./docs/adrs/ADR-003-acesso-rds-restrito-ao-eks.md)
4. [ADR-004 — Criptografia e backups do RDS](./docs/adrs/ADR-004-criptografia-e-backups-do-rds.md)
5. [ADR-005 — Monitoramento e observabilidade do PostgreSQL](./docs/adrs/ADR-005-monitoramento-e-observabilidade-do-postgresql.md)
6. [ADR-006 — Usuário dedicado para monitoramento](./docs/adrs/ADR-006-usuario-dedicado-monitoramento.md)
7. [ADR-007 — Usuário restrito para autenticação](./docs/adrs/ADR-007-usuario-restrito-para-autenticacao.md)
8. [ADR-008 — Parameter Group customizado](./docs/adrs/ADR-008-parameter-group-customizado.md)
9. [ADR-009 — Integração entre repositórios](./docs/adrs/ADR-009-integracao-entre-repositorios.md)
10. [ADR-010 — Limitações do AWS Academy](./docs/adrs/ADR-010-limitacoes-do-aws-academy.md)

A documentação completa da arquitetura está disponível em:

[docs/architecture.md](./docs/architecture.md)

---

## Segurança

Nunca adicionar ao repositório:

* Senhas;
* Tokens;
* Access Keys;
* Secret Keys;
* Connection strings com credenciais;
* Arquivos `.tfvars` contendo informações sensíveis;
* Secrets utilizados pela aplicação.

Antes de realizar um commit, verificar se nenhum dado sensível foi incluído.

Exemplos presentes na documentação utilizam valores fictícios como:

```text
CHANGE_ME
ALTERAR_SENHA
xxxxxxxxxxxxxxxx
```

---

## Limitações do ambiente

Este projeto é desenvolvido utilizando o **AWS Academy**, que possui restrições de permissões, serviços e recursos disponíveis.

Algumas decisões arquiteturais foram adaptadas para esse ambiente, incluindo:

* Uso de recursos compatíveis com as permissões disponíveis;
* Limitações relacionadas ao IAM;
* Ausência do Enhanced Monitoring do RDS;
* Configurações voltadas ao ciclo de desenvolvimento acadêmico;
* Uso de recursos dimensionados para o orçamento disponível.

As limitações e suas consequências estão registradas nos ADRs.

---

## Status

A arquitetura da camada de database está definida utilizando Amazon RDS PostgreSQL e Terraform.

A implementação contempla:

* [x] Amazon RDS PostgreSQL;
* [x] DB Subnet Group;
* [x] RDS Security Group;
* [x] Private Subnets;
* [x] Criptografia do storage;
* [x] Backups;
* [x] Performance Insights;
* [x] CloudWatch Logs;
* [x] PostgreSQL Parameter Group;
* [x] `pg_stat_statements`;
* [x] Usuário de autenticação;
* [x] Usuário de monitoramento;
* [x] Outputs para integração entre repositórios;
* [x] Documentação da arquitetura;
* [x] ADRs das principais decisões arquiteturais.

A infraestrutura pode ser provisionada ou destruída conforme a necessidade do ambiente AWS Academy.
