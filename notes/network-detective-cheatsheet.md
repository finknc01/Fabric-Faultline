# Network Detective Cheat Sheet

This is not a command list to memorize. It is a list of **questions to ask when something is broken on a RHEL host**.

## 1. What does NetworkManager think is active?

```bash
nmcli device status
nmcli connection show --active
```

Ask whether the expected device and connection profile are active before assuming the kernel state came from the configuration you intended.

## 2. What interfaces exist, and are they alive?

```bash
ip link
```

Ask whether the expected interface exists, is UP, and reports a usable lower-layer state.

## 3. What addresses does this host believe it owns?

```bash
ip addr
```

Check the IP, prefix length, and interface. The prefix changes what the host believes is local.

## 4. Where does the kernel intend to send the packet?

```bash
ip route
ip route get <DESTINATION_IP>
```

Ask whether the destination is directly connected, which interface/source address will be used, and whether a gateway is required.

## 5. Can the host resolve the local next hop?

```bash
ip neigh
```

Check the destination/gateway link-layer entry and its state. A valid route plus failed neighbor resolution points lower in the path than an application problem.

## 6. Can basic IP traffic make the trip?

```bash
ping <IP>
```

A successful ping does **not** prove DNS, TCP/UDP, a particular port, firewall policy, or application health.

## 7. Where does the routed path appear to stop?

```bash
tracepath <IP>
```

Use it to reason about Layer-3 hops and path-MTU clues without assuming every router will answer diagnostic probes.

## 8. Is the application listening where you expect?

```bash
ss -lntup
```

Check protocol, port, bind address, and whether a listener exists at all.

## 9. Does RHEL firewall policy permit the path?

```bash
firewall-cmd --get-active-zones
firewall-cmd --list-all
```

If necessary, inspect the underlying nftables state as supporting evidence, but administer normal RHEL host policy through firewalld.

## 10. Is DNS the actual problem?

```bash
nmcli device show | grep -E 'IP4.DNS|IP6.DNS'
cat /etc/resolv.conf
dig <NAME>
getent hosts <NAME>
```

Compare IP-based and name-based tests. If the IP path works and the name does not, stop blaming switching or routing until the resolver path is understood.

## 11. What are the packets actually doing?

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

Ask whether the request left, whether the reply returned, whether retransmissions are present, whether neighbor resolution repeats, and whether traffic is on the interface you predicted.

## 12. What does the virtual switch know?

For Linux bridges:

```bash
bridge link
bridge fdb show
```

Check bridge membership and learned MAC-to-port mappings.

## 13. Is the link healthy but slow?

```bash
iperf3
ethtool <INTERFACE>
```

Later missions add `tc` for deliberate latency, loss, and bandwidth experiments.

> **Reachable and healthy are different states.**

## Troubleshooting ladder

```text
Expected NetworkManager profile active?
        ↓
Interface exists/up?
        ↓
Correct IP/prefix?
        ↓
Correct route?
        ↓
Next hop resolvable?
        ↓
Packets leaving/arriving?
        ↓
Firewall permits path?
        ↓
Transport port reachable/listening?
        ↓
Name resolution correct?
        ↓
Application healthy?
```

The goal is not to say “the network is broken.” The goal is to identify the first point where observed behavior diverges from the expected path and show the evidence that proves it.
