//
//  ViewController.swift
//  WordScramble
//
//  Created by Diego Castro on 10/08/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer)) //The ".add" parameter indicated that the button is going to be a "plus" symbol
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") //We use if let because Bundle.main.url returns an optional URL, it may be an URL, or it may be nil
        {
            if let startWords = try? String(contentsOf: startWordsURL) //We use Try? because String(contents of: ) may throw an error, so this will be done only if there's no error.
            {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["Text file couldn't be loaded"]
        }
        startGame()
    }
    
    func startGame () {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true) //Remove any previous words stores in the usedWords array
        tableView.reloadData() //Reloads all the sections and rows of the table.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row] //The text that will be seen in each table cell
        
        return cell
    }
    
    @objc func promptForAnswer () {
        let ac = UIAlertController (title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in //The array before "in" specifies the input of the closure, it also says that both the viewcontroller (self) and the alert controller are captured in a weak way, so it might not exist in the future, it may be nil.
            guard let answer = ac?.textFields?[0].text else { return }
            //The textfield is indexed to zero because it refers to the first, and only, textfiled in the alert.
            
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present (ac, animated: true)
    }
    
    func submit (_ answer: String) {
        //This method should check 3 conditions
        //Is the word possible? is it original? is it real?
        let lowerAnswer = answer.lowercased() //Lowercases the string
        let errorTittle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer){
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath (row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic) //These two lineas of code are neccesary only to display the new row with an animation
                    return
                } else {
                    errorTittle = "Word not recognized"
                    errorMessage = "You can't just make them up you know!"
                }
            } else {
                errorTittle = "Word already used"
                errorMessage = "You have to be more original"
            }
        } else {
            errorTittle = "Word not Possible"
            errorMessage = "you can't speel that word from \(title!.lowercased())"
        }
        let ac = UIAlertController(title: errorTittle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present (ac, animated: true)
        
        
    }
    
    func isPossible (word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) // The .firstIndex method returns the position of the substring if it existis, or nil if it doesn't
            {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal (word: String) -> Bool {
        
        return !usedWords.contains(word)
    }
    
    func isReal (word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count) //it is better to work with utf16 notation when using functions not created by ourselves
        let misspellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspellRange.location == NSNotFound //NSRange predates swift by looong, thus, we can not use nil here, that why we use NSNotFound, this means that no misspells were found, hence, the word exists.
    }


}

