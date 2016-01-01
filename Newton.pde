
//CREDIT: http://www.ugrad.math.ubc.ca/Flat/newton-code.html
class Newton  {

    double f(double x, double c) {
      return x + 24*log2(x) + c;
    }

    double fprime(double x) {
        return 1 + 24/(x*Math.log(2));
    }
    
    double log2(double x)
    {
      return Math.log(x)/Math.log(2);
    }
    
    /**
     * Newtons method
     * @param c; the constant to feed into f (f is x + 24log(x) + c)
     * @return; x
     */
    double NewtonsMethod(double c)
    {

    double tolerance = .000000001; // Our approximation of zero
    int maxIterations = 1000; // Maximum number of Newton's method iterations
    
    //guess
    double x = 100;
      
    for( int count=1; (Math.abs(f(x,c)) > tolerance) && ( count < maxIterations); count ++) 
    {
      x= x - f(x,c)/fprime(x);
        System.out.println("Step: "+count+" x:"+x+" Value:"+f(x,c));
    }            
    if( Math.abs(f(x,c)) <= tolerance) {
      System.out.println("Zero found at x="+x);
    }
    else
    {
      System.out.println("Failed to find a zero");
    }
    return x;
    }

}