CREATE USER monitoring_user WITH PASSWORD 'ALTERAR_SENHA';

GRANT CONNECT ON DATABASE oficina TO monitoring_user;

GRANT USAGE ON SCHEMA public TO monitoring_user;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO monitoring_user;

ALTER DEFAULT PRIVILEGES
FOR ROLE oficina_admin
IN SCHEMA public
GRANT SELECT ON TABLES TO monitoring_user;

GRANT pg_monitor TO monitoring_user;
