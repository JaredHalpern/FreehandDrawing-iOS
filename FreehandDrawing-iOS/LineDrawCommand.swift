/*
The MIT License (MIT)

Copyright (c) 2015-present Badoo Trading Limited.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import UIKit

struct LineDrawCommand : DrawCommand {
    let current: Segment
    let previous: Segment?
    
    let width: CGFloat
    let color: UIColor

    // MARK: DrawCommand
    
    func execute(_ canvas: Canvas) {
        self.configure(canvas)

        if self.previous != nil {
            self.drawQuadraticCurve(canvas)
        } else {
            self.drawLine(canvas)
        }
    }
    
    fileprivate func configure(_ canvas: Canvas) {
        canvas.context.setStrokeColor(self.color.cgColor)
        canvas.context.setLineWidth(self.width)
        (canvas.context).setLineCap(CGLineCap.round)
    }
    
    fileprivate func drawLine(_ canvas: Canvas) {
        canvas.context.move(to: CGPoint(x: self.current.a.x, y: self.current.a.y))
        canvas.context.addLine(to: CGPoint(x: self.current.b.x, y: self.current.b.y))
        canvas.context.strokePath()
    }
    
    fileprivate func drawQuadraticCurve(_ canvas: Canvas) {
        if let previousMid = self.previous?.midPoint {
            let currentMid = self.current.midPoint
            
            canvas.context.move(to: CGPoint(x: previousMid.x, y: previousMid.y))
            canvas.context.addQuadCurve(to: CGPoint(x:current.a.x, y:current.a.y), control: currentMid)
            canvas.context.strokePath()
        }
    }
}
