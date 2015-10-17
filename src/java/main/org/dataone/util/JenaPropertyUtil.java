package org.dataone.util;

import com.hp.hpl.jena.rdf.model.Property;

public class JenaPropertyUtil {
	public static Property getType(Property prop) {
		return prop;
	}

	public static String getNameSpace(Property prop) {
		return prop.getNameSpace();
	}
}