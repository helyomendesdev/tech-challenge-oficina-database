# ADR-007 — Utilização de Usuário Restrito para o Serviço de Autenticação

**Status:** Aceito  

## Contexto

O componente responsável pela autenticação precisa acessar informações específicas armazenadas no banco de dados.

O serviço de autenticação não necessita possuir acesso administrativo completo ao PostgreSQL.

Permitir acesso amplo ao banco aumentaria os riscos de segurança.

É necessário restringir as permissões de acordo com a responsabilidade do serviço.

## Decisão

Será utilizado um usuário específico para o serviço de autenticação:

```text
oficina_auth
```

O usuário receberá apenas as permissões necessárias para consultar as informações utilizadas pelo processo de autenticação.

A configuração atual inclui:

```text
GRANT CONNECT ON DATABASE oficina TO oficina_auth;
GRANT USAGE ON SCHEMA public TO oficina_auth;
GRANT SELECT ON TABLE atendimento_cliente TO oficina_auth;
```

## Justificativa

A utilização de um usuário específico permite aplicar o princípio do menor privilégio.

O serviço de autenticação possui acesso apenas aos dados necessários para executar sua responsabilidade.

Essa abordagem reduz o impacto caso as credenciais do serviço sejam comprometidas.

## Consequências

### Positivas

Menor privilégio;
Separação de responsabilidades;
Redução da superfície de acesso;
O serviço não possui permissões administrativas;
O serviço não possui permissões de escrita.

### Negativas

Necessidade de manter permissões específicas;
Alterações no fluxo de autenticação podem exigir novas permissões;
Dependência da estrutura da tabela utilizada pelo serviço.

## Arquitetura

```text
Serviço de Autenticação
          │
          │ SELECT
          ▼
    atendimento_cliente
          │
          ▼
      PostgreSQL
```

O serviço não possui acesso irrestrito ao banco.

## Segurança

A senha do usuário:

```text
oficina_auth
```

não deve ser armazenada diretamente no código-fonte.

O valor:

```text
ALTERAR_SENHA
```

deve ser substituído por uma credencial segura.

A credencial real deve ser armazenada através de um mecanismo apropriado para gerenciamento de Secrets.

## Decisão final

O serviço de autenticação utilizará um usuário PostgreSQL dedicado com permissões restritas às operações necessárias.
