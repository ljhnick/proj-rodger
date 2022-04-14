//
//  DrawingViewController.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/23/22.
//

import UIKit
import SpriteKit
import ARKit

class DrawingViewController: UIViewController {
    
    // Load the SKScene from 'Scene.sks'
    var skScene = Scene(fileNamed: "Scene")!
    
    var graphicButtonList = [UIButton]()
    
    @IBAction func btnRig(_ sender: Any) {
        skScene.btnRig()
    }
    
    @IBAction func btnDraw(_ sender: Any) {
        skScene.btnDraw()
    }
    
    @IBAction func btnGroup(_ sender: Any) {
        skScene.btnGroup()
    }
    
    @IBAction func btnReset(_ sender: Any) {
        App.state.restart()
    }

    @IBAction func btnPickColor(_ sender: Any) {
        App.state.isPickingColor = true
    }
    
    @IBAction func colorWhite(_ sender: Any) {
        App.state.DRAWING_COLOR = .white
    }
    @IBAction func colorBlue(_ sender: Any) {
        App.state.DRAWING_COLOR = .blue
    }
    @IBAction func colorYellow(_ sender: Any) {
        App.state.DRAWING_COLOR = .yellow
    }
    @IBAction func colorRed(_ sender: Any) {
        App.state.DRAWING_COLOR = .red
    }
    @IBAction func colorPurple(_ sender: Any) {
        App.state.DRAWING_COLOR = .purple
    }
    @IBAction func colorGreen(_ sender: Any) {
        App.state.DRAWING_COLOR = .green
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.state.drawingViewController = self
    }
    
    func updateDrawingList() {
        for btn in graphicButtonList {
            btn.removeFromSuperview()
        }
        graphicButtonList.removeAll()
        
        for (i, graphic) in App.state.drawingNodes.enumerated() {
            let btn = UIButton(type: .system)
            btn.backgroundColor = .systemMint
            btn.setTitle(graphic.name, for: .normal)
            self.view.addSubview(btn)
            graphicButtonList.append(btn)
            
            btn.addTarget(self, action: #selector(deleteDrawing), for: .touchUpInside)
            
            let width = 100
            btn.frame = CGRect(x: Int(view.frame.midX+CGFloat(width*i)), y: 0, width: width, height: 30)
            btn.layer.cornerRadius = 5
            btn.setTitleColor(.white, for: .normal)
        }
    }
    
    @objc func deleteDrawing(sender: UIButton!) {
        let index = graphicButtonList.firstIndex(of: sender)
        let graphic = App.state.drawingNodes[index!]
        App.state.drawingNodes.remove(at: index!)
        graphic.removeFromParent()
//        graphicButtonList[index!].removeFromSuperview()
        updateDrawingList()
    }
}
