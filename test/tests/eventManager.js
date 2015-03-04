describe("Locale.Translator", function() {

	var container, viewport, navigation, item1, item2, item3, content, content2, grid, column, eventManager;
	before(function(){
		eventManager = new Miwo.app.EventManager();
		container = new Miwo.Container();
		viewport = container.add('myViewport', new Miwo.Container({
			xtype: 'viewport',
			isViewport: true,
			title: 'Viewport Application',
			id: 'viewportId'
		}));

		navigation = viewport.add('navigation', new Miwo.Container({
			xtype: 'navigation',
			id: 'navigation',
			isNavigation: true,
			type: 'horizontal'
		}));
		item1 = navigation.add('item1', new Miwo.Component({
			xtype: 'navitem',
			title: 'Item 1',
			type: 'normal'
		}));
		item2 = navigation.add('item2', new Miwo.Component({
			xtype: 'navitem',
			title: 'Item 2',
			type: 'normal'
		}));
		item3 = navigation.add('item3', new Miwo.Component({
			xtype: 'navitem',
			title: 'Item 3',
			type: 'primary'
		}));

		content = viewport.add('content', new Miwo.Container({
			xtype: 'panel'
		}));
		content2 = content.add('content', new Miwo.Container({
			xtype: 'panel',
			id: 'gridPanel'
		}));
		grid = content2.add('grid', new Miwo.Container({
			xtype: 'grid',
			title: 'Grid'
		}));
		column = grid.add('username', new Miwo.Component({
			xtype: 'column',
			label: 'Username',
			id: 'usernameColumn'
		}));
	});

	after(function() {
		eventManager.destroy();
		container.destroy();
	});

	describe("#isMatched(component, selector)", function() {
		it("should match by type", function () {
			expect(eventManager.isMatched(grid, 'grid')).to.equal(true);
		});

		it("should match by name", function () {
			expect(eventManager.isMatched(grid, '.grid')).to.equal(true);
		});

		it("should match by id", function () {
			expect(eventManager.isMatched(column, '#usernameColumn')).to.equal(true);
		});

		it("should match by type and parent type", function () {
			expect(eventManager.isMatched(column, 'grid column')).to.equal(true);
		});

		it("should match by type and parent id", function () {
			expect(eventManager.isMatched(column, '#gridPanel column')).to.equal(true);
		});

		it("should match by 3 times type", function () {
			expect(eventManager.isMatched(column, 'viewport grid column')).to.equal(true);
		});

		it("should match by types with id", function () {
			expect(eventManager.isMatched(column, 'viewport #gridPanel column')).to.equal(true);
		});

		it("should not match by type and parent id", function () {
			expect(eventManager.isMatched(column, '#navigation column')).to.equal(false);
		});

		it("should not match by id", function () {
			expect(eventManager.isMatched(column, '#unknown')).to.equal(false);
		});

		it("should not match xtype and property", function () {
			expect(navigation.is('[isNavigation]')).to.equal(true);
			expect(eventManager.isMatched(navigation, 'viewport [isNavigation]')).to.equal(true);
		});
	});

});