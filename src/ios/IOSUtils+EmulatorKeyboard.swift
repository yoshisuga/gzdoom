//
//  IOSUtils+EmulatorKeyboard.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 10/24/21.
//

import Foundation

extension IOSUtils {
    @objc var leftKeyboardModel: EmulatorKeyboardViewModel {
       return EmulatorKeyboardViewModel(keys: [
          [
             EmulatorKeyboardKey(label: "1", code: DIK_1),
             EmulatorKeyboardKey(label: "2", code: DIK_2),
             EmulatorKeyboardKey(label: "3", code: DIK_3),
             EmulatorKeyboardKey(label: "4", code: DIK_4),
             EmulatorKeyboardKey(label: "5", code: DIK_5),
          ],
          [
             EmulatorKeyboardKey(label: "q", code: DIK_Q),
             EmulatorKeyboardKey(label: "w", code: DIK_W),
             EmulatorKeyboardKey(label: "e", code: DIK_E),
             EmulatorKeyboardKey(label: "r", code: DIK_R),
             EmulatorKeyboardKey(label: "t", code: DIK_T),
          ],
          [
             EmulatorKeyboardKey(label: "a", code: DIK_A),
             EmulatorKeyboardKey(label: "s", code: DIK_S),
             EmulatorKeyboardKey(label: "d", code: DIK_D),
             EmulatorKeyboardKey(label: "f", code: DIK_F),
             EmulatorKeyboardKey(label: "g", code: DIK_G),
          ],
          [
             EmulatorKeyboardKey(label: "z", code: DIK_Z),
             EmulatorKeyboardKey(label: "x", code: DIK_X),
             EmulatorKeyboardKey(label: "c", code: DIK_C),
             EmulatorKeyboardKey(label: "v", code: DIK_V),
             EmulatorKeyboardKey(label: "b", code: DIK_B),
          ],
          [
             EmulatorKeyboardKey(label: "SHIFT", code: DIK_LSHIFT, keySize: .standard, isModifier: true, imageName: "shift", imageNameHighlighted: "shift.fill"),
             EmulatorKeyboardKey(label: "Fn", code: 9000, keySize: .standard, imageName: "fn"),
             EmulatorKeyboardKey(label: "CTRL", code: DIK_LCONTROL, isModifier: true, imageName: "control"),
             EmulatorKeyboardKey(label: "Space", code: DIK_SPACE, keySize: .wide)
          ]
       ],
       alternateKeys: [
          [
             EmulatorKeyboardKey(label: "ESC", code: DIK_ESCAPE, imageName: "escape"),
             SliderKey(keySize: .standard)
          ],
          [
             EmulatorKeyboardKey(label: "F1", code: DIK_F1),
             EmulatorKeyboardKey(label: "F2", code: DIK_F2),
             EmulatorKeyboardKey(label: "F3", code: DIK_F3),
             EmulatorKeyboardKey(label: "F4", code: DIK_F4),
             EmulatorKeyboardKey(label: "F5", code: DIK_F5),
          ],
          [
             EmulatorKeyboardKey(label: "-", code: DIK_MINUS),
             EmulatorKeyboardKey(label: "=", code: DIK_EQUALS),
             EmulatorKeyboardKey(label: "/", code: DIK_SLASH),
             EmulatorKeyboardKey(label: "[", code: DIK_LBRACKET),
             EmulatorKeyboardKey(label: "]", code: DIK_RBRACKET),
          ],
          [
             EmulatorKeyboardKey(label: ";", code: DIK_SEMICOLON),
             EmulatorKeyboardKey(label: "~", code: DIK_GRAVE),
             EmulatorKeyboardKey(label: ":", code: DIK_COLON)
          ],
          [
             EmulatorKeyboardKey(label: "SHIFT", code: DIK_LSHIFT, keySize: .standard, isModifier: true, imageName: "shift", imageNameHighlighted: "shift.fill"),
             EmulatorKeyboardKey(label: "Fn", code: 9000, keySize: .standard, imageName: "fn"),
             EmulatorKeyboardKey(label: "CTRL", code: DIK_LCONTROL, isModifier: true, imageName: "control"),
             EmulatorKeyboardKey(label: "Space", code: DIK_SPACE, keySize: .wide)
          ]
       ])
    }

    @objc var rightKeyboardModel: EmulatorKeyboardViewModel {
       EmulatorKeyboardViewModel(keys: [
          [
             EmulatorKeyboardKey(label: "6", code: DIK_6),
             EmulatorKeyboardKey(label: "7", code: DIK_7),
             EmulatorKeyboardKey(label: "8", code: DIK_8),
             EmulatorKeyboardKey(label: "9", code: DIK_9),
             EmulatorKeyboardKey(label: "0", code: DIK_0)
          ],
          [
             EmulatorKeyboardKey(label: "y", code: DIK_Y),
             EmulatorKeyboardKey(label: "u", code: DIK_U),
             EmulatorKeyboardKey(label: "i", code: DIK_I),
             EmulatorKeyboardKey(label: "o", code: DIK_O),
             EmulatorKeyboardKey(label: "p", code: DIK_P),
          ],
          [
             EmulatorKeyboardKey(label: "h", code: DIK_H),
             EmulatorKeyboardKey(label: "j", code: DIK_J),
             EmulatorKeyboardKey(label: "k", code: DIK_K),
             EmulatorKeyboardKey(label: "l", code: DIK_L),
             EmulatorKeyboardKey(label: "'", code: DIK_APOSTROPHE)
          ],
          [
             EmulatorKeyboardKey(label: "n", code: DIK_N),
             EmulatorKeyboardKey(label: "m", code: DIK_M),
             EmulatorKeyboardKey(label: ",", code: DIK_COMMA),
             EmulatorKeyboardKey(label: ".", code: DIK_PERIOD),
             EmulatorKeyboardKey(label: "BKSPC", code: DIK_BACK, imageName: "delete.left", imageNameHighlighted: "delete.left.fill")
          ],
          [
             EmulatorKeyboardKey(label: "Alt", code: DIK_LMENU, isModifier: true, imageName: "alt"),
             EmulatorKeyboardKey(label: "tab", code: DIK_TAB, imageName: "arrow.right.to.line"),
             EmulatorKeyboardKey(label: "RETURN", code: DIK_RETURN, keySize: .wide)
          ],
       ],
       alternateKeys: [
          [
             EmulatorKeyboardKey(label: "F6", code: DIK_F6),
             EmulatorKeyboardKey(label: "F7", code: DIK_F7),
             EmulatorKeyboardKey(label: "F8", code: DIK_F8),
             EmulatorKeyboardKey(label: "F9", code: DIK_F9),
             EmulatorKeyboardKey(label: "F10", code: DIK_F10),
          ],
          [
             EmulatorKeyboardKey(label: "PAGEUP", code: DIK_PRIOR, imageName: "arrow.up.doc"),
             EmulatorKeyboardKey(label: "HOME", code: DIK_HOME, imageName: "house"),
             EmulatorKeyboardKey(label: "INS", code: DIK_INSERT, imageName: "text.insert"),
             EmulatorKeyboardKey(label: "END", code: DIK_END),
             EmulatorKeyboardKey(label: "PAGEDWN", code: DIK_NEXT, imageName: "arrow.down.doc"),
          ],
          [
             EmulatorKeyboardKey(label: "F11", code: DIK_F11),
             EmulatorKeyboardKey(label: "⬆️", code: DIK_UP, imageName: "arrow.up"),
             SpacerKey(),
             SpacerKey(),
             EmulatorKeyboardKey(label: "F12", code: DIK_F12),
          ],
          [
             EmulatorKeyboardKey(label: "⬅️", code: DIK_LEFT, imageName: "arrow.left"),
             EmulatorKeyboardKey(label: "⬇️", code: DIK_DOWN, imageName: "arrow.down"),
             EmulatorKeyboardKey(label: "➡️", code: DIK_RIGHT, imageName: "arrow.right"),
             SpacerKey(),
             EmulatorKeyboardKey(label: "DEL", code: DIK_DELETE, imageName: "clear", imageNameHighlighted: "clear.fill"),
          ],
          [
             EmulatorKeyboardKey(label: "RETURN", code: DIK_RETURN, keySize: .wide)
          ]
       ])
    }
}
