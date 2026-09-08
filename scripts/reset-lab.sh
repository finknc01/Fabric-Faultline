#!/usr/bin/env bash
set -euo pipefail

# Fabric-Faultline reset helper.
# Removes only the namespace/link names used by documented lab missions.
# It does NOT flush host firewall rules, NetworkManager connections, host routes,
# or unrelated interfaces.

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root (for example: sudo $0)." >&2
  exit 1
fi

NAMESPACES=(
  alpha beta
  h1 h2 h3
  red1 red2 blue1 blue2
  client server router
  compute1 compute2 compute3 compute4
  leaf1 leaf2 spine1 spine2
)

ROOT_LINKS=(
  sw1
  br-red br-blue
  leaf1 leaf2 spine1 spine2
)

existing_namespaces=()
existing_links=()

for ns in "${NAMESPACES[@]}"; do
  if ip netns list | awk '{print $1}' | grep -qx "$ns"; then
    existing_namespaces+=("$ns")
  fi
done

for link in "${ROOT_LINKS[@]}"; do
  if ip link show "$link" >/dev/null 2>&1; then
    existing_links+=("$link")
  fi
done

echo "Fabric-Faultline reset preview"
echo "Known lab namespaces present: ${existing_namespaces[*]:-(none)}"
echo "Known lab root links present: ${existing_links[*]:-(none)}"

if [[ ${#existing_namespaces[@]} -eq 0 && ${#existing_links[@]} -eq 0 ]]; then
  echo "No documented Fabric-Faultline resources found."
  exit 0
fi

read -r -p "Delete only the resources listed above? [y/N] " answer
if [[ ! ${answer} =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

for ns in "${existing_namespaces[@]}"; do
  echo "Deleting namespace: $ns"
  ip netns delete "$ns"
done

for link in "${existing_links[@]}"; do
  if ip link show "$link" >/dev/null 2>&1; then
    echo "Deleting root link/bridge: $link"
    ip link delete "$link"
  fi
done

echo "Reset complete. Unlisted host resources were not targeted."
