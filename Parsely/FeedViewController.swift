//
//  FeedViewController.swift
//  Parsely
//
//  Created by Gyandeep Reddy on 4/8/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
   
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var Recipes = [PFObject]()
    var numberOfRecipes: Int!
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        myRefreshControl.addTarget(self, action: #selector(loadRecipes), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadRecipes()
        
    }
    
    @objc func loadRecipes(){
        
        numberOfRecipes = 20
        let query = PFQuery(className: "Recipes")
        //let test = PFQuery(className: "Recipes"', predicate: )
        query.includeKeys(["name", "cook_time", "prep_time", "tags"])
        print("Search bar text used in query: \(searchBar.text!)")
        query.whereKey("tags", contains: searchBar.text!.lowercased())
        query.limit = 20
        query.findObjectsInBackground(){ (Recipes, error) in
            if Recipes != nil {
                self.Recipes = Recipes!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
            
        }
        
    }
    
    func loadMoreRecipes(){
        numberOfRecipes+=20
        let query = PFQuery(className: "Recipes")
        //let test = PFQuery(className: "Recipes"', predicate: )
        query.includeKeys(["name", "cook_time", "prep_time", "tags"])
        //print("Search bar text used in query: \(searchBar.text!)")
        query.whereKey("tags", contains: searchBar.text!.lowercased())
        query.limit = 20
        query.findObjectsInBackground(){ (Recipes, error) in
            if Recipes != nil {
                for recipe in Recipes! {
                    self.Recipes.append(recipe)
                }
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Recipes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeCell
        let recipe = Recipes[indexPath.row]
        let nameRecipe = recipe["name"] as! String
        cell.recipeName.text = nameRecipe
        let prepTime = recipe["prep_time"] as! String
        cell.prepTimeLabel.text = prepTime
        let cookTime = recipe["cook_time"] as! String
        cell.cookTimeLabel.text = cookTime
        let recipeTags = recipe["tags"] as! String
        cell.tagsLabel.text = recipeTags.split(separator: " ").joined(separator: ", ")
        let imageFile = recipe["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.recipePhotoView.af.setImage(withURL: url)
        cell.recipeId = recipe.objectId
        
        let query = PFQuery(className: "User_Favorite_Recipe")
        query.includeKeys(["recipeId", "userId", "favorited"])
        query.whereKey("recipeId", equalTo: recipe.objectId!)
        query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        query.findObjectsInBackground() { (objects, error) in
            if objects!.count != 0 {
                if(objects![0]["favorited"] as! Bool == true) {
                    cell.setFavorited(true)
                }
            }
        }
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //print("User search text: \(searchText)")
        //print("Search bar text: \(searchBar.text)")
        loadRecipes()
        tableView.reloadData()
    }
 
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate
        else {return}
        delegate.window?.rootViewController = loginViewController
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is UITableViewCell {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            let recipe = Recipes[indexPath.row]
            let detailsViewController = segue.destination as! RecipeDetailsViewController
            detailsViewController.recipe = recipe
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    

}
