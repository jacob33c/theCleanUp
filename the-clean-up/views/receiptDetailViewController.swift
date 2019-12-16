//
//  receiptDetailViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 12/8/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import MapKit

class receiptDetailViewController: UIViewController {
    
//MARK:-LABELS
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
//MARK:- RECIEPT
    var receipt = CleanReceipt()
    @IBOutlet weak var mapView: MKMapView!
//MARK:-IMAGES
    @IBOutlet var starImages: [UIImageView]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAll(receipt: receipt)
    }
    
    
    
    func setAll(receipt : CleanReceipt){
        setDate(date: receipt.date)
        setStars(numStars: receipt.numStars)
        amountPaid(amount: receipt.amountPaid)
        setMap(location: receipt.clientLocation)
        setOrderLabel(orderString: receipt.order.orderCounterToString())
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
    func setMap(location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 0.2, longitudinalMeters: 0.20)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Clean Completed"
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    func amountPaid(amount: Int){
        let amountDouble = Double(amount)
        costLabel.text = "$\(amountDouble / 100)"
    }
    func setOrderLabel(orderString : String){
        orderLabel.text = orderString
    }
    



}
