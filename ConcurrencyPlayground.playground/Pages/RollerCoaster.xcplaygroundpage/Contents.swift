//: [Previous](@previous)
// Roller coaster problem described in Gregory R. Andrews. Concurrent Programming
// Solution proposed by Allen B. Downey in Little book of Semaphores

import Foundation
import PlaygroundSupport

var str = "Hello, playground"
PlaygroundPage.current.needsIndefiniteExecution = true

public class RollerCoasterCar {
    
    public let allowedPassengers:Int
    private let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    private let allAboard = DispatchSemaphore(value: 0)
    private let allAshore = DispatchSemaphore(value: 0)
    
    private let mutex = DispatchSemaphore(value: 1)
    
    private var currentOnBoardPassengers = 0
    
    public let trackNumber:Int
    public private(set) weak var ride:RollerCoasterRide?
    
    init(forRide ride:RollerCoasterRide, withCapacity numPassengers:Int, andTrack trackNum:Int) {
        self.ride = ride
        allowedPassengers = numPassengers
        trackNumber = trackNum
    }
    
    public func load() {
        print("Attention ride will begin shortly, please proceed to track(\(trackNumber))")
        
        ride?.beginBoarding(forCar: self)
        allAboard.wait()
    }
    
    public func beginRide() {
        print("All aboard, ride on going on track(\(trackNumber))")
    }
    
    public func unload() {
        print("Ride terminated on track(\(trackNumber)), all passengers disembark")
        ride?.beginUnBoarding(forCar: self)
        allAshore.wait()
    }
    
    public func boardPassenger(passenger:Passenger) {
        
        
        mutex.wait()
        
        if currentOnBoardPassengers < allowedPassengers {
         
            currentOnBoardPassengers = currentOnBoardPassengers + 1
            
            print("\(currentOnBoardPassengers) of \(allowedPassengers) passengers have boarded car(\(trackNumber))")
            
            if currentOnBoardPassengers == allowedPassengers {
                allAboard.signal()
            }
            
        }
        
        mutex.signal()
    }
    
    public func unboardPassenger(passenger:Passenger) {
        
        mutex.wait()
        
        currentOnBoardPassengers = currentOnBoardPassengers - 1
        if currentOnBoardPassengers == 0 {
            allAshore.signal()
        }
        
        mutex.signal()
    }
    
    public func run() {
        
        dispatchQueue.async {
            for _ in 0..<10 {
                
                self.ride?.enterBoardingArea(atTrack: self.trackNumber, andPerform: { 
                    self.load()
                })
                
                self.beginRide()
                
                self.ride?.enterUnBoardingArea(atTrack: self.trackNumber, andPerform: { 
                    self.unload()
                })
                
            }
            
            print("track(\(self.trackNumber)) closed, come back tomorrow")
        }
        
    }
}

public class RollerCoasterRide {
    
    public let numCars:Int
    private let boardingAreaQueue:[DispatchSemaphore]
    private let unboardingAreaQueue:[DispatchSemaphore]
    private var cars:[RollerCoasterCar]
    
    private let boardQueue = DispatchSemaphore(value: 0)
    private let unboardQueue = DispatchSemaphore(value: 0)
    
    public private(set) var currentBoardingIndex = 0
    public private(set) var currentUnBoardingIndex = 0
    
    init(withNumCars numCars:Int, andCarCapacity capacity:Int) {
        self.numCars = numCars
        boardingAreaQueue = Array(repeating: DispatchSemaphore(value:0), count: numCars)
        unboardingAreaQueue = Array(repeating: DispatchSemaphore(value:0), count: numCars)
        
        cars = [RollerCoasterCar]()
        
        for i in 0..<self.numCars {
            cars.append(RollerCoasterCar(forRide: self, withCapacity: capacity, andTrack: i))
        }
    }
    
    private func next(_ index:Int) -> Int {
        return (index + 1) % numCars
    }
    
    public func beginBoarding(forCar car:RollerCoasterCar) {
        
        for _ in 0..<car.allowedPassengers {
            boardQueue.signal()
        }
    }
    
    public func beginUnBoarding(forCar car:RollerCoasterCar) {
        
        for _ in 0..<car.allowedPassengers {
            unboardQueue.signal()
        }
    }
    
    public func enterBoardingArea(atTrack trackNum:Int, andPerform function:(()->Void)) {
        
        boardingAreaQueue[trackNum].wait()
        
        function()
        
        currentBoardingIndex = next(currentBoardingIndex)
        
        boardingAreaQueue[next(trackNum)].signal()
    }
    
    public func enterUnBoardingArea(atTrack trackNum:Int, andPerform function:(()->Void)) {
        
        unboardingAreaQueue[trackNum].wait()
        
        function()
        
        currentUnBoardingIndex = next(currentUnBoardingIndex)
        
        unboardingAreaQueue[next(trackNum)].signal()
    }
    
    public func boardPassenger(passenger:Passenger) {
        
        boardQueue.wait()
        
        cars[currentBoardingIndex].boardPassenger(passenger: passenger)
        
    }
    
    public func unboardPassenger(passenger:Passenger) {
        
        unboardQueue.wait()
        
        cars[currentUnBoardingIndex].unboardPassenger(passenger: passenger)
        
    }
    
    public func run() {
        
        self.boardingAreaQueue.first?.signal()
        self.unboardingAreaQueue.first?.signal()
        
        for car in cars {
            car.run()
        }
    }

    
}

public class Passenger {
    
    private let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    public func board(ride:RollerCoasterRide) {
     
        ride.boardPassenger(passenger: self)
        
    }
    
    public func unboard(ride:RollerCoasterRide) {
        
        ride.unboardPassenger(passenger: self)
    }
    
    public func run(goTo ride:RollerCoasterRide) {
        
        dispatchQueue.async {
         
            while true {
                
                self.board(ride: ride)
                self.unboard(ride: ride)
            }
        }
    }
}

let spaceMountain = RollerCoasterRide(withNumCars: 3, andCarCapacity: 10)

spaceMountain.run()

let passengers = Array(repeating: Passenger(), count: 30)

for passenger in passengers {
    passenger.run(goTo: spaceMountain)
}


//: [Next](@next)
