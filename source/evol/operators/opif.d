/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.opif;import devol.typemng;

import devol.individ;
import devol.world;
import devol.operator;  
import devol.std.typepod;

debug import std.stdio;

class IfOperator : Operator
{
    TypePod!bool booltype;
    TypeVoid voidtype;
    
    enum description = "Условный оператор, который берет три аргумента. Первый "
    "имеет логический тип, который относится к условию действия. Если этот аргумент "
    "вычисляется в значение 'ИСТИНА', то возвращается второй аргумент, иначе "
    "возвращается третий аргумент. Второй и третий аргументы относятся к действиям, "
    "которые имеют тип void";
    
    this()
    {
        booltype = cast(TypePod!bool)(TypeMng.getSingleton().getType("Typebool"));
        assert(booltype, "We need bool type!");
        
        voidtype = cast(TypeVoid)(TypeMng.getSingleton().getType("TypeVoid"));
        
        mRetType = voidtype;
        super("if", description, ArgsStyle.CONTROL_STYLE);
        
        ArgInfo a1;
        a1.type = booltype;
        args ~= a1;
        
        a1.type = voidtype;
        args ~= a1;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto cond = cast(ArgPod!bool)(line[0]);
        
        Line vthen = cast(Line)(line[1]);
        Line velse = cast(Line)(line[2]);
        
        ArgScope sthen = cast(ArgScope)(line[1]);
        ArgScope selse = cast(ArgScope)(line[2]);
        
        if (cond.val)
        {
            if (vthen !is null)
            {
                vthen.compile(ind, world);
            } else if (sthen !is null)
            {
                foreach(Line aline; sthen)
                {
                    auto line = cast(Line)aline;
                    line.compile(ind, world);
                }
            } else
            {
                debug writeln("Warning: invalid ThenArg: ", line.tostring);
            }//else throw new Exception("If is confused! ThenArg is no line, no scope. " ~ line.tostring);
        } else
        {
            if (velse !is null)
            {
                velse.compile(ind, world);
            } else if (selse !is null)
            {
                foreach(Line aline; selse)
                {
                    auto line = cast(Line)aline;
                    line.compile(ind, world);
                }               
            } else
            {
                debug writeln("Warning: invalid ElseArg: ", line.tostring);
            } //else throw new Exception("If is confused! ElseArg is no line, no scope" ~ line.tostring);           
        }
        return voidtype.getNewArg();
    }   
}
