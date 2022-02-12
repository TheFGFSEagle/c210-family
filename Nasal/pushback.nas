var PushbackDialog = {
	new: func {
		var obj = {
			parents: [PushbackDialog, canvas.Window.new([200, 100], "dialog").setTitle("Pushback control")],
			pushbackNode: props.globals.getNode("/sim/model/pushback"),
		};
		
		obj.pushbackActiveNode = obj.pushbackNode.getNode("attached");
		
		obj.c = obj.createCanvas();
		obj.root = obj.c.createGroup();
		obj.layout = canvas.VBoxLayout.new();
		obj.c.setLayout(obj.layout);
		obj.togglePushbackButton = canvas.gui.widgets.Button.new(obj.root, canvas.style, {})
						.setText("Attach pushback")
						.setCheckable(1)
						.setChecked(0);
		obj.togglePushbackButton.listen("toggled", func (event) { obj.togglePushback(event); });
		obj.layout.addItem(obj.togglePushbackButton);
		
		obj.pushbackSpeedSlider = canvas.gui.widgets.Slider.new(obj.root, canvas.style, {});
		obj.pushbackSpeedSlider.listen("value-changed", func (event) { obj.updatePushbackSpeed(event); });
		obj.layout.addItem(obj.pushbackSpeedSlider);
	},
	
	togglePushback: func (event) {
		if (event.detail.checked) {
			me.pushbackActiveNode.setBoolValue(1);
			me.togglePushbackButton.setText("Pushback attached");
		} else {
			me.pushbackActiveNode.setBoolValue(0);
			me.togglePushbackButton.setText("Attach pushback");
		}
	},
	
	updatePushbackSpeed: func (event) {
		
	},
};

var pushbackDialog = nil;

var showPushbackDialog = func {
	if (pushbackDialog == nil) {
		pushbackDialog = PushbackDialog.new();
	}
	pushbackDialog.update();
	pushbackDialog.show();
}
