module ContextSensitiveEGraphAnalysis



include("helper_functions.jl")
include("termset.jl")
include("intersect.jl")
include("ruler/ruler.jl")
using .Ruler
include("solve.jl")





export solve, create_termset

end # module ContextSensitiveEGraphAnalysis
