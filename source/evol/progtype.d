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
import evol.operators.opwhile;
import evol.operators.or;
import evol.operators.plus;
import evol.operators.mult;
import evol.operators.div;
import evol.operators.relation;
import evol.operators.gpop;
import evol.operators.gpush;
import evol.operators.gdup;
import evol.operators.gover;
import evol.operators.grot;
import evol.operators.gswap;
import evol.operators.ipop;
import evol.operators.ipush;
import evol.operators.idup;
import evol.operators.iover;
import evol.operators.irot;
import evol.operators.iswap;
import evol.operators.construct;
import evol.operators.dist;
import evol.operators.source;
import evol.operators.idcast;
import evol.operators.round;
import evol.operators.answer;

import evol.types.typeedge;
import evol.individ;
import evol.world;

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
        if(types.find("Typeint").empty)
        {
            tmng.registerType!TypeInt();
        }
        if(types.find("Typedouble").empty)
        {
            tmng.registerType!TypeDouble();
        }
        if(types.find("TypeEdge").empty)
        {
            tmng.registerType!TypeEdge();
        }
        
        auto ops = omng.strings;
        void registerOperator(T)(string name)
        {
            assert(name != "");
            if(ops.find(name).empty)
            {
                omng.registerOperator!T();
            }
        }
        
        registerOperator!IfOperator("if");
        registerOperator!WhileOperator("while");
        registerOperator!AndOperator("&&");
        registerOperator!OrOperator("||");
        registerOperator!NotOperator("!");
        
        registerOperator!PlusOperator("+");
        registerOperator!MultOperator("*");
        registerOperator!DivOperator("/");
        
        registerOperator!IntEqualOperator("== (int)");
        registerOperator!IntGreaterOperator("> (int)");
        registerOperator!IntLesserOperator("< (int)");
        registerOperator!IntGreaterEqualOperator(">= (int)");
        registerOperator!IntLesserEqualOperator("<= (int)");
        
        registerOperator!DoubleEqualOperator("== (double)");
        registerOperator!DoubleGreaterOperator("> (double)");
        registerOperator!DoubleLesserOperator("< (double)");
        
        registerOperator!GenericPopOperator("gpop");
        registerOperator!GenericPushOperator("gpush");
        registerOperator!GenericDupOperator("gdup");
        registerOperator!GenericOverOperator("gover");
        registerOperator!GenericRotOperator("grot");
        registerOperator!GenericSwapOperator("gswap");
        
        registerOperator!InputPopFirstOperator("ipop1");
        registerOperator!InputPushFirstOperator("ipush1");
        registerOperator!InputDupFirstOperator("idup1");
        registerOperator!InputOverFirstOperator("iover1");
        registerOperator!InputRotFirstOperator("irot1");
        registerOperator!InputSwapFirstOperator("iswap1");
        
        registerOperator!InputPopSecondOperator("ipop2");
        registerOperator!InputPushSecondOperator("ipush2");
        registerOperator!InputDupSecondOperator("idup2");
        registerOperator!InputOverSecondOperator("iover2");
        registerOperator!InputRotSecondOperator("irot2");
        registerOperator!InputSwapSecondOperator("iswap2");
        
        registerOperator!ConstructOperator("construct");
        registerOperator!GetSourceOperator("getSource");
        registerOperator!GetDistOperator("getDist");
        
        registerOperator!IntDoubleCastOperator("cast");
        registerOperator!RoundOperator("round");
        registerOperator!AnswerOperator("answer");
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
    
    private double mGraphPermuteChance = 0.5;
    @property double graphPermuteChance()
    {
        return mGraphPermuteChance;
    }
    
    @property void graphPermuteChance(double val)
    in
    {
        assert(0.0 <= val && val <= 1.1, "Not a chance!"); 
    }
    body
    {
        mGraphPermuteChance = val;
    }
    
    private size_t mGraphNodesCountMin = 3;
    @property size_t graphNodesCountMin()
    {
        return mGraphNodesCountMin;
    }
    
    @property void graphNodesCountMin(size_t val)
    in
    {
        assert(val <= mGraphNodesCountMax, "Must be <= graphNodesCountMax");
    }
    body
    {
        mGraphNodesCountMin = val;
    }
    
    private size_t mGraphNodesCountMax = 10;
    @property size_t graphNodesCountMax()
    {
        return mGraphNodesCountMax;
    }
    
    @property void graphNodesCountMax(size_t val)
    in
    {
        assert(val >= mGraphNodesCountMin, "Must be >= graphNodesCountMin");
    }
    body
    {
        mGraphNodesCountMax = val;
    }
    
    private size_t mGraphLinksCountMin = 3;
    @property size_t graphLinksCountMin()
    {
        return mGraphLinksCountMin;
    }
    
    @property void graphLinksCountMin(size_t val)
    in
    {
        assert(val <= mGraphLinksCountMax, "Must be <= graphLinksCountMax");
    }
    body
    {
        mGraphLinksCountMin = val;
    }
    
    private size_t mGraphLinksCountMax = 6;
    @property size_t graphLinksCountMax()
    {
        return mGraphLinksCountMax;
    }
    
    @property void graphLinksCountMax(size_t val)
    in
    {
        assert(val >= mGraphLinksCountMin, "Must be >= graphLinksCountMin");
    }
    body
    {
        mGraphLinksCountMax = val;
    }
    
    
    private size_t mGraphPermutesCountMin = 2;
    @property size_t graphPermutesCountMin()
    {
        return mGraphPermutesCountMin;
    }
    
    @property void graphPermutesCountMin(size_t val)
    in
    {
        assert(val <= mGraphPermutesCountMax, "Must be <= graphPermutesCountMax");
    }
    body
    {
        mGraphPermutesCountMin = val;
    }
    
    private size_t mGraphPermutesCountMax = 4;
    @property size_t graphPermutesCountMax()
    {
        return mGraphPermutesCountMax;
    }
    
    @property void graphPermutesCountMax(size_t val)
    in
    {
        assert(val >= mGraphPermutesCountMin, "Must be >= graphPermutesCountMin");
    }
    body
    {
        mGraphPermutesCountMax = val;
    }
    
    Line[] initValues(WorldAbstract pWorld)
    {
        return new Line[0];
    }
        
    double getFitness(IndAbstract pInd, WorldAbstract pWorld, double time)
    {
        auto ind = cast(GraphIndivid)pInd;
        auto world = cast(GraphWorld)pWorld;
        assert(ind); 
        assert(world);
        
        /// TODO: time check
        return ind.answer == world.correctAnswer ? 1.0 : 0.0; 
    }
}