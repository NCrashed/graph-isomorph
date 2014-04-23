/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.progtype;

import devol.programtype;
import devol.typemng;
import devol.operatormng;
import std.conv;

class ProgramType : ProgTypeAbstract
{
    this()
    {
        auto tmng = TypeMng.getSingleton();
        auto omng = OperatorMng.getSingleton();
        
//        tmng.registerType!TypeBool();
//        tmng.registerType!TypeInt();
//        
//        omng.registerOperator!If();
//        omng.registerOperator!Plus();
//        omng.registerOperator!OpSense();
//        omng.registerOperator!GoForward();
//        omng.registerOperator!TurnLeft();
//        omng.registerOperator!TurnRight();
    }
    
    private uint mProgMinSize = 4;
    @property uint progMinSize()
    {
        return mProgMinSize;
    }
    
    void progMinSize(uint val)
    {
        mProgMinSize = val;
    }
    
    private uint mProgMaxSize = 8;
    @property uint progMaxSize()
    {
        return mProgMaxSize;
    }
    
    void progMaxSize(uint val)
    {
        mProgMaxSize = val;
    }
    
    private float mNewOpGenChacne = 0.3;
    @property float newOpGenChance()
    {
        return mNewOpGenChacne;
    }
    
    void newOpGenChance(float val)
    {
        mNewOpGenChacne = val;
    }
    
    private float mNewScopeGenChance = 0.1;
    @property float newScopeGenChance()
    {
        return mNewScopeGenChance;
    }
    
    void newScopeGenChance(float val)
    {
        mNewScopeGenChance = val;
    }
      
    private float mNewLeafGenChance = 0.6;
    @property float newLeafGenChance()
    {
        return mNewLeafGenChance;
    }
    
    void newLeafGenChance(float val)
    {
        mNewLeafGenChance = val;
    }
    
    private uint mScopeMinSize = 2;
    @property uint scopeMinSize()
    {
        return mScopeMinSize;
    }
    
    void scopeMinSize(uint val)
    {
        mScopeMinSize = val;
    }
    
    private uint mScopeMaxSize = 5;
    @property uint scopeMaxSize()
    {
        return mScopeMaxSize;
    }
    
    void scopeMaxSize(uint val)
    {
        mScopeMaxSize = val;
    }
    
    private float mMutationChance = 0.3;
    @property float mutationChance()
    {
        return mMutationChance;
    }
    
    void mutationChance(float val)
    {
        mMutationChance = val;
    }
    
    private float mCrossingoverChance = 0.7;
    @property float crossingoverChance()
    {
        return mCrossingoverChance;
    }
    
    void crossingoverChance(float val)
    {
        mCrossingoverChance = val;
    }
    
    private float mMutationChangeChance = 0.5;
    @property float mutationChangeChance()
    {
        return mMutationChangeChance;
    }
    
    void mutationChangeChance(float val)
    {
        mMutationChangeChance = val;
    }
    
    private float mMutationReplaceChance = 0.3;
    @property float mutationReplaceChance()
    {
        return mMutationReplaceChance;
    }
    
    void mutationReplaceChance(float val)
    {
        mMutationReplaceChance = val;
    }
    
    private float mMutationDeleteChance = 0.2;
    @property float mutationDeleteChance()
    {
        return mMutationDeleteChance;
    }
    
    void mutationDeleteChance(float val)
    {
        mMutationDeleteChance = val;
    }
    
    private float mMutationAddLineChance = 0.1;
    @property float mutationAddLineChance()
    {
        return mMutationAddLineChance;
    }
    
    void mutationAddLineChance(float val)
    {
        mMutationAddLineChance = val;
    }
    
    private float mMutationRemoveLineChance = 0.05;
    @property float mutationRemoveLineChance()
    {
        return mMutationRemoveLineChance;
    }
    
    void mutationRemoveLineChance(float val)
    {
        mMutationRemoveLineChance = val;
    }
    
    private string mMaxMutationChange = "100";
    @property string maxMutationChange()
    {
        return mMaxMutationChange;
    }
    
    void maxMutationChange(double val)
    {
        mMaxMutationChange = val.to!string;
    }
    
    private float mCopyingPart = 0.1;
    @property float copyingPart()
    {
        return mCopyingPart;
    }
    
    void copyingPart(float val)
    {
        mCopyingPart = val;
    }
    
    private size_t mDeleteMutationRiseGenomeSize = 200;
    size_t deleteMutationRiseGenomeSize()
    {
        return mDeleteMutationRiseGenomeSize;
    }
    
    void deleteMutationRiseGenomeSize(size_t val)
    {
        mDeleteMutationRiseGenomeSize = val;
    }
    
    private size_t mMaxGenomeSize = 300;
    size_t maxGenomeSize()
    {
        return mMaxGenomeSize;
    }
    
    void maxGenomeSize(size_t val)
    {
        mMaxGenomeSize = val;
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