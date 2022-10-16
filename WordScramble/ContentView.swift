//
//  ContentView.swift
//  WordScramble
//
//  Created by OAA on 16/08/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    @State private var restartGame = false
        
    var body: some View {
        
        VStack {
            
            Text("WordScramble")
                .font(.title)
                .fontWeight(.bold)
            
            NavigationView{
                List {
                    Section ("Your guesses") {
                        TextField("Enter your word", text: $newWord)
                            .autocapitalization(.none)
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                          
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                .navigationTitle(rootWord)
                .toolbar {
                    Button("New game") {restartGame.toggle()}
                }
                .alert("Are you sure you want to restart game?", isPresented: $restartGame) {
                    Button("Yes") { startGame() }
                    Button("No", role: .cancel) {}
                } message: {
                    Text("Your score will be reset")
                }
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
            }
            
            Text("Total Score:")
                .font(.title2)
                .fontWeight(.medium)
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
        
        }
    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isNewWord(word: answer) else {
            wordError(title: "It's the same word", message: "Do not try to trick!")
            return
        }
        
        guard isRightLength(word: answer) else {
            wordError(title: "Too short", message: "Please enter words with more than 2 letters")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't speall that word from \(rootWord)")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make em up!")
            return
        }

        score += answer.count
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        
    }
    
    
    
    func startGame() {
        
        restartGame = false
        usedWords = []
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isNewWord(word: String) -> Bool {
        !(word == rootWord)
    }
    
    func isRightLength(word: String) -> Bool {
        word.count >= 3
    }
    
    func isPossible(word: String) -> Bool {
        
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
    
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
