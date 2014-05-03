/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.opwhile;

import devol.typemng;

import devol.individ;
import devol.world;
import devol.operator;  
import devol.std.typepod;

debug import std.stdio;

class WhileOperator : Operator
{
    TypePod!bool booltype;
    TypeVoid voidtype;
    
    enum MAX_ITERATIONS = 100;
    
    enum description = "Оператор, управляющий потоком исполнения. Его второй аргумент "
                       "выполняется до тех пор, пока первый аргумент вычисляется в ИСТИНА. "
                       "Во избежание бесконечной программы накладывается ограничение на "
                       "максимальное число итераций.";
    
    this()
    {
        booltype = cast(TypePod!bool)(TypeMng.getSingleton().getType("Typebool"));
        assert(booltype, "We need bool type!");
        
        voidtype = cast(TypeVoid)(TypeMng.getSingleton().getType("TypeVoid"));
        
        mRetType = voidtype;
        super("while", description, ArgsStyle.CONTROL_STYLE);
        
        ArgInfo a1;
        a1.type = booltype;
        a1.eval = false;
        args ~= a1;
        
        a1.type = voidtype;
        a1.eval = false;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto condLine = cast(Line)(line[0]);
        auto condConst = cast(ArgPod!bool)(line[0]);
        size_t iterations;
        
        Line vaction = cast(Line)(line[1]);
        ArgScope saction = cast(ArgScope)(line[1]);
        
        void iterateOnce()
        {
            if (vaction !is null)
            {
                vaction.compile(ind, world);
            } else if (saction !is null)
            {
                foreach(Line aline; saction)
                {
                    auto line = cast(Line)aline;
                    line.compile(ind, world);
                }
            } else
            {
                debug writeln("Warning: invalid ThenArg: ", line.tostring);
            }
        }
        
        if(condLine is null)
        {
            assert(condConst);
            if(condConst)
            {
               foreach(i; 0..MAX_ITERATIONS)
               {
                   iterateOnce();
               }
            }
        } else
        {
           foreach(i; 0..MAX_ITERATIONS)
           {
               if(!condLine.compile(ind, world)) break;
               iterateOnce();
           }
        }
        
        return voidtype.getNewArg();
    }   
}
