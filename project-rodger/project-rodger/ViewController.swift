//
//  ViewController.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/14/22.
//

import UIKit
import SpriteKit
import ARKit
import Charts
import TinyConstraints

class ViewController: UIViewController, ARSKViewDelegate, ChartViewDelegate {
     
    @IBOutlet var sceneView: ARSKView!
    
    // Load the SKScene from 'Scene.sks'
    var skScene = Scene(fileNamed: "Scene")!
    
    @IBOutlet weak var drawView: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var worldView: UIView!
    @IBOutlet weak var endUserView: UIView!
    
    var buttonMenu = UIButton()
    var buttonMenuList = [UIButton]()
    var currentNode = SKNode()
    
    var velChart = LineChartView()
    
    @IBOutlet weak var currentMode: UISegmentedControl!
    
    @IBAction func switchMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            drawView.isHidden = false
            mapView.isHidden = true
            saveView.isHidden = true
            worldView.isHidden = true
            endUserView.isHidden = true
            skScene.btnDraw()
        } else if sender.selectedSegmentIndex == 1{
            drawView.isHidden = true
            mapView.isHidden = false
            saveView.isHidden = false
            worldView.isHidden = true
            endUserView.isHidden = true
            skScene.btnMapping()
            App.state.mappingViewController.toggleSubTypeAction(App.state.mappingViewController.toggleSubType)
        } else {
            drawView.isHidden = true
            mapView.isHidden = true
            saveView.isHidden = true
            worldView.isHidden = false
            endUserView.isHidden = true
        }
    }
    
    @IBAction func hideViews(_ sender: UISegmentedControl) {
        // developer mode and end-user mode
        if sender.selectedSegmentIndex == 2 {
            drawView.isHidden = true
            mapView.isHidden = true
            saveView.isHidden = true
            worldView.isHidden = true
        } else if sender.selectedSegmentIndex == 1{
            // end user interface
            drawView.isHidden = true
            mapView.isHidden = true
            saveView.isHidden = true
            worldView.isHidden = true
            endUserView.isHidden = false
            App.state.currentState = App.state.STATE_ENDUSER
            
        } else {
            switchMode(currentMode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        sceneView.showsPhysics = true
        
        App.state.sceneView = sceneView
                
        // Load the SKScene from 'Scene.sks'
        App.state.scene = skScene
        skScene.scaleMode = .resizeFill
        sceneView.presentScene(App.state.scene)
        
        skScene.physicsBody = SKPhysicsBody(edgeLoopFrom: skScene.frame)
        
        App.state.mainViewController = self
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    func createButtonMenu(position: CGPoint, node: SKNode) {
        buttonMenu = UIButton(type: .system)
        buttonMenu.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        let name = "  \(node.name!)  "
        buttonMenu.setTitle(name, for: .normal)
        buttonMenu.setTitleColor(.white, for: .normal)
        buttonMenu.center = position
        buttonMenu.backgroundColor = .systemBlue
        buttonMenu.layer.cornerRadius = 5
        buttonMenu.sizeToFit()
        
        let position_XY = UIAction(title: "Position (X, Y)" , handler: { _ in
            App.state.STATES = App.state.STATES_POSITION_MAG
            App.state.mappingTemp.inputNode = node
            App.state.mappingViewController.inValue1.text = "click&drag"
            self.hideButtonMenu()
        })
        
        let position_X = UIAction(title: "Position X" , handler: { _ in
            App.state.STATES = App.state.STATES_POSITION_X
            App.state.mappingTemp.inputNode = node
            self.hideButtonMenu()
        })
        
        let position_Y = UIAction(title: "Position Y" , handler: { _ in
            App.state.STATES = App.state.STATES_POSITION_Y
            App.state.mappingTemp.inputNode = node
            self.hideButtonMenu()
        })
        
        let orientation = UIAction(title: "Orientation" , handler: { _ in
            App.state.STATES = App.state.STATES_ORI
            App.state.mappingTemp.inputNode = node
            self.hideButtonMenu()
        })
        
        let vel_mag = UIAction(title: "Velocity Magnitude" , handler: { _ in
            App.state.STATES = App.state.STATES_VELOCITY_MAG
            App.state.mappingTemp.inputNode = node
            // show the record button
            App.state.mappingViewController.btnRecord.isHidden = false
            self.hideButtonMenu()
        })
        
        let vel_x = UIAction(title: "Velocity X" , handler: { _ in
            App.state.STATES = App.state.STATES_VELOCITY_X
            App.state.mappingTemp.inputNode = node
            // show the record button
            App.state.mappingViewController.btnRecord.isHidden = false
            self.hideButtonMenu()
        })
        
        let vel_y = UIAction(title: "Velocity Y" , handler: { _ in
            App.state.STATES = App.state.STATES_VELOCITY_Y
            App.state.mappingTemp.inputNode = node
            // show the record button
            App.state.mappingViewController.btnRecord.isHidden = false
            self.hideButtonMenu()
        })
        
        let vel_ang = UIAction(title: "Angular Velocity" , handler: { _ in
            App.state.STATES = App.state.STATES_ANGULAR_VEL
            App.state.mappingTemp.inputNode = node
            // show the record button
            App.state.mappingViewController.btnRecord.isHidden = false
            self.hideButtonMenu()
        })
        
        let joint_ang = UIAction(title: "Angle" , handler: { _ in
            App.state.STATES = App.state.STATES_ANGLE
            App.state.mappingTemp.inputNode = node
            self.hideButtonMenu()
        })
        
        let joint_ang_vel = UIAction(title: "Angular Velocity" , handler: { _ in
            App.state.STATES = App.state.STATES_ANGLE_VEL
            App.state.mappingTemp.inputNode = node
            // show the record button
            App.state.mappingViewController.btnRecord.isHidden = false
            self.hideButtonMenu()
        })
        
        let depth = UIAction(title: "Depth" , handler: { _ in
            App.state.STATES = App.state.STATES_DEPTH
            App.state.mappingTemp.inputNode = node
            self.hideButtonMenu()
        })
        
        if !(App.state.mappingTemp is SwitchingNode) {
            position_XY.attributes = .disabled
        }
        
        if App.state.updatingTarget == App.state.UPDATE_INPUT_TARGET {
            // check if the input target
            if node is GraphicsNode {
                let position = UIMenu(title: "Position", children: [position_XY, position_X, position_Y])
                let velocity = UIMenu(title: "Velocity", children: [vel_mag, vel_x, vel_y, vel_ang])
                
                let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [position, velocity, orientation])
                buttonMenu.menu = menu
            } else if node is LinkNode {
                let position = UIMenu(title: "Position", children: [position_XY, position_X, position_Y])
                let velocity = UIMenu(title: "Velocity", children: [vel_mag, vel_x, vel_y, vel_ang])
                
                let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [position, velocity, depth, orientation])
                buttonMenu.menu = menu
            } else if node is MarkerNode {
                let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [joint_ang, joint_ang_vel])
                buttonMenu.menu = menu
            }
        }
        
        // continuous graphical properties of the output
        let transform = UIAction(title: "Transformation" , handler: { _ in
            App.state.STATES = App.state.STATES_TRANSFORMATION
            self.hideButtonMenu()
        })
        let position = UIAction(title: "Position" , handler: { _ in
            App.state.STATES = App.state.STATES_POSITION_OUTPUT
            self.hideButtonMenu()
        })
        let scale = UIAction(title: "Scale" , handler: { _ in
            App.state.STATES = App.state.STATES_SCALE
            self.hideButtonMenu()
        })
        let visibility = UIAction(title: "Visibility" , handler: { _ in
            App.state.STATES = App.state.STATES_VISIBILITY
            self.hideButtonMenu()
        })
        
        let physics = UIAction(title: "Change physics" , handler: { _ in
            App.state.STATES = App.state.STATES_PHYSIC_RELATION
            self.hideButtonMenu()
            App.state.mappingViewController.outValue1.text = "click&connect"
        })
        
        let change_graph = UIAction(title: "Change graphics" , handler: { _ in
            App.state.STATES = App.state.STATES_CHANGE_GRAPHICS
            self.hideButtonMenu()
            App.state.mappingViewController.outValue1.text = "click&draw"
        })
        
        let change_color = UIAction(title: "Change color" , handler: { _ in
            App.state.STATES = App.state.STATES_COLOR_CHANGE
            self.hideButtonMenu()
            App.state.mappingViewController.isColorBtnHidden(false)
            App.state.mappingViewController.outValue1.text = "click&choose"
            App.state.mappingViewController.outValue2.text = "click&choose"
        })
        
        if !(App.state.mappingTemp is SwitchingNode) {
            change_graph.attributes = .disabled
            change_color.attributes = .disabled
            physics.attributes = .disabled
        }
        
        
        if App.state.updatingTarget == App.state.UPDATE_OUTPUT_TARGET {
            App.state.mappingTemp.outputNode = node

            let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [transform, scale, visibility, physics, change_graph, change_color])
            buttonMenu.menu = menu
        }

        buttonMenu.showsMenuAsPrimaryAction = true
        buttonMenuList.append(buttonMenu)
        
        self.view.addSubview(buttonMenu)
        
    }
    
    func hideButtonMenu() {
        App.state.mappingTemp.setupStatesInputOutput()
        
//        let textInTarget = App.state.mappingTemp.inputNode?.name
//        App.state.mappingViewController.inTargetText.text = App.state.mappingTemp.inputNode?.name
//        App.state.mappingViewController.outTargetText.text = App.state.mappingTemp.outputNode?.name
        
        for menu in buttonMenuList {
            menu.removeFromSuperview()
        }
        
        App.state.mappingViewController.inTargetText.endEditing(true)
        App.state.mappingViewController.outTargetText.endEditing(true)
        buttonMenuList = [UIButton]()
        App.state.updatingStatus = false
        App.state.updatingTarget = 0
        App.state.STATES = App.state.STATES_NONE
    }
    
    func creatChart(time: [TimeInterval], value: [CGFloat]) {
        let chartView = LineChartView()
        self.velChart = chartView
        chartView.delegate = self
        
        let dataSet = createDataEntries(time: time, value: value)
        let set1 = LineChartDataSet(entries: dataSet, label: "velocity")
//        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 3
        set1.setColor(.white)
        set1.highlightColor = .systemRed
        set1.highlightLineWidth = 2
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        
        chartView.data = data
        
//        chartView.centerInSuperview()
        self.view.addSubview(chartView)
        chartView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        chartView.center = CGPoint(x: 450, y: 400)
        
        chartView.doubleTapToZoomEnabled = false
        
//        var entry = [ChartDataEntry]()
//        for x in 0..<10 {
//            entry.append(ChartDataEntry(x: Double(x), y: Double(x)))
//        }
//        let set1 = LineChartDataSet(entries: entry, label: "")
//        set1.colors = [.white]
//
//        chartView.delegate = self
////        chartView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
//        self.view.addSubview(chartView)
////        chartView.center = CGPoint(x: 500, y: 500)
//
//        chartView.centerInSuperview()
//        chartView.width(500)
//        chartView.height(500)
//
//        set1.lineWidth = 5
//        let data = LineChartData(dataSet: set1)
//        chartView.data = data
//
//        chartView.backgroundColor = .systemBlue
    }
    
    func createDataEntries(time: [TimeInterval], value: [CGFloat]) -> [ChartDataEntry] {
        var entry = [ChartDataEntry]()
        for (i, _) in time.enumerated() {
            entry.append(ChartDataEntry(x: Double(time[i]), y: value[i]))
        }
        
        return entry
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        App.state.selectedVelocity = CGFloat(entry.y)
    }
}
