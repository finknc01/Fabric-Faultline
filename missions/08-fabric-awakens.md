# Mission 08 — The Fabric Awakens

## Briefing
Helios is expanding from a few hosts into multiple racks. A single-switch mental model no longer scales.

## Objective
Understand leaf-spine architecture, east-west traffic, path diversity, oversubscription, failure domains, and ECMP concepts.

## Build
Model two leaf and two spine devices using namespaces/bridges/routers. Attach two compute nodes to each leaf. Static routing is acceptable for the core exercise; optional routing software may be added later.

## Tasks
Trace same-leaf and cross-leaf traffic. Calculate available uplink/downlink capacity and an oversubscription ratio. Fail one spine path and document what a resilient production fabric should do.

## Evidence to save
- leaf-spine diagram
- path table for representative flows
- oversubscription calculation
- failure-domain notes

## Victory condition
You can explain why AI clusters favor predictable east-west fabrics and what a spine failure should mean to properly designed connectivity.
