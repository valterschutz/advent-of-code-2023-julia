using PrettyPrint
using GLMakie

struct Pipe
    type::Char # One of: '|', '-', 'L', 'J', '7', 'F', '.', 'S'
end

function Base.:(==)(pipe1::Pipe, pipe2::Pipe)
    pipe1.type == pipe2.type
end

function connection_dirs(pipe::Pipe)
    if pipe == Pipe('|')
        return [CartesianIndex(1,0), CartesianIndex(-1,0)]
    elseif pipe == Pipe('-')
        return [CartesianIndex(0,1), CartesianIndex(0,-1)]
    elseif pipe == Pipe('L')
        return [CartesianIndex(-1,0), CartesianIndex(0,1)]
    elseif pipe == Pipe('J')
        return [CartesianIndex(-1,0), CartesianIndex(0,-1)]
    elseif pipe == Pipe('7')
        return [CartesianIndex(1,0), CartesianIndex(0,-1)]
    elseif pipe == Pipe('F')
        return [CartesianIndex(1,0), CartesianIndex(0,1)]
    elseif pipe == Pipe('S')
        return [CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0), CartesianIndex(-1,0)]
    else
        return []
    end
end

function connection_possible(origin_pipe, relative_index, next_pipe)
    b1 = relative_index in connection_dirs(origin_pipe)
    b2 = (-relative_index) in connection_dirs(next_pipe)
    # println("b1 = $b1, b2 = $b2")
    return b1 && b2
end

function read_pipe_matrix(filename)
    lines = readlines(filename)
    # pprintln(lines)

    # Create pipe matrix
    pipe_matrix = Matrix{Pipe}(undef, length(lines), length(lines[1]))
    for (i,line) in enumerate(lines)
        for (j,char) in enumerate(filter(c -> c != '\n', line))
            pipe_matrix[i,j] = Pipe(char)
        end
    end

    return pipe_matrix
end

function find_S_index(pipe_matrix)
    findfirst(pipe -> pipe==Pipe('S'), pipe_matrix)
end

function valid_pipe_index(pipe_matrix, index)
    (1 <= index[1] <= size(pipe_matrix, 1)) && (1 <= index[2] <= size(pipe_matrix, 2))
end

function traverse_pipes(pipe_matrix, step_matrix, starting_index)
    curr_index = starting_index
    curr_pipe = pipe_matrix[curr_index]
    step_counter = 1
    step_matrix[curr_index] = min(step_matrix[curr_index], step_counter)
    prev_index = nothing
    while true
        dirs = connection_dirs(curr_pipe)
        for dir in dirs
            next_index = curr_index + dir
            # pprintln("next_index: $next_index")
            if next_index == prev_index
                continue
            end
            next_pipe = pipe_matrix[next_index]
            if connection_possible(curr_pipe, dir, next_pipe)
                step_counter += 1
                prev_index = curr_index
                curr_index = next_index
                curr_pipe = next_pipe
                step_matrix[curr_index] = min(step_counter, step_matrix[curr_index])
                break
            end
        end
        if curr_pipe == Pipe('S')
            break
        end
    end
end

function plot_step_matrix(step_matrix, s_index, max_val)
    p = heatmap(step_matrix, colormap=:viridis, colorrange=(0,max_val-1), lowclip=:green, highclip=:blue)
    scatter!([s_index[1]], [s_index[2]]; color=:red)
    return p
end

function main()
    # Parse input
    pipe_matrix = read_pipe_matrix("day10_input.txt")

    # Also create a matrix to keep track of steps taken in maze
    step_matrix = ones(Int, size(pipe_matrix)...) * typemax(Int)

    # Also keep track of trajectory
    # traj::Vector{CartesianIndex} = []

    # Find S
    s_index = find_S_index(pipe_matrix)
    s_pipe = pipe_matrix[s_index]
    step_matrix[s_index] = 0
    # push!(traj, s_index)

    # Step through both pipes until we come back to S
    starting_indices = [s_index + dir for dir in connection_dirs(s_pipe) if valid_pipe_index(pipe_matrix, s_index+dir) && connection_possible(s_pipe, dir, pipe_matrix[s_index+dir])]

    # pprintln(starting_indices)
    for starting_index in starting_indices
        traverse_pipes(pipe_matrix, step_matrix, starting_index)
    end
    # println(traj)
    # typemax(Int) is not a real distance, set it to -1
    step_matrix = map(x -> x == typemax(Int) ? -1 : x, step_matrix)
    # foreach(println, eachrow(step_matrix))

    # Find largest number of steps
    max_steps = maximum(step_matrix)
    println("Max steps: $max_steps")
    display(plot_step_matrix(step_matrix, s_index, max_steps))
    read(stdin, Char)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
