

import Foundation
import UIKit

class SentMemesTableViewController : UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    private var meme: Meme!
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    private var memeEditorShown = false
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        return appDelegate.memes
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.reloadData()
        
        if (appDelegate.memes.count == 0) {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
            }
    }
    
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            print(appDelegate.memes.count)
            
            if (appDelegate.memes.count == 0) && (memeEditorShown == false) {
                performSegue(withIdentifier: "MemeEditorSegueFromMemeScenesTable", sender: self)
                memeEditorShown = true
            }
        }
    
    @IBAction func editTable(sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        // Toggle the Done and Edit buttons based on editing state
        if tableView.isEditing {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell", for: indexPath) as! SentMemesTableViewCell
        let meme = appDelegate.memes[indexPath.row]
        
        // Set the name and image
       
        cell.topTextLabel.text = meme.topText
        cell.bottomTextLabel.text = meme.bottomText
        cell.memeImageView.image = meme.memedImage
    
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = self.memes[indexPath.row]
        performSegue(withIdentifier: "DetailsSegueFromTable", sender: meme)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            meme = nil
            appDelegate.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsSegueFromTable" {
            let controller = segue.destination as! MemeDetailViewController
            controller.meme = sender as? Meme
        }
    }
    
}

