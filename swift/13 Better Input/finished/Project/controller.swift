//
//  controller.swift
//  Project
//
//  Created by Andrew Mengede on 1/2/2023.
//
import GameController

struct Point2D {
    var x: Float
    var y: Float
}

class InputController {
    static let controller: InputController = .init()
    var keysPressed: Set<GCKeyCode> = []
    var mousePressed: Bool = false
    var mouseDelta: Point2D = .init(x: 0, y: 0)

    init() {
        let center = NotificationCenter.default

        center.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: nil) {
            notification in
            GZLogFunc()
            let keyboard = notification.object as? GCKeyboard
            keyboard?.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                if pressed {
                    self.keysPressed.insert(keyCode)
                } else {
                    self.keysPressed.remove(keyCode)
                }
            }
        }

        center.addObserver(forName: .GCMouseDidConnect, object: nil, queue: nil) {
            notification in
            GZLogFunc()
            let mouse = notification.object as? GCMouse

            mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                self.mousePressed = pressed
            }

            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                GZLogFunc(deltaX)
                self.mouseDelta = Point2D(x: -deltaX, y: -deltaY)
            }
        }
    }
}
