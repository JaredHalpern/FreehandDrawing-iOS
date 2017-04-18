//
//  FreehandDrawController.swift
//  FreehandDrawing-iOS
//
//  Created by Miguel Angel Quinones on 03/06/2015.
//  Copyright (c) 2015 badoo. All rights reserved.
//

import UIKit

class FreehandDrawController : NSObject {
    var color: UIColor = UIColor.black
    var width: CGFloat = 5.0
    
    required init(canvas: Canvas & DrawCommandReceiver, view: UIView) {
        self.canvas = canvas
        super.init()
        
        self.setupGestureRecognizersInView(view)
    }
    
    // MARK: API
    
    func undo() {
        if self.commandQueue.count > 0{
            self.commandQueue.removeLast()
            self.canvas.reset()
            self.canvas.executeCommands(self.commandQueue)
        }
    }
    
    // MARK: Gestures
    
    fileprivate func setupGestureRecognizersInView(_ view: UIView) {
        // Pan gesture recognizer to track lines
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(FreehandDrawController.handlePan(_:)))
        view.addGestureRecognizer(panRecognizer)
        
        // Tap gesture recognizer to track points
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FreehandDrawController.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc fileprivate func handlePan(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: sender.view)
        switch sender.state {
        case .began:
            self.startAtPoint(point)
        case .changed:
            self.continueAtPoint(point, velocity: sender.velocity(in: sender.view))
        case .ended:
            self.endAtPoint(point)
        case .failed:
            self.endAtPoint(point)
        default:
            assert(false, "State not handled")
        }
    }
    
    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: sender.view)
        if sender.state == .ended {
            self.tapAtPoint(point)
        }
    }
    
    // MARK: Draw commands
    
    fileprivate func startAtPoint(_ point: CGPoint) {
        self.lastPoint = point
        self.lineStrokeCommand = ComposedCommand(commands: [])
    }
    
    fileprivate func continueAtPoint(_ point: CGPoint, velocity: CGPoint) {
        let segmentWidth = modulatedWidth(self.width, velocity: velocity, previousVelocity: self.lastVelocity, previousWidth: self.lastWidth ?? self.width)
        let segment = Segment(a: self.lastPoint, b: point, width: segmentWidth)
        
        let lineCommand = LineDrawCommand(current: segment, previous: lastSegment, width: segmentWidth, color: self.color)
        
        self.canvas.executeCommands([lineCommand])

        self.lineStrokeCommand?.addCommand(lineCommand)
        self.lastPoint = point
        self.lastSegment = segment
        self.lastVelocity = velocity
        self.lastWidth = segmentWidth
    }
    
    fileprivate func endAtPoint(_ point: CGPoint) {
        if let lineStrokeCommand = self.lineStrokeCommand {
            self.commandQueue.append(lineStrokeCommand)
        }
        
        self.lastPoint = CGPoint.zero
        self.lastSegment = nil
        self.lastVelocity = CGPoint.zero
        self.lastWidth = nil
        self.lineStrokeCommand = nil
    }
    
    fileprivate func tapAtPoint(_ point: CGPoint) {
        let circleCommand = CircleDrawCommand(center: point, radius: self.width/2.0, color: self.color)
        self.canvas.executeCommands([circleCommand])
        self.commandQueue.append(circleCommand)
    }
    
    fileprivate let canvas: Canvas & DrawCommandReceiver
    fileprivate var lineStrokeCommand: ComposedCommand?
    fileprivate var commandQueue: Array<DrawCommand> = []
    fileprivate var lastPoint: CGPoint = CGPoint.zero
    fileprivate var lastSegment: Segment?
    fileprivate var lastVelocity: CGPoint = CGPoint.zero
    fileprivate var lastWidth: CGFloat?
}
