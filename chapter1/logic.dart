abstract class Formula {
  bool Evaluate();
  List Variables();
  Formula ToNnf();
  Formula ToCnf();

  Formula DistributeCnf(Formula p, Formula q) {
    if (p is And) {
      return new And(
          DistributeCnf((p as And).P, q), DistributeCnf((p as And).Q, q));
    }

    if (q is And) {
      return new And(
          DistributeCnf(p, (q as And).P), DistributeCnf(p, (q as And).Q));
    }
  }
}

class Variable extends Formula {
  bool Value;
  Variable(this.Value);

  @override
  bool Evaluate() {
    return this.Value;
  }

  @override
  List Variables() {
    return [this];
  }

  @override
  Formula ToNnf() {
    return this;
  }

  @override
  Formula ToCnf() {
    return this;
  }
}

abstract class BinaryGate extends Formula {
  Formula P;
  Formula Q;

  List Variables() {
    return new List.from(P.Variables())..addAll(Q.Variables());
  }
}

class And extends BinaryGate {
  And(Formula p, Formula q) {
    this.P = p;
    this.Q = q;
  }

  @override
  bool Evaluate() {
    return P.Evaluate() && Q.Evaluate();
  }

  @override
  Formula ToNnf() {
    return new And(P.ToNnf(), Q.ToNnf());
  }

  @override
  Formula ToCnf() {
    return new And(P.ToNnf(), Q.ToNnf());
  }
}

class Or extends BinaryGate {
  Or(Formula p, Formula q) {
    this.P = p;
    this.Q = q;
  }

  @override
  bool Evaluate() {
    return P.Evaluate() || Q.Evaluate();
  }

  @override
  Formula ToNnf() {
    return new Or(P.ToNnf(), Q.ToNnf());
  }

  @override
  Formula ToCnf() {
    return DistributeCnf(P.ToCnf(), Q.ToCnf());
  }
}

class Not extends BinaryGate {
  Not(Formula p) {
    this.P = p;
  }

  @override
  bool Evaluate() {
    return !P.Evaluate();
  }

  @override
  Formula ToNnf() {
    switch (P.runtimeType) {
      case And:
        {
          return new Or(new Not(P as And).P, new Not(P as And).Q);
        }
        break;
      case Or:
        {
          return new And(new Not((P as Or).P), new Not((P as Or).Q));
        }
        break;
      case Not:
        {
          return new And(new Not((P as Or).P), new Not((P as Or).Q));
        }
        break;
      default:
        {
          return this;
        }
        break;
    }
  }

  @override
  Formula ToCnf() {
    return this;
  }
}

class BinaryDecisionTree {
  BinaryDecisionTree RightTree;
  BinaryDecisionTree LeftTree;
  int Value;

  BinaryDecisionTree() {}
  BinaryDecisionTree.fromValue(this.Value) {}
  BinaryDecisionTree.fromTrees(
      this.Value, BinaryDecisionTree newRight, BinaryDecisionTree newLeft) {
    this.RightTree = newRight;
    this.LeftTree = newLeft;
  }
}

BinaryDecisionTree TreeBuilder(
    Formula f, List<Variable> variables, int varIndex, String path) {
  path ??= "";
  if (path != "") {
    variables[(varIndex - 1)].Value = path[(path.length - 1)] != 0;
  }

  if (varIndex == variables.length) {
    if (f.Evaluate()) {
      return BinaryDecisionTree.fromValue(1);
    } else {
      return BinaryDecisionTree.fromValue(0);
    }
  }
  return BinaryDecisionTree.fromTrees(
      varIndex,
      TreeBuilder(f, variables, varIndex + 1, path + "0"),
      TreeBuilder(f, variables, varIndex + 1, path + "1"));
}

void main() {
  Variable x = Variable(true);
  Variable y = Variable(false);

  And andtest = And(x, y);
  Or ortest = Or(x, y);
  Not notTest = Not(x);

  print("Binary Gate results");
  print(andtest.Evaluate());
  print(ortest.Evaluate());
  print(notTest.Evaluate());

  print("BinaryDesicionTree results");
  print(andtest.ToNnf());
}
