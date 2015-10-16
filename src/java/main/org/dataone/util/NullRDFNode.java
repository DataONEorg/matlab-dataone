package org.dataone.util;

import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.Set;

import org.dspace.foresite.Predicate;

import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.graph.Triple;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.sparql.util.Base64.InputStream;
import com.hp.hpl.jena.util.FileManager;

/**
 * A temporary class that provides an RDFNode static member that is set to null because
 * Matlab cannot cast to Java classes.
 */
public class NullRDFNode {
	
    public final static RDFNode nullRDFNode = null;

}

