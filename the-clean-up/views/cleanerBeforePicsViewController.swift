//
//  cleanerProgressViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/7/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import BSImagePicker
import Photos
import AyLoading
import SCLAlertView

class cleanerProgressViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- BUTTONS
    @IBOutlet var checkMarkButtons: [UIButton]!
    
    //MARK:- IMAGES
    @IBOutlet var checkmarkImages: [UIImageView]!

    //MARK:- LABELS
    @IBOutlet weak var masterCountLabel: UILabel!
    @IBOutlet weak var kitchenDishCountLabel: UILabel!
    @IBOutlet weak var kitchenCountLabel: UILabel!
    @IBOutlet weak var regularCountLabel: UILabel!
    @IBOutlet weak var garageCountLabel: UILabel!
    @IBOutlet weak var laundryCountLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    //MARK:- REQUEST
    var request    = Request()

    //MARK:- IMAGE PICKER
    let picker = UIImagePickerController()
    let vc = BSImagePickerViewController()
    
    //MARK:- ORDER COUNT
    var orderCount  = cleaningOrderCount()
    
    //MARK:- REQUEST INFORMATION
    var transactionID = String()
    var requestNote = String()
    var clientUID  = String()
    var status = String()
    var included    = RoomIncluded()
    var pathString = String()
    var path       = StorageReference()
    
    

    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideImagesInArray(images: checkmarkImages)
        setLabels()
        checkStatus()
        print(orderCount.orderCounterToString())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkStatus()
    }
    
    func checkStatus(){
        if status != ""{
            performSegue(withIdentifier: "beforeToAfterSegue", sender: nil)
            print("beforeToAfter")
        }
        else{
            print("status is null")
        }
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
        
    }
    
    func cancelIcon(index: Int){
        checkmarkImages[index].image      = UIImage(named: "cancel")
        checkmarkImages[index].isHidden   = false
        checkMarkButtons[index].isEnabled = false
        //TODO:- make sure buttons are disabled
    }
    
    
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        onPhotoButton(buttonTapped: sender.tag)
    }
    
    func unhideImage(index : Int){
        if checkmarkImages[index].isHidden{
            checkmarkImages[index].isHidden = false
        }
        else {
            checkmarkImages[index].isHidden = true
        }
    }
    
    @IBAction func startCleaningButtonTapped(_ sender: Any) {
        if isCompleted() {
            cleanInProgressDB(userID: clientUID)
            performSegue(withIdentifier: "beforeToAfterSegue", sender: nil)
        }
        else {
            SCLAlertView().showError("Upload a photo for each room", subTitle: "Please finish uploading the before photographs") // Error
        }
    }
    
    func isCompleted() -> Bool{
        for image in checkmarkImages{
            if image.isHidden == true {
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
    
    func uploadPhotos(assets: [PHAsset], roomType: Int){
        var index = 0
        checkmarkImages[roomType].ay.startLoading()
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
                    self.checkmarkImages[roomType].ay.stopLoading()
                }
                if error != nil {
                    print(error ?? "no error")
                }
            }
            print("index = \(index)")
            index += 1
        }
        
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
        pathString = "\(String(describing: userID))/\(transactionID)/before/\(roomType)\(roomNumber)"
        print(pathString)
        path       = storageRef.child(pathString)
        
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
        performSegue(withIdentifier: "infoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue"{
            if let destinationVC = segue.destination as? userIncludedViewController {
                destinationVC.included = included
            }
        }
        if segue.identifier == "beforeToAfterSegue"{
            if let destinationVC = segue.destination as? cleanerAfterViewController{
                destinationVC.orderCount    = orderCount
                destinationVC.requestNote   = requestNote
                destinationVC.included      = included
                destinationVC.transactionID = transactionID
                destinationVC.clientUID     = clientUID
                destinationVC.request       = request
            }
        }
        
    }
    
    
    
    
    
    
    
    
}

extension PHAsset {
    func image(targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) -> UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
}

