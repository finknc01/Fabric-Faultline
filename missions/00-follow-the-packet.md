# Mission 00 — Follow the Packet

## Incident briefing

Helios is not broken yet.

Before you are allowed to touch the cluster network, your lead gives you a challenge:

> **Explain exactly what your RHEL host does when it sends one packet to another machine.**

No subnetting drills. No memorized OSI mnemonics. Your first job is to build a mental model you can actually use during an outage.

## Mission objective

By the end of this mission, you should be able to explain the difference between:

- interface
- NetworkManager connection profile
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

A crucial distinction:

> **IP decides where the packet needs to go. Ethernet delivers it across the current local link.**

## Recon your RHEL host

Start with NetworkManager:

```bash
nmcli device status
nmcli connection show --active
```

Identify the active connection profile and the device it manages.

Then inspect kernel interface state:

```bash
ip link
ip addr
```

For the primary interface, record its MAC address, IPv4 address, prefix length, and UP/DOWN state.

Inspect routing:

```bash
ip route
```

Find your directly connected subnet, default route, default gateway, and egress interface.

Write this sentence using your actual lab values:

```text
Traffic for __________ is directly connected through __________.
Everything else normally goes to gateway __________ through __________.
```

## Ask the kernel where a packet would go

Pick a safe public IPv4 address and run:

```bash
ip route get 1.1.1.1
```

Focus on the route choice rather than whether that service is reachable.

Then ask about your own gateway:

```bash
ip route get <YOUR_GATEWAY_IP>
```

Explain why one path needs a gateway while the other may not.

## Inspect neighbor state

Run:

```bash
ip neigh
```

Generate traffic to the gateway:

```bash
ping -c 2 <YOUR_GATEWAY_IP>
```

Run `ip neigh` again and explain how IP neighbor resolution connects the network-layer destination to the local link-layer destination.

## Watch traffic instead of guessing

On the active interface:

```bash
sudo tcpdump -ni <INTERFACE> arp or icmp
```

In another terminal:

```bash
ping -c 3 <YOUR_GATEWAY_IP>
```

Connect what `ping` reports to what is actually visible on the interface.

## Transport layer observation

Run:

```bash
ss -lntup
```

Use this mental model:

```text
IP address → host/interface endpoint
Port       → application/service endpoint
Protocol   → TCP or UDP behavior
```

This is why a host can be reachable by ICMP while an application is unavailable.

## DNS: keep it separate

Inspect RHEL resolver configuration through NetworkManager and the generated resolver file:

```bash
nmcli device show | grep -E 'IP4.DNS|IP6.DNS'
cat /etc/resolv.conf
```

Query a name:

```bash
dig example.com
getent hosts example.com
```

DNS answers a naming question. It does not prove that the resulting IP is reachable.

## Mission debrief

Without looking anything up, explain this scenario in plain English:

> You open a connection to a server whose IP is not on your local subnet.

Your explanation should include the application, transport/network information, route choice, default gateway, neighbor resolution, local Ethernet delivery, and onward routing.

## Victory condition

You pass Mission 00 when you can look at these commands:

```bash
nmcli device status
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

Draw or describe one packet leaving your RHEL host and reaching a non-local destination.

## References

- RHEL 10 Configuring and managing networking: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/configuring_and_managing_networking/index
