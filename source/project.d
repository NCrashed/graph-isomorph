/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module project;

import evol.progtype;
import evol.compiler;

import yaml;
import std.path;
import std.file;
import std.stream;

import dlogg.log;

class Project
{
    ProgramType programType;
    GraphPopulation population;
    string name;
    string filename;
    string populationPath;
    
    bool popLoaded = true;
    
    private shared ILogger logger;
    
    enum defaultProjectPath = "./project.yaml";
    enum evolSettings = "evolutionSettings";
    enum projectName = "name";
    enum popPathKeyName = "population";
    
    this(shared ILogger logger)
    {
        this.logger = logger;
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
            setValue!"populationSize";
            setValue!"graphPermuteChance";
            setValue!"graphNodesCountMin";
            setValue!"graphNodesCountMax";
            setValue!"graphLinksCountMin";
            setValue!"graphLinksCountMax";
            setValue!"graphPermutesCountMin";
            setValue!"graphPermutesCountMax";
        }
        
        if(root.containsKey(popPathKeyName))
        {
            populationPath = root[popPathKeyName].as!string;
        }
    }
    
    void open(string filename)
    {
        this.filename = filename;
        open(Loader(filename).load);
        
        loadPopulation();
    }
    
    void save(string filename)
    {
        this.filename = filename;
        savePopulation();
        Dumper(filename).dump(dump);
    }
    
    private void savePopulation()
    {
        if(population is null) return;
        
        if(populationPath == "")
        {
            populationPath = population.name~".yaml";
        }
        
        try
        {
            if(!populationPath.dirName.exists)
            {
                mkdirRecurse(populationPath.dirName);
            }
            
            Dumper(populationPath).dump(population.saveYaml);
        } catch(Exception e)
        {
            logger.logError(text("Failed to load population from '", populationPath, "'. Reason: ", e.msg));
            debug logger.logError(e.toString);
            
            population = null;
            popLoaded = true;
        }
    }
    
    private void loadPopulation()
    {
        try
        {
            auto node = Loader(populationPath).load();
            population = GraphPopulation.loadYaml(node);
            popLoaded = true;
        } catch(Exception e)
        {
            logger.logError(text("Failed to load population from '", populationPath, "'. Reason: ", e.msg));
            debug logger.logError(e.toString);
            
            population = null;
            popLoaded = true;
        }
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
        setValue!"populationSize";
        setValue!"graphPermuteChance";
        setValue!"graphNodesCountMin";
        setValue!"graphNodesCountMax";
        setValue!"graphLinksCountMin";
        setValue!"graphLinksCountMax";
        setValue!"graphPermutesCountMin";
        setValue!"graphPermutesCountMax";
            
        return Node([
            projectName    : Node(name),
            evolSettings   : Node(emap),
            popPathKeyName : Node(populationPath)
            ]);
    }
    
    void recreate(string filename)
    {
        programType = new ProgramType();
        name = filename.baseName;
        this.population = null;
        this.filename = filename;
        save(filename);
    }
}