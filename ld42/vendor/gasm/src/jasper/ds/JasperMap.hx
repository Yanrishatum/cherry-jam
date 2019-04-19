package jasper.ds;

import haxe.Constraints.IMap;

@:generic
class JasperMap<K:{},V> implements IMap<K, V>
{
    public function new() : Void
    {
        _keys = [];
        _map = new Map();
    }

    public function empty() : Bool
    {
        return _keys.length == 0;
    }

    public inline function exists(key :K) : Bool
    {
        return _map.exists(key);
    }

    public inline function get(key :K) : V
    {
        return _map.get(key);
    }

    public inline function iterator() : JasperIterator<K,V>
    {
        return new JasperIterator(this);
    }

    public inline function keyValIterator() : KeyValIterator<K,V>
    {
        return new KeyValIterator(this);
    }

    public inline function keys() : Iterator<K>
    {
        return _keys.iterator();
    }

    public inline function remove(key :K) : Bool
    {
        return _map.remove(key) && _keys.remove(key);
    }

    public inline function set(key :K, value :V) : Void
    {
        if (!_map.exists(key)) {
            _keys.push(key);
        }
        _map[key] = value;
    }

    public inline function toString() : String
    {
        return _map.toString();
    }

    private var _map :Map<K, V>;
    @:allow(jasper.ds.JasperIterator)
    @:allow(jasper.ds.KeyValIterator)
    private var _keys :Array<K>;
}

@:generic
private class JasperIterator<K:{},V> 
{
    public function new(map :JasperMap<K,V>) 
    {
        _map = map;
    }

    public function hasNext() : Bool 
    {
        return _index < _map._keys.length;
    }

    public function next() : V
    {
        return _map.get(_map._keys[_index++]);
    }

    private var _map : JasperMap<K,V>;
    private var _index : Int = 0;
}

@:generic
private class KeyValIterator<K:{},V> 
{
    public function new(map :JasperMap<K,V>) 
    {
        _map = map;
        _item = {first:null,second:null};
    }

    public function hasNext() : Bool 
    {
        return _index < _map._keys.length;
    }

    public function next() : {first:K,second:V}
    {
        _item.first = _map._keys[_index++];
        _item.second = _map.get(_item.first);
        return _item;
    }

    private var _map : JasperMap<K,V>;
    private var _index : Int = 0;
    private var _item :{first:K,second:V};
}