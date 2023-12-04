struct Card
    winning_numbers::Vector{Int}
    have_numbers::Vector{Int}
end

cards::Vector{Card} = []

# Extract all numbers from a String
function numbers(t::Type{T}, str::AbstractString) where {T<:Number}
    collect(parse(t, m.match) for m in eachmatch(r"\d+", str))
end

# How many points a card is worth
function points(card::Card)
    n_matches = count(x -> x in card.winning_numbers, card.have_numbers)
    if n_matches == 0
        return 0
    end
    2^(n_matches-1)
end

# Parse input
for line in eachline("day4_input.txt")
    line = line[9:end] # Skip the "Card X: " part
    winning_str, have_str = split(line, '|')
    winning_nums = numbers(Int, winning_str)
    have_nums = numbers(Int, have_str)
    push!(cards, Card(winning_nums, have_nums))
end

println("Total points: $(cards .|> points |> sum)")
