package jasper.ds;

@:forward(remove, exists, keys, empty, keyValIterator)
abstract FloatMap<K:{}>(JasperMap<K, Float>)
{
    public inline function new() : Void
    {
        this = new JasperMap<K, Float>();
    }

    @:arrayAccess
    public inline function get(key:K) : Float
    {
        return this.exists(key) ? this.get(key) : 0;
    }

    @:arrayAccess
    public inline function arrayWrite(k:K, v:Float) : Float
    {
        this.set(k, v);
        return v;
    }
}