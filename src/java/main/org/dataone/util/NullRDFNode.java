package org.dataone.util;

import com.hp.hpl.jena.rdf.model.RDFNode;

/**
 * A temporary class that provides an RDFNode static member that is set to null because
 * Matlab cannot cast to Java classes.
 */
public class NullRDFNode {
	
    public final static RDFNode nullRDFNode = null;

}

