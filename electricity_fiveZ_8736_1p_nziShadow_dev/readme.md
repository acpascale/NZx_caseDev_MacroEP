# 5 zone, electricity-only example with 1 planning period (2024), based on the PIER2.0 demand and supply model at https://zenodo.org/records/18043483

This is a simple example of a fize-zone model with electricity-only generation and load. It is loosely based on the India grid. It is intended to demonstrate the basic structure of a model in this repository. More details will be added in the future.

16 April 2026
Have added explicit defintiion for "BalanceConstraint" to all nodes in the nodes.json file (in system folder). 
Now, the *dev stream case works with both old and new versions of Macro, BUT the case produces different results depending on whether run with new or old version of Macro. Tentative reason appears to be with tracking and inclusion of fuel costs in optimization. 
I have moved back to older version of Macro (git reset --hard  b044fda9007b3b25a3ae6c9404ccb95945dde1e8)