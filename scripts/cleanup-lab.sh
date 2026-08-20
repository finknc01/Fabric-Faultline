#!/usr/bin/env bash
set -euo pipefail

# Fabric-Faultline cleanup helper.
# Safety rule: this script only removes network namespaces and links whose
# names begin with the lab prefix "ff-". Build lab resources with that prefix.

PREFIX="ff-"

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root (for example: sudo $0)." >&2
  exit 1
fi

mapfile -t namespaces < <(ip netns list | awk '{print $1}' | grep -E "^${PREFIX}" || true)
mapfile -t links < <(ip -o link show | awk -F': ' '{print $2}' | cut -d@ -f1 | grep -E "^${PREFIX}" || true)

echo "Fabric-Faultline cleanup preview"
echo "Namespaces: ${namespaces[*]:-(none)}"
echo "Root-namespace links: ${links[*]:-(none)}"

if [[ ${#namespaces[@]} -eq 0 && ${#links[@]} -eq 0 ]]; then
  echo "Nothing matching prefix ${PREFIX} found."
  exit 0
fi

read -r -p "Delete only the resources listed above? [y/N] " answer
if [[ ! ${answer} =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

for ns in "${namespaces[@]}"; do
  ip netns delete "${ns}" || true
done

# Deleting a bridge usually removes its attached virtual endpoints as links are
# dismantled; this second pass catches any ff-* root-namespace links left over.
for link in "${links[@]}"; do
  if ip link show "${link}" &>/dev/null; then
    ip link delete "${link}" || true
  fi
done

echo "Cleanup complete. Non-ff-* interfaces/namespaces were not targeted."
