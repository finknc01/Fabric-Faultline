# Mission 06 — The Invisible Wall

## Briefing
Ping works. DNS works. SSH works. The AI service still times out. Network operations says the network is fine; the application team says it is not.

## Objective
Learn TCP/UDP ports, listening sockets, bind addresses, connection establishment, and firewall filtering.

## Build
Run two simple services on different high ports. Record which IP each service binds to and verify connections from another namespace.

## Deliberate failures
Choose two: bind only to loopback, stop the service, block the port with a lab `nftables` rule, or test the wrong transport/port.

## Investigation
Use `ss -lntup`, `nft list ruleset`, `tcpdump`, and a client such as `curl`, `nc`, or `iperf3`. For TCP, identify whether SYN leaves, arrives, and receives SYN-ACK/RST/no response.

## Evidence to save
- socket table
- packet handshake or failure capture
- firewall evidence if used

## Victory condition
You can explain why ICMP reachability says almost nothing about whether an application is listening and permitted.
