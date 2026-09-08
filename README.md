# Fabric-Faultline

> **Operation Packetfall — the Helios AI cluster is losing packets, breaking routes, and inventing new outages faster than the network team can explain them. Follow the packet and save the cluster.**

## Lab environment

- **Core environment:** RHEL 10 lab host by default, using Linux network namespaces, veth pairs, bridges, routing, traffic shaping, and packet capture. If mentored work is tied to another supported RHEL major version, mirror that version.
- **Evidence rule:** Real virtual-network experiments are measured; InfiniBand/RoCE/RDMA production behavior is modeled/reference unless actually available.
- **Hardware rule:** No physical switch is required for the core campaign.
- **Safety rule:** Use the single documented reset script to remove only known lab namespaces/links; do not flush host-wide routes or firewall state as a generic cleanup step.

## Skills developed

- TCP/IP and practical packet-path reasoning
- Ethernet, MAC addresses, ARP/neighbor discovery, and switching
- IPv4 addressing, subnetting, routes, and default gateways
- VLANs and network segmentation
- TCP vs UDP, ports, sockets, DNS, and firewall reasoning
- RHEL networking with NetworkManager plus namespaces, veth pairs, bridges, and routing
- packet capture with `tcpdump`
- throughput, latency, loss, MTU, and congestion diagnostics
- leaf-spine and east-west AI data-center networking concepts
- RDMA, RoCE, InfiniBand, and NCCL context
- evidence-driven troubleshooting instead of configuration guessing

## Purpose

Fabric-Faultline is the **networking-from-first-principles lab**.

You are the new infrastructure engineer assigned to fictional AI cluster **Helios**. The network starts failing in increasingly difficult ways: two hosts that should communicate cannot, a switching path disappears, DNS gets blamed for an IP problem, ping works while the application does not, throughput collapses without connectivity fully dying, and eventually distributed AI traffic starts exposing the limits of the fabric.

Every incident asks the same question:

> **Where did the packet stop, and what evidence proves it?**

The lab grows from two namespaces into a miniature AI data-center fabric while keeping the distinction between locally measured behavior and production-only concepts explicit.

## Campaign

| Mission | Incident | Networking concept | Victory condition |
|---|---|---|---|
| [00 — Follow the Packet](missions/00-follow-the-packet.md) | Boot Camp | layers, interfaces, MAC, IP, TCP/UDP, ICMP | explain one packet end-to-end |
| [01 — Two Machines, No Excuses](missions/01-two-machines.md) | two isolated hosts | interfaces, subnets, ARP/neighbor discovery | two hosts communicate and faults are explained |
| [02 — The Switchyard](missions/02-switchyard.md) | switching failure | Ethernet, MAC learning, bridges | three hosts communicate through a virtual switch |
| [03 — The Quarantine Deck](missions/03-quarantine-deck.md) | segmentation failure | VLAN concepts and segmentation | traffic is intentionally separated and restored |
| [04 — The Router at the Edge](missions/04-router-at-the-edge.md) | routing failure | routing tables, gateways, IP forwarding | two subnets communicate through a router |
| [05 — The Name That Vanished](missions/05-name-that-vanished.md) | naming failure | DNS vs connectivity | prove whether an outage is DNS or network-related |
| [06 — The Invisible Wall](missions/06-invisible-wall.md) | application path blocked | ports, TCP/UDP, firewalld | identify why ping works but an application does not |
| [07 — The Broken Road](missions/07-broken-road.md) | degraded path | latency, loss, MTU, throughput, `tc`, `iperf3` | diagnose degraded—not dead—connectivity |
| [08 — The Fabric Awakens](missions/08-fabric-awakens.md) | fabric expansion | leaf-spine, ECMP concepts, east-west traffic | build and explain a miniature fabric |
| [09 — The Training Job From Hell](missions/09-training-job-from-hell.md) | congestion | bottlenecks, AI traffic patterns | explain why distributed traffic collapses under load |
| [10 — Beyond Ethernet](missions/10-beyond-ethernet.md) | specialized fabrics | RDMA, RoCE, InfiniBand, NCCL context | explain why AI clusters use specialized networking |
| [Final — Black Sky](missions/final-black-sky.md) | multi-fault incident | cross-layer troubleshooting | repair an unknown scenario using evidence only |

The mission files are authoritative for the build/break/investigate steps.

## Investigation rule

For any destination or application path, work downward before changing configuration:

1. What is the expected application/data path?
2. What source and destination are involved?
3. Is the interface present and up?
4. What address/prefix does the host have?
5. What route will the kernel choose?
6. Can the next hop be resolved?
7. Does traffic leave and arrive where expected?
8. Does firewall policy allow the path?
9. Is the transport/application listening?
10. What changed between healthy and failed states?

Use `nmcli`, `ip`, `ss`, `bridge`, `ethtool`, `tcpdump`, `iperf3`, `dig`, `getent`, `firewall-cmd`, and `tc` because each answers a specific troubleshooting question—not as a checklist to run blindly.

## Evidence standard

Every failure worth keeping should record:

```text
Symptom:
Expected path:
First confirmed-good point:
First confirmed-bad point:
Evidence:
Hypothesis:
Test:
Root cause:
Fix:
Why the fix worked:
Production monitoring/prevention idea:
```

The finished repository should demonstrate troubleshooting ability, not merely working configurations.

## Prerequisites

Recommended RHEL 10 packages/tools:

```bash
sudo dnf install -y iproute iputils tcpdump iperf3 bind-utils ethtool firewalld
```

Use NetworkManager/`nmcli` for RHEL host networking. Namespace/bridge topology inside individual missions may be built directly with `ip`/`bridge` because those objects are deliberately temporary lab constructs.

## Production-scale boundary

Later missions connect ordinary networking to east-west AI traffic, leaf-spine design, oversubscription, congestion, RDMA, RoCE, InfiniBand, and NCCL collective communication.

The laptop is **not** an InfiniBand or production RoCE fabric. Those behaviors remain modeled/reference unless real equipment is available.

## References

- RHEL 10 Configuring and managing networking: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/configuring_and_managing_networking/index
- NVIDIA networking documentation: https://docs.nvidia.com/networking/

## Completion condition

Fabric-Faultline is complete when you can take an ambiguous symptom, trace the expected packet/application path, identify the first broken layer from evidence, and explain the repair without configuration guessing.
