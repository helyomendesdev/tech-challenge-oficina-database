# Architecture Decision Records (ADRs)

Esta pasta contém os Architecture Decision Records (ADRs) relacionados à infraestrutura e à arquitetura do banco de dados do projeto Tech Challenge Oficina.

Os ADRs têm como objetivo registrar as principais decisões arquiteturais, seus motivos, alternativas consideradas e consequências. Dessa forma, a documentação permite compreender não apenas o que foi implementado, mas também por que determinadas decisões foram tomadas.

## Estrutura

Os ADRs estão organizados cronologicamente:

```text
docs/
└── adrs/
    ├── ADR-001-utilizacao-amazon-rds-postgresql.md
    ├── ADR-002-rds-em-subnets-privadas.md
    ├── ADR-003-acesso-rds-restrito-ao-eks.md
    ├── ADR-004-criptografia-e-backups-do-rds.md
    ├── ADR-005-monitoramento-e-observabilidade-do-postgresql.md
    ├── ADR-006-usuario-dedicado-monitoramento.md
    ├── ADR-007-usuario-restrito-para-autenticacao.md
    ├── ADR-008-parameter-group-customizado.md
    ├── ADR-009-integracao-entre-repositorios.md
    └── ADR-010-limitacoes-do-aws-academy.md
```
