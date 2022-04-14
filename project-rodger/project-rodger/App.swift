//
//  App.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/14/22.
//

import UIKit
import SpriteKit
import ARKit

class App {
    private init() {}
    static let state = App()
    
    var sceneView: ARSKView!
    var scene = SKScene()
    
    // States
    var currentState = 0
    var STATE_RIGGING = 1
    var STATE_DRAWING = 2
    var STATE_GROUP = 3
    var STATE_MAPPING = 4
    var STATE_ENDUSER = 5
    
    // Mapping type
    var typeOfMapping = 1
    var TYPE_AFFIXING = 1
    var TYPE_PHYSICS = 2
    var TYPE_SWITCH_STATES = 3
    var TYPE_INTERPOLATION = 4
    
    // Physics type
    var typeOfPhysics = 0
    var PHYSICS_NONE = 1
    var PHYSICS_SPRING = 2
    var PHYSICS_STRING = 3
    
    // Updating mappings
    var updatingStatus = false
    var updatingTarget = 0
    var UPDATE_INPUT_TARGET = 1
    var UPDATE_OUTPUT_TARGET = 2
    var UPDATE_INPUT_VALUE_1 = 3
    var UPDATE_INPUT_VALUE_2 = 4
    var UPDATE_OUTPUT_VALUE_1 = 5
    var UPDATE_OUTPUT_VALUE_2 = 6
    
    // States
    var STATES = 0
    var STATES_NONE = 0
    var STATES_POSITION_MAG = 1
    var STATES_POSITION_X = 2
    var STATES_POSITION_Y = 3
    var STATES_ORI = 4
    var STATES_VELOCITY_MAG = 5
    var STATES_VELOCITY_X = 6
    var STATES_VELOCITY_Y = 7
    var STATES_ANGULAR_VEL = 8
    var STATES_ANGLE = 15
    var STATES_ANGLE_VEL = 16
    var STATES_DEPTH = 19
    
    var STATES_TRANSFORMATION = 9
    var STATES_POSITION_OUTPUT = 10
    var STATES_SCALE = 11
    var STATES_VISIBILITY = 12
    
    var STATES_CHANGE_GRAPHICS = 13
    var STATES_MAPPING_ONOFF_OUTPUT = 14
    var STATES_COLOR_CHANGE = 17
    var STATES_PHYSIC_RELATION = 19
    
    var STATES_MAPPING_ONOFF_INPUT = 18
    
    // different step
    var selectingReference = false
    var isRecording = false
    var isPickingColor = false
    
    // STORAGE
    // Object of the input
    var object = ObjectNode()
    // ---- Input ----- //
    var markersArrayShapeNode = [SKShapeNode]()
    var markerNodes = [MarkerNode]()
    var linkNodes = [LinkNode]()
    var jointNode = [MarkerNode]()
    // ---- Mapping ----- //
    var mappingNodes = [MappingNode]()
    var mappingTemp = MappingNode()
    // ---- Output ----- //
    var drawingNodes = [GraphicsNode]()
    // ---- velocity recording related ---- //
    var timeArray = [TimeInterval]()
    var velocityArray = [CGFloat]()
    var selectedVelocity = CGFloat.zero
    
    // View controllers
    var mainViewController = ViewController()
    var drawingViewController = DrawingViewController()
    var mappingViewController = MappingViewController()
    var savingViewController = SavingViewController()
    var worldViewController = WorldViewController()
    var endUserViewController = EndUserViewController()
    
    // Drawing Parameter
    var DRAWING_LINEWIDTH: CGFloat = 6
    var DRAWING_COLOR: UIColor = .white
    
    // Mis
    var secondPathTemp = CGMutablePath()
    var touchPoint = CGPoint()
    var cameraImage: CGImage?
    var pickedRed: Int32? = 0
    var pickedGreen: Int32? = 0
    var pickedBlue: Int32? = 0
    var addVelocity = false
    var makeStable = false
    
    func restart() {
        scene.removeAllChildren()
        currentState = 0
        object = ObjectNode()
        // ---- Input ----- //
        markersArrayShapeNode = [SKShapeNode]()
        markerNodes = [MarkerNode]()
        linkNodes = [LinkNode]()
        jointNode = [MarkerNode]()
        // ---- Mapping ----- //
        mappingNodes = [MappingNode]()
        mappingTemp = MappingNode()
        // ---- Output ----- //
        drawingNodes = [GraphicsNode]()
    }

}
