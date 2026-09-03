# ADR-001 — Utilização do Amazon RDS com PostgreSQL

**Status:** Aceito  

## Contexto

A aplicação Tech Challenge Oficina necessita de um banco de dados relacional para armazenar informações relacionadas ao domínio da oficina.

A arquitetura da Fase 3 possui requisitos relacionados a:

- Escalabilidade;
- Disponibilidade;
- Segurança;
- Separação de responsabilidades;
- Infraestrutura em nuvem;
- Redução da complexidade operacional.

Nas versões anteriores da aplicação, o banco de dados poderia ser executado localmente ou em containers.

Para a arquitetura em nuvem, foi decidido utilizar um serviço gerenciado de banco de dados.

## Decisão

Será utilizado o **Amazon RDS** com **PostgreSQL** como banco de dados principal da aplicação.

A instância será provisionada utilizando Terraform.

A configuração atual utiliza:

- Engine: PostgreSQL;
- Versão: PostgreSQL 17;
- Instância gerenciada pelo Amazon RDS;
- Armazenamento `gp3`;
- Criptografia de armazenamento;
- Backups automáticos;
- Logs integrados ao CloudWatch.

## Justificativa

A utilização do Amazon RDS permite delegar parte das responsabilidades operacionais à AWS.

O serviço fornece recursos gerenciados para:

- Provisionamento da instância;
- Armazenamento;
- Backups;
- Monitoramento;
- Logs;
- Configuração de parâmetros;
- Manutenção da infraestrutura do banco.

O PostgreSQL foi escolhido por ser um banco de dados relacional robusto e compatível com a aplicação existente.

Além disso, a aplicação já utiliza PostgreSQL, evitando uma migração de tecnologia.

## Consequências

### Positivas

- Redução da responsabilidade operacional sobre o banco;
- Banco de dados separado do cluster Kubernetes;
- Backups automáticos;
- Armazenamento criptografado;
- Integração com CloudWatch;
- Integração com ferramentas de monitoramento;
- Configuração centralizada através do RDS;
- Provisionamento reproduzível através de Terraform.

### Negativas

- Dependência da AWS;
- Custo associado ao serviço;
- Limitações impostas pelo ambiente AWS Academy;
- Algumas configurações administrativas do PostgreSQL são controladas pelo Amazon RDS;
- Alterações em determinados parâmetros podem exigir reinicialização da instância.

## Alternativas consideradas

### PostgreSQL executado no Kubernetes

Vantagens:

- Infraestrutura concentrada no cluster Kubernetes;
- Maior controle sobre o banco.

Desvantagens:

- Maior responsabilidade operacional;
- Necessidade de gerenciar persistência;
- Maior complexidade para backups;
- Maior complexidade para recuperação;
- Banco e aplicação compartilhando a mesma infraestrutura.

### PostgreSQL em container Docker

Vantagens:

- Simplicidade para ambientes locais;
- Facilidade de reprodução.

Desvantagens:

- Não representa adequadamente um banco de dados gerenciado em produção;
- Maior responsabilidade sobre backups e persistência;
- Menor integração com serviços gerenciados da AWS.

### Amazon RDS PostgreSQL

Vantagens:

- Serviço gerenciado;
- Backups automáticos;
- Criptografia;
- Monitoramento;
- Integração com CloudWatch;
- Separação entre aplicação e banco de dados.

Desvantagens:

- Dependência da AWS;
- Custo;
- Menor controle sobre algumas configurações internas.

## Decisão final

Será utilizado o Amazon RDS com PostgreSQL como banco de dados principal da aplicação.

A infraestrutura será provisionada utilizando Terraform e permanecerá separada do cluster Kubernetes.
