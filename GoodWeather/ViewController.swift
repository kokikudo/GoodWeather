//
//  ViewController.swift
//  GoodWeather
//
//  Created by Mohammad Azam on 3/6/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TextFieldの編集が終わったときに実行される
        // これがないと値が変わるたびにAPI通信が実行されるので良くない
        self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.cityNameTextField.text }
            .subscribe(onNext: { city in
                
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
                
            }).disposed(by: disposeBag)
      
    }
    
    private func fetchWeather(by city: String) {
        
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL.urlForWeatherAPI(city: cityEncoded) else {
                return
        }
        
        let resource = Resource<WeatherResult>(url: url)

        // load: 拡張した関数。引数のURLからデコードされたAPIレスポンスをObservableで返す
        // observa関数にMainSchduler.instanceを入れると以降の処理をメインスレッドで行う。UIの変更処理などでDispatchキューで行う処理を簡潔にかける
        // catchAndReturnでエラー発生時に空の天気データを返す
//　bind or driver を使わない場合
//        URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance)
//            .catchAndReturn(WeatherResult.empty)
//            .subscribe(onNext: { result in
//
//                let weather = result.main
//                self.displayWeather(weather)
//
//            }).disposed(by: disposeBag)

        // bindでLabelに値を振り分ける
//        let resultWeather = URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance)
//            .catchAndReturn(WeatherResult.empty)
//
//        resultWeather.map { "\($0.main.temp) ℉" }
//        .bind(to: self.temperatureLabel.rx.text)
//        .disposed(by: disposeBag)
//
//        resultWeather.map { "\($0.main.humidity) ℉" }
//        .bind(to: self.humidityLabel.rx.text)
//        .disposed(by: disposeBag)

        // driverはbindと同じ機能を持ちさらにMainスレッドで
        // 実行され、エラーをキャッチする機能を持ってる
        // UIの変更の場合はdriverで良さげ
        // Hot-Cold機能もあるらしいがよくわからん
        let resultWeather = URLRequest.load(resource: resource).observe(on: MainScheduler.instance)
            .retry(3)// エラーが起きた時に再試行する
            .catch { error in // HTTP通信がうまくいかなかった場合の処理
                print(error.localizedDescription)
                return Observable.just(WeatherResult.empty)
            }
            .asDriver(onErrorJustReturn: WeatherResult.empty)

        resultWeather.map { "\($0.main.temp) ℉" }
        .drive(self.temperatureLabel.rx.text)
        .disposed(by: disposeBag)

        resultWeather.map { "\($0.main.humidity) ℉" }
        .drive(self.humidityLabel.rx.text)
        .disposed(by: disposeBag)
    }
    
    private func displayWeather(_ weather: Weather?) {
        
        if let weather = weather {
            self.temperatureLabel.text = "\(weather.temp) ℉"
            self.humidityLabel.text = "\(weather.humidity) 💦"
        } else {
            self.temperatureLabel.text = "🙈"
            self.humidityLabel.text = "⦰"
        }
    }

}

