# Mission 02 — The Switchyard

## Incident briefing

Helios has grown from two nodes to three.

Someone plugs all three into a switch.

At first, everything works.

Then one port is removed from the switching fabric and one compute node vanishes from the network.

Your job is to understand what a switch actually does—not just that "it connects computers."

---

## What you are building

```text
                 Linux bridge: sw1
              ┌──────┬──────┬──────┐
              │      │      │
            swp1   swp2   swp3
              │      │      │
             h1     h2     h3
       10.44.10.11  .12    .13
```

A Linux bridge behaves like a simple Layer-2 Ethernet switch for this lab.

---

## Concepts introduced

- Ethernet switching
- Layer 2 vs Layer 3
- MAC addresses
- MAC learning / forwarding database
- broadcast traffic
- why a switch does not need to route between hosts on one subnet
- separating "host configuration" from "switch membership"

---

## Build the switch

Create the namespaces:

```bash
for n in h1 h2 h3; do
  sudo ip netns add "$n"
  sudo ip -n "$n" link set lo up
done
```

Create the bridge:

```bash
sudo ip link add sw1 type bridge
sudo ip link set sw1 up
```

Create three virtual patch cables:

```bash
sudo ip link add h1-eth type veth peer name swp1
sudo ip link add h2-eth type veth peer name swp2
sudo ip link add h3-eth type veth peer name swp3
```

Move host ends into namespaces:

```bash
sudo ip link set h1-eth netns h1
sudo ip link set h2-eth netns h2
sudo ip link set h3-eth netns h3
```

Attach switch ends to the bridge:

```bash
sudo ip link set swp1 master sw1
sudo ip link set swp2 master sw1
sudo ip link set swp3 master sw1
```

Bring switch ports up:

```bash
sudo ip link set swp1 up
sudo ip link set swp2 up
sudo ip link set swp3 up
```

Configure hosts:

```bash
sudo ip -n h1 addr add 10.44.10.11/24 dev h1-eth
sudo ip -n h2 addr add 10.44.10.12/24 dev h2-eth
sudo ip -n h3 addr add 10.44.10.13/24 dev h3-eth

sudo ip -n h1 link set h1-eth up
sudo ip -n h2 link set h2-eth up
sudo ip -n h3 link set h3-eth up
```

---

## Prove the network

From h1:

```bash
sudo ip netns exec h1 ping -c 2 10.44.10.12
sudo ip netns exec h1 ping -c 2 10.44.10.13
```

From h2:

```bash
sudo ip netns exec h2 ping -c 2 10.44.10.13
```

Now inspect the bridge:

```bash
bridge link
bridge fdb show br sw1
```

Look for MAC addresses associated with ports such as `swp1`, `swp2`, and `swp3`.

---

## What the switch is learning

A simple switch does not need to understand your application.

At this stage, its essential question is:

> **Which port should receive a frame destined for this MAC address?**

Conceptually:

```text
MAC A → swp1
MAC B → swp2
MAC C → swp3
```

This mapping is the forwarding database (FDB).

If the switch does not know where a destination MAC lives, it may flood the frame across eligible ports until it learns from observed source MAC addresses.

---

# Fault 1 — Compute-02 Disappears

Detach `swp2` from the bridge without deleting the interface:

```bash
sudo ip link set swp2 nomaster
```

Now test from h1:

```bash
sudo ip netns exec h1 ping -c 2 10.44.10.12
sudo ip netns exec h1 ping -c 2 10.44.10.13
```

### Symptoms

- h3 should still be reachable
- h2 should fail
- h2's own IP configuration can still look perfectly correct

Investigate:

```bash
sudo ip -n h2 addr
sudo ip -n h2 route
sudo ip -n h2 link
bridge link
bridge fdb show br sw1
```

### Lesson

A host can have:

- correct IP
- correct subnet
- UP interface

…and still be disconnected because the switching path is broken elsewhere.

Restore:

```bash
sudo ip link set swp2 master sw1
```

---

# Fault 2 — The Silent Port

Take the switch-facing port down:

```bash
sudo ip link set swp3 down
```

Test h3 connectivity.

Then compare:

```bash
sudo ip -n h3 link
ip link show swp3
bridge link
```

Notice that the host-side interface and switch-side interface are different objects.

The failure is outside h3 even though h3 experiences the outage.

Restore:

```bash
sudo ip link set swp3 up
```

---

## Packet-capture challenge — watch a broadcast

Before generating new traffic, inspect the neighbor table in h1:

```bash
sudo ip -n h1 neigh
```

Start captures on two switch ports in separate terminals:

```bash
sudo tcpdump -eni swp2 arp
```

```bash
sudo tcpdump -eni swp3 arp
```

Then from h1, generate traffic toward another host.

If neighbor state is already cached, you may recreate the namespaces or flush the relevant neighbor entry:

```bash
sudo ip -n h1 neigh flush all
```

Then ping h2.

Observe where ARP traffic appears.

### Question

Why would an ARP request be visible beyond only the final destination's switch port?

This is your introduction to broadcast behavior.

---

## Mini challenge — identify hosts by MAC, not IP

Print each host's MAC:

```bash
sudo ip -n h1 link show h1-eth
sudo ip -n h2 link show h2-eth
sudo ip -n h3 link show h3-eth
```

Then compare them with:

```bash
bridge fdb show br sw1
```

Create a small map:

```text
Host     IP             MAC                 Switch port
h1       10.44.10.11    __:__:__:__:__:__   swp1
h2       10.44.10.12    __:__:__:__:__:__   swp2
h3       10.44.10.13    __:__:__:__:__:__   swp3
```

This is the first time you are documenting the network from both Layer 2 and Layer 3 perspectives.

---

## Debrief questions

1. What problem does a switch solve that a direct veth pair does not?
2. What does the bridge FDB map?
3. Why do h1/h2/h3 not need a router in this topology?
4. What is the difference between an IP address and a MAC address in this lab?
5. Why can h2's local configuration look healthy when its switch port is detached?
6. What evidence would distinguish a host configuration problem from a switch-path problem?

---

## Victory condition

You pass when you can draw this path and explain each boundary:

```text
h1 process
   ↓
h1 IP stack
   ↓
h1 Ethernet interface
   ↓
swp1
   ↓
sw1 bridge / forwarding decision
   ↓
swp2
   ↓
h2 Ethernet interface
   ↓
h2 IP stack
```

You should also be able to explain why **no router participated**.

---

## Artifact

Save:

```text
diagrams/mission-02-switchyard.md
```

Include:

- the topology
- host IPs
- host MACs
- bridge port mapping
- one paragraph explaining how the switch learned where each host lived

---

## Cleanup

```bash
for n in h1 h2 h3; do
  sudo ip netns del "$n" 2>/dev/null || true
done

sudo ip link del sw1 2>/dev/null || true
```
