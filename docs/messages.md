# Messages

The application converts Postgres WAL stream into JSON messages. This document describes how the messages are formed and how they are sent to SQS.

## Message Structure

The application emits a message for each `insert/update/delete`. 
Messages are formatted as JSON objects following the structure of the underlying table. For example, insert into the following table:
```sql
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(50) NOT NULL,
    register_date TIMESTAMP NOT NULL DEFAULT NOW(),
    email TEXT NOT NULL
);

INSERT INTO customers(customer_id, full_name, register_date, email)
VALUES 
    ('9d3ad872-45c7-11f0-905e-40c2ba1d360b', -- customer_id 
     'Melvin Goodwin',                       -- full_name
     '2025-06-30T14:48:46.503105Z',          -- register_date
     'melvin.goodwin@harber.com'             -- email
    )
```
would generate the following sample JSON:
```json
{
  "customer_id":"9d3ad872-45c7-11f0-905e-40c2ba1d360b",
  "full_name":"Melvin Goodwin",
  "register_date":"2025-06-30T14:48:46.503105Z",
  "email":"melvin.goodwin@harber.com",
  "lastupdated":"2025-06-30T14:48:46.503425Z",
  "kind":"insert"
}
```

The JSON contains properties configured for the particular table (see [Table config](./config.md#table-configuration-tables))

Depending on the configuration, the application may add two additional properties:
1. `kind` - when one queue is configured for more than one DML statement. 

For example, the following configuration would result in `kind` being added for each `insert/update/delete`:
```yaml
tables:
  - users:
      columns: ["id", "name", "email"]
      queue:
        name: "users-queue"
        url: "https://sqs.region.amazonaws.com/123456789012/users-queue"      
```
The following configuration would add `kind` only for `insert/update`
```yaml
tables:
  - users:
      columns: ["id", "name", "email"]
      queue:
        name: "users-queue"
        url: "https://sqs.region.amazonaws.com/123456789012/users-queue"
        delete:
          name: "user-deleted"
          url: "https://sqs.region.amazonaws.com/123456789012/user-deleted-queue"
```
2. Additional property defined by the `commitTimeColumn` setting (only when `track_commit_timestamp` is enabled on the PostgreSQL server). Time is printed in the `RFC3339Nano` format. For example:
```yaml
sqs:
  commitTimeColumn: lastupdated 
```
and output would be e.g.:
```json
{
  <json>...
  "lastupdated":"2025-04-02T16:57:54.970966Z"
}
```

