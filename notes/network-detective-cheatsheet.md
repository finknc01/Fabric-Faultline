# Network Detective Cheat Sheet

This is not a command list to memorize.

It is a list of **questions to ask when something is broken**.

---

## 1. What interfaces exist, and are they alive?

```bash
ip link
```

Ask:

- Does the expected interface exist?
- Is it UP?
- Is the lower layer reporting a usable link?

---

## 2. What addresses does this host believe it owns?

```bash
ip addr
```

Ask:

- Correct IP?
- Correct prefix length?
- Correct interface?

Do not treat `10.0.0.10/24` and `10.0.0.10/30` as the same configuration. The prefix changes what the host believes is local.

---

## 3. Where does Linux intend to send the packet?

```bash
ip route
ip route get <DESTINATION_IP>
```

Ask:

- Is the destination directly connected?
- Which interface will be used?
- Is there a gateway/next hop?
- Which source IP will Linux choose?

This is often more useful than staring at a topology diagram.

---

## 4. Can the host resolve the local next hop?

```bash
ip neigh
```

Ask:

- Is there a MAC address for the destination or gateway?
- Is the neighbor entry REACHABLE, STALE, INCOMPLETE, or FAILED?

A useful clue:

```text
route exists + neighbor resolution fails
```

usually points you lower in the path than an application problem.

---

## 5. Can basic IP traffic make the trip?

```bash
ping <IP>
```

Ping answers a limited question.

A successful ping does **not** mean:

- DNS works
- TCP works
- a specific port is open
- the application is healthy

It proves only part of the path.

---

## 6. Where does the routed path appear to stop?

```bash
tracepath <IP>
```

Use this to reason about intermediate Layer-3 hops and path MTU clues.

Do not assume every router will answer diagnostic probes.

---

## 7. Is the application listening?

```bash
ss -lntup
```

Ask:

- TCP or UDP?
- Correct port?
- Bound to the correct address?
- Listening at all?

Classic symptom:

```text
ping works
application fails
```

This should make you investigate higher layers instead of changing routes.

---

## 8. Is DNS the actual problem?

```bash
dig <NAME>
resolvectl status
```

Compare:

```bash
ping <IP>
ping <NAME>
```

If the IP works and the name does not, stop blaming switching.

---

## 9. What are the packets actually doing?

```bash
tcpdump -ni <INTERFACE>
```

Target the capture whenever possible:

```bash
tcpdump -ni eth0 arp
tcpdump -ni eth0 icmp
tcpdump -ni eth0 host 10.0.0.20
tcpdump -ni eth0 tcp port 443
```

Ask:

- Did the request leave?
- Did the reply return?
- Are there retransmissions?
- Is ARP happening repeatedly?
- Is the traffic on the interface you expected?

`tcpdump` is how you stop arguing with your assumptions.

---

## 10. What does the switch know?

For Linux bridges:

```bash
bridge link
bridge fdb show
```

Ask:

- Is the port part of the bridge?
- Which MAC addresses were learned on which ports?

---

## 11. Is the link healthy but slow?

```bash
iperf3
ethtool <INTERFACE>
```

Later missions add:

```bash
tc
```

for deliberate latency/loss/bandwidth problems.

The key lesson:

> **"Reachable" and "healthy" are different states.**

---

# The troubleshooting ladder

When you freeze during a network problem, use this order:

```text
Interface exists/up?
        ↓
Correct IP/prefix?
        ↓
Correct route?
        ↓
Next hop resolvable?
        ↓
Packets leaving?
        ↓
Packets arriving?
        ↓
Transport port reachable/listening?
        ↓
Name resolution correct?
        ↓
Application healthy?
```

It is not universal, but it gives you a disciplined starting point.

---

# The most important habit

Never say:

> "The network is broken."

Try to say:

> "The source has a valid interface and route, ARP for the gateway succeeds, ICMP leaves the source and reaches the router, but no reply appears on the destination-side interface. The fault is therefore downstream of the source subnet."

That is the difference between guessing and troubleshooting.
