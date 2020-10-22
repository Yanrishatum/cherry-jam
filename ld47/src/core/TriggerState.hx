package core;

import h2d.Text;
import hxd.Res;
import ch2.StencilMask;
import h2d.Tile;
import h2d.Bitmap;
import h2d.RenderContext;
import h2d.Mask;
import h2d.Object;

@:access(core.Trigger)
class TriggerState extends Object {
  
  public var trigger:Trigger;
  
  var bg:Bitmap;
  var low:Bitmap;
  var mid:Bitmap;
  var high:Bitmap;
  var alarm:Bitmap;
  
  public function new(t:Trigger) {
    super();
    this.trigger = t;
    var core = new Object(this);
    bg = new Bitmap(Res.bar_empty.toTile().center(), core);
    low = new Bitmap(Res.bar_red.toTile().center(), core);
    mid = new Bitmap(Res.bar_yellow.toTile().center(), core);
    high = new Bitmap(Res.bar_green.toTile().center(), core);
    core.y = -bg.tile.height - (t.name == 'debris' ? 5 : -3);
    core.x = t.collider.bounds().width / 2;
    this.x = t.x;
    this.y = t.y;
    alarm = new Bitmap(t.once ? Res.alarm_big.toTile().center() : Res.alarm.toTile().center(), core);
    alarm.scale(0.5);
    if (t.name == 'debris') alarm.alpha = 0;
    alarm.x = -bg.tile.width / 2 - 12;
    State.game.root.add(this, State.game.playerLayer + 1);
    
    var name = new Text(R.getFont(24), core);
    // name.y -= bg.tile.height / 2 - name.font.lineHeight;
    name.textAlign = Center;
    name.text = t.name.l();
    var f = new h2d.filter.Outline(1, 0xff000000, 1);
    name.filter = f;
  }
  
  override function sync(ctx:RenderContext)
  {
    var w = trigger.hp / 100 * (bg.tile.width - 9 - 5) + 5;
    var h = bg.tile.height;
    visible = trigger.visible;
    low.tile.setSize(w, h);
    mid.tile.setSize(w, h);
    high.tile.setSize(w, h);
    mid.visible = trigger.hp > 33;
    high.visible = trigger.hp > 66;
    alarm.visible = !mid.visible || trigger.once;
    if (trigger.hp <= 0) {
      if (alarm.scaleX != 0.7) alarm.setScale(0.7);
      var s = Math.sin((hxd.Timer.lastTimeStamp + 1.2) * 10);
      alarm.rotation = s > 0 ? 0.1 : 0;
    }
    else if (alarm.scaleX != 0.5) {
      alarm.setScale(0.5);
      alarm.rotation = 0;
    }
    super.sync(ctx);
  }
  
  
  
}