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

import project;

alias Population!( getDefChars, GraphIndivid ) GraphPopulation;

class GraphCompilation : GameCompilation
{
    Project project;
    
	this(Project project, void delegate() updateGenerationInfo)
	{
	    this.project = project;
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
        project.population = cast(GraphPopulation)pop;	
    	updateGenerationInfo();
    }
    
    int roundsPerInd()
    {
        return 10;
    }
    
    private void delegate() updateGenerationInfo;
}


alias GraphCompiler = Compiler!(
      GraphCompilation
    , Evolutor
    , ProgramType
    , GraphPopulation
    , GraphWorld);
