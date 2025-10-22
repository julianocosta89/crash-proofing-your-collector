<!-- markdownlint-disable-next-line -->
# <a href="assets/otelio_collector.png"><img src="assets/otelio_collector.png" alt="OTelio Collector" height="30px" align="left" style="margin-right: 10px;"></a>Crash-Proofing Your OpenTelemetry Collector

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?color=red)](https://github.com/julianocosta89/smells-like-clean-telemetry/blob/main/LICENSE)
[![Daily Renovate](https://github.com/julianocosta89/crash-proofing-your-collector/actions/workflows/renovate-daily.yml/badge.svg)](https://github.com/julianocosta89/crash-proofing-your-collector/actions/workflows/renovate-daily.yml)

This repository demonstrates the importance of batching data and how that affects
persistent queuing in OpenTelemetry Collectors. This repository is a companion
for the talk Crash-Proofing Your OpenTelemetry Collector, which compares
two different approaches for handling batches with persistent queues.

## Overview

When an OpenTelemetry Collector crashes or is terminated unexpectedly, any
telemetry data in memory will be lost. This demo shows why we need to move
away from the batch processor and how to prevent data loss using
persistent storage with OTLP batch.

## Architecture

The demo consists of:

- **OpenTelemetry Collector** - Receives and exports telemetry data
- **Jaeger** - Backend for visualizing traces
- **Telemetrygen** - Tool for generating sample traces
- **File Storage** - Persistent storage to store telemetry data

## Prerequisites

- Docker and Docker Compose installed
- Bash shell (Linux/macOS)

## What the `run_test` script does

The automated test script ([run_test.sh](run_test.sh)) performs the following steps:

1. Cleans up any existing file storage to start fresh
2. Starts the Collector and Jaeger backend using Docker Compose
3. Sends 100 traces to the Collector using `telemetrygen`
4. Waits 15 seconds
5. Forcefully kills the Collector container to simulate a crash scenario
6. Prompts you to check Jaeger (you should see **no traces** yet)
7. Instructs you to restart the Collector to observe two different scenarios:
    1. Data loss with the batch processor
    2. Data recovery with OTLP batch

## Quick Start

### Running the demo with the batch processor

```bash
./run_test.sh batch_processor
```

### Running the demo with the OTLP batch

```bash
./run_test.sh otlp_batcher
```

## Verifying the Results

### Step 1: Check for Missing Data

After the Collector is killed, open Jaeger in your browser:
<http://localhost:16686>

You should see **no traces** because they were still in the buffer
when the Collector crashed.

### Step 2: Restart the Collector and Verify Data Loss/Recovery

Restart the Collector with:

#### Batch processor (data loss)

```bash
# For batch_processor test
docker compose --profile batch_processor up otelcol-batch_processor
```

Now refresh Jaeger. No matter how long you wait, there is no
data to be sent. You have a telemetry data loss!

#### OTLP batch (data recovery)

```bash
# For otlp_batcher test
docker compose --profile otlp_batcher up otelcol-otlp_batcher
```

Now refresh Jaeger. After a couple of seconds you should see the
100 traces that were recovered from persistent storage!

## Configuration Comparison

### batch processor

Location: [otelcol-batch_processor/otelcol-config.yaml](otelcol-batch_processor/otelcol-config.yaml)

```yaml
processors:
  batch:
    timeout: 30s

exporters:
  otlp:
    sending_queue:
      storage: file_storage
```

This configuration uses:

- The batch processor with 30s timeout
- File-backed sending queue in the exporter

### OTLP batch

Location: [otelcol-otlp_batcher/otelcol-config.yaml](otelcol-otlp_batcher/otelcol-config.yaml)

```yaml
exporters:
  otlp:
    sending_queue:
      storage: file_storage
      sizer: "items"
      queue_size: 10000
      batch:
        min_size: 10000
        flush_timeout: 30s
```

This configuration uses:

- Batching configuration directly in the exporter
- File-backed sending queue with item-based sizing
- Batch flush timeout of 30s.

## Cleanup

To stop all containers and clean up file storage:

```bash
./run_test.sh cleanup
```

This will:

- Stop and remove all Docker containers from both profiles
- Clean up both file storage directories

## Learn More

- [OpenTelemetry Collector Resiliency Documentation][2]
- [Batch Processor][3]
- [Exporter Helper (contains OTLP batch)][4]
- [Storage Extension][5]

## License

This project is open source and available under the Apache License 2.0.

[1]: https://opentelemetry.io/docs/collector/resiliency/
[2]: https://opentelemetry.io/docs/collector/resiliency/
[3]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/processor/batchprocessor
[4]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/exporterhelper
[5]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/storage
