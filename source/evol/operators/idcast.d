/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.idcast;

import std.stdio;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typepod;
}

class IntDoubleCastOperator : Operator
{
    TypePod!double doubletype;
    TypePod!int inttype;
    
    enum description = "Преобразует целочисленное в действительное число.";
    
    this()
    {
        inttype = cast(TypePod!int)(TypeMng.getSingleton().getType("Typeint"));
        assert(inttype, "We need int type!");
        
        doubletype = cast(TypePod!double)(TypeMng.getSingleton().getType("Typedouble"));
        assert(doubletype, "We need double type!");
        
        mRetType = doubletype;
        super("cast", description, ArgsStyle.UNAR_STYLE);
        
        ArgInfo a1;
        a1.type = inttype;
        a1.min = "-100";
        a1.max = "+100";
        
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto ret = doubletype.getNewArg();
        
        auto a1 = cast(ArgPod!int)(line[0]);
        
        assert( a1 !is null, "Critical error: Operator plus, argument 1 isn't a right value!");
        
        ret = cast(double)a1.val;
        return ret;
    }   
}