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

    # Now add a 0 at the **start** and fill arrays backwards
    pushfirst!(thing[end], 0)
    prev_v = thing[end]
    for v in thing[end-1:-1:1]
        pushfirst!(v, v[1] - prev_v[1])
        prev_v = v
    end

    # We only care about the **first** value
    push!(last_values, thing[1][1])
end

s = sum(last_values)
println("Sum of last values: $s")
