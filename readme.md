# 🚀 pg2sqs (BETA)

**pg2sqs** is a lightweight PostgreSQL-to-SQS streamer that captures row-level changes (insert, update, delete) from WAL in real time, enabling event-driven pipelines on AWS with reliable at-least-once delivery.

---

## 📦 Features

- **Real-time event streaming** — turn PostgreSQL into the backbone of event-driven pipelines.
- **Seamless AWS integration** — publishes changes directly to SQS for easy fan-out to Lambdas, microservices, analytics.
- **Reliable delivery** — at-least-once guarantees with deduplication logic that prevents duplicate row changes while running.
- **Row-level granularity** — each database insert, update, or delete is captured as a standalone message.
- **Easy deployment** – available as a binary or Docker container.

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
