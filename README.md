# Case development repository for modelling net-zero transitions in Macro and energyPATHWAYS models

## (case) electricity_fiveZ_8736_1p_nziShadow_*
Electricity-only, 5 zone, runs over 52 sub-periods * 168 hours each = 8736 hours, runs for single planning period (2024), 

Data source: [1] PIER2.0 demand and supply model at https://zenodo.org/records/18043483.

Description: This case provides an example of a fize-zone model with electricity-only generation and load. It is based on the India grid in 2024, as represented in PIER2.0 [1]. The case is intended to demonstrate the basic structure of a Case designed to use the Macro model framework (https://github.com/macroenergy/MacroEnergy.jl). One goal of this case is to eventually demonstrate best-practice formatting and documentation.

Macro results can be viewed using either: 
- the Tableau workbook (2_MACRO_results_long_5z_8736_1p_twh_viz.twb) in the "viz_compare_info" folder, or 
- a few basic plots can be generated using the R code (3_NZI_Macro_energyPlots_8736out.r) in the same folder. 

Users will need to modify the R code to specify inputs and output paths, and case names sepecific to their local configuration. The R code will be updated as needed for additional plots.

A summary of (evolving) model inputs drawn from PIER2.0 [1] can be found in the "0_NZIshadow_PIERinfo.xlsx" workbook in the "viz_compare_info" folder.  

This model will be ported to a multiperiod model during the first half of 2026.

Activity
17 April 2026 - reintroduction of explicit "BalanceConstraint" definitions for all nodes in the nodes.json file for transparency and clarity on advice of LB. Addition of a stable (Official) case that is meant to be back compatible with the last Official release of Macro.

16 April 2026 p2
This case now runs as expected in the current version of Macro available on the post date. Fixes required to bring my case into alignemnt with the current version of Macro are documented here: https://github.com/MacroEnergy/MacroEnergy.jl/issues/226 . Explicit definition of BalanceConstraint for all nodes in nodes.json, which was adopted to allow forward-backward compatability with versions of Macro has been removed, with only modes with the non-default BalanceConstraint=false being explicitly defined. DEV case transferred to "stable".

16 April 2026 p1
Have added explicit defintiion for "BalanceConstraint" to all nodes in the nodes.json file (in system folder). 
Now, the *dev stream case works with both old and new versions of Macro, BUT the case produces different results depending on whether run with new or old version of Macro. Tentative reason appears to be with tracking and inclusion of fuel costs in optimization. 
I have moved back to older version of Macro (git reset --hard  b044fda9007b3b25a3ae6c9404ccb95945dde1e8)