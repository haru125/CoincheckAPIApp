//
//  ViewController.swift
//  CoincheckAPIApp
//
//  Created by Satoshi Ota on 2021/07/23.
//

import UIKit
import Moya
import Charts

enum CoinCheck {
    case AllTask
}

struct BtcJson: Codable {
    let data: [dataArray]
    struct dataArray: Codable {
        let rate: Double
//        let created_at: String
    }
}



class ViewController: UIViewController {
    
    var timer:Timer!
    var rateArray = [Double]()
    var dateArray = [Double]()
    var date: Double = 0
    let provider = MoyaProvider<CoinCheck>()
    var lineChartDataSet: LineChartDataSet!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func timeFunc() {
        provider.request(.AllTask) { (result) in
            switch result {
            case .success(let response):
                do {
                    let decoder:JSONDecoder = JSONDecoder()
                    let dataArrayInfo = try! decoder.decode(BtcJson.self, from: response.data)
                    self.date = self.date + 1
                    self.dateArray.append(self.date)
                    let rate: Double = dataArrayInfo.data[0].rate
                    self.rateArray.append(rate)
                    self.lineChartView.data = self.generationLineChartData()
                } catch {
                    print("error")
                }
            case .failure(let error):
                print("error")
            }
        }
    }
    
    func generationLineChartData() -> LineChartData {
        var entries: [ChartDataEntry] = Array()
        for (i, value) in rateArray.enumerated() {
            entries.append(ChartDataEntry(x: dateArray[i], y: value))
        }
        
        var linedata: [LineChartDataSet] = Array()
        lineChartDataSet = LineChartDataSet(entries: entries, label: "btc")
        linedata.append(lineChartDataSet)
//        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.circleColors = [#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)]
        lineChartDataSet.colors = [#colorLiteral(red: 0.2156862745, green: 0.6705882353, blue: 0.6156862745, alpha: 1)]
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.drawFilledEnabled = true
        lineChartView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = IAxisDateFomatter()
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelCount = 3
        return LineChartData(dataSets: linedata)
    }
    
    @IBAction func actionButton(_ sender: Any) {
        if timer == nil {
           timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timeFunc), userInfo: nil, repeats: true)
        } else if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
}

extension CoinCheck: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://coincheck.com") else {
            fatalError()
        }
        return url
    }
    
    var path: String {
        switch self {
        case .AllTask:
            return "/api/trades"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .AllTask:
            return .requestParameters(parameters: ["pair" : "btc_jpy"], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}

