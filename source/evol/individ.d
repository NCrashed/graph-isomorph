/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.individ;

import devol.individ;

import dyaml.all;

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
}
