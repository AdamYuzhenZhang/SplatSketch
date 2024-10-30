//
//  NoTouchCanvasView.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/23/24.
//

import PencilKit

class NoTouchCanvasView: PKCanvasView {
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupGestureRecognizers()
        }
    required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupGestureRecognizers()
        }
    
    private func setupGestureRecognizers() {
            guard let gestureRecognizers = self.gestureRecognizers else { return }
            for gestureRecognizer in gestureRecognizers {
                gestureRecognizer.delegate = self
            }
        }
    /*
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let touches = event?.touches(for: self), touches.count > 0 {
            for touch in touches {
                if touch.type == .pencil {
                    // Only handle pencil
                    return super.hitTest(point, with: event)
                }
            }
        }
        return nil;
    }
    */
}

extension NoTouchCanvasView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.type == .pencil {
            // Allow gesture recognizer to handle Pencil touches
            return true
        } else {
            // Prevent gesture recognizer from handling finger touches
            return false
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous recognition if needed
        return true
    }
}
