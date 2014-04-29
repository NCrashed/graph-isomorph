/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.compiler;

import devol.compiler;
import devol.population;

import evol.individ;
import evol.world;
import evol.progtype;

alias Population!( getDefChars, GraphIndivid ) GraphPopulation;

class GraphCompilation : GameCompilation
{
	this(void delegate(size_t, double, double) updateGenerationInfo)
	{
		this.updateGenerationInfo = updateGenerationInfo;
	}
	
    bool stopCond(ref int step, IndAbstract ind, WorldAbstract world)
    {
        return step >= 1;
    }
    
    void drawStep(IndAbstract ind, WorldAbstract world)
    {
        
    }
    
    void drawFinal(PopAbstract pop, WorldAbstract world)
    {
    	double maxFit = 0.0;
    	double avarFit = 0.0;
        foreach(ind; pop)
        {
        	if(ind.fitness > maxFit) maxFit = ind.fitness;
        	
        	avarFit += ind.fitness;
        }
        if(pop.length > 0)
        	avarFit /= pop.length;
        	
    	updateGenerationInfo(cast(size_t)pop.generation, maxFit, avarFit);
    }
    
    int roundsPerInd()
    {
        return 10;
    }
    
    private void delegate(size_t, double, double) updateGenerationInfo;
}


alias GraphCompiler = Compiler!(
      GraphCompilation
    , Evolutor
    , ProgramType
    , GraphPopulation
    , GraphWorld);
