first_digit_pattern = r"^.*?(\d)"
last_digit_pattern = r".*(\d).*?$"

cal_sum = 0
open("day1_input.txt") do file
    for line in eachline(file)
        m1 = match(first_digit_pattern, line)
        m2 = match(last_digit_pattern, line)
        a, = m1.captures
        b, = m2.captures
        global cal_sum += parse(Int, a * b)
    end
end

println("Calibration sum: $cal_sum")
