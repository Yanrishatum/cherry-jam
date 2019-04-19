package gasm.core;
import buddy.BuddySuite;

using buddy.Should;
/**
 * ...
 * @author Leo Bergman
 */
class EntityTest extends BuddySuite {
    public function new() {
        describe("Entity", {
            describe("addChild", {
                it("should return child as added as firstChild when adding single child", {
                    var base = new Entity();
                    var child = new Entity();
                    base.addChild(child);

                    child.should.be(base.firstChild);
                });

                it("should return first child added as firstChild when adding two children", {
                    var base = new Entity();
                    var child = new Entity();
                    var child2 = new Entity();
                    base.addChild(child);
                    base.addChild(child2);

                    child.should.be(base.firstChild);
                });

                it("should return sibling as next when adding two children", {
                    var base = new Entity();
                    var child1 = new Entity();
                    base.addChild(child1);
                    var child2 = new Entity();
                    base.addChild(child2);

                    child2.should.be(child1.next);
                });

                it("should return sibling as parent.firstChild when adding two children", {
                    var base = new Entity();
                    var child1 = new Entity();
                    base.addChild(child1);
                    var child2 = new Entity();
                    base.addChild(child2);

                    child1.should.be(child2.parent.firstChild);
                });
            });

            describe("removeChild", {
                it("should remove added child", {
                    var base = new Entity();
                    var child1 = new Entity();
                    base.addChild(child1);
                    base.removeChild(child1);

                    base.firstChild.should.be(null);
                    child1.parent.should.be(null);
                });
                it("should leave other children be", {
                    var base = new Entity();
                    var child1 = new Entity();
                    var child2 = new Entity();
                    base.addChild(child1);
                    base.addChild(child2);
                    base.removeChild(child1);

                    base.firstChild.should.be(child2);
                    child1.parent.should.be(null);
                });
            });

            describe("disposeChildren", {
                it("should remove children from entity and their reference to parent", {
                    var base = new Entity();
                    var child1 = new Entity();
                    var child2 = new Entity();
                    base.addChild(child1);
                    base.addChild(child2);
                    base.disposeChildren();

                    base.firstChild.should.be(null);
                    child1.parent.should.be(null);
                    child2.parent.should.be(null);
                });

                it("should remain in graph and keep its reference to parent", {
                    var base = new Entity();
                    var child = new Entity();
                    var grandchild = new Entity();
                    base.addChild(child);
                    child.addChild(grandchild);
                    child.disposeChildren();

                    base.firstChild.should.be(child);
                    child.parent.should.be(base);
                    grandchild.parent.should.be(null);
                });
            });

            describe("dispose", {
                it("should remove itself from parent", {
                    var base = new Entity();
                    var child = new Entity();
                    base.addChild(child);
                    child.dispose();

                    child.parent.should.be(null);
                    base.firstChild.should.be(null);
                });

                it("should remove own children", {
                    var base = new Entity();
                    var child = new Entity();
                    var grandchild = new Entity();
                    base.addChild(child);
                    child.addChild(grandchild);

                    child.dispose();

                    child.firstChild.should.be(null);
                    grandchild.parent.should.be(null);
                });
            });
        });
    }
}