//
//  CleanReceiptTableViewController.swift
//  
//
//  Created by Jacob Fraizer on 11/12/19.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class CleanReceiptTableViewController: UITableViewController {
    
    
    var cleanReceipts = [CleanReceipt]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        startObserving()
    }

    // MARK: - Table view data source
    
    
    func startObserving(){
        let uid           = Auth.auth().currentUser?.uid ?? ""
        let userRef       = Database.database().reference().child("users/\(uid)/pastRequests")
        userRef.observe(.childAdded) { (snapshot) in
            let value   = snapshot.value as? [String: Any] ?? [:]
            var receipt = CleanReceipt()
            receipt.setCleanReceiptFromDictionary(dictionary: value)
            self.cleanReceipts.append(receipt)
            self.tableView.reloadData()
            print("appended")
        }
    }

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cleanReceipts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCell(withIdentifier: "CleanReceiptCell") as! CleanReceiptCell
        let receipt = cleanReceipts[indexPath.row]
        cell.setAll(receipt: receipt)
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Past Requests"
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura-Bold", size: 25)!
        header.textLabel?.textAlignment = .center
    }
    
}


struct CleanReceipt{
    var clientLocation = CLLocationCoordinate2D()
    var amountPaid     = Int()
    var date           = String()
    var numStars       = Int()
    
    mutating func setCleanReceiptFromDictionary(dictionary : [String : Any]){
        let lat  = dictionary["lat"] as? Double ?? 0.0
        let long = dictionary["long"] as? Double ?? 0.0
        let userRating = dictionary["userRating"] as? [String: Any]  ?? [:]
        numStars       = userRating["stars"] as? Int ?? 0
        amountPaid     = dictionary["amount"] as? Int ?? 0
        date           = dictionary["date"] as? String ?? ""
        clientLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    
}


class CleanReceiptCell : UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountPaidLabel: UILabel!
    @IBOutlet var starImages: [UIImageView]!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    func setAll(receipt : CleanReceipt){
        setDate(date: receipt.date)
        setStars(numStars: receipt.numStars)
        amountPaid(amount: receipt.amountPaid)
        setMap(location: receipt.clientLocation)
        
         
    }
    
    
    func setMap(location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 0.2, longitudinalMeters: 0.20)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Clean Completed"
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    
    
    
    func setStars(numStars : Int){
        var index = 0
        for star in starImages{
            if index > numStars {
                star.image = UIImage(named: "starEmpty")
            }
            index += 1
        }
    }
    
    func setDate(date : String){
        dateLabel.text = date
    }
    
    
    func amountPaid(amount: Int){
        let amountDouble = Double(amount)
        amountPaidLabel.text = "$\(amountDouble / 100)"
    }
}
