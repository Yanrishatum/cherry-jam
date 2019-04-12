package gasm.heaps.components;

import gasm.core.Component;
import gasm.heaps.text.ScalingTextField;
import h2d.filter.Glow;
import gasm.core.data.TextConfig;
import h2d.Font;
import h2d.Text;
import hxd.Res;
import gasm.core.components.TextModelComponent;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class HeapsTextComponent extends Component {

    public var textField(default, null):ScalingTextField;

    var _config:TextConfig;
    var _font:h2d.Font;
    var _text:String;
    var _showOutline:Bool;
    var _model:TextModelComponent;
    var _lastW:Float;
    var _lastH:Float;

    public function new(config:TextConfig) {
        _font = cast(config.font, h2d.Font);
        textField = new ScalingTextField(_font);
        var scale = config.size / _font.size;
        textField.scale(scale);
        textField.smooth = true;
        componentType = ComponentType.Text;
        _text = config.text != null ? config.text : '';
        config.scaleToFit = config.scaleToFit == null ? true : config.scaleToFit;
        _config = config;
    }

    override public function init() {
        _model = owner.get(TextModelComponent);
        _model.font = _config.font;
        _model.size = _config.size;
        _model.color = textField.textColor = _config.color;

        textField.text = _model.text = _text;
        textField.textAlign = switch(_config.align) {
            case 'left': Align.Left;
            case 'right': Align.Right;
            default: Align.Center;
        };
        textField.letterSpacing = 1;
        if(_config.filters != null) {
           textField.filter = new h2d.filter.Group(cast _config.filters);
        }
        var w = textField.getSize().width;
        var h = textField.getSize().height;
        if (w > 0) {
            _model.width = w;
            _model.height = h;
        }
        if(_config.scaleToFit){
            textField.scaleToFit(_config.width);
        }
    }

    public function outline(color:Int = 0x000000, alpha:Float = 1.0, quality:Int = 1, passes:Int = 1, sigma:Float = 1.0) {
        var glow = new Glow(color, alpha, quality, passes, sigma);
        textField.filter = glow;
    }

    override public function update(delta:Float) {
        var textChanged = false;
        if (textField.text != _model.text) {
            textField.text = _model.text;
            textChanged = true;
        }
        var formatChanged = false;
        if (_config.font != _model.font || _config.size != _model.size) {
            _config.font = _model.font;
            _config.size = _model.size;
            textField.font = Res.load(_config.font).to(hxd.res.Font).build(_config.size);
            formatChanged = true;
        }
        if (_config.color != _model.color) {
            textField.textColor = _model.color;
        }
        textField.x = _model.x + _model.offsetX;
        textField.y = _model.y + _model.offsetY;
        var w = textField.getBounds().width;
        var h = textField.getBounds().height;
        if (w != _lastW) {
            _model.width = w;
        }
        if (h != _lastH) {
            _model.height = h;
        }
        _lastW = _model.width;
        _lastH = _model.height;
        textField.visible = _model.visible;
        if(textChanged || formatChanged) {
            if(_config.scaleToFit){
                textField.scaleToFit(_model.width);
            }
        }
    }

}