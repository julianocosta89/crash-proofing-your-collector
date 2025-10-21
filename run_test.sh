#!/bin/bash

# Get the test parameter
TEST_PARAM="$1"

# Check if parameter is passed
if [ -z "$TEST_PARAM" ]; then
    echo "Error: No test parameter provided"
    echo "Usage: ./run_test.sh <test_parameter>"
    echo "Available tests:"
    echo "  - batch_processor"
    echo "  - otlp_batcher"
    echo "  - cleanup"
    exit 1
fi

# Handle cleanup
if [ "$TEST_PARAM" = "cleanup" ]; then
    echo "====================================="
    echo "Running cleanup..."
    echo "====================================="

    echo ""
    echo "Stopping and removing all docker compose services..."
    docker compose --profile batch_processor --profile otlp_batcher down

    echo ""
    echo "Cleaning up file storage directories..."
    rm -rf otelcol-batch_processor/file_storage/*
    rm -rf otelcol-otlp_batcher/file_storage/*

    echo ""
    echo "====================================="
    echo "Cleanup complete!"
    echo "====================================="
    exit 0
fi

echo "Running $TEST_PARAM test"

echo "Cleaning up file storage to start fresh"
rm -rf "otelcol-${TEST_PARAM}/file_storage/*"

echo "Starting the demo services"
docker compose --profile "${TEST_PARAM}" up -d
echo "Docker compose started."

echo ""
echo "Sleep for 5 seconds"
for i in {1..5}; do
    sleep 1
    echo -n "."
done

echo ""
echo "Sending 100 traces to the Collector"

# Send 100 traces
docker run --rm --network=crash-proofing \
    ghcr.io/open-telemetry/opentelemetry-collector-contrib/telemetrygen:v0.137.0 \
    traces \
    --otlp-insecure \
    --otlp-endpoint otel-collector:4317 \
    --rate 0 \
    --traces 100


echo "Waiting for 15 seconds before killing the Collector"

for i in {1..15}; do
    sleep 1
    echo -n "."
done

echo ""
echo "Killing the Collector"

# Kill the container
docker kill otel-collector
echo "Collector killed."

echo ""
echo "Navigate to the backend to view that no data was sent."
echo "Jaeger: http://localhost:16686"

echo ""
echo "Whenever ready, run the following command to start the Collector again (add \`-d\` to run in background):"
echo "docker compose --profile ${TEST_PARAM} up otelcol-${TEST_PARAM}"

echo ""
echo "After the Collector is running again, navigate to the backend to view if you get any traces."

echo ""
echo ""
echo "====================================="
echo "When you're done, run cleanup with:"
echo "./run_test.sh cleanup"
echo "====================================="
