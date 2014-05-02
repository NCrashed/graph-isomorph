/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.types.typeedge;

import std.stream;

public
{
    import devol.argument;
    import devol.type;
    import evol.types.argedge;
}

import dyaml.all;

import graph.directed;

class TypeEdge : Type
{
    this()
    {
        super("TypeEdge");
    }
    
    override ArgEdge getNewArg()
    {
        auto arg = new ArgEdge();
        foreach(i; 0..10)
            arg.randomChange();
            
        return arg;
    }
    
    override ArgEdge getNewArg(string min, string max, string[] exVal)
    {
        return getNewArg;
    }
    
    override Argument loadArgument(InputStream stream)
    {
        assert(false, "Not implemented!");
    }   
    
    override Argument loadArgument(Node node)
    {
        return new ArgEdge(IDirectedGraph.IndexedEdge(node["source"].as!size_t, node["dist"].as!size_t));
    }
}