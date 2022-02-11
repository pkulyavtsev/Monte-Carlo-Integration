//
//  ContentView.swift
//  Shared
//
//  Created by Jeff Terry on 12/31/20.
//

import SwiftUI

struct ContentView: View {
    
    @State var pi = 0.0
    @State var totalGuesses = 0.0
    @State var totalIntegral = 0.0
    @State var radius = 1.0
    @State var guessString = "23458"
    @State var totalGuessString = "0"
    @State var piString = "0.0"
    @State var n = 0.0 // initialize n for user input
    @State var nString = "10" //take in user input?
    
    // Setup the GUI to monitor the data from the Monte Carlo Integral Calculator
    @ObservedObject var monteCarlo = MonteCarloCircle(withData: true)
    
    //Setup the GUI View
    var body: some View {
        HStack{
            
            VStack{
                
                VStack(alignment: .center) { //vertically stacks text and textfield
                    Text("Guesses") //label for guesses  field
                        .font(.callout)
                        .bold()
                    TextField("# Guesses", text: $guessString) //Guesses field
                        .padding()
                }
                .padding(.top, 5.0)
                
                VStack(alignment: .center) { //vertically stacks text and textfield
                    Text("Total Guesses") //label for total guesses field
                        .font(.callout)
                        .bold()
                    TextField("# Total Guesses", text: $totalGuessString) //total  guesses field
                        .padding()
                }
                
                VStack(alignment: .center) { //vertically stacks text and textfield
                    Text("π")
                        .font(.callout)
                        .bold()
                    TextField("# π", text: $piString)
                        .padding()
                }
                
                
                Button("Cycle Calculation", action: {Task.init{await self.calculatePi()}})
                    .padding() 
                    .disabled(monteCarlo.enableButton == false)
                
                Button("Clear", action: {self.clear()})
                    .padding(.bottom, 5.0)
                    .disabled(monteCarlo.enableButton == false)
                
                if (!monteCarlo.enableButton){
                    
                    ProgressView()
                }
                
                
            }
            .padding()
            
            //DrawingField
            
            
            drawingView(redLayer:$monteCarlo.insideData, blueLayer: $monteCarlo.outsideData)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
            // Stop the window shrinking to zero.
            Spacer()
            
        }
    }
    
    func calculatePi() async {
        
        
        monteCarlo.setButtonEnable(state: false)
        
        monteCarlo.guesses = Int(guessString)!
        monteCarlo.radius = radius
        monteCarlo.totalGuesses = Int(totalGuessString) ?? Int(0.0)
        
        await monteCarlo.calculatePI()
        
        totalGuessString = monteCarlo.totalGuessesString
        
        piString =  monteCarlo.piString
        
        monteCarlo.setButtonEnable(state: true)
        
    }
    
    func clear(){
        
        guessString = "23458"
        totalGuessString = "0.0"
        piString =  ""
        monteCarlo.totalGuesses = 0
        monteCarlo.totalIntegral = 0.0
        monteCarlo.insideData = []
        monteCarlo.outsideData = []
        monteCarlo.firstTimeThroughLoop = true
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
