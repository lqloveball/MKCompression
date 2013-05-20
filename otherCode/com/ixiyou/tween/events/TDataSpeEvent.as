package  com.ixiyou.tween.events
{
    import flash.events.*;

    public class TDataSpeEvent extends Event
    {
        private var _data:Object;

        public function TDataSpeEvent(param1:String, param2:Object, param3:Boolean = false, param4:Boolean = false)
        {
            super(param1, param3, param4);
            _data = param2;
            return;
        }

        public function get data() : Object
        {
            return _data;
        }

        public override function toString() : String
        {
            return formatToString("DataSpeEvent:", "type", "bubbles", "cancelable", "data");
        }
    }
}
