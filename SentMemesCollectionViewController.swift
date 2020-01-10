

import Foundation
import UIKit

let reuseIdentifier = "MemeItemCell"

class SentMemesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var toolbar: UIToolbar!
    var toolbarItemDelete: UIBarButtonItem!

    private var meme: Meme!
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    private var inEditingMode = false

    // Layout properties
    let minimumSpacingBetweenCells = 5
    let cellsPerRowInPortraitMode = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Create the toolbar
        toolbar = UIToolbar(frame: CGRect(
            x: 0,
            y: (self.view.bounds.size.height - 44),
            width: self.view.bounds.size.width,
            height: 44))
        toolbar.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleTopMargin]
        self.view.addSubview(toolbar)

        // Create the trash icon (UIBarButtonItem)
        toolbarItemDelete = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: nil, action: "deleteSelectedModels")
        toolbar.items = [toolbarItemDelete]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()

        // Turn edit mode off
        turnEditModeOff()
    }

    // MARK: - Edit collection and toolbar

    @IBAction func editCollection(sender: UIBarButtonItem) {
        // Toggle edit mode
        if inEditingMode {
            turnEditModeOff()
        } else {
            toolbar.isHidden = false
            editButton.title = "Done"
            self.collectionView?.allowsMultipleSelection = true
            self.tabBarController?.tabBar.isHidden = true
            inEditingMode = true
        }
    }

    private func turnEditModeOff() {
        // Deselect all items when edit mode is turned off
        if let itemPaths = self.collectionView?.indexPathsForSelectedItems {
            for indexPath in itemPaths {
                self.collectionView?.deselectItem(at: indexPath, animated: false)
            }
        }
        // Disable multiple selection, show tab bar, hide edit toolbar
        self.collectionView?.allowsMultipleSelection = false
        self.tabBarController?.tabBar.isHidden = false
        toolbar.isHidden = true

        // Set edit button properties
        editButton.title = "Edit"
        if (appDelegate.memes.count == 0) {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }

        // Disable trash icon and set edit mode to false
        toolbarItemDelete.isEnabled = toolbarItemDeleteState()
        inEditingMode = false
    }

    private func toolbarItemDeleteState() -> Bool {
        // Enable or disable trash icon in toolbar based on items selected
        if let itemPaths = self.collectionView?.indexPathsForSelectedItems{
            if itemPaths.count > 0 {
                return true
            }
        }
        return false
    }

    // MARK: Meme Delete

    func deleteSelectedModels() {
        self.collectionView?.performBatchUpdates({
            if let itemPaths = self.collectionView?.indexPathsForSelectedItems {
                var indicesToDelete = [Int]()
                for indexPath in itemPaths {
                    indicesToDelete.append(indexPath.row)
                }

                indicesToDelete.sort()
                for index in indicesToDelete {
                    self.appDelegate.memes.remove(at: index)
                }
                self.collectionView?.deleteItems(at: itemPaths)
            }
        }, completion: nil)
        inEditingMode = false
        turnEditModeOff()
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use width in portrait mode; height in landscape
        let deviceOrientation = UIDevice.current.orientation
        var widthForCollection: CGFloat!
        if (deviceOrientation == UIDeviceOrientation.portrait) || (deviceOrientation == UIDeviceOrientation.portraitUpsideDown) {
            widthForCollection = self.view.frame.width
        } else {
            widthForCollection = self.view.frame.height
        }
        
        // To determine width of a cell we divide frame width by cells per row
        // Then compensate it by subtracting minimum spacing between cells
        // The last cell doesn't need compensation for spacing
        let width = Float(widthForCollection / CGFloat(cellsPerRowInPortraitMode)) -
            Float(minimumSpacingBetweenCells - (minimumSpacingBetweenCells / cellsPerRowInPortraitMode))
        let height = width
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(minimumSpacingBetweenCells)
    }

    

    // MARK: - UICollectionViewDataSource

    func deleteItems(at indexPaths: [IndexPath]){
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        
        let meme = appDelegate.memes[indexPath.row]
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleToFill
        imageView.clipsToBounds = true
        imageView.image = meme.memedImage
        cell.backgroundView = imageView
        
        // Selected state properties
        let backgroundView = UIView(frame: cell.contentView.frame)
        backgroundView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)
        
        let checkmarkImageView = UIImageView(frame: cell.contentView.frame)
        checkmarkImageView.contentMode = UIView.ContentMode.bottomRight
        checkmarkImageView.image = UIImage(named: "checkmark")
        backgroundView.addSubview(checkmarkImageView)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }


    
    // MARK: - UICollectionViewDelegate

    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !inEditingMode {
            meme = appDelegate.memes[indexPath.row]
            performSegue(withIdentifier: "DetailsSegueFromCollection", sender: meme)
        } else {
//            toolbarItemDelete.enabled = toolbarItemDeleteState()
            return
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if inEditingMode {
            toolbarItemDelete.isEnabled = toolbarItemDeleteState()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if !inEditingMode {
            collectionView.cellForItem(at: indexPath)?.selectedBackgroundView = nil
        }
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if !inEditingMode {
            collectionView.cellForItem(at: indexPath as IndexPath)?.selectedBackgroundView = nil
        }
        return true
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsSegueFromCollection" {
            let controller = segue.destination as! MemeDetailViewController
            controller.meme = meme
        }
    }
}
