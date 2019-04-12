package gasm.heaps.text;

class ScalingTextField extends h2d.Text {
    public function new(font:h2d.Font, ?parent) {
        super(font, parent);
    }
    public inline function scaleToFit(w:Float) {
        var actualW = getSize().width;
        var baseScale = scaleX;
        while(actualW > w) {
            scale((scaleX/baseScale)*0.997);
            actualW = getSize().width;
        }
    }
}
