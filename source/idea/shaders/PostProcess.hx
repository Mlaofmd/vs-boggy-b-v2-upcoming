package idea.shaders;

import lime.utils.Float32Array;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import flixel.system.FlxAssets.FlxShader;

using StringTools;

class PostProcess extends FlxShader {
    inline static var FRAGMENT_HEADER:String = "
        #pragma version

        #pragma precision

        varying float openfl_Alphav;
        varying vec4 openfl_ColorMultiplierv;
        varying vec4 openfl_ColorOffsetv;
        varying vec2 openfl_TextureCoordv;
        uniform bool openfl_HasColorTransform;
        uniform vec2 openfl_TextureSize;
        uniform sampler2D bitmap;
    " #if FLX_DRAW_QUADS + "
        uniform bool hasTransform;
        uniform bool hasColorTransform;
        vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
        {
            vec4 color = texture2D(bitmap, coord);
            if (!hasTransform)
            {
                return color;
            }
            if (color.a == 0.0)
            {
                return vec4(0.0, 0.0, 0.0, 0.0);
            }
            if (!hasColorTransform)
            {
                return color * openfl_Alphav;
            }
            color = vec4(color.rgb / color.a, color.a);
            mat4 colorMultiplier = mat4(0);
            colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
            colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
            colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
            colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
            color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
            if (color.a > 0.0)
            {
                return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
            }
            return vec4(0.0, 0.0, 0.0, 0.0);
        }
    " #end;

    inline static var FRAGMENT_BODY:String = "
        vec4 color = texture2D(bitmap, openfl_TextureCoordv);
		if (color.a == 0.0)
			gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
		else if (openfl_HasColorTransform) {
			color = vec4 (color.rgb / color.a, color.a);
			mat4 colorMultiplier = mat4 (0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = 1.0; // openfl_ColorMultiplierv.w;
			color = clamp (openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
			if (color.a > 0.0)
				gl_FragColor = vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			else
				gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
		} else
			gl_FragColor = color * openfl_Alphav;
    ";

    inline static var FRAGMENT_SOURCE:String = #if FLX_DRAW_QUADS "
        #pragma header
            
        void main()
            gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    " #else "
        #pragma header

        void main() {
            #pragma body
        }
    " #end;

    inline static var VERTEX_HEADER:String = "
        #pragma version

		#pragma precision

		attribute float openfl_Alpha;
		attribute vec4 openfl_ColorMultiplier;
		attribute vec4 openfl_ColorOffset;
		attribute vec4 openfl_Position;
		attribute vec2 openfl_TextureCoord;
		varying float openfl_Alphav;
		varying vec4 openfl_ColorMultiplierv;
		varying vec4 openfl_ColorOffsetv;
		varying vec2 openfl_TextureCoordv;
		uniform mat4 openfl_Matrix;
		uniform bool openfl_HasColorTransform;
		uniform vec2 openfl_TextureSize;
    ";

    inline static var VERTEX_BODY:String = "
        openfl_Alphav = openfl_Alpha;
        openfl_TextureCoordv = openfl_TextureCoord;
        if (openfl_HasColorTransform) {
            openfl_ColorMultiplierv = openfl_ColorMultiplier;
            openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
        }
        gl_Position = openfl_Matrix * openfl_Position;
    ";

    inline static var VERTEX_SOURCE:String = #if FLX_DRAW_QUADS "
        #pragma header
            
        attribute float alpha;
        attribute vec4 colorMultiplier;
        attribute vec4 colorOffset;
        uniform bool hasColorTransform;
        
        void main() {
            #pragma body
            
            openfl_Alphav = openfl_Alpha * alpha;
            
            if (hasColorTransform) {
                openfl_ColorOffsetv = colorOffset / 255.0;
                openfl_ColorMultiplierv = colorMultiplier;
            }
        }
    " #else "
        #pragma header

        void main() {
            #pragma body
        }
    " #end;

    var PRECISION_HEADERS(get, never):String;
    function get_PRECISION_HEADERS():String {
        return "
            #ifdef GL_ES
            " + (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH
                precision highp float;
            #else
                precision mediump float;
            #endif" : "precision lowp float;")
            + "
            #endif
        ";
    }

    static final PRAGMA_HEADER:String = "#pragma header";
	static final PRAGMA_BODY:String = "#pragma body";
	static final PRAGMA_PRECISION:String = "#pragma precision";
	static final PRAGMA_VERSION:String = "#pragma version";

    private var glslVersion:Int;

    public function new(fragment:String = null, vertex:String = null, glslVersion:Int = 120) {
        this.glslVersion = glslVersion;

        if (fragment == null)
            fragment = FRAGMENT_SOURCE;
        fragment = fragment.replace(PRAGMA_HEADER, FRAGMENT_HEADER).replace(PRAGMA_BODY, FRAGMENT_BODY);

        if (vertex == null)
            vertex = VERTEX_SOURCE;
        vertex = vertex.replace(PRAGMA_HEADER, VERTEX_HEADER).replace(PRAGMA_BODY, VERTEX_BODY);

        glFragmentSource = fragment;
        glVertexSource = vertex;

		__glSourceDirty = true;
		__isGenerated = false;

		super();
    }

    override function __initGL() {
        if (__glSourceDirty || __paramBool == null) {
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		@:privateAccess
		if (__context != null && program == null) {
			var gl = __context.gl;

            var vertex:String = glVertexSource.replace(PRAGMA_PRECISION, PRECISION_HEADERS).replace(PRAGMA_VERSION, "#version " + glslVersion);
            var fragment:String = glFragmentSource.replace(PRAGMA_PRECISION, PRECISION_HEADERS).replace(PRAGMA_VERSION, "#version " + glslVersion);

			var id = vertex + fragment;

			if (__context.__programs.exists(id))
				program = __context.__programs.get(id);
			else {
				program = __context.createProgram(GLSL);
				program.__glProgram = __createGLProgram(vertex, fragment);
				__context.__programs.set(id, program);
			}

			if (program != null) {
				glProgram = program.__glProgram;

				for (input in __inputBitmapData) {
					if (input.__isUniform)
						input.index = gl.getUniformLocation(glProgram, input.name);
					else
						input.index = gl.getAttribLocation(glProgram, input.name);
				}

				for (parameter in __paramBool) {
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}

				for (parameter in __paramFloat) {
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}

				for (parameter in __paramInt) {
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}
		}
    }

    private override function __processGLData(source:String, storageType:String) {
		var position;
		var name;
		var type;

		var regex = (storageType == "uniform")
			? ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/
			: ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;

		var lastMatch = 0;

		@:privateAccess
		while (regex.matchSub(source, lastMatch)) {
			type = regex.matched(1);
			name = regex.matched(2);

			if (name.startsWith("gl_"))
				continue;

			var isUniform = (storageType == "uniform");

			if (type.startsWith("sampler")) {
				var input = new ShaderInput<BitmapData>();
				input.name = name;
				input.__isUniform = isUniform;
				__inputBitmapData.push(input);

				if (name == "openfl_Texture")
					__texture = input;
				else if (name == "bitmap")
					__bitmap = input;

				Reflect.setField(__data, name, input);
			} else if (!Reflect.hasField(__data, name) || Reflect.field(__data, name) == null) {
				var parameterType:ShaderParameterType = switch(type) {
					case "bool": BOOL;
					case "double", "float": FLOAT;
					case "int", "uint": INT;
					case "bvec2": BOOL2;
					case "bvec3": BOOL3;
					case "bvec4": BOOL4;
					case "ivec2", "uvec2": INT2;
					case "ivec3", "uvec3": INT3;
					case "ivec4", "uvec4": INT4;
					case "vec2", "dvec2": FLOAT2;
					case "vec3", "dvec3": FLOAT3;
					case "vec4", "dvec4": FLOAT4;
					case "mat2", "mat2x2": MATRIX2X2;
					case "mat2x3": MATRIX2X3;
					case "mat2x4": MATRIX2X4;
					case "mat3x2": MATRIX3X2;
					case "mat3", "mat3x3": MATRIX3X3;
					case "mat3x4": MATRIX3X4;
					case "mat4x2": MATRIX4X2;
					case "mat4x3": MATRIX4X3;
					case "mat4", "mat4x4": MATRIX4X4;
					default: null;
				}

				var length = switch(parameterType) {
					case BOOL2, INT2, FLOAT2: 2;
					case BOOL3, INT3, FLOAT3: 3;
					case BOOL4, INT4, FLOAT4, MATRIX2X2: 4;
					case MATRIX3X3: 9;
					case MATRIX4X4: 16;
					default: 1;
				}

				var arrayLength = switch(parameterType) {
					case MATRIX2X2: 2;
					case MATRIX3X3: 3;
					case MATRIX4X4: 4;
					default: 1;
				}

				switch(parameterType) {
					case BOOL, BOOL2, BOOL3, BOOL4:
						var parameter = new ShaderParameter<Bool>();
						parameter.name = name;
						parameter.type = parameterType;
						parameter.__arrayLength = arrayLength;
						parameter.__isBool = true;
						parameter.__isUniform = isUniform;
						parameter.__length = length;
						__paramBool.push(parameter);

						if (name == "openfl_HasColorTransform")
							__hasColorTransform = parameter;

						Reflect.setField(__data, name, parameter);

					case INT, INT2, INT3, INT4:
						var parameter = new ShaderParameter<Int>();
						parameter.name = name;
						parameter.type = parameterType;
						parameter.__arrayLength = arrayLength;
						parameter.__isInt = true;
						parameter.__isUniform = isUniform;
						parameter.__length = length;
						__paramInt.push(parameter);
						Reflect.setField(__data, name, parameter);

					default:
						var parameter = new ShaderParameter<Float>();
						parameter.name = name;
						parameter.type = parameterType;
						parameter.__arrayLength = arrayLength;
						#if lime
						if (arrayLength > 0) parameter.__uniformMatrix = new Float32Array(arrayLength * arrayLength);
						#end
						parameter.__isFloat = true;
						parameter.__isUniform = isUniform;
						parameter.__length = length;
						__paramFloat.push(parameter);

						if (name.startsWith("openfl_")) {
							switch(name) {
								case "openfl_Alpha": __alpha = parameter;
								case "openfl_ColorMultiplier": __colorMultiplier = parameter;
								case "openfl_ColorOffset": __colorOffset = parameter;
								case "openfl_Matrix": __matrix = parameter;
								case "openfl_Position": __position = parameter;
								case "openfl_TextureCoord": __textureCoord = parameter;
								case "openfl_TextureSize": __textureSize = parameter;
							}
						}

						Reflect.setField(__data, name, parameter);
				}
			}

			position = regex.matchedPos();
			lastMatch = position.pos + position.len;
		}
	}

	public function setUniform(name:String, value:Dynamic) {
		if (!Reflect.hasField(data, name))
			return;

		Reflect.setField(data, name, value);
	}

	public function getUniform(name:String):Dynamic {
		return Reflect.field(data, name);
	}

	public function toString():String {
		return 'FlxRuntimeShader';
	}
}