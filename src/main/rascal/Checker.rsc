module Checker

import Syntax;
import ParseTree;
extend analysis::typepal::TypePal;

data AType
  = intType()
  | boolType()
  | charType()
  | stringType()
  | userType(str name)
  ;


data IdRole
  = varId()       
  | typeId()      
  ;


data DefInfo(list[str] fields = []);


public TModel modelFromTree(Tree pt) {
  if (pt has top) pt = pt.top;
  TypePalConfig cfg = tconfig();
  c = newCollector("ALU-checker", pt, cfg);
  collect(pt, c);
  return newSolver(pt, c.run()).run();
}


void collect(current: (Statement) `<ID x> : <Type t>`, Collector c) {
    c.define("<x>", varId(), x, defType(typeFromSyntax(t)));
}


void collect(current: (Statement) `<ID x> : <Type t> = <Expr e>`, Collector c) {
    c.define("<x>", varId(), x, defType(typeFromSyntax(t)));
    c.use(e, { varId() });
}

void collect(current: (Statement) `<ID x> = <Expr e>`, Collector c) {
    c.use(x, { varId() });
    c.use(e, { varId() });
}


void collect(current: (DataDef) `<ID typeName> = data with <IDList fields>`, Collector c) {
    fieldList = [ "<f>" | /<ID f> := fields ];
    dt = defType(userType("<typeName>"));
    dt.fields = fieldList;
    c.define("<typeName>", typeId(), typeName, dt);
}

void collect(current: (Expr) `<ID x>`, Collector c) {
    c.use(x, { varId() });
}


AType typeFromSyntax(Type t) {
  switch (t) {
    case "Int": return intType();
    case "Bool": return boolType();
    case "Char": return charType();
    case "String": return stringType();
    case ID n: return userType("<n>");
  }
}
