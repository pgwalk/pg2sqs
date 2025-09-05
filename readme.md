# 🚀 pg2sqs (BETA)

**pg2sqs** is a lightweight service that streams PostgreSQL WAL (Write-Ahead Log) records to an AWS SQS queue. Ideal for change data capture (CDC), audit pipelines, and replication into event-driven architectures.

---

## 📦 Features

- Connects to PostgreSQL using logical replication
- Sends changes to AWS SQS queues
- Run via Docker or Linux binary
- Fault-tolerant WAL offset tracking
- Configurable via YAML or environment variables

---

## ⚙️ Installation

### From Binary

**Not yet available**

### From Dockerhub
```
docker pull alikpgwalk/pg2sqs:latest
docker run --rm -v $PWD/config.yaml:/app/config.yaml alikpgwalk/pg2sqs:latest
```

## 🛠️ Configuration

You can configure the app via:
- config file
- ENV variables

See [Configuration](docs/config.md) for more details.

## 📝 Message Format

See [Messages](docs/messages.md) for more details.

## 📄 License

**pg2sqs is currently free to use during the beta period, which runs until November 30th, 2025.**

You are welcome to use the software for evaluation during the beta. However, the following terms apply:

- 📅 **Beta period ends on November 30th, 2025**  
  After this date, usage might require a valid paid license.
- Beta period license key:
```
1foW3IIh3xHAOSHKJmOJSFiQ53QCZZks3fxWMycRXFLHbsweTq2ikqyiymaSPwTVDCMMcgf1v7mTJaikIzERrryUbt7CA0Eypy76cYmEmT81A9kYmS5qN6J1pyTSe6StIKxXhiqheHRwphp5vJ3uWEbZcZXLNWuyUoWAYIpMzbwmyChTqLgViYbtCXbegQzuWR3zdxLk7
```

- See [Configuration/License](docs/config.md#license) on how to configure the license.
- 🚫 **No redistribution or resale**  
  You may not redistribute the binary or use it as part of a paid service or product.

- 🛠 **No warranty or SLA**  
  This beta is provided "as is", without warranties or guarantees of performance.

We reserve the right to change licensing terms after the beta period. Stay updated by checking [our website](https://pgwalk.com/pg2sqs.html) or subscribing to updates.

For questions about licensing or commercial use, please contact us at [pg2sqs@pgwalk.com](mailto:pg2sqs@pgwalk.com).
