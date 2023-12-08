using PrettyPrinting
using Base.Iterators

mutable struct Node
    value::String
    left_node::Union{Node, Nothing}
    right_node::Union{Node, Nothing}
end

const created_nodes::Dict{String, Node} = Dict()

function add_node(node_line)
    node_value, left_value, right_value = match(r"(\w{3}) = \((\w{3}), (\w{3})\)", node_line)
    if haskey(created_nodes, left_value)
        left_node = created_nodes[left_value]
    else
        left_node = created_nodes[left_value] = Node(left_value, nothing, nothing)
    end
    if haskey(created_nodes, right_value)
        right_node = created_nodes[right_value]
    else
        right_node = created_nodes[right_value] = Node(right_value, nothing, nothing)
    end
    if haskey(created_nodes, node_value)
        node = created_nodes[node_value]
        node.left_node = left_node
        node.right_node = right_node
    else
        created_nodes[node_value] = Node(node_value, left_node, right_node)
    end
end

function main()
    # Parse input
    lines = readlines("day8_input.txt")
    dir_line = lines[1]
    dirs = Vector{Char}(dir_line)
    node_lines = lines[3:end]
    for node_line in node_lines
        add_node(node_line)
    end

    # Follow the left/right directions as a ghost!
    # One node at a time
    nodes = filter(node -> endswith(node.value, "A"), collect(values(created_nodes)))
    steps = []
    for node in nodes
        counter = 0
        for dir in cycle(dirs)
            if dir == 'L'
                node = node.left_node
            elseif dir == 'R'
                node = node.right_node
            end
            counter += 1
            if endswith(node.value, "Z")
                break
            end
        end
        push!(steps, counter)
    end

    println("Number of steps: $(lcm(steps...))")
end

main()
