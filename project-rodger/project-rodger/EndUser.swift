//
//  EndUser.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 3/22/22.
//

import SpriteKit
import ARKit
import UIKit

extension Scene {
    
    func endUserTouchesBegan(_ touches: Set<UITouch>) {
        
    }
    
    func endUserTouchesMoved(_ touches: Set<UITouch>) {
        
    }
    
    func endUserTouchesEnded(_ touches: Set<UITouch>) {
        let path = CGMutablePath()
        path.move(to: drawPathArray[0])
        for point in drawPathArray {
            path.addLine(to: point)
        }
        let shape = SKShapeNode(path: path)
        let center = CGPoint(x: shape.frame.midX, y: shape.frame.midY)
        
        let nodes = nodes(at: center)

        switch App.state.endUserViewController.STEP {
        case App.state.endUserViewController.STEP_ACTION_SELECT_INPUT:
            guard let inputNode = nodes.first(where: {$0.name != nil}) else {
                App.state.endUserViewController.promptRetry()
                return }
            App.state.endUserViewController.inputNode = inputNode
            App.state.endUserViewController.promptSuccess()
        case App.state.endUserViewController.STEP_ACTION_SELECT_OUTPUT:
            guard let outputNode = nodes.first(where: {$0.name != nil}) else {
                App.state.endUserViewController.promptRetry()
                return }
            App.state.endUserViewController.outputNode = outputNode
            App.state.endUserViewController.promptSuccess()
        default:
            ()
        }
    }
}
