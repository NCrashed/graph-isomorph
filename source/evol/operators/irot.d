/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.irot;

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

alias InputRotFirstOperator = InputRotOperator!((ind) => ind.firstGraphStack, "irot1"
    , "Перемещает третий элемент стека первого графа на вершину.");  
alias InputRotSecondOperator = InputRotOperator!((ind) => ind.secondGraphStack, "irot2"
    , "Перемещает третий элемент стека второго графа на вершину.");

class InputRotOperator(alias stack, string opname, string description) : Operator
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
        
        stack(gind).stackRot();
        
        return new ArgVoid;
    }   
}