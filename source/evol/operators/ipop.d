/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.ipop;

import std.stdio;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import evol.types.typeedge;
    import evol.types.argedge;
}

import evol.individ;

alias InputPopFirstOperator = InputPopOperator!((ind) => ind.firstGraphStack, "ipop1",
    "Снимает и возвращает голову стека первого графа.");
alias InputPopSecondOperator = InputPopOperator!((ind) => ind.secondGraphStack, "ipop2",
    "Снимает и возвращает голову стека второго графа.");

class InputPopOperator(alias stack, string opname, string description) : Operator
{
    TypeEdge edgetype;
    
    this()
    {
        edgetype = cast(TypeEdge)(TypeMng.getSingleton().getType("TypeEdge"));
        assert(edgetype, "We need edge type!");
        
        mRetType = edgetype;
        super(opname, description, ArgsStyle.NULAR_STYLE);
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto gind = cast(GraphIndivid)ind;
        assert(gind);
        
        return stack(gind).stackPop;
    }   
}