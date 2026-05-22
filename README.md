# Case development repository for modelling net-zero transitions in Macro and energyPATHWAYS models

## (case) electricity_fiveZ_8736_Xp_nziShadow_*
Electricity-only, 5 zone, runs over 52 sub-periods * 168 hours each = 8736 hours, runs for X planning periods, 

Data source: [1] PIER2.0 demand and supply model at https://zenodo.org/records/18043483.

Description: This case provides an example of a fize-zone model with electricity-only generation and load. It is based on the India grid in 2024, as represented in PIER2.0 [1]. The case is intended to demonstrate the basic structure of a Case designed to use the Macro model framework (https://github.com/macroenergy/MacroEnergy.jl). One goal of this case is to eventually demonstrate best-practice formatting and documentation.

Macro results can be viewed using either: 
- the Tableau workbook (2_MACRO_results_long_5z_8736_Xp_twh_viz.twb) in the "viz_compare_info" folder, or 
- a few basic plots can be generated using the R code (3_NZI_Macro_energyPlots_8736out.r) in the same folder. 

Users will need to modify the R code to specify inputs and output paths, and case names sepecific to their local configuration. The R code will be updated as needed for additional plots.

The latest summary of (evolving) model inputs drawn from PIER2.0 [1] can be found in the "[...]_6p_nziShadow_stable\viz_compare_info\0_India5region_PIERinfo.xlsx" workbook.

## Short-term todo list
1. Extend 8760 to 6 period run (see electricity_fiveZ_8736_6p_nziShadow_dev)
2. Compare primary energy use for power generation to make sure that case primary energy results are similar to PIER2.0 -- TechMin?
3. Make 288-hour branch of 2p
4. Extend 288 to 18 period (18p) run 

## Long-term todo list 
1. Determine why hydro and nuclear have higher electricity generation in Macro 
2. Expand Macro case to include demand for other energy carriers -- disaggregating demand appropriately for matching with already available/planned Macro modules  
3. '                  ' upstream infrastructure needed to serve demand
4. '                  ' industry modules for inclusion in the ootimization 
5. Expand plotting code to other output files
6. How to efficienctly swap fuel characteristics (eg Domestic vs Imported coal without adding entirely new assets)

## 22 May 2026 3p, 6p(4p)
- Added 3p to repository
- Started 4p, but incomplete.

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

## 15 May 2026, 2p & 6p (to stable)
- Minor updates on coal and transmission assets to
    - correct fuel use of legacy coal plants
    - remove redundant lines in transmission and storage instances
    - correct investment cost of new coal plants (none) in period 2 (2024)
    - update images shown in this readme
- Added 6p shell with support workbook (viz_compare_info/0_India5region_PIERinfo.xlsx) to auto-populate paramaters for expanded nodes using PIER2.0 files
    - Updated nodes sheet for 6 periods
    - Updated asset sheet for 6 periods

## 13 May 2026, 2p
2p Test Runs
- 1
    - "SolutionAlgorithm": "Monolithic"
    - run_benders.jl
    - 50 minutes (running with Highs not Gurobi ... perhaps defining an impossible combination led to a Highs default?)
- 2 
    - "SolutionAlgorithm": "Benders"
    - run_benders.jl
    - 1h 45 minutes (Macro selected Gurobi not Highs this time, as instructured in run_benders.jl, perhaps my settings for benders led to the long run time)
- 3 (mirroring last run yesterday)
    - "SolutionAlgorithm": "Monolithic"
    - run.jl
    - 16 minutes (using Gurobi)

## 12 May 2026 , 2p
- Disaggregated coal supply into regional nodes with regional domestic and imported capacities. Added in inter- and intra-regional transfers for coal with costs and losses (and distances... does Macro use distances??). Similar bus-bar arrangement to electricity. Coal transfers in MWh are priced in PIER2.0 in million tonnes. Macro is in MWh, which means there should be different per-MWh prices for domestic and imported coal (with imported being cheaper due to a higher specific energy), but have not made that adjustment. Would need to add separate domestic and import nodes in order to deal with difference in specific energies. Along the same lines, would need to differentiate between generation units burning doemstic vs imported coal in order to deal with differences in GHG profiles (asset instances). Addition of regional upstream T&D added ~11 minutes to run time (18 min instead of 7 min... sp almost 3x prior run time!) A question on whether another structure is possible that would keep needed detail but reduce run time. The importance of India's coal resource and industry is an important aspect of any energy transition in India.

## 11 May 2026, 2p (moved to stable)
- Change legacy and new transmission to unidirectional with different potential flows in opposite directions in same 'corridor'. Added variable O&M costs as equivalent to PIER2.0 "transit cost". Max-transit is the legacy capacity. (viz_compare_info/0_India5region_PIERinfo.xlsx) 
- Fixed problem with storage assets in period 2. Comments in wrong place in file led to soft fail (no error... but fail to use any of the assets). Comments need to be located within global_data or individual instances to avoid soft fail. 

## 8 May 2026, 2p
- Changed system structure for cleaner accomodation (and quicker load) of multi-period runs by reducing demand and availability input file size.
- Added "Biomass Waste" as subcommodity for power plants. Biomass resource unallocated in electricity only.
- If forcing retirement of legacy asset, must explicity allow retirment for that region/asset (or Macro fail with 'no solutions'). Add PIER2.0 prescribed retirement of coal in norther region.
- Added taxes into commodity price, and updated resource totals in nodes. Still not split at state level for coal. 
- Updated Storage specs for periods in case and coverage in support file (viz_compare_info/0_India5region_PIERinfo.xlsx) 

## 6/7 May 2026, 2p
- Update r code to include basic multi-period plots (viz_compare_info/2_Macro_energyPlots_8736out.r).
- Update r code to generate on-demand, demand input for Macro based on periods between 2024 and 2041 (viz_compare_info/PIERumi/3_Macro_DemandGenerator_from_PIER2dot0.R). Will need further updating for projections (or seperate code until NZI data is released.)
- Improved PIER to Macro documentation for indivudal periods, will later be used to auto-generate assets based on completed period-wise sheets (viz_compare_info/0_India5region_PIERinfo.xlsx) 
- Aded in retired legacy capacity in period 2 (2024), and checked all other capacity. Found discrepancies, especially in hydro which will likely account for generation differences (see prior post) <- IT DID NOT.

## 5 May 2026, 2p
- Move from 730 hours for each month of the year in availability profiles, to profiles that better represent hours in each month. This will impact generation from coal, hydropower, and biomass, and likely better align generation results for calibration with PIER2.0 results for 2024 (viz_compare_info/PIERumi/2_Macro_TechHourlyGenerator_from_PIER2dot0.R). 
    - It did not. The Macro case still has 3.4 % more generation from large hydro and 11% more generation from nuclear than in PIER+Rumi results, providing more low-cost generation options than in PIER2.0+Rumi model.
- Added explicit capital_recovery_period definition to all legacy assets to highlight that the model is using the default value = 1, when reporting model outputs for period 1 (2023) in which all legacy assets are built. We are using the combination of annualized_capital_cost and capitral_recovery_period in period 1, rather than investment_cost & wacc & capital_recovery_period as we do in all other periods, so that we can compare Macro investment results for period 1 directly with PIER2.0 results for 2024.
- Updated r code for plotting results to loop over multiple periods. Todo - merge in older code to plot results for multiple periods as time series (viz_compare_info/2_Macro_energyPlots_8736out.r).

## 4 May 2026, 2p
- Updated costs to for proper relationship wrt PIER2.0 costs (largely divide by 3)
- Upate R code for pre-processing of PIER2.0+Rumi input/output data for input into Macro (viz_compare_info/2_Macro_energyPlots_8736out.r).
- CO2 emissions from coal generation appears to be between values in PIER - TBD

## 1 May 2026, 2p (stable)
Updated costs to use annualized investements for all legacy assets (to match PIER in 2024), and to move to CAPEX accounting for all future builds. All costs need scruitiny against PIER input/output costs to arrive at final values. Model costs are still 1e3 larger than PIER outputs!?
Added self-consumption from PIER into Macro assets via:
- Thermal generators, fuel input has been adjusted to address self consumption
- VRE, availability has been adjusted to subtract self-consumption in each hour
- Hydro, Discharge_efficiency has been updated for self-consumption

## 28 April 2026, 1p
- Updated Availabilities to be in MWh, converted from physical quantities in PIER to energy. 
- Added in PIER2.0 self consumption for all generators. Check if excess columns slows down initial load of system data or run and by how much.
- Check why unserved demand. Where is unserved demand as current plots match PIER2.0!? If moves loads back to main busbar? If bins back to infinity? 

## 27 April 2026, 1p
- Problem from Friday 24th was the location of comment, and (potentially) not enough resource. Segment specification cleaner now. Need to transfer units from MT/BCM to MWh for all energy carriers. Removed 'Infinity' from max, althugh Macro recognizes this value (without quotes). Still deriving emission rates from PIER outputs rather than from PIER2.0 carrier data. Changed availability profiles for vre legacy installs to 2023 (was 2024)- I am guessing that this is how availability profiles are used in PIER2.0, because annual technology improvements are implemented in availabilities, base availability profile * tech improvement = availability profile for tech in install year.

## 24 April 2026, 1p
- Attempt to change structure of NG nodes to handle both domestic and import supply has led to a problem with ng supply.

## 23 April 2026, 1p
- Updated emission rates for Coal and Natural gas to match PIER using results... but still need to derive them correctly.
- Added a link between the power reaching a region's electricity busbar (elec_^R), and the region's load (load_^R). This OneWay link has been added to model the region's distribution network, and has been seeded with losses specified in PIER. 

## 21 April 2026, 1p 
- (stable/stableOfficial) Fixed issues in stable Cases in repository to do with unrecognized variables in the constraint definition sections of the  nodes.json file. These were introduced in the repository update on the 17th. Note to self, do not rush to push changes without fully testing!
- (dev) Moved to two period model containing a legacy build for 2023, so that the intended single period model is passed existing assets and financial streams. Updated files and comments in files to reflect these changes. Unused assets (offshore wind & OCGT & SMR) have also been removed from period 1 in this model, although assets that still have a capacity of zero in 2024 are kept in period 2 in case they get used in later expansion of the model to run to 2041 (and beyond).

## 17 April 2026, 1p 
- reintroduction of explicit "BalanceConstraint" definitions for all nodes in the nodes.json file for transparency and clarity on advice of LB. Addition of a stable (Official) case that is meant to be back compatible with the last Official release of Macro.

## 16 April 2026, 1p post 2
- This case now runs as expected in the current version of Macro available on the post date. Fixes required to bring my case into alignemnt with the current version of Macro are documented here: https://github.com/MacroEnergy/MacroEnergy.jl/issues/226 . Explicit definition of BalanceConstraint for all nodes in nodes.json, which was adopted to allow forward-backward compatability with versions of Macro has been removed, with only modes with the non-default BalanceConstraint=false being explicitly defined. DEV case transferred to "stable".

## 16 April 2026, 1p post 1
- Have added explicit defintiion for "BalanceConstraint" to all nodes in the nodes.json file (in system folder).  Now, the *dev stream case works with both old and new versions of Macro, BUT the case produces different results depending on whether run with new or old version of Macro. Tentative reason appears to be with tracking and inclusion of fuel costs in optimization.  I have moved back to older version of Macro (git reset --hard  b044fda9007b3b25a3ae6c9404ccb95945dde1e8)

## Build Notes:
Lead to case run failures:
- Comments--or unrecognized variables--in settings/macro_settings/json (ok to have them in case_settings.json)
- Decimal in "lifetime" of an asset (e.g. 12.5 instead of 13)
- Comments--or unrecognized variables--within some constraints definititons in nodes.json
- Comments--or unrecognized variables--outside of global_data{}, or instance_data{} -->soft fail as assets just fail to show up