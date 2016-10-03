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
    
    let arrFixedColors: [UIColor] = [UIColor.red, UIColor.yellow, UIColor.green, UIColor.orange, UIColor.purple, UIColor.blue, UIColor.darkGray, UIColor.lightGray, UIColor.gray, UIColor.white, UIColor.cyan, UIColor.magenta, UIColor.brown]
    var arrPuzzleColors: [UIColor] = []
    var prevRandom: Int = 0
    var currentLevelSides: Int = 2
    let padding = 1
    var currentLevel = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.isNavigationBarHidden = true
        collectionView.register(UINib(nibName: "PuzzleHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "PuzzleHeader")
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPuzzleColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PuzzleCell", for: indexPath)
        cell.backgroundColor = arrPuzzleColors[(indexPath as NSIndexPath).item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PuzzleHeader", for: indexPath) as! PuzzleHeader
        headerView.lblRound.text = "Round \(currentLevel)"
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, didMoveTo toIndexPath: IndexPath) {
        let color: UIColor = arrPuzzleColors.remove(at: (at as NSIndexPath).item)
        arrPuzzleColors.insert(color, at: (toIndexPath as NSIndexPath).item)
    }
    
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didEndDraggingItemTo indexPath: IndexPath) {
        
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
            
            let alert = UIAlertController(title: "Congratulations!!!", message: "You won this round.", preferredStyle: .actionSheet)
            let playNextLevel = "Play Round \(currentLevel+1)"
            let playAgainAction = UIAlertAction(title: playNextLevel, style: .default, handler: { (action) in
                self.currentLevel += 1
                self.currentLevelSides += 1
                self.arrPuzzleColors.removeAll()
                self.refreshData()
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                    }, completion: nil)
            })
            alert.addAction(playAgainAction)
            
            let exitAction = UIAlertAction(title: "Exit", style: .destructive, handler: { (action) in
                exit(0)
            })
            alert.addAction(exitAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cgFloatPadding = CGFloat(padding)
        return UIEdgeInsets(top: cgFloatPadding, left: cgFloatPadding, bottom: cgFloatPadding, right: cgFloatPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let cgFloatPadding = CGFloat(padding)
        return cgFloatPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cgFloatPadding = CGFloat(padding)
        return cgFloatPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        let interItemPadding = (currentLevelSides - 1) * padding
        let allItemPadding = 2 * padding
        let totalPadding = CGFloat(interItemPadding + allItemPadding)
        let cellSide = ((screenWidth - totalPadding) / CGFloat(currentLevelSides))
        return CGSize(width: cellSide, height: cellSide)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 60)
    }
}
