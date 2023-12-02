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

# Parse input
games = [parse_game(line) for line in readlines("day2_input.txt")]

# Filter possible games
contents = Contents(12, 13, 14)
possible_games::Vector{Game} = filter(g -> is_game_possible(g, contents), games)

# Sum of possible game IDs
id_sum = sum(game.id for game in possible_games)
println("ID sum: $id_sum")
