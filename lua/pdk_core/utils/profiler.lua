local pi = pi

--- Simple lua profiler to test your code.
--- @param f function Your code in a scope of function to test.
--- @param try number How much times function should called ? (Default: 10,000)
--- @param ... any Your parameters to pass your function.
--- @return number Time
function pi.util.Profiler( f, try, ... )

    try = try or 10000
    local s = os.clock()

    for i=1,100000 do

        f(...)

    end

    return os.clock() - s

end