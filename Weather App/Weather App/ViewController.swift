//
//  ViewController.swift
//  Weather App
//
//  Created by Irina Ignatenok on 2024-07-10.
//

import UIKit
import CoreLocation
struct WeatherItem {
    let image: UIImage?
    let name: String
    let condition: String
    let temperature: Float
    let temperature_F: Float
}

class ViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate {

    
    var weatherItem: [WeatherItem] = [] 
    var isCelsiusSelected: Bool = true
    private let locationManager=CLLocationManager()
    let weatherCodeToSymbol: [Int: String] = [
        1000:  "sun.max.circle.fill",
                    1003: "cloud.sun.circle.fill",
                    1006: "cloud",
                    1009: "cloud.fill",
                    1030: "cloud.fog",
                    1063: "cloud.drizzle",
                    1066: "cloud.snow",
                    1069: "cloud.sleet",
                    1072: "cloud.hail",
                    1087: "cloud.bolt",
                    1114: "cloud.snow.fill",
                    1117: "snow",
                    1135: "cloud.fog.fill",
                    1147: "cloud.fog",
                    1150: "cloud.drizzle",
                    1153: "cloud.drizzle.fill",
                    1201: "cloud.heavyrain.fill",
                    1204: "cloud.sleet.fill",
                   1207: "cloud.heavysleet.fill",
                   1210: "cloud.snow.fill",
                   1213: "snow",
                   1216: "cloud.snow",
                   1219: "cloud.heavysnow",
                   1222: "cloud.heavysnow.fill",
                   1225: "snowflake",
                   1237: "cloud.hail.fill",
                   1240: "cloud.rain.fill",
                   1243: "cloud.heavyrain.fill",
                   1246: "cloud.bolt.rain.fill",
                   1249: "cloud.sleet.fill",
                   1252: "cloud.heavysleet.fill",
                   1255: "cloud.snow.fill",
                   1258: "cloud.heavysnow.fill",
                   1261: "cloud.hail.fill",
                   1264: "cloud.heavyhail.fill",
                   1273: "cloud.bolt.rain",
                   1276: "cloud.bolt.rain.fill",
                   1279: "cloud.snow.bolt",
                   1282: "cloud.snow.bolt.fill",
    ]
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var weatherCondition: UILabel!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        displayImage()
        weatherConditionImage.contentMode = .scaleAspectFit
           weatherConditionImage.widthAnchor.constraint(equalToConstant: 240).isActive = true
           weatherConditionImage.heightAnchor.constraint(equalToConstant: 240).isActive = true
        
        activityIndicator.hidesWhenStopped = true
        locationManager.delegate=self
        

    }
    
    
    private func displayImage(){
      

        let config = UIImage.SymbolConfiguration(paletteColors: [.systemOrange,.systemYellow, .systemPink])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: "sun.dust.circle.fill")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        loadWeather(cityName: searchTextField.text, latitude: nil, longitude:nil )
        textField.endEditing(true)
            return true
    }
    
  

    @IBAction func onCelsiusTapped(_ sender: UISegmentedControl) {
        handleSegmentChange(sender: sender)
    }
    
//    AREZOU put here location
    @IBAction func onLocationTapped(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()

        locationManager.requestLocation()
        
    }
    
    @IBAction func onSearchTapped(_ sender: UIBarButtonItem) {
        loadWeather(cityName: searchTextField.text, latitude: nil, longitude: nil)
    }
    @IBAction func onCitiesTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSecondScreen", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSecondScreen" {
            if let destination = segue.destination as? SecondViewController {
                destination.weatherItem = weatherItem
                
                let selectedSegment = segmentedControl.selectedSegmentIndex
                if let latestWeatherItem = weatherItem.last {
                    switch selectedSegment {
                    case 0:
                        // Celsius selected
                        destination.isCelsiusSelected = true
                        destination.selectedTemperature = "\(latestWeatherItem.temperature)C"
                    case 1:
                        // Fahrenheit selected
                        destination.isCelsiusSelected = false
                        destination.selectedTemperature = "\(latestWeatherItem.temperature_F)F"
                    default:
                        break
                    }
                }
            }
        }
    }

    
//    To handle Segment Change
    func handleSegmentChange(sender: UISegmentedControl) {
        guard let latestWeatherItem = weatherItem.last else { return }
        
        switch sender.selectedSegmentIndex {
        case 0:
            // Celsius selected
            isCelsiusSelected = true
            tempretureLabel.text = "\(latestWeatherItem.temperature)C"
            
        case 1:
            // Fahrenheit selected
            isCelsiusSelected = false
            tempretureLabel.text = "\(latestWeatherItem.temperature_F)F"
            
        default:
            break
        }
    }

    func loadWeather(cityName: String?,latitude: Double?, longitude: Double?) {
//        guard let cityName = cityName else {
//            return
//        }
        
        startLoading()
        
        guard let url = getURL(cityName: cityName, latitude: latitude, longitude: longitude) else {
            print("Could not get URL")
            stopLoading()
            return
        }
        print(url)
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.stopLoading()
            }
            
            guard error == nil else {
                print("Received error:", error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data) {
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    
                    // Determine which temperature to display based on selected unit
                    let temperature = self.isCelsiusSelected ? weatherResponse.current.temp_c : weatherResponse.current.temp_f
                    self.tempretureLabel.text = "\(temperature)\(self.isCelsiusSelected ? "C" : "F")"
                    
                    self.weatherCondition.text = weatherResponse.current.condition.text
                    
                    if let symbol = self.weatherCodeToSymbol[weatherResponse.current.condition.code] {
                        self.weatherConditionImage.image = UIImage(systemName: symbol)
                    } else {
                        self.weatherConditionImage.image = UIImage(systemName: "questionmark")
                    }
                    
                    // Create the WeatherItem and append to weatherItem array
                    let weatherItem = WeatherItem(
                        image: self.weatherConditionImage.image,
                        name: weatherResponse.location.name,
                        condition: weatherResponse.current.condition.text,
                        temperature: weatherResponse.current.temp_c,
                        temperature_F: weatherResponse.current.temp_f
                    )
                    
                    self.weatherItem.append(weatherItem)
                }
            }
        }
        
        dataTask.resume()
        searchTextField.text = ""
    }
    

//    API

    private func getURL(cityName: String?, latitude: Double?, longitude: Double?) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "1751bfb89ca94a6fa3620316241207"
        
        // Safely unwrap cityName, latitude, and longitude
        if let unwrappedCityName = cityName, !unwrappedCityName.isEmpty {
            let query = unwrappedCityName
            let urlString = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let url = URL(string: urlString ?? "") else { return nil }
            print(url)
            return url
        } else if let unwrappedLatitude = latitude, let unwrappedLongitude = longitude {
            let query = "\(unwrappedLatitude),\(unwrappedLongitude)"
            let urlString = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let url = URL(string: urlString ?? "") else { return nil }
            print(url)
            return url
        } else {
            // Neither cityName nor both latitude and longitude are available
            return nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got location")
        if let location = locations.last{
            let lat=location.coordinate.latitude
            let lng=location.coordinate.longitude
            print("lat :  \(lat),\(lng)")
            loadWeather(cityName: nil,latitude: lat, longitude: -lng)
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
        
        if let clError = error as? CLError, clError.code == .denied {
            let alert = UIAlertController(title: "Location Access Denied", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Failed to retrieve location. Please check your network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    

    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather:WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from:data)

        } catch {
            print("Error decoding")
        }
        return weather
    }
    
    func startLoading() {
          activityIndicator.startAnimating()
      }

      func stopLoading() {
          activityIndicator.stopAnimating()
          
      }
}

struct WeatherResponse: Decodable {
    let location : Location
    let current : Weather
}

struct Location: Decodable  {
    let name: String
}

struct Weather: Decodable  {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable  {
    let text: String
    let code: Int
}
class MyLocationManagerDelegate:NSObject,CLLocationManagerDelegate {
    

    
}
