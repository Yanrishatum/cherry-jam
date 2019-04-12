package game.comps;

import hxd.Res;
import gasm.heaps.components.HeapsSpriteComponent;
import h2d.Text;
import h2d.Object as Sprite;
import engine.HXP;
import engine.HComp;

class HPAnnouncer extends HComp
{
  
  private var sprite:Sprite;
  
  public function new(amount:Int, x:Float)
  {
    super();
    
    sprite = new Sprite();
    var txt:Text = new Text(GameUI.elmessiriBig, sprite);
    txt.text = (amount > 0 ? ("-" + amount) : ("+" + (-amount)));
    txt.textAlign = Center;
    txt.color.setColor(0xffffffff);
    txt.dropShadow = {dx: 2, dy: 2, color: 0, alpha: 1};
    sprite.x = x;
    sprite.y = 720 - Res.vnbg.getSize().height + 30;
    
    HXP.wrap(this);
    HXP.engine.scene.add(owner);
  }
  
  override public function setup()
  {
    var comp = new HeapsSpriteComponent();
    comp.sprite.addChild(sprite);
    owner.add(comp);
  }
  
  override public function update(delta:Float)
  {
    sprite.y -= delta * 4;
    sprite.alpha -= delta * .5;
    if (sprite.alpha < 0)
    {
      sprite.alpha = 0;
      owner.parent.removeChild(owner);
      owner.dispose();
    }
  }
  
  
}