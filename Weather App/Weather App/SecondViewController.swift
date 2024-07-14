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
        
        if let itemImage = item.image {
             let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .medium)
             let coloredConfig = config.applying(UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemOrange, .systemPink]))
             let configuredImage = itemImage.withConfiguration(coloredConfig)
             content.image = configuredImage
         } else {
             content.image = UIImage(systemName: "questionmark.circle")
         }
//         Set up text
        content.textProperties.font = UIFont.systemFont(ofSize: 20, weight: .bold)
           content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16, weight: .regular)
           
           // Set the text alignment
//        content.textProperties.alignment = .justified
//           content.secondaryTextProperties.alignment = .natural
           
           // Set the text color
           content.textProperties.color = .systemBlue
           content.secondaryTextProperties.color = .systemGray
        
        content.text = item.name
        
        // Set the temperature based on the selected format
        let temperature = isCelsiusSelected ? "\(item.temperature)C" : "\(item.temperature_F)F"
        content.secondaryText = "\(temperature) - \(item.condition)"
        content.imageToTextPadding = 40
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
