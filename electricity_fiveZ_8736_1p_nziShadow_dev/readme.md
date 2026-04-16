# 5 zone, electricity-only example with 1 planning period (2024), based on the PIER2.0 demand and supply model at https://zenodo.org/records/18043483

This is a simple example of a fize-zone model with electricity-only generation and load. It is loosely based on the India grid in 2024. It is intended to demonstrate the basic structure of a Macro (https://github.com/macroenergy/MacroEnergy.jl)case, and aspires to eventually demonstrate best-practice formatting and documentation of an active Case build.

Macro results can be viewed using the Tableau workbook (2_MACRO_results_long_5z_8736_1p_twh_viz.twb) in the "viz_compare_info" folder, or a few basic plots can be generated using the R code (3_NZI_Macro_energyPlots_8736out.r) in the same folder. The R code will need modification to specify inputs and outputs. The R code will be updated as needed for additional plots.

A summary of (evolving) model inputs can be found in the "0_NZIshadow_PIERinfo.xlsx" workbook in the "viz_compare_info" folder.  This model will be ported to a multiperiod model during the first half of 2026.

16 April 2026 p2
This case now runs as expected in the current version of Macro available on the post date. Fixes required to bring my case into alignemnt with the current version of Macro are documented here: https://github.com/MacroEnergy/MacroEnergy.jl/issues/226 . Explicit definition of BalanceConstraint for all nodes in nodes.json, which was adopted to allow forward-backward compatability with versions of Macro has been removed, with only modes with the non-default BalanceConstraint=false being explicitly defined. DEV case transferred to "stable".
16 April 2026 p1
Have added explicit defintiion for "BalanceConstraint" to all nodes in the nodes.json file (in system folder). 
Now, the *dev stream case works with both old and new versions of Macro, BUT the case produces different results depending on whether run with new or old version of Macro. Tentative reason appears to be with tracking and inclusion of fuel costs in optimization. 
I have moved back to older version of Macro (git reset --hard  b044fda9007b3b25a3ae6c9404ccb95945dde1e8)