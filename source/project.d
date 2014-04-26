/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module project;

import evol.progtype;
import yaml;
import std.path;

class Project
{
    ProgramType programType;
    string name;
    string filename;
    
    enum defaultProjectPath = "./project.yaml";
    enum evolSettings = "evolutionSettings";
    enum projectName = "name";
    
    this()
    {
        programType = new ProgramType();
        filename = defaultProjectPath;
        name = defaultProjectPath.baseName;
    }
    
    void open(Node root)
    {
    	programType = new ProgramType();
    	
        if(root.containsKey(projectName))
        {
            name = root[projectName].as!string;
        }
        
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
    
    void open(string filename)
    {
        this.filename = filename;
        open(Loader(filename).load);
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
        
        return Node([
            projectName  : Node(name),
            evolSettings : Node(emap)
            ]);
    }
    
    void recreate(string filename)
    {
        programType = new ProgramType();
        name = filename.baseName;
        this.filename = filename;
        save(filename);
    }
}