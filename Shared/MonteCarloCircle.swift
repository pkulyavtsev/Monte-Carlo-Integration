//
//  MonteCarloCircle.swift
//  Monte Carlo Integration
//
//  Created by Jeff Terry on 12/31/20.
//

import Foundation
import SwiftUI

class MonteCarloCircle: NSObject, ObservableObject {
    
    @MainActor @Published var insideData = [(xPoint: Double, yPoint: Double)]()
    @MainActor @Published var outsideData = [(xPoint: Double, yPoint: Double)]()
    @Published var totalGuessesString = ""
    @Published var guessesString = ""
    @Published var piString = ""
    @Published var enableButton = true
    
    var pi = 0.0
    var guesses = 1
    var totalGuesses = 0
    var totalIntegral = 0.0
    var radius = 1.0
    var firstTimeThroughLoop = true
    
    @MainActor init(withData data: Bool){
        
        super.init()
        
        insideData = []
        outsideData = []
        
    }


    /// calculate the value of π
    ///
    /// - Calculates the Value of π using Monte Carlo Integration
    ///
    /// - Parameter sender: Any
    func calculatePI() async {
        
        var maxGuesses = 0.0
        let boundingBoxCalculator = BoundingBox() ///Instantiates Class needed to calculate the area of the bounding box.
        
        
        maxGuesses = Double(guesses)
        
        let newValue = await calculateMonteCarloIntegral(radius: radius, maxGuesses: maxGuesses)
        
        totalIntegral = totalIntegral + newValue
        
        totalGuesses = totalGuesses + guesses
        
        await updateTotalGuessesString(text: "\(totalGuesses)")
        
        //totalGuessesString = "\(totalGuesses)"
        
        ///Calculates the value of π from the area of a unit circle
        
        pi = totalIntegral/Double(totalGuesses) * boundingBoxCalculator.calculateSurfaceArea(numberOfSides: 2, lengthOfSide1: 1.0, lengthOfSide2: 1.0, lengthOfSide3: 0.0)
        
        await updatePiString(text: "\(pi)")
        
        //piString = "\(pi)"
        
       
        
    }

    /// calculates the Monte Carlo Integral of a Circle
    ///
    /// - Parameters:
    ///   - radius: radius of circle
    ///   - maxGuesses: number of guesses to use in the calculaton
    /// - Returns: ratio of points inside to total guesses. Must mulitply by area of box in calling function
    func calculateMonteCarloIntegral(radius: Double, maxGuesses: Double) async -> Double {
        
        var numberOfGuesses = 0.0
        var pointsInRadius = 0.0
        var integral = 0.0
        var point = (xPoint: 0.0, yPoint: 0.0)
        var radiusPoint = 0.0 //i dont remember what this is lol
        var height = 4.0//Double.random(in: 0.0...5.0) //gives random height between 0 and 5 meters...
        var initialEnergy = 1.0 //Use a normalized value, like 1, then take 10 percent off each time
        var currentEnergy = 0.0 // really not sure why two seperate but whatever
        var lossEnergy = 0.10 //this is the % lost each interaction...woohoo
        var radius = 1.0 //radius of each depth of penetration is is is 1...for now
        var theta = Double.random(in: 0.0...(2*Double.pi)) ///uhhh between 0 and 2 pi radians...yes this is math
        //STOPPING POINT::::::: NEXT WE WANT TO TAKE AWAY ENERGY AND BOUNCE
        
        var newInsidePoints : [(xPoint: Double, yPoint: Double)] = []
        var newOutsidePoints : [(xPoint: Double, yPoint: Double)] = []
        
       
        currentEnergy = initialEnergy
        //particle hits the wall...travels 1m parralelll to x axis
        point.xPoint =  point.xPoint + radius //given condition that parallel and travels 1 radius before next event
        currentEnergy -= lossEnergy //subtracts lossEnergy from currrentEnergy due to initial hit
        
        while currentEnergy > 0 && point.xPoint < 5 && point.yPoint > 0 && point.yPoint < 5 { //incorporate breaks, perhaps
            
            //when x greater than 5 or when Energy = 0
            
            /* Calculate 2 random values within the box */
            /* Determine the distance from that point to the origin */
            /* If the distance is less than the unit radius count the point being within the Unit Circle */
            
            //after height, travels 1 m (inc x by 1, y by 0) this was calculated outside the while loop woohooo......
            // particle is at (1,h)
            //need to take off 10% from initial energy
            // next generate a x and y that are within 1 unit of the previous point
            // use theta as rand, this r is permanently 1 (until otherwise specified)
            // maybe do a while loop???????
            
            point.xPoint = point.xPoint + (radius * cos(theta))
                                //Double.random(in: 0.0...1.0) //Chooses X
            point.yPoint = point.yPoint + (radius * sin(theta))
                                //sqrt(1 - pow(point.xPoint, 2)) //Chooses random  Y, is X the right X??
            
            radiusPoint = sqrt(pow(point.xPoint,2.0) + pow(point.yPoint,2.0)) //i forgot what this is too
            
            theta = Double.random(in: 0.0...(2*Double.pi))
            
            let checkValue = point.xPoint ///wall is going from 0-5m since it is 5m thick and 5 m high
            ///every time it iterates it needs to decrease by 10%
            ///
            
            // if inside the circle add to the number of points in the radius
            if((checkValue) >= 5.0){ //check if X >5m, that means it outside the wall. Woohoo.
                pointsInRadius += 1.0
                
                newInsidePoints.append(point)
               
            }
            else { //if outside the circle do not add to the number of points in the radius
                
                
                newOutsidePoints.append(point)

                
            }
            
            numberOfGuesses += 1.0
            
            
            
            
            }

        
        integral = Double(pointsInRadius)
        
        //Append the points to the arrays needed for the displays
        //Don't attempt to draw more than 250,000 points to keep the display updating speed reasonable.
        
        if ((totalGuesses < 500001) || (firstTimeThroughLoop)){
        
//            insideData.append(contentsOf: newInsidePoints)
//            outsideData.append(contentsOf: newOutsidePoints)
            
            var plotInsidePoints = newInsidePoints
            var plotOutsidePoints = newOutsidePoints
            
            if (newInsidePoints.count > 750001) {
                
                plotInsidePoints.removeSubrange(750001..<newInsidePoints.count)
            }
            
            if (newOutsidePoints.count > 750001){
                plotOutsidePoints.removeSubrange(750001..<newOutsidePoints.count)
                
            }
            
            await updateData(insidePoints: plotInsidePoints, outsidePoints: plotOutsidePoints)
            firstTimeThroughLoop = false
        }
        
        return integral
        }
    
    
    /// updateData
    /// The function runs on the main thread so it can update the GUI
    /// - Parameters:
    ///   - insidePoints: points inside the circle of the given radius
    ///   - outsidePoints: points outside the circle of the given radius
    @MainActor func updateData(insidePoints: [(xPoint: Double, yPoint: Double)] , outsidePoints: [(xPoint: Double, yPoint: Double)]){
        
        insideData.append(contentsOf: insidePoints)
        outsideData.append(contentsOf: outsidePoints)
    }
    
    /// updateTotalGuessesString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the number of total guesses
    @MainActor func updateTotalGuessesString(text:String){
        
        self.totalGuessesString = text
        
    }
    
    /// updatePiString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the current value of Pi
    @MainActor func updatePiString(text:String){
        
        self.piString = text
        
    }
    
    
    /// setButton Enable
    /// Toggles the state of the Enable Button on the Main Thread
    /// - Parameter state: Boolean describing whether the button should be enabled.
    @MainActor func setButtonEnable(state: Bool){
        
        
        if state {
            
            Task.init {
                await MainActor.run {
                    
                    
                    self.enableButton = true
                }
            }
            
            
                
        }
        else{
            
            Task.init {
                await MainActor.run {
                    
                    
                    self.enableButton = false
                }
            }
                
        }
        
    }

}
