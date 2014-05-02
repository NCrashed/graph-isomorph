/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.idup;

import std.stdio;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typevoid;
    import devol.std.argvoid;
}

import evol.individ;

alias InputDupFirstOperator = InputDupOperator!((ind) => ind.firstGraphStack, "idup1"
    , "Копирует вершину стека первого графа.");  
alias InputDupSecondOperator = InputDupOperator!((ind) => ind.secondGraphStack, "idup2"
    , "Копирует вершину стека второго графа.");

class InputDupOperator(alias stack, string opname, string description) : Operator
{
    TypeVoid voidtype;
    
    this()
    {
        voidtype = cast(TypeVoid)(TypeMng.getSingleton().getType("TypeVoid"));
        assert(voidtype);
        
        mRetType = voidtype;
        super(opname, description, ArgsStyle.NULAR_STYLE);
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto gind = cast(GraphIndivid)ind;
        assert(gind);
        
        stack(gind).stackDup();
        
        return new ArgVoid;
    }   
}