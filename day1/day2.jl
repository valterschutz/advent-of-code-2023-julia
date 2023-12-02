first_digit_pattern = r"^.*?(\d|one|two|three|four|five|six|seven|eight|nine)"
last_digit_pattern = r".*(\d|one|two|three|four|five|six|seven|eight|nine).*?$"

word_to_digit = Dict(
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
)

cal_sum = 0
open("day1_input.txt") do file
    for line in eachline(file)
        m1 = match(first_digit_pattern, line)
        m2 = match(last_digit_pattern, line)
        a, = m1.captures
        b, = m2.captures
        a = get(word_to_digit, a, a)
        b = get(word_to_digit, b, b)
        global cal_sum += parse(Int, a * b)
    end
end

println("Calibration sum: $cal_sum")
