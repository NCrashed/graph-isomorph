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
    
    this(IDirectedGraph.Edge edge)
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
    
    ref ArgEdge opAssign(IDirectedGraph.Edge val)
    {
        mEdge = val;
        return this;
    }
    
    override @property string tostring(uint depth=0)
    {
        return to!string(mEdge);
    }
    
    @property IDirectedGraph.Edge edge()
    {
        return mEdge;
    }
    
    override void randomChange()
    {
        string permuteStr(string str)
        {
            enum alphabet = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
            
            auto chance = uniform!"[]"(0,3);
            if(chance == 0) // adding char
            {
                if(str == "") return [alphabet[uniform(0,alphabet.length)]].idup;
                
                size_t point = uniform(0, str.length);
                
                return str[0 .. point] ~ alphabet[uniform(0,alphabet.length)] ~ str[point .. $];
            } 
            else if(chance == 1) // removing chance
            {
                if(str == "") return str;
                
                size_t point = uniform(0, str.length);
                return str[0 .. point] ~ str[point+1 .. $];
            }
            else if(chance == 2) // changing chance
            {
                if(str == "") return str;
                
                size_t point = uniform(0, str.length);
                return str[0 .. point] ~ alphabet[uniform(0,alphabet.length)] ~ str[point+1 .. $];
            }
            
            return str;
        }
        
        auto chance = uniform!"[]"(0,1);
        if(chance == 0)
        {
            mEdge.source = permuteStr(mEdge.source);
        } else if(chance == 1)
        {
            mEdge.dist = permuteStr(mEdge.dist);
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
    
    protected IDirectedGraph.Edge mEdge;
}