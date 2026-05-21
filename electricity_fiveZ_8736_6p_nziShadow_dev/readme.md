# (case) electricity_fiveZ_8736_6_nziShadow_dev (Unofficial)

Version of case used for development and (nightly) backup by user. There is no gaurantee that this version of the case will a) run to completion in latest (unofficial) version of Macro OR b) work as expected.

When this version reaches stable operation and represents a useful update to the *stable* version, it will be merged into *_stable. If it is time period or regional expansion of a prior model, it will be become a new *stable* version.

## Running list of
- Comparisons between PIERumi and Macro
    - Primary energy accounting
    - Variable cost accounting
    - Fuel cost accounting for electricity
    - Nuclear and Hydro, why Macro larger?
- Differences between PIERumi and Macro
    - Base reporting of investement costs (Macro default is annuity * remaining model window; PIERumi default is annuity streams)
    - Base reporting of transmission costs (Macro's approach is to cost assets; PIERumi's is to apply a variable 'transit' cost to electricity, which includes asset annuities... this may be the way that Macro deals with distribution costs eventually, but more likely that Macro considers upfront CAPEX of new long-distance transmission)
    - Base reporting of commodity costs used in the generation of electricity (Macro reports those costs as fuel costs ; PIERumi calculates and reports the cost of electricity (which aggregates the cost of both fuels and transmission?? TBD))
- Assets/Constraints/Systems modelled in PIER2.0, but not (yet**) in Macro, ** = plans to implement by mid-June
    - Coal transfer and regional pricing scheme: important from the perspective of equity and energy systems in India, but unlikely to shift optimization. Test of system in 2p model led to ~3x increase in run time, left out of 6p model right now (see assets/notFielded)
    - **Rest of India energy system, beyond the electricity grid
- Assets/Constraints/Systems not modelled in PIER2.0, but with eventual plans for inclusion in Macro
    - Industrial production systems will be modelled in Macro and included in the optimization
- Issues to be discussed/resolved in Macro
    - Modelling of future tecnology improvements between periods
        - PIER wraps this into its availability profiles, and tying the profile in all future years to the installation year. It is unclear how Macro carries forward the installation state of legacy assets... what is recommended? I would expect that the availability of wind and solar should be left available to be tied to climate changes and not represent technology changes. 

## 21 May 2026, 6p & 2p
- 2p & 6p:
    - Turned UC off and removed UC related constraints from assets previosuly using UC
    - changed all hydro lifetimes to "discharge_lifetime" so model works correctly when retirement is allowed
    - changed all storage lifetimes to "discharge_lifetime" so model works correctly when retirement is allowed
- 6p:
    - fix 3p model (put regional coal prices and transfers back in place). Test, visualize, update Tableau wb. 2p,Mono = 5 min, :: 3p,Mono = 30/50 mins!
    - fix 3p model (fix storage lifetimes, add national coal source, no transfers). Test, visualize, update Tableau wb. 3p,Mono =  10 mins.
    - populated 4p model with updated nodes, availability, demand, and assets folders. Tested and visualized using updated Tableau workbook.
    - populated 5p model with updated nodes, availability, demand, and assets folders. Tested and visualized using updated Tableau workbook.
    - populated 6p model with updated nodes, availability, demand, and assets folders. Tested and visualized using updated Tableau workbook.

## 20 May 2026, 6p and 2p
- 2p: Minor updates to clean assets and a few small capcity adjustments
- 6p:
    - Update storage assets sheet for auto-populate based on year of seleected periods (from PIER2.0), see (viz_compare_info/0_India5region_PIERinfo.xlsx) 
    - populated 3p model with updated nodes, availability, demand, and assets folders. Tested and visualized using updated Tableau workbook. (soft fail, to do with coal transfers)

## 15 May 2026, 6p (and also works for 2p)
- Update support workbook (viz_compare_info/0_India5region_PIERinfo.xlsx) to auto-populate paramaters for expanded nodes using PIER2.0 files
    - Updated nodes sheet for 6 periods
    - Updated asset sheet for 6 periods