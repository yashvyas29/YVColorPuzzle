//
//  ViewController.swift
//  YVPuzzleGame
//
//  Created by Yash on 12/07/16.
//  Copyright © 2016 Yash. All rights reserved.
//

import UIKit
import RAReorderableLayout

class ViewController: UIViewController, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let arrFixedColors: [UIColor] = [UIColor.redColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.orangeColor(), UIColor.purpleColor(), UIColor.blueColor(), UIColor.darkGrayColor(), UIColor.lightGrayColor(), UIColor.grayColor(), UIColor.whiteColor(), UIColor.cyanColor(), UIColor.magentaColor(), UIColor.brownColor()]
    var arrPuzzleColors: [UIColor] = []
    var prevRandom: Int = 0
    var currentLevelSides: Int = 2
    let padding = 1
    var currentLevel = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.navigationBarHidden = true
        collectionView.registerNib(UINib(nibName: "PuzzleHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "PuzzleHeader")
        refreshData()
    }

    func refreshData() {
        
        let colorCount =  UInt32(currentLevelSides)
        var i = Int(arc4random_uniform(colorCount))
        while i == prevRandom && currentLevelSides != 1 {
            i = Int(arc4random_uniform(colorCount))
        }
        prevRandom = i
        
        let totalItems = currentLevelSides * currentLevelSides
        for j in 1...totalItems {
            
            arrPuzzleColors.append(arrFixedColors[i])
            if i < currentLevelSides {
                i += 1
                
                if j % currentLevelSides == 0 {
                    i -= 1
                } else if i == currentLevelSides {
                    i = 0
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - RAReorderableLayout Delegate
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPuzzleColors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PuzzleCell", forIndexPath: indexPath)
        cell.backgroundColor = arrPuzzleColors[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "PuzzleHeader", forIndexPath: indexPath) as! PuzzleHeader
        headerView.lblRound.text = "Round \(currentLevel)"
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        
        let color: UIColor = arrPuzzleColors.removeAtIndex(atIndexPath.item)
        arrPuzzleColors.insert(color, atIndex: toIndexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, collectionViewLayout layout: RAReorderableLayout, didEndDraggingItemToIndexPath indexPath: NSIndexPath) {
        
        var success = false
        var rowSets = Set<Set<UIColor>>()
        var colSets = Set<Set<UIColor>>()
        
        var i = 0
        var j = 0
        
        
        for index in 1...currentLevelSides {
            
            var rowSet = Set<UIColor>()
            var colSet = Set<UIColor>()
            
            for _ in 1...currentLevelSides {
                rowSet.insert(arrPuzzleColors[i])
                colSet.insert(arrPuzzleColors[j])
                i += 1
                j += currentLevelSides
            }
            
            if rowSet.count == 1 {
                rowSets.insert(rowSet)
            }
            
            if colSet.count == 1 {
                colSets.insert(colSet)
            }
            
            j = index
        }
        
        if rowSets.count == currentLevelSides || colSets.count == currentLevelSides {
            success = true
        }
        
        if success {
            
            let alert = UIAlertController(title: "Congratulations!!!", message: "You won this round.", preferredStyle: .ActionSheet)
            let playNextLevel = "Play Round \(currentLevel+1)"
            let playAgainAction = UIAlertAction(title: playNextLevel, style: .Default, handler: { (action) in
                self.currentLevel += 1
                self.currentLevelSides += 1
                self.arrPuzzleColors.removeAll()
                self.refreshData()
                self.collectionView.performBatchUpdates({ 
                    self.collectionView.reloadSections(NSIndexSet(index: 0))
                    }, completion: nil)
            })
            alert.addAction(playAgainAction)
            
            let exitAction = UIAlertAction(title: "Exit", style: .Destructive, handler: { (action) in
                exit(0)
            })
            alert.addAction(exitAction)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let cgFloatPadding = CGFloat(padding)
        return UIEdgeInsets(top: cgFloatPadding, left: cgFloatPadding, bottom: cgFloatPadding, right: cgFloatPadding)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        let cgFloatPadding = CGFloat(padding)
        return cgFloatPadding
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        let cgFloatPadding = CGFloat(padding)
        return cgFloatPadding
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let interItemPadding = (currentLevelSides - 1) * padding
        let allItemPadding = 2 * padding
        let totalPadding = CGFloat(interItemPadding + allItemPadding)
        let cellSide = ((screenWidth - totalPadding) / CGFloat(currentLevelSides))
        return CGSize(width: cellSide, height: cellSide)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 60)
    }
}
