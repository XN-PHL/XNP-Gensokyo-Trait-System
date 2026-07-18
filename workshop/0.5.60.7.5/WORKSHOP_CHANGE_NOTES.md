# 0.5.60.7.5 Runtime Test

- Corrected world-to-screen projection to deduct the selected player's camera offset exactly once.
- Applied the engine-proven per-player zoom division and global-UI viewport origin.
- Added fail-closed inflight draw proof before impact damage or cooldown consumption.
- Added a 500 ms/two-frame minimum visible flight and a default-on diagnostic border.
- Replaced the outline route's global zombie enumeration with a bounded lock-area square scan.
- Preserved NPC/Bandit damage, player immunity, native impact markers, and runtime no-cooldown.
- Removed development evidence and raw logs from the public Workshop tree.
