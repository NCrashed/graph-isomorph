/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.progtype;

import devol.programtype;
import devol.typemng;
import devol.operatormng;

import devol.std.typepod;
import std.conv;

import evol.operators.and;
import evol.operators.not;
import evol.operators.opif;
import evol.operators.or;

import std.algorithm;
import std.range;

class ProgramType : ProgTypeAbstract
{
    this()
    {
        registerTypes();
    }

    void registerTypes()
    {
        auto tmng = TypeMng.getSingleton();
        auto omng = OperatorMng.getSingleton();
        
        auto types = tmng.strings;
        if(types.find("Typebool").empty)
        {
            tmng.registerType!TypeBool();
        }
        
        auto ops = omng.strings;
        if(ops.find("if").empty)
        {
            omng.registerOperator!IfOperator();
        }
        if(ops.find("&&").empty)
        {
            omng.registerOperator!AndOperator();
        }
        if(ops.find("||").empty)
        {
            omng.registerOperator!OrOperator();
        }
        if(ops.find("!").empty)
        {
            omng.registerOperator!NotOperator();
        }
    }
    
    private uint mProgMinSize = 4;
    @property uint progMinSize()
    {
        return mProgMinSize;
    }
    
    @property void progMinSize(uint val)
    {
        mProgMinSize = val;
    }
    
    private uint mProgMaxSize = 8;
    @property uint progMaxSize()
    {
        return mProgMaxSize;
    }
    
    @property void progMaxSize(uint val)
    {
        mProgMaxSize = val;
    }
    
    private float mNewOpGenChacne = 0.3;
    @property float newOpGenChance()
    {
        return mNewOpGenChacne;
    }
    
    @property void newOpGenChance(float val)
    {
        mNewOpGenChacne = val;
    }
    
    private float mNewScopeGenChance = 0.1;
    @property float newScopeGenChance()
    {
        return mNewScopeGenChance;
    }
    
    @property void newScopeGenChance(float val)
    {
        mNewScopeGenChance = val;
    }
      
    private float mNewLeafGenChance = 0.6;
    @property float newLeafGenChance()
    {
        return mNewLeafGenChance;
    }
    
    @property void newLeafGenChance(float val)
    {
        mNewLeafGenChance = val;
    }
    
    private uint mScopeMinSize = 2;
    @property uint scopeMinSize()
    {
        return mScopeMinSize;
    }
    
    @property void scopeMinSize(uint val)
    {
        mScopeMinSize = val;
    }
    
    private uint mScopeMaxSize = 5;
    @property uint scopeMaxSize()
    {
        return mScopeMaxSize;
    }
    
    @property void scopeMaxSize(uint val)
    {
        mScopeMaxSize = val;
    }
    
    private float mMutationChance = 0.3;
    @property float mutationChance()
    {
        return mMutationChance;
    }
    
    @property void mutationChance(float val)
    {
        mMutationChance = val;
    }
    
    private float mCrossingoverChance = 0.7;
    @property float crossingoverChance()
    {
        return mCrossingoverChance;
    }
    
    @property void crossingoverChance(float val)
    {
        mCrossingoverChance = val;
    }
    
    private float mMutationChangeChance = 0.5;
    @property float mutationChangeChance()
    {
        return mMutationChangeChance;
    }
    
    @property void mutationChangeChance(float val)
    {
        mMutationChangeChance = val;
    }
    
    private float mMutationReplaceChance = 0.3;
    @property float mutationReplaceChance()
    {
        return mMutationReplaceChance;
    }
    
    @property void mutationReplaceChance(float val)
    {
        mMutationReplaceChance = val;
    }
    
    private float mMutationDeleteChance = 0.2;
    @property float mutationDeleteChance()
    {
        return mMutationDeleteChance;
    }
    
    @property void mutationDeleteChance(float val)
    {
        mMutationDeleteChance = val;
    }
    
    private float mMutationAddLineChance = 0.1;
    @property float mutationAddLineChance()
    {
        return mMutationAddLineChance;
    }
    
    @property void mutationAddLineChance(float val)
    {
        mMutationAddLineChance = val;
    }
    
    private float mMutationRemoveLineChance = 0.05;
    @property float mutationRemoveLineChance()
    {
        return mMutationRemoveLineChance;
    }
    
    @property void mutationRemoveLineChance(float val)
    {
        mMutationRemoveLineChance = val;
    }
    
    private string mMaxMutationChange = "100";
    @property string maxMutationChange()
    {
        return mMaxMutationChange;
    }
    
    @property void maxMutationChange(string val)
    {
        mMaxMutationChange = val;
    }
    
    private float mCopyingPart = 0.1;
    @property float copyingPart()
    {
        return mCopyingPart;
    }
    
    @property void copyingPart(float val)
    {
        mCopyingPart = val;
    }
    
    private size_t mDeleteMutationRiseGenomeSize = 200;
    @property size_t deleteMutationRiseGenomeSize()
    {
        return mDeleteMutationRiseGenomeSize;
    }
    
    @property void deleteMutationRiseGenomeSize(size_t val)
    {
        mDeleteMutationRiseGenomeSize = val;
    }
    
    private size_t mMaxGenomeSize = 300;
    @property size_t maxGenomeSize()
    {
        return mMaxGenomeSize;
    }
    
    @property void maxGenomeSize(size_t val)
    {
        mMaxGenomeSize = val;
    }
    
    private size_t mPopulationSize = 10;
    @property size_t populationSize()
    {
        return mPopulationSize;
    }
    
    @property void populationSize(size_t val)
    {
        mPopulationSize = val;
    }
    
    Line[] initValues(WorldAbstract pWorld)
    {
        return new Line[0];
    }
        
    double getFitness(IndAbstract pInd, WorldAbstract pWorld, double time)
    {
        return 0.0; // stab
    }
}