//
//  DetailedItemViewController.swift
//  karma
//
//  Created by Agustiadi on 16/3/15.
//  Copyright (c) 2015 Agustiadi. All rights reserved.
//

import UIKit

var nameOfItem = String()
var categoryOfItem = String()
var descriptionOfItem = String()
var giverID = String()
var objectID = String()
var giverImage = UIImage()
var giverName = String()

class DetailedItemViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    //IBOutlets Connections
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var giverNameLabel: UILabel!
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var wantItBtnLabel: UIButton!
    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var categoryTag: UIImageView!
    
    @IBAction func wantItBtn(sender: AnyObject) {
        performSegueWithIdentifier("wantIt", sender: self)
        println("Want It Button Pressed")
    }

    var imagePic = UIImage()
    var itemImageIndex = 0
    var itemImagesFile = [PFFile]()
    var itemImages = [UIImage]()
    
    func makeLayout(){
        let viewWidthUnit = viewWidth/20
        let viewHeightUnit = viewHeight/20
        
        // Header
        headerBackground.frame = CGRectMake(0, 0, viewWidth, 48)
        profilePic.frame = CGRectMake(12, 5, 38, 38)
        giverNameLabel.frame = CGRectMake(63, 12, viewWidth*0.5, 25)

        // Image + wording
        collectionView.frame = CGRectMake(0, 48, viewWidth, 231)
        itemNameLabel.frame = CGRectMake(15, 285, viewWidth-30, 25)
        categoryTag.frame = CGRectMake(15, 315, 93, 25)
        categoryLabel.frame = CGRectMake(21, 317, 80, 21)
        descriptionLabel.frame = CGRectMake(15, 352, viewWidth-30, 40)

        
        // Buttons
        wantItBtnLabel.frame = CGRectMake(0, viewHeight-109, viewWidth, 45)
    }
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeLayout()
        
        profilePic.layer.cornerRadius = 20
        profilePic.clipsToBounds = true
        
        itemNameLabel.text = nameOfItem
        
        categoryLabel.text = categoryOfItem
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = descriptionOfItem
        descriptionLabel.sizeToFit()
        
        wantItBtnLabel.layer.zPosition = 20
        
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: descriptionLabel.frame.maxY + wantItBtnLabel.frame.height + 70)
        
        if giverID == PFUser.currentUser().objectId {
            
            wantItBtnLabel.removeFromSuperview()
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: true)

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollEnabled = true
        
        getUserData(giverID, name: giverNameLabel, profilePic: profilePic)
        getItemImages(objectID)

    }
    
    func getUserData(userID: String, name: UILabel, profilePic: UIImageView){
        
        var userQuery = PFQuery(className: "_User")
        userQuery.whereKey("objectId", equalTo: userID)
        userQuery.findObjectsInBackgroundWithBlock {
            (userObjects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                
                for user in userObjects {
                    
                    name.text = user["name"] as? String
                    giverName = user["name"] as! String
                    
                    if let temp: AnyObject = user["profilePic"] {
                    
                        temp.getDataInBackgroundWithBlock{
                            (imageData: NSData!, error: NSError!) -> Void in
                            
                            if error == nil {
                                
                                let image = UIImage(data: imageData)
                                profilePic.image = image
                                giverImage = image!
                                
                                
                            } else {
                                
                                println(error)
                                
                            }
                        }
                        
                    } else {
                        
                        profilePic.image = UIImage(named: "profilePlaceholder")!
                        giverImage = UIImage(named: "profilePlaceholder")!
                        
                    }

                

                    }
                }
            }
        }
    
    
    func getItemImages(objectID: String) {
        
        self.itemImagesFile.removeAll(keepCapacity: true)
        
        var imageQuery = PFQuery(className: "Item")
        imageQuery.whereKey("objectId", equalTo: objectID)
        imageQuery.findObjectsInBackgroundWithBlock {
            (imageObjects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                
                let selectedItem = imageObjects[0] as! PFObject
                
                for image in ["image_1", "image_2", "image_3", "image_4", "image_5"] {
                    
                    if selectedItem["\(image)"] != nil {
                        self.itemImagesFile.append(selectedItem["\(image)"] as! PFFile)
                    }
                    
                }
                self.collectionView.reloadData()
                
            }
            
        }

    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImagesFile.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("itemImage", forIndexPath: indexPath) as! ItemImagesCollectionViewCell
        
        // Set cell width to 100%
        cell.frame.size.width = self.collectionView.bounds.size.width
        
        cell.backgroundColor = UIColor.whiteColor()
        
        let itemImageFile = itemImagesFile[indexPath.row] as PFFile
        itemImageFile.getDataInBackgroundWithBlock({
            (imageData: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                
                let image = UIImage(data: imageData)
                cell.itemImageView.image = image
                
            } else {
                
                println(error)
                
            }

            
        })
        
        //Add Image Index Indicator Label
        cell.indicatorLabel.backgroundColor = UIColor.blackColor()
        cell.indicatorLabel.alpha = 0.85
        cell.indicatorLabel.textColor = UIColor.whiteColor()
        cell.indicatorLabel.text = "\(indexPath.row + 1) of \(itemImagesFile.count)"
        cell.indicatorLabel.textAlignment = NSTextAlignment.Center
        cell.indicatorLabel.font = UIFont(name: "Helvetica Neue", size: 10)

        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "wantIt" {
            
            let destinationVC = segue.destinationViewController as! ChatWindowViewController
            destinationVC.itemID = objectID
            destinationVC.otherUserID = giverID
            destinationVC.otherUserProfilePic = giverImage
            destinationVC.otherUsername = giverName
            
            let current_User = PFUser.currentUser()
            
            if current_User["profilePic"] != nil {
                
                current_User["profilePic"].getDataInBackgroundWithBlock({
                    (imageData: NSData!, error: NSError!) -> Void in
                    
                    if error == nil {
                        
                        let image = UIImage(data: imageData)
                        destinationVC.currentUserProfilPic = image!
                        
                    } else {
                        
                        println(error)
                        
                    }
                })
                
            } else {
                destinationVC.currentUserProfilPic = UIImage(named: "profilePlaceholder")!
            }
            
            
        }
    }

}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

