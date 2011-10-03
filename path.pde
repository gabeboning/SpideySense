class Path {
  PVector from, to;
  boolean blocked;
  
  Path(PVector from, PVector to) {
    this.from = from;
    this.blocked = false;
    this.to = to;
  }
  
  float magnitude() {
    return PVector.sub(from,to).mag();
  }
  
  
  
}
