//
//  ChartManager.swift
//  KChartDemoiOSTaipeh
//
//  Created by Wei Jen Wang on 2019/5/8.
//  Copyright © 2019 Wei Jen Wang. All rights reserved.
//

import Foundation

class ChartManager {
    // MARK: 上半部技術計算
    func computeMA(candles: [CandleItems]) -> [String: [Double]] {
        var ma5: [Double] = []
        var ma10: [Double] = []
        var ma30: [Double] = []
        
        for i in 0..<candles.count {
            var ma5Sum: Double = 0
            for j in (i - 4)...i {
                //                let v5: Double = (j < 0) ? 0 : Double(candles[j].Close) ?? 0
                let v5: Double = Double(candles[max(0, j)].Close) ?? 0
                ma5Sum += v5
            }
            
            var ma10Sum: Double = 0
            for j in (i - 9)...i {
                //                let v10: Double = (j < 0) ? 0 : Double(candles[j].Close) ?? 0
                let v10: Double = Double(candles[max(0, j)].Close) ?? 0
                ma10Sum += v10
            }
            
            var ma30Sum: Double = 0
            for j in (i - 29)...i {
                //                let v30: Double = (j < 0) ? 0 : Double(candles[j].Close) ?? 0
                let v30: Double = Double(candles[max(0, j)].Close) ?? 0
                ma30Sum += v30
            }
            
            ma5.append(ma5Sum / 5)
            ma10.append(ma10Sum / 10)
            ma30.append(ma30Sum / 30)
        }
        
        return ["MA5": ma5, "MA10": ma10, "MA30": ma30]
    }
    
    func computeBOLL(candles: [CandleItems]) -> [String: [Double]] {
        var up: [Double] = []
        var mb: [Double] = []
        var dn: [Double] = []
        
        for i in 0..<candles.count {
            var mbSum: Double = 0
            for j in (i - 19)...i {
                let v: Double = Double(candles[max(0, j)].Close) ?? 0
                mbSum += v
            }
            let avg = mbSum / 20
            mb.append(avg)
            
            var vSum: Double = 0
            for j in (i - 19)...i {
                let v: Double = (Double(candles[max(0, j)].Close) ?? 0) - avg
                let vv: Double = v * v
                vSum += vv
            }
            
            vSum /= 20
            let sd: Double = sqrt(vSum)
            
            up.append(avg + 2 * sd)
            dn.append(avg - 2 * sd)
        }
        
        return ["UP": up, "MB": mb, "DN": dn]
    }
    
    // MARK: 下半部技術計算
    func computeARBR(candles: [CandleItems]) -> [String: [Double]] {
        var AR: [Double] = []
        var BR: [Double] = []
        
        for i in 0..<candles.count {
            var hoSum: Double = 0
            var olSum: Double = 0
            var hpcSum: Double = 0
            var pclSum: Double = 0
            for j in (i - 25)...i {
                //                let ho: Double = (j < 0) ? 0 : (Double(candles[j].High) ?? 0) - (Double(candles[j].Open) ?? 0)
                //                let ol: Double = (j < 0) ? 0 : (Double(candles[j].Open) ?? 0) - (Double(candles[j].Low) ?? 0)
                let ho: Double = (Double(candles[max(0, j)].High) ?? 0) - (Double(candles[max(0, j)].Open) ?? 0)
                let ol: Double = (Double(candles[max(0, j)].Open) ?? 0) - (Double(candles[max(0, j)].Low) ?? 0)
                hoSum += ho
                olSum += ol
                
                //                let hpc: Double = (j < 0) ? 0 : (Double(candles[j].High) ?? 0) - (Double(candles[j].Close) ?? 0)
                //                let pcl: Double = (j < 0) ? 0 : (Double(candles[j].Close) ?? 0) - (Double(candles[j].Low) ?? 0)
                let hpc: Double = (Double(candles[max(0, j)].High) ?? 0) - (Double(candles[max(0, j)].Close) ?? 0)
                let pcl: Double = (Double(candles[max(0, j)].Close) ?? 0) - (Double(candles[max(0, j)].Low) ?? 0)
                hpcSum += hpc
                pclSum += pcl
            }
            AR.append(hoSum / olSum * 100)
            BR.append(hpcSum / pclSum * 100)
        }
        
        return ["AR": AR, "BR": BR]
    }
    
    func computeATR(candles: [CandleItems]) -> [String: [Double]] {
        var atr21: [Double] = []
        
        var trs: [Double] = []
        for i in 0..<candles.count {
            let hl = (Double(candles[i].High) ?? 0) - (Double(candles[i].Low) ?? 0)
            let ch = abs((Double(candles[max(0, i - 1)].Close) ?? 0) - (Double(candles[i].High) ?? 0))
            let cl = abs((Double(candles[max(0, i - 1)].Close) ?? 0) - (Double(candles[i].Low) ?? 0))
            let tr = max(hl, ch, cl)
            trs.append(tr)
        }
        
        for i in 0..<trs.count {
            var trSum: Double = 0
            for j in (i - 20)...i {
                trSum = trSum + trs[max(0, j)]
            }
            atr21.append(trSum / 21)
        }
        
        return ["ATR": atr21]
    }
    
    func computeBIAS(candles: [CandleItems]) -> [String: [Double]] {
        var bias: [Double] = []
        
        for i in 0..<candles.count {
            var ma20Sum: Double = 0
            for j in (i - 19)...i {
                let v20: Double = Double(candles[max(0, j)].Close) ?? 0
                ma20Sum += v20
            }
            
            let ma20 = ma20Sum / 20
            bias.append(((Double(candles[i].Close) ?? 0) - ma20) / ma20 * 10000)
        }
        
        return ["BIAS": bias]
    }
    
    func computeCCI(candles: [CandleItems]) -> [String: [Double]] {
        var cci: [Double] = []
        
        var ma20s: [Double] = []
        for i in 0..<candles.count {
            var ma20Sum: Double = 0
            for j in (i - 19)...i {
                let v20: Double = Double(candles[max(0, j)].Close) ?? 0
                ma20Sum += v20
            }
            
            let ma20 = ma20Sum / 20
            ma20s.append(ma20)
        }
        
        for i in 0..<candles.count {
            let h = Double(candles[i].High) ?? 0
            let l = Double(candles[i].Low) ?? 0
            let c = Double(candles[i].Close) ?? 0
            let tp = (h + l + c) / 3
            
            let md = ma20s[i] - (Double(candles[i].Close) ?? 0)
            
            let cciValue = (tp - ma20s[i]) / md / 0.015
            cci.append(cciValue)
        }
        
        return ["CCI": cci]
    }
    
    func computeMACD(candles: [CandleItems]) -> [String: [Double]] {
        var dif: [Double] = []
        var macd: [Double] = []
        var osc: [Double] = []
        
        for i in 0..<candles.count {
            var ema12Sum: Double = 0
            for j in (i - 11)...i {
                let e12: Double = (Double(candles[max(0, j)].Close) ?? 0)
                ema12Sum += e12
            }
            
            var ema26Sum: Double = 0
            for j in (i - 25)...i {
                let e26: Double = (Double(candles[max(0, j)].Close) ?? 0)
                ema26Sum += e26
            }
            
            dif.append(ema12Sum / 12 - ema26Sum / 26)
        }
        
        for i in 0..<dif.count {
            var difSum: Double = 0
            for j in (i - 8)...i {
                let d9: Double = dif[max(0, j)]
                difSum += d9
            }
            
            macd.append(difSum / 9)
            osc.append(dif[i] - difSum / 9)
        }
        
        return ["DIF": dif, "MACD": macd, "OSC": osc]
    }
    
    func computeKD(candles: [CandleItems]) -> [String: [Double]] {
        var k: [Double] = []
        var d: [Double] = []
        
        var rsvs: [Double] = []
        for i in 0..<candles.count {
            let subCandles = candles[max(0, i - 8)...i]
            let recently9DaysLow = Double(subCandles.map { $0.Low }.min() ?? "50") ?? 50
            let recently9DaysHigh = Double(subCandles.map { $0.High }.max() ?? "50") ?? 50
            
            let rsv = ((Double(candles[i].Close) ?? 0) - recently9DaysLow) / (recently9DaysHigh - recently9DaysLow) * 100
            rsvs.append(rsv)
        }
        
        for i in 0..<candles.count {
            let previousK: Double = (k.count <= 0) ? 0 : k[i - 1]
            let currentK: Double = (previousK * 2 / 3) + (rsvs[i] / 3)
            
            let previousD: Double = (d.count <= 0) ? 0 : d[i - 1]
            let currentD = (previousD * 2 / 3) + (currentK / 3)
            
            k.append(currentK)
            d.append(currentD)
        }
        
        return ["K": k, "D": d]
    }
    
    func computeKDJ(candles: [CandleItems]) -> [String: [Double]] {
        var k: [Double] = []
        var d: [Double] = []
        var j: [Double] = []
        
        var rsvs: [Double] = []
        for i in 0..<candles.count {
            let subCandles = candles[max(0, i - 8)...i]
            let recently9DaysLow = Double(subCandles.map { $0.Low }.min() ?? "50") ?? 50
            let recently9DaysHigh = Double(subCandles.map { $0.High }.max() ?? "50") ?? 50
            
            let rsv = ((Double(candles[i].Close) ?? 0) - recently9DaysLow) / (recently9DaysHigh - recently9DaysLow) * 100
            rsvs.append(rsv)
        }
        
        for i in 0..<candles.count {
            let previousK: Double = (k.count <= 0) ? 0 : k[i - 1]
            let currentK: Double = (previousK * 2 / 3) + (rsvs[i] / 3)
            
            let previousD: Double = (d.count <= 0) ? 0 : d[i - 1]
            let currentD = (previousD * 2 / 3) + (currentK / 3)
            
            let currentJ = (currentD * 3) - (currentK * 2)
            
            k.append(currentK)
            d.append(currentD)
            j.append(currentJ)
        }
        
        return ["K": k, "D": d, "J": j]
    }
    
    func computeRSI(candles: [CandleItems]) -> [String: [Double]] {
        var rsi5: [Double] = []
        var rsi14: [Double] = []
        var rsi21: [Double] = []
        
        for i in 0..<candles.count {
            var up5: Double = 0
            var dn5: Double = 0
            for j in (i - 4)...i {
                let diff = (Double(candles[max(0, j)].Close) ?? 0) - (Double(candles[max(0, j - 1)].Close) ?? 0)
                if diff > 0 {
                    up5 += abs(diff)
                } else {
                    dn5 += abs(diff)
                }
            }
            up5 /= 5
            dn5 /= 5
            let rs5 = (up5 == 0) ? 0 : up5 / dn5
            let rsi5v = (1 - 1 / (1 + rs5)) * 100
            rsi5.append(rsi5v)
            
            var up14: Double = 0
            var dn14: Double = 0
            for j in (i - 13)...i {
                let diff = (Double(candles[max(0, j)].Close) ?? 0) - (Double(candles[max(0, j - 1)].Close) ?? 0)
                if diff > 0 {
                    up14 += abs(diff)
                } else {
                    dn14 += abs(diff)
                }
            }
            up14 /= 14
            dn14 /= 14
            let rs14 = (dn14 == 0) ? 0 : up14 / dn14
            let rsi14v = (1 - 1 / (1 + rs14)) * 100
            rsi14.append(rsi14v)
            
            var up21: Double = 0
            var dn21: Double = 0
            for j in (i - 20)...i {
                let diff = (Double(candles[max(0, j)].Close) ?? 0) - (Double(candles[max(0, j - 1)].Close) ?? 0)
                if diff > 0 {
                    up21 += abs(diff)
                } else {
                    dn21 += abs(diff)
                }
            }
            up21 /= 21
            dn21 /= 21
            let rs21 = (dn21 == 0) ? 0 : up21 / dn21
            let rsi21v = (1 - 1 / (1 + rs21)) * 100
            rsi21.append(rsi21v)
        }
        
        return ["RSI5": rsi5, "RSI14": rsi14, "RSI21": rsi21]
    }
}
