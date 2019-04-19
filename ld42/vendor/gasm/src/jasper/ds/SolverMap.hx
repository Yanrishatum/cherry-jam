package jasper.ds;

@:forward(exists, remove, keyValIterator)
abstract SolverMap<K:{},V>(JasperMap<K,V>)
{
    public inline function new() : Void
    {
        this = new JasperMap<K,V>();
    }

    @:arrayAccess
    public inline function get(key:K) : V
    {
        return this.get(key);
    }

    @:arrayAccess
    public inline function arrayWrite(k:K, v:V) : V
    {
        this.set(k, v);
        return v;
    }
}