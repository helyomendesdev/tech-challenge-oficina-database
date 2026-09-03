# ADR-009 — Integração da Infraestrutura por Variáveis e Outputs do Terraform

**Status:** Aceito  

## Contexto

O projeto Tech Challenge Oficina possui múltiplos repositórios.

Entre eles:

- Repositório da aplicação;
- Repositório Kubernetes;
- Repositório do banco de dados;
- Repositório de autenticação.

A infraestrutura do banco depende de informações provisionadas pelo repositório Kubernetes.

Entre essas informações estão:

- ID da VPC;
- IDs das subnets privadas;
- Security Group utilizado para comunicação com o EKS.

É necessário definir como essas informações serão compartilhadas.

## Decisão

O repositório do banco receberá as informações externas através de variáveis Terraform.

O repositório Kubernetes disponibilizará as informações necessárias através de outputs.

Exemplos:

```text
vpc_id
private_subnet_ids
eks_cluster_security_group_id
```

Esses valores serão informados ao Terraform do banco.

## Justificativa

Essa abordagem mantém os repositórios separados.

O repositório do banco não precisa criar ou controlar diretamente a infraestrutura do EKS.

Cada repositório mantém responsabilidade sobre seus próprios recursos.

## Fluxo

```text
tech-challenge-oficina-k8s
            │
            │ Terraform Outputs
            ▼
      Valores da Infraestrutura
            │
            ▼
tech-challenge-oficina-database
            │
            │ Terraform Variables
            ▼
        Amazon RDS
```

## Consequências

### Positivas

Separação de responsabilidades;
Menor acoplamento entre códigos Terraform;
Reutilização da infraestrutura existente;
Maior clareza sobre dependências.

### Negativas
Processo manual de compartilhamento de valores;
Necessidade de manter os valores atualizados;
Possibilidade de utilizar valores incorretos.

## Limitação conhecida

A infraestrutura atual não utiliza um backend remoto compartilhado ou Terraform Remote State para integração automática entre repositórios.

Portanto, os valores podem precisar ser transferidos manualmente.

Essa abordagem é considerada suficiente para o contexto acadêmico atual.

## Alternativas futuras

Uma evolução possível seria utilizar:

Terraform Remote State;
Pipeline de CI/CD para compartilhamento de outputs;
AWS Systems Manager Parameter Store;
Outros mecanismos centralizados de configuração.

## Decisão final

O repositório do banco utilizará variáveis Terraform para receber informações da infraestrutura Kubernetes.

Os valores serão obtidos através dos outputs disponibilizados pelo repositório responsável pelo Kubernetes.
