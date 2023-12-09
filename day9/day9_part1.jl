# Parse histories
histories = eachline("day9_input.txt") .|>
            split .|>
            (x -> parse.(Int, x))

last_values::Vector{Int} = []
for history in histories
    # Take the difference between elements until we get all 0s
    thing = [history]
    while !all(x == 0 for x in thing[end])
        push!(thing, diff(thing[end]))
    end

    # Now add a 0 at the end and fill arrays backwards
    push!(thing[end], 0)
    prev_v = thing[end]
    for v in thing[end-1:-1:1]
        push!(v, v[end] + prev_v[end])
        prev_v = v
    end

    # We only care about the last value
    push!(last_values, thing[1][end])
end

s = sum(last_values)
println("Sum of last values: $s")
