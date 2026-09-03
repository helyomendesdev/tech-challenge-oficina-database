# ADR-003 — Restrição de Acesso ao RDS através de Security Groups

**Status:** Aceito  

## Contexto

A aplicação executada no Amazon EKS precisa acessar o banco PostgreSQL executado no Amazon RDS.

O banco não deve aceitar conexões indiscriminadas provenientes da rede.

É necessário definir quais recursos podem estabelecer conexões com o RDS.

A infraestrutura utiliza Security Groups da AWS para controlar o tráfego entre os componentes.

## Decisão

O Security Group do Amazon RDS permitirá conexões PostgreSQL somente a partir do Security Group utilizado pelo ambiente EKS.

A porta permitida será:

```text
5432/TCP
```

A regra será configurada utilizando referência entre Security Groups.

Exemplo conceitual:

```text
EKS Security Group
        │
        │ TCP 5432
        ▼
RDS Security Group
        │
        ▼
PostgreSQL
```

## Justificativa

A utilização de referências entre Security Groups permite restringir o acesso com base na identidade dos recursos da AWS.

Essa abordagem evita a necessidade de liberar a porta PostgreSQL para:

```text
0.0.0.0/0
```

ou para intervalos amplos de IP.

## Consequências

### Positivas

Redução da superfície de ataque;
Acesso limitado aos recursos autorizados;
Menor dependência de endereços IP específicos;
Melhor integração entre infraestrutura EKS e RDS;
Configuração declarativa através do Terraform.

### Negativas

Dependência entre os repositórios de infraestrutura;
O Security Group correto do EKS precisa ser utilizado;
Mudanças na infraestrutura do EKS podem exigir atualização das variáveis do RDS.
Integração entre repositórios

O repositório de infraestrutura Kubernetes disponibiliza o Security Group necessário através de um output.

Exemplo:

```text
eks_cluster_security_group_id
```

Esse valor é utilizado pelo repositório do banco para configurar a regra de entrada do RDS.

## Limitação conhecida

É necessário garantir que o Security Group utilizado realmente represente os recursos que precisam acessar o banco.

Managed Node Groups podem utilizar Security Groups criados ou associados automaticamente pelo Amazon EKS.

Portanto, deve ser validado o Security Group efetivamente utilizado pelos nodes e pelas interfaces responsáveis pelo tráfego da aplicação.

## Alternativas consideradas

### Liberar PostgreSQL para toda a internet

0.0.0.0/0

Desvantagens:

Exposição desnecessária;
Alto risco de segurança;
Não adequado para a arquitetura.

### Utilizar CIDR da VPC

Vantagens:

Configuração simples.

Desvantagens:

Permite acesso de diversos recursos da VPC;
Menor granularidade.

### Utilizar Security Group do EKS

Vantagens:

Maior restrição;
Comunicação baseada em grupos de segurança;
Menor dependência de IPs.

Desvantagens:

Dependência entre componentes da infraestrutura.

## Decisão final

O Amazon RDS permitirá conexões PostgreSQL na porta 5432 apenas a partir do ambiente autorizado do Amazon EKS através de referências entre Security Groups.
