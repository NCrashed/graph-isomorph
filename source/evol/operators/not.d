/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.not;

import devol.world;
import devol.std.line;
import devol.individ;
import devol.operator;
import devol.type;
import devol.typemng;
import devol.std.argpod;
import devol.std.typepod;
import devol.argument;

class NotOperator : Operator
{
    TypePod!bool booltype;
    
    this()
    {
        booltype = cast(TypePod!bool)TypeMng.getSingleton().getType("Typebool");
        mRetType = booltype;
        
        super("!", "Логическое 'НЕТ' для значений ложь/истина.", ArgsStyle.UNAR_STYLE);
        
        ArgInfo a1;
        a1.type = booltype;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract individ, Line line, WorldAbstract world)
    {
        auto ret = booltype.getNewArg();
        
        auto a1 = cast(ArgPod!bool)line[0];
        
        assert(a1 !is null);
        
        ret = !a1.val;
        return ret;
    }
}