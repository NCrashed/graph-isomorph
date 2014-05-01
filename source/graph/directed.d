/**
*   Module describes directed graph weighted over strings.
*
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module graph.directed;

import std.range;

/**
*   Generic interface for directed graph. Nodes are marked with
*   strings, edges are marked with strings too.
*/
interface IDirectedGraph
{
    /**
    *   Unpacked graph edge.
    */
    struct Edge
    {
        /// Edge source
        string source;
        /// Edge dist
        string dist;
        /// Edge weight
        string weight;
        
        string toString()
        {
            if(weight == "")
            {
                return source ~ " -> " ~ dist;
            } 
            else
            {
                return source ~ "- " ~ weight ~ " -> " ~ dist;
            }
        }
    }
    alias string Node;
    alias string Weight;
    
    /**
    *   Loading graph from raw data.
    */
    void load(InputRange!Edge input);
    
    /**
    *   Returns graph nodes set
    */
    InputRange!Node nodes();
    
    /**
    *   Returns graph weights set
    */
    InputRange!Weight weights();
    
    /**
    *   Returns graph edges set
    */
    InputRange!Edge edges();
    
    /**
    *   Generates dot description for
    *   visualization.
    */
    string genDot();
}
