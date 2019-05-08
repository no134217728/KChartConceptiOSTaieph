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
    @IBOutlet weak var techUsingRightView: UIView!
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
    
    var candleWidth: Double = 5
    var candles: [CandleItems] = []
    
    var startCandle: Int = 0
    var visibleCount: Int = 0
    
    var dottedLineLength = 5
    var decimalPlaces: UInt8 = 5
    var techDecimalPlaces: UInt8 = 2
    
    var horizontalLines = 0
    var techHorizontalLines = 0
    var verticalLines = 0
    
    var currentRightLabels: [UILabel] = []
    var currentBottomLables: [UILabel] = []
    var currentTechRightLabels: [UILabel] = []
    
    var rightMax: Double = 0
    var rightMin: Double = 0
    var rightDiff: Double {
        return rightMax - rightMin
    }
    var techRightMax: Double = 0
    var techRightMin: Double = 0
    var techRightDiff: Double {
        return techRightMax - techRightMin
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "PreviousCandles", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
                return
        }
        
        do {
            let json = try JSONDecoder().decode(CandlesModel.self, from: data)
            candles = json.candleItems
        } catch {
            print("candles decode fail")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        visibleCount = Int(gridView.frame.width / CGFloat(candleWidth))
        
        drawKLine()
    }
    
    // MARK: 繪圖呼叫
    func drawKLine(contentOffsetXType: ContentOffsetType = .ToLast) {
        chartsScrollView.isScrollEnabled = true
        
        constraintChartUsingRightWidth.constant = CGFloat(Double(candles.count) * candleWidth)
        constraintTechUsingRightWidth.constant = constraintChartUsingRightWidth.constant
        constraintTechViewHeight.constant = 180
        view.layoutIfNeeded()
        
        drawBasicGridAndSetupBasicRightBottomLabels(horLines: 3, verLines: 2)
        drawTechGridAndSetupTechRightLabels(techHorLines: 2)
        
        switch contentOffsetXType {
        case .Current:
            let x = candleWidth / 2 + Double(startCandle) * candleWidth
            chartsScrollView.contentOffset = CGPoint(x: x, y: 0)
        case .ToLast:
            chartsScrollView.contentOffset = CGPoint(x: constraintChartUsingRightWidth.constant - chartsScrollView.frame.width, y: 0)
        }

        findRightMaxMinAndUpdateTheLabelsThenRedraw()
        updateTheBottomLabels()
//        drawTech()
    }
    
    private func drawBasicGridAndSetupBasicRightBottomLabels(horLines: Int, verLines: Int) {
        horizontalLines = horLines
        verticalLines = verLines
        
        currentRightLabels = []
        currentBottomLables = []
        gridView.layer.sublayers = []
        
        for lable in rightLabelsView.subviews {
            lable.removeFromSuperview()
        }
        
        for label in bottomLabelsView.subviews {
            label.removeFromSuperview()
        }
        
        let gridBorder = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: gridView.frame.width, height: gridView.frame.height), cornerRadius: 0)
        
        let gridBorderLayer = CAShapeLayer()
        gridBorderLayer.path = gridBorder.cgPath
        gridBorderLayer.lineWidth = 1
        gridBorderLayer.strokeColor = UIColor.black.cgColor
        gridBorderLayer.fillColor = UIColor.clear.cgColor
        gridView.layer.addSublayer(gridBorderLayer)
        
        setupRightLabel(value: String(format: "%.\(decimalPlaces)f", rightMax.roundTo(places: Int(decimalPlaces))), yPosition: 8, rightView: rightLabelsView, storedArray: &currentRightLabels)
        for i in 1...horizontalLines {
            let gridLine = UIBezierPath()
            let gridLineLayer = CAShapeLayer()
            
            let y = gridView.frame.height * CGFloat(Double(i) / Double(horizontalLines + 1))
            
            gridLine.move(to: CGPoint(x: 0, y: y))
            for d in stride(from: 0, through: Int(gridView.frame.width), by: dottedLineLength) {
                if (d / dottedLineLength) % 2 == 0 {
                    gridLine.move(to: CGPoint(x: CGFloat(d), y: y))
                } else {
                    gridLine.addLine(to: CGPoint(x: CGFloat(d), y: y))
                }
            }
            
            gridLineLayer.path = gridLine.cgPath
            gridLineLayer.lineWidth = 1
            gridLineLayer.strokeColor = UIColor.lightGray.cgColor
            gridView.layer.addSublayer(gridLineLayer)
            
            setupRightLabel(value: String(format: "%.\(decimalPlaces)f", (rightMax - rightDiff * Double(i) / Double(horizontalLines + 1)).roundTo(places: Int(decimalPlaces))), yPosition: Int(y), rightView: rightLabelsView, storedArray: &currentRightLabels)
        }
        setupRightLabel(value: String(format: "%.\(decimalPlaces)f", rightMin.roundTo(places: Int(decimalPlaces))), yPosition: Int(rightLabelsView.frame.height) - 8, rightView: rightLabelsView, storedArray: &currentRightLabels)
        
        setupBottomLabel(value: candles[0].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n"), xPosition: 0)
        for i in 1...verticalLines {
            let gridLine = UIBezierPath()
            let gridLineLayer = CAShapeLayer()
            
            let x = gridView.frame.width * CGFloat(Double(i) / Double(verticalLines + 1))
            
            gridLine.move(to: CGPoint(x: x, y: 0))
            for d in stride(from: 0, through: Int(gridView.frame.height), by: dottedLineLength) {
                if (d / dottedLineLength) % 2 == 0 {
                    gridLine.move(to: CGPoint(x: x, y: CGFloat(d)))
                } else {
                    gridLine.addLine(to: CGPoint(x: x, y: CGFloat(d)))
                }
            }
            
            gridLineLayer.path = gridLine.cgPath
            gridLineLayer.lineWidth = 1
            gridLineLayer.strokeColor = UIColor.lightGray.cgColor
            gridView.layer.addSublayer(gridLineLayer)
            
            let offset = Int(Double(visibleCount) * Double(i) / Double(verticalLines + 1))
            setupBottomLabel(value: candles[max(0, min(candles.count - 1, offset))].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n"), xPosition: Int(x))
        }
        setupBottomLabel(value: candles[min(candles.count - 1, Int(gridView.frame.width / CGFloat(candleWidth)))].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n"), xPosition: Int(bottomLabelsView.frame.width))
    }
    
    private func setupRightLabel(value: String, yPosition: Int, rightView: UIView, storedArray: inout [UILabel]) {
        let label = UILabel(frame: CGRect(x: 0, y: yPosition - 8, width: Int(rightView.frame.width), height: 16))
        label.text = value
        label.font = UIFont.systemFont(ofSize: 12)
        rightView.addSubview(label)
        storedArray.append(label)
    }
    
    private func setupBottomLabel(value: String, xPosition: Int) {
        let label = UILabel(frame: CGRect(x: xPosition, y: 0, width: 100, height: 16))
        label.numberOfLines = 0
        label.text = value
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.frame = CGRect(x: label.frame.origin.x - (label.frame.size.width / 2), y: 0, width: label.frame.width, height: label.frame.height)
        label.textAlignment = .center
        bottomLabelsView.addSubview(label)
        currentBottomLables.append(label)
    }
    
    private func findRightMaxMinAndUpdateTheLabelsThenRedraw() {
        if startCandle + visibleCount < candles.count {
            let visibleCandles = candles[max(0, startCandle)...startCandle + visibleCount]
            rightMax = Double(visibleCandles.map { $0.High }.max() ?? "0") ?? 0
            rightMin = Double(visibleCandles.map { $0.Low }.min() ?? "0") ?? 0
        } else {
            let visibleCandles = candles[startCandle...(candles.count - 1)]
            rightMax = Double(visibleCandles.map { $0.High }.max() ?? "0") ?? 0
            rightMin = Double(visibleCandles.map { $0.Low }.min() ?? "0") ?? 0
        }
        
        rightMax = rightMax + rightDiff * 0.2
        rightMin = rightMin - rightDiff * 0.2
        
        currentRightLabels[0].text = String(format: "%.\(decimalPlaces)f", rightMax.roundTo(places: Int(decimalPlaces)))
        for i in 1..<currentRightLabels.count - 1 {
            currentRightLabels[i].text = String(format: "%.\(decimalPlaces)f", (rightMax - rightDiff * Double(i) / Double(horizontalLines + 1)).roundTo(places: Int(decimalPlaces)))
        }
        currentRightLabels[currentRightLabels.count - 1].text = String(format: "%.\(decimalPlaces)f", rightMin.roundTo(places: Int(decimalPlaces)))
        
        drawTheChartUsingRight()
    }
    
    private func drawTheChartUsingRight() {
        chartUsingRightView.layer.sublayers = []
        
        for i in max(0, startCandle)...min(candles.count - 1, startCandle + visibleCount) {
            let high = Double(candles[i].High) ?? 0
            let low = Double(candles[i].Low) ?? 0
            let open = Double(candles[i].Open) ?? 0
            let close = Double(candles[i].Close) ?? 0
            
            drawACandle(high: high, low: low, open: open, close: close, sequence: i)
        }
        
//        switch selectedKTechType {
//        case .None:
//            break
//        case .MA:
//            drawKTechUsingRight(values: MAValues)
//        case .BOLL:
//            drawKTechUsingRight(values: BOLLValues)
//        }
    }
    
    private func drawACandle(high: Double, low: Double, open: Double, close: Double, sequence: Int) {
        let x = CGFloat(Double(sequence) * candleWidth) + CGFloat(candleWidth / 2)
        let yHigh = convertPosition(system: .Right, value: high)
        let yLow = convertPosition(system: .Right, value: low)
        let yOpen = convertPosition(system: .Right, value: open)
        let yClose = convertPosition(system: .Right, value: close)
        
        let strokeColor = (close > open) ? UIColor.green.cgColor : UIColor.red.cgColor
        
        let candleHighLowLine = UIBezierPath()
        let candleHighLowLayer = CAShapeLayer()
        
        candleHighLowLine.move(to: CGPoint(x: x, y: yHigh))
        candleHighLowLine.addLine(to: CGPoint(x: x, y: yLow))
        candleHighLowLayer.path = candleHighLowLine.cgPath
        candleHighLowLayer.lineWidth = 1
        candleHighLowLayer.strokeColor = strokeColor
        chartUsingRightView.layer.addSublayer(candleHighLowLayer)
        
        let candleOpenCloseLine = UIBezierPath()
        let candleOpenCloseLayer = CAShapeLayer()
        candleOpenCloseLine.move(to: CGPoint(x: x, y: yOpen))
        candleOpenCloseLine.addLine(to: CGPoint(x: x, y: yClose))
        candleOpenCloseLayer.path = candleOpenCloseLine.cgPath
        candleOpenCloseLayer.lineWidth = CGFloat(candleWidth)
        candleOpenCloseLayer.strokeColor = strokeColor
        chartUsingRightView.layer.addSublayer(candleOpenCloseLayer)
    }
    
    private func updateTheBottomLabels() {
        currentBottomLables[0].text = candles[max(0, startCandle)].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n")
        for i in 1..<currentBottomLables.count - 1 {
            let offset = Int(Double(visibleCount) * Double(i) / Double(verticalLines + 1))
            let candleIndex = startCandle + offset
            currentBottomLables[i].text = candles[max(0, min(candles.count - 1, candleIndex))].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n")
        }
        currentBottomLables[currentBottomLables.count - 1].text = candles[min(candles.count - 1, startCandle + visibleCount)].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n")
    }
    
    // MARK: 下半部技術圖
    private func drawTechGridAndSetupTechRightLabels(techHorLines: Int) {
        techHorizontalLines = techHorLines
        currentTechRightLabels = []
        techGridView.layer.sublayers = []
        
        for label in techRightLabelsView.subviews {
            label.removeFromSuperview()
        }
        
        let techGridBorder = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: techGridView.frame.width, height: techGridView.frame.height), cornerRadius: 0)
        
        let techGridBorderLayer = CAShapeLayer()
        techGridBorderLayer.path = techGridBorder.cgPath
        techGridBorderLayer.lineWidth = 1
        techGridBorderLayer.strokeColor = UIColor.black.cgColor
        techGridBorderLayer.fillColor = UIColor.clear.cgColor
        techGridView.layer.addSublayer(techGridBorderLayer)
        
        setupRightLabel(value: String(format: "%.\(techDecimalPlaces)f", techRightMax.roundTo(places: Int(techDecimalPlaces))), yPosition: 8, rightView: techRightLabelsView, storedArray: &currentTechRightLabels)
        for i in 1...techHorizontalLines {
            let techGridLine = UIBezierPath()
            let techGridLineLayer = CAShapeLayer()
            
            let y = techGridView.frame.height * CGFloat(Double(i) / Double(techHorizontalLines + 1))
            
            techGridLine.move(to: CGPoint(x: 0, y: y))
            for d in stride(from: 0, through: Int(techGridView.frame.width), by: dottedLineLength) {
                if (d / dottedLineLength) % 2 == 0 {
                    techGridLine.move(to: CGPoint(x: CGFloat(d), y: y))
                } else {
                    techGridLine.addLine(to: CGPoint(x: CGFloat(d), y: y))
                }
            }
            
            techGridLineLayer.path = techGridLine.cgPath
            techGridLineLayer.lineWidth = 1
            techGridLineLayer.strokeColor = UIColor.lightGray.cgColor
            techGridView.layer.addSublayer(techGridLineLayer)
            
            setupRightLabel(value: String(format: "%.\(techDecimalPlaces)f", (techRightMax - techRightDiff * Double(i) / Double(techHorizontalLines + 1)).roundTo(places: Int(techDecimalPlaces))), yPosition: Int(y), rightView: techRightLabelsView, storedArray: &currentTechRightLabels)
        }
        setupRightLabel(value: String(format: "%.\(techDecimalPlaces)f", techRightMin.roundTo(places: Int(techDecimalPlaces))), yPosition: Int(techRightLabelsView.frame.height) - 8, rightView: techRightLabelsView, storedArray: &currentTechRightLabels)
        
        for i in 1...verticalLines {
            let gridLine = UIBezierPath()
            let gridLineLayer = CAShapeLayer()
            
            let x = techGridView.frame.width * CGFloat(Double(i) / Double(verticalLines + 1))
            
            gridLine.move(to: CGPoint(x: x, y: 0))
            for d in stride(from: 0, through: Int(techGridView.frame.height), by: dottedLineLength) {
                if (d / dottedLineLength) % 2 == 0 {
                    gridLine.move(to: CGPoint(x: x, y: CGFloat(d)))
                } else {
                    gridLine.addLine(to: CGPoint(x: x, y: CGFloat(d)))
                }
            }
            
            gridLineLayer.path = gridLine.cgPath
            gridLineLayer.lineWidth = 1
            gridLineLayer.strokeColor = UIColor.lightGray.cgColor
            techGridView.layer.addSublayer(gridLineLayer)
        }
    }
    
    // MARK: 公用
    private func convertPosition(system: PositionSystem, value: Double) -> CGFloat {
        switch system {
        case .Right:
            return CGFloat((rightMax - value) / rightDiff) * chartUsingRightView.frame.height
        case .TechRight:
            return CGFloat((techRightMax - value) / techRightDiff) * techUsingRightView.frame.height
        default:
            return 0
        }
    }
}

extension ChartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        startCandle = Int(Double(scrollView.contentOffset.x) / candleWidth)
        
        findRightMaxMinAndUpdateTheLabelsThenRedraw()
//        drawTech()
        updateTheBottomLabels()
//        updateCurrentPriceLine(price: theCurrentPrice)
        
        switch scrollView {
        case chartsScrollView:
            techScrollView.contentOffset = scrollView.contentOffset
        case techScrollView:
            chartsScrollView.contentOffset = scrollView.contentOffset
        default:
            break
        }
    }
}
