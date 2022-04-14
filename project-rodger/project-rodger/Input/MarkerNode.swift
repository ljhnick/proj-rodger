//
//  MarkerNode.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/14/22.
//

import ARKit
import SpriteKit
import SceneKit

class MarkerNode: SKNode {
    var marker = SKShapeNode()
    let markerChild = SKShapeNode(circleOfRadius: 15)
    var parentLinks = [LinkNode]()
    
    // flag if the marker is a joint (shared marker of two links)
    var isJoint = false
    
    // if it is a joint
    var ang = CGFloat.zero
    var angVel = CGFloat.zero
    
    // variables for calculating the velocity
    var currentTime = TimeInterval()
    var timeArray = Array(repeating: TimeInterval(0), count: 20)
    var angArray = Array(repeating: CGFloat(), count: 20)
    
    func setup(_ markerDetected: SKShapeNode) {
        marker = markerDetected
        self.position = marker.position
        self.addChild(markerChild)
        App.state.scene.addChild(self)
    }
    
    func setupColor(_ color: UIColor) {
        markerChild.fillColor = color
    }
    
    func update() {
        self.position = marker.position
        
        if isJoint {
            let nodeLink1Pos = parentLinks[0].markerChildren.first(where: {$0 != self})?.position
            let nodeLink2Pos = parentLinks[1].markerChildren.first(where: {$0 != self})?.position
            let a = distanceCGPointsSK(self.position, nodeLink1Pos!)
            let b = distanceCGPointsSK(self.position, nodeLink2Pos!)
            let c = distanceCGPointsSK(nodeLink1Pos!, nodeLink2Pos!)
            let cosine = (a * a + b * b - c * c)/(2 * a * b)
            ang = acos(Double(cosine))
            
            currentTime = App.state.sceneView.session.currentFrame!.timestamp.magnitude
            timeArray.removeFirst()
            angArray.removeFirst()
            timeArray.append(currentTime)
            angArray.append(ang)
            
            calAngularVelocity()
        }
    }
    
    func checkJoint() {
        if !isJoint {
            if parentLinks.count >= 2 {
                isJoint = true
                App.state.jointNode.append(self)
                let num = App.state.jointNode.count
                self.name = "Joint\(num)"
            }
        }
    }
    
    func calAngularVelocity() {
        let num = CGFloat(timeArray.count)
        let index_1 = num/4
        let index_2 = num*3/4
        // time
        
        let t1 = timeArray[Int(index_1.rounded(.up))]
        let t2 = timeArray[Int(index_2.rounded(.up))]
        let dt = t2 - t1

        let ang_1 = angArray[Int(index_1.rounded(.up))]
        let ang_2 = angArray[Int(index_2.rounded(.up))]
        let d_ang = ang_2 - ang_1
        angVel = d_ang/dt
    }
}
