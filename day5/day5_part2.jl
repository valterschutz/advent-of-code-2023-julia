using PrettyPrinting
using ProgressBars
# using StaticArrays
using DataStructures

"""
    parse_map(str)

Converts mapping such as
    50 98 2
    52 50 48
into a mapping of Function type.
"""
function parse_map(str)
    thing = [[parse(Int,cap) for cap in m.captures] for m in eachmatch(r"^(\d+) (\d+) (\d+)$"m, str)]
    d = Dict((src_range_start:(src_range_start+range_length-1), dest_range_start:(dest_range_start+range_length-1)) for (dest_range_start, src_range_start, range_length) in thing)
    return function(src)
        for (dest_range_start, src_range_start, range_length) in thing
            if src in src_range_start:(src_range_start+range_length-1)
                return dest_range_start + (src-src_range_start)
            end
        end
        return src
    end
end

function parse_seeds(str)
    g = (parse.(Int,m.captures) for m in eachmatch(r"(\d+) (\d+)", str))
    return (i for (range_start, range_length) in g for i in range_start:(range_start+range_length-1))
end

function main()
    file_contents = read("day5_input.txt", String)
    v = split(file_contents, "\n\n")

    seeds = parse_seeds(v[1])
    println("seeds parsed")
    maps = parse_map.(v[2:end])
    println("maps parsed")

    # For each seed, pass it through the maps
    lowest_location = minimum(foldl((acc,f) -> f.(acc), maps, init=seeds))
    println("Lowest location: $lowest_location")
end

main()
