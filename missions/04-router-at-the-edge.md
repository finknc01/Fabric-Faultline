# Mission 04 — The Router at the Edge

## Briefing
The quarantine worked too well. Management and compute networks now need controlled communication through a router.

## Objective
Understand local-vs-remote delivery, subnet masks, default gateways, routing tables, and Linux IP forwarding.

## Build
Create two subnets joined by a router namespace with one interface in each network. Enable forwarding only in the lab router. Verify that same-subnet traffic does not need the router while cross-subnet traffic does.

## Deliberate failures
Choose two: wrong prefix length, missing default route, incorrect next hop, forwarding disabled, or a return route missing.

## Investigation
At each host ask: is the destination local? Which route wins? What next hop is chosen? Does the router receive the packet? Does the destination have a return path?

Use `ip route get`, `ip route`, `ip neigh`, `tcpdump`, and `tracepath`.

## Evidence to save
- forwarding path in both directions
- route tables before/failure/after
- capture from at least two hops

## Victory condition
You can diagnose asymmetric or missing routing without randomly adding routes.
