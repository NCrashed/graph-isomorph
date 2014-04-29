/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.individ;

import devol.individ;

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
}
