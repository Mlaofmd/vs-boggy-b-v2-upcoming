package external.stylesheet;

using StringTools;
class CssSprite {
	public var tag:String = "";
	public var width:Int = 0;
	public var height:Int = 0;
	public var background_position:Array<Int> = [0, 0];

	public function new(css:String) {
		var lines:Array<String> = css.split(";");

		tag = lines[0].substr(1).replace(" {", "").trim();
		lines.shift();

		for (line in lines) {
			var field:String = line.split(":")[0].trim();
			var value:String = line.split(":")[1].replace(";", "").trim();

			if (line != "}" && field.replace(" ", "").length == 0) {
				switch(field) {
					case "width" | "height":
						Reflect.setField(this, field, Std.parseInt(value.replace("px", "")));
					case "background_position":
						var rawPositions:Array<String> = value.replace("px", "").split(" ");
						for (pos in rawPositions)
								background_position.push(Std.parseInt(pos));
				}
			}

            for (i in 0...background_position.length)
                background_position[i] *= -1;

            if (background_position.length > 2)
                background_position = [background_position[0], background_position[1]]; 
		}
	}
}