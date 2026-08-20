# Mission 00 — Follow the Packet

## Incident briefing

Helios is not broken yet.

That is suspicious.

Before you are allowed to touch the cluster network, your lead gives you a challenge:

> **Explain exactly what your computer does when it sends one packet to another machine.**

No subnetting drills. No memorized OSI mnemonics. Your first job is to build a mental model you can actually use during an outage.

---

## Mission objective

By the end of this mission, you should be able to explain the difference between:

- interface
- MAC address
- IP address
- subnet/prefix
- default gateway
- route
- ARP / neighbor discovery
- Ethernet frame
- IP packet
- ICMP
- TCP
- UDP
- port
- DNS

More importantly, you should know **which of these participates at each stage of a connection**.

---

## The mental model

When an application wants to communicate, think from the inside outward:

```text
Application
    ↓
TCP / UDP / ICMP
    ↓
IP packet
    ↓
Routing decision
    ↓
Next-hop resolution
    ↓
Ethernet frame
    ↓
Network interface
    ↓
Physical / virtual link
```

The receiving machine reverses that process.

A crucial distinction:

> **IP decides where the packet needs to go. Ethernet delivers it across the current local link.**

You will spend the rest of this lab seeing why that distinction matters.

---

## Recon your own machine

Run:

```bash
ip link
```

For every interface you see, answer:

- Is it physical, virtual, loopback, Wi-Fi, Ethernet, bridge, VPN, or something else?
- Is it UP or DOWN?
- Does it have a MAC address?

Now run:

```bash
ip addr
```

Find:

- your loopback address
- your primary IPv4 address
- its prefix length
- the interface holding that address

Now inspect routing:

```bash
ip route
```

Find:

- your directly connected subnet
- your default route
- your default gateway

Write this sentence using your real values:

```text
Traffic for __________ is directly connected through __________.
Everything else normally goes to gateway __________ through __________.
```

---

## Ask Linux where a packet would go

Pick a public IPv4 address, such as a resolver address, and run:

```bash
ip route get 1.1.1.1
```

Do **not** focus on whether that particular service is reachable.

Focus on Linux's routing decision:

- Which interface would it use?
- Which source IP would it choose?
- Is there a next-hop gateway?

Now ask about your own subnet's gateway:

```bash
ip route get <YOUR_GATEWAY_IP>
```

Compare the two results.

Why does one need a gateway while the other may not?

---

## Inspect the neighbor table

Run:

```bash
ip neigh
```

This table connects two worlds:

```text
IP address ↔ link-layer address
```

Find your gateway if it appears.

Then generate traffic to the gateway:

```bash
ping -c 2 <YOUR_GATEWAY_IP>
```

Run `ip neigh` again.

Observe whether the neighbor state changed.

### Question

If your machine knows the gateway's IP address but does **not** know its MAC address, what must happen before an Ethernet frame can be sent to it?

---

## Watch traffic instead of guessing

Identify your active interface, then run this in one terminal:

```bash
sudo tcpdump -ni <INTERFACE> arp or icmp
```

In another terminal, ping your gateway:

```bash
ping -c 3 <YOUR_GATEWAY_IP>
```

Do not worry if you do not see ARP every time; your host may already have a cached neighbor entry.

If necessary, simply focus on the ICMP exchange.

Your job is to connect what `ping` says with what is actually visible on the wire/interface.

---

## The three questions that solve half of networking

For any destination IP, ask:

### 1. Is the destination local?

The host compares the destination with its directly connected prefixes.

### 2. If it is not local, where is my next hop?

The routing table decides.

### 3. How do I deliver to that next hop on this link?

The host needs the link-layer information required for the local medium—for Ethernet, typically a MAC address learned through neighbor resolution.

Keep those three questions for the entire lab.

---

## Transport layer observation

Run:

```bash
ss -lntup
```

Look for listening sockets.

Notice that an IP address alone does not identify an application.

A useful mental model is:

```text
IP address → which host/interface endpoint?
Port       → which application/service?
Protocol   → TCP or UDP behavior?
```

This is why a server can be reachable by ping while an application is still unavailable.

That exact problem becomes a later mission.

---

## DNS: keep it separate

Run:

```bash
dig example.com
```

Then inspect your resolver configuration:

```bash
resolvectl status
```

DNS answers a naming question:

```text
What IP address corresponds to this name?
```

It does **not** prove that the resulting IP is reachable.

One of the most important habits in troubleshooting is separating:

```text
name-resolution problem
```

from:

```text
connectivity problem
```

---

## Mission debrief

Without looking anything up, explain this scenario in plain English:

> You open a connection to a server whose IP is not on your local subnet.

Your explanation should include:

1. the application generates traffic
2. transport/network information is created
3. the kernel makes a routing decision
4. the default gateway is selected as next hop
5. the gateway must be reachable on the local link
6. neighbor resolution provides the Ethernet destination information
7. the frame crosses the local link to the gateway
8. the IP packet is routed onward

You do **not** need to explain every header field.

You need to understand the path.

---

## Victory condition

You pass Mission 00 when you can look at these commands:

```bash
ip addr
ip route
ip neigh
ss
```

and explain **what networking question each command answers**.

### Artifact to save

Create:

```text
notes/packet-journey.md
```

Draw or describe one packet leaving your machine and reaching a non-local destination.

That becomes your first networking artifact.

---

## References

- Ubuntu networking introduction: https://documentation.ubuntu.com/server/explanation/intro-to/networking/
- Ubuntu networking key concepts: https://documentation.ubuntu.com/server/explanation/networking/networking-key-concepts/
