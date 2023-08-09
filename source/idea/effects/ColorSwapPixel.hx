package idea.effects;

import flixel.system.FlxAssets.FlxShader;

class ColorSwapPixel {
    public var shader:ColorSwapPixelShader = new ColorSwapPixelShader();
    public var hue(default, set):Float = 0;
    public var saturation(default, set):Float = 0;
    public var brightness(default, set):Float = 0;

    public function set_hue(value:Float):Float {
        hue = value;
        shader.data.hue.value = [value];
        return value;
    }

    public function set_saturation(value:Float):Float {
        saturation = value;
        shader.data.saturation.value = [value];
        return value;
    }

    public function set_brightness(value:Float):Float {
        brightness = value;
        shader.data.brightness.value = [value];
        return value;
    }

    public function new() {
        var uBlockSize:Float = 1;
        if (PlayState.isPixelStage)
            uBlockSize = PlayState.daPixelZoom;

        shader.data.uBlockSize.value = [uBlockSize, uBlockSize];
	}
}

class ColorSwapPixelShader extends FlxShader {
    @:glFragmentSource('
        #pragma header

        uniform vec2 uBlockSize;

        uniform float hue;
        uniform float saturation;
        uniform float brightness;
        
        vec3 rgb2hsv(vec3 c)
        {
            vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
            vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
        
            float d = q.x - min(q.w, q.y);
            float e = 1.0e-10;
            return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
        }
        
        vec3 hsv2rgb(vec3 c)
        {
            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
            return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
        }
        
        void main() {
            vec2 blocks = openfl_TextureSize / uBlockSize;
            vec4 color = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
        
            vec4 newColor = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color.a);
            
            newColor[0] += hue;
            newColor[1] += saturation;
            newColor[2] *= 1 + brightness;
        
            newColor = vec4(hsv2rgb(vec3(newColor[0], newColor[1], newColor[2])), newColor.a);
        
            gl_FragColor = newColor;
        }
    ')
    public function new() {
        super();
    }
}