/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.iover;

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

alias InputOverFirstOperator = InputOverOperator!((ind) => ind.firstGraphStack, "iover1"
    , "Копирует второй элемент стека первого графа на вершину.");  
alias InputOverSecondOperator = InputOverOperator!((ind) => ind.secondGraphStack, "iover2"
    , "Копирует второй элемент стека второго графа на вершину.");

class InputOverOperator(alias stack, string opname, string description) : Operator
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
        
        stack(gind).stackOver();
        
        return new ArgVoid;
    }   
}