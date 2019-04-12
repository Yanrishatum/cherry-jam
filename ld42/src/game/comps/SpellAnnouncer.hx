package game.comps;

import engine.Locale;
import gasm.heaps.components.HeapsSpriteComponent;
import h2d.Text;
import h2d.Object as Sprite;
import h2d.Tile;
import hxd.Res;
import engine.HXP;
import engine.HComp;
import game.data.MagicRef;

class SpellAnnouncer extends HComp
{
  
  private var sprite:Sprite;
  private var text:Text;
  private var w:Int;
  
  private var timer:Float;
  
  public function new()
  {
    
    super();
    HXP.wrap(this);
  }
  
  override public function setup()
  {
    var bg = Res.castbg.toTile();
    sprite = new Sprite();
    new h2d.Bitmap(bg, sprite);
    text = new Text(GameUI.elmessiriBig, sprite);
    text.color.setColor(GameUI.color);
    text.maxWidth = bg.width;
    text.textAlign = Align.Center;
    text.y = (bg.height - 24) / 2;
    w = bg.iwidth;
    
    var comp:HeapsSpriteComponent = new HeapsSpriteComponent();
    owner.add(comp);
    comp.sprite.addChild(sprite);
    sprite.visible = false;
  }
  
  public function show(text:String):Void
  {
    sprite.visible = true;
    sprite.alpha = 0;
    timer = 2;
    sprite.x = (hxd.Window.getInstance().width - w) / 2;
    this.text.text = Locale.get(text);
  }
  
  override public function update(delta:Float)
  {
    if (timer > 0)
    {
      if (sprite.alpha < 1)
      {
        sprite.alpha += delta * 4;
        if (sprite.alpha > 1) sprite.alpha = 1;
      }
      timer -= delta;
      if (timer < 0)
      {
        timer = 0;
      }
    }
    else if (sprite.visible)
    {
      sprite.alpha -= delta * 4;
      if (sprite.alpha <= 0)
      {
        sprite.alpha = 0;
        sprite.visible = false;
      }
    }
  }
  
}