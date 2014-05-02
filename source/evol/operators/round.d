/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.round;

import std.stdio;
import std.math;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typepod;
}

class RoundOperator : Operator
{
    TypePod!double doubletype;
    TypePod!int inttype;
    
    enum description = "Преобразует действительное в целочисленное число с помощью математического округления.";
    
    this()
    {
        inttype = cast(TypePod!int)(TypeMng.getSingleton().getType("Typeint"));
        assert(inttype, "We need int type!");
        
        doubletype = cast(TypePod!double)(TypeMng.getSingleton().getType("Typedouble"));
        assert(doubletype, "We need double type!");
        
        mRetType = inttype;
        super("round", description, ArgsStyle.UNAR_STYLE);
        
        ArgInfo a1;
        a1.type = doubletype;
        a1.min = "-100";
        a1.max = "+100";
        
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto ret = inttype.getNewArg();
        
        auto a1 = cast(ArgPod!double)(line[0]);
        
        assert( a1 !is null, "Critical error: Operator plus, argument 1 isn't a right value!");
        
        ret = cast(int)round(a1.val);
        return ret;
    }   
}