package ld45;

import h3d.scene.RenderContext;
import hxd.Timer;
import hxd.Res;
import h3d.scene.Object;

class TileIcon extends UpdateObject {
  
  var bag:Object;
  var quest:Object;
  
  public function new(parent)
  {
    super(parent);
    bag = Util.loadOutlined(Res.models.item_bag, Res.models.item_bag_outline);
    bag.scale(0.6);
    quest = Util.loadOutlined(Res.models.quest_mark, Res.models.quest_mark_outline);
    quest.scale(1.5);
    // scale(0.6);
    z = 2;
    y = 1;
    addChild(bag);
    addChild(quest);
    quest.visible = false;
    bag.visible = false;
  }
  
  override function sync(ctx:RenderContext)
  {
    super.sync(ctx);
  }
  
  public function show(sbag:Bool, squest:Bool)
  {
    bag.visible = sbag;
    quest.visible = squest;
    if (bag.visible && quest.visible)
    {
      bag.x = -0.5;
      quest.x = 0.5;
    }
    else if (bag.visible || quest.visible)
    {
      bag.x = quest.x = 0;
    }
  }
  
  public function hide()
  {
    quest.visible = false;
    bag.visible = false;
  }
  
  override public function update()
  {
    bag.z = Math.cos(Timer.lastTimeStamp+absPos.tx) * 0.5 + 0.5;
    quest.z = Math.sin(Timer.lastTimeStamp+absPos.tx) * 0.5 - 5.4;
    
  }
  
}