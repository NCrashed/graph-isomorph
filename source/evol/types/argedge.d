/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module evol.types.argedge;

import std.conv;
import std.random;
import devol.serializable;
import devol.typemng;

import dyaml.all;

import graph.directed;

class ArgEdge : Argument, ISerializable
{
    this()
    {
        super( TypeMng.getSingleton().getType("TypeEdge") );
    }
    
    this(IDirectedGraph.IndexedEdge edge)
    {
        this();
        opAssign(edge);
    }
    
    ref ArgEdge opAssign(Argument val)
    {
        auto arg = cast(ArgEdge)(val);
        if (arg is null) return this;
        
        mEdge = arg.mEdge;
        return this;
    }
    
    ref ArgEdge opAssign(IDirectedGraph.IndexedEdge val)
    {
        mEdge = val;
        return this;
    }
    
    override @property string tostring(uint depth=0)
    {
        return to!string(mEdge);
    }
    
    @property IDirectedGraph.IndexedEdge edge()
    {
        return mEdge;
    }
    
    @property IDirectedGraph.IndexedEdge val()
    {
        return mEdge;
    }
    
    override void randomChange()
    {
        size_t permuteIndex(size_t i)
        {
            int change = uniform!"[]"(-2,2);
            if(cast(int)i + change < 0) return 0; 
            return i + change;
        }
        
        auto chance = uniform!"[]"(0,1);
        if(chance == 0)
        {
            mEdge.source = permuteIndex(mEdge.source);
        } else if(chance == 1)
        {
            mEdge.dist = permuteIndex(mEdge.dist);
        }
    }
    
    override void randomChange(string maxChange)
    {
        randomChange();
    }
    
    override @property Argument dup()
    {
        auto darg = new ArgEdge();
        darg.mEdge = mEdge;
        return darg;
    }
    
    void saveBinary(OutputStream stream)
    {
        assert(false, "Not implemented!");
    }
    
    override Node saveYaml()
    {
        return Node([
            "class": Node("plain"),
            "source": Node(mEdge.source),
            "dist": Node(mEdge.dist),
            ]);
    }
    
    protected IDirectedGraph.IndexedEdge mEdge;
}