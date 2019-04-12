package gasm.heaps.components;

import hxd.res.Sound;
import gasm.core.Component;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class HeapsSoundComponent extends Component
{
	public var sound(default, default):Sound;
	public function new() 
	{
		type = ComponentType.Sound;
	}
}