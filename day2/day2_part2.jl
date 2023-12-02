struct Draw
    red::Int
    green::Int
    blue::Int
end

struct Game
    id::Int
    draws::Vector{Draw}
end

struct Contents
    red::Int
    green::Int
    blue::Int
end

# Creates a Draw from a string such as "3 blue, 4 red"
function parse_draw(str)
    red, green, blue = 0, 0, 0
    for (n, color) in eachmatch(r"(\d+) (red|green|blue)", str)
        if color == "red"
            red = parse(Int, n)
        elseif color == "green"
            green = parse(Int, n)
        elseif color == "blue"
            blue = parse(Int, n)
        end
    end
    return Draw(red, green, blue)
end


function parse_game(str)
    game_str, draw_strs = split(str, ":")
    game_id = parse(Int, match(r"\d+", game_str).match)
    draws = [parse_draw(draw_str) for draw_str in split(draw_strs, ";")]
    return Game(game_id, draws)
end

function Base.:<=(draw::Draw, contents::Contents)
    return draw.red <= contents.red && draw.green <= contents.green && draw.blue <= contents.blue
end

function is_game_possible(game::Game, contents::Contents)
    return all(draw<=contents for draw in game.draws)
end

function power(game::Game)
    max_red = maximum(draw.red for draw in game.draws)
    max_green = maximum(draw.green for draw in game.draws)
    max_blue = maximum(draw.blue for draw in game.draws)
    return max_red * max_green * max_blue
end

# Parse input
games = [parse_game(line) for line in readlines("day2_input.txt")]

power_sum = sum(map(power, games))
println("Power sum: $power_sum")
