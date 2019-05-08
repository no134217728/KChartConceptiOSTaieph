//
//  ChartViewController.swift
//  KChartDemoiOSTaipeh
//
//  Created by Wei Jen Wang on 2019/5/8.
//  Copyright © 2019 Wei Jen Wang. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    @IBOutlet weak var kLineView: UIView!
    @IBOutlet weak var topLabelsView: UIView!
    @IBOutlet weak var leftLabelsView: UIView!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var chartsScrollView: UIScrollView!
    @IBOutlet weak var chartUsingRightView: UIView!
    @IBOutlet weak var rightLabelsView: UIView!
    @IBOutlet weak var bottomLabelsView: UIView!
    
    @IBOutlet weak var techView: UIView!
    @IBOutlet weak var techTopLablesView: UIView!
    @IBOutlet weak var techLeftLabelsView: UIView!
    @IBOutlet weak var techGridView: UIView!
    @IBOutlet weak var techScrollView: UIScrollView!
    @IBOutlet weak var techRightLabelsView: UIView!
    @IBOutlet weak var techBottomLabelsView: UIView!
    
    @IBOutlet weak var currentLineView: UIView!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    @IBOutlet weak var constraintTopLabelsHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintLeftLabelsWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintChartUsingRightWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintRightLabelsWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomLabelsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintTechViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTechTopHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTechUsingRightWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintTechBottomHeight: NSLayoutConstraint!
}

extension ChartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
