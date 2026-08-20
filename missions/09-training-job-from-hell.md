# Mission 09 — The Training Job From Hell

## Briefing
One flow performs well. Eight simultaneous worker flows make throughput collapse. Nothing is unplugged.

## Objective
Connect distributed AI traffic patterns to congestion, contention, oversubscription, queueing, and fairness.

## Build
Use multiple namespaces and parallel `iperf3` flows to create an incast/all-to-one or many-to-many traffic pattern. Place a deliberate bottleneck on a shared uplink using `tc` rate limiting.

## Investigation
Measure aggregate throughput and per-flow behavior as concurrency rises. Change only the bottleneck capacity, then only the traffic pattern. Identify where contention first appears.

## Evidence to save
- traffic matrix
- one-flow vs multi-flow measurements
- bottleneck diagram
- explanation of why endpoint health checks did not reveal the problem

## Victory condition
You can explain why distributed training can expose network weaknesses that ordinary server-to-server tests miss.
