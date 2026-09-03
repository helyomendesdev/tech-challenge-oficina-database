# ADR-008 — Utilização de Parameter Group Customizado para PostgreSQL

**Status:** Aceito  

## Contexto

O Amazon RDS utiliza Parameter Groups para configurar determinados parâmetros do banco de dados.

A configuração padrão não contém necessariamente todos os parâmetros necessários para os requisitos de observabilidade do projeto.

O PostgreSQL precisa ser configurado para:

- Carregar `pg_stat_statements`;
- Registrar consultas lentas;
- Monitorar consultas;
- Coletar informações de I/O.

## Decisão

Será utilizado um Parameter Group customizado para PostgreSQL.

A configuração será provisionada utilizando Terraform.

Os principais parâmetros incluem:

```text
shared_preload_libraries = pg_stat_statements
log_min_duration_statement = 1000
pg_stat_statements.track = all
track_io_timing = 1
```

## Justificativa

A utilização de um Parameter Group customizado permite:

Versionar configurações através do Terraform;
Reproduzir a infraestrutura;
Documentar parâmetros importantes;
Evitar alterações manuais no console da AWS.

## Consequências

### Positivas

Infraestrutura reproduzível;
Configuração declarativa;
Melhor controle sobre parâmetros;
Suporte aos requisitos de observabilidade.

### Negativas

Algumas alterações exigem reinicialização;
Alterações de parâmetros precisam ser avaliadas;
Configurações incorretas podem afetar o desempenho.

## Aplicação dos parâmetros

Os parâmetros podem possuir diferentes métodos de aplicação.

### Immediate

Algumas alterações são aplicadas imediatamente.

### Pending Reboot

Algumas alterações exigem reinicialização da instância.

O parâmetro:

```text
shared_preload_libraries
```

utiliza:

```text
pending-reboot
```

## Limitação conhecida

A criação da extensão:

```text
CREATE EXTENSION pg_stat_statements;
```

não substitui a necessidade de configurar:

```text
shared_preload_libraries
```

A biblioteca precisa estar carregada pelo PostgreSQL.

## Decisão final

Será utilizado um Parameter Group customizado provisionado através de Terraform para configurar os parâmetros necessários ao PostgreSQL e à estratégia de observabilidade.
