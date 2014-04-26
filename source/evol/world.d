/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.world;

import devol.world;

import std.algorithm;
import std.array;
import std.random;
import std.range;

import graph.directed;
import graph.connectivity;

class GraphWorld : WorldAbstract
{
    void initialize()
    {   
        genUniqName(true);
        initInput();
    }
    
    IDirectedGraph firstGraph()
    {
        return mInputGraphFirst;
    }
    
    IDirectedGraph secondGraph()
    {
        return mInputGraphSecond;
    }
    
    private
    {
        IDirectedGraph mInputGraphFirst;
        IDirectedGraph mInputGraphSecond;
        enum permuteChance = 0.5;
        enum defaultNodesCount = 5;
        enum defaultLinksCount = 3;
        enum defaultPermutesMin = 2;
        enum defaultPermutesMax = 4;
        
        void initInput()
        {
            mInputGraphFirst = generateGraph(defaultNodesCount, defaultLinksCount);
            if(getChance(permuteChance))
            {
                mInputGraphSecond 
                    = permuteGraph(mInputGraphFirst
                        , uniform!"[]"(defaultPermutesMin, defaultPermutesMax));
            } else
            {
                mInputGraphSecond 
                    = generateGraph(defaultNodesCount, defaultLinksCount);
            }
        }
        
        static bool getChance(float val)
        {
            return uniform!"[]"(0.0,1.0) <= val;
        }
        
        static string genUniqName(bool clearMemory = false)
        {
            static bool[string] memory;
            if(clearMemory)
            {
                bool[string] clean;
                memory = clean;
                return "";
            }
            
            immutable alphabet = "qwertyuiopasdfghjklzxcvbnm";
            string genString(size_t l)
            {
                auto builder = appender!string;
                foreach(i; 0..l)
                    builder.put(alphabet[uniform(0,alphabet.length)]);
                return builder.data;
            }
            
            size_t i = 1;
            while(true)
            {
                string name = genString(i);
                if(name in memory)
                {
                    i++;
                } else
                {
                    return name;
                }
            }
        }
        
        static IDirectedGraph generateGraph(size_t nodesCount, size_t linksCount)
        {
            auto nodesBuilder = appender!(string[]);
            foreach(i; 0..nodesCount)
            {
                nodesBuilder.put(genUniqName());
            }
            
            auto nodes = nodesBuilder.data;
            auto edgeBuilder = appender!(IDirectedGraph.Edge[]);
            foreach(i; 0..linksCount)
            {
                size_t a = uniform(0, nodesCount);
                size_t b = uniform(0, nodesCount);
                edgeBuilder.put(IDirectedGraph.Edge(nodes[a], nodes[b], ""));
            }
            
            auto graph = new ConnListGraph;
            graph.load(edgeBuilder.data[].inputRangeObject);
            return graph;
        }
        
        static IDirectedGraph permuteGraph(IDirectedGraph graph, size_t permuteCount)
        {
            auto edges = graph.edges.array;
            
            foreach(i; 0..permuteCount)
            {
                size_t a = uniform(0, edges.length);
                size_t b = uniform(0, edges.length);
                
                if(a != b)
                {
                    auto edgeAOld = edges[a];
                    auto edgeBOld = edges[b];
                    
                    if(getChance(0.5))
                    {
                        auto edgeANew = IDirectedGraph.Edge(
                            edgeBOld.source,
                            edgeAOld.dist,
                            edgeAOld.weight);
                        auto edgeBNew = IDirectedGraph.Edge(
                            edgeAOld.source,
                            edgeBOld.dist,
                            edgeBOld.weight);
                        
                        edges[a] = edgeANew;
                        edges[b] = edgeBNew;
                    } else
                    {
                        auto edgeANew = IDirectedGraph.Edge(
                            edgeAOld.source,
                            edgeBOld.dist,
                            edgeAOld.weight);
                        auto edgeBNew = IDirectedGraph.Edge(
                            edgeBOld.source,
                            edgeAOld.dist,
                            edgeBOld.weight);
                        
                        edges[a] = edgeANew;
                        edges[b] = edgeBNew;
                    }
                }
            }
            
            auto newGraph = new ConnListGraph;
            newGraph.load(edges[].inputRangeObject);
            return newGraph;
        }
    }
}