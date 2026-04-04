## v3.6.16 - 2026-04-04
### Variable Cell Count Support (1S to 16S)

- Added major support for variable cell-count battery packs (1S to 16S).
- The addon now automatically detects the real number of cells reported by the BMS (`cell_count_N`) and adjusts cell voltage calculations accordingly.
- This ensures correct min/max/average/delta values on 4S, 8S, 15S and all other supported configurations up to 16S.

⚠️ Ne pas utiliser cette version en production !!!!  ⚠️
Elle sert pour diagnostiquer et tester