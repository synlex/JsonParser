//
//  ViewController.swift
//  JsonParser
//
//  Created by synlex on 2018. 4. 4..
//  Copyright © 2018년 synlex. All rights reserved.
//

import UIKit

struct Weather: Decodable {
    let country: String
    let weather: String
    let temperature: String
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var datalist = [Weather]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView.startAnimating()
        
        let urlString = "https://raw.githubusercontent.com/ChoiJinYoung/iphonewithswift2/master/swift4weather.json"
        
        guard let jsonURL = URL(string: urlString) else { return }
        
        // 이미 만들어진 URLSession 를 공유해서 사용(share)
        // session 만들어서 resume 해야 함
        URLSession.shared.dataTask(with: jsonURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            
            // do 안에 try를 사용하여 에러 처리
            do {
                // type : [Weather].self
                self.datalist = try JSONDecoder().decode([Weather].self, from: data)
                
                // background thread : main thread 화면을 사용할 수 없음
                // runtime error : UITableView.reloadData() must be used from main thread only
                // 참고 키워드 : main thread checker
                //self.tableView.reloadData()
                
                // 작업을 마치면, main thread에 반영 요청
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.indicatorView.stopAnimating()
                    })
            } catch {
                // error 이름으로 에러 전달됨
                print("Parsing error \(error)")
            }
        }).resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datalist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WeatherCell
        
        let weather = datalist[indexPath.row]
        cell.countryLabel.text = weather.country
        cell.temperatureLabel.text = weather.temperature
        let weatherStr = weather.weather
        cell.weatherLabel.text = weatherStr

        // optional image에 이미지 파일 연결
        if weatherStr == "맑음" {
            cell.imgView!.image = UIImage(named: "sunny.png")
        } else if weatherStr == "비" {
            cell.imgView!.image = UIImage(named: "rainy.png")
        } else if weatherStr == "눈" {
            cell.imgView!.image = UIImage(named: "snow.png")
        } else if weatherStr == "흐림" {
            cell.imgView!.image = UIImage(named: "cloudy.png")
        } else if weatherStr == "우박" {
            cell.imgView!.image = UIImage(named: "blizzard.png")
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

