# Replication management

The application relies on the [logical decoding mechanism](https://www.postgresql.org/docs/current/logicaldecoding-explanation.html) of the PostgreSQL. 
Logical decoding is the process of extracting all persistent changes to a database's tables into a coherent, easy to understand format which can be interpreted without detailed knowledge of the database's internal state.
It is implemented by decoding the contents of the WAL (write-ahead log), which is sent as a stream of changes via an output plugin.
PG2SQS works with the built-in `pgoutput` plugin.

## Replication slots
The stream of changes is represented by a logical replication slot. Each slot streams a sequence of changes from a single database.
Replication slots state is persisted independently of the connection using them (usually at checkpoint) and are crash-safe. 
This means that if the application stops for any reason, upon restart it continues reading the WAL where it left off last time. 

However, in some cases, when a PostgreSQL server crashes, the slot may return to an earlier position in WAL and will then cause recent changes to be sent again.
To prevent such cases to a certain degree, the application saves its state into the `pgwalk.app_state` table. See [Database setup](config.md#database-setup). 

The logical replication slot can be created with the following query:

```sql
SELECT pg_create_logical_replication_slot('my_replication_slot', 'pgoutput');
```

Replication slots are guaranteed to retain all WAL segments not yet read by the consumer. For this reason, unused replication slots may cause high disk space consumption, and it is important to monitor the state of the replication slots. 
See [streaming replication slots](https://www.postgresql.org/docs/current/warm-standby.html#STREAMING-REPLICATION-SLOTS) in the official PostgreSQL docs.


## Limitations

Logical decoding has some limitations:
1. In a replicated setup, when the application runs on the primary, it may publish a message before the data gets replicated.
2. It does not capture values for generated columns. 
   3. **NOTE:** Starting from **PostgreSQL 18** it's possible to configure logical decoding to replicate generated columns. See [Generated Column Replication](https://www.postgresql.org/docs/18/logical-replication-gencols.html). 

## Slot replication

In **PostgreSQL versions <= 15**, a logical replication slot can only be created on the primary server. This means that the application can only work with the active primary server. It is important to correctly promote the standby and create a replication slot manually. The slot must be created before any changes are done to the data.

In **PostgreSQL 16** it is possible to create logical replication slots on replicas. In this case you can set `host` to the comma-separated list of the PostgreSQL servers. The application connects to the active primary node. But it will also synchronize slot's state across replicas on a best-effort basis. This means that in case of a failure the application would report the error but won't quit.

In **PostgreSQL >= 17** you can configure replication slots on a primary server for automatic failover. See [Logical replication failover](https://www.postgresql.org/docs/17/logical-replication-failover.html) and [Replication slot synchronization](https://www.postgresql.org/docs/17/logicaldecoding-explanation.html#LOGICALDECODING-REPLICATION-SLOTS-SYNCHRONIZATION) in the official PostgreSQL docs.   

The most important settings are:
1. On the PRIMARY: `standby_slot_names` (see [Stand by slot names](https://www.postgresql.org/docs/17/runtime-config-replication.html#GUC-STANDBY-SLOT-NAMES))
2. On the REPLICA: `sync_replication_slots = on` and `hot_standby_feedback = on` (see [Replication slot synchronization](https://www.postgresql.org/docs/17/logicaldecoding-explanation.html#LOGICALDECODING-REPLICATION-SLOTS-SYNCHRONIZATION))
