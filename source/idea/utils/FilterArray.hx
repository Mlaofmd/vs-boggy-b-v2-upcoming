package idea.utils;

import haxe.iterators.ArrayKeyValueIterator;
import haxe.iterators.ArrayIterator;
import openfl.filters.BitmapFilter;

class FilterArray {
    var array:Array<BitmapFilter> = [];

    public var length(get, never):Int;
    public function get_length():Int {
        return array.length;
    }

    public function new(value:Array<BitmapFilter>) {
        set(value);
    }

    public function set(value:Array<BitmapFilter>) {
        array = value;
    }

    public function concat(a:Array<BitmapFilter>):Array<BitmapFilter> {
        return array.concat(a);
    }

    public function join(sep:String):String {
        return array.join(sep);
    }

    public function pop():Null<BitmapFilter> {
        return array.pop();
    }

    public function push(x:BitmapFilter) {
        array.push(x);
    }

    public function reverse() {
        array.reverse();
    }

    public function shift():Null<BitmapFilter> {
        return array.shift();
    }

    public function slice(pos:Int, ?end:Int):Array<BitmapFilter> {
        return array.slice(pos, end);
    }

    public function sort(f:T->T->Int) {
        array.sort(f);
    }

    public function splice(pos:Int, len:Int):Array<BitmapFilter> {
        return array.splice(pos, len);
    }

    public function toString():String {
        return array.toString();
    }

    public function unshift(x:BitmapFilter) {
        array.unshift(x);
    }

    public function insert(pos:Int, x:BitmapFilter) {
        array.insert(pos, x);
    }

    public function remove(x:BitmapFilter):Bool {
        return array.remove(x);
    }

    @:pure
    public function contains(x:BitmapFilter):Bool {
        return array.contains(x);
    }

    public function indexOf(x:T, ?fromIndex:Int):Int {
        return array.indexOf(x, fromIndex);
    }

    public function lastIndexOf(x:T, ?fromIndex:Int):Int {
        return array.lastIndexOf(x, fromIndex);
    }

    public function copy():Array<BitmapFilter> {
        return array.copy();
    }

    @:runtime
    inline public function iterator():ArrayIterator<BitmapFilter> {
        return array.iterator();
    }

    @:pure
    @:runtime
    inline public function keyValueIterator():ArrayKeyValueIterator<BitmapFilter> {
        return array.keyValueIterator();
    }

    /*@:runtime
    inline public function map(f:BitmapFilter->BitmapFilter):Array<BitmapFilter> {
        return array.map<BitmapFilter>(f);
    }*/

    @:runtime
    inline public function filter(f:BitmapFilter->Bool):Array<BitmapFilter> {
        return array.filter(f);
    }

    public function resize(len:Int) {
        array.resize(len);
    }

    @:arrayAccess
    public function get(i:Int):BitmapFilter {
        return array[i];
    }
}