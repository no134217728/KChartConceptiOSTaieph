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
    
    @IBOutlet weak var constraintCurrentPriceLineViewTopPosition: NSLayoutConstraint!
    
    let chartManager = ChartManager()
    var isMountain: Bool = false
    
    var candleWidth: Double = 5 {
        didSet {
            visibleCount = Int(gridView.frame.width / CGFloat(candleWidth))
            drawKLine(contentOffsetXType: .Current)
        }
    }
    var candles: [CandleItems] = [] {
        didSet {
            DispatchQueue.global(qos: .userInteractive).async {
                self.MAValues = self.chartManager.computeMA(candles: self.candles)
                self.BOLLValues = self.chartManager.computeBOLL(candles: self.candles)
                
                self.ARBRValues = self.chartManager.computeARBR(candles: self.candles)
                self.ATRValues = self.chartManager.computeATR(candles: self.candles)
                self.BIASValues = self.chartManager.computeBIAS(candles: self.candles)
                self.CCIValues = self.chartManager.computeCCI(candles: self.candles)
                self.MACDValues = self.chartManager.computeMACD(candles: self.candles)
                self.KDValues = self.chartManager.computeKD(candles: self.candles)
                self.KDJValues = self.chartManager.computeKDJ(candles: self.candles)
                self.RSIValues = self.chartManager.computeRSI(candles: self.candles)
            }
        }
    }
    var theCurrentPrice: Double {
        let value = Double(candles.last?.Close ?? "0") ?? 0
        currentPriceLabel.text = String(format: "%.\(decimalPlaces)f", value)
        return value
    }
    
    var startCandle: Int = 0
    var visibleCount: Int = 0
    
    var dottedLineLength = 5
    var decimalPlaces: UInt8 = 5
    var techDecimalPlaces: UInt8 = 2
    var selectedKTechType: KTechType = .None
    var selectedTechType: TechType = .ARBR {
        didSet {
            techUnit = ""
            techDecimalPlaces = 5
            switch selectedTechType {
            case .None:
                break
            case .ARBR:
                techDecimalPlaces = 2
            case .ATR:
                break
            case .BIAS:
                techUnit = "%"
                techDecimalPlaces = 2
            case .CCI:
                techDecimalPlaces = 2
            case .MACD:
                break
            case .KD:
                techDecimalPlaces = 2
            case .KDJ:
                techDecimalPlaces = 2
            case .RSI:
                techDecimalPlaces = 2
            }
        }
    }
    var techUnit: String = ""
    
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
    
    var MAValues: [String: [Double]] = [:]
    var BOLLValues: [String: [Double]] = [:]
    
    var ARBRValues: [String: [Double]] = [:]
    var ATRValues: [String: [Double]] = [:]
    var BIASValues: [String: [Double]] = [:]
    var CCIValues: [String: [Double]] = [:]
    var MACDValues: [String: [Double]] = [:]
    var KDValues: [String: [Double]] = [:]
    var KDJValues: [String: [Double]] = [:]
    var RSIValues: [String: [Double]] = [:]
    
    @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer) {
        let offset: Double = (sender.scale > 1) ? 0.5 : -0.5
        candleWidth = max(2, min(30, candleWidth + offset))
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
        isMountain = false
        
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
        drawTech()
    }
    
    func drawTech() {
        switch selectedTechType {
        case .None:
            break
        case .ARBR:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: ARBRValues)
        case .ATR:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: ATRValues)
        case .BIAS:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: BIASValues)
        case .CCI:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: CCIValues)
        case .MACD:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: MACDValues)
        case .KD:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: KDValues)
        case .KDJ:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: KDJValues)
        case .RSI:
            findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: RSIValues)
        }
    }
    
    func drawMountain() {
        isMountain = true
        
        chartsScrollView.setContentOffset(.zero, animated: false)
        chartsScrollView.isScrollEnabled = false
        
        constraintChartUsingRightWidth.constant = 0
        constraintTechUsingRightWidth.constant = constraintChartUsingRightWidth.constant
        constraintTechViewHeight.constant = 0
        view.layoutIfNeeded()
        
        drawBasicGridAndSetupBasicRightBottomLabels(horLines: 3, verLines: 2)
        
        findRightMaxMinForMountain()
        updateTheBottomLabelsForMountainChart()
        drawTheMountain()
    }
    
    // MARK: 上半部主要線圖
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
        
        switch selectedKTechType {
        case .None:
            break
        case .MA:
            drawKTechUsingRight(values: MAValues)
        case .BOLL:
            drawKTechUsingRight(values: BOLLValues)
        }
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
    
    private func findRightMaxMinForMountain() {
        rightMax = Double(candles.map { $0.High }.max() ?? "0") ?? 0
        rightMin = Double(candles.map { $0.Low }.min() ?? "0") ?? 0
        
        rightMax = rightMax + rightDiff * 0.1
        rightMin = rightMin - rightDiff * 0.1
        
        currentRightLabels[0].text = String(rightMax.roundTo(places: Int(decimalPlaces)))
        for i in 1..<currentRightLabels.count - 1 {
            currentRightLabels[i].text = String((rightMax - rightDiff * Double(i) / Double(horizontalLines + 1)).roundTo(places: Int(decimalPlaces)))
        }
        currentRightLabels[currentRightLabels.count - 1].text = String(rightMin.roundTo(places: Int(decimalPlaces)))
    }
    
    private func updateTheBottomLabelsForMountainChart() {
        currentBottomLables[0].text = candles[0].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n")
        for i in 1..<currentBottomLables.count - 1 {
            let offset = Int(Double(candles.count) * Double(i) / Double(verticalLines + 1))
            currentBottomLables[i].text = candles[max(0, min(candles.count - 1, offset))].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n")
        }
        currentBottomLables[currentBottomLables.count - 1].text = candles[candles.count - 1].Time.replacingOccurrences(of: "Z", with: "").replacingOccurrences(of: "T", with: "\n")
    }
    
    private func drawTheMountain() {
        chartUsingRightView.layer.sublayers = []
        
        var mountainValue: [Double] = []
        for (seq, candle) in candles.enumerated() {
            if seq < 1440 {
                let open = Double(candle.Open) ?? 0
                let close = Double(candle.Close) ?? 0
                mountainValue.append((open + close) / 2)
            }
        }
        
        drawMountainChartAndTheAvgLine(values: mountainValue)
    }
    
    private func drawMountainChartAndTheAvgLine(values: [Double]) {
        let mountainLine = UIBezierPath()
        let mountainLayer = CAShapeLayer()
        let mountainLastLine = UIBezierPath()
        let mountainLastLayer = CAShapeLayer()
        let avgLine = UIBezierPath()
        let avgLayer = CAShapeLayer()
        
        let theFirstValue = convertPosition(system: .Right, value: values[0])
        mountainLine.move(to: CGPoint(x: 0, y: theFirstValue))
        avgLine.move(to: CGPoint(x: 0, y: theFirstValue))
        
        for i in 1...values.count - 1 {
            let pt = CGPoint(x: CGFloat(i) * chartUsingRightView.frame.width / 1440, y: convertPosition(system: .Right, value: values[i]))
            mountainLine.addLine(to: pt)
            
            var sum: Double = 0
            for j in 0...i {
                sum = sum + values[j]
            }
            let avgvalue = sum / (Double(i) + 1)
            let avgPt = CGPoint(x: CGFloat(i) * chartUsingRightView.frame.width / 1440, y: convertPosition(system: .Right, value: avgvalue))
            avgLine.addLine(to: avgPt)
        }
        mountainLine.addLine(to: CGPoint(x: CGFloat(values.count - 1) * chartUsingRightView.frame.width / 1440, y: chartUsingRightView.frame.height))
        mountainLine.addLine(to: CGPoint(x: 0.0, y: chartUsingRightView.frame.height))
        mountainLine.close()
        
        mountainLastLine.move(to: CGPoint(x: CGFloat(values.count - 1) * chartUsingRightView.frame.width / 1440, y: convertPosition(system: .Right, value: values.last ?? 0)))
        mountainLastLine.addLine(to: CGPoint(x: CGFloat(values.count - 1) * chartUsingRightView.frame.width / 1440, y: chartUsingRightView.frame.height))
        
        mountainLayer.path = mountainLine.cgPath
        mountainLayer.lineWidth = 1
        mountainLayer.strokeColor = UIColor.white.cgColor
        mountainLayer.fillColor = UIColor.lightGray.cgColor
        chartUsingRightView.layer.addSublayer(mountainLayer)
        
        mountainLastLayer.path = mountainLastLine.cgPath
        mountainLastLayer.lineWidth = 1
        mountainLastLayer.strokeColor = UIColor.lightGray.cgColor
        chartUsingRightView.layer.addSublayer(mountainLastLayer)
        
        avgLayer.path = avgLine.cgPath
        avgLayer.lineWidth = 1
        avgLayer.strokeColor = UIColor.yellow.cgColor
        avgLayer.fillColor = UIColor.clear.cgColor
        chartUsingRightView.layer.addSublayer(avgLayer)
    }
    
    private func drawKTechUsingRight(values: [String: [Double]]) {
        let keys = values.keys
        
        for key in keys {
            let techLine = UIBezierPath()
            let techLineLayer = CAShapeLayer()
            var strokeColor: CGColor { // TODO: 暫時隨便設定
                switch key {
                case "MA5":
                    return UIColor.yellow.cgColor
                case "MA10":
                    return UIColor.blue.cgColor
                case "MA30":
                    return UIColor.green.cgColor
                case "UP":
                    return UIColor.red.cgColor
                case "MB":
                    return UIColor.blue.cgColor
                case "DN":
                    return UIColor.green.cgColor
                default:
                    return UIColor.lightGray.cgColor
                }
            }
            
            if let selected = values[key], selected.count > 0 {
                let firstValue = convertPosition(system: .Right, value: selected[0])
                techLine.move(to: CGPoint(x: CGFloat(candleWidth / 2), y: firstValue))
                for i in max(1, startCandle)...min(candles.count - 1, startCandle + visibleCount) {
                    let x = CGFloat(Double(i) * candleWidth) + CGFloat(candleWidth / 2)
                    let theValue = convertPosition(system: .Right, value: selected[i])
                    techLine.addLine(to: CGPoint(x: x, y: theValue))
                }
                
                techLineLayer.path = techLine.cgPath
                techLineLayer.lineWidth = 1
                techLineLayer.strokeColor = strokeColor
                techLineLayer.fillColor = UIColor.clear.cgColor
                chartUsingRightView.layer.addSublayer(techLineLayer)
            }
        }
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
    
    private func findTechRightMaxMinAndUpdateTheLabelsThenRedraw(values: [String: [Double]]) {
        var theMaxs: [Double] = []
        var theMins: [Double] = []
        let keys = values.keys
        
        for key in keys {
            let items: [Double] = values[key] ?? []
            var itemMax: Double = 0
            var itemMin: Double = 0
            var itemDiff: Double {
                return itemMax - itemMin
            }
            
            var visibleItems: ArraySlice<Double> = []
            if startCandle + visibleCount < candles.count {
                visibleItems = items[max(0, startCandle)...(startCandle + visibleCount)]
            } else {
                visibleItems = items[startCandle...(candles.count - 1)]
            }
            itemMax = visibleItems.max() ?? 0
            itemMin = visibleItems.min() ?? 0
            
            itemMax = itemMax + itemDiff * 0.1
            itemMin = itemMin - itemDiff * 0.1
            
            theMaxs.append(itemMax)
            theMins.append(itemMin)
        }
        
        techRightMax = theMaxs.max() ?? 0
        techRightMin = theMins.min() ?? 0
        
        currentTechRightLabels[0].text = "\(String(format: "%.\(techDecimalPlaces)f", techRightMax.roundTo(places: Int(techDecimalPlaces)))) \(techUnit)"
        for i in 1..<currentTechRightLabels.count - 1 {
            currentTechRightLabels[i].text = "\(String(format: "%.\(techDecimalPlaces)f", (techRightMax - techRightDiff * Double(i) / Double(techHorizontalLines + 1)).roundTo(places: Int(techDecimalPlaces)))) \(techUnit)"
        }
        currentTechRightLabels[currentTechRightLabels.count - 1].text = "\(String(format: "%.\(techDecimalPlaces)f", techRightMin.roundTo(places: Int(techDecimalPlaces)))) \(techUnit)"
        
        drawTheTechUsingRight(values: values)
    }
    
    private func drawTheTechUsingRight(values: [String: [Double]]) {
        techUsingRightView.layer.sublayers = []
        let keys = values.keys
        
        for key in keys {
            let techLine = UIBezierPath()
            let techLineLayer = CAShapeLayer()
            if key == "OSC" { // MACD 的註狀圖
                if let selected = values["OSC"], selected.count > 0 {
                    for i in max(0, startCandle)...min(candles.count - 1, startCandle + visibleCount) {
                        drawAMACDBarForTech(start: selected[i], sequence: i)
                    }
                }
            } else {
                var strokeColor: CGColor { // TODO: 暫時隨便設定，最後移至全域
                    switch key {
                    case "AR":
                        return UIColor.yellow.cgColor
                    case "BR":
                        return UIColor.blue.cgColor
                    case "DIF":
                        return UIColor.yellow.cgColor
                    case "MACD":
                        return UIColor.white.cgColor
                    case "CCI":
                        return UIColor.yellow.cgColor
                    case "K":
                        return UIColor.blue.cgColor
                    case "D":
                        return UIColor.green.cgColor
                    case "J":
                        return UIColor.red.cgColor
                    case "RSI5":
                        return UIColor.blue.cgColor
                    case "RSI14":
                        return UIColor.green.cgColor
                    case "RSI21":
                        return UIColor.red.cgColor
                    default:
                        return UIColor.lightGray.cgColor
                    }
                }
                
                if let selected = values[key], selected.count > 0 {
                    let firstValue = convertPosition(system: .TechRight, value: selected[max(0, startCandle)])
                    techLine.move(to: CGPoint(x: CGFloat(candleWidth / 2), y: firstValue))
                    for i in max(1, startCandle)...min(candles.count - 1, startCandle + visibleCount) {
                        let x = CGFloat(Double(i) * candleWidth) + CGFloat(candleWidth / 2)
                        let theValue = convertPosition(system: .TechRight, value: selected[i])
                        techLine.addLine(to: CGPoint(x: x, y: theValue))
                    }
                    
                    techLineLayer.path = techLine.cgPath
                    techLineLayer.lineWidth = 1
                    techLineLayer.strokeColor = strokeColor
                    techLineLayer.fillColor = UIColor.clear.cgColor
                    techUsingRightView.layer.addSublayer(techLineLayer)
                }
            }
        }
    }
    
    private func drawAMACDBarForTech(start: Double, sequence: Int) {
        let x = CGFloat(Double(sequence) * candleWidth) + CGFloat(candleWidth / 2)
        let yStart = convertPosition(system: .TechRight, value: start)
        let yEnd = convertPosition(system: .TechRight, value: 0)
        
        let strokeColor = (start > 0) ? UIColor.green.cgColor : UIColor.red.cgColor
        
        let barLine = UIBezierPath()
        let barLayer = CAShapeLayer()
        
        barLine.move(to: CGPoint(x: x, y: yStart))
        barLine.addLine(to: CGPoint(x: x, y: yEnd))
        barLayer.path = barLine.cgPath
        barLayer.lineWidth = CGFloat(candleWidth - 1)
        barLayer.strokeColor = strokeColor
        techUsingRightView.layer.addSublayer(barLayer)
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
    
    private func updateCurrentPriceLine(price: Double) {
        currentLineView.isHidden = !(price < rightMax && price > rightMin) || isMountain
        
        let y = convertPosition(system: .Right, value: price)
        constraintCurrentPriceLineViewTopPosition.constant = y - 8
        view.layoutIfNeeded()
    }
}

extension ChartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        startCandle = Int(Double(scrollView.contentOffset.x) / candleWidth)
        
        findRightMaxMinAndUpdateTheLabelsThenRedraw()
        drawTech()
        updateTheBottomLabels()
        updateCurrentPriceLine(price: theCurrentPrice)
        
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
