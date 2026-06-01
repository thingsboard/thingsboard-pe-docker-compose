# Docker configuration for ThingsBoard Microservices

This folder containing scripts and Docker Compose configurations to run ThingsBoard in Microservices mode. 

See official [documentation page](https://thingsboard.io/docs/user-guide/install/pe/cluster/docker-compose-setup/) for more details.

## Citus (distributed PostgreSQL)

For large-scale deployments the single `postgres` service can be replaced with a [Citus](https://www.citusdata.com/) cluster
(a coordinator plus worker nodes) that distributes ThingsBoard tables across shards. This is a ThingsBoard PE feature and is
only supported with the **advanced** setup and `DATABASE=postgres`.

To enable it, set the following in `.env`:

```bash
TB_SETUP=advanced
DATABASE=postgres
CITUS_ENABLED=true
# Number of shards for the distributed tables. Must match DATABASE_CITUS_SHARD_COUNT passed to tb-node.
CITUS_SHARD_COUNT=32
```

When `CITUS_ENABLED=true`:

- The single `postgres` service is replaced by `citus-coordinator`, `citus-worker-1`, `citus-worker-2` and a
  `citus-manager` (membership manager) that automatically registers the workers with the coordinator on startup.
  No manual `citus_add_node` calls are required.
- The `tb-node` services connect to `citus-coordinator` and receive `DATABASE_CITUS_ENABLED=true` and
  `DATABASE_CITUS_SHARD_COUNT=${CITUS_SHARD_COUNT}`. `CITUS_SHARD_COUNT` must be kept in sync with the value baked into the
  schema; changing it after the database has been distributed is not supported.

When `CITUS_ENABLED=false` (the default) the deployment uses the single `postgres` service exactly as before; the Citus
files are inert.

A **fresh install** with `CITUS_ENABLED=true` distributes the schema automatically. To **convert an existing single-postgres
database** to Citus, run the upgrade during downtime:

```bash
./docker-upgrade-tb.sh --fromVersion=postgres-to-citus
```

Make sure `CITUS_ENABLED=true` is set in `.env` before converting so the upgrade container runs with
`DATABASE_CITUS_ENABLED=true` against the coordinator.

