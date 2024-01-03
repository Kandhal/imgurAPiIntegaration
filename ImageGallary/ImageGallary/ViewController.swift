//
//  ViewController.swift
//  ImageGallary
//
//  Created by Kindness on 03/01/24.
//

import UIKit

struct ImgurData: Codable {
    let images: [ImgurImage]
    
    enum CodingKeys: String, CodingKey {
        case images = "data"
    }
}

struct ImgurImage: Codable {
    let title: String?
    let date: Int?
    let additionalImagesCount: Int?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case date = "datetime"
        case additionalImagesCount = "images_count"
        case imageUrl = "link"
    }
}


class ViewController: UIViewController, UITableViewDataSource, UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toggleSegmentedControl: UISegmentedControl!
    
    var imgurImages: [ImgurImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        fetchData()
    }
    
    // Register NIbs
    func registerNibs() {
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        collectionView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")
    }
    func fetchData() {
        // Make API request to Imgur
        // Replace 'YOUR_CLIENT_ID' with your actual Imgur client ID
        let clientId = "1869f7b84c5216d"
        let apiUrl = "https://api.imgur.com/3/gallery/hot/viral/day/1?showViral=true&mature=false&album_previews=true"
        
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
           // print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

            do {
                let imgurData = try JSONDecoder().decode(ImgurData.self, from: data)
                
                self.imgurImages = imgurData.images
               // self.imgurImages.sort(by: { $0.date > $1.date })
                print(self.imgurImages.count)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    @IBAction func toggleChanged(_ sender: UISegmentedControl) {
        tableView.isHidden = sender.selectedSegmentIndex == 1
        collectionView.isHidden = sender.selectedSegmentIndex == 0
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgurImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        configureListCell(cell, at: indexPath)
        return cell
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgurImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
        configureGridCell(cell, at: indexPath)
        return cell
    }
    
    // Helper methods to configure cell
    
    func configureListCell(_ cell: ListCell, at indexPath: IndexPath) {
        let imgurImage = imgurImages[indexPath.row]
        cell.titleLabel.text = imgurImage.title
        cell.dateLabel.text = convertTimestampToString(timestamp: "\(imgurImage.date!)")
        cell.additionalImagesLabel.text = "\(String(describing: imgurImage.additionalImagesCount)) additional images"
        
        // Load thumbnail image using AlamofireImage
        // Load thumbnail image using URLSession and UIImage
        if let imageUrl = URL(string: imgurImage.imageUrl!) {
            loadImage(from: imageUrl, into: cell.thumbnailImageView)
        }
    }
    // Helper method to load image from URL
    func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
        }.resume()
    }
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180  // Set an estimated height for smoother scrolling
    }

    func configureGridCell(_ cell: GridCell, at indexPath: IndexPath) {
        let imgurImage = imgurImages[indexPath.row]
        cell.titleLabel.text = imgurImage.title
        
        // Load larger thumbnail image using AlamofireImage
        // Load thumbnail image using URLSession and UIImage
        if let imageUrl = URL(string: imgurImage.imageUrl!) {
            loadImage(from: imageUrl, into: cell.thumbnailImageView)
        }
    }
    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 16  // Assuming you want two cells per row with some spacing
        let height = width * 1.5  // Adjust the aspect ratio as needed
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8  // Adjust the spacing between rows
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8  // Adjust the spacing between items in the same row
    }

    // Helper method to format date
    func convertTimestampToString(timestamp: String, format: String = "dd/MM/yy hh:mm a") -> String {
        guard let timestampDouble = Double(timestamp) else {
            return "Invalid Timestamp"
        }
        
        let date = Date(timeIntervalSince1970: timestampDouble)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }

}
