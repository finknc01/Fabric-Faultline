# Mission 07 — The Broken Road

## Briefing
Nothing is technically “down,” but jobs are slow enough to miss their SLA. This is the first Helios incident where binary up/down thinking will fail you.

## Objective
Measure throughput, latency, loss, jitter, retransmission effects, and MTU problems.

## Build
Create a working namespace path and baseline it with `ping`, `iperf3`, and appropriate socket statistics.

## Deliberate failures
Use `tc netem` on lab interfaces to add controlled delay, loss, or rate limiting. Create a separate MTU mismatch experiment. Change one variable at a time first, then combine two.

## Investigation
Compare baseline and degraded metrics. Use packet capture to observe retransmissions/fragmentation-related behavior where applicable. Explain why small pings can succeed while bulk throughput suffers.

## Evidence to save
- baseline vs degraded table
- latency/loss/throughput plots or summaries
- exact `tc`/MTU configuration
- recovery validation

## Victory condition
You can diagnose a network that is alive but unhealthy using measurements instead of adjectives like “slow.”
