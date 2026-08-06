# Tech Challenge Oficina — Infraestrutura do Banco

Infraestrutura como código do banco de dados gerenciado da Fase 3 do Tech Challenge FIAP.

## Responsabilidade

- Provisionar banco relacional gerenciado com Terraform.
- Configurar rede, parâmetros, backups e disponibilidade.
- Separar homologação e produção.
- Publicar somente outputs necessários aos demais componentes.
- Documentar modelo relacional, relacionamentos, índices e decisões de performance.

Responsável técnica: Sophia Sussa Campos Bastos (`sophiasussa`).

## Decisões pendentes

Devem ser registradas em RFC/ADR antes da implementação definitiva:

- Provedor e serviço de banco gerenciado.
- Versão e parâmetros do PostgreSQL ou alternativa escolhida.
- Estratégia de backup e recuperação.
- Alta disponibilidade.
- Estado remoto do Terraform.
- Gestão de credenciais e rotação de segredos.

## Estrutura planejada

```text
terraform/
  modules/
  environments/
    homologacao/
    producao/
docs/
  adrs/
  rfcs/
  modelo-relacional/
```

A estrutura será implementada após validação com a responsável pela infraestrutura.

## Branches e ambientes

- `develop`: homologação.
- `main`: produção.
- Mudanças entram exclusivamente por Pull Request.

## Status

Estrutura inicial criada. Terraform e CI/CD serão adicionados após a escolha da nuvem e do banco.
