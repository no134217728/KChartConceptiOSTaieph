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
        
    }
    
    @IBAction func candlesClicked() {
        
    }

    @IBAction func maClicked() {
        
    }
    
    @IBAction func bollClicked() {
        
    }
    
    @IBAction func arbrClicked() {
        
    }
    
    @IBAction func macdClicked() {
        
    }
    
    var chartViewController: ChartViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        chartViewController = segue.destination as? ChartViewController
    }
}
