import crypto;

struct Session {
    Key token;
}

struct Account {
    ulong accountid;
    Key accountkey;
    
    Session TryNewSession() {
        throw new Error("unimplemented");
    }
}

Account TryCreateAccount() {
    throw new Error("unimplemented");
}