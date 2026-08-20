# Mission 10 — Beyond Ordinary Ethernet

## Briefing
Helios leadership asks whether the next cluster should use ordinary TCP/IP Ethernet, RoCE, or InfiniBand. “Which is fastest?” is not a sufficient answer.

## Objective
Understand the problems RDMA solves, how RoCE relates to Ethernet, how InfiniBand differs operationally, and why NCCL communication cares about fabric behavior.

## Laptop boundary
This mission is architecture analysis, not fake InfiniBand. Do not claim Linux namespaces reproduce RDMA hardware semantics.

## Tasks
1. Draw a conventional TCP data path and an RDMA-style conceptual data path.
2. Compare Ethernet/TCP, RoCE, and InfiniBand across latency, CPU involvement, loss/congestion sensitivity, operations, and hardware requirements.
3. Map common collective patterns—ring/all-reduce conceptually—to the fabric.
4. Revisit Mission 09 and explain which problems a specialized fabric helps and which topology/capacity mistakes it cannot magically fix.

## Evidence to save
- comparison matrix
- data-path diagrams
- “what must be measured on real hardware” checklist

## Victory condition
You can discuss specialized AI networking without treating RDMA, RoCE, InfiniBand, and NCCL as interchangeable buzzwords.
