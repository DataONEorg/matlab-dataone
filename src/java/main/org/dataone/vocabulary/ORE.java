/**
 * This work was created by participants in the DataONE project, and is
 * jointly copyrighted by participating institutions in DataONE. For 
 * more information on DataONE, see our web site at http://dataone.org.
 *
 *   Copyright 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and 
 * limitations under the License.
 * 
 */

package org.dataone.vocabulary;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.List;

import org.dspace.foresite.Predicate;

import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.ResourceFactory;

/**
 * Provides select static terms for the ORE ontology used in ProvONE constructs
 * 
 */
public class ORE {

    public static final String namespace = "http://www.openarchives.org/ore/terms/";
    
    public static final String prefix = "ore";

    /** Classes defined in ORE (ProvONE-relevant subset) */
    public static final List<String> classes = Arrays.asList(
            "Aggregation",
            "AggregatedResource",
            "Proxy",
            "ResourceMap");
    
    /* Object properties defined in PROV (ProvONE-relevant subset) */
    public static final List<String> properties = Arrays.asList(
            "aggregates",           
            "isAggregatedBy",
            "describes",
            "isDescribedBy",
            "lineage",
            "proxyFor",
            "proxyIn",
            "similarTo");
    
    public static final Resource Aggregation          = resource("Aggregation");
    public static final Resource AggregatedResource   = resource("AggregatedResource");
    public static final Resource Proxy                = resource("Proxy");
    public static final Resource ResourceMap          = resource("ResourceMap");

    public static final Property aggregates     = property("aggregates");    
    public static final Property isAggregatedBy = property("isAggregatedBy");
    public static final Property describes      = property("describes");
    public static final Property isDescribedBy  = property("isDescribedBy");
    public static final Property lineage        = property("lineage");
    public static final Property proxyFor       = property("proxyFor");
    public static final Property proxyIn        = property("proxyIn");
    public static final Property similarTo      = property("similarTo");

    /**
     * For a given ORE property string, return a Predicate object with the URI, namespace,
     * and prefix fields set to the default values.
     * 
     * @param property  The name of the ORE object property to use as a Predicate
     * @return  The Predicate instance using the given property
     * 
     * @throws IllegalArgumentException
     * @throws URISyntaxException
     */
    public static Predicate predicate(String property) 
            throws IllegalArgumentException, URISyntaxException {
        
        if ( ! properties.contains(property) ) {
           throw new IllegalArgumentException("The given argument: " + property +
                   " is not an ORE property. Please use one of the follwing to " +
                   "create a Predicate: " + Arrays.toString(properties.toArray())); 
        }
        
        Predicate predicate = new Predicate();
        predicate.setPrefix(prefix);
        predicate.setName(property);
        predicate.setNamespace(namespace);
        predicate.setURI(new URI(namespace + property));
        
        return predicate;
        
    }
    
    /**
     * Return a Jena Resource instance for the given localName term
     * 
     * @param localName
     * @return  resource  The Resource for the term
     */
    protected static Resource resource(String localName) {
        return ResourceFactory.createResource(namespace + localName);
        
    }

    /**
     * Return a Jena Property instance for the given localName term
     * 
     * @param localName
     * @return  property  The Property for the term
     */
    protected static Property property(String localName) {
        return ResourceFactory.createProperty(namespace, localName);
        
    }


}

