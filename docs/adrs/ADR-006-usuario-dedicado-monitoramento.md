# ADR-006 — Utilização de Usuário Dedicado para Monitoramento do PostgreSQL

**Status:** Aceito  

## Contexto

A solução de observabilidade do projeto precisa acessar informações do PostgreSQL.

Utilizar o usuário administrador do banco para ferramentas de monitoramento aumenta o risco de segurança.

O usuário administrativo possui permissões superiores às necessárias para atividades de monitoramento.

É necessário aplicar o princípio do menor privilégio.

## Decisão

Será utilizado um usuário dedicado para monitoramento:

```text
monitoring_user
```

O usuário receberá permissões específicas para leitura e monitoramento.

As permissões incluem:

```text
GRANT CONNECT ON DATABASE oficina TO monitoring_user;
GRANT USAGE ON SCHEMA public TO monitoring_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO monitoring_user;
```

Também será utilizada a role:

```text
GRANT pg_monitor TO monitoring_user;
```

## Privilégios futuros

Para garantir acesso a novas tabelas criadas no schema, será utilizada a configuração:

```text
ALTER DEFAULT PRIVILEGES
FOR ROLE oficina_admin
IN SCHEMA public
GRANT SELECT ON TABLES TO monitoring_user;
```

## Justificativa

A utilização de um usuário dedicado permite separar:

Administração;
Aplicação;
Monitoramento.

A ferramenta de observabilidade não precisa possuir permissões de escrita ou administração completa.

## Consequências

### Positivas

Aplicação do princípio do menor privilégio;
Redução do risco associado ao monitoramento;
Separação de responsabilidades;
Maior controle sobre permissões;
Possibilidade de revogar acesso sem afetar a aplicação.

### Negativas

Maior quantidade de usuários para administrar;
Necessidade de gerenciar credenciais;
Necessidade de revisar permissões conforme o banco evolui.

## Segurança

O usuário de monitoramento não deve ser utilizado pela aplicação.

As credenciais devem ser armazenadas fora do código-fonte.

O valor real da senha não deve ser versionado em arquivos SQL públicos.

## Limitação conhecida

As permissões padrão dependem do papel utilizado para criar novas tabelas.

A configuração:

```text
ALTER DEFAULT PRIVILEGES
FOR ROLE oficina_admin
```

somente afeta objetos criados pelo papel especificado.

Caso outro usuário crie tabelas, permissões adicionais poderão ser necessárias.

## Decisão final

Será utilizado um usuário dedicado chamado monitoring_user, com permissões específicas para leitura e monitoramento do PostgreSQL.
