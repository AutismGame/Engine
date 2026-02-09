import crypto;
import result;
import packet;

alias RSResult = Result!(Session, Information);
alias RAResult = Result!(Account, Information);

struct Session
{
    Key token;
}

struct Account
{
    ulong accountid;
    Key accountkey;

    RSResult TryNewSession()
    {
        
        
        return new RSResult(Information.ErrorInternal);
    }
}

RAResult TryCreateAccount()
{
    throw new Error("unimplemented");
}