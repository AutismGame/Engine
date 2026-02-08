import libsodium;

/// libsodium-devel is required for header files.

// i dont know any other libs so ill remain using libsodium

struct Key {
    /**
    * 256 Key Class
    */
    private:
    ulong[4] quads;

    public:
    /**
         * This Constructor method generates a new, unique key.
         */
    Key Hash(Key other) {
        // TODO

        throw new Error("unimplemented");

        return other;
    }

    Key GeneratePublic() {
        // TODO

        throw new Error("unimplemented");

        return this;
    }

    bool Equals(Key other) {
        return (
            this.quads[0] == other.quads[0] &&
            this.quads[1] == other.quads[1] &&
            this.quads[2] == other.quads[2] &&
            this.quads[3] == other.quads[3]
        );
    }

}

Key NewKey() {
    Key newK;

    randombytes_buf(newK.quads.ptr, 32);

    return newK;
}