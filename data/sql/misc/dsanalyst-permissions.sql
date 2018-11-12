
/* Original source of query: https://dba.stackexchange.com/questions/95867/grant-usage-on-all-schemas-in-a-database */

DO $do$
DECLARE
    sch text;
BEGIN
    FOR sch IN SELECT nspname FROM pg_namespace WHERE nspname not like 'pg_%' and nspname != 'information_schema' and nspname != 'looker_scratch'
    LOOP
        EXECUTE format($$ GRANT USAGE ON SCHEMA %I TO dsanalyst $$, sch);
        EXECUTE format($$ GRANT SELECT ON ALL TABLES IN SCHEMA %I to dsanalyst $$, sch);
        EXECUTE format($$ GRANT TEMP ON DATABASE quasar to dsanalyst $$, sch);
    END LOOP;
END;
$do$;
