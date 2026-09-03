# ADR-010 — Consideração das Limitações do Ambiente AWS Academy

**Status:** Aceito  

## Contexto

O projeto Tech Challenge Oficina utiliza o ambiente AWS Academy Learner Lab.

Esse ambiente possui restrições relacionadas às permissões disponíveis na conta AWS.

As permissões disponíveis não são equivalentes às permissões de uma conta AWS convencional.

Determinadas operações relacionadas a IAM e outros recursos podem ser limitadas.

Essas limitações precisam ser consideradas durante o desenvolvimento e o provisionamento da infraestrutura.

## Decisão

A infraestrutura será projetada considerando as permissões disponíveis no ambiente AWS Academy.

Quando uma funcionalidade depender da criação ou modificação de recursos IAM não permitidos pelo ambiente, a limitação será documentada.

Sempre que possível, serão utilizadas Roles disponibilizadas pelo próprio ambiente AWS Academy.

## Situação

Alguns recursos da AWS podem exigir IAM Roles específicas.

Exemplo:

```text
Enhanced Monitoring
        │
        ▼
Precisa de IAM Role
        │
        ▼
AWS Academy restringe criação de Role
        │
        ▼
Funcionalidade não implementada no momento
```

Essa situação não representa necessariamente um erro no Terraform.

A funcionalidade pode depender de permissões que não estão disponíveis no ambiente AWS Academy.

## Consequências

### Positivas

A infraestrutura permanece compatível com o ambiente disponível;
Redução de tentativas de provisionamento de recursos não permitidos;
Melhor documentação das limitações;
Separação entre erro de implementação e restrição do ambiente.

### Negativas
Algumas funcionalidades da AWS não podem ser implementadas;
A arquitetura acadêmica pode ser diferente de uma arquitetura de produção;
Alguns recursos podem precisar ser adaptados ou removidos.

## Limitações conhecidas

O ambiente AWS Academy pode restringir:

Criação de IAM Users;
Criação de IAM Groups;
Criação de determinadas IAM Roles;
Alteração de permissões IAM;
Utilização de determinados serviços ou configurações.

As permissões disponíveis devem ser verificadas antes da implementação de novos recursos.

## Produção

Em uma conta AWS convencional, as limitações do AWS Academy não se aplicariam necessariamente.

Uma arquitetura de produção poderia utilizar recursos adicionais, incluindo:

Roles específicas para monitoramento;
Estratégias mais avançadas de gerenciamento de Secrets;
Backends remotos para Terraform;
Políticas IAM específicas;
Recursos adicionais de observabilidade.

## Decisão final

As limitações do AWS Academy serão consideradas como restrições conhecidas do ambiente acadêmico.

Funcionalidades não implementadas devido à ausência de permissões serão documentadas.

Essas limitações não devem ser interpretadas automaticamente como erros na infraestrutura Terraform.
