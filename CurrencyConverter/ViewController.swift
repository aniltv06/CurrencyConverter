//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by anilkumar thatha. venkatachalapathy on 6/7/16.
//  Copyright © 2016 Anil T V. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pickerViewFrom: UIPickerView!
    @IBOutlet weak var pickerViewTo: UIPickerView!
    @IBOutlet weak var inputCurrencyText: UITextField!
    @IBOutlet weak var outputCurrencyLabel: UILabel!
    
    var pickerDataSource = ["AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK",
                            "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY",
                            "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON",
                            "RUB", "SEK","SGD", "THB", "TRY", "USD", "ZAR"];
    
    let  defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var selectedFromCurrency: NSString?
    var selectedToCurrency: NSString?
    var dataTask: NSURLSessionDataTask?
    var currencyRatesFetched = [ratesModel]()
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView == pickerViewFrom {
            self.selectedFromCurrency = pickerDataSource[row]
        }
        else
        {
            self.selectedToCurrency = pickerDataSource[row]
        }
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == pickerViewFrom {
            self.selectedFromCurrency = pickerDataSource[row]
        }
        else {
            self.selectedToCurrency = pickerDataSource[row]
        }
        self.ConvertCurrency(UIButton())
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.outputCurrencyLabel.text = ("Enter Input Value")
        self.fetchCurrencyRates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func presentAlertForError (message: String){
        let alertController = UIAlertController(title: "Currency Conveter",
                                                message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func fetchCurrencyRates() {
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let url = NSURL(string: "https://api.fixer.io/latest")
        
        dataTask = defaultSession.dataTaskWithURL(url!){
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.updateCurrencyRates(data)
                }
                else {
                    self.inputCurrencyText.enabled = false
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentAlertForError("Error Occured while connecting to server")
                    }
                }
            }
        }
        dataTask?.resume()
    }
    
    func updateCurrencyRates(data: NSData?) {
        self.currencyRatesFetched.removeAll()
        do {
            if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject]{
                let base = response["base"] as? String
                let date = response["date"] as? String
                let rates = response["rates"] as? NSDictionary
                currencyRatesFetched.append(ratesModel(base:base, date: date, rates: rates))
                if rates == nil {
                    self.inputCurrencyText.enabled = false
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentAlertForError("Convertion Rates are not found")
                    }
                }
                else {
                    self.inputCurrencyText.enabled = true
                }
            }
            else {
                print("JSON Error")
                self.inputCurrencyText.enabled = false
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentAlertForError("JSON Error")
                }
            }
        }catch let error as NSError {
            print("Error :\(error.localizedDescription)")
            self.inputCurrencyText.enabled = false
            dispatch_async(dispatch_get_main_queue()) {
                self.presentAlertForError("Error :\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func ConvertCurrency(sender: UIButton) {
        self.outputCurrencyLabel.text = ("")
        if ((self.inputCurrencyText.text?.isEmpty) == false) {
            let fetchedRates = self.currencyRatesFetched[0].rates! as NSDictionary
            let fromCurrency = fetchedRates.objectForKey(self.selectedFromCurrency as! String) as! Float
            let toCurrency = fetchedRates.objectForKey(self.selectedToCurrency as! String) as! Float
            let inputCurrency = Float(inputCurrencyText.text!)
            if inputCurrency > 0 {
                let convertedCurrency = (toCurrency/fromCurrency)*inputCurrency!
                self.outputCurrencyLabel.text = NSString(format: "%.2f", convertedCurrency) as String
            }
            else {
                self.outputCurrencyLabel.text = ("Invalid Input")
            }
        }
        else {
            self.outputCurrencyLabel.text = ("Enter Input Value")
        }
    }
    
    
    @IBAction func textFieldDidChange(textField: UITextField) {
            self.ConvertCurrency(UIButton())
    }
    
}

