//
//  LinkNode.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/14/22.
//

import ARKit
import SpriteKit
import SceneKit

class LinkNode: SKNode {
    var markerChildren = [MarkerNode]()
    
    var numOfMarkers: Int = 0
    var midPositionOfMarkers: CGPoint = CGPoint.zero
    var orientation: CGFloat = 0
    
    // spatial properties and variables
    var posVel = CGVector.zero
    var angVel = CGFloat.zero
    var depth = CGFloat(1)

    // flag
    var isHighlighted = false
    // variables for calculating the velocity
    var currentTime = TimeInterval()
    var timeArray = Array(repeating: TimeInterval(0), count: 20)
    var posArray = Array(repeating: CGPoint(), count: 20)
    var oriArray = Array(repeating: CGFloat(), count: 20)
    
    // labeling
    var lineLength = CGFloat.zero
    
    func setup(_ markers: [MarkerNode]) {
        markerChildren = markers
        numOfMarkers = markers.count
        calMidPosition()
        lineLength = addLines()
        App.state.object.addALink(self)
        for marker in markers {
            marker.parentLinks.append(self)
            marker.checkJoint()
        }
        App.state.linkNodes.append(self)
        
        let index = App.state.linkNodes.firstIndex(of: self)
        self.name = "Link\(index!+1)"
    }
    
    func calMidPosition() {
        var x_min = markerChildren[0].position.x
        var x_max = x_min
        var y_min = markerChildren[0].position.y
        var y_max = y_min
        for marker in markerChildren {
            let x = marker.position.x
            let y = marker.position.y
            if x < x_min {
                x_min = x
            } else if x > x_max {
                x_max = x
            }
            if y < y_min {
                y_min = y
            } else if y > y_max {
                y_max = y
            }
        }
        self.midPositionOfMarkers = CGPoint(x: (x_min+x_max)/2, y: (y_min+y_max)/2)
    }
    
    func calOrientation() {
        let marker_1 = markerChildren[0]
        let marker_2 = markerChildren[1]
        let dx = marker_1.position.x - marker_2.position.x
        let dy = marker_1.position.y - marker_2.position.y
        orientation = atan2(dy, dx)
    }
    
    func calVelocity() {
        let num = CGFloat(timeArray.count)
        // time
        let t1 = timeArray[0...(Int(num/2)-1)]
        let t2 = timeArray[Int(num/2)...(Int(num)-1)]
        let t1avg = t1.reduce(0, +)/Double(t1.count)
        let t2avg = t2.reduce(0, +)/Double(t2.count)
        let dt = t2avg - t1avg
        // position
        let index_1 = num/4
        let index_2 = num*3/4
        let pos_1 = posArray[Int(index_1.rounded(.up))]
        let pos_2 = posArray[Int(index_2.rounded(.up))]
        let d_pos = pos_2 - pos_1
        // orientation
        let ori_1 = oriArray[Int(index_1.rounded(.up))]
        let ori_2 = oriArray[Int(index_2.rounded(.up))]
        let d_ori = ori_2 - ori_1
        // calculate
        posVel.dx = d_pos.x/dt
        posVel.dy = d_pos.y/dt
        angVel = d_ori/dt
    }
    
    func addLines() -> CGFloat {
        self.removeAllChildren()
        let path = CGMutablePath()
        path.move(to: markerChildren.first!.position)
        for node in markerChildren {
            path.addLine(to: node.position)
        }
        if markerChildren.count > 2 {
            path.addLine(to: markerChildren.first!.position)
        }
        
        let lines = SKShapeNode(path: path, centered: true)
        if isHighlighted {
            lines.strokeColor = .red
        }
        
        let length = distanceCGPointsSK(markerChildren.first!.position, markerChildren.last!.position)
        depth = lineLength / length
        self.addChild(lines)
        
        return length
    }
    
    func highlightLink() {
        isHighlighted = true
    }
    
    func highlightLinkOff() {
        isHighlighted = false
    }
    
    func update() {
        _ = addLines()
        calMidPosition()
        calOrientation()
        self.position = midPositionOfMarkers
        
        // for calculating velocity
        currentTime = App.state.sceneView.session.currentFrame!.timestamp.magnitude
        posArray.removeFirst()
        oriArray.removeFirst()
        timeArray.removeFirst()
        posArray.append(midPositionOfMarkers)
        oriArray.append(orientation)
        timeArray.append(currentTime)
        
        // calculating velocity
        calVelocity()
        
    }
}
