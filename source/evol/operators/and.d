/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.and;

import devol.world;
import devol.std.line;
import devol.individ;
import devol.operator;
import devol.type;
import devol.typemng;
import devol.std.argpod;
import devol.std.typepod;
import devol.argument;

class AndOperator : Operator
{
    TypePod!bool booltype;
    
    this()
    {
        booltype = cast(TypePod!bool)TypeMng.getSingleton().getType("Typebool");
        mRetType = booltype;
        
        super("&&", "Логическое 'И' для значений ложь/истина.", ArgsStyle.BINAR_STYLE);
        
        ArgInfo a1;
        a1.type = booltype;
        args ~= a1;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract individ, Line line, WorldAbstract world)
    {
        auto ret = booltype.getNewArg();
        
        auto a1 = cast(ArgPod!bool)line[0];
        auto a2 = cast(ArgPod!bool)line[1];
        
        assert(a1 !is null);
        assert(a2 !is null);
        
        ret = a1.val && a2.val;
        return ret;
    }
}