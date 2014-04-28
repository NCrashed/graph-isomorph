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
    bool stopCond(ref int step, IndAbstract ind, WorldAbstract world)
    {
        return step >= 1;
    }
    
    void drawStep(IndAbstract ind, WorldAbstract world)
    {
        
    }
    
    void drawFinal(PopAbstract pop, WorldAbstract world)
    {
        
    }
    
    int roundsPerInd()
    {
        return 1;
    }
}


alias GraphCompiler = Compiler!(
      GraphCompilation
    , Evolutor
    , ProgramType
    , GraphPopulation
    , GraphWorld);
