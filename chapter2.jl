include("chapter1.jl")

const preorder = 0
const postorder = 1

function order_v_first(v, e)
    x, y = e
    return (x == v) ? (x, y) : (y, x)
end

function dfs_recursive!(g::UndirectedGraph; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    dprint("starting recursive depth first search")
    labels = repmat([0], g.n)
    visited_edges = repmat([false], g.m)
    label = 1

    function label_vertex(v, label)
        dprint("v$v is not labeled, labeling as $(label)")
        labels[v] = label
        return label + 1
    end

    function dfs_body(v)
        dprint("Originating depth search from v$v...")
        for e in g.edges_at[v]
            dprint("Checking e$e starting from v$v")
            if visited_edges[e]
                dprint("e$e was already visited, skipping.")
                continue
            else
                visited_edges[e] = true
                v, w = g.edges[e]
                dprint("e$e = ($v, $w) is not visited. checking it's head") 
                if labels[w] == 0
                    label = label_vertex(w, label)
                    dfs_body(w)
                else
                    dprint("v$w was already labeled. skipping.")
                end
            end
        end
        dprint("no more unvisited edges starting from $v")
    end

    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if labels[v] != 0
            dprint("v$v is already labeled, skipping")
            continue
        else
            label = label_vertex(v, label)
            dfs_body(v)
        end
    end
    return labels
end

function dfs_recursive!(g::DirectedGraph; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    dprint("starting recursive depth first search")
    labels = repmat([0], g.n)
    visited_edges = repmat([false], g.m)
    label = 1

    function label_vertex(v, label)
        dprint("v$v is not labeled, labeling as $(label)")
        labels[v] = label
        return label + 1
    end

    function dfs_body(v)
        dprint("Originating depth search from v$v...")
        for e in g.edges_from[v]
            dprint("Checking e$e starting from v$v")
            if visited_edges[e]
                dprint("e$e was already visited, skipping.")
                continue
            else
                visited_edges[e] = true
                v, w = g.edges[e]
                dprint("e$e = ($v, $w) is not visited. checking it's head") 
                if labels[w] == 0
                    label = label_vertex(w, label)
                    dfs_body(w)
                else
                    dprint("v$w was already labeled. skipping.")
                end
            end
        end
        dprint("no more unvisited edges starting from $v")
    end

    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if labels[v] != 0
            dprint("v$v is already labeled, skipping")
            continue
        else
            label = label_vertex(v, label)
            dfs_body(v)
        end
    end
    return labels
end

function dfs_stack!(g::UndirectedGraph;
                    order=preorder, count_components=false, debug=false)
    dprint(args...) = debug ? println(args...) : Void
    labels = repmat([0], g.n)
    visited_vertices = repmat([false], g.n)
    visited_edges = repmat([false], g.m)
    label = 1
    stack = Int[]
    components = 0
    str_stack() = "[" * join(["v$v" for v in reverse(stack)], ", ") * "]"

    function spush(v)
        if order == preorder
            label = label_vertex(v, label)
        end
        dprint("pushing v$v into stack...")
        push!(stack, v)
        dprint("current stack: $(str_stack())")
    end

    function spop()
        v = pop!(stack)
        dprint("popping v$v from stack...")
        if order == postorder
            label = label_vertex(v, label)
        end
        dprint("current stack: $(str_stack())")
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        return label + 1
    end

    function dfs_from_tos()
        components += 1
        dprint("connected components so far = $components")
        while !isempty(stack)
            v = stack[end]
            dprint("Stack not empty, top is v$v")
            dprint("Originating depth search from v$v...")
            pushed_new_vert = false
            for e in g.edges_at[v]
                dprint("Checking e$e starting from v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    x, y = g.edges[e]
                    dprint("e$e = (v$x, v$y) has not been visited. " *
                           "checking it's other end.") 
                    v, w = order_v_first(v, (x, y))
                    if !visited_vertices[w]
                        visited_vertices[w] = true
                        dprint("v$w has not been visited before.")
                        spush(w)
                        pushed_new_vert = true
                        break
                    else
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            if pushed_new_vert
                # found and pushed new vert, start over the search from
                # that vert.
                continue
            else
                # no new edges or no new verts. meaning this vert is fully
                # invesitgated. time to backtrack, remove it from stack.
                dprint("no more unvisited edges starting from v$v")
                x = spop()
            end
        end
    end

    dprint("starting stack based depth first search")
    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if visited_vertices[v]
            dprint("v$v is already visited, skipping")
            continue
        else
            spush(v)
            visited_vertices[v] = true
            dprint("Found new vertex v$v.")
            dfs_from_tos()
        end
    end
    g.labels = copy(labels)
    if count_components
        return components, labels
    else
        return labels
    end
end

function dfs_stack!(g::DirectedGraph; order=preorder, debug=false)
    dprint(args...) = debug ? println(args...) : Void
    labels = repmat([0], g.n)
    visited_vertices = repmat([false], g.n)
    visited_edges = repmat([false], g.m)
    label = 1
    stack = Int[]
    str_stack() = "[" * join(["v$v" for v in reverse(stack)], ", ") * "]"

    function spush(v)
        if order == preorder
            label = label_vertex(v, label)
        end
        dprint("pushing v$v into stack...")
        push!(stack, v)
        dprint("current stack: $(str_stack())")
    end

    function spop()
        v = pop!(stack)
        dprint("popping v$v from stack...")
        if order == postorder
            label = label_vertex(v, label)
        end
        dprint("current stack: $(str_stack())")
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        return label + 1
    end

    function dfs_from_tos()
        while !isempty(stack)
            v = stack[end]
            dprint("Stack not empty, top is v$v")
            dprint("Originating depth search from v$v...")
            pushed_new_vert = false
            for e in g.edges_from[v]
                dprint("Checking e$e starting from v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    v, w = g.edges[e]
                    dprint("e$e = (v$v, v$w) is not visited. " *
                           "checking it's head") 
                    if !visited_vertices[w]
                        visited_vertices[w] = true
                        dprint("v$w has not been visited before.")
                        spush(w)
                        pushed_new_vert = true
                        break
                    else
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            if pushed_new_vert
                # found and pushed new vert, start over the search from
                # that vert.
                continue
            else
                # no new edges or no new verts. meaning this vert is fully
                # invesitgated. time to backtrack, remove it from stack.
                dprint("no more unvisited edges starting from v$v")
                x = spop()
            end
        end
    end

    dprint("starting stack based depth first search")
    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if visited_vertices[v]
            dprint("v$v is already visited, skipping")
            continue
        else
            spush(v)
            visited_vertices[v] = true
            dprint("Found new vertex v$v.")
            dfs_from_tos()
        end
    end
    g.labels = copy(labels)
    return labels
end

# depth first search for undirected graphs.
# can record depth from the tree node.
function bfs!(g::UndirectedGraph; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    visited_edges = repmat([false], g.m)
    label = 1 # current label
    labels = repmat([0], g.n)
    queue = Int[] # search queue
    depth = 0 # current depth
    depths = repmat([0], g.n) # depth for each vertex
    str_queue() = "[" * join(["v$v" for v in reverse(queue)], ", ") * "]"
    
    function enqueue(v)
        # for bfs, there is no distinction for preorder and postorder,
        # so we can always label a vert when we queue it.
        label = label_vertex(v, label)
        dprint("marking v$v as depth $(depth).")
        depths[v] = depth
        dprint("queuing v$v...")
        unshift!(queue, v)
        dprint("current queue: $(str_queue())")
    end

    function dequeue()
        v = pop!(queue)
        dprint("dequeuing v$v...")
        dprint("current queue: $(str_queue())")
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        depths[v] = depth
        return label + 1
    end

    function bfs_from_toq()
        while !isempty(queue)
            v = queue[end] # peek q first to set depth and messages.
            depth = depths[v]
            dprint("current depth = $depth")
            dprint("Queue not empty, top is v$v")
            v = dequeue()
            dprint("Originating breadth first search from v$v...")
            first_new_vert_in_this_loop = true
            for e in g.edges_at[v]
                dprint("Checking e$e connected on v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    x, y = g.edges[e]
                    dprint("e$e = (v$x, v$y) is not visited. " *
                           "checking it's other end")
                    u, w = order_v_first(v, (x, y))
                    if labels[w] == 0
                        dprint("v$w was has not been labeled before.")
                        if first_new_vert_in_this_loop
                            depth += 1
                            first_new_vert_in_this_loop = false
                        end
                        enqueue(w)
                    else
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            dprint("no more unvisited edges starting from $v")
        end
    end

    dprint("starting queue based depth first search")
    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if labels[v] != 0
            dprint("v$v is already labeled, skipping")
            continue
        else
            depth = 1
            enqueue(v)
            bfs_from_toq()
        end
    end
    dprint("depths = " * str(depths))
    g.labels = copy(labels)
    return labels
end

# shortest path search for undirected graphs.
function shortest_path(g::UndirectedGraph, s::Int, t::Int; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    visited_edges = repmat([false], g.m)
    label = 1 # current label
    labels = repmat([0], g.n)
    queue = Int[] # search queue
    parents = repmat([0], g.n)
    depth = 0 # current depth
    depths = repmat([0], g.n) # depth for each vertex
    str_queue() = "[" * join(["v$v" for v in reverse(queue)], ", ") * "]"
    assert(s <= g.n || t <= g.n)
    if s == t
        dprint("start and goal is the same.")
        return [s, s]
    end
    
    function enqueue(v)
        # for bfs, there is no distinction for preorder and postorder,
        # so we can always label a vert when we queue it.
        label = label_vertex(v, label)
        dprint("marking v$v as depth $(depth).")
        depths[v] = depth
        dprint("queuing v$v...")
        unshift!(queue, v)
        dprint("current queue: $(str_queue())")
    end

    function dequeue()
        v = pop!(queue)
        dprint("dequeuing v$v...")
        dprint("current queue: $(str_queue())")
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        depths[v] = depth
        return label + 1
    end

    function path_to(w)
        path = Int[]
        while parents[w] > 0
            push!(path, w)
            w = parents[w]
        end
        push!(path, w)
        return reverse(path)
    end
    
    function bfs_for_path()
        while !isempty(queue)
            v = queue[end] # peek q first to set depth and messages.
            depth = depths[v]
            # discard backtracked branch
            dprint("current depth = $depth")
            dprint("Queue not empty, top is v$v")
            v = dequeue()
            dprint("Originating breadth first search from v$v...")
            first_new_vert_in_this_loop = true
            for e in g.edges_at[v]
                dprint("Checking e$e connected on v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    x, y = g.edges[e]
                    dprint("e$e = (v$x, v$y) is not visited. " *
                           "checking it's other end")
                    u, w = order_v_first(v, (x, y))
                    if labels[w] == 0
                        dprint("v$w was has not been labeled before.")
                        if first_new_vert_in_this_loop
                            depth += 1
                            first_new_vert_in_this_loop = false
                        end
                        parents[w] = v
                        enqueue(w)
                    if w == t
                        dprint("Found path from $s to $t: $(str(path_to(w)))")
                        return path_to(w)
                    end
                    else
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            dprint("no more unvisited edges starting from $v")
        end
        dprint("No path from $s to $t found.")
        return Int[]
    end
    dprint("starting shortest path search from $s to $t")
    v = s
    dprint("Setting  v$v as start")
    depth = 1
    enqueue(v)
    parents[v] = 0 # bfs root has no parent.
    return bfs_for_path()
end

# shortest path search for directed graphs.
function shortest_path(g::DirectedGraph, s::Int, t::Int; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    visited_edges = repmat([false], g.m)
    label = 1 # current label
    labels = repmat([0], g.n)
    queue = Int[] # search queue
    parents = repmat([0], g.n)
    depth = 0 # current depth
    depths = repmat([0], g.n) # depth for each vertex
    str_queue() = "[" * join(["v$v" for v in reverse(queue)], ", ") * "]"
    assert(s <= g.n || t <= g.n)
    if s == t
        dprint("start and goal is the same.")
        return [s, s]
    end
    
    function enqueue(v)
        # for bfs, there is no distinction for preorder and postorder,
        # so we can always label a vert when we queue it.
        label = label_vertex(v, label)
        dprint("marking v$v as depth $(depth).")
        depths[v] = depth
        dprint("queuing v$v...")
        unshift!(queue, v)
        dprint("current queue: $(str_queue())")
    end

    function dequeue()
        v = pop!(queue)
        dprint("dequeuing v$v...")
        dprint("current queue: $(str_queue())")
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        depths[v] = depth
        return label + 1
    end

    function path_to(w)
        path = Int[]
        while parents[w] > 0
            push!(path, w)
            w = parents[w]
        end
        push!(path, w)
        return reverse(path)
    end
    
    function bfs_for_path()
        while !isempty(queue)
            v = queue[end] # peek q first to set depth and messages.
            depth = depths[v]
            # discard backtracked branch
            dprint("current depth = $depth")
            dprint("Queue not empty, top is v$v")
            v = dequeue()
            dprint("Originating breadth first search from v$v...")
            first_new_vert_in_this_loop = true
            for e in g.edges_from[v]
                dprint("Checking e$e connected on v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    u, w = g.edges[e]
                    dprint("e$e = (v$u, v$w) is not visited. " *
                           "checking it's head")
                    if labels[w] == 0
                        dprint("v$w was has not been labeled before.")
                        if first_new_vert_in_this_loop
                            depth += 1
                            first_new_vert_in_this_loop = false
                        end
                        parents[w] = v
                        enqueue(w)
                    if w == t
                        dprint("Found path from $s to $t: ")
                        dprint(str(path_to(w)))
                        return path_to(w)
                    end
                    else
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            dprint("no more unvisited edges starting from $v")
        end
        dprint("No path from $s to $t found.")
        return Int[]
    end
    dprint("starting shortest path search from $s to $t")
    v = s
    dprint("Setting  v$v as start")
    depth = 1
    enqueue(v)
    parents[v] = 0 # bfs root has no parent.
    return bfs_for_path()
end

function bfs!(g::DirectedGraph; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    visited_edges = repmat([false], g.m)
    label = 1 # current label
    labels = repmat([0], g.n)
    queue = Int[] # search queue
    depth = 0 # current depth
    depths = repmat([0], g.n) # depth for each vertex
    str_queue() = "[" * join(["v$v" for v in reverse(queue)], ", ") * "]"
    
    function enqueue(v)
        # for bfs, there is no distinction for preorder and postorder,
        # so we can always label a vert when we queue it.
        label = label_vertex(v, label)
        dprint("marking v$v as depth $(depth).")
        depths[v] = depth
        dprint("queuing v$v...")
        unshift!(queue, v)
        dprint("current queue: $(str_queue())")
    end

    function dequeue()
        v = pop!(queue)
        dprint("dequeuing v$v...")
        dprint("current queue: $(str_queue())")
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        depths[v] = depth
        return label + 1
    end

    function bfs_from_toq()
        while !isempty(queue)
            v = queue[end] # peek q first to set depth and messages.
            depth = depths[v]
            dprint("current depth = $depth")
            dprint("Queue not empty, top is v$v")
            v = dequeue()
            dprint("Originating breadth first search from v$v...")
            first_new_vert_in_this_loop = true
            for e in g.edges_from[v]
                dprint("Checking e$e starting from v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    u, w = g.edges[e]
                    dprint("e$e = (v$u, v$w) is not visited. " *
                           "checking it's head")
                    if labels[w] == 0
                        dprint("v$w was has not been labeled before.")
                        if first_new_vert_in_this_loop
                            depth += 1
                            first_new_vert_in_this_loop = false
                        end
                        enqueue(w)
                    else
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            dprint("no more unvisited edges starting from $v")
        end
    end

    dprint("starting queue based depth first search")
    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if labels[v] != 0
            dprint("v$v is already labeled, skipping")
            continue
        else
            depth = 1
            enqueue(v)
            bfs_from_toq()
        end
    end
    dprint("depths = " * str(depths))
    g.labels = copy(labels)
    return labels
end

function detect_loops(g::UndirectedGraph; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    labels = repmat([0], g.n)
    visited_vertices = repmat([false], g.n)
    visited_edges = repmat([false], g.m)
    label = 1
    stack = Int[]
    in_stack = repmat([false], g.n)
    loops = Array{Int, 1}[]
    str_stack() = "[" * join(["v$v" for v in reverse(stack)], ", ") * "]"
    str_loop(l) = "{" * join(["v$v" for v in l], " -> ") * "}"

    function spush(v)
        label = label_vertex(v, label)
        dprint("pushing v$v into stack...")
        push!(stack, v)
        in_stack[v] = true
        dprint("current stack: $(str_stack())")
    end

    function spop()
        v = pop!(stack)
        dprint("popping v$v from stack...")
        dprint("current stack: $(str_stack())")
        in_stack[v] = false
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        return label + 1
    end

    
    function dfs_from_tos()
        while !isempty(stack)
            v = stack[end]
            dprint("Stack not empty, top is v$v")
            dprint("Originating depth search from v$v...")
            pushed_new_vert = false
            for e in g.edges_at[v]
                dprint("Checking e$e connected on v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    x, y = g.edges[e]
                    dprint("e$e = (v$x, v$y) is not visited. " *
                           "checking it's other end.") 
                    v, w = order_v_first(v, (x, y))
                    if !visited_vertices[w]
                        visited_vertices[w] = true
                        dprint("v$w has not been visited before.")
                        spush(w)
                        pushed_new_vert = true
                        break
                    else
                        if in_stack[w]
                            i = findfirst(stack, w)
                            loop = stack[i:end]
                            unshift!(loop, v)
                            dprint("loop detected (not exhaustive): " *
                                   str_loop(loop))
                            push!(loops, loop)
                        end
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            if pushed_new_vert
                # found and pushed new vert, start over the search from
                # that vert.
                continue
            else
                # no new edges or no new verts. meaning this vert is fully
                # invesitgated. time to backtrack, remove it from stack.
                dprint("no more unvisited edges starting from v$v")
                x = spop()
            end
        end
    end

    dprint("starting stack based depth first search")
    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if visited_vertices[v]
            dprint("v$v is already visited, skipping")
            continue
        else
            spush(v)
            visited_vertices[v] = true
            dprint("Found new vertex v$v.")
            dfs_from_tos()
        end
    end
    return loops
end

function detect_loops(g::DirectedGraph; debug=false)
    dprint(args...) = debug ? println(args...) : Void
    labels = repmat([0], g.n)
    visited_vertices = repmat([false], g.n)
    visited_edges = repmat([false], g.m)
    label = 1
    stack = Int[]
    in_stack = repmat([false], g.n)
    loops = Array{Int, 1}[]
    str_stack() = "[" * join(["v$v" for v in reverse(stack)], ", ") * "]"
    str_loop(l) = "{" * join(["v$v" for v in l], " -> ") * "}"
    
    function spush(v)
        label = label_vertex(v, label)
        dprint("pushing v$v into stack...")
        push!(stack, v)
        in_stack[v] = true
        dprint("current stack: $(str_stack())")
    end

    function spop()
        v = pop!(stack)
        dprint("popping v$v from stack...")
        dprint("current stack: $(str_stack())")
        in_stack[v] = false
        return v
    end

    function label_vertex(v, label)
        dprint("labeling v$v as $(label)")
        labels[v] = label
        return label + 1
    end

    function dfs_from_tos()
        while !isempty(stack)
            v = stack[end]
            dprint("Stack not empty, top is v$v")
            dprint("Originating depth search from v$v...")
            pushed_new_vert = false
            for e in g.edges_from[v]
                dprint("Checking e$e starting from v$v")
                if visited_edges[e]
                    dprint("e$e was already visited, skipping.")
                    continue
                else
                    visited_edges[e] = true
                    v, w = g.edges[e]
                    dprint("e$e = (v$v, v$w) is not visited. " *
                           "checking it's head") 
                    if !visited_vertices[w]
                        visited_vertices[w] = true
                        dprint("v$w has not been visited before.")
                        spush(w)
                        pushed_new_vert = true
                        break
                    else
                        if in_stack[w]
                            i = findfirst(stack, w)
                            loop = stack[i:end]
                            unshift!(loop, v)
                            dprint("loop detected (not exhaustive): " *
                                   str_loop(loop))
                            push!(loops, loop)
                        end
                        dprint("v$w was already labeled. skipping.")
                    end
                end
            end
            if pushed_new_vert
                # found and pushed new vert, start over the search from
                # that vert.
                continue
            else
                # no new edges or no new verts. meaning this vert is fully
                # invesitgated. time to backtrack, remove it from stack.
                dprint("no more unvisited edges starting from v$v")
                x = spop()
            end
        end
    end

    dprint("starting stack based depth first search")
    for v in 1:g.n
        dprint("Outer loop: checking v$v")
        if visited_vertices[v]
            dprint("v$v is already visited, skipping")
            continue
        else
            spush(v)
            visited_vertices[v] = true
            dprint("Found new vertex v$v.")
            dfs_from_tos()
        end
    end
    return loops
end


function test2()

    # テキスト p. 26 図2.1の有向グラフ
    e1 = [(1, 2), (1, 5), (2, 6), (6, 5), (4, 1), (5, 4), (3, 6),
          (2, 3), (3, 4)]
    # エッジリストからオブジェクト生成
    g1 = DirectedGraph(e1)
    # 再帰版深さ優先探索によるラベル付け
    assert(dfs_recursive!(g1) == [1, 2, 6, 5, 4, 3])
    # スタック版深さ優先探索によるラベル付け
    # オプションを指定しなければラベル付けの順番は先行順
    assert(dfs_stack!(g1) == [1, 2, 6, 5, 4, 3])
    # キュー版幅優先探索によるラベル付け
    assert(bfs!(g1) == [1, 2, 5, 6, 3, 4])
    # 閉路検出
    # detect_loops関数は見つかった閉路のリストを返すので、それが空かどうかを
    # 見れば閉路があるかどうかがわかる。
    # アルゴリズムの性質上、すべての閉路が検出されるわけではないが、グラフが
    # 閉路を持つかどうかは正しく判定できる。
    assert(!isempty(detect_loops(g1)))

    # テキスト p. 29 図2.2の有向グラフ    
    e2 = [(1, 2), (2, 3), (3, 4), (4, 2), (1, 8), (8, 7), (8, 2),
          (7, 2), (7, 4), (5, 4), (7, 5), (5, 6), (6, 7), (8, 9),
          (9, 10), (9, 1), (1, 10), (10, 8), (1, 3)]
    g2 = DirectedGraph(e2)
    assert(dfs_recursive!(g2) == [1, 2, 3, 4, 7, 8, 6, 5, 9, 10])
    assert(dfs_stack!(g2) == [1, 2, 3, 4, 7, 8, 6, 5, 9, 10])
    # スタック版深さ優先探索、後行順によるラベル付け
    assert(dfs_stack!(g2, order=postorder) == [10, 3, 2, 1, 5, 4, 6, 9, 8, 7])
    assert(bfs!(g2) == [1, 2, 5, 8, 9, 10, 6, 3, 7, 4])
    # ループあり
    assert(!isempty(detect_loops(g2)))
    # 最短経路探索
    # スタートとゴールが同一頂点vpであれば単にリスト[p, p]が返る
    assert(shortest_path(g2, 4, 4) == [4, 4])
    # v9からv5への最短経路
    assert(shortest_path(g2, 9, 5) == [9, 10, 8, 7, 5])
    # 有向グラフなので逆向きにはたどれない。経路がない場合空リストが返る
    assert(shortest_path(g2, 5, 9) == [])

    # テキスト p. 38 図2.7の無向グラフ
    e3 = [(1, 2), (2, 3), (1, 4), (3, 5), (2, 5), (3, 4), (4, 5)]
    u3 = UndirectedGraph(e3)
    # 深さ優先探索 (p. 39 図2.8参照)
    assert(dfs_recursive!(u3) == [1, 2, 3, 5, 4])
    assert(dfs_stack!(u3) == [1, 2, 3, 5, 4])
    # 幅優先探索 (p. 39 図2.8参照)
    assert(bfs!(u3) == [1, 2, 4, 3, 5])
    assert(!isempty(detect_loops(u3)))
    
    # テキスト p. 43 図2.9の無向グラフ
    e4 = [(1, 2), (1, 3), (1, 4), (3, 5), (5, 6), (3, 6), (5, 7), (2, 3),
          (2, 4), (2, 8), (2, 9), (8, 9), (4, 10), (10, 11), (4, 11), (4, 12)]
    u4 = UndirectedGraph(e4)
    # 深さ優先探索、再帰
    assert(dfs_recursive!(u4) == [1, 2, 3, 7, 4, 5, 6, 11, 12, 8, 9, 10])
    # 深さ優先探索、スタック
    assert(dfs_stack!(u4) == [1, 2, 3, 7, 4, 5, 6, 11, 12, 8, 9, 10])
    # 深さ優先探索、スタック、後行順
    assert(dfs_stack!(u4, order=postorder) ==
           [12, 11, 4, 8, 3, 1, 2, 10, 9, 6, 5, 7])
    # 幅優先探索
    assert(bfs!(u4) == [1, 2, 3, 4, 7, 8, 12, 5, 6, 9, 10, 11])
    # 閉路検出
    assert(!isempty(detect_loops(u4)))
    # 連結成分のカウント
    assert(dfs_stack!(u4, count_components=true)[1] == 1)
    # 最短経路検出
    assert(shortest_path(u4, 5, 9) == [5, 3, 2, 9])
    # 無向グラフなので逆順にもたどれる
    assert(shortest_path(u4, 9, 5) == [9, 2, 3, 5])
    assert(shortest_path(u4, 2, 2) == [2, 2])
    
    p = shortest_path(u4, 10, 6)
    # 最短の経路が二つある場合、どちらが返るかは初期データでのエッジの
    # 番号付けその他に依存する
    assert(p == [10, 4, 1, 3, 6] || p == [10, 4, 2, 3, 6])

    # シンプルな三角形、ただし一周できない有向グラフ
    e5 = [(1, 2), (2, 3), (1, 3)]
    g5 = DirectedGraph(e5)
    # 有向グラフの意味での閉路は存在しない
    assert(detect_loops(g5) == [])
    # 有向グラフの向き付けを無視して無向グラフに変換
    u5 = UndirectedGraph(e5)
    # 無向グラフとしては閉路を持つ
    assert(!isempty(detect_loops(u5)))

    # 同じく三角形だがこちらは一周できる
    e6 = [(1, 2), (2, 3), (3, 1)]
    g6 = DirectedGraph(e6)
    # 有向、無向どちらでも閉路を持つ
    assert(detect_loops(g6) != [])
    u6 = UndirectedGraph(e6)
    assert(!isempty(detect_loops(u6)))

    # 前出の e3にe5、e6を頂点番号が重ならないように変更して追加したグラフ。
    # つまり3つの連結成分を持つ
    e7 = [(1, 2), (2, 3), (1, 4), (3, 5), (2, 5), (3, 4), (4, 5),
      (6, 7), (7, 8), (8, 6), (9, 10), (10, 11), (12, 11)]
    u7 = UndirectedGraph(e7)
    # count_componentsオプションをtrueにしてdfs_stack!を呼ぶと
    # (連結成分数、頂点ラベルのリスト）のタプルを返すので
    # 第一成分を見れば連結成分数がわかる。
    assert(dfs_stack!(u7, count_components=true)[1] == 3)

    # 同じく p. 47 図2.12の無向グラフによる連結成分数カウント
    e8 = [(1, 2), (1, 3), (3, 4), (2, 4), (2, 5), (2, 6), (5, 6),
          (7, 8), (7, 9), (7, 10), (7, 11), (8, 9), (10, 11),
          (12, 14), (12, 15), (13, 14), (14, 15), (15, 16)]
    u8 = UndirectedGraph(e8)
    assert(dfs_stack!(u8, count_components=true)[1] == 3)
    
end

# 幅優先探索、深さ優先探索がO(n+m)で実行されることのテスト
# 注意: 実行時間は実行中にガベージコレクションが起きたかどうかに大幅に依存する
# たとえばガベージコレクションが90%を占めると表示された場合、実際の実行時間より
# 10倍の時間が表示されていることになる。
# 今のところ、高速化についての検討は一切していない。
function test2_1()
    # n, m を同時に 10^1 から 10^6まで変化させて実行時間を計測
    imax = 6
    graphs1 = [DirectedGraph(10^i, 10^i) for i in 1:imax]
    println("breadth first search")
    for i in 1:imax
        print("n = $(10^i)")
        @time bfs!(graphs1[i])
    end
    println("depth first search (recursive)")
    for i in 1:imax
        print("n = $(10^i)")
        @time dfs_recursive!(graphs1[i])
    end
    println("depth first search (stack)")
    for i in 1:imax
        print("n = $(10^i)")
        @time dfs_stack!(graphs1[i])
    end
end

test2()
#test2_1()

# e2 = [(1, 2), (2, 3), (3, 4), (4, 2), (1, 8), (8, 7), (8, 2),
#       (7, 2), (7, 4), (5, 4), (7, 5), (5, 6), (6, 7), (8, 9),
#       (9, 10), (9, 1), (1, 10), (10, 8), (1, 3)]
# g2 = DirectedGraph(e2)
# println(detect_loops(g2, debug=true))


e3 = [(1, 2), (2, 3), (1, 4), (3, 5), (2, 5), (3, 4), (4, 5)]
g3 = UndirectedGraph(e3)
#println(detect_loops(g3, debug=true))
println(str(detect_loops(g3)))
# e4 = [(1, 2), (1, 3), (1, 4), (3, 5), (5, 6), (3, 6), (5, 7), (2, 3),
#       (2, 4), (2, 8), (2, 9), (8, 9), (4, 10), (10, 11), (4, 11), (4, 12)]
# u4 = UndirectedGraph(e4)
# println(shortest_path(u4, 3, 3, debug=true))
# println(shortest_path(u4, 5, 9, debug=true))
# bfs!(u4, debug=true)

# u7 = UndirectedGraph(e7, )
# println(dfs_stack!(u7, count_components=true, debug=true))

# e8 = [(1, 2), (2, 3), (1, 4), (3, 5), (2, 5), (3, 4), (4, 5)]
# u8 = UndirectedGraph(e8)
# print(u8)
# bfs!(u8, debug=true)
# print(u8)

