/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.individ;

import devol.individ;
import devol.argument;
import devol.std.argvoid;

import dyaml.all;

import std.container;

class GraphIndivid : Individ
{
    this()
    {

    }
    
    this(Individ ind)
    {
        this();
        loadFrom(ind);
    }
    
    override void initialize() 
    {
        super.initialize;
        
        mStack.clear;
    }
    
    override @property GraphIndivid dup()
    {
        auto ind = new GraphIndivid();
        
        ind.mProgram = [];
        foreach(line; mProgram)
            ind.mProgram ~= line.dup;
            
        ind.mMemory = [];
        foreach(line; mMemory)
            ind.mMemory ~= line.dup;
            
        ind.inVals = [];    
        foreach(line; inVals)
            ind.inVals ~= line.dup;
            
        ind.outVals = [];     
        foreach(line; outVals)
            ind.outVals ~= line.dup;    
            
        return ind;
    } 
    
    static GraphIndivid loadYaml(Node node)
    {
        auto ind = Individ.loadYaml(node);
        auto ant = new GraphIndivid();
        
        foreach(line; ind.program)
            ant.mProgram ~= line.dup;
        foreach(line; ind.memory)
            ant.mMemory ~= line.dup;    
        foreach(line; ind.invals)
            ant.inVals ~= line.dup;     
        foreach(line; ind.outvals)
            ant.outVals ~= line.dup;    
        
        return ant;
    } 
    
    void stackPush(Argument arg)
    {
        mStack.insertFront = arg;
    }
    
    Argument stackPop()
    {
        if(mStack.empty)
        {
            return new ArgVoid;
        } 
        else
        {
            auto arg = mStack.front;
            mStack.removeFront();
            return arg;
        }
    }
    
    void stackSwap()
    {
        if(mStack.empty) return;
        
        auto a1 = mStack.front;
        mStack.removeFront;
        
        if(mStack.empty)
        {
            mStack.insertFront = a1;
        } else
        {
            auto a2 = mStack.front;
            mStack.removeFront;
            
            mStack.insertFront = a1;
            mStack.insertFront = a2;
        }
    }
    
    void stackDup()
    {
        if(mStack.empty) return;
        
        mStack.insertFront = mStack.front;
    }
    
    void stackOver()
    {
        if(mStack.empty) return;
        
        auto a1 = mStack.front;
        mStack.removeFront;
        
        if(mStack.empty)
        {
            mStack.insertFront = a1;
        } else
        {
            auto a2 = mStack.front;
            mStack.removeFront;
            
            mStack.insertFront = a2;
            mStack.insertFront = a1;
            mStack.insertFront = a2;
        }
    }
    
    void stackRot()
    {
        if(mStack.empty) return;
        
        auto a1 = mStack.front;
        mStack.removeFront;
        
        if(mStack.empty)
        {
            mStack.insertFront = a1;
        } else
        {
            auto a2 = mStack.front;
            mStack.removeFront;
            
            if(mStack.empty)
            {
                mStack.insertFront = a2;
                mStack.insertFront = a1;
            } else
            {
                auto a3 = mStack.front;
                mStack.removeFront;
                
                mStack.insertFront = a2;
                mStack.insertFront = a1;
                mStack.insertFront = a3;
            }
        }
    }
    
    void stackDrop()
    {
        if(mStack.empty) return;
        
        mStack.removeFront;
    }
    
    private
    {
        DList!Argument mStack;
    }
}
