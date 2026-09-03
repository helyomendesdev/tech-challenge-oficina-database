# ADR-005 — Monitoramento e Observabilidade do PostgreSQL

**Status:** Aceito  

## Contexto

A arquitetura do projeto possui requisitos relacionados a monitoramento e observabilidade.

O banco de dados é um componente crítico da aplicação.

Problemas relacionados ao banco podem afetar:

- Disponibilidade;
- Latência;
- Performance;
- Consumo de recursos;
- Execução de consultas.

É necessário disponibilizar informações suficientes para análise do comportamento do PostgreSQL.

## Decisão

A infraestrutura utilizará recursos do PostgreSQL e do Amazon RDS para apoiar o monitoramento.

A configuração inclui:

- Performance Insights;
- Exportação de logs PostgreSQL;
- Extensão `pg_stat_statements`;
- Parâmetros de monitoramento do PostgreSQL;
- Usuário dedicado ao monitoramento;
- Role `pg_monitor`.

## Configuração

### Performance Insights

A instância RDS possui:

```text
performance_insights_enabled = true
```

A retenção configurada é de:

7 dias

### Logs PostgreSQL

Os logs PostgreSQL são exportados.

Configuração:

```text
enabled_cloudwatch_logs_exports = ["postgresql"]
```

### pg_stat_statements

A extensão:

```text
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

é utilizada para coletar estatísticas relacionadas à execução de consultas.

### shared_preload_libraries

O PostgreSQL é configurado para carregar:

```text
pg_stat_statements
```

Essa configuração é realizada através do Parameter Group.

### log_min_duration_statement

Consultas com duração superior a:

```text
1000 ms
```

podem ser registradas para análise.

### pg_stat_statements.track

A configuração:

```text
all
```

permite acompanhar diferentes tipos de comandos SQL.

### track_io_timing

A configuração:

```text
track_io_timing = 1
```

permite coletar informações relacionadas ao tempo de operações de I/O.

## Justificativa

O monitoramento do banco permite identificar problemas como:

Consultas lentas;
Alto consumo de recursos;
Gargalos de I/O;
Consultas executadas com frequência;
Problemas de performance.

A utilização de mecanismos nativos do PostgreSQL reduz a necessidade de modificar a aplicação para coletar determinadas informações.

## Consequências

### Positivas

Maior visibilidade sobre o comportamento do banco;
Identificação de consultas lentas;
Análise de performance;
Integração com CloudWatch;
Integração com ferramentas externas de observabilidade.

### Negativas

Coleta adicional de métricas pode gerar overhead;
Algumas configurações exigem reinicialização;
Dados de monitoramento precisam ser protegidos.

## Limitação conhecida

A configuração:

```text
shared_preload_libraries = pg_stat_statements
```

utiliza:

```text
apply_method = pending-reboot
```

Portanto, a alteração não é aplicada imediatamente.

A instância precisa ser reinicializada para que a configuração seja efetivamente carregada.

## Decisão final

O PostgreSQL utilizará mecanismos nativos de monitoramento, incluindo pg_stat_statements, logs PostgreSQL e Performance Insights.
