include("chapter2.jl")
using GR

function plot_graph(g::DirectedGraph)
    markersize = 5
    margin = 1.0 + markersize * 0.02
    GR.clearws()
    GR.setviewport(0.0, 1.0, 0.0, 1.0)
    GR.setwindow(-margin, 1.0 + margin, -margin, 1.0 + margin)
    GR.selntran(0)
    r = 0.005 * markersize
    shorten(x1, y1, x2, y2, r) = (x1, y1, x2 - r*(x2 - x1), y2 - r*(y2 - y1))
    GR.setarrowstyle(2)
    GR.setmarkertype(GR.MARKERTYPE_SOLID_CIRCLE)
    GR.setmarkersize(markersize)
    GR.setcolorrep(100, 0.5, 0.5, 1.0)
    GR.setmarkercolorind(100)
    pos = [(rand(), rand()) for i in 1:g.n]
    X = [p[1] for p in pos]
    Y = [p[2] for p in pos]
    for i in 1:g.m
        head, tail = g.edges[i]
        l = sqrt((X[tail] - X[head])^2 + (Y[tail] - Y[head])^2)
        GR.drawarrow(shorten(X[head], Y[head], X[tail], Y[tail], r/l)...)
    end
    GR.polymarker(X, Y)
    tw = 0.014
    th = 0.012
    oy = 0.008
    for i in 1:g.n
        GR.text(pos[i][1] - tw, pos[i][2] - oy + th , "v$i")
    end
    if ! isempty(g.labels)
        for i in 1:g.n
            GR.text(pos[i][1] - tw, pos[i][2] - oy - th , "$(g.labels[i])")
        end
    end
    GR.updatews()
end

@doc """
input(prompt::String="")::String

    Read a string from STDIN. The trailing newline is stripped.
    The prompt string, if given, is printed to standard output without a
    trailing newline before reading input.
    cited from SalchiPapa's answer on stack overflow, 
    https://stackoverflow.com/questions/17479782/julia-request-user-input-from-script#17480813"""

function input(prompt::String="")::String
    print(prompt)
    return chomp(readline())
end

function testplot()
    e1 = [(1, 2), (1, 5), (2, 6), (6, 5), (4, 1), (5, 4), (3, 6),
          (2, 3), (3, 4)]
    g1 = DirectedGraph(e1)
    dfs_stack!(g1)
    plot_graph(g1)
    while((a = input("type q to quit.")) != "q")
    end
end

testplot()
