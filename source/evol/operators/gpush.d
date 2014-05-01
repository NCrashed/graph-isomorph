/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.gpush;

import std.stdio;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typepod;
    import devol.std.typevoid;
    import devol.std.argvoid;
}

import evol.individ;

class GenericPushOperator : Operator
{
    TypePod!double doubletype;
    TypeVoid voidtype;
    
    enum description = "Сохраняет действительное число в стек общего назначения.";
    
    this()
    {
        doubletype = cast(TypePod!double)(TypeMng.getSingleton().getType("Typedouble"));
        assert(doubletype, "We need double type!");
    
        voidtype = cast(TypeVoid)(TypeMng.getSingleton().getType("TypeVoid"));
        assert(voidtype);
        
        mRetType = voidtype;
        super("gpush", description, ArgsStyle.UNAR_STYLE);
        
        ArgInfo a1;
        a1.type = doubletype;
        a1.min = "-1000";
        a1.max = "+1000";
        
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto gind = cast(GraphIndivid)ind;
        assert(gind);
        
        auto a1 = cast(ArgPod!double)(line[0]);
        assert(a1);
        
        gind.genericStack.stackPush(a1);
        
        return new ArgVoid;
    }   
}