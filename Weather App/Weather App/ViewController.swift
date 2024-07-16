//
//  ViewController.swift
//  Weather App
//
//  Created by Irina Ignatenok on 2024-07-10.
//

import UIKit
struct WeatherItem {
    let image: UIImage?
    let name: String
    let condition: String
    let temperature: Float
    let temperature_F: Float
}

class ViewController: UIViewController, UITextFieldDelegate {

    
    var weatherItem: [WeatherItem] = [] 
    var isCelsiusSelected: Bool = true

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

    }
    
    
    private func displayImage(){
      

        let config = UIImage.SymbolConfiguration(paletteColors: [.systemOrange,.systemYellow, .systemPink])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: "sun.dust.circle.fill")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        loadWeather(search: searchTextField.text)
        textField.endEditing(true)
            return true
    }
    
  

    @IBAction func onCelsiusTapped(_ sender: UISegmentedControl) {
        handleSegmentChange(sender: sender)
    }
    
//    AREZOU put here location
    @IBAction func onLocationTapped(_ sender: UIBarButtonItem) {
        loadWeather2(latitude: 51.50986, longitude: -0.11809)
        
    }
    
    @IBAction func onSearchTapped(_ sender: UIBarButtonItem) {
        loadWeather(search: searchTextField.text)
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


    
    func loadWeather(search: String?) {
        guard let search = search else {
            return
        }
        
        startLoading()
        
        guard let url = getURL(query: search) else {
            print("Could not get URL")
            stopLoading()
            return
        }
        
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
    private func getURL(query:String) -> URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "1751bfb89ca94a6fa3620316241207"
       guard let url =  "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(query)"
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
           return nil
       }
        
        print(url)
        
        return URL(string:url)
    }
    
    // Define the getURL function
    private func getURL2(latitude: Double, longitude: Double) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "1751bfb89ca94a6fa3620316241207"
        
        let query = "\(latitude),\(longitude)"
        
        guard let url = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        print(url)
        
        return URL(string: url)
    }

    func loadWeather2(latitude: Double, longitude: Double) {
        startLoading()
        
        // Step 1: Get URL for latitude and longitude
        guard let url = getURL2(latitude: latitude, longitude: longitude) else {
            print("Could not get URL")
            stopLoading()
            return
        }
        
        // Step 2: Create URLSession
        let session = URLSession.shared
        
        // Step 3: Create data task for session
        let dataTask = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.stopLoading()
            }
            
            // Check for errors
            guard error == nil else {
                print("Received error:", error!.localizedDescription)
                return
            }
            
            // Check if data is available
            guard let data = data else {
                print("No data found")
                return
            }
            
            // Parse JSON data into WeatherResponse object
            if let weatherResponse = self.parseJson(data: data) {
                print("Location:", weatherResponse.location.name)
                print("Temperature:", weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    // Update UI components with weather data
                    self.locationLabel.text = weatherResponse.location.name
                    self.tempretureLabel.text = "\(weatherResponse.current.temp_c)°C"
                    self.weatherCondition.text = weatherResponse.current.condition.text
                    
                    // Set weather condition image based on weather code
                    if let symbol = self.weatherCodeToSymbol[weatherResponse.current.condition.code] {
                        self.weatherConditionImage.image = UIImage(systemName: symbol)
                    } else {
                        self.weatherConditionImage.image = UIImage(systemName: "questionmark")
                    }
                    
                    // Append weather data to weatherItem array
                    self.weatherItem.append(WeatherItem(
                        image: self.weatherConditionImage.image,
                        name: weatherResponse.location.name,
                        condition: weatherResponse.current.condition.text,
                        temperature: weatherResponse.current.temp_c,
                        temperature_F: weatherResponse.current.temp_f
                    ))
                }
            }
        }
        
        // Step 4: Start the data task
        dataTask.resume()
        searchTextField.text = ""  // Assuming searchTextField is where the user enters city names
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

//struct WeatherItem {
//    let image = UIImage?(<#UIImage#>)
//    let condition: String
//    let temperature: Float
//}
//do {
//    "location": {
//        "name": "London",
//        "region": "City of London, Greater London",
//        "country": "United Kingdom",
//        "lat": 51.52,
//        "lon": -0.11,
//        "tz_id": "Europe/London",
//        "localtime_epoch": 1720754029,
//        "localtime": "2024-07-12 4:13"
//    },
//    "current": {
//        "last_updated_epoch": 1720753200,
//        "last_updated": "2024-07-12 04:00",
//        "temp_c": 14.2,
//        "temp_f": 57.6,
//        "is_day": 0,
//        "condition": {
//            "text": "Overcast",
//            "icon": "//cdn.weatherapi.com/weather/64x64/night/122.png",
//            "code": 1009
//        },
//        "wind_mph": 11.9,
//        "wind_kph": 19.1,
//        "wind_degree": 50,
//        "wind_dir": "NE",
//        "pressure_mb": 1017.0,
//        "pressure_in": 30.03,
//        "precip_mm": 0.01,
//        "precip_in": 0.0,
//        "humidity": 82,
//        "cloud": 100,
//        "feelslike_c": 13.2,
//        "feelslike_f": 55.7,
//        "windchill_c": 11.1,
//        "windchill_f": 52.0,
//        "heatindex_c": 12.5,
//        "heatindex_f": 54.5,
//        "dewpoint_c": 11.0,
//        "dewpoint_f": 51.9,
//        "vis_km": 10.0,
//        "vis_miles": 6.0,
//        "uv": 1.0,
//        "gust_mph": 12.5,
//        "gust_kph": 20.1
//    }
//}
