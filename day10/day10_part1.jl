using PrettyPrint

function convert_input_file(input_filename, output_filename)
    contents = read(input_filename, String)
    contents = replace(contents,
                       '-' => '\u2500',
                       'L' => '\u2570',
                       '7' => '\u256e',
                       'F' => '\u256d',
                       'J' => '\u256f',
                       'S' => '🟩')
    write(output_filename, contents)
end

# A pipe has a certain shape and is possibly connected to 2 other pipes
mutable struct Pipe
    shape
    connected_pipes::Tuple{Union{Pipe, Nothing}, Union{Pipe, Nothing}}
    location::Tuple{Integer, Integer}
end

function read_pipe_matrix(filename)
    lines = readlines(filename)

    # Create pipe matrix
    pipe_matrix = Matrix{Pipe}(undef, length(lines), length(lines[1]))
    for (i,line) in enumerate(lines)
        for (j,char) in enumerate(filter(c -> c != '\n', line))
            pipe_matrix[i,j] = Pipe(char, (nothing, nothing), (i,j))
        end
    end

    return pipe_matrix
end

function connect_pipes!(pipe_matrix)
    for i in axes(pipe_matrix, 1)
        for j in axes(pipe_matrix, 2)
            pipe_shape = pipe_matrix[i,j].shape
            if i == 1
                top_pipe = nothing
            else
                top_pipe = pipe_matrix[i-1,j]
            end
            if i == size(pipe_matrix, 1)
                bottom_pipe = nothing
            else
                bottom_pipe = pipe_matrix[i+1,j]
            end
            if j == 1
                left_pipe = nothing
            else
                left_pipe = pipe_matrix[i,j-1]
            end
            if j == size(pipe_matrix, 2)
                right_pipe = nothing
            else
                right_pipe = pipe_matrix[i,j+1]
            end


            if pipe_shape == '|'
                connected_pipes = (top_pipe, bottom_pipe)
            elseif pipe_shape == '-'
                connected_pipes = (left_pipe, right_pipe)
            elseif pipe_shape == 'L'
                connected_pipes = (top_pipe, right_pipe)
            elseif pipe_shape == 'J'
                connected_pipes = (top_pipe, left_pipe)
            elseif pipe_shape == '7'
                connected_pipes = (left_pipe, bottom_pipe)
            elseif pipe_shape == 'F'
                connected_pipes = (right_pipe, bottom_pipe)
            elseif pipe_shape == '.'
                connected_pipes = (nothing, nothing)
            elseif pipe_shape == 'S'
                # S has to be manually connected to other pipes
                connected_pipes = (nothing, nothing)
            end

            pipe_matrix[i,j].connected_pipes = connected_pipes
        end
    end
end

function set_S_connected_pipes!(pipe_matrix, start_index)
    # Sets which pipes 'S' is connected to
    i, j = Tuple(start_index)

    if i > 1 && pipe_matrix[i-1,j].shape in ['|', '7', 'F']
        top_pipe = pipe_matrix[i-1,j]
    else
        top_pipe = nothing
    end
    if i < size(pipe_matrix, 1) && pipe_matrix[i+1,j].shape in ['|', 'L', 'J']
        bottom_pipe = pipe_matrix[i+1,j]
    else
        bottom_pipe = nothing
    end
    if j > 1 && pipe_matrix[i,j-1].shape in ['-', 'L', 'F']
        left_pipe = pipe_matrix[i,j-1]
    else
        left_pipe = nothing
    end
    if j < size(pipe_matrix, 2) && pipe_matrix[i,j+1].shape in ['-', 'J', '7']
        right_pipe = pipe_matrix[i,j+1]
    else
        right_pipe = nothing
    end
    # v should only contain 2 elements
    v = [pipe for pipe in [top_pipe, bottom_pipe, left_pipe, right_pipe] if pipe !== nothing]
    pipe_matrix[start_index].connected_pipes = (v[1], v[2])
end

function start_travel(pipe_matrix, start_index, direction_index)
    start_pipe = pipe_matrix[start_index]
    step_matrix::Matrix{Union{Integer,Missing}} = fill(missing, size(pipe_matrix)...)
    step_matrix[start_index] = 0
    curr_pipe = start_pipe
    # Take one step manually
    next_pipe = start_pipe.connected_pipes[direction_index]
    step_counter = 1
    step_matrix[next_pipe.location...] = step_counter
    prev_pipe, curr_pipe = curr_pipe, next_pipe
    # Take the rest until we come back to the start
    while true
        next_pipe = [pipe for pipe in curr_pipe.connected_pipes if pipe != prev_pipe][]
        if next_pipe == start_pipe
            break
        end
        step_counter += 1
        step_matrix[next_pipe.location...] = step_counter
        prev_pipe, curr_pipe = curr_pipe, next_pipe
    end
    
    return step_matrix
end

function main()
    # Read file, create matrix of pipes but the pipes are not yet "connected"
    pipe_matrix = read_pipe_matrix("day10_input.txt")

    # Now connect the pipes
    connect_pipes!(pipe_matrix)

    # Find where to start
    start_index = findfirst(p -> p.shape == 'S', pipe_matrix)
    set_S_connected_pipes!(pipe_matrix, start_index)

    # Start traveling along both directions, return a matrix with how many
    # steps it took to reach each pipe
    step_matrix1 = start_travel(pipe_matrix, start_index, 1)
    step_matrix2 = start_travel(pipe_matrix, start_index, 2)

    # Take the minimum of the two matrices above
    step_matrix = min.(step_matrix1, step_matrix2)
    
    # The largest number is the largest distance
    farthest_distance = maximum(skipmissing(step_matrix))

    println("Farthest distance: $farthest_distance")

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
