using MacroEnergy
using Gurobi
using Logging

(system, model) = run_case(@__DIR__; 
                    optimizer=Gurobi.Optimizer, log_level=Logging.Debug,
                    optimizer_attributes=("Method" => 2, "Crossover" => 1, "BarConvTol" => 1e-4),
    lazy_load=false,
);