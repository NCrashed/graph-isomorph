/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module project;

import evol.progtype;
import yaml;

class Project
{
    ProgramType programType;
    enum evolSettings = "evolutionSettings";
    
    this(Node root)
    {
        programType = new ProgramType();
        
        if(root.containsKey(evolSettings))
        {
            Node node = root[evolSettings];
            
            void setValue(string field)()
            {
                mixin("alias T = typeof(programType."~field~");");
                if(node.containsKey(field))
                {
                    mixin("programType."~field~` = node["`~field~`"].as!`~T.stringof~";");
                }
            }
            
            setValue!"progMinSize";
            setValue!"progMaxSize";
            setValue!"newOpGenChance";
            setValue!"newScopeGenChance";
            setValue!"newLeafGenChance";
            setValue!"scopeMinSize";
            setValue!"scopeMaxSize";
            setValue!"mutationChance";
            setValue!"crossingoverChance";
            setValue!"mutationChangeChance";
            setValue!"mutationReplaceChance";
            setValue!"mutationDeleteChance";
            setValue!"mutationAddLineChance";
            setValue!"mutationRemoveLineChance";
            setValue!"copyingPart";
            setValue!"deleteMutationRiseGenomeSize";
            setValue!"maxGenomeSize";
        }
    }
    
    this(string filename)
    {
        Node root = Loader(filename).load();
        this(root);
    }
    
    void save(string filename)
    {
        Dumper(filename).dump(dump);
    }
    
    Node dump()
    {
        Node[string] emap;
        
        void setValue(string field)()
        {
            mixin("alias T = typeof(programType."~field~");");
            emap[field] = Node(mixin("programType."~field));
        }
        
        setValue!"progMinSize";
        setValue!"progMaxSize";
        setValue!"newOpGenChance";
        setValue!"newScopeGenChance";
        setValue!"newLeafGenChance";
        setValue!"scopeMinSize";
        setValue!"scopeMaxSize";
        setValue!"mutationChance";
        setValue!"crossingoverChance";
        setValue!"mutationChangeChance";
        setValue!"mutationReplaceChance";
        setValue!"mutationDeleteChance";
        setValue!"mutationAddLineChance";
        setValue!"mutationRemoveLineChance";
        setValue!"copyingPart";
        setValue!"deleteMutationRiseGenomeSize";
        setValue!"maxGenomeSize";
        
        return Node([evolSettings : Node(emap)]);
    }
}