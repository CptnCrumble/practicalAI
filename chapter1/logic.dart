abstract class Formula {
  bool Evaluate();
  List Variables();
}

class Variable extends Formula{
  bool Value;
  Variable(this.Value);
  
  @override bool Evaluate(){
    return this.Value;
  }

  @override List Variables() {
    return [this];
  }

}

abstract class BinaryGate extends Formula {
  Formula P;
  Formula Q; 

  List Variables() {    
    return  new List.from(P.Variables())..addAll(Q.Variables());
  }
}

class And extends BinaryGate {
  And(Formula p, Formula q){
    this.P = p;
    this.Q = q;
  }

  @override bool Evaluate() {
    return P.Evaluate() && Q.Evaluate();
  }
}

class Or extends BinaryGate {
  Or(Formula p, Formula q){
    this.P = p;
    this.Q = q;
  }

  @override bool Evaluate() {
    return P.Evaluate() || Q.Evaluate();
  }
}

class Not extends BinaryGate {
  Not(Formula p, Formula q){
    this.P = p;
    this.Q = q;
  }

  @override bool Evaluate(){
    return P.Evaluate() != Q.Evaluate();
  }
}


void main(){
  Formula x = 
}

