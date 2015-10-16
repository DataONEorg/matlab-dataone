package org.dataone.util;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

import org.dataone.service.types.v1.Identifier;

/**
 * A temporary wrapper class to HashMap<Identifier, List<Identifier>>
 * that does not require support for Java Generic typing.
 **/
public class HashmapWrapper extends HashMap<Identifier, List<Identifier>> {}
