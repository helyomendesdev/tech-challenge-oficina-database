# ADR-004 — Utilização de Criptografia e Backups Automáticos no Amazon RDS

**Status:** Aceito  

## Contexto

O banco de dados armazena informações persistentes da aplicação.

A arquitetura precisa considerar requisitos relacionados à segurança e recuperação de dados.

O Amazon RDS oferece mecanismos gerenciados para:

- Criptografia do armazenamento;
- Backups automáticos;
- Snapshots.

## Decisão

A instância PostgreSQL será configurada com:

```text
storage_encrypted = true
```

Também será configurada retenção de backups automáticos por:

7 dias

Configuração:

backup_retention_period = 7

## Justificativa

A criptografia do armazenamento protege os dados persistidos no RDS.

Os backups automáticos permitem recuperação em caso de problemas relacionados aos dados ou à infraestrutura.

A retenção de sete dias foi considerada suficiente para o contexto acadêmico do projeto.

## Consequências

### Positivas

Dados armazenados de forma criptografada;
Backups automáticos;
Maior capacidade de recuperação;
Redução da responsabilidade operacional.

### Negativas

A configuração de backups pode gerar custos;
A retenção atual é limitada;
A política não representa necessariamente uma configuração definitiva para produção.

## Limitação conhecida

A infraestrutura atual possui:

deletion_protection = false
skip_final_snapshot = true

Essas configurações facilitam a remoção da infraestrutura durante o desenvolvimento e os testes.

Entretanto, não são ideais para um ambiente de produção.

Em produção, recomenda-se:

Habilitar proteção contra exclusão;
Criar snapshot final antes da remoção;
Definir políticas formais de retenção;
Definir procedimentos de recuperação.

## Alternativas consideradas

### Sem backups automáticos

Vantagens:

Menor complexidade.

Desvantagens:

Maior risco de perda de dados;
Sem mecanismo automatizado de recuperação.

### Backups automáticos

Vantagens:

Recuperação mais simples;
Serviço gerenciado;
Maior proteção contra perda de dados.

Desvantagens:

Custos adicionais;
Necessidade de definir retenção.

## Decisão final

A instância Amazon RDS utilizará armazenamento criptografado e backups automáticos com retenção de sete dias.

As configurações relacionadas à remoção da instância são consideradas adequadas apenas para o contexto atual de desenvolvimento e ambiente acadêmico.
