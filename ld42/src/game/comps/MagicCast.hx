package game.comps;

import hxd.snd.Channel;
import hxd.snd.ChannelGroup;
import hxd.Res;
import msignal.Slot;
import hxd.Key;
import h2d.col.IPoint;
import engine.HScene;
import engine.HXP;
import engine.HComp;
import game.data.MagicRef;

class MagicCast extends HComp
{
  
  public var ref:MagicRef;
  private var overlays:Array<HexOverlay>;
  private var isOk:Bool;
  private var battle:BattleScene;
  
  private var slots:Array<msignal.Slot.AnySlot>;
  private var char:Character;
  
  public function new(battle:BattleScene, owner:Character, ref:MagicRef)
  {
    super();
    this.char = owner;
    this.battle = battle;
    HXP.wrap(this);
    this.ref = ref;
    this.overlays = [new HexOverlay()];
    for (i in 0...ref.extraTiles.length)
    {
      overlays.push(new HexOverlay());
    }
  }
  
  override public function dispose()
  {
    for (o in overlays) o.dispose();
  }
  
  public function spawn():Void
  {
    battle.add(owner);
    battle.spellcast = this;
    startSel();
  }
  
  public function cancel():Void
  {
    stopSel();
    battle.remove(owner);
    battle.spellcast = null;
    dispose();
  }
  
  public function startSel():Void
  {
    var s:HScene = HXP.engine.scene;
    slots = [
    MapHex.onHover.add(onHover),
    MapHex.onOut.add(onOut),
    MapHex.onClick.add(onClick),
    ];
    for (o in overlays)
    {
      o.hide();
      s.add(o.owner);
    }
  }
  
  public function stopSel():Void
  {
    var s:HScene = HXP.engine.scene;
    for (s in slots) s.remove();
    for (o in overlays)
    {
      s.remove(o.owner);
    }
  }
  
  private function onHover(tile:MapHex, _dir:Int):Void
  {
    var overlay:HexOverlay = overlays[overlays.length - 1];
    overlay.setPos(tile, _dir);
    var ok:Int = 0;
    if (!tile.destroyed && tile.type == ref.type)
    {
      overlay.ok();
      ok++;
    }
    else overlay.invalid();
    var off:Int = 0;
    for (dir in ref.extraTiles)
    {
      var pt:IPoint = GridMap.moveCoord(tile.x, tile.y, (dir[0] + _dir) % 6);
      var i:Int = 1;
      while (i < dir.length)
      {
        GridMap.moveCoord(pt.x, pt.y, (dir[i++] + _dir) % 6);
      }
      overlay = overlays[off++];
      overlay.setPosXY(pt.x, pt.y);
      var t:MapHex = GridMap.instance.tile(pt.x, pt.y);
      if (t != null && !t.destroyed && t.type == ref.type)
      {
        overlay.ok();
        ok++;
      }
      else overlay.invalid();
    }
    isOk = ok == overlays.length;
  }
  
  private function onOut(tile:MapHex):Void
  {
    for (o in overlays) o.hide();
  }
  
  private static var sfx:Channel;
  
  private function onClick(tile:MapHex, dir:Int):Void
  {
    if (isOk)
    {
      activate();
      // trace("OK");
    }
    else 
    {
      if (sfx != null && sfx.position < sfx.duration) sfx.position = 0;
      else sfx = Res.sfx.sfx_invalid.play(false, 1, Main.sfxChannel);
    }
  }
  
  private function activate():Void
  {
    for (o in overlays)
    {
      var hex:MapHex = GridMap.instance.tile(o.x, o.y);
      if (ref.extraAction != null) ref.extraAction(hex);
      else hex.destroy();
    }
    
    battle.announcer.show(ref.name);
    battle.ui.resetAtb(false);
    char.casting = ref;
    char.playAnim("cast");
    cancel();
  }
  
  override public function update(delta:Float)
  {
    super.update(delta);
    if (Key.isReleased(Key.MOUSE_RIGHT))
    {
      // stopSel();
      trace("CANCEL");
    }
  }
  
}