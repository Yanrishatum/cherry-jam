package gasm.core;

import buddy.BuddySuite;
import gasm.core.Entity;
import gasm.core.Component;

using buddy.Should;
/**
 * Integration tests. Makes sense to test Component end Entity together since we want to properly test traversing the graph.
 * So rather than mocking entities in components and components in entities, we have on test for both.
 */
class EntityComponentTest extends BuddySuite {
    public function new() {
        describe("entity-component integration", {
            it("should return component added as firstComponent when adding single component", {
                var base = new Entity();
                var comp = new TestComponent();
                base.add(comp);
                comp.should.be(base.firstComponent);
            });

            it("should return first component added as firstComponent when adding two different components", {
                var base = new Entity();
                // we need to use different classes for different components, since there can only be one of each type.
                var comp1 = new TestComponentA();
                var comp2 = new TestComponentB();
                base.add(comp1);
                base.add(comp2);
                comp1.should.be(base.firstComponent);
            });

            it("should return second component added as firstComponent when adding two identical components", {
                var base = new Entity();
                var comp1 = new TestComponent();
                var comp2 = new TestComponent();
                base.add(comp1);
                base.add(comp2);
                comp2.should.be(base.firstComponent);
            });
            /**
			 * We don't want two classes with same super in one Entity, unless Component is super.
			 * So we should use the class which is one step above Component for resolution.
			 */
            it("should return second component added as firstComponent when adding two components with same super", {
                var base = new Entity();
                var comp1 = new TestComponentExtendsComponentA();
                var comp2 = new TestComponentExtendsComponentB();
                base.add(comp1);
                base.add(comp2);
                comp2.should.be(base.firstComponent);
            });
            /**
			 * If we extend classes with different base classes, they should result in en entity with two components.
			 */
            it("should return first component added as firstComponent when adding two components with different super", {
                var base = new Entity();
                var comp1 = new TestComponentExtendsMockA();
                var comp2 = new TestComponentExtendsMockB();
                base.add(comp1);
                base.add(comp2);
                comp1.should.be(base.firstComponent);
            });

            /**
			 * If we add two components, we should be able to get component B in component A 
			 */
            it("should be able to get sibling component from owner by class", {
                var base = new Entity();
                var comp1 = new TestComponentA();
                var comp2 = new TestComponentB();
                base.add(comp1);
                base.add(comp2);
                comp2.should.be(comp1.owner.get(TestComponentB));
            });

            /**
			 * If we add two components with the same base, they should count as same component type, and second component added should replace first.
			 */
            it("should get itself as component from component B when adding components with same base", {
                var base = new Entity();
                var comp1 = new TestComponentExtendsComponentA();
                var comp2 = new TestComponentExtendsComponentB();
                base.add(comp1);
                base.add(comp2);
                comp2.should.be(comp2.owner.get(TestComponent));
            });

            /**
			 * While resolution is done from the base class above Component, if you do use a subclass as get argument you have to use the same subclass as was added.
			 */
            it("should get null as component A from component B when adding components with same base", {
                var base = new Entity();
                var comp1 = new TestComponentExtendsComponentA();
                var comp2 = new TestComponentExtendsComponentB();
                base.add(comp1);
                base.add(comp2);
                var match = comp2.owner.get(TestComponentExtendsComponentA);
                match.should.be(null);
            });

            /**
			 * If we add two components with the same base, we can use the base type to get the component.
			 */
            it("should get itself as component when added as component A", {
                var base = new Entity();
                var comp1 = new TestComponentExtendsComponentA();
                base.add(comp1);
                comp1.should.be(comp1.owner.get(TestComponent));
            });

            /**
			 * If we add two components with the different base, they should count as different component types.
			 * So when getting comp1 from comp2's owner, it should get a reference to comp1.
			 */
            it("should get component A from component B when adding components with different base", {
                var base = new Entity();
                var comp1 = new TestComponentExtendsMockA();
                var comp2 = new TestComponentExtendsMockB();
                base.add(comp1);
                base.add(comp2);
                comp1.should.be(comp2.owner.get(TestComponentExtendsMockA));
            });

            it("should get component from immediate parent", {
                var base = new Entity();
                var comp1 = new TestComponentA();
                var comp2 = new TestComponentB();
                var child = new Entity();
                base.add(comp1);
                base.addChild(child);
                child.add(comp2);
                comp2.owner.getFromParents(TestComponentA).should.be(comp1);
            });

            it("should not get component from sibling parent", {
                var base = new Entity();
                var child = new Entity();
                var sibling = new Entity();
                var comp1 = new TestComponentA();
                var comp2 = new TestComponentB();
                base.addChild(child);
                base.addChild(sibling);
                sibling.add(comp1);
                child.add(comp2);
                comp2.owner.getFromParents(TestComponentA).should.be(null);
            });

            it("should get component from grandparent", {
                var base = new Entity();
                var child = new Entity();
                var grandchild = new Entity();
                var comp1 = new TestComponentA();
                var comp2 = new TestComponentB();
                base.addChild(child);
                child.addChild(grandchild);
                base.add(comp1);
                grandchild.add(comp2);
                comp2.owner.getFromParents(TestComponentA).should.be(comp1);
            });

            it("should get component from root", {
                var root = new Entity();
                var base = new Entity();
                var child = new Entity();
                var grandchild = new Entity();
                var comp1 = new TestComponentA();
                var comp2 = new TestComponentB();
                root.addChild(base);
                base.addChild(child);
                child.addChild(grandchild);
                root.add(comp1);
                base.add(comp2);
                grandchild.getFromRoot(TestComponentA).should.be(comp1);
            });

            it("should get component from one level up from root", {
                var root = new Entity();
                var base = new Entity();
                var child = new Entity();
                var grandchild = new Entity();
                var comp1 = new TestComponentA();
                var comp2 = new TestComponentB();
                root.addChild(base);
                base.addChild(child);
                child.addChild(grandchild);
                base.add(comp1);
                child.add(comp2);
                grandchild.getFromRoot(TestComponentA).should.be(comp1);
            });

            it("should get component in self from root", {
                var root = new Entity();
                var base = new Entity();
                var child = new Entity();
                var comp1 = new TestComponentA();
                root.addChild(base);
                base.addChild(child);
                child.add(comp1);
                child.getFromRoot(TestComponentA).should.be(comp1);
            });
        });
    }
}

class TestComponent extends Component {
    public function new() {

    }
}

class TestComponentA extends Component {
    public function new() {

    }
}

class TestComponentB extends Component {
    public function new() {

    }
}

class TestComponentExtendsComponentA extends TestComponent {

}

class TestComponentExtendsComponentB extends TestComponent {

}

class TestComponentExtendsMockA extends TestComponentA {

}

class TestComponentExtendsMockB extends TestComponentB {

}