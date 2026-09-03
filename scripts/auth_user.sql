CREATE USER oficina_auth WITH PASSWORD 'ALTERAR_SENHA';

GRANT CONNECT ON DATABASE oficina TO oficina_auth;

GRANT USAGE ON SCHEMA public TO oficina_auth;

GRANT SELECT ON TABLE atendimento_cliente TO oficina_auth;
