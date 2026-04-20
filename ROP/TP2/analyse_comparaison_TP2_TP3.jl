# Script de comparaison TP2 vs TP3
# À exécuter après avoir complété les deux notebooks

include("NotebookTP2.ipynb")  # Charger les fonctions du TP2
include("TP3_skeleton.ipynb") # Charger les fonctions du TP3

using DataFrames, Statistics

# Fonction de lecture (réutilisée)
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

# Lister toutes les instances
instances = [
    "InstancesKnapSack/test.opb.txt",
    "InstancesKnapSack/Similar_Weights/KnapSack_100_1000_-995.opb.txt",
    "InstancesKnapSack/Strongly_Correlated/KnapSack_100_1000_-2397.opb.txt",
    "InstancesKnapSack/Uncorrelated/KnapSack_100_1000_-9147.opb.txt",
    "InstancesKnapSack/Weakly_Correlated/KnapSack_100_1000_-1514.opb.txt",
]

results = DataFrame(
    Instance = String[],
    TP2_Cost = Float64[],
    TP3_Cost = Float64[],
    Match = Bool[],
    Difference = Float64[]
)

println("=" ^ 80)
println("COMPARAISON TP2 vs TP3 - Programmation Dynamique pour le Sac à Dos")
println("=" ^ 80)
println()

for instance in instances
    if isfile(instance)
        println("Testant : $instance")
        
        try
            # Résultat TP3 (programmation dynamique)
            tp3_cost, tp3_items = solveKnapDP(instance)
            
            # Résultat TP2 (à adapter selon votre implémentation)
            # Supposant que votre TP2 a une fonction solveKnapXXX
            # À ADAPTER selon votre implémentation réelle du TP2
            # tp2_cost, tp2_items = solveKnapTP2(instance)  # À remplacer
            
            # Pour le moment, on affiche juste le TP3
            println("  TP3 (Prog. Dynamique) : Cost = $tp3_cost, Items = $tp3_items")
            println()
            
            # push!(results, (instance, tp2_cost, tp3_cost, tp2_cost ≈ tp3_cost, abs(tp2_cost - tp3_cost)))
            
        catch e
            println("  ERREUR : $e")
            println()
        end
    else
        println("Fichier non trouvé : $instance")
        println()
    end
end

println("=" ^ 80)
println("RÉSUMÉ DE L'ANALYSE")
println("=" ^ 80)
# println(results)
println()
println("NOTE : Cette analyse compare les résultats des deux approches.")
println("Les solutions doivent être identiques (même coût optimal).")
println("La programmation dynamique du TP3 doit trouver l'optimum global.")
println()
