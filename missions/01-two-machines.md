# Mission 01 — Two Machines, No Excuses

## Incident briefing

Two Helios compute nodes have been delivered.

They are connected by a cable.

They cannot communicate.

There is no switch, router, DNS server, firewall, Kubernetes cluster, or AI framework to blame.

Just two machines and one link.

Your job is to make them communicate—and then break them in ways that teach you exactly what a subnet means.

---

## What you are building

Linux network namespaces let one Linux system act like several isolated network hosts.

```text
alpha                                  beta
10.44.1.10/24                         10.44.1.20/24
   [veth-a] ------------------------- [veth-b]
```

Each namespace gets its own interfaces and routing table.

---

## Concepts introduced

- network namespaces
- virtual Ethernet pairs
- IPv4 addresses
- CIDR prefix lengths
- directly connected routes
- ARP / neighbor resolution
- why hosts on the same subnet do not need a router

---

## Build the two hosts

Install the basic tools if necessary:

```bash
sudo apt update
sudo apt install -y iproute2 iputils-ping tcpdump
```

Create the namespaces:

```bash
sudo ip netns add alpha
sudo ip netns add beta
```

Create a virtual Ethernet cable:

```bash
sudo ip link add veth-a type veth peer name veth-b
```

Move one end into each namespace:

```bash
sudo ip link set veth-a netns alpha
sudo ip link set veth-b netns beta
```

Assign addresses:

```bash
sudo ip -n alpha addr add 10.44.1.10/24 dev veth-a
sudo ip -n beta  addr add 10.44.1.20/24 dev veth-b
```

Bring up loopback and the interfaces:

```bash
sudo ip -n alpha link set lo up
sudo ip -n beta  link set lo up
sudo ip -n alpha link set veth-a up
sudo ip -n beta  link set veth-b up
```

Inspect both hosts:

```bash
sudo ip -n alpha addr
sudo ip -n beta addr
sudo ip -n alpha route
sudo ip -n beta route
```

Do not ping yet.

Predict what the routing tables should contain.

---

## First contact

From `alpha`:

```bash
sudo ip netns exec alpha ping -c 3 10.44.1.20
```

Then inspect neighbor state:

```bash
sudo ip -n alpha neigh
sudo ip -n beta neigh
```

### Explain what happened

When `alpha` sent traffic to `10.44.1.20`, it should have recognized that `10.44.1.20` belongs to its directly connected `10.44.1.0/24` network.

There is therefore no gateway.

The core path is:

```text
alpha sees destination is local
        ↓
alpha needs beta's MAC address
        ↓
neighbor resolution / ARP
        ↓
Ethernet frame sent directly across veth
        ↓
beta receives IP packet
```

---

# Fault 1 — The Wrong Neighborhood

Change beta's address so that it appears to live on another subnet:

```bash
sudo ip -n beta addr flush dev veth-b
sudo ip -n beta addr add 10.44.2.20/24 dev veth-b
```

Now try:

```bash
sudo ip netns exec alpha ping -c 2 10.44.2.20
```

Before changing anything, inspect:

```bash
sudo ip -n alpha route
sudo ip netns exec alpha ip route get 10.44.2.20
```

### Investigation question

Why does the physical/virtual cable being connected **not** mean alpha knows how to reach `10.44.2.20`?

The expected answer should involve the routing table—not "ping is broken."

---

# Fault 2 — Same Number, Different Belief

Try a more subtle mismatch.

Configure:

```bash
sudo ip -n alpha addr flush dev veth-a
sudo ip -n beta addr flush dev veth-b

sudo ip -n alpha addr add 10.44.1.10/24 dev veth-a
sudo ip -n beta  addr add 10.44.1.20/30 dev veth-b
```

Now inspect:

```bash
sudo ip -n alpha route
sudo ip -n beta route
```

Ask each host where it believes the other address lives:

```bash
sudo ip netns exec alpha ip route get 10.44.1.20
sudo ip netns exec beta  ip route get 10.44.1.10
```

The point is not to memorize `/30` arithmetic immediately.

The point is to discover that **two hosts can look numerically close while having different beliefs about which addresses are local**.

---

# Fault 3 — The Cable Is There, But the Interface Is Dead

Restore the working `/24` configuration, then take one interface down:

```bash
sudo ip -n beta link set veth-b down
```

Test again.

Inspect:

```bash
sudo ip -n beta link
sudo ip -n alpha neigh
```

This is your first example of the troubleshooting principle:

> A correct IP configuration cannot rescue a failed lower layer.

Restore it:

```bash
sudo ip -n beta link set veth-b up
```

---

## Packet-capture challenge

Clear the namespaces and rebuild the working `/24` setup if needed.

In one terminal:

```bash
sudo ip netns exec alpha tcpdump -ni veth-a arp or icmp
```

In another:

```bash
sudo ip netns exec alpha ping -c 3 10.44.1.20
```

Try to identify:

1. the ARP request
2. the ARP reply
3. the ICMP echo request
4. the ICMP echo reply

Now the words "ARP" and "ping" should correspond to packets you have personally seen.

---

## Debrief questions

Answer these without searching:

1. Why did the original hosts not need a default gateway?
2. What does `/24` tell the host?
3. What command proves what Linux believes is directly connected?
4. Why can two hosts be physically linked but unable to reach one another?
5. What does `ip neigh` tell you that `ip route` does not?
6. If ARP requests leave alpha but no replies return, which parts of the path have you already proven?

---

## Victory condition

You pass when you can diagnose all three faults without blindly changing addresses.

You should be comfortable answering:

```text
Is the interface up?
What IP/prefix does it have?
Does Linux believe the destination is local?
If local, can neighbor resolution succeed?
```

---

## Artifact

Create an incident report for one failure in:

```text
incidents/mission-01-<fault-name>.md
```

Include the evidence that led you to the root cause.

---

## Cleanup

```bash
sudo ip netns del alpha 2>/dev/null || true
sudo ip netns del beta 2>/dev/null || true
```
