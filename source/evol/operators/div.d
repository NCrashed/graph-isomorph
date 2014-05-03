/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.div;

import std.stdio;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typepod;
}

class DivOperator : Operator
{
    TypePod!double doubletype;
    
    enum description = "Арифметическая операция деления действительных чисел.";
    
    this()
    {
        doubletype = cast(TypePod!double)(TypeMng.getSingleton().getType("Typedouble"));
        assert(doubletype, "We need double type!");
        
        mRetType = doubletype;
        super("/", description, ArgsStyle.BINAR_STYLE);
        
        ArgInfo a1;
        a1.type = doubletype;
        a1.min = "-1000";
        a1.max = "+1000";
        
        args ~= a1;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto ret = doubletype.getNewArg();
        
        auto a1 = cast(ArgPod!double)(line[0]);
        auto a2 = cast(ArgPod!double)(line[1]);
        
        assert( a1 !is null, "Critical error: Operator plus, argument 1 isn't a right value!");
        assert( a2 !is null, "Critical error: Operator plus, argument 2 isn't a right value!");
        
        ret = a1.val / a2.val;
        return ret;
    }   
}