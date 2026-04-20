#!/usr/bin/env julia
# Script de comparaison TP2 vs TP3
# TP2 : Branch-and-Bound
# TP3 : Programmation Dynamique
# À exécuter après avoir complété les deux notebooks

using DataFrames, Printf, BenchmarkTools

# ============================================================================
# FONCTION DE LECTURE D'INSTANCES
# ============================================================================
function readKnaptxtInstance(filename)
    price=[]
    weight=[]
    KnapCap=[]
    open(filename) do f
        for i in 1:3
            tok = split(readline(f))
            if(tok[1] == "ListPrices=")
                for i in 2:(length(tok)-1)
                    push!(price,parse(Int64, tok[i]))
                end
            elseif(tok[1] == "ListWeights=")
                for i in 2:(length(tok)-1)
                    push!(weight,parse(Int64, tok[i]))
                end
            elseif(tok[1] == "Capacity=")
                push!(KnapCap, parse(Int64, tok[2]))
            else
                println("Unknown read :", tok)
            end 
        end
    end
    capacity=KnapCap[1]
    return price, weight, capacity
end

# ============================================================================
# TP3 : PROGRAMMATION DYNAMIQUE
# ============================================================================
function solveKnapDP(filename)
    ## Loading data ##
    prices, weights, capacity_bag = readKnaptxtInstance(filename)

    ## Initialisation of the matrix ##
    n_items = length(prices)
    n_columns = capacity_bag + 1
    matrix_best_price = zeros(n_items, n_columns)

    ## Fulfilling th first row ##
    for capacity in weights[1]+1:n_columns
        matrix_best_price[1,capacity] = prices[1]
    end
    
    ## Fulfilling the matrix with the recursive formula ##
    for item in 2:n_items
        for capacity in 1:n_columns
            if capacity >= weights[item]+1
                matrix_best_price[item, capacity] = max(matrix_best_price[item-1, capacity], matrix_best_price[item-1, capacity-weights[item]] + prices[item])
            else
                matrix_best_price[item, capacity] = matrix_best_price[item-1, capacity]
            end
        end
    end

    best_cost = matrix_best_price[n_items, n_columns]

    ## Backtracking to identify items selected
    remaining_capacity = capacity_bag + 1 
    list_items_selected = []

    ## Backtracking rows 2:n_items
    for item in n_items:-1:2
        if matrix_best_price[item, remaining_capacity] != matrix_best_price[item-1, remaining_capacity]
            push!(list_items_selected, item)
            remaining_capacity -= weights[item]
        end
    end

    ## Checking whether item n°1 has been selected 
    if matrix_best_price[1,remaining_capacity] > 0
        push!(list_items_selected, 1)
    end

    return best_cost, reverse(list_items_selected)
end

# ============================================================================
# TP2 : BRANCH-AND-BOUND (à appeler depuis le notebook TP2)
# ============================================================================
# NOTE : Vous devez exécuter les cellules du TP2 d'abord pour que 
# la fonction solveKnapInstance soit disponible

# ============================================================================
# INSTANCES À TESTER
# ============================================================================
instances = [
    ("test.opb.txt", "InstancesKnapSack/test.opb.txt"),
    ("Similar_Weights_100", "InstancesKnapSack/Similar_Weights/KnapSack_100_1000_-995.opb.txt"),
    ("Strongly_Correlated_100", "InstancesKnapSack/Strongly_Correlated/KnapSack_100_1000_-2397.opb.txt"),
    ("Uncorrelated_100", "InstancesKnapSack/Uncorrelated/KnapSack_100_1000_-9147.opb.txt"),
    ("Weakly_Correlated_100", "InstancesKnapSack/Weakly_Correlated/KnapSack_100_1000_-1514.opb.txt"),
]

# ============================================================================
# STRUCTURE POUR LES RÉSULTATS
# ============================================================================
mutable struct ResultatComparaison
    instance_name::String
    tp3_cost::Float64
    tp3_items::Vector
    tp3_time::Float64
    tp2_cost::Union{Float64, Missing}
    tp2_time::Union{Float64, Missing}
end

# ============================================================================
# MAIN - COMPARAISON
# ============================================================================
println("╔" * "=" ^ 78 * "╗")
println("║" * " " ^ 15 * "COMPARAISON TP2 (Branch-and-Bound) vs TP3 (Programmation Dynamique)" * " " ^ 0 * "║")
println("╚" * "=" ^ 78 * "╝")
println()

resultats = ResultatComparaison[]

for (name, filepath) in instances
    if !isfile(filepath)
        println("⚠️  Fichier non trouvé : $filepath")
        continue
    end
    
    println("📊 Instance : $name")
    println("   Chemin : $filepath")
    
    try
        # Exécuter TP3 (Programmation Dynamique)
        tp3_time = @elapsed begin
            tp3_cost, tp3_items = solveKnapDP(filepath)
        end
        
        println("   ✓ TP3 (PD)     : Coût = $tp3_cost, Temps = $(round(tp3_time*1000, digits=2)) ms")
        
        # TP2 : À compléter si vous exécutez le script dans l'environnement TP2
        tp2_cost = missing
        tp2_time = missing
        
        push!(resultats, ResultatComparaison(name, tp3_cost, tp3_items, tp3_time, tp2_cost, tp2_time))
        
    catch e
        println("   ❌ ERREUR TP3 : $e")
    end
    
    println()
end

# ============================================================================
# AFFICHAGE DU TABLEAU COMPARATIF
# ============================================================================
println("╔" * "=" ^ 78 * "╗")
println("║" * " " ^ 32 * "RÉSUMÉ COMPARATIF" * " " ^ 30 * "║")
println("╚" * "=" ^ 78 * "╝")
println()

println(@sprintf "%-25s | %12s | %12s | %12s", "Instance", "TP3 Cost", "TP3 Time(ms)", "TP2 Cost")
println("-" ^ 78)

for r in resultats
    tp2_str = ismissing(r.tp2_cost) ? "À compléter" : @sprintf("%.0f", r.tp2_cost)
    println(@sprintf "%-25s | %12.0f | %12.2f | %12s", 
            r.instance_name, r.tp3_cost, r.tp3_time*1000, tp2_str)
end

println()
println("╔" * "=" ^ 78 * "╗")
println("║" * " " ^ 28 * "INSTRUCTIONS POUR COMPLÉTER L'ANALYSE" * " " ^ 13 * "║")
println("╚" * "=" ^ 78 * "╝")
println()
println("1️⃣  Exécutez d'abord TOUTES les cellules du NotebookTP2.ipynb")
println("2️⃣  Puis importez les résultats TP2 dans ce script")
println("3️⃣  Les résultats TP3 (Programmation Dynamique) sont déjà calculés")
println("4️⃣  Comparez les coûts et les temps d'exécution")
println()
println("💡 Notes :")
println("   - Les deux méthodes doivent trouver le MÊME coût optimal")
println("   - TP3 (PD) : O(n × capacity) en temps et espace")
println("   - TP2 (B&B) : Élimine des branches mais peut être plus lent sur petites instances")
println()
