#!/usr/bin/env bash
set -u

# Fabric-Faultline lab cleanup helper.
# Removes only namespaces/bridges used by the documented missions below.
# It intentionally does NOT flush host firewall rules, routes, or interfaces.

NAMESPACES=(
  alpha beta
  h1 h2 h3
  red1 red2 blue1 blue2
  client server router
  compute1 compute2 compute3 compute4
  leaf1 leaf2 spine1 spine2
)

LINKS=(
  sw1
  br-red br-blue
  leaf1 leaf2 spine1 spine2
)

echo "[Fabric-Faultline] Cleaning known lab namespaces..."
for ns in "${NAMESPACES[@]}"; do
  if sudo ip netns list | awk '{print $1}' | grep -qx "$ns"; then
    echo "  deleting namespace: $ns"
    sudo ip netns del "$ns"
  fi
done

echo "[Fabric-Faultline] Cleaning known lab links/bridges..."
for link in "${LINKS[@]}"; do
  if ip link show "$link" >/dev/null 2>&1; then
    echo "  deleting link: $link"
    sudo ip link del "$link"
  fi
done

echo "[Fabric-Faultline] Cleanup complete."
