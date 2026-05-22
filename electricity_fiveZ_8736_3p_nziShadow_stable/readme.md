# (case) electricity_fiveZ_8736_3p_nziShadow_stable (Unofficial)

Version of case used for development and (nightly) backup by user. There is no gaurantee that this version of the case will a) run to completion in latest (unofficial) version of Macro OR b) work as expected.

When this version reaches stable operation and represents a useful update to the *stable* version, it will be merged into *_stable. If it is time period or regional expansion of a prior model, it will be become a new *stable* version.

## 22 May 2026, 3p
- Added 3p to repository

## 21 May 2026, 6p & 2p
- 2p & 6p:
    - Turned UC off and removed UC related constraints from assets previosuly using UC
    - changed all hydro lifetimes to "discharge_lifetime" so model works correctly when retirement is allowed
    - changed all storage lifetimes to "discharge_lifetime" so model works correctly when retirement is allowed
- 6p:
    - fix 3p model (put regional coal prices and transfers back in place). Test, visualize, update Tableau wb. 2p,Mono = 5 min, :: 3p,Mono = 30/50 mins!
    - fix 3p model (fix storage lifetimes, add national coal source, no transfers). Test, visualize, update Tableau wb. 3p,Mono =  10 mins.

## 20 May 2026, 6p and 2p
- 2p: Minor updates to clean assets and a few small capcity adjustments
- 6p:
    - Update storage assets sheet for auto-populate based on year of seleected periods (from PIER2.0), see (viz_compare_info/0_India5region_PIERinfo.xlsx) 
    - populated 3p model with updated nodes, availability, demand, and assets folders. Tested and visualized using updated Tableau workbook. (soft fail, to do with coal transfers)

## 15 May 2026, 6p (and also works for 2p)
- Update support workbook (viz_compare_info/0_India5region_PIERinfo.xlsx) to auto-populate paramaters for expanded nodes using PIER2.0 files
    - Updated nodes sheet for 6 periods
    - Updated asset sheet for 6 periods