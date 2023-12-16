

function dp_closure(s, groups)
    s_len = length(s)
    groups_len = length(groups)

    memo = Dict()

    function broken_dp(pos, done_groups, run, prev_match)
        # @assert (done_groups < groups_len) "assertion failed"
        # Called when we find a (possibly) broken spring

        # If we have already matched enough broken springs
        if done_groups == groups_len
            return 0
        end
        # If we just finished a group, we have to wait 1 char
        if run == 0 && prev_match == true
            broken = 0
        # We finish a group
        elseif run+1 == groups[done_groups+1]
            broken = dp(pos+1, done_groups+1, 0, true)
        # Or don't finish a group
        else
            broken = dp(pos+1, done_groups, run+1, true)
        end
        return broken
    end

    function dp_(pos, done_groups, run, prev_match)
        # Called when result has not been memoized yet

        # Base cases
        if pos == s_len
            # If we arrived at the end and found all groups
            if done_groups == groups_len && run == 0
                return 1
            # If we arrived at the end but the match is incorrect
            else
                return 0
            end
        end
        # If we have too many matches before the end
        # elseif (done_groups == groups_len && run > 0) || done_groups > groups_len
        #     return 0
        # end

        curr_char = s[pos]
        # Switch on curr_char
        if curr_char == '.'
            not_broken = dp(pos+1, done_groups, run, false)
            broken = 0
        elseif curr_char == '?'
            not_broken = dp(pos+1, done_groups, run, false)
            broken = broken_dp(pos, done_groups, run, prev_match)
        elseif curr_char == '#'
            not_broken = 0
            broken = broken_dp(pos, done_groups, run, prev_match)
        end
        return not_broken + broken
    end

    function dp(pos, done_groups, run, prev_match)
        println("dp called with ($pos, $done_groups, $run, $prev_match)")
        # If result has already been memoized, return it
        key = (pos,done_groups,run,prev_match)
        if ! (key in keys(memo))
            memo[key] = dp_(key...)
        end
        return memo[key]
    end

    return dp(1, 0, 0, false)
end

function main()
    # arrangements = dp(1,0,0,false)
    # println(arrangements)
    v = readlines("day12_test_input.txt") .|> split
    strings = getindex.(v, 1) .|> s -> s * '.'
    groups = getindex.(v, 2) .|> s -> split(s, ",") .|> (v -> v .|> (x -> parse(Int,x)))

    # results = [dp_closure(s,g) for (s,g) in zip(strings,groups)]
    # println(results)
    result = dp_closure(strings[end], groups[end])
    println(result)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
