package gasm.core.components;

import gasm.core.api.singnals.TResize;
import gasm.core.components.LayoutComponent.Align;
import gasm.core.components.LayoutComponent.Constraints;
import gasm.core.components.LayoutComponent.LayoutBox;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;
import gasm.core.enums.EventType;
import gasm.core.enums.ScaleType;
import gasm.core.events.InteractionEvent;
import gasm.core.math.geom.Point;
import gasm.core.utils.Assert;
import gasm.core.utils.Log;
import jasper.Solver;
import jasper.Variable;

class LayoutComponent extends Component {

    public var computedMargins(get, null):Margins;

    public function get_computedMargins():Margins {
        return calculateMargins(layoutBox.margins, parent);
    }

    public var layoutBox(default, null):LayoutBox;
    public var spriteModel(default, null):SpriteModelComponent;
    public var isRoot(default, null):Bool;
    public var freeze(default, default):Bool;
    public var constraints:Constraints;
    public var parent:LayoutComponent;

    var _appModel:AppModelComponent;
    var _computedPadding:Size;
    var _displayDelay:Int;
    var _parentBox:LayoutBox;
    var _children:Array<LayoutComponent>;

    public function new(box:LayoutBox, displayDelay:Int = 0) {
        box.margins = initMargins(box.margins);
        if (box.dock == null) {
            box.dock = Dock.NONE;
        }
        box.flow = box.flow != null ? box.flow : Flow.HORIZONTAL;
        box.vAlign = box.vAlign != null ? box.vAlign : Align.MID;
        box.hAlign = box.hAlign != null ? box.hAlign : Align.MID;
        constraints = {
            x:new Variable("x"),
            y:new Variable("y"),
            containerW:new Variable("containerW"),
            containerH:new Variable("containerH"),
            leftMarg:new Variable('leftMarg'),
            rightMarg:new Variable('rightMarg'),
            topMarg:new Variable('topMarg'),
            bottomMarg:new Variable('bottomMarg'),
            left:new Variable('left'),
            center:new Variable('center'),
            right:new Variable('right'),
            top:new Variable('top'),
            middle:new Variable('middle'),
            bottom:new Variable('bottom'),
            contentW:new Variable('contentW'),
            contentH:new Variable('contentH'),
            ypos:new Variable('ypos'),
            xpos:new Variable('xpos'),
            yMarg:new Variable('yMarg'),
            xMarg:new Variable('xMarg'),
            parentW:new Variable('parentW'),
            parentH:new Variable('parentH'),
            xScale:new Variable('xScale'),
            yScale:new Variable('yScale'),
        };
        layoutBox = box;
        _displayDelay = displayDelay;
        _children = [];
        componentType = ComponentType.Actor;
    }

    override public function init() {
        spriteModel = owner.get(SpriteModelComponent);
        if (spriteModel == null) {
            spriteModel = cast owner.get(TextModelComponent);
            if (spriteModel == null) {
                spriteModel = new SpriteModelComponent();
            }
        }

        _appModel = owner.getFromParents(AppModelComponent);
        Assert.that(_appModel != null, 'No AppModelComponent in graph. Check that your gasm integration context is adding it.');

        parent = owner.parent != null ? owner.parent.getFromParents(LayoutComponent) : null;
        if (parent != null) {
            parent.addChild(this);
            _parentBox = parent.layoutBox;
        } else {
            isRoot = true;
        }

        _appModel.resizeSignal.connect(function(size:TResize) {
            layout();
        });

        spriteModel.addHandler(EventType.RESIZE, onResize);
        layout();

        if (_displayDelay > 0) {
            var visibility = spriteModel.visible;
            spriteModel.visible = false;
            haxe.Timer.delay(function() {
                spriteModel.visible = visibility;
            }, _displayDelay);
        }
    }


    override public function dispose():Void {
        freeze = true;
        spriteModel.dispose();
        _children = null;
        constraints = null;
        parent = null;
        super.dispose();
    }

    /**
    * Perform layout. Will be called automatically on resize events.
    **/
    public function layout() {
        if (freeze) {
            return;
        }
        scale();
    }

    function addChild(child:LayoutComponent) {
        _children.push(child);
        freeze = false;
        layout();
    }

    function scale() {
        if (spriteModel == null) {
            haxe.Timer.delay(layout, 50);
            return;
        }
        var w = layoutBox.scale != null ? spriteModel.origWidth : spriteModel.width;
        var h = layoutBox.scale != null ? spriteModel.origHeight : spriteModel.height;
        var margins = calculateMargins(layoutBox.margins, parent);
        calculatePadding();

        var ypos = 0.0;
        var xpos = 0.0;
        var xMarg = 0.0;
        var yMarg = 0.0;

        var dockedLeft = getDocked(Dock.LEFT);
        var dockedTop = getDocked(Dock.TOP);
        var dockedRight = getDocked(Dock.RIGHT);
        var dockedBottom = getDocked(Dock.BOTTOM);
        var undocked = getDocked(Dock.NONE);
        var allChildren:Array<LayoutComponent> = dockedLeft.concat(dockedRight).concat(dockedTop).concat(dockedBottom).concat(undocked);
        for(comp in allChildren) {
            if(!comp.inited) {
                haxe.Timer.delay(scale, 50);
                return;
            }
        }
        if (!(allChildren.length > 0)) {
            return;
        }
        var parentSize = getComponentSize(parent);
        var size = getComponentSize(this);
        var scale = getComponentScale(this);

        for (layoutComp in dockedTop) {
            var c = layoutComp.constraints;
            var solver = new Solver();
            solver.addConstraint(c.xMarg == xMarg);
            solver.addConstraint(c.yMarg == yMarg);
            solver.addConstraint(c.xpos == xpos);
            solver.addConstraint(c.ypos == ypos);

            solver.addConstraint(c.left == c.leftMarg);
            solver.addConstraint(c.right <= c.containerW - (c.contentW + c.rightMarg));
            solver.addConstraint(c.center == c.left + (c.containerW - (c.contentW + c.leftMarg + c.rightMarg)) / 2);
            solver.addConstraint(c.top == c.ypos + c.topMarg);
            solver.addConstraint(c.bottom == c.ypos + c.containerH - (c.contentH + c.bottomMarg));
            solver.addConstraint(c.middle == c.top + (c.containerH - (c.contentH + c.topMarg + c.bottomMarg)) / 2);
            layoutItem(layoutComp, solver, constraints, size, parentSize, scale, Flow.VERTICAL);
            ypos += c.containerH.m_value + _computedPadding.value;
        }
        for (layoutComp in dockedBottom) {
            var c = layoutComp.constraints;
            var solver = new Solver();
            solver.addConstraint(c.xMarg == xMarg);
            solver.addConstraint(c.yMarg == yMarg);
            solver.addConstraint(c.xpos == xpos);
            solver.addConstraint(c.ypos == ypos);

            solver.addConstraint(c.left == c.leftMarg);
            solver.addConstraint(c.right == c.containerW - (c.contentW + c.rightMarg));
            solver.addConstraint(c.center == c.left + (c.containerW - (c.contentW)) / 2);
            solver.addConstraint(c.top == c.topMarg + c.parentH - (c.containerH));
            solver.addConstraint(c.middle == c.parentH - (c.yMarg + c.containerH - (c.containerH - c.contentH) / 2));
            solver.addConstraint(c.bottom == c.parentH - (c.yMarg + c.containerH - (c.contentH - c.bottomMarg)));
            layoutItem(layoutComp, solver, constraints, size, parentSize, scale, Flow.VERTICAL);
            yMarg += c.containerH.m_value + _computedPadding.value + c.topMarg.m_value + c.bottomMarg.m_value;
        }
        for (layoutComp in dockedLeft) {
            var c = layoutComp.constraints;
            var solver = new Solver();
            solver.addConstraint(c.xMarg == xMarg);
            solver.addConstraint(c.yMarg == yMarg);
            solver.addConstraint(c.xpos == xpos);
            solver.addConstraint(c.ypos == ypos);

            solver.addConstraint(c.left == c.xpos + c.leftMarg);
            solver.addConstraint(c.right <= c.xpos + c.containerW - (c.contentW + c.rightMarg));
            solver.addConstraint(c.center == c.xpos + c.left + (c.containerW - (c.contentW + c.leftMarg + c.rightMarg + c.xpos)) / 2);
            solver.addConstraint(c.top >= c.ypos + c.topMarg);
            solver.addConstraint(c.middle == c.top + (c.containerH - c.contentH) / 2);
            solver.addConstraint(c.bottom <= c.containerH - (c.contentH + c.bottomMarg + c.ypos));
            layoutItem(layoutComp, solver, constraints, size, parentSize, scale, Flow.HORIZONTAL);
            xpos += c.containerW.m_value + _computedPadding.value + c.leftMarg.m_value + c.rightMarg.m_value;
        }
        for (layoutComp in dockedRight) {
            var c = layoutComp.constraints;
            var solver = new Solver();
            solver.addConstraint(c.xMarg == xMarg);
            solver.addConstraint(c.yMarg == yMarg);
            solver.addConstraint(c.xpos == xpos);
            solver.addConstraint(c.ypos == ypos);

            solver.addConstraint(c.left == (c.leftMarg + c.parentW - (c.containerW + c.xMarg)));
            solver.addConstraint(c.right == c.parentW - (c.contentW + c.rightMarg + c.xMarg));
            solver.addConstraint(c.center == c.leftMarg - c.xMarg + c.parentW - c.containerW + ((c.containerW - (c.contentW + c.leftMarg + c.rightMarg)) / 2));
            solver.addConstraint(c.top >= c.ypos + c.topMarg);
            solver.addConstraint(c.middle == c.top + (c.containerH - (c.contentH + c.topMarg + c.bottomMarg)) / 2);
            solver.addConstraint(c.bottom == c.containerH - (c.contentH + c.bottomMarg));
            layoutItem(layoutComp, solver, constraints, size, parentSize, scale, Flow.HORIZONTAL);
            xMarg += c.containerW.m_value + _computedPadding.value + c.leftMarg.m_value + c.rightMarg.m_value;
        }
        //var paddingTotal:Float = (_computedPadding.value * (undocked.length - 1));

        for (layoutComp in undocked) {
            var c = layoutComp.constraints;
            var solver = new Solver();
            solver.addConstraint(c.xMarg == xMarg);
            solver.addConstraint(c.yMarg == yMarg);
            solver.addConstraint(c.xpos == xpos);
            solver.addConstraint(c.ypos == ypos);

            solver.addConstraint(c.left == c.xpos + c.leftMarg);
            solver.addConstraint(c.right <= c.xpos + c.leftMarg + c.parentW - (c.contentW + c.rightMarg + c.leftMarg));
            solver.addConstraint(c.center == c.xpos + c.left + (c.parentW - (c.contentW + c.leftMarg + c.rightMarg)) / 2);
            solver.addConstraint(c.top == c.ypos + c.topMarg);
            solver.addConstraint(c.bottom <= c.ypos + c.containerH - (c.yMarg + c.contentH + c.bottomMarg));
            solver.addConstraint(c.middle == c.ypos + c.top + (c.containerH - (c.contentH + c.bottomMarg + c.topMarg)) / 2);

            layoutItem(layoutComp, solver, constraints, size, parentSize, scale, layoutComp.layoutBox.flow);
            if (layoutBox.flow == Flow.VERTICAL) {
                ypos += c.containerH.m_value + _computedPadding.value;
            } else {
                xpos += c.containerW.m_value + _computedPadding.value + c.leftMarg.m_value + c.rightMarg.m_value;
            }
        }
    }

    function layoutItem(layoutComp:LayoutComponent, solver:Solver, parentConstraints:Constraints, size:Point, parentSize:Point, scale:Point, flow:Flow) {
        if (layoutComp.spriteModel == null) {
            Log.warn('Attempting to layout en element which does not have a sprite model.');
            return;
        }
        var c = layoutComp.constraints;
        if(layoutComp.layoutBox.dimensions != null) {
            layoutComp.spriteModel.origWidth = layoutComp.layoutBox.dimensions.x;
            layoutComp.spriteModel.origHeight = layoutComp.layoutBox.dimensions.y;
        }
        var childBox = layoutComp.layoutBox;
        var childMargins = layoutComp.computedMargins;
        var xMargins = childMargins.right.value + childMargins.left.value;
        var yMargins = childMargins.top.value + childMargins.bottom.value;
        var parentW = constraints.contentW.m_value > 0 ? constraints.contentW.m_value / constraints.xScale.m_value : parentSize.x;
        var parentH = constraints.contentH.m_value > 0 ? constraints.contentH.m_value / constraints.yScale.m_value : parentSize.y;
        solver.addConstraint(c.parentW == parentW);
        solver.addConstraint(c.parentH == parentH);
        solver.addConstraint(c.leftMarg == childMargins.left.value);
        solver.addConstraint(c.rightMarg == childMargins.right.value);
        solver.addConstraint(c.topMarg == childMargins.top.value);
        solver.addConstraint(c.bottomMarg == childMargins.bottom.value);

        var containerW:Float;
        var containerH:Float;
        var hasDimensions = layoutComp.spriteModel.origWidth > 0 && layoutComp.spriteModel.origHeight > 0;
        if (childBox.size == null) {
            if (hasDimensions) {
                switch(flow) {
                    case Flow.VERTICAL:
                        childBox.size = {value:layoutComp.spriteModel.origHeight};
                    case Flow.HORIZONTAL:
                        childBox.size = {value:layoutComp.spriteModel.origWidth};
                }
            }
        }
        if (childBox.size != null) {
            switch(flow) {
                case Flow.VERTICAL:
                    containerW = parentW;
                    if (childBox.size.percent) {
                        containerH = (childBox.size.value * parentH) / 100;
                    } else {
                        containerH = childBox.size.value;
                    }
                case Flow.HORIZONTAL:
                    containerH = parentH;
                    if (childBox.size.percent) {
                        containerW = (childBox.size.value * parentW) / 100;
                    } else {
                        containerW = childBox.size.value;
                    }
                default:
                    containerW = parentW;
                    containerH = parentH;
            }
        } else {
            containerW = parentSize.x;
            containerH = parentSize.y;
        }

        var scaledH:Float;
        var scaledW:Float;
        var xScale:Float = 1.0;
        var yScale:Float = 1.0;
        if (childBox.scale == ScaleType.PROPORTIONAL) {
            var parent:LayoutComponent = layoutComp.owner.getFromParents(LayoutComponent);
            var origW = layoutComp.spriteModel.origWidth > 0 ? layoutComp.spriteModel.origWidth : size.x;
            var origH = layoutComp.spriteModel.origHeight > 0 ? layoutComp.spriteModel.origHeight : size.y;
            var ratio = Math.min((containerW - xMargins) / origW, (containerH - yMargins) / origH);
            scaledW = origW * ratio;
            scaledH = origH * ratio;
            xScale = ratio;
            yScale = ratio;
        } else if (childBox.scale == ScaleType.FIT) {
            scaledW = containerW - xMargins;
            scaledH = containerH - yMargins;
            xScale = (containerW - xMargins) / layoutComp.spriteModel.origWidth;
            yScale = (containerH - yMargins) / layoutComp.spriteModel.origHeight;
        } else if (layoutComp.spriteModel.origWidth > 0 && layoutComp.spriteModel.origHeight > 0) {
            scaledW = layoutComp.spriteModel.origWidth;
            scaledH = layoutComp.spriteModel.origHeight;
        } else {
            scaledW = layoutComp.spriteModel.origWidth = c.contentW.m_value > 0 ? c.contentW.m_value : (containerW - xMargins);
            scaledH = layoutComp.spriteModel.origHeight = c.contentH.m_value > 0 ? c.contentH.m_value : (containerH - yMargins);
        }
        solver.addConstraint(c.xScale == xScale);
        solver.addConstraint(c.yScale == yScale);
        solver.addConstraint(c.contentW == scaledW);
        solver.addConstraint(c.contentH == scaledH);
        solver.addConstraint(c.containerW == containerW);
        solver.addConstraint(c.containerH == containerH);
        switch(childBox.hAlign) {
            case Align.NEAR:
                solver.addConstraint(c.x == c.left);
            case Align.MID:
                solver.addConstraint(c.x == c.center);
            case Align.FAR:
                solver.addConstraint(c.x == c.right);
        }
        switch(childBox.vAlign) {
            case Align.NEAR:
                solver.addConstraint(c.y >= c.top);
            case Align.MID:
                solver.addConstraint(c.y == c.middle);
            case Align.FAR:
                solver.addConstraint(c.y <= c.bottom);
        }
        solver.updateVariables();
        layoutComp.spriteModel.x = c.x.m_value;
        layoutComp.spriteModel.y = c.y.m_value;
        layoutComp.spriteModel.width = scaledW;
        layoutComp.spriteModel.height = scaledH;
        layoutComp.spriteModel.xScale = xScale;
        layoutComp.spriteModel.yScale = yScale;
    }

    inline function getDocked(dock:Dock):Array<LayoutComponent> {
        var a:Array<LayoutComponent> = [];
        for (child in _children) {
            if (child.layoutBox != null && child.layoutBox.dock == dock) {
                a.push(child);
            }
        }
        return a;
    }

    inline function calculateSize(size:Size, parent:LayoutComponent):Float {
        var parentSize = getComponentSize(parent);

        var flow = parent != null && parent.layoutBox != null ? parent.layoutBox.flow : Flow.HORIZONTAL;
        var val = 0.0;
        if (size.percent) {
            var parentDim = flow == Flow.VERTICAL ? parentSize.x : parentSize.y;
            val = parentDim * (size.value / 100);
        } else {
            val = size.value;
        }
        return val;
    }

    inline function calculateMargins(margins:Margins, parent:LayoutComponent):Margins {
        var parentSize = getComponentSize(parent);
        margins = initMargins(margins);
        return {
            bottom: {value:margins.bottom.percent ? parentSize.y * (margins.bottom.value / 100) : margins.bottom.value},
            top: {value:margins.top.percent ? parentSize.y * (margins.top.value / 100) : margins.top.value},
            left: {value:margins.left.percent ? parentSize.x * (margins.left.value / 100) : margins.left.value},
            right: {value:margins.right.percent ? parentSize.x * (margins.right.value / 100) : margins.right.value},
        };
    }

    inline function getComponentSize(layout:LayoutComponent):Point {
        var w = layout != null && !layout.isRoot ? layout.spriteModel.width : _appModel.stageSize.x;
        var h = layout != null && !layout.isRoot ? layout.spriteModel.height : _appModel.stageSize.y;
        if (layout != null) {
            if (layout.layoutBox.size != null) {
                if (layout.layoutBox.flow == Flow.VERTICAL) {
                    if (layout.layoutBox.size.percent) {
                        h = (layout.layoutBox.size.value * h) / 100;
                    } else {
                        h = layout.layoutBox.size.value;
                    }
                } else {
                    if (layout.layoutBox.size.percent) {
                        w = (layout.layoutBox.size.value * w) / 100;
                    } else {
                        w = layout.layoutBox.size.value;
                    }
                }
            }
        }

        return {x:w, y:h};
    }

    inline function getComponentScale(layout:LayoutComponent):Point {
        var x = 1.0;
        var y = 1.0;
        if (layout != null) {
            x = layout.spriteModel.xScale;
            y = layout.spriteModel.yScale;
        }
        return {x:x, y:y};
    }

    inline function calculatePadding() {
        var value:Float;
        if (layoutBox.padding == null) {
            value = 0;
        } else if (layoutBox.padding.percent) {
            value = layoutBox.size.value * (layoutBox.padding.value / 100);
        } else {
            value = layoutBox.padding.value;
        }
        _computedPadding = {value:value};
    }

    inline function initMargins(margins:Margins):Margins {
        if (margins == null) {
            margins = {};
        }
        if (margins.left == null) {
            margins.left = {value:0};
        }
        if (margins.right == null) {
            margins.right = {value:0};
        }
        if (margins.top == null) {
            margins.top = {value:0};
        }
        if (margins.bottom == null) {
            margins.bottom = {value:0};
        }
        return margins;
    }

    inline function onResize(event:InteractionEvent) {
        layout();
    }
}

/**
* Layout definition, used to define layout for a box.
**/
typedef LayoutBox = {
?margins:Margins,
?dock:Dock,
?flow:Flow,
?size:Size,
?scale:ScaleType,
?padding:Size,
?vAlign:Align,
?hAlign:Align,
?name:String,
?dimensions:Point,
}

/**
* Margins definition with sizes for each edge.
**/
typedef Margins = {
?bottom:Size,
?top:Size,
?left:Size,
?right:Size,
}

/**
* Size definition.
**/
typedef Size = {
value:Float,
?percent:Bool,
}

/**
* Constraint variables used to calculate layout
**/
typedef Constraints = {
x:Variable,
y:Variable,
    // Width of container, including margins
containerW:Variable,
    // Height of container, including margins
containerH:Variable,
leftMarg:Variable,
rightMarg:Variable,
topMarg:Variable,
bottomMarg:Variable,
left:Variable,
center:Variable,
right:Variable,
top:Variable,
middle:Variable,
bottom:Variable,
    // Width of content, excluding margins
contentW:Variable,
    // Height of content, excluding margins
contentH:Variable,
ypos:Variable,
xpos:Variable,
yMarg:Variable,
xMarg:Variable,
parentW:Variable,
parentH:Variable,
xScale:Variable,
yScale:Variable,
}

/**
* Can be either near, mid or far. If flow is horizontal, near is left and far is right. If flow is vertical, near is top and far is bottom.
**/
enum Align {
    NEAR; MID; FAR;
}

/**
* Defines if the container should be docked in the parent. A child container can be docked either top, bottom, left or right.
* Containers that is not docked (ContainerDock .NONE), as well as display object that are not containers, will be layed out
* according to flow and alignment values of the parent.
**/
enum Dock {
    LEFT; RIGHT; TOP; BOTTOM; NONE;
}

/**
* Flow defines if children of the container should be laid out vertically or horizontally.
**/
enum Flow {
    VERTICAL; HORIZONTAL;
}