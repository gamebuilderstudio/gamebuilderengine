/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.serialization.Enumerable;

    import flash.utils.Dictionary;

    /**
     * Enumeration class that maps friendly key names to their key code equivalent. This class
     * should not be instantiated directly, rather, one of the constants should be used.
     */   
    public class InputKey extends Enumerable
    {
        public static const INVALID:InputKey = new InputKey(0);

        public static const BACKSPACE:InputKey = new InputKey(8);
        public static const TAB:InputKey = new InputKey(9);
        public static const ENTER:InputKey = new InputKey(13);
        public static const COMMAND:InputKey = new InputKey(15);
        public static const SHIFT:InputKey = new InputKey(16);
        public static const CONTROL:InputKey = new InputKey(17);
        public static const ALT:InputKey = new InputKey(18);
        public static const PAUSE:InputKey = new InputKey(19);
        public static const CAPS_LOCK:InputKey = new InputKey(20);
        public static const ESCAPE:InputKey = new InputKey(27);

        public static const SPACE:InputKey = new InputKey(32);
        public static const PAGE_UP:InputKey = new InputKey(33);
        public static const PAGE_DOWN:InputKey = new InputKey(34);
        public static const END:InputKey = new InputKey(35);
        public static const HOME:InputKey = new InputKey(36);
        public static const LEFT:InputKey = new InputKey(37);
        public static const UP:InputKey = new InputKey(38);
        public static const RIGHT:InputKey = new InputKey(39);
        public static const DOWN:InputKey = new InputKey(40);

        public static const INSERT:InputKey = new InputKey(45);
        public static const DELETE:InputKey = new InputKey(46);

        public static const ZERO:InputKey = new InputKey(48);
        public static const ONE:InputKey = new InputKey(49);
        public static const TWO:InputKey = new InputKey(50);
        public static const THREE:InputKey = new InputKey(51);
        public static const FOUR:InputKey = new InputKey(52);
        public static const FIVE:InputKey = new InputKey(53);
        public static const SIX:InputKey = new InputKey(54);
        public static const SEVEN:InputKey = new InputKey(55);
        public static const EIGHT:InputKey = new InputKey(56);
        public static const NINE:InputKey = new InputKey(57);

        public static const A:InputKey = new InputKey(65);
        public static const B:InputKey = new InputKey(66);
        public static const C:InputKey = new InputKey(67);
        public static const D:InputKey = new InputKey(68);
        public static const E:InputKey = new InputKey(69);
        public static const F:InputKey = new InputKey(70);
        public static const G:InputKey = new InputKey(71);
        public static const H:InputKey = new InputKey(72);
        public static const I:InputKey = new InputKey(73);
        public static const J:InputKey = new InputKey(74);
        public static const K:InputKey = new InputKey(75);
        public static const L:InputKey = new InputKey(76);
        public static const M:InputKey = new InputKey(77);
        public static const N:InputKey = new InputKey(78);
        public static const O:InputKey = new InputKey(79);
        public static const P:InputKey = new InputKey(80);
        public static const Q:InputKey = new InputKey(81);
        public static const R:InputKey = new InputKey(82);
        public static const S:InputKey = new InputKey(83);
        public static const T:InputKey = new InputKey(84);
        public static const U:InputKey = new InputKey(85);
        public static const V:InputKey = new InputKey(86);
        public static const W:InputKey = new InputKey(87);
        public static const X:InputKey = new InputKey(88);
        public static const Y:InputKey = new InputKey(89);
        public static const Z:InputKey = new InputKey(90);

        public static const NUM0:InputKey = new InputKey(96);
        public static const NUM1:InputKey = new InputKey(97);
        public static const NUM2:InputKey = new InputKey(98);
        public static const NUM3:InputKey = new InputKey(99);
        public static const NUM4:InputKey = new InputKey(100);
        public static const NUM5:InputKey = new InputKey(101);
        public static const NUM6:InputKey = new InputKey(102);
        public static const NUM7:InputKey = new InputKey(103);
        public static const NUM8:InputKey = new InputKey(104);
        public static const NUM9:InputKey = new InputKey(105);

        public static const MULTIPLY:InputKey = new InputKey(106);
        public static const ADD:InputKey = new InputKey(107);
        public static const NUMENTER:InputKey = new InputKey(108);
        public static const SUBTRACT:InputKey = new InputKey(109);
        public static const DECIMAL:InputKey = new InputKey(110);
        public static const DIVIDE:InputKey = new InputKey(111);

        public static const F1:InputKey = new InputKey(112);
        public static const F2:InputKey = new InputKey(113);
        public static const F3:InputKey = new InputKey(114);
        public static const F4:InputKey = new InputKey(115);
        public static const F5:InputKey = new InputKey(116);
        public static const F6:InputKey = new InputKey(117);
        public static const F7:InputKey = new InputKey(118);
        public static const F8:InputKey = new InputKey(119);
        public static const F9:InputKey = new InputKey(120);
        // F10 is considered 'reserved' by Flash
        public static const F11:InputKey = new InputKey(122);
        public static const F12:InputKey = new InputKey(123);

        public static const NUM_LOCK:InputKey = new InputKey(144);
        public static const SCROLL_LOCK:InputKey = new InputKey(145);

        public static const COLON:InputKey = new InputKey(186);
        public static const PLUS:InputKey = new InputKey(187);
        public static const COMMA:InputKey = new InputKey(188);
        public static const MINUS:InputKey = new InputKey(189);
        public static const PERIOD:InputKey = new InputKey(190);
        public static const BACKSLASH:InputKey = new InputKey(191);
        public static const TILDE:InputKey = new InputKey(192);

        public static const LEFT_BRACKET:InputKey = new InputKey(219);
        public static const SLASH:InputKey = new InputKey(220);
        public static const RIGHT_BRACKET:InputKey = new InputKey(221);
        public static const QUOTE:InputKey = new InputKey(222);

        public static const MOUSE_BUTTON:InputKey = new InputKey(253);
        public static const MOUSE_X:InputKey = new InputKey(254);
        public static const MOUSE_Y:InputKey = new InputKey(255);
        public static const MOUSE_WHEEL:InputKey = new InputKey(256);
        public static const MOUSE_HOVER:InputKey = new InputKey(257);

        /**
         * A dictionary mapping the string names of all the keys to the InputKey they represent.
         */
        public static function get staticTypeMap():Dictionary
        {
            if (!_typeMap)
            {
                _typeMap = new Dictionary();
                _typeMap["BACKSPACE"] = BACKSPACE;
                _typeMap["TAB"] = TAB;
                _typeMap["ENTER"] = ENTER;
                _typeMap["RETURN"] = ENTER;
                _typeMap["SHIFT"] = SHIFT;
                _typeMap["COMMAND"] = COMMAND;
                _typeMap["CONTROL"] = CONTROL;
                _typeMap["ALT"] = ALT;
                _typeMap["OPTION"] = ALT;
                _typeMap["ALTERNATE"] = ALT;
                _typeMap["PAUSE"] = PAUSE;
                _typeMap["CAPS_LOCK"] = CAPS_LOCK;
                _typeMap["ESCAPE"] = ESCAPE;
                _typeMap["SPACE"] = SPACE;
                _typeMap["SPACE_BAR"] = SPACE;
                _typeMap["PAGE_UP"] = PAGE_UP;
                _typeMap["PAGE_DOWN"] = PAGE_DOWN;
                _typeMap["END"] = END;
                _typeMap["HOME"] = HOME;
                _typeMap["LEFT"] = LEFT;
                _typeMap["UP"] = UP;
                _typeMap["RIGHT"] = RIGHT;
                _typeMap["DOWN"] = DOWN;
                _typeMap["LEFT_ARROW"] = LEFT;
                _typeMap["UP_ARROW"] = UP;
                _typeMap["RIGHT_ARROW"] = RIGHT;
                _typeMap["DOWN_ARROW"] = DOWN;
                _typeMap["INSERT"] = INSERT;
                _typeMap["DELETE"] = DELETE;
                _typeMap["ZERO"] = ZERO;
                _typeMap["ONE"] = ONE;
                _typeMap["TWO"] = TWO;
                _typeMap["THREE"] = THREE;
                _typeMap["FOUR"] = FOUR;
                _typeMap["FIVE"] = FIVE;
                _typeMap["SIX"] = SIX;
                _typeMap["SEVEN"] = SEVEN;
                _typeMap["EIGHT"] = EIGHT;
                _typeMap["NINE"] = NINE;
                _typeMap["0"] = ZERO;
                _typeMap["1"] = ONE;
                _typeMap["2"] = TWO;
                _typeMap["3"] = THREE;
                _typeMap["4"] = FOUR;
                _typeMap["5"] = FIVE;
                _typeMap["6"] = SIX;
                _typeMap["7"] = SEVEN;
                _typeMap["8"] = EIGHT;
                _typeMap["9"] = NINE;
                _typeMap["NUMBER_0"] = ZERO;
                _typeMap["NUMBER_1"] = ONE;
                _typeMap["NUMBER_2"] = TWO;
                _typeMap["NUMBER_3"] = THREE;
                _typeMap["NUMBER_4"] = FOUR;
                _typeMap["NUMBER_5"] = FIVE;
                _typeMap["NUMBER_6"] = SIX;
                _typeMap["NUMBER_7"] = SEVEN;
                _typeMap["NUMBER_8"] = EIGHT;
                _typeMap["NUMBER_9"] = NINE;
                _typeMap["A"] = A;
                _typeMap["B"] = B;
                _typeMap["C"] = C;
                _typeMap["D"] = D;
                _typeMap["E"] = E;
                _typeMap["F"] = F;
                _typeMap["G"] = G;
                _typeMap["H"] = H;
                _typeMap["I"] = I;
                _typeMap["J"] = J;
                _typeMap["K"] = K;
                _typeMap["L"] = L;
                _typeMap["M"] = M;
                _typeMap["N"] = N;
                _typeMap["O"] = O;
                _typeMap["P"] = P;
                _typeMap["Q"] = Q;
                _typeMap["R"] = R;
                _typeMap["S"] = S;
                _typeMap["T"] = T;
                _typeMap["U"] = U;
                _typeMap["V"] = V;
                _typeMap["W"] = W;
                _typeMap["X"] = X;
                _typeMap["Y"] = Y;
                _typeMap["Z"] = Z;
                _typeMap["NUM0"] = NUM0;
                _typeMap["NUM1"] = NUM1;
                _typeMap["NUM2"] = NUM2;
                _typeMap["NUM3"] = NUM3;
                _typeMap["NUM4"] = NUM4;
                _typeMap["NUM5"] = NUM5;
                _typeMap["NUM6"] = NUM6;
                _typeMap["NUM7"] = NUM7;
                _typeMap["NUM8"] = NUM8;
                _typeMap["NUM9"] = NUM9;
                _typeMap["NUMPAD_0"] = NUM0;
                _typeMap["NUMPAD_1"] = NUM1;
                _typeMap["NUMPAD_2"] = NUM2;
                _typeMap["NUMPAD_3"] = NUM3;
                _typeMap["NUMPAD_4"] = NUM4;
                _typeMap["NUMPAD_5"] = NUM5;
                _typeMap["NUMPAD_6"] = NUM6;
                _typeMap["NUMPAD_7"] = NUM7;
                _typeMap["NUMPAD_8"] = NUM8;
                _typeMap["NUMPAD_9"] = NUM9;
                _typeMap["MULTIPLY"] = MULTIPLY;
                _typeMap["ASTERISK"] = MULTIPLY;
                _typeMap["NUMMULTIPLY"] = MULTIPLY;
                _typeMap["NUMPAD_MULTIPLY"] = MULTIPLY;
                _typeMap["ADD"] = ADD;
                _typeMap["NUMADD"] = ADD;
                _typeMap["NUMPAD_ADD"] = ADD;
                _typeMap["SUBTRACT"] = SUBTRACT;
                _typeMap["NUMSUBTRACT"] = SUBTRACT;
                _typeMap["NUMPAD_SUBTRACT"] = SUBTRACT;
                _typeMap["DECIMAL"] = DECIMAL;
                _typeMap["NUMDECIMAL"] = DECIMAL;
                _typeMap["NUMPAD_DECIMAL"] = DECIMAL;
                _typeMap["DIVIDE"] = DIVIDE;
                _typeMap["NUMDIVIDE"] = DIVIDE;
                _typeMap["NUMPAD_DIVIDE"] = DIVIDE;
                _typeMap["NUMENTER"] = NUMENTER;
                _typeMap["NUMPAD_ENTER"] = NUMENTER;
                _typeMap["F1"] = F1;
                _typeMap["F2"] = F2;
                _typeMap["F3"] = F3;
                _typeMap["F4"] = F4;
                _typeMap["F5"] = F5;
                _typeMap["F6"] = F6;
                _typeMap["F7"] = F7;
                _typeMap["F8"] = F8;
                _typeMap["F9"] = F9;
                _typeMap["F11"] = F11;
                _typeMap["F12"] = F12;
                _typeMap["NUM_LOCK"] = NUM_LOCK;
                _typeMap["SCROLL_LOCK"] = SCROLL_LOCK;
                _typeMap["COLON"] = COLON;
                _typeMap["SEMICOLON"] = COLON;
                _typeMap["PLUS"] = PLUS;
                _typeMap["EQUAL"] = PLUS;
                _typeMap["COMMA"] = COMMA;
                _typeMap["LESS_THAN"] = COMMA;
                _typeMap["MINUS"] = MINUS;
                _typeMap["UNDERSCORE"] = MINUS;
                _typeMap["PERIOD"] = PERIOD;
                _typeMap["GREATER_THAN"] = PERIOD;
                _typeMap["BACKSLASH"] = BACKSLASH;
                _typeMap["QUESTION_MARK"] = BACKSLASH;
                _typeMap["TILDE"] = TILDE;
                _typeMap["BACK_QUOTE"] = TILDE;
                _typeMap["LEFT_BRACKET"] = LEFT_BRACKET;
                _typeMap["LEFT_BRACE"] = LEFT_BRACKET;
                _typeMap["SLASH"] = SLASH;
                _typeMap["FORWARD_SLASH"] = SLASH;
                _typeMap["PIPE"] = SLASH;
                _typeMap["RIGHT_BRACKET"] = RIGHT_BRACKET;
                _typeMap["RIGHT_BRACE"] = RIGHT_BRACKET;
                _typeMap["QUOTE"] = QUOTE;
                _typeMap["MOUSE_BUTTON"] = MOUSE_BUTTON;
                _typeMap["MOUSE_X"] = MOUSE_X;
                _typeMap["MOUSE_Y"] = MOUSE_Y;
                _typeMap["MOUSE_WHEEL"] = MOUSE_WHEEL;
                _typeMap["MOUSE_HOVER"] = MOUSE_HOVER;
            }

            return _typeMap;
        }

        /**
         * Converts a key code to the string that represents it.
         */
        public static function codeToString(value:int):String
        {
            var tm:Dictionary = staticTypeMap;
            for (var name:String in tm)
            {
                if (staticTypeMap[name.toUpperCase()].keyCode == value)
                    return name.toUpperCase();
            }

            return null;
        }

        /**
         * Converts the name of a key to the keycode it represents.
         */
        public static function stringToCode(value:String):int
        {
            if (!staticTypeMap[value.toUpperCase()])
                return 0;

            return staticTypeMap[value.toUpperCase()].keyCode;
        }

        /**
         * Converts the name of a key to the InputKey it represents.
         */
        public static function stringToKey(value:String):InputKey
        {
            return staticTypeMap[value.toUpperCase()];
        }

        private static var _typeMap:Dictionary = null;

        /**
         * The key code that this wraps.
         */
        public function get keyCode():int
        {
            return _keyCode;
        }

        public function InputKey(keyCode:int=0)
        {
            _keyCode = keyCode;
        }

        override public function get typeMap():Dictionary
        {
            return staticTypeMap;
        }

        override public function get defaultType():Enumerable
        {
            return INVALID;
        }

        private var _keyCode:int = 0;
    }
}

