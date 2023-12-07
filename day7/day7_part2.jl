using PrettyPrinting
using Combinatorics

import Base

struct Card
    char::Char
end

const card_dict = Dict([('J', 1), ('2', 2), ('3', 3), ('4', 4), ('5', 5), ('6', 6), ('7', 7),
            ('8', 8), ('9', 9), ('T', 10), ('Q', 11), ('K', 12),
            ('A', 13)])
const card_chars = keys(card_dict)
const all_cards_except_joker = [Card(char) for char in card_chars if char != 'J']

function Base.:<(a::Card, b::Card)
    return card_dict[a.char] < card_dict[b.char]
end

function Base.:(==)(a::Card, b::Card)
    return card_dict[a.char] == card_dict[b.char]
end

function Base.isless(a::Card, b::Card)
    return a < b
end

struct Hand
    cards::Vector{Card}
end

abstract type HandType end

struct FiveOfAKind <: HandType end
struct FourOfAKind <: HandType end
struct FullHouse <: HandType end
struct ThreeOfAKind <: HandType end
struct TwoPair <: HandType end
struct OnePair <: HandType end
struct HighCard <: HandType end

function replace_indices(h::Hand, ind::Vector{Int}, cards::Vector{Card})
    new_hand = Hand(copy(h.cards))
    
    # Replace joker
    new_hand.cards[ind] = cards

    return new_hand
end

function hand_type(h::Hand) 
    # If there is a joker, let the hand type be the strongest possible one
    if Card('J') in h.cards
        n_jokers = count(c -> c == Card('J'), h.cards)
        joker_indices = findall(c -> c == Card('J'), h.cards)
        return hand_type(maximum(replace_indices(h, joker_indices, cards) for cards in with_replacement_combinations(all_cards_except_joker, n_jokers)))
    end

    # Otherwise, proceed as in part 1
    v = (sum(card.char == char for card in h.cards) for char in card_chars)
    if any(v .== 5)
        return FiveOfAKind()
    elseif any(v .== 4)
        return FourOfAKind()
    elseif any(v .== 3) && any(v .== 2)
        return FullHouse()
    elseif any(v .== 3)
        return ThreeOfAKind()
    elseif sum(v .== 2) == 2
        return TwoPair()
    elseif any(v .== 2)
        return OnePair()
    else
        return HighCard()
    end
end

const hand_type_ordering = Dict(
                                HighCard() => 1,
                                OnePair() => 2,
                                TwoPair() => 3,
                                ThreeOfAKind() => 4,
                                FullHouse() => 5,
                                FourOfAKind() => 6,
                                FiveOfAKind() => 7
                               )
function Base.:<(ht1::T, ht2::V) where {T<:HandType, V<:HandType}
    return hand_type_ordering[ht1] < hand_type_ordering[ht2]
end

function Base.:<(h1::Hand, h2::Hand)
    h1_type, h2_type = hand_type(h1), hand_type(h2)
    same_hand_type = h1_type == h2_type
    if same_hand_type
        for (card1, card2) in zip(h1.cards, h2.cards)
            if card1 == card2
                continue
            end
            return card1 < card2
        end
        return false
    else
        return h1_type < h2_type
    end
end

function Base.:(==)(h1::Hand, h2::Hand)
    # Two hands are only equal if neither of them is greater than the other
    !(h1 < h2) && !(h1 > h2)
end

function Base.isless(h1::Hand, h2::Hand)
    return h1 < h2
end

# Parse input
hands::Vector{} = []
bids::Vector{Int} = []
for line in eachline("day7_input.txt")
    hand_str, bid_str = split(line)
    hand = Hand(collect(Card(c) for c in hand_str)) 
    push!(hands, hand)
    bid = parse(Int, bid_str)
    push!(bids, bid)
end

# Sort list of hands
p = sortperm(hands)
total_winnings = sum(i*bid for (i,bid) in enumerate(bids[p]))
println("Total winnings: $total_winnings")
