import networkx as nx
import matplotlib.pyplot as plt

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

def to_origin1(l):
    if type(l) == int:
        return l + 1
    elif type(l) == list:
        return [to_origin1(elem) for elem in l]
    elif type(l) == tuple:
        return tuple(to_origin1(elem) for elem in l)
    else:
        raise ValueError("unkown data type to convert to origin 1")

def to_origin0(l):
    if type(l) == int:
        return l - 1
    elif type(l) == list:
        return [to_origin0(elem) for elem in l]
    elif type(l) == tuple:
        return tuple(to_origin0(elem) for elem in l)
    else:
        raise ValueError("unkown data type to convert to origin 1")

class UndirectedGraph:

    def __init__(self, edges:list, n=-1, m=-1):
        self.n, self.m = check_nm(edges, n, m)
        self.edges = to_origin0(edges)
        self.edges_at = [[] for i in range(self.n)]
        for i in range(self.m):
            u, v = self.edges[i]
            self.edges_at[u].append(i)
            self.edges_at[v].append(i)

    def __str__(self):
        s = "n, m = %d, %d\n" % (self.n, self.m)
        s += "edges: %s\n" % str(to_origin1(self.edges))
        s += "edges_at: %s\n" % str(to_origin1(self.edges_at))
        return s

    
class DirectedGraph:
    
    def __init__(self, g, n=-1, m=-1):
        if type(g) == list:
            self.n, self.m = check_nm(g, n, m)
            self.edges = to_origin0(g)
            self.edges_from = [[] for i in range(self.n)]
            self.edges_to = [[] for i in range(self.n)]
            for i in range(self.m):
                u, v = self.edges[i]
                self.edges_from[u].append(i)
                self.edges_to[v].append(i)
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
        
    def __str__(self):
        s = "n, m = %d, %d\n" % (self.n, self.m)
        s += "edges: %s\n" % str(to_origin1(self.edges))
        s += "edges_from: %s\n" % str(to_origin1(self.edges_from))
        s += "edges_to: %s\n" % str(to_origin1(self.edges_to))
        return s

