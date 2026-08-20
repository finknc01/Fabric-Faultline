# Mission 03 — The Quarantine Deck

## Briefing
Helios security isolates management systems from compute traffic. Minutes later, two machines that should communicate cannot—and one pair that should be isolated still can.

## Objective
Learn VLANs as a Layer-2 segmentation mechanism rather than as magic numbers on switch ports.

## Build
Create four Linux namespaces, one or two Linux bridges, and VLAN-tagged interfaces. Put management and compute hosts into separate broadcast domains. Draw where Ethernet frames are tagged and untagged.

## Deliberate failures
Create two reversible faults: a host/port in the wrong VLAN and a trunk that does not carry the expected VLAN. Predict which pairs should fail before testing.

## Investigation
Use `ip -d link`, `bridge vlan show`, `bridge fdb show`, `ping`, and `tcpdump -e` to prove whether the frame is emitted, tagged, learned, and delivered.

## Evidence to save
- VLAN table and topology
- packet capture showing 802.1Q tagging where visible
- matrix of intended vs observed reachability
- root-cause explanation for each fault

## Victory condition
You can explain why two hosts with compatible IP addresses still cannot communicate when their Layer-2 domains differ.
