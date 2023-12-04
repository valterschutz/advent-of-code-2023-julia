mutable struct Card
    winning_numbers::Vector{Int}
    have_numbers::Vector{Int}
    cardinality::Int
end

cards::Vector{Card} = []

# Extract all numbers from a String
function numbers(t::Type{T}, str::AbstractString) where {T<:Number}
    collect(parse(t, m.match) for m in eachmatch(r"\d+", str))
end

# How many matches a card has
function n_matches(card::Card)
    return count(x -> x in card.winning_numbers, card.have_numbers)
end

# Parse input
for line in eachline("day4_input.txt")
    line = line[9:end] # Skip the "Card X: " part
    winning_str, have_str = split(line, '|')
    winning_nums = numbers(Int, winning_str)
    have_nums = numbers(Int, have_str)
    push!(cards, Card(winning_nums, have_nums, 1))
end

# Add cards
for i = 1:length(cards)
    card = cards[i]
    n_match = n_matches(card)
    for j = i+1:i+n_match
        if j > length(cards)
            break
        end
        cards[j].cardinality += card.cardinality
    end
end

# Total amount of cards is the sum of their cardinality
tot_cardinality = sum(card.cardinality for card in cards)
println("Total amount of cards: $tot_cardinality")
