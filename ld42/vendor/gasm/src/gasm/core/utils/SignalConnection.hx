package gasm.core.utils;

import gasm.core.api.IDisposable;

/**
 * Represents a connected signal listener.
 */
class SignalConnection implements IDisposable {
    /**
     * True if the listener will remain connected after being used.
     */
    public var stayInList (default, null):Bool;

    @:allow(gasm) function new(signal:SignalBase, listener:Dynamic) {
        _signal = signal;
        _listener = listener;
        stayInList = true;
    }

    /**
     * Tells the connection to dispose itself after being used once.
     * @returns This instance, for chaining.
     */
    public function once() {
        stayInList = false;
        return this;
    }

    /**
     * Disconnects the listener from the signal.
     */
    public function dispose() {
        if (_signal != null) {
            _signal.disconnect(this);
            _signal = null;
        }
    }

    @:allow(gasm) var _next:SignalConnection = null;

    @:allow(gasm) var _listener:Dynamic;
    private var _signal:SignalBase;
}
