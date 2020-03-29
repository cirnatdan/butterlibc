//dummy file needed as per https://dlang.org/changelog/2.079.0.html#minimal_runtime
module object;

version (D_LP64)
{
    alias size_t = ulong;
    alias ptrdiff_t = long;
}
else
{
    alias size_t = uint;
    alias ptrdiff_t = int;
}

class TypeInfo {}
