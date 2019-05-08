//
//  YourChartUsingViewController.swift
//  KChartDemoiOSTaipeh
//
//  Created by Wei Jen Wang on 2019/5/8.
//  Copyright © 2019 Wei Jen Wang. All rights reserved.
//

import UIKit

class YourChartUsingViewController: UIViewController {
    @IBOutlet weak var todaysButton: UIButton!
    @IBOutlet weak var candlesButton: UIButton!
    @IBOutlet weak var maButton: UIButton!
    @IBOutlet weak var bollButton: UIButton!
    @IBOutlet weak var arbrButton: UIButton!
    @IBOutlet weak var macdButton: UIButton!

    @IBAction func todaysClicked() {
        chartViewController?.drawMountain()
        
        maButton.isHidden = true
        bollButton.isHidden = true
        arbrButton.isHidden = true
        macdButton.isHidden = true
    }
    
    @IBAction func candlesClicked() {
        chartViewController?.selectedKTechType = .None
        chartViewController?.drawKLine()
        
        maButton.isHidden = false
        bollButton.isHidden = false
        arbrButton.isHidden = false
        macdButton.isHidden = false
    }

    @IBAction func maClicked() {
        chartViewController?.selectedKTechType = .MA
        chartViewController?.drawKLine()
    }
    
    @IBAction func bollClicked() {
        chartViewController?.selectedKTechType = .BOLL
        chartViewController?.drawKLine()
    }
    
    @IBAction func arbrClicked() {
        chartViewController?.selectedTechType = .ARBR
        chartViewController?.drawKLine()
    }
    
    @IBAction func macdClicked() {
        chartViewController?.selectedTechType = .MACD
        chartViewController?.drawKLine()
    }
    
    var chartViewController: ChartViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        chartViewController = segue.destination as? ChartViewController
    }
}
