//
//  Tracking.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/14/22.
//

import ARKit
import SpriteKit
import SceneKit

extension Scene {

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        guard let sceneView = self.view as? ARSKView else { return }
        guard let frame = sceneView.session.currentFrame else { return }
        
        let image: CIImage
        let pixelBuffer = frame.capturedImage
        image = CIImage(cvImageBuffer: pixelBuffer)
        
        let context = CIContext(options: nil)
        guard let cameraImage = context.createCGImage(image, from: image.extent) else { return }
        App.state.cameraImage = cameraImage
        var src: UIImage? = UIImage(cgImage: cameraImage)
                
        // track the color marker
        var num: Int32 = 0
        var x = [Int32](repeating: 0, count: 30)
        var y = [Int32](repeating: 0, count: 30)
        OpenCV.getMarkersPositions(&src, num: &num, x: &x, y: &y, r: App.state.pickedRed!, g: App.state.pickedGreen!, b: App.state.pickedBlue!)
        
        // detect the color marker
        if App.state.currentState == 0 {
            self.removeAllChildren()
            App.state.markersArrayShapeNode.removeAll()
            App.state.markerNodes.removeAll()
            var i = 0
            while i < num {
                let circle = SKShapeNode(circleOfRadius: 10)
                circle.position = convertPoint(fromView: CGPoint(x: Double(x[i]), y: Double(y[i])))
                circle.position.y += 40
//
//                circle.strokeColor = .brown
//                circle.lineWidth = 1
//                circle.fillColor = .brown
//                circle.name = String(i)
//                self.addChild(circle)
                i += 1
                let markerNode = MarkerNode()
                markerNode.setup(circle)
                let color = getColorAroundMarker(src: src, pos: convertPoint(toView: circle.position))
//                print(color)
                markerNode.setupColor(color!)
                
                App.state.markersArrayShapeNode.append(circle)
                App.state.markerNodes.append(markerNode)
            }
        } else {
            // start rigging
            var i = 0
            while i < num {
                var detectedMarker = convertPoint(fromView: CGPoint(x: Double(x[i]), y: Double(y[i])))
                detectedMarker.y += 40
                for (j, node) in App.state.markersArrayShapeNode.enumerated() {
                    let dist = distanceCGPoints(node.position, detectedMarker)
                    if dist < 40 {
                        App.state.markersArrayShapeNode[j].position = detectedMarker
                        break
                    }
                }
                i += 1
            }
            for node in App.state.markerNodes {
                node.update()
            }
        }
        
        // update the object node
        App.state.object.update()
        
        for node in App.state.mappingNodes {
            node.updateMapping()
        }
        
        if App.state.isRecording {
            App.state.timeArray.append(App.state.sceneView.session.currentFrame!.timestamp.magnitude)
            if let mapping = App.state.mappingTemp as? InterpolationNode {
                mapping.getCurrentInputU()
                App.state.velocityArray.append(mapping.uInput)
            }
            
            if let mapping = App.state.mappingTemp as? SwitchingNode {
                mapping.getCurrentIntput()
                App.state.velocityArray.append(mapping.currentInputValue)
            }
        }
        
    }
}
