/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.operators.relation;

import devol.typemng;

public
{
    import devol.individ;
    import devol.world;
    import devol.operator;
    import devol.std.typepod;
}

alias IntEqualOperator = RelationOperator!("== (int)", "==", TypePod!int, ArgPod!int, "Typeint", "Сравнение на равенство целочисленных аргументов.");
alias DoubleEqualOperator = RelationOperator!("== (double)", "==", TypePod!double, ArgPod!double, "Typedouble", "Сравнение на равенство действительных аргументов.");
    
alias IntGreaterOperator = RelationOperator!("> (int)", ">", TypePod!int, ArgPod!int, "Typeint", "Сравнение целочисленных аргументов. Возвращает ИСТИНА, если первый больше второго.");
alias IntLesserOperator = RelationOperator!("< (int)", "<", TypePod!int, ArgPod!int, "Typeint", "Сравнение целочисленных аргументов. Возвращает ИСТИНА, если первый меньше второго.");
alias IntGreaterEqualOperator = RelationOperator!(">= (int)", ">=", TypePod!int, ArgPod!int, "Typeint", "Сравнение целочисленных аргументов. Возвращает ИСТИНА, если первый больше второго или равен второму.");
alias IntLesserEqualOperator = RelationOperator!("<= (int)", "<=", TypePod!int, ArgPod!int, "Typeint", "Сравнение целочисленных аргументов. Возвращает ИСТИНА, если первый меньше второго или равен второму.");

alias DoubleGreaterOperator = RelationOperator!("> (double)", ">", TypePod!double, ArgPod!double, "Typedouble", "Сравнение действительных аргументов. Возвращает ИСТИНА, если первый больше второго.");
alias DoubleLesserOperator = RelationOperator!("< (double)", "<", TypePod!double, ArgPod!double, "Typedouble", "Сравнение действительных аргументов. Возвращает ИСТИНА, если первый меньше второго.");

class RelationOperator(string opname, string relation, DslType, DslArg, string dslTypeName, string description) : Operator
{
    DslType inputType;
    TypePod!bool boolType;
    
    static assert(opname != "");
    
    this()
    {
        inputType = cast(DslType)(TypeMng.getSingleton().getType(dslTypeName));
        assert(inputType, "We need "~dslTypeName~" type!");
        
        boolType = cast(TypePod!bool)(TypeMng.getSingleton().getType("Typebool"));
        assert(boolType, "We need bool type!");
        
        mRetType = boolType;
        super(opname, description, ArgsStyle.BINAR_STYLE);
        
        ArgInfo a1;
        a1.type = inputType;
        a1.min = "-1000";
        a1.max = "+1000";
        
        args ~= a1;
        args ~= a1;
    }
    
    override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
    {
        auto ret = boolType.getNewArg();
        
        auto a1 = cast(DslArg)(line[0]);
        auto a2 = cast(DslArg)(line[1]);
        
        assert( a1 !is null, "Critical error: Operator "~name~", argument 1 isn't a right value!");
        assert( a2 !is null, "Critical error: Operator "~name~", argument 2 isn't a right value!");
        
        ret = mixin(q{a1.val } ~ relation ~ q{ a2.val});
        return ret;
    }   
}