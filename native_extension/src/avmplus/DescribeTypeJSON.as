// =================================================================================================
//
//	Modified by Rodrigo Lopez [roipeker™] on 20/01/2019.
//
//  original class:
//  https://github.com/tschneidereit/SwiftSuspenders/blob/master/src/avmplus/DescribeTypeJSON.as
//
//  Check https://jacksondunstan.com/articles/2609 for reference.
//
//
// =================================================================================================

package avmplus {

/**
 * -- Basic Usage:
 *
 * var desc:Object = DescribeTypeJSON.run( AnyClassOrInstance );
 * trace( JSON.stringify( desc )) ;
 *
 */

/**
 * Makes the hidden, unofficial function describeTypeJSON available outside of the avmplus
 * package.
 *
 * <strong>As Adobe doen't officially support this method and it is only visible to client
 * code by accident, it should only ever be used with runtime-detection and automatic fallback
 * on describeType.</strong>
 *
 * @see http://www.tillschneidereit.de/2009/11/22/improved-reflection-support-in-flash-player-10-1/
 */
public class DescribeTypeJSON {
    //----------------------              Public Properties             ----------------------//
    public static var available:Boolean = describeTypeJSON != null;

    public static const INSTANCE_FLAGS:uint = INCLUDE_VARIABLES | USE_ITRAITS | HIDE_OBJECT;
    public static const CLASS_FLAGS:uint = INCLUDE_VARIABLES | INCLUDE_TRAITS | HIDE_OBJECT;


    private static var _instance:DescribeTypeJSON;

    public static function get():DescribeTypeJSON {
        if (!_instance) _instance = new DescribeTypeJSON();
        return _instance;
    }

    public static function run(obj:Object):Object {
        // little hack to call Class from instance
        if (!(obj is Class)) obj = Object(obj).constructor;
        return get().describeType(obj, CLASS_FLAGS | INSTANCE_FLAGS);
    }

    //----------------------               Public Methods               ----------------------//
    public function DescribeTypeJSON() {
    }

    public function describeType(target:Object, flags:uint):Object {
        return describeTypeJSON(target, flags);
    }

    public function getInstanceDescription(type:Object):Object {
        return describeTypeJSON(type, INSTANCE_FLAGS);
    }

    public function getClassDescription(type:Class):Object {
        return describeTypeJSON(type, CLASS_FLAGS);
    }
}
}