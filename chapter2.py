# import networkx as nx
# import matplotlib.pyplot as plt

# minimal sanity check for given data to construct graphs.
# (n, m): (number of vertices, m: number of edges)
# n, m can be -1. in that case they are guess from edges.
# when values >= 0 are given, m must be len(edges).
# there is no possible check for n based only on edges data.
import copy

def check_nm(edges, n, m):
     m1 = len(edges)
     n1 = max(map(max, edges))
     if m < 0:
          m = m1
     elif not m == m1:
         raise ValueError("number of edges does not match with given m")
     if n < 0:
          n = n1
     return n, m

# conversion function between 0 origin values and 1 origin values
# works on list, tuples recursively defined on in integer values.
def add(a, l):
    if type(l) == int:
        return l + a
    elif type(l) == list:
        return [add(a, elem) for elem in l]
    elif type(l) == tuple:
        return tuple(add(a, elem) for elem in l)
    else:
        raise ValueError("unkown data type to apply add()")


# print stack in compatible manner with the textbook.
def str_stack(a):
     return "[" + ", ".join(["v"+str(v) for v in reversed(add(1, a))]) + "]"

# Undirected Graph    
class UndirectedGraph:
     preorder = 0
     postorder = 1
     def __init__(self, g, n=-1, m=-1, labels=[], debug=False):
          self.debug = debug
          self.label = 1
          if type(g) == list:
               self.n, self.m = check_nm(g, n, m)
               self.edges = add(-1, g)
               self.edges_at = [[] for i in range(self.n)]
               for i in range(self.m):
                    u, v = self.edges[i]
                    self.edges_at[u].append(i)
                    self.edges_at[v].append(i)
          # DirectedGraph can be initialized by a DirectedGraph
          # every edge in Directedgraph is converted to an undirected edge.
          # Vertices are kept as-is.
          elif type(g) == DirectedGraph:
               self.n, self.m = g.n, g.m
               self.edges = copy.deepcopy(g.edges)
               for i in range(self.m):
                    u, v = self.edges[i]
                    self.edges_at[u].append(i)
                    self.edges_at[v].append(i)
          else:
               raise ValueError("initialize from unsupported data type.")
          if labels:
               self.labels = labels
          else:
               self.labels = [0]*self.n
          self.visited_vertices = [False] * self.n
          self.visited_edges = [False] * self.m
          self.order = UndirectedGraph.preorder
          
     def __str__(self):
          s = "n, m = %d, %d" % (self.n, self.m)
          s += "\nedges: %s" % str(add(1, self.edges))
          s += "\nedges_at: %s" % str(add(1, self.edges_at))
          if self.labels:
               s += "\nlabels: %s" % str(self.labels)
          return s

     def dprint(self, args, **kwargs):
         # debug print function
         if self.debug:
              print(args, **kwargs)
         else:
              pass

     # in undirectional graphs,
     # edge with number e that has v and w as verts might be stored in the
     # edges list as either of (v, w) or (w, v). reorder it as (v, w)
     def order_v_first(self, v, e):
          x, y = self.edges[e]
          if x == v:
               return x, y
          elif y == v:
               return y, x
          else:
               raise ValueError("edge %d has no end point v%d" % (e + 1, v + 1))
         
     def depth_search_recursive(self):
          self.init_search_variables()
          for v in self.unlabeled_vertices():
               self.label_vertex(v)
               self.dfs_body(v)

     def dfs_body(self, v):
          found_unlabeled_vertex = False
          unvisited_edges = (e for e in self.edges_at[v]
                             if not self.visited_edges[e])
          for e in unvisited_edges:
               self.visited_edges[e] = True
               # x, y = self.edges[e]
               # self.dprint("checking e%d = %s" % (e + 1, (x + 1, y + 1)))
               v, w = self.order_v_first(v, e)
               self.dprint("found non-visited edge e%d with verts"
                           " (v%d, v%d)" % (e + 1, v + 1, w + 1))
               if self.labels[w] == 0:
                    self.label_vertex(w)
                    found_unlabeled_vertex = True
                    self.dfs_body(w)
               else:
                    self.dprint("v%d is already labeled as %d" %
                                (w + 1, self.labels[w]))
          self.dprint("no more unvisited edges starting from v%d" % (v + 1))

     # generator to obtain next unlabeled vertex.
     def unlabeled_vertices(self):
          for v in range(self.n):
               if self.labels[v] == 0:
                    self.dprint("found unlabeled vert v%d" % (v + 1))
                    yield v
          # exiting for loop means no unlabeled verts left.

     # vert numbers in stack are converted to origin 1 and the order
     # is reverted in order to compare with the textbook exmaple.

     def unvisited_vertices(self):
     # needed for postorder labeling in stack depth search,
     # since we dont' label verts right away when we find them, so
     # there are verts not labeld but held in the stack.
     # need to keep track of them in order to avoid puting them into
     # the stack again.
          for v in range(self.v):
               if not self.visited_vertices[v]:
                    self.dprint("found unvisited vert v%d" % (v + 1))
                    yield v

     # preorder: label vert when it's pushed into stack.
     # postorder: label vert when it's popped out from stack.
     def push(self, x):
          if self.order == UndirectedGraph.preorder:
               self.label_vertex(x)
          self.dprint("pushing v%d into stack" % (x + 1))
          self.visited_vertices[x] = True
          self.stack.append(x)
          self.dprint("stack = %s" % str_stack(self.stack))

     def pop(self):
          x = self.stack.pop()
          if self.order == UndirectedGraph.postorder:
               self.label_vertex(x)
          self.dprint("popping v%d from stack" % (x + 1))
          self.dprint("stack = %s" % str_stack(self.stack))
          self.dprint("labels = %s" % self.labels)
          return x

     # when to label the vert does not matter for queue. so we
     # always label it when it gets queued.
     def put(self, x):
          self.label_vertex(x)
          self.dprint("putting v%d into queue" % (x + 1))
          self.visited_vertices[x] = True
          self.stack.insert(0, x)
          self.dprint("queue = %s" % str_stack(self.stack))

     def get(self):
          x = self.stack.pop()
          self.dprint("dequeuing v%d from queue" % (x + 1))
          self.dprint("queue = %s" % str_stack(self.stack))
          self.dprint("labels = %s" % self.labels)
          return x
     
     def label_vertex(self, v):
          self.dprint("v%d is unlabeled. labeling it as %d"
                      % (v + 1, self.label))
          self.labels[v] = self.label
          self.label += 1
               
     def init_search_variables(self):
          self.labels = [0] * self.n
          self.visited_vertices = [False] * self.n
          self.visited_edges = [False] * self.m
          self.label = 1
          self.stack = []

     def depth_search_stack(self):
          self.init_search_variables()
          components = 0
          for v in self.unlabeled_vertices(): # step 2(a)
               components += 1
               self.push(v)
               self.depth_search_from_stack_top() # step 2 (b)
          self.dprint("all vertices are labelled")
          self.dprint("the graph has %d connected components." % components)
          self.components = components
          
     def depth_search_from_stack_top(self):
          while self.stack:
               # step 2 (b)(i) start
               v = self.stack[-1] # peek stack top
               self.dprint("stack not empty, top is v%d" % (v + 1))
               self.dprint("originating search from v%d" % (v + 1))
               # step 2 (b)(i) end
               # step 2 (b)(ii) start
               pushed_new_vert = False
               unvisited_edges = (e for e in self.edges_at[v]
                                  if not self.visited_edges[e])
               for e in unvisited_edges:
                    self.visited_edges[e] = True
                    v, w = self.order_v_first(v, e)
                    self.dprint("found non-visited edge e%d with verts"
                                " (v%d, v%d)" % (e + 1, v + 1, w + 1))
                    if not self.visited_vertices[w]:
                         self.push(w)
                         pushed_new_vert = True
                         break # from for loop
                    else:
                         self.dprint("v%d is already labeled as %d" %
                                     (w + 1, self.labels[w]))
               if pushed_new_vert:
                    continue # back to top of while loop
               else:
                    x = self.pop() # dropping v from stack
               self.dprint("no more unvisited edges starting"
                           " from v%d" % (v + 1))

     def breadth_search(self):
          self.init_search_variables()
          for v in self.unlabeled_vertices(): # step 2(a)
               self.put(v)
               self.breadth_search_from_queue_top() # step 2 (b)
          self.dprint("all vertices are labelled")
               
     def breadth_search_from_queue_top(self):
          while self.stack:
               v = self.stack[-1]
               self.dprint("queue not empty, top is v%d" % (v + 1))
               v = self.get()
               self.dprint("originating search from v%d" % (v + 1))
               unvisited_edges = (e for e in self.edges_at[v]
                                  if not self.visited_edges[e])
               for e in unvisited_edges:
                    self.visited_edges[e] = True
                    v, w = self.order_v_first(v, e)
                    self.dprint("found non-visited edge e%d with verts"
                                " (v%d, v%d)" % (e + 1, v + 1, w + 1))
                    if not self.visited_vertices[w]:
                         self.put(w)
                         put_new_vert = True
                    else:
                         self.dprint("v%d is already labeled as %d" %
                                     (w + 1, self.labels[w]))
               self.dprint("no more unvisited edges starting"
                           " from v%d" % (v + 1))

# Directed Graph    
class DirectedGraph:
     preorder = 0
     postorder = 1
     def __init__(self, g, n=-1, m=-1, labels=[], debug=False):
          self.debug = debug
          self.detect_loop = False
          self.label = 1
          if type(g) == list:
               self.n, self.m = check_nm(g, n, m)
               self.edges = add(-1, g)
               self.edges_from = [[] for i in range(self.n)]
               self.edges_to = [[] for i in range(self.n)]
               for i in range(self.m):
                    u, v = self.edges[i]
                    self.edges_from[u].append(i)
                    self.edges_to[v].append(i)
          # DirectedGraph can be initialized by a UndirectedGraph
          # every edge in UndirectedGraph is converted to a pair of edges in
          # both directions. Vertices are kept as-is.
          elif type(g) == UndirectedGraph:
               self.n, self.m = g.n, 2 * g.m
               self.edges = []
               for e in g.edges:
                    u, v = e
                    self.edges.append((u, v))
                    self.edges.append((v, u))
                    self.edges_from = [[] for i in range(self.n)]
                    self.edges_to = [[] for i in range(self.n)]
                    for i in range(self.m):
                         u, v = self.edges[i]
                         self.edges_from[u].append(i)
                         self.edges_to[v].append(i)
          else:
               raise ValueError("initialize from unsupported data type.")
          if labels:
               self.labels = labels
          else:
               self.labels = [0]*self.n
          self.visited_vertices = [False] * self.n
          self.visited_edges = [False] * self.m
          self.order = DirectedGraph.preorder
          
     def __str__(self):
          s = "n, m = %d, %d" % (self.n, self.m)
          s += "\nedges: %s" % str(add(1, self.edges))
          s += "\nedges_from: %s" % str(add(1, self.edges_from))
          s += "\nedges_to: %s" % str(add(1, self.edges_to))
          if self.labels:
               s += "\nlabels: %s" % str(self.labels)
          return s

     def dprint(self, args, **kwargs):
         # debug print function
         if self.debug:
              print(args, **kwargs)
         else:
              pass

     def depth_search_recursive(self):
          self.init_search_variables()
          for v in self.unlabeled_vertices():
               self.label_vertex(v)
               self.dfs_body(v)

     def dfs_body(self, v):
          found_unlabeled_vertex = False
          unvisited_edges = (e for e in self.edges_from[v]
                             if not self.visited_edges[e])
          for e in unvisited_edges:
               self.visited_edges[e] = True
               v, w = self.edges[e]
               self.dprint("found non-visited edge e%d with verts"
                           " (v%d, v%d)" % (e + 1, v + 1, w + 1))
               if self.labels[w] == 0:
                    self.label_vertex(w)
                    found_unlabeled_vertex = True
                    self.dfs_body(w)
               else:
                    self.dprint("v%d is already labeled as %d" %
                                (w + 1, self.labels[w]))
          self.dprint("no more unvisited edges starting from v%d" % (v + 1))

     # generator to obtain next unlabeled vertex.
     def unlabeled_vertices(self):
          for v in range(self.n):
               if self.labels[v] == 0:
                    self.dprint("found unlabeled vert v%d" % (v + 1))
                    yield v
          # exiting for loop means no unlabeled verts left.

     # vert numbers in stack are converted to origin 1 and the order
     # is reverted in order to compare with the textbook exmaple.

     def unvisited_vertices(self):
     # needed for postorder labeling in stack depth search,
     # since we dont' label verts right away when we find them, so
     # there are verts not labeld but held in the stack.
     # need to keep track of them in order to avoid puting them into
     # the stack again.
          for v in range(self.v):
               if not self.visited_vertices[v]:
                    self.dprint("found unvisited vert v%d" % (v + 1))
                    yield v
     
     def push(self, x):
          if self.order == DirectedGraph.preorder:
               self.label_vertex(x)
          self.dprint("pushing v%d into stack" % (x + 1))
          self.visited_vertices[x] = True
          self.stack.append(x)
          self.in_stack[x] = True
          self.dprint("stack = %s" % str_stack(self.stack))

     def pop(self):
          x = self.stack.pop()
          if self.order == DirectedGraph.postorder:
               self.label_vertex(x)
          self.dprint("popping v%d from stack" % (x + 1))
          self.dprint("stack = %s" % str_stack(self.stack))
          self.dprint("labels = %s" % self.labels)
          self.in_stack[x] = False
          return x

     def put(self, x):
          self.label_vertex(x)
          self.dprint("putting v%d into queue" % (x + 1))
          self.visited_vertices[x] = True
          self.stack.insert(0, x)
          self.in_stack[x] = True
          self.dprint("queue = %s" % str_stack(self.stack))

     def get(self):
          x = self.stack.pop()
          if self.order == DirectedGraph.postorder:
               self.label_vertex(x)
          self.dprint("dequeuing v%d from queue" % (x + 1))
          self.dprint("queue = %s" % str_stack(self.stack))
          self.dprint("labels = %s" % self.labels)
          self.in_stack[x] = False
          return x
     

     def label_vertex(self, v):
          self.dprint("v%d is unlabeled. labeling it as %d"
                      % (v + 1, self.label))
          self.labels[v] = self.label
          self.label += 1
               
     def init_search_variables(self):
          self.labels = [0] * self.n
          self.visited_vertices = [False] * self.n
          self.visited_edges = [False] * self.m
          self.label = 1
          self.stack = []
          self.in_stack = [False] * self.n
          self.loops = []

     def loop_from(self, w):
          i = self.stack.index(w)
          l = self.stack[i:]
          l.append(l[0])
          return l

     def print_loops(self):
          s = "["
          for loop in self.loops:
               s += "<" + " -> ".join(map(str, add(1, loop))) + ">"
          s += "]"
          print(s)

     def depth_search_stack(self):
          self.init_search_variables()
          for v in self.unlabeled_vertices(): # step 2(a)
               self.push(v)
               self.depth_search_from_stack_top() # step 2 (b)
          self.dprint("all vertices are labelled")

     def depth_search_from_stack_top(self):
          while self.stack:
               # step 2 (b)(i) start
               v = self.stack[-1] # peek stack top
               self.dprint("stack not empty, top is v%d" % (v + 1))
               self.dprint("originating search from v%d" % (v + 1))
               # step 2 (b)(i) end
               # step 2 (b)(ii) start
               pushed_new_vert = False
               unvisited_edges = (e for e in self.edges_from[v]
                                  if not self.visited_edges[e])
               for e in unvisited_edges:
                    self.visited_edges[e] = True
                    v, w = self.edges[e]
                    self.dprint("found non-visited edge e%d with verts"
                                " (v%d, v%d)" % (e + 1, v + 1, w + 1))
                    if not self.visited_vertices[w]:
                         self.push(w)
                         pushed_new_vert = True
                         break # from for loop
                    else:
                         self.dprint("v%d is already labeled as %d" %
                                     (w + 1, self.labels[w]))
                         if self.in_stack[w]:
                              if self.detect_loop:
                                   self.loops.append(self.loop_from(w))
               if pushed_new_vert:
                    continue # back to top of while loop
               else:
                    x = self.pop() # dropping v from stack
               self.dprint("no more unvisited edges starting"
                           " from v%d" % (v + 1))

     def find_path_readable(self, s, t):
          print(add(1, self.find_path(s-1, t-1)))
     def find_path(self, s, t):
          # s, t are 1-based indices.
          assert(0 <= s and s < self.n - 1 and 0 <= t and t < self.n)
          self.init_search_variables()
          self.push(s)
          while self.stack:
               # step 2 (b)(i) start
               v = self.stack[-1] # peek stack top
               self.dprint("stack not empty, top is v%d" % (v + 1))
               self.dprint("originating search from v%d" % (v + 1))
               # step 2 (b)(i) end
               # step 2 (b)(ii) start
               pushed_new_vert = False
               unvisited_edges = (e for e in self.edges_from[v]
                                  if not self.visited_edges[e])
               for e in unvisited_edges:
                    self.visited_edges[e] = True
                    v, w = self.edges[e]
                    self.dprint("found non-visited edge e%d with verts"
                                " (v%d, v%d)" % (e + 1, v + 1, w + 1))
                    if not self.visited_vertices[w]:
                         self.push(w)
                         pushed_new_vert = True
                         if w == t:
                              return copy.copy(self.stack)
                         break # from for loop
                    else:
                         self.dprint("v%d is already labeled as %d" %
                                     (w + 1, self.labels[w]))
                         if self.detect_loop and w in self.stack:
                              print("closed path detected (not exhaustive); %s"
                                    % self.closed_path_str(w))
               if pushed_new_vert:
                    continue # back to top of while loop
               else:
                    x = self.pop() # dropping v from stack
               self.dprint("no more unvisited edges starting"
                           " from v%d" % (v + 1))
               return []
     def find_shortest_path_readable(self, s, t):
          print(add(1, self.find_shortest_path(s-1, t-1)))
     def find_shortest_path(self, s, t):
          assert(0 <= s and s < self.n - 1 and 0 <= t and t < self.n)
          self.init_search_variables()
          self.push(s)
          while self.stack:
               v = self.stack[-1]
               self.dprint("queue not empty, top is v%d" % (v + 1))
               v = self.pop()
               self.dprint("originating search from v%d" % (v + 1))
               unvisited_edges = (e for e in self.edges_from[v]
                                  if not self.visited_edges[e])
               for e in unvisited_edges:
                    self.visited_edges[e] = True
                    v, w = self.edges[e]
                    self.dprint("found non-visited edge e%d with verts"
                                " (v%d, v%d)" % (e + 1, v + 1, w + 1))
                    if not self.visited_vertices[w]:
                         self.put(w)
                         put_new_vert = True
                         if w == t:
                              print("there is a shortest path from %d to %t" %
                                    (s + 1, t + 1))
                    else:
                         self.dprint("v%d is already labeled as %d" %
                                     (w + 1, self.labels[w]))
               self.dprint("no more unvisited edges starting"
                           " from v%d" % (v + 1))


          
     def breadth_search(self):
          self.init_search_variables()
          for v in self.unlabeled_vertices(): # step 2(a)
               self.put(v)
               self.breadth_search_from_queue_top() # step 2 (b)
          self.dprint("all vertices are labelled")
               
     def breadth_search_from_queue_top(self):
          while self.stack:
               v = self.stack[-1]
               self.dprint("queue not empty, top is v%d" % (v + 1))
               v = self.pop()
               self.dprint("originating search from v%d" % (v + 1))
               unvisited_edges = (e for e in self.edges_from[v]
                                  if not self.visited_edges[e])
               for e in unvisited_edges:
                    self.visited_edges[e] = True
                    v, w = self.edges[e]
                    self.dprint("found non-visited edge e%d with verts"
                                " (v%d, v%d)" % (e + 1, v + 1, w + 1))
                    if not self.visited_vertices[w]:
                         self.put(w)
                         put_new_vert = True
                    else:
                         self.dprint("v%d is already labeled as %d" %
                                     (w + 1, self.labels[w]))
               self.dprint("no more unvisited edges starting"
                           " from v%d" % (v + 1))

               
if __name__ == '__main__':
     e1 = [(1, 2), (1, 5), (2, 6), (6, 5), (4, 1),
           (5, 4), (3, 6), (2, 3), (3, 4)]
     g1 = DirectedGraph(e1)
     g1.depth_search_recursive()
     assert(g1.labels == [1, 2, 6, 5, 4, 3])
     # g1.detect_loop = True
     g1.depth_search_stack()
     assert(g1.labels == [1, 2, 6, 5, 4, 3])
     g1.breadth_search()
     assert(g1.labels == [1, 2, 5, 6, 3, 4])

     e2 = [(1, 2), (2, 3), (3, 4), (4, 2), (1, 8), (8, 7), (8, 2), (7, 2),
           (7, 4), (5, 4), (7, 5), (5, 6), (6, 7), (8, 9), (9, 10), (9, 1),
           (1, 10), (10, 8), (1, 3)]
     g2 = DirectedGraph(e2)
     # g2.detect_loop = True     
     g2.depth_search_recursive()
     assert(g2.labels == [1, 2, 3, 4, 7, 8, 6, 5, 9, 10])
     g2.depth_search_stack()
     assert(g2.labels == [1, 2, 3, 4, 7, 8, 6, 5, 9, 10])
     g2.order = DirectedGraph.postorder
     g2.depth_search_stack()
     assert(g2.labels == [10, 3, 2, 1, 5, 4, 6, 9, 8, 7])
     g2.order = DirectedGraph.preorder
     g2.breadth_search()
     assert(g2.labels == [1, 2, 5, 8, 9, 10, 6, 3, 7, 4])

     e3 = [(1, 2), (2, 3), (1, 4), (3, 5), (2, 5), (3, 4), (4, 5)]
     g3 = UndirectedGraph(e3)
     g3.depth_search_recursive()
     assert(g3.labels == [1, 2, 3, 5, 4])
     g3.depth_search_stack()
     assert(g3.labels == [1, 2, 3, 5, 4])
     g3.breadth_search()
     assert(g3.labels == [1, 2, 4, 3, 5])
     
     e4 = [(1, 2), (1, 3), (1, 4), (3, 5), (5, 6), (3, 6), (5, 7), (2, 3),
           (2, 4), (2, 8), (2, 9), (8, 9), (4, 10), (10, 11), (4, 11), (4, 12)]
     g4 = UndirectedGraph(e4)
     g4.depth_search_recursive()
     assert(g4.labels == [1, 2, 3, 7, 4, 5, 6, 11, 12, 8, 9, 10])
     g4.depth_search_stack()
     assert(g4.labels == [1, 2, 3, 7, 4, 5, 6, 11, 12, 8, 9, 10])
     g4.order = UndirectedGraph.postorder
     g4.depth_search_stack()
     assert(g4.labels == [12, 11, 4, 8, 3, 1, 2, 10, 9, 6, 5, 7])
     g4.breadth_search()
     assert(g4.labels == [1, 2, 3, 4, 7, 8, 12, 5, 6, 9, 10, 11])
     e5 = [(1, 2), (2, 4), (4, 3), (3, 1), (2, 5), (5, 6), (6, 2),
           (7, 8), (8, 9), (9, 7), (7, 10), (10, 11), (11, 7), (12, 14),
           (14, 13), (12, 15), (15, 14), (15, 16)]
     g5 = UndirectedGraph(e5)
     g5.depth_search_stack()
     assert(g5.components == 3)
     
