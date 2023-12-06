using PrettyPrinting

"""
    parse_map(str)

Converts mapping such as
    50 98 2
    52 50 48
into a mapping of Function type.
"""
function parse_map(str)
    thing = [[parse(Int,cap) for cap in m.captures] for m in eachmatch(r"^(\d+) (\d+) (\d+)$"m, str)]
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
    collect(parse(Int,m.match) for m in eachmatch(r"\d+", str))
end

function main()
    file_contents = read("day5_input.txt", String)
    v = split(file_contents, "\n\n")

    seeds = parse_seeds(v[1])
    maps = parse_map.(v[2:end])

    # For each seed, pass it through the maps
    things = seeds
    for mapping in maps
        things = [mapping(thing) for thing in things]
    end
    lowest_location = minimum(things)
    println("Lowest location: $lowest_location")
end

main()
