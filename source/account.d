import crypto;

struct Session {
    Key token;
}

struct Account {
    ulong accountid;
    Key accountkey;
    
    Session TryNewSession() {
        
    }
}

Account TryCreateAccount() {
    
}