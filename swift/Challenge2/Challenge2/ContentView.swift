//
//  ContentView.swift
//  Challenge2
//
//  Created by Edward Fitz Abucay on 9/20/24.
//

import SwiftUI

enum Choices {
    case Rock, Paper, Scissors
    
    var text: String {
        switch self {
        case .Rock: return "🪨"
        case .Paper: return "📃"
        case .Scissors: return "✂️"
        }
    }
}

enum SimonWants {
    case Win, Lose
    
    var text: String {
        switch self {
        case .Win: return "WIN"
        case .Lose: return "LOSE"
        }
    }
}

struct ContentView: View {
    let choices = [Choices.Rock, Choices.Paper, Choices.Scissors]
    let totalGames = 10
    
    @State private var playerScore = 0
    @State private var playerTurns = 1
    @State private var appRand = Int.random(in: 0...2)
    @State private var simonRand = Bool.random()
    @State private var isGameEnd = false
    
    var appChoice: Choices {
        choices[appRand]
    }
    
    var simonSays: SimonWants {
        simonRand ? SimonWants.Win : SimonWants.Lose
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Turn \(playerTurns)")
                    .font(.title)
                Text("Your score: \(playerScore)")
                Text("The app chooses: \(appChoice.text)")
                Text("The app want's you to \(simonSays.text)")
            }
            Spacer()
            Section("Select from the choices below:") {
                HStack {
                    ForEach(choices, id: \.self) { choice in
                        Button(choice.text) {
                            choiceTapped(choice)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(.circle)
                    }
                }
                .font(.system(size: 60))
                .foregroundStyle(.white)
            }
            .padding()
            Spacer()
        }
        .padding()
        .alert("End Game!", isPresented: $isGameEnd) {
            Button("Continue", action: reset)
        } message: {
            Text("Your total score is \(playerScore)")
        }
    }
    
    func choiceTapped(_ playerChoice: Choices) {
        var outcome: SimonWants {
            switch (playerChoice, appChoice) {
            case (.Rock, .Rock): return .Lose
            case (.Rock, .Scissors): return .Win
            case (.Rock, .Paper): return .Lose
            case (.Paper, .Paper): return .Lose
            case (.Paper, .Rock): return .Win
            case (.Paper, .Scissors): return .Lose
            case (.Scissors, .Scissors): return .Lose
            case (.Scissors, .Paper): return .Win
            case (.Scissors, .Rock): return .Lose
            }
        }
        
        if simonSays == .Win && outcome == .Win {
            playerScore += 1
        } else if simonSays == .Lose && outcome == .Lose {
            playerScore += 1
        }
        
        playerTurns += 1
        
        if playerTurns >= totalGames {
            isGameEnd = true
        }
        toggle()
    }
    
    func toggle() {
        appRand = Int.random(in: 0...2)
        simonRand = Bool.random()
    }
    
    func reset() {
        playerScore = 0
        playerTurns = 1
        isGameEnd = false
        toggle()
    }
}

#Preview {
    ContentView()
}
