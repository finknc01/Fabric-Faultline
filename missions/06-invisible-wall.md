# Mission 06 — The Invisible Wall

## Briefing
Ping works. DNS works. SSH works. The AI service still times out. Network operations says the network is fine; the application team says it is not.

## Objective
Learn TCP/UDP ports, listening sockets, bind addresses, connection establishment, and RHEL firewall filtering.

## Build
Run two simple services on different high ports. Record which IP each service binds to and verify connections from another namespace. Record the active firewalld zone and relevant rules before changing anything.

## Deliberate failures
Choose two: bind only to loopback, stop the service, block the port with a temporary/reversible `firewalld` rule, or test the wrong transport/port.

## Investigation
Use `ss -lntup`, `firewall-cmd --get-active-zones`, `firewall-cmd --list-all`, `tcpdump`, and a client such as `curl`, `nc`, or `iperf3`. For TCP, identify whether SYN leaves, arrives, and receives SYN-ACK/RST/no response.

If you inspect the underlying nftables ruleset, treat it as supporting evidence for firewalld rather than bypassing firewalld as the normal RHEL administration interface.

## Evidence to save
- socket table
- packet handshake or failure capture
- firewalld zone/rule evidence if used
- before/failure/after validation

## Victory condition
You can explain why ICMP reachability says almost nothing about whether an application is listening and permitted, and you can prove whether the failed layer is the process, bind address, transport, or firewall policy.
