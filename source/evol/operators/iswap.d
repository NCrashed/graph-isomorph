/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.iswap;

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

alias InputSwapFirstOperator = InputSwapOperator!((ind) => ind.firstGraphStack, "iswap1"
    , "Меняет первых два элемента на стеке для первого графа местами.");  
alias InputSwapSecondOperator = InputSwapOperator!((ind) => ind.secondGraphStack, "iswap2"
    , "Меняет первых два элемента на стеке для второго графа местами.");

class InputSwapOperator(alias stack, string opname, string description) : Operator
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
        
        stack(gind).stackSwap();
        
        return new ArgVoid;
    }   
}