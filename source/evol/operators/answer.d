/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.answer;

import devol.typemng;

import devol.individ;
import devol.world;
import devol.operator;  
import devol.std.typepod;

import evol.individ;

class AnswerOperator : Operator
{
    TypePod!bool booltype;
    TypeVoid voidtype;
    
    enum description = "Записывает ответ. True - графы изоморфны, False - не изоморфны.";
    
    this()
    {
        booltype = cast(TypePod!bool)(TypeMng.getSingleton().getType("Typebool"));
        assert(booltype, "We need bool type!");
        
        voidtype = cast(TypeVoid)(TypeMng.getSingleton().getType("TypeVoid"));
        assert(voidtype);
        
        mRetType = voidtype;
        super("answer", description, ArgsStyle.UNAR_STYLE);
        
        ArgInfo a1;
        a1.type = booltype;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract aind, Line line, WorldAbstract world)
    {
        auto ind = cast(GraphIndivid)aind;
        assert(ind);
        
        auto cond = cast(ArgPod!bool)(line[0]);
        assert(cond);
 
        ind.answer = cond.val;
        
        return new ArgVoid;
    }   
}
