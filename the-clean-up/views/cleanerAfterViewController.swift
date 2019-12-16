//
//  cleanerAfterViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 11/10/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import BSImagePicker
import Photos
import AyLoading
import SCLAlertView

class cleanerAfterViewController: UIViewController {
    
    //MARK:- BUTTONS
    @IBOutlet var checkButtons: [UIButton]!
    
    
    //MARK:-REQUEST
    var orderCount  = cleaningOrderCount()
    var requestNote = String()
    var included    = RoomIncluded()
    var request     = Request()
    
    //MARK:-VIEW CONTROLLERS
    let picker = UIImagePickerController()
    let vc     = BSImagePickerViewController()
    
    //MARK:-STRINGS
    var transactionID = String()
    var clientUID     = String()
    var pathString    = String()
    
    //MARK:- REFERENCES
    var path = StorageReference()
    
    //MARK:- LABELS
    @IBOutlet weak var masterCountLabel: UILabel!
    @IBOutlet weak var kitchenDishCountLabel: UILabel!
    @IBOutlet weak var kitchenCountLabel: UILabel!
    @IBOutlet weak var regularCountLabel: UILabel!
    @IBOutlet weak var garageCountLabel: UILabel!
    @IBOutlet weak var laundryCountLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideImages()
        setLabels()
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func setLabels(){
           masterCountLabel.text       = orderCount.masterBedroomCount.description
           kitchenDishCountLabel.text  = orderCount.kitchenDishCount.description
           kitchenCountLabel.text      = orderCount.kitchenCount.description
           regularCountLabel.text      = orderCount.regularRoomCount.description
           garageCountLabel.text       = orderCount.garageCount.description
           laundryCountLabel.text      = orderCount.laundryCount.description
           notesLabel.text             = requestNote
           checkRequiredRooms()
       }

    
    func checkRequiredRooms(){
        if notRequired(roomCount: orderCount.masterBedroomCount) {cancelIcon(index: 0)}
        if notRequired(roomCount: orderCount.kitchenDishCount)   {cancelIcon(index: 1)}
        if notRequired(roomCount: orderCount.kitchenCount)       {cancelIcon(index: 2)}
        if notRequired(roomCount: orderCount.regularRoomCount)   {cancelIcon(index: 3)}
        if notRequired(roomCount: orderCount.garageCount)        {cancelIcon(index: 4)}
        if notRequired(roomCount: orderCount.laundryCount)       {cancelIcon(index: 5)}
        print(orderCount)
    }
    
    func hideImages(){
        for button in checkButtons{
            button.setImage(nil, for: .normal)
        }
    }
    
    func cancelIcon(index: Int){
        let cancelImage = UIImage(named: "cancel")
        checkButtons[index].setImage(cancelImage, for: .normal)
        checkButtons[index].imageView?.isHidden = false
        checkButtons[index].isEnabled           = false
    }
    
    
    
    
    //MARK:- BUTTON ACTIONS
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        onPhotoButton(buttonTapped: sender.tag)
    }
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        var info = RoomIncluded()
        switch sender.tag {
        case 0:
            info = masterInclude
        case 1:
            info = kitchenDishInclude
        case 2:
            info = kitchenInclude
        case 3:
            info = regularInclude
        case 4:
            info = garageInclude
        case 5:
            info = laundryInclude
        default:
            return
        }
        included = info
        performSegue(withIdentifier: "infoSegue1", sender: nil)
    }
    
    @IBAction func completeButtonTapped(_ sender: Any) {
        if isCompleted(){
            cleanFinishedInDB(userID: self.clientUID)
            performSegue(withIdentifier: "cleanerToRatingSegue", sender: nil)
        }
        else{
            SCLAlertView().showError("Upload a photo for each room", subTitle: "Please finish uploading the before photographs") // Error
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue1"{
            if let destinationVC = segue.destination as? userIncludedViewController {
                destinationVC.included = included
            }
        }
        if segue.identifier == "cleanerToRatingSegue"{
           if let destinationVC = segue.destination as? ratingsViewController {
            destinationVC.isDriver      = true
            destinationVC.order         = orderCount
            destinationVC.clientUID     = clientUID
            destinationVC.request       = request
            destinationVC.transactionID = transactionID
           }
        }
    }
    
    
    
    func isCompleted() -> Bool{
        for button in checkButtons{
            if button.imageView?.image == nil {
                return false
            }
        }
        return true
    }
    
    
    func onPhotoButton(buttonTapped : Int) {
        vc.takePhotos = true
        let minPhoto  = setMax(buttonTapped: buttonTapped)
        
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                print("selected")
            }, deselect: { (asset: PHAsset) -> Void in
                print("deselected")
            }, cancel: { (assets: [PHAsset]) -> Void in
                print("canceled")
            }, finish: { (assets: [PHAsset]) -> Void in
                print("finished")
                if assets.count < minPhoto {
                    SCLAlertView().showError("Upload a photo for each room", subTitle: "Please upload \(minPhoto) photos.") // Error
                }
                else{
                    self.unhideImage(index: buttonTapped)
                    self.uploadPhotos(assets: assets, roomType: buttonTapped)
                }
            }, completion: nil)
    }
    
    func unhideImage(index : Int){
        if checkButtons[index].imageView?.image == nil{
            let buttonImage = UIImage(named: "greenCheck")
            checkButtons[index].setImage(buttonImage, for: .normal)
        }
        else {
            checkButtons[index].setImage(nil, for: .normal)
        }
    }
    
    
    func uploadPhotos(assets: [PHAsset], roomType: Int){
    var index = 0
    checkButtons[roomType].ay.startLoading()
    for asset in assets {
        createPath(room: roomType, roomNumber: index)
        let option           = PHImageRequestOptions()
        let image            = asset.image(targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option)
        var data             = Data()
        data                 = image.pngData()!
        let metaData         = StorageMetadata()
        metaData.contentType = "image/png"
        path.putData(data, metadata: metaData) { (outcome, error) in
            if outcome != nil {
                print(outcome ?? "no outcome")
                self.checkButtons[roomType].ay.stopLoading()
            }
            if error != nil {
                print(error ?? "no error")
            }
        }
        print("index = \(index)")
        index += 1
    }
    }
    
    
    func setMax(buttonTapped : Int) -> Int{
        var order = Int()
        switch buttonTapped {
        case 0:
            order = orderCount.masterBedroomCount
        case 1:
            order = orderCount.kitchenDishCount
        case 2:
            order = orderCount.kitchenCount
        case 3:
            order = orderCount.regularRoomCount
        case 4:
            order = orderCount.garageCount
        case 5:
            order = orderCount.laundryCount
        default:
            order = Int(masterMax)
            print("something went wrong in setMax cleanerBefore")
        }
        vc.maxNumberOfSelections = order
        return order
    }
    
    func createPath(room : Int, roomNumber: Int){
           var roomType = String()
           switch room {
           case 0:
               roomType = "master"
           case 1:
               roomType = "kitchenDish"
           case 2:
               roomType = "kitchen"
           case 3:
               roomType = "regular"
           case 4:
               roomType = "garage"
           case 5:
               roomType = "laundry"
           default:
               roomType = "no Room"
           }
           guard let userID = Auth.auth().currentUser?.uid else {
               print("no user id")
               return
           }
           pathString = "\(String(describing: userID))/\(transactionID)/after/\(roomType)\(roomNumber)"
           print(pathString)
           path       = storageRef.child(pathString)
           
       }
    
    
    
    
    
}
