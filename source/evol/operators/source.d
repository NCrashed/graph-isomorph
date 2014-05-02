/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.source;

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

class GetSourceOperator : Operator
{
    TypeEdge edgetype;
    TypePod!int inttype;
    
    enum description = "Возвращает индекс вершины, из которой выходит ребро графа.";
    
    this()
    {
        edgetype = cast(TypeEdge)(TypeMng.getSingleton().getType("TypeEdge"));
        assert(edgetype, "We need edge type!");
    
        inttype = cast(TypePod!int)(TypeMng.getSingleton().getType("Typeint"));
        assert(inttype);
        
        mRetType = inttype;
        super("getSource", description, ArgsStyle.UNAR_STYLE);
        
        ArgInfo a1;
        a1.type = edgetype;
        
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto gind = cast(GraphIndivid)ind;
        assert(gind);
        
        auto a1 = cast(ArgEdge)(line[0]);
        assert(a1);
        
        return new ArgPod!int(cast(int)a1.edge.source);
    }   
}