# Mission 05 — The Name That Vanished

## Briefing
“Compute-02 is down.” Its IP responds immediately, but the hostname does not. Half the team still wants to reboot the server.

## Objective
Separate DNS resolution from IP connectivity and understand resolver configuration, query path, caching, and name-to-address assumptions.

## Build
Use a small local DNS service or controlled `/etc/hosts`/resolver lab. Establish a name that resolves to a reachable service.

## Deliberate failures
Use a wrong DNS server, missing record, stale/wrong address, or search-domain mistake. Keep the underlying IP path healthy.

## Investigation
Compare `ping <IP>` with name-based tests. Use `dig`, `getent hosts`, and `resolvectl` where available. Capture DNS queries and responses with `tcpdump`.

## Evidence to save
- resolution path diagram
- query/response capture
- proof that transport remained healthy while naming failed

## Victory condition
You can state precisely whether a symptom is name resolution, routing, transport, or application behavior.
