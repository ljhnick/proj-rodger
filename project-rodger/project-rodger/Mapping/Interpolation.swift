//
//  Interpolation.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/21/22.
//

import ARKit
import SpriteKit
import SceneKit

class InterpolationNode: MappingNode {
//    var reference: SKNode?
//    var states = StatesNode()
    var repeatedTime = 6
    var inputStates = Array(repeating: CGFloat.zero, count: 3)
    var outputStatesNonTransformation = Array(repeating: CGFloat.zero, count: 3)
    var outputStatesTransformation = Array(repeating: [SIMD2<Float>](), count: 3)
    
    
    var inputType = App.state.STATES
    var outputType = App.state.STATES
    
    var uInput = CGFloat()
    var uOutputNonT = CGFloat()
    var uOutputT = [SIMD2<Float>]()
    
    func setup() {
        if outputType == App.state.STATES_TRANSFORMATION {
            if let output = outputNode as? GraphicsNode {
                output.setupTransformationControl()
            }
        }
        
        let numOfMappings = App.state.mappingNodes.count
        self.name = "Mapping #\(numOfMappings), type: Interpolation"
        
        
    }
    
    func addAStateIn(index: Int, updateVal: CGFloat? = nil) {
        getCurrentInputU()
        inputStates[index] = uInput
        if updateVal != nil {
            uInput = updateVal!
            inputStates[index] = uInput
        }
    }
    
    func addAStateOut(index: Int, updateVal: CGFloat? = nil) {
        getCurrentOutput()
        if outputType == App.state.STATES_TRANSFORMATION {
            outputStatesTransformation[index] = uOutputT
        } else {
            if updateVal != nil {
                uOutputNonT = updateVal!
            }
            outputStatesNonTransformation[index] = uOutputNonT
        }

    }
    
    func getCurrentInputU() {
        switch inputType {
        case App.state.STATES_POSITION_X:
            uInput = convertPointToReference(point: inputNode!.position, reference: self.reference).x
        case App.state.STATES_POSITION_Y:
            uInput = convertPointToReference(point: inputNode!.position, reference: self.reference).y
        case App.state.STATES_ORI:
            if let input = inputNode as? LinkNode {
                uInput = input.orientation
            }
            if let input = inputNode as? GraphicsNode {
                uInput = input.zRotation
            }
        case App.state.STATES_VELOCITY_MAG:
            if let input = inputNode as? LinkNode {
                uInput = sqrt(input.posVel.dx * input.posVel.dx + input.posVel.dy * input.posVel.dy)
            }
        case App.state.STATES_VELOCITY_X:
            if let input = inputNode as? LinkNode {
                uInput = input.posVel.dx
            }
        case App.state.STATES_VELOCITY_Y:
            if let input = inputNode as? LinkNode {
                uInput = input.posVel.dy
            }
        case App.state.STATES_ANGULAR_VEL:
            if let input = inputNode as? LinkNode {
                uInput = input.angVel
            }
        case App.state.STATES_ANGLE:
            if let input = inputNode as? MarkerNode {
                uInput = input.ang
            }
        case App.state.STATES_ANGLE_VEL:
            if let input = inputNode as? MarkerNode {
                uInput = input.angVel
            }
        case App.state.STATES_DEPTH:
            if let input = inputNode as? LinkNode {
                uInput = input.depth
            }
        default:
            uInput = 0
        }
    }
    
    func getCurrentOutput() {
        if outputType == App.state.STATES_TRANSFORMATION {
            getWarpingGeometry()
            return
        }
        switch outputType {
        case App.state.STATES_POSITION_OUTPUT:
            if let input = outputNode as? GraphicsNode {
                uOutputNonT = input.position.x
            }
        case App.state.STATES_SCALE:
            if let input = outputNode as? GraphicsNode {
                uOutputNonT = input.xScale
            }
        case App.state.STATES_VISIBILITY:
            if let input = outputNode as? GraphicsNode {
                uOutputNonT = input.alpha
            }
        default:
            uOutputNonT = 0
        }
    }
    
    func getWarpingGeometry() {
        if let output = outputNode as? GraphicsNode {
            uOutputT = output.transformationControl
        }
    }
    
    func interpolateWarpingGeometry(u: CGFloat) {
//        let outputTransformation = [SIMD2<Float>]()
        if let output = outputNode as? GraphicsNode {
            for i in 0..<output.warpGeometryGrid.vertexCount {
                let x0 = outputStatesTransformation[0][i].x
                let y0 = outputStatesTransformation[0][i].y
                let x1 = outputStatesTransformation[1][i].x
                let y1 = outputStatesTransformation[1][i].y
                uOutputT[i].x = x0 + Float(u)*(x1-x0)
                uOutputT[i].y = y0 + Float(u)*(y1-y0)
            }
            output.applyWarping(warping: uOutputT)
        }
    }
    
    func interpolateOutput(u: CGFloat) {
        if outputType == App.state.STATES_TRANSFORMATION {
            interpolateWarpingGeometry(u: u)
            return
        }
        
        let outputVal = outputStatesNonTransformation[0] + (outputStatesNonTransformation[1] - outputStatesNonTransformation[0]) * u
        switch outputType {
        case App.state.STATES_POSITION_OUTPUT:
            ()
        case App.state.STATES_SCALE:
            if let output = outputNode as? GraphicsNode {
                output.setScale(outputVal)
            }
        case App.state.STATES_VISIBILITY:
            if let output = outputNode as? GraphicsNode {
                output.alpha = outputVal
            }
        default:
            ()
        }
    }
    
    func convertPointToReference(point: CGPoint, reference: SKNode?) -> CGPoint {
        guard let ref = reference else { return point }
        return convert(point, to: ref)
    }
    
    override func setupStatesInputOutput() {
        if App.state.updatingTarget == App.state.UPDATE_INPUT_TARGET {
            inputType = App.state.STATES
            App.state.mappingViewController.inTargetText.text = inputNode!.name! + App.state.mappingViewController.stringifyStatesType(stateTag: App.state.STATES)
        } else if App.state.updatingTarget == App.state.UPDATE_OUTPUT_TARGET {
            outputType = App.state.STATES
            App.state.mappingViewController.outTargetText.text = outputNode!.name! + App.state.mappingViewController.stringifyStatesType(stateTag: App.state.STATES)
        }
        
        if inputType != App.state.STATES_NONE && outputType != App.state.STATES_NONE {
            setup()
        }
    }
    
    override func updateMapping() {
        if !activateStatus { return }
        
        getCurrentInputU()
        getCurrentOutput()
        if isSetup {
            
            if repeatedTime == 1 {
                var u = (uInput - inputStates[0])/(inputStates[1] - inputStates[0])
                u = (u < 0) ? 0 : u
                u = (u > 1) ? 1 : u
                interpolateOutput(u: u)
            } else {
                let max = max(inputStates[0], inputStates[1])
                let min = min(inputStates[0], inputStates[1])
                let interval = Double((max - min)) / Double(repeatedTime)
                let phase = floor((Double(uInput) - min) / interval)
                let start = min + interval*phase
//                let end = min + interval*(phase+1)
                let localU = (uInput - start)/(interval)
                
                if phase < 0 {
                    interpolateOutput(u: 0)
                } else if Int(phase) > repeatedTime {
                    interpolateOutput(u: 1)
                } else if Int(phase) % 2 == 1 {
                    interpolateOutput(u: localU)
                } else if Int(phase) % 2 == 0 {
                    interpolateOutput(u: 1-localU)
                }
                
            }
            
        }
    }
    
    override func activateMapping() {
        if inputNode != nil && outputNode != nil {
            isSetup = true
        }
    }
    
    override func isBeingUpdated() {
        if outputType == App.state.STATES_TRANSFORMATION {
            if let output = outputNode as? GraphicsNode {
                output.showControlPoints()
            }
//            activateStatus = false
        }
    }
    
    override func didBeingUpdated() {
        if outputType == App.state.STATES_TRANSFORMATION {
            if let output = outputNode as? GraphicsNode {
                output.hideControlPoints()
            }
        }
        
        activateStatus = true
    }
    
}
