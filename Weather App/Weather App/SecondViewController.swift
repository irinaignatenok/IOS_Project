//
//  SecondViewController.swift
//  Weather App
//
//  Created by Irina Ignatenok on 2024-07-10.
//

import UIKit

class SecondViewController: UIViewController {
//    var weatherItem: WeatherItem? 
    @IBOutlet weak var tableView: UITableView!
    
//    var weatherItem: [WeatherItem] = []
    
    var weatherItem: [WeatherItem] = []
    
    var selectedTemperature: String?
    var isCelsiusSelected: Bool = true 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }
    var index = 0

}

extension SecondViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        let item = weatherItem[indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        // Configure the image based on weather condition
        if let itemImage = item.image {
            let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .medium)
            let coloredConfig = config.applying(UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemOrange, .systemPink]))
            let configuredImage = itemImage.withConfiguration(coloredConfig)
            content.image = configuredImage
        } else {
            content.image = UIImage(systemName: "questionmark.circle")
        }
        
        // Configure text properties
        content.textProperties.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        content.textProperties.color = .systemBlue
        content.secondaryTextProperties.color = .systemGray
        
        // Set the city name
        content.text = item.name
        
        // Determine the temperature based on the selected format
        let temperature: String
        if isCelsiusSelected {
            temperature = "\(item.temperature)C"
        } else {
            temperature = "\(item.temperature_F)F"
        }
        print(temperature)
        // Set the secondary text with temperature and condition
        content.secondaryText = "\(temperature) - \(item.condition)"
        content.imageToTextPadding = 40
        
        // Apply content configuration to cell
        cell.contentConfiguration = content
        
        // Add border to cell
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1.0
        
        return cell
    }


    
}
extension SecondViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
