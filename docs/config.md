# Configuration Guide

This document describes how to configure the application using either YAML configuration files or environment variables.

## Configuration Methods

The application can be configured using either:
1. YAML configuration file
2. Environment variables

Environment variables take precedence over YAML configuration values.

## YAML Configuration

App loads the config file in the following order:
1. `/etc/opt/pg2sqs/config.yaml`
2. `./config.yaml`
3. File defined by the `PG2SQS_CONFIG_PATH` env variable. The app won't start if the env var is set but the file does not exist

## Environment Variables

All configuration options can be set using environment variables. The naming convention follows the structure of the YAML configuration, using underscores as separators and uppercase letters.

## Main Configuration

### `debug`, `PG2SQS_DEBUG`
  - Enable debug mode (true/false)

### `flushInterval`, `PG2SQS_FLUSHINTERVAL`
  - Interval for flushing data to the downstream. Default is `500ms`. When a value does not have time units, the milliseconds are assumed. See [Time units](#time-units)

### `flushWorkers`, `PG2SQS_FLUSHWORKERS`
  - Number of parallel workers used to send downstream requests. The default value is the container-aware number of CPU.

### `maxWriteQueueSize`, `PG2SQS_MAXWRITEQUEUESIZE`
  - Controls the maximum length of the downstream write queue, which is unlimited by default.
    This setting serves two primary purposes:
    1. Prevents overwhelming the downstream system
    2. Controls memory usage by limiting the number of in-memory messages awaiting acknowledgment
  - The `maxWriteQueueSize` setting limits the number of pending messages. When this limit is reached, the application will continue processing the current transaction. After that, the app won't generate new messages until the queue size drops below the limit. This ensures that transactions remain atomic while preventing memory overflow.

### `writeTimeout`, `PG2SQS_WRITETIMEOUT` 
  - Downstream wait timeout. Defines how much time to wait until a downstream request succeeded. See [Time units](#time-units).
    Without the time units, seconds are assumed. Default is 10 seconds.

### `shutdownTimeout`, `PG2SQS_SHUTDOWNTIMEOUT`
  - Timeout for graceful shutdown. See [Time units](#time-units).

### `statsInterval`, `PG2SQS_STATSINTERVAL`
  - Interval of printing application statistics. See [Time units](#time-units).

### Retry policy, `retryPolicy`
  Retry policy for the failed messages.
  - #### `maxRetries`, `PG2SQS_RETRYPOLICY_MAXRETRIES`
    - Maximum number of retry attempts for failed operations. 
    - Should be >= 1.
    - Defines how many times an operation will be retried before giving up.
  - #### `maxConnectionRetries`, `PG2SQS_RETRYPOLICY_MAXCONNECTIONRETRIES`
    - Maximum number of connection retry attempts.
    - Should be >= 0.
    - Specifies the maximum number of times to retry establishing a connection. A value of 0 means connection retries will
      be attempted forever.
    - When `maxConnectionRetries` value is greater than 0, the application will terminate after the specified number of failed
      connection attempts.
  - #### `initialBackoff`, `PG2SQS_RETRYPOLICY_INITIALBACKOFF`
    - Initial wait time between retry attempts.
    - Should be > 0.
    - The base duration to wait before the first retry attempt. Subsequent retries may be modified by the multiplier and jitter values.
  - #### `multiplier`, `PG2SQS_RETRYPOLICY_MULTIPLIER`
    - Backoff multiplier between retry attempts. 
    - Should be >= 1. 
    - Multiplier applied to the backoff duration for each subsequent retry. A value of 1.0 means the backoff duration remains constant between retries.
  - #### `jitter`, `PG2SQS_RETRYPOLICY_JITTER`
    - Random variation in retry timing.
    - Should be within [0.0, 1.0] range.
    - Adds randomness to the backoff duration to prevent thundering herd problems. A value of 0.4 means the actual backoff time will be randomly adjusted by up to ±40%.
  - #### `maxBackoff`, `PG2SQS_RETRYPOLICY_MAXBACKOFF`
    - Maximum backoff duration.
    - Should be > 0.
    - The upper limit for the backoff duration, regardless of the multiplier and number of retries. Ensures that retry attempts don't wait longer than this specified time.
 
### Postgres Configuration, `postgres`
  - #### Connection settings, `conn`
    - `host`, `PG2SQS_POSTGRES_CONN_HOST`
      - Host. Can be a comma-separated list of the hosts. The application connects to the active primary server. 
    - `port`, `PG2SQS_POSTGRES_CONN_PORT`
      - Port.
    - `database`, `PG2SQS_POSTGRES_CONN_DATABASE` 
      - Database name.
    - `user`, `PG2SQS_POSTGRES_CONN_USER` 
      - Database user.
    - `password`, `PG2SQS_POSTGRES_CONN_PASSWORD`
      - Database password.
  - #### TLS settings, `tls`
    - `cert`, `PG2SQS_POSTGRES_CONN_TLS_CERT`
      - TLS certificate path.
    - `key`, `PG2SQS_POSTGRES_CONN_TLS_KEY` 
      - TLS key path.
    - `rootCert`, `PG2SQS_POSTGRES_CONN_TLS_ROOTCERT`
      - TLS root certificate path.
  - #### Replication settings, `repl`
    - `pub`, `PG2SQS_POSTGRES_REPL_PUB`
      - Publication name.
    - `slot`, `PG2SQS_POSTGRES_REPL_SLOT` 
      - Replication slot name. See [Slot setup](#slot-setup) on how to configure slot in Postgres.
  - #### `numericMode`, `PG2SQS_POSTGRES_NUMERICMODE` 
    - Numeric mode ("float" or "string"). See [Numeric modes](#numeric-modes)
  - #### `standByTimeout`, `PG2SQS_POSTGRES_STANDBYTIMEOUT` 
    - Standby timeout. See [Time units](#time-units).
  - #### `receiveTimeout`, `PG2SQS_POSTGRES_RECEIVETIMEOUT` 
    - Receive timeout. See [Time units](#time-units).

### SQS Configuration, `sqs`

  - #### `commitTimeColumn`, `PG2SQS_SQS_COMMITTIMECOLUMN`
    - The app can put transaction commit time as an additional field in the generated message. This setting specifies the name of the field in JSON.
      Only works when `track_commit_timestamp` setting is turned on (see [Postgres docs](https://www.postgresql.org/docs/current/functions-info.html#FUNCTIONS-INFO-COMMIT-TIMESTAMP)). You can enable this setting using one of the following methods:
      - `ALTER SYSTEM SET track_commit_timestamp = ON;`
      -  Edit the Postgres config file
    
      Postgres needs to be restarted for the change to take effect.

  - #### AWS config
  
  The app uses AWS SDK to access AWS services. You need to provide AWS credentials for the app to work properly.
  - AWS credentials can be provided through shared config/credentials files, environment variables, IAM roles (for
    EC2/ECS)
  - See AWS documentation on credentials configuration: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
  - Sample config via ENV vars:
```bash
AWS_REGION=<e.g. us-east-1>
AWS_ACCESS_KEY_ID=<access key ID>
AWS_SECRET_ACCESS_KEY=<secret KEY>
AWS_ENDPOINT_URL_SQS=<e.g. https://sqs.us-east-1.amazonaws.com>
```

### Table Configuration, `tables`
  - #### `<schema.table>`, `PG2SQS_T_<#num>_NAME`
    - Name of the table to read changes from. Can contain schema. When no schema is set then `public` schema is assumed.
    - `<#num>` is the index of the table. Start with zero and increment by 1 for each new table. See examples below. 
    - #### `columns`, `PG2SQS_T_<#num>_COLUMNS`
      - Comma-separated list of columns for which the application reads changes. Set `all` for all columns. 
      - Postgres version >=15 supports publications with a subset of a tables' columns. And it's possible to specify individual columns in the publication.
      - For PG version >= 12 and < 15 application reads all columns from the Postgres. Application extracts required columns in memory. 
      - ⚠️ **Primary key column(s) must be included**. 
      - ⚠️ When adding new columns with default values to a table, all existing rows will receive the default value in the database. However, these changes won't be captured by logical replication.
    - #### Queue config, `queue`
      - ##### `name`, `PG2SQS_T_<#num>_Q_NAME`
        - Name of the SQS queue
      - #### `groupID`, `PG2SQS_T_<#num>_Q_GROUPID`
        - GroupID macros. Only for FIFO queues. See [Macroses](#macroses)
      - #### update/insert/delete specific settings
        - It is possible to configure the application to send messages to a specific queue depending on the DML operation (INSERT/UPDATE/DELETE).
        - To do so, a new subsection can be added into the queue config
```yaml
tables:
  - public.customers:
    columns: [all] # or list of columns e.g. id, name, active, etc
    queue:
      name: customers.fifo
      groupID: ${%table%}-${id}
    update:
      name: customerUpdated.fifo
      groupID: <macros>  # if required
    insert:
      name: customerCreated.fifo
      groupID: <macros>  # if required
    delete:
      name: customerDeleted.fifo
      groupID: <macros>  # if required
  - public.orders:
    columns: [all]
    queue:
      name: orders
```
```bash
#same with ENV variables
PG2SQS_T_0_NAME=public.customers
PG2SQS_T_0_COLUMNS=all
PG2SQS_T_0_Q_NAME=customers.fifo
PG2SQS_T_0_Q_GROUPID=${%table%}${id} 
PG2SQS_T_0_Q_UPDATE_NAME=customerUpdated.fifo 
PG2SQS_T_0_Q_UPDATE_GROUPID=${%table%}${id} # if required 
PG2SQS_T_0_Q_INSERT_NAME=customerCreated.fifo
PG2SQS_T_0_Q_INSERT_GROUPID=${%table%}${id} # if required
PG2SQS_T_0_Q_DELETE_NAME=customerDeleted.fifo
PG2SQS_T_0_Q_DELETE_GROUPID=${%table%}${id} # if required

PG2SQS_T_1_NAME=public.orders
PG2SQS_T_1_COLUMNS=all
PG2SQS_T_1_Q_NAME=orders
```
## License
PG2SQS is a paid product. A valid license is required to use the product. 
Until November 30th, 2025 the product is in beta and everyone can use the app for free.
Set the license key to the ENV variable `PGWALK_LIC_PG2SQS`:
```bash
  PGWALK_LIC_PG2SQS=<license key>
```
Or save the key to a file and put the file path into the `PGWALK_LICFILE_PG2SQS` ENV var:
```bash
  PGWALK_LICFILE_PG2SQS=/path/to/beta/key.pg2sqslic
```
App won't start without a valid license key.

## Example config file

```yaml
postgres:
  conn:
    host: "localhost"
    port: "5432"
    database: "mydb"
    user: "postgres"
    password: "secret"
    tls:
      cert: "/path/to/cert.pem"
      key: "/path/to/key.pem"
      rootCert: "/path/to/root.pem"
  repl:
    slot: "repl_slot"
    pub: "repl_pub"
  numericMode: "float"
  standByTimeout: "30s"
  receiveTimeout: "30s"

sqs:
  commitTimeColumn: "commit_time"

tables:
  - users:
      columns: ["id", "name", "email"]
      queue:
        name: "users-queue"
        url: "https://sqs.region.amazonaws.com/123456789012/users-queue"
        groupID: "users-group"
        insert:
          name: "users-insert"
          url: "https://sqs.region.amazonaws.com/123456789012/users-insert"
        update:
          name: "users-update"
          url: "https://sqs.region.amazonaws.com/123456789012/users-update"
        delete:
          name: "users-delete"
          url: "https://sqs.region.amazonaws.com/123456789012/users-delete"

flushInterval: "500ms"
flushQueueDepth: 32
flushWorkers: 4
statsInterval: "1m"
maxWriteQueueSize: 10000
writeTimeout: "5s"
shutdownTimeout: "30s"
debug: false

retryPolicy:
  maxRetries: 10
  maxConnectionRetries: 10
  initialBackoff: "10s"
  multiplier: 2.0
  jitter: 0.1
  maxBackoff: "30s"
```

### Example configuration with ENV variables
```bash
# Main configuration
PG2SQS_POSTGRES_CONN_DATABASE=postgres
PG2SQS_POSTGRES_CONN_HOST=postgres_primary,postgres_replica
PG2SQS_POSTGRES_CONN_PORT=5432
PG2SQS_POSTGRES_CONN_USER=user
PG2SQS_POSTGRES_CONN_PASSWORD=password
PG2SQS_POSTGRES_REPL_PUB=orders_publication
PG2SQS_POSTGRES_REPL_SLOT=orders_slot
PG2SQS_POSTGRES_STANDBYTIMEOUT=15s
PG2SQS_POSTGRES_RECEIVETIMEOUT=15s

PG2SQS_SQS_COMMITTIMECOLUMN=lastUpdated

PG2SQS_FLUSHINTERVAL=500
PG2SQS_FLUSHWORKERS=3
PG2SQS_MAXWRITEQUEUESIZE=10000
PG2SQS_WRITETIMEOUT=10s
PG2SQS_SHUTDOWNTIMEOUT=20s
PG2SQS_STATSINTERVAL=5s

PG2SQS_T_0_NAME=public.customers
PG2SQS_T_0_COLUMNS=all
PG2SQS_T_0_Q_NAME=customers.fifo
PG2SQS_T_0_Q_GROUPID=${%table%}${id}
PG2SQS_T_1_NAME=public.orders
PG2SQS_T_1_COLUMNS=all
PG2SQS_T_1_Q_NAME=orders.fifo
PG2SQS_T_1_Q_GROUPID=${%table%}${id}

PG2SQS_RETRYPOLICY_MAXRETRIES=5
PG2SQS_RETRYPOLICY_MAXCONNECTIONRETRIES=0
PG2SQS_RETRYPOLICY_INITIALBACKOFF=15s
PG2SQS_RETRYPOLICY_MULTIPLIER=1
PG2SQS_RETRYPOLICY_JITTER=0.4
PG2SQS_RETRYPOLICY_MAXBACKOFF=120s

AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=DEV_ACCESS_KEY_ID_1
AWS_ENDPOINT_URL_SQS=http://172.21.0.5:9324
AWS_SECRET_ACCESS_KEY=DEV_SECRET_ACCESS_KEY_1

PG2SQS_CPUPROF_ENABLED=false
PG2SQS_WATCHXID=
PG2SQS_DEBUG=true

PGWALK_LICFILE_PG2SQS=demo.pg2sqslic
```

## Time units
For all time duration settings valid time units are `ns`, `us` (or `µs`), `ms`, `s`, `m`, `h`. 
The default unit depends on the setting.

## Numeric modes

The application supports two modes for handling PostgreSQL numeric types:

1. **float** mode (default)
  - Represents numbers by using double values
  - It may result in a loss of precision
  - Example:
    ```sql
    -- PostgreSQL
    CREATE TABLE products (
        id SERIAL PRIMARY KEY,
        price NUMERIC(10,2)
    );
    INSERT INTO products (price) VALUES (199.99);
    ```
    ```json
    // SQS Message
    {
        "price": 199.99
    }
    ```

2. **string** mode
  - Numeric values are preserved as strings
  - Maintains exact precision
  - Example:
    ```sql
    -- PostgreSQL
    CREATE TABLE products (
        id SERIAL PRIMARY KEY,
        price NUMERIC(10,3)
    );
    INSERT INTO products (price) VALUES (199.99);
    ```
    ```json
    // SQS Message
    {
        "price": "199.990"
    }
    ```

Set the mode using either:

- YAML configuration:
  ```yaml
  postgres:
    numericMode: "string"  # or "float"
  ```
- Environment variable:
  ```bash
  PG2SQS_POSTGRES_NUMERICMODE=string  # or float
  ```

### Special Numeric Values Handling

The application handles special numeric values differently depending on the selected mode:

1. **float** mode:
  - NaN (Not a Number) → `null`
  - Infinity → `null`
  - -Infinity → `null`

2. **string** mode:
  - NaN → `"NaN"`
  - Infinity → `"Infinity"`
  - -Infinity → `"-Infinity"`


## Postgres setup
Postgres logical replication uses **publications** and **replication slots** to stream data changes:
- **Publication**: Defines which tables and operations (INSERT, UPDATE, DELETE) to replicate
- **Logical Slot**: Maintains the replication state and ensures no data is lost during streaming

See [Replication management](pgrepl.md) for more details on how to manage replication slots.

1. **Configuration settings** in `postgresql.conf`:
```
  wal_level = logical
  max_replication_slots = 10  -- Adjust based on your needs
  max_wal_senders = 10        -- Should be >= max_replication_slots
```
2. **Restart Postgres** after configuration changes
3. **Appropriate permissions** for the replication user

### Creating a publication
```sql
-- Create a publication for all tables
CREATE PUBLICATION my_publication FOR ALL TABLES;

-- Create a publication for specific tables
CREATE PUBLICATION customer_orders_pub FOR TABLE customers, orders;

-- Create a publication for specific operations only
CREATE PUBLICATION insert_only_pub FOR TABLE users WITH (publish = 'insert');

-- Create a publication with specific columns (Postgres 15+)
CREATE PUBLICATION partial_pub FOR TABLE customers (id, name, email);
```

### Creating a logical replication slot
```sql
SELECT pg_create_logical_replication_slot('my_replication_slot', 'pgoutput');
```
- Second parameter for the `pg_create_logical_replication_slot` must be `pgoutput`. Application won't start otherwise.

### Database setup

Min supported Postgres version is 12.

#### Security

```sql
-- Create user. REPLICATION and LOGIN permissions are required
CREATE USER pg2sqs_user WITH REPLICATION LOGIN PASSWORD 'secure_password';

-- Grant SELECT access to all necessary tables
GRANT SELECT ON <my_table> TO pg2sqs_user;

-- Optionally grant on future tables in a schema (if using many tables)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO pg2sqs_user;
```

You also need to make sure that in `pg_hba.conf` file the host on which application is running can connect to the PostgreSQL host via `replication` connection. See [PostgreSQL docs](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html).  

#### Application state
The application saves internal state into the `pgwalk.app_state` table. To create the table and grant permissions, use the following SQL:
```sql
CREATE SCHEMA IF NOT EXISTS pgwalk;
CREATE TABLE IF NOT EXISTS pgwalk.app_state
(
 app_name TEXT NOT NULL PRIMARY KEY,
 state TEXT NOT NULL,
 last_xid TEXT NOT NULL
);

GRANT USAGE ON SCHEMA pgwalk TO pg2sqs_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON pgwalk.app_state TO pg2sqs_user;
```

The application won't stop working without the state table. But it'll be emitting log entries when it's unable to save the state.

## Macroses

For FIFO queues, GroupID can be configured with macroses using special syntax `${column_name}`. The value in braces can reference a column name from a table. The column must exist and be part of a publication. It is replaced with an actual value during runtime. There are special macroses:

- `${%table%}` - Table name without schema
- `${%schema%}` - Schema name
- `${%xid%}` - Transaction ID

Example usage:
```yaml
tables:
  - public.customers:
      columns: [all]
      queue:
        name: customers.fifo
        groupID: ${%table%}-${id}
```

Also, for FIFO queues the application generates message deduplication id. It includes schema qualified table name, primary key value, DML kind (`insert/update/delete`) and transaction id. If there's more than one primary key column, then values from all PK columns will be joined with `:` as separator.

Valid values for group id and deduplication id are: `alphanumeric` characters (`a-z`, `A-Z`, `0-9`) and punctuation (``!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~``).
Both are truncated after reaching length > 128 characters (this is a limit of AWS SQS). 