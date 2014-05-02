/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.construct;

import std.stdio;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typevoid;
    import devol.std.argvoid;
    import devol.std.typepod;
    
    import evol.types.typeedge;
    import evol.types.argedge;
}

import evol.individ;
import graph.directed;

class ConstructOperator : Operator
{
    TypeEdge edgetype;
    TypePod!int inttype;
    
    enum description = "Создает новое ребро графа из двух индексов: начала и конца.";
    
    this()
    {
        edgetype = cast(TypeEdge)(TypeMng.getSingleton().getType("TypeEdge"));
        assert(edgetype, "We need edge type!");
    
        inttype = cast(TypePod!int)(TypeMng.getSingleton().getType("Typeint"));
        assert(inttype);
        
        mRetType = edgetype;
        super("construct", description, ArgsStyle.CLASSIC_STYLE);
        
        ArgInfo a1;
        a1.type = inttype;
        a1.max = "20";
        a1.min = "0";
        
        args ~= a1;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto gind = cast(GraphIndivid)ind;
        assert(gind);
        
        auto a1 = cast(ArgPod!int)(line[0]);
        auto a2 = cast(ArgPod!int)(line[0]);
        assert(a1);
        assert(a2);
        
        return new ArgEdge(IDirectedGraph.IndexedEdge(a1.val, a2.val));
    }   
}