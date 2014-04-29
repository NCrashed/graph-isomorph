/**
*   Module describes directed graph implemented via connectivity list.
*
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module graph.connectivity;

import graph.directed;
import std.range;
import std.array;
import std.conv;

/**
*   Graph implemented via connectivity lists.
*/
class ConnListGraph : IDirectedGraph
{
    /**
    *   Loading graph from raw data.
    */
    void load(InputRange!Edge input)
    {
        foreach(edge; input)
        {
            if(edge.source !in lists)
            {
                Weight[Node] empty;
                lists[edge.source] = empty;
            }
            auto list = lists[edge.source];
            
            if(edge.dist in list)
            {
                assert(edge.weight == list[edge.dist]);
            } 
            list[edge.dist] = edge.weight;
            lists[edge.source] = list;
        }
    }
    
    /**
    *   Returns graph nodes set
    */
    InputRange!string nodes()
    {
        bool[Node] nodes;
        
        foreach(source, list; lists)
        {
            nodes[source] = true;
            foreach(dist, weight; list)
            {
                nodes[dist] = true;
            }
        }

        return nodes.keys.inputRangeObject;
    }
    
    /**
    *   Returns graph weights set
    */
    InputRange!string weights()
    {
        bool[Weight] weights;
        
        foreach(source, list; lists)
        {
            foreach(dist, weight; list)
            {
                weights[weight] = true;
            }
        }
        return weights.keys.inputRangeObject;
    }
    
    /**
    *   Returns graph edges set
    */
    InputRange!Edge edges()
    {
        auto builder = appender!(Edge[]);

        foreach(source, list; lists)
        {
            foreach(dist, weight; list)
            {
                builder.put(Edge(source, dist, weight));
            }
        }

        return builder.data.inputRangeObject;
    }
    
    string genDot()
    {
        Weight[Node] getFirst(out Node node)
        {
            foreach(k, list; lists)
            {
                node = k;
                return list;
            }
            assert(false);
        }
        
        string genNodeName(size_t i)
        {
            if(i >= 1000)
            {
                return text("n",i);
            } else if(i >= 100)
            {
                return text("n0",i);
            } else if(i >= 10)
            {
                return text("n00",i);
            } else
            {
                return text("n00",i);
            }
        }
        
        string genForList(ref size_t i, Node node, Weight[Node] list, ref size_t[Node] nodeMap)
        {
            auto builder = appender!string;
            
            string nodeName;
            if(node !in nodeMap)
            {
                nodeName = genNodeName(i);
                nodeMap[node] = i;
                i+=1;
                
                builder.put(nodeName);
                builder.put(" ;\n");
                
                builder.put(nodeName);
                builder.put(`[label="`);
                builder.put(node.to!string);
                builder.put(`"] ;`"\n"); 
            } else
            {
                nodeName = genNodeName(nodeMap[node]);
            }
            
            foreach(dist, weight; list)
            {
                bool genLabel = false;
                if(dist !in nodeMap)
                {
                    nodeMap[dist] = i;
                    i+=1;
                    genLabel = true;
                }
                builder.put(nodeName);
                builder.put(" -> ");
                builder.put(genNodeName(nodeMap[dist]));
                builder.put(` [ label = "`);
                builder.put(weight.to!string);
                builder.put(`" ] ;`);
                builder.put("\n");
                
                if(genLabel)
                {
                    builder.put(genNodeName(nodeMap[dist]));
                    builder.put(`[label="`);
                    builder.put(dist.to!string);
                    builder.put(`"] ;`"\n"); 
                }
            }
            return builder.data;
        }
        
        auto builder = appender!string;
        
        builder.put(`digraph "" {`"\n");
        size_t[Node] nodeMap;
        
        size_t i = 0;
        foreach(node, list; lists)
        {
            builder.put(genForList(i, node, list, nodeMap));
        }
        
        builder.put(`}`"\n");
        
        return builder.data;
    }
    
    private
    {
        Weight[Node][Node] lists;
    }
}

unittest
{
    import std.algorithm;
    
    auto edges = [
        IDirectedGraph.Edge("a", "b", "1"),
        IDirectedGraph.Edge("b", "a", "2")
    ]; 
    
    auto graph = new ConnListGraph();
    graph.load(edges.inputRangeObject);
    
    assert(graph.nodes.array.sort.equal(["a", "b"]));
    assert(graph.weights.array.sort.equal(["1", "2"]));
}
unittest
{
    import std.process;
    import std.stdio;
    
    auto edges = [
        IDirectedGraph.Edge("a", "b", "1"),
        IDirectedGraph.Edge("b", "a", "2"),
        IDirectedGraph.Edge("c", "a", "3"),
        IDirectedGraph.Edge("c", "b", "1")
    ];
    
    auto graph = new ConnListGraph();
    graph.load(edges.inputRangeObject);
    
    auto file = File("test.dot", "w");
    file.writeln(graph.genDot);
    file.close();
    
    shell("dot -Tpng test.dot > test.png");
    shell("gwenview test.png");
}