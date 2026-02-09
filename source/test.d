// Module for placeholder code that helps implementing a new feature
import std.stdio;

void RunAllTests() {
    printf("! [0;32mRunning Tests[0;37m\n");

    ResultTypeTest();

    printf("! [0;32mTests ran[0;37m\n");
}

void ResultTypeTest() {
    import result;
    
    class A {} // Ok type
    class B {} // Err type
    
    alias AB_Result = Result!(A,B); // Ok, Error

    A a = new A();
    B b = new B();
    
    AB_Result r1 = new AB_Result(a);
    
    assert( r1.is_ok());
    assert(!r1.is_err());

    AB_Result r2 = new AB_Result(b);

    assert(!r2.is_ok());
    assert( r2.is_err());
}