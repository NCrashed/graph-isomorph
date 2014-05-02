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
import std.file;
import std.stdio;
import std.path;
import std.process;

import graph.directed;
import graph.connectivity;

import evol.progtype;

class GraphWorld : WorldAbstract
{
    ProgramType programType;
    
    this()
    {
        assert(false);
    }
    
    this(ProgramType programType, 
         void delegate(IDirectedGraph, IDirectedGraph) updateDrawDel)
    {
        this.programType = programType;
        this.updateDrawDel = updateDrawDel;
    }
    
    void initialize()
    {   
        genUniqName(true);
        initInput();
        
        updateDrawDel(mInputGraphFirst, mInputGraphSecond);
    }
    
    IDirectedGraph firstGraph()
    {
        return mInputGraphFirst;
    }
    
    IDirectedGraph secondGraph()
    {
        return mInputGraphSecond;
    }
    
    bool correctAnswer()
    {
        return mAnswer;
    }
    
    private
    {
        void delegate(IDirectedGraph, IDirectedGraph) updateDrawDel;
        IDirectedGraph mInputGraphFirst;
        IDirectedGraph mInputGraphSecond;
        bool mAnswer;
        
        void initInput()
        {
            mInputGraphFirst = generateGraph(
                  uniform!"[]"(programType.graphNodesCountMin, programType.graphNodesCountMax)
                , uniform!"[]"(programType.graphLinksCountMin, programType.graphLinksCountMax));
            if(getChance(programType.graphPermuteChance))
            {
                mInputGraphSecond 
                    = permuteGraph(mInputGraphFirst
                        , uniform!"[]"(programType.graphPermutesCountMin
                                     , programType.graphPermutesCountMax));
                mAnswer = true;
            } else
            {
                mInputGraphSecond 
                    = generateGraph(
                  uniform!"[]"(programType.graphNodesCountMin, programType.graphNodesCountMax)
                , uniform!"[]"(programType.graphLinksCountMin, programType.graphLinksCountMax));
                
                mAnswer = false;
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
            auto nodes = graph.nodes.array;
            IDirectedGraph.Edge[] edges;
            
            foreach(i; 0..permuteCount)
            {
                auto builder = appender!(IDirectedGraph.Edge[]);
                auto a = nodes[uniform(0, nodes.length)];
                auto b = nodes[uniform(0, nodes.length)];
                
                foreach(edge; graph.edges)
                {
                    if(a != b)
                    {
                        if(edge.source == a) edge.source = b;
                        else if(edge.source == b) edge.source = a;
                        
                        if(edge.dist == a) edge.dist = b;
                        else if(edge.dist == b) edge.dist = a;
                    }
                    
                    builder.put(edge);
                }
                
                edges = builder.data;
            }
            
            auto newGraph = new ConnListGraph;
            newGraph.load(edges.inputRangeObject);
            return newGraph;
        }
    }
}