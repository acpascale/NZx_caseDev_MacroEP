# (case) electricity_fiveZ_8736_2p_nziShadow_dev (Unofficial)

Version of case used for development and (nightly) backup by user. There is no gaurantee that this version of the case will a) run to completion in latest (unofficial) version of Macro OR b) work as expected.

When this version reaches stable operation and represents a useful update to the *stable* version, it will be merged into *_stable. If it is time period or regional expansion of a prior model, it will be become a new *stable* version.

5 May 2026
- Move from 730 hours for each month of the year in availability profiles, to profiles that better represent days in each month. This will impact generation from coal, hydropower, and biomass, and likely better align generation results for calibration with PIER2.0 results for 2024. It did not. Still 3.4 % more generation from large hydro in Macro than in PIER, and 11% more generation from Nuclear.... which lessens generation from coal and natural gas.
- Added explicit capital_recovery_period definition to all legacy assets to highlight that the model is using the default value = 1, when reporting model outputs for period 1 (2023) in which all legacy assets are built. We are using the combination of annualized_capital_cost and capitral_recovery_period in period 1, rather than investment_cost & wacc & capital_recovery_period as we do in all other periods, so that we can compare Macro investment results for period 1 directly with PIER2.0 results for 2024.
- Updated r code for plotting results to loop over multiple periods. Todo - merge in older code to plot results for multiple periods as time series.
4 May 2026
- Updated costs to for proper relationship wrt PIER2.0 costs (largely divide by 3)
- Upate R code for pre-processing of PIER2.0+Rumi input/output data for input into Macro (see code 2_* in viz_compare_infor/PIERumi/)
- CO2 emissions from coal generation appears to be between values in PIER - TBD

![Local Image](viz_compare_info/images/MACROvPIER.png) "Macro vs PIER2.0 Generation and CO2 emissions. Co2 emissions factor needs better alignment with PIER2.0 for coal, not sure of reasion for difference yet. Macro shows 3.4 % more generation from large hydro than PIER2.0+Rumi, and 11% more generation from Nuclear.... which lessens total generation from coal and natural gas. This may arise from PIERumi's use of 12 days (288 hours) to represent a year, and Macro which has adapted PIERumi's 12 days into 8760 hours. It depends on how PIER2.0+Rumi's 12 day output is translated into a year. A run of Macro with 288 hours will help determine if this might be the cause." 

![Local Image](viz_compare_info/images/PeriodCapacity.png) "Macro Period Capacities 2023 (left), 2024 (right)"

![Local Image](viz_compare_info/images/PeriodCosts.png) "Macro Period Costs 2023 (left, shows investment annuities for legacy capacity), 2024 (right shows new CAPEX investments in capacity added in 2024). Taxes and other handling fees not in variable O&M for different carriers need to be added, as well as costs for all carrier transfers."