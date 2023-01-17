//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
//    didUpdateBitcoin(self, bitcoin: bitcoin)
    
    func didUpdateBitcoin(_ coinManager: CoinManager, bitcoin: Double, currency: String)
    
    func didFailWithError(_ coinManager: CoinManager, error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "4BB9CEC8-7854-4496-BFA6-886E0016EAE8"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = baseURL + "/\(currency)?apikey=\(apiKey)"
        
        // Create url
        if let url = URL(string: urlString) {
            // Create URL session
            let session = URLSession(configuration: .default)
            
            // Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let bitcoin = self.parseJSON(safeData) {
                        self.delegate?.didUpdateBitcoin(self, bitcoin: bitcoin, currency: currency)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()

        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            
            
            return lastPrice
        } catch {
            delegate?.didFailWithError(self, error: error)
            print(error)
            return nil
        }
    }
    
}
