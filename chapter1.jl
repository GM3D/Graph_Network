# check basic consistency among given edges data and m, n
# -1 for m or n means they are not specified and should be
# guessed from edge data.
# m must coincide with the length(edges).
# n can be arbitrary since we do not give vertices list explicitly.
function check_nm(edges::Array{Tuple{Int, Int}, 1}, n::Int, m::Int)
    m1 = length(edges)
    n1 = maximum(Iterators.flatten(edges))
    if m < 0
        m = m1
    elseif m != length(edges)
        error("number of edges does not match with given m")
    end
    if n < 0
        n = n1
    end
    return n, m
end

str(a::Array{Tuple{Int64,Int64},1}) =
    "[" * join([string(t) for t in a], ", ") * "]"
str(a::Array{Array{Int64, 1},1}) =
    "[" * join([string(t) for t in a], ", ") * "]"
str(a::Array{Int,1}) =
    "[" * join([string(t) for t in a], ", ") * "]"

type UndirectedGraph
    n::Int # number of vertices
    m::Int # number of edges
    # list of edges. for each edge, the order of u and v in (u, v) does not
    # matter.
    edges::Array{Tuple{Int, Int},1}
    # edges connected to each vertex. note that at each vertex i, each edge
    # in edges_at[i] is in the form of either (i, j) or (j, i).
    edges_at::Array{Array{Int,1},1}
    labels::Array{Int, 1}
    # ctors.
end

function UndirectedGraph(edges::Array{Tuple{Int, Int}, 1}; n=-1, m=-1)
    # construct complete data structure from given edge data.
    # n: number of vertices
    # m: number of edges
    # edges: an array of directed edges. each edge given by (tail, head)
    # where 1 <= tail, head <= n
    n, m = check_nm(edges, n, m)
    edges_at = [Int[] for i in 1:n]
    for i in 1:m
        tail, head = edges[i]
        push!(edges_at[head], i)
        push!(edges_at[tail], i)
    end
    UndirectedGraph(n, m, edges, edges_at, [])
end

function UndirectedGraph(n::Int, m::Int)
    edges = []
    edges_at = [Int[] for i in 1:n]
    for i in 1:m
        push!(edges, (rand(1:n), rand(1:n)))
    end
    for i in 1:m
        tail, head = edges[i]
        push!(edges_at[tail], i)
        push!(edges_at[head], i)
    end
    UndirectedGraph(n, m, edges, edges_at, [])
end


function Base.show(io::IO, ::MIME"text/plain", g::UndirectedGraph)
    println(io, "n, m = $(g.n), $(g.m)")
    println(io, "edges = $(str(g.edges))")
    println(io, "edges_at = $(str(g.edges_at))")
    println(io, "labels =  $(str(g.labels))")
end

function Base.print(io::IO, g::UndirectedGraph)
    println(io, "n, m = $(g.n), $(g.m)")
    println(io, "edges = $(str(g.edges))")
    println(io, "edges_at = $(str(g.edges_at))")
    println(io, "labels =  $(str(g.labels))")
end

type DirectedGraph
    n::Int # number of vertices
    m::Int # number of edges
    edges::Array{Tuple{Int,Int},1} # edges list
    edges_from::Array{Array{Int,1},1} # edges going out from each vertex
    edges_to::Array{Array{Int,1},1} # edges coming into each vertex
    labels::Array{Int, 1}

    # ctors.
    function DirectedGraph(edges::Array{Tuple{Int, Int}, 1}; n=-1, m=-1)
        n, m = check_nm(edges, n, m)
        # construct connected edges list for each vertex.
        edges_from = [Int[] for i in 1:n]
        edges_to = [Int[] for i in 1:n]
        for i in 1:m
            tail, head = edges[i]
            push!(edges_from[tail], i)
            push!(edges_to[head], i)
        end
        new(n, m, edges, edges_from, edges_to, [])
    end

    # conversion from undirected graph as show in the textbook.
    function DirectedGraph(g::UndirectedGraph)
        #construct edge list directed in both ways.
        edges = Tuple{Int, Int}[]
        for i in 1:g.m
            push!(edges, g.edges[i], reverse(g.edges[i]))
        end
        n, m = g.n, 2*g.m
        # construct connected edges list for each vertex.
        edges_from = [Int[] for i in 1:n]
        edges_to = [Int[] for i in 1:n]
        for i in 1:m
            tail, head = edges[i]
            push!(edges_from[tail], i)
            push!(edges_to[head], i)
        end
        new(n, m, edges, edges_from, edges_to, [])
    end

    function DirectedGraph(n::Int, m::Int)
        if(m > n*(n - 1)/2)
            error("m must be less than or equal n*(n - 1)/2")
        end
        edges = []
        edges_from = [Int[] for i in 1:n]
        edges_to = [Int[] for i in 1:n]
        for i in 1:m
            u = rand(1:n)
            # avoid self loops
            if u == 1
                v = rand(2:n)
            elseif u == n
                v = rand(1:n-1)
            else
                v = rand(append!(collect(1:u-1), collect(u+1:n)))
            end
            # avoid pararell edges
            while (u, v) in edges
                u, v = rand(1:n), rand(1:n)
            end
            push!(edges, (u, v))
        end
        for i in 1:m
            print(edges[i])
            tail, head = edges[i]
            push!(edges_from[tail], i)
            push!(edges_to[head], i)
        end
        new(n, m, edges, edges_from, edges_to, [])
    end
end


function Base.show(io::IO, ::MIME"text/plain", g::DirectedGraph)
    println(io, "n, m = $(g.n), $(g.m)")
    println(io, "edges = $(str(g.edges))")
    println(io, "edges_from = $(str(g.edges_from))")
    println(io, "edges_to = $(str(g.edges_to))")
    println(io, "labels =  $(str(g.labels))")
end

function Base.print(io::IO, g::DirectedGraph)
    println(io, "n, m = $(g.n), $(g.m)")
    println(io, "edges = $(str(g.edges))")
    println(io, "edges_from = $(str(g.edges_from))")
    println(io, "edges_to = $(str(g.edges_to))")
    println(io, "labels =  $(str(g.labels))")
end

function UndirectedGraph(g::DirectedGraph)
    n, m = g.n, g.m
    edges = deepcopy(g.edges)
    edges_at = [Int[] for i in 1:n]
    for i in 1:m
        tail, head = edges[i]
        push!(edges_at[head], i)
        push!(edges_at[tail], i)
    end
    return UndirectedGraph(n, m, edges, edges_at, [])
end


function test1()
    # テキスト p. 26 図2.1の有向グラフ
    e1 = [(1, 2), (1, 5), (6, 2), (6, 5), (4, 1), (5, 4), (3, 6),
          (2, 3), (4, 3)]
    # エッジリストから無向グラフ生成
    u1 = UndirectedGraph(e1)
    # エッジリストから有向グラフ生成
    g1 = DirectedGraph(e1)
    # オブジェクト表示
    println("Undirected graph")
    println(u1)
    println("Directed graph")
    println(g1)
    # 無向グラフを有向グラフに変換
    println("Directed Graph converted from undirected one")
    g11 = DirectedGraph(u1)
    print(g11)
    # 有向グラフを無向グラフに変換
    println("Undirected Graph converted from directed one")
    u11 = UndirectedGraph(g1)
    print(u11)
    
    # テキスト p. 43 図2.9の無向グラフ
    e2 = [(1, 2), (1, 3), (1, 4), (3, 5), (5, 6), (3, 6), (5, 7), (2, 3),
          (2, 4), (2, 8), (2, 9), (8, 9), (4, 10), (4, 11), (4, 12), (10, 11)]
    u2 = UndirectedGraph(e2)
    g2 = DirectedGraph(e2)
    println("Undirected Graph")
    println(u2)
    println("Directed Graph")
    println(g2)
    println("Directed Graph converted from undirected one")
    g22 = DirectedGraph(u2)
    print(g22)
    println("Undirected Graph converted from directed one")
    u22 = UndirectedGraph(g2)
    print(u22)

    # 頂点数と辺数だけ指定してグラフを生成
    # 辺はランダムに頂点を選んで結ぶ
    g3 = DirectedGraph(5, 8)
    print(g3)
    u3 = UndirectedGraph(5, 8)
    print(u3)
end

# test1()
