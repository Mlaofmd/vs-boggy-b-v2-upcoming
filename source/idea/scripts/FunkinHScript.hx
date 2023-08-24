package idea.scripts;

import idea.scripts.FunkinLua;
import tea.SScript;

class FunkinHScript extends SScript {
    public var scriptName:String = "";

    public function new(script:String) {
        #if HSCRIPT_ALLOWED
        super(script, false, false);

        scriptName = script;
        trace("hscript loaded succesfully: " + script);

        set("scriptName", script);
        set("this", this);
        set("game", PlayState.instance);

		// just fuckin' psych support
        #if windows
		set("buildTarget", "windows");
		#elseif linux
		set("buildTarget", "linux");
		#elseif mac
		set("buildTarget", "mac");
		#elseif html5
		set("buildTarget", "browser");
		#elseif android
		set("buildTarget", "android");
		#else
		set("buildTarget", "unknown");
		#end

        set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

        set('Function_Stop', FunkinLua.Function_Stop);
		set('Function_Continue', FunkinLua.Function_Continue);
		set('Function_StopLua', FunkinLua.Function_StopLua); //doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', FunkinLua.Function_StopHScript);
		set('Function_StopAll', FunkinLua.Function_StopAll);
    
        set("add", PlayState.instance.add);
		set("addBehindGF", PlayState.instance.addBehindGF);
		set("addBehindDad", PlayState.instance.addBehindDad);
		set("addBehindBF", PlayState.instance.addBehindBF);
		set("insert", PlayState.instance.insert);
		set("remove", PlayState.instance.remove);
        set("luaTrace", FunkinLua.luaTrace);
        #else
        super("", false, false);
        #end
    }

    #if (SScript >= "3.0.3")
	override function destroy() {
		scriptName = null;

		super.destroy();
	}
	#else
	public function destroy() {
		active = false;
	}
	#end
}