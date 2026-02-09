// scary fucking rust code. Result<T, E>. Except that E is basically always RegistryPacket_B0_Info.Information

enum Tag : ubyte {
    Ok,
    Err
};

class Result(T, E) {
    Tag tag;
    
    union {
        T ok;
        E err;
    }
    
    this(T t) {
        this.tag = Tag.Ok;
        this.ok = t;
    }
    
    this(E e) {
        this.tag = Tag.Err;
        this.err = e;
    }

    pragma(inline) bool is_ok() {
        return this.tag == Tag.Ok;
    }
    
    pragma(inline) bool is_err() {
        return this.tag == Tag.Err;   
    }
}
