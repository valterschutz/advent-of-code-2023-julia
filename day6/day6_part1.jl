function ways_to_beat_record(time,record_distance)
    # travel_time = time-boat_spd
    # boat_dist = boat_spd(time-boat_spd)
    count(boat_spd*(time-boat_spd) > record_distance for boat_spd in 1:time-1)
end

# Parse input, guaranteed 2 lines
time_line, distance_line = readlines("day6_input.txt")
times = eachmatch(r"\d+", time_line) .|> (m -> parse(Int,m.match))
distances = eachmatch(r"\d+", distance_line) .|> (m -> parse(Int,m.match))

# For each race, in how many different ways can we win?
num = reduce(*, ways_to_beat_record(time,distance) for (time,distance) in zip(times,distances))
println("The multiplied number is $num")
