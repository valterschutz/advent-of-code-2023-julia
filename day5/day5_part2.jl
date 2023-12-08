using PrettyPrinting
using ProgressBars
# using StaticArrays
using DataStructures
using ProgressMeter

function parse_map(str)
    thing = [[parse(Int,cap) for cap in m.captures] for m in eachmatch(r"^(\d+) (\d+) (\d+)$"m, str)]
    return Dict((src_range_start:(src_range_start+range_length-1), dest_range_start:(dest_range_start+range_length-1)) for (dest_range_start, src_range_start, range_length) in thing)
end

function parse_seed_ranges(str)
    g = (parse.(Int,m.captures) for m in eachmatch(r"(\d+) (\d+)", str))
    return [range_start:(range_start+range_length-1) for (range_start, range_length) in g]
end

function merge_ranges(ranges)
    if isempty(ranges)
        return []
    end

    # Sort the ranges based on their start values
    sorted_ranges = sort(ranges, by=x->x.start)

    merged_ranges = [sorted_ranges[1]]

    # for i in 2:length(sorted_ranges)
    for current_range in sorted_ranges[2:end]
        # current_range = sorted_ranges[i]
        last_merged_range = merged_ranges[end]

        # Check for overlap
        if current_range.start <= last_merged_range.stop
            # Merge overlapping ranges
            merged_ranges[end] = last_merged_range.start:max(current_range.stop, last_merged_range.stop)
        else
            # Add non-overlapping range to the result
            push!(merged_ranges, current_range)
        end
    end

    return merged_ranges
end

function get_src(mapping, dest)
    for (src_range, dest_range) in mapping
        if dest in dest_range
            return src_range.start + (dest - dest_range.start)
        end
    end
    return dest
end

function main()
    file_contents = read("day5_input.txt", String)
    v = split(file_contents, "\n\n")

    seed_ranges = merge_ranges(parse_seed_ranges(v[1]))

    maps = parse_map.(v[2:end])

    # The lowest location could be any UInt32...
    local lowest_location
    for location in 1:typemax(UInt32)
        seed_candidate = foldl((acc,d) -> get_src(d,acc), reverse(maps), init=location)
        if any(seed_candidate in seed_range for seed_range in seed_ranges)
            lowest_location = location
            break
        end
    end
    println("Lowest location: $lowest_location")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
