package game.comps;

import hxd.Cursor;
import hxd.snd.Channel;
import hxd.Event;
import engine.Locale;
import h2d.RenderContext;
import hxd.Key;
import h2d.Interactive;
import h2d.Bitmap;
import h3d.mat.Texture;
import hxd.Res;
import h2d.Tile;
import h2d.Flow;
import hxd.res.DefaultFont;
import h2d.Font;
import h2d.Mask;
import h2d.Text;
import h2d.Object as Sprite;
import engine.HXP;
import engine.HComp;

class GameUI extends HComp
{
  
  
  public static var texture:Texture;
  public static function tile(x:Int, y:Int, w:Int, h:Int):Tile
  {
    return @:privateAccess new Tile(texture, x, y, w, h);
  }
  
  public static function init_base():Void
  {
    
    elmessiriBig = Res.el_messiri_regular_22.toFont();
    elmessiriSmall = Res.el_messiri_regular_12.toFont();
    elmessiri20 = Res.el_messiri_regular_20.toFont();
    elmessiri14 = Res.el_messiri_regular_14.toFont();
    
    texture = Res.ui.toTexture();
  }
  
  public static var elmessiriBig:Font;
  public static var elmessiriSmall:Font;
  public static var elmessiri20:Font;
  public static var elmessiri14:Font;
  public static inline var color:Int = 0xff51110a;
  
  private var leftUI:h2d.Bitmap;
  private var centerUI:h2d.Bitmap;
  private var rightUI:h2d.Bitmap;
  
  private var charUI:Array<CharUI>;
  
  private var sprite:Sprite;
  private var battle:BattleScene;
  
  private var attack:TextButton;
  private var magic:TextButton;
  private var other:TextButton;
  
  private var menu:Int;
  
  private var switch2:Bitmap;
  
  private var spells:Array<TextButton>;
  
  private var help:Interactive;
  private var settings:SettingsWindow;
  
  public function new(battle:BattleScene)
  {
    super();
    this.battle = battle;
    sprite = new Sprite();
    menu = 0;
    
    leftUI = new h2d.Bitmap(tile(0, 0, 350, 165), sprite);
    centerUI = new h2d.Bitmap(tile(350, 0, 126, 165), sprite);
    centerUI.x = 350;
    rightUI = new h2d.Bitmap(tile(350+126, 0, 348, 165), sprite);
    rightUI.x = 350+126;
    
    var btm = new h2d.Bitmap(Res.ui_violette.toTile(), sprite);
    btm.y = 12+3;
    btm.x = rightUI.x + 360-8;
    
    var f:Flow = new Flow(centerUI);
    f.y = 40-6;
    f.x = 14;
    f.layout = Vertical;
    attack = new TextButton("Attack", 98, f);
    magic = new TextButton("Magic", 98, f);
    other = new TextButton("Guard", 98, f);
    attack.onClick = whackClick;
    magic.onClick = magicClick;
    other.onClick = defClick;
    
    f = new Flow(rightUI);
    f.y = 26;
    f.x = 18;
    f.verticalSpacing = -2;
    f.layout = Vertical;
    spells = new Array();
    for (i in 0...4)
    {
      var txt:TextButton = new TextButton("", "", 300, f);
      txt.onClick = ((j:Int) -> magicCastClick.bind(j))(i);
      spells.push(txt);
    }
    
    switch2 = new Bitmap(GameUI.tile(295, 168, 19, 20), sprite);
    switch2.x = 469 - 25; // 35, 70, 70+35
    switch2.y = 70;
    
    var halp:Interactive = new Interactive(51, 51, sprite);
    halp.addChild(new Bitmap(Res.btn_help.toTile()));
    halp.x = 1280 - 51 - 5;
    halp.y = 5;
    halp.onClick = showHelp;
    
    var bsettings:Interactive = new Interactive(51, 51, sprite);
    bsettings.addChild(new Bitmap(Res.btn_settings.toTile()));
    bsettings.x = 1280 - 51 - 5 - 51 - 5;
    bsettings.y = 5;
    bsettings.onClick = showSettings;
    
    help = new Interactive(620, 580);
    help.cursor = Cursor.Default;
    help.visible = false;
    help.addChild(new Bitmap(Res.tutorial.toTile()));
    var helpClose:Interactive = new Interactive(40, 40, help);
    helpClose.onClick = showHelp;
    helpClose.x = 572;
    helpClose.y = 8;
    help.x = (1280 - 620) / 2;
    help.y = (720 - 580) / 2;
    
    sprite.y = 720 - 165;
    halp.y -= sprite.y;
    bsettings.y -= sprite.y;
    help.y -= sprite.y;
    
    charUI = new Array();
    HXP.wrap(this);
  }
  
  override public function init()
  {
    sprite.addChild(help);
    // sprite.addChild(settings);
  }
  
  private function showSettings(e:Event)
  {
    click();
    if (settings != null && settings.parent != null)
    {
      settings.remove();
      settings = null;
    }
    else 
    {
      settings = new SettingsWindow(sprite);
      settings.y -= sprite.y;
    }
  }
  
  private function showHelp(e:Event)
  {
    click();
    help.visible = !help.visible;
  }
  
  private static var _bleep:Channel;
  public static inline function bleep(alt:Bool = false):Void
  {/*
    if (_bleep != null && _bleep.position < _bleep.duration) _bleep.position = 0;
    else*/
    if (alt)  Res.sfx.sfx_atb.play(false, 0.2, Main.sfxChannel);
    else Res.sfx.sfx_cursor_move.play(false, 0.05, Main.sfxChannel);
  }
  
  private static var sfx:Channel;
  public static inline function click():Void
  {/*
    if (sfx != null && sfx.position < sfx.duration) sfx.position = 0;
    else sfx = */Res.sfx.sfx_cursor_click.play(false, 0.2, Main.sfxChannel);
  }
  
  private function magicCastClick(idx:Int, e:Event):Void
  {
    if (e.button != Key.MOUSE_LEFT) return;
    click();
    var char:Character = findChar();
    if (battle.spellcast != null)
    {
      if (battle.spellcast.ref == char.spells[idx]) return;
      battle.spellcast.cancel();
    }
    
    var caster:MagicCast = new MagicCast(battle, char, char.spells[idx]);
    caster.spawn();
    menu++;
  }
  
  
  private function whackClick(e:Event):Void
  {
    if (e.button != Key.MOUSE_LEFT) return;
    // click();
    Res.sfx.sfx_whack.play(false, 0.2, Main.sfxChannel);
    if (battle.spellcast != null)
    {
      battle.spellcast.cancel();
      menu--;
    }
    if (menu == 2)
    {
      menu--;
      return;
    }
    var char:Character = resetAtb();
    char.playAnim("attack");
    battle.boss.damage(char.attack);
  }
  
  private function magicClick(e:Event):Void
  {
    if (e.button != Key.MOUSE_LEFT) return;
    click();
    if (battle.spellcast != null)
    {
      battle.spellcast.cancel();
      menu--;
    }
    if (menu == 2)
    {
      menu--;
      return;
    }
    menu = 2;
    var char:Character = findChar();
    for ( i in 0...4)
    {
      spells[i].setText(char.spells[i].name, char.spells[i].cost);
    }
  }
  
  
  private function defClick(e:Event):Void
  {
    if (e.button != Key.MOUSE_LEFT) return;
    click();
    if (battle.spellcast != null)
    {
      battle.spellcast.cancel();
      menu--;
    }
    if (menu == 2)
    {
      menu--;
      return;
    }
    resetAtb().defending = true;
  }
  
  private function findChar():Character
  {
    for (char in battle.chars)
    {
      if (char.atb == 1) return char;
    }
    return null;
  }
  
  public function resetAtb(enableUpdate:Bool = true):Character
  {
    for (char in battle.chars)
    {
      if (char.atb == 1)
      {
        char.atb = 0;
        menu = 0;
        if (enableUpdate)
          battle.updateAtb = true;
        return char;
      }
    }
    return null;
  }
  
  public function addChar(char:Character):Void
  {
    if (char.cname == "Violette")
    {
      var ui = new CharUI(this, char, sprite, 0);
      ui.x = rightUI.x + rightUI.getSize().width + 20;
      ui.y += 3;
      this.charUI.push(ui);
    }
    else
    {
      this.charUI.push(new CharUI(this, char, sprite, charUI.length));
    }
  }
  
  override public function setup()
  {
    var s:Sprite = new Sprite();
    s.addChild(sprite);
    owner.add(new gasm.heaps.components.HeapsSpriteComponent(s, false, false));
  }
  
  override public function update(delta:Float)
  {
    for (ui in charUI)
    {
      if (ui.update() && ui.char.cname != "Violette")
      {
        if (menu == 0)
        {
          bleep(true);
          menu = 1;
        }
        else if (menu >= 2 && Key.isReleased(Key.MOUSE_RIGHT))
        {
          if (battle.spellcast != null)
          {
            battle.spellcast.cancel();
          }
          menu--;
        }
      }
    }
    centerUI.visible = menu > 0;
    rightUI.visible = menu > 1;
    switch2.visible = menu > 1;
  }
  
}

class CharUI extends Sprite
{
  
  private var ui:GameUI;
  public var char:Character;
  
  private var nameT:Text;
  private var hp:Text;
  private var hpMask:Mask;
  private var atbMask:Mask;
  
  private static inline var maskSize:Int = 189;
  
  private static var SLOTS:Array<Int> = [0, 35, 36+35, 35+71];
  private static var SLOTS_ATB:Array<Int> = [0, 1, 4, 4];
  
  public var slot:Int;
  
  private var icon:Bitmap;
  
  public function new (ui:GameUI, char:Character, ?parent:Sprite, slot:Int)
  {
    super(parent);
    this.slot = slot;
    this.ui = ui;
    this.x = 30;
    this.y = SLOTS[slot] + 29;
    this.char = char;
    
    var tile:Tile = GameUI.tile(103, 169, maskSize, 16);
    
    hpMask = new Mask(tile.iwidth, tile.iheight, this);
    hpMask.setPosition(89, 2);
    new h2d.Bitmap(tile, hpMask);
    
    tile = GameUI.tile(102, 192, maskSize, 5);
    atbMask = new Mask(tile.iwidth, tile.iheight, this);
    atbMask.setPosition(89, 25 + SLOTS_ATB[slot]);
    new h2d.Bitmap(tile, atbMask);
    
    nameT = new Text(GameUI.elmessiriBig, this);
    nameT.maxWidth = 84;
    nameT.textAlign = Align.Center;
    nameT.setPosition(0, -4);
    nameT.text = Locale.get(char.cname);
    nameT.color.setColor(GameUI.color);
    nameT.y += 5;
    hp = new Text(GameUI.elmessiriSmall, this);
    var w:Float = hp.calcTextWidth("9999/9999");
    hp.maxWidth = w;
    hp.textAlign = Align.Center;
    hp.setPosition(89 + (maskSize - w) / 2, 4);
    hp.color.setColor(GameUI.color);
    
    icon = new Bitmap(GameUI.tile(295, 168, 19, 20), this);
    icon.x = maskSize + hpMask.x + 4;
    icon.y += 5;
  }
  
  public function update():Bool
  {
    hp.text = Math.ceil(char.hp) + "/" + char.hpMax;
    hpMask.width = Math.ceil((char.hp / char.hpMax) * maskSize);
    
    atbMask.width = Math.ceil((char.atb) * maskSize);
    
    return icon.visible = char.atb == 1;
  }
  
}

class TextButton extends Interactive
{
  
  private var curs:Tile;
  private var text:Text;
  private var cost:Text;
  
  public function new(text:String, ?right:String, w:Int, ?parent:Sprite)
  {
    super(w, 30, parent);
    var t:Text = this.text = new Text(right != null ? GameUI.elmessiri20 : GameUI.elmessiriBig, this);
    if (text != "") t.text = Locale.get(text);
    else t.text = "stub";
    t.color.setColor(GameUI.color);
    if (right != null)
    {
      cost = new Text(GameUI.elmessiri14, this);
      cost.color.setColor(GameUI.color);
      if (right != "") cost.text = Locale.get(right);
      else cost.text = "stub";
      cost.textAlign = Align.Right;
      cost.maxWidth = w;
      cost.y = (t.textHeight - cost.textHeight) / 2;
      t.x = 20;
    }
    else 
    {
      t.maxWidth = w;
      t.textAlign = Align.Center;
    }
    
    // t.x = 0;
    curs = GameUI.tile(295, 168, 19, 20);
    // curs.dx = Std.int((w - t.textWidth) / 2 - 19);
    curs.dy = 3;
  }
  
  public function setText(left:String, right:String):Void
  {
    text.text = Locale.get(left);
    cost.text = Locale.get(right);
  }
  
  override private function draw(ctx:RenderContext)
  {
    super.draw(ctx);
    if (isOver()) emitTile(ctx, curs);
  }
  
  override public function handleEvent(e:Event)
  {
    super.handleEvent(e);
    if (e.kind == EventKind.EOver) GameUI.bleep();
  }
  
}