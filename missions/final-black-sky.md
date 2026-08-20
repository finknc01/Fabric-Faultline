# Final Mission — Black Sky Incident

## Briefing
At 02:17 Helios begins failing in contradictory ways. Some hosts resolve names but cannot connect. Others connect with terrible throughput. One subnet appears healthy from inside itself. No single team owns the entire path.

## Challenge format
Do not pre-read an answer key. Have another person or tool select 3–4 reversible faults from different layers and record them privately. Examples: VLAN mismatch, wrong route, DNS error, blocked port, MTU mismatch, induced loss, stopped service.

## Rules
- Start with symptoms only.
- Draw the expected packet path before changing anything.
- Confirm a good point and a bad point with evidence.
- Make one corrective change at a time.
- Preserve captures and timestamps.

## Required evidence
- initial symptom matrix
- topology and expected paths
- investigation timeline
- packet captures/route/socket/firewall evidence
- each root cause and why it produced its specific symptoms
- final validation matrix
- short postmortem with monitoring ideas

## Victory condition
You restore the environment without random configuration changes and can narrate the investigation layer by layer.

Operation Packetfall is complete when “the network is broken” has become a question you know how to decompose.
