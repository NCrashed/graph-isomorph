/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.ipush;

import std.stdio;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typevoid;
    import devol.std.argvoid;
    
    import evol.types.typeedge;
    import evol.types.argedge;
}

import evol.individ;

alias InputPushFirstOperator = InputPushOperator!((ind) => ind.firstGraphStack, "ipush1"
    , "Сохраняет грань графа во входной стек для первого графа");  
alias InputPushSecondOperator = InputPushOperator!((ind) => ind.secondGraphStack, "ipush2"
    , "Сохраняет грань графа во входной стек для второго графа");

class InputPushOperator(alias stack, string opname, string description) : Operator
{
    TypeEdge edgetype;
    TypeVoid voidtype;
    
    this()
    {
        edgetype = cast(TypeEdge)(TypeMng.getSingleton().getType("TypeEdge"));
        assert(edgetype, "We need edge type!");
    
        voidtype = cast(TypeVoid)(TypeMng.getSingleton().getType("TypeVoid"));
        assert(voidtype);
        
        mRetType = voidtype;
        super(opname, description, ArgsStyle.UNAR_STYLE);
        
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
        
        stack(gind).stackPush(a1);
        
        return new ArgVoid;
    }   
}