//: Playground - noun: a place where people can play

//This playground demonstrates a solution for the dining philosopher problem according to Tannenbaum

import Foundation
import PlaygroundSupport

var str = "Hello, playground"

public class Philosopher: Equatable{
    
    public enum State {
        case thinking,eating, hungry
    }
    
    public let id:String
    public var position:Int?
    public var state:State = .thinking
    public let permission = DispatchSemaphore(value: 0)
    public let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    public var isSeated: Bool {get{ return position != nil}}
    
    init(withId id:String) {
        self.id = id
    }
    
    func eat() {
        print("\(self.id) is 🍽")
    }
    
    func think() {
        print("\(self.id) is 🤔")
    }
    
    func askForPermission() {
        self.permission.wait()
    }
    
    func getPermission() {
        self.permission.signal()

    }
    
    func philosophize(at table:RestaurantTable) {
        
        if isSeated {
            
            dispatchQueue.async {
             
                var counter = 5
                
                repeat{
                    self.think()
                    table.takeforks(at: self.position!)
                    self.eat()
                    table.putdownForks(at: self.position!)
                    counter = counter - 1
                    
                }while counter > 0
                
                print("\(self.id) has left the restaurant🚶")
            }
        }
    }
    
    public static func ==(lhs: Philosopher, rhs: Philosopher) -> Bool{
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}

public class RestaurantTable{
    
    private var circularTable:[Philosopher] = []
    private let mutex = DispatchSemaphore(value: 1)
    
    public func takeforks(at position:Int) {
        
        executeCritical {
            
            circularTable[position].state = .hungry
            test(position: position)
            
        }

        circularTable[position].askForPermission()
    }
    
    public func putdownForks(at position:Int) {
        
        executeCritical {
            circularTable[position].state = .thinking
            test(position: left(of: position))
            test(position: right(of: position))
        }
        
    }
    
    private func test(position:Int) {
        
        
        if circularTable[position].state == .hungry && circularTable[left(of:position)].state != .eating && circularTable[right(of:position)].state != .eating {
            
            circularTable[position].state = .eating
            circularTable[position].getPermission()
            
        }
    }
    
    private func executeCritical(function:(() -> Void)) {
        
        mutex.wait()
        function()
        mutex.signal()
    }
    
    private func left(of position:Int) -> Int {
        return (position + circularTable.count - 1) % circularTable.count
    }
    
    private func right(of position:Int) -> Int {
        return (position + 1) % circularTable.count
    }
    
    public func seat(philosopher:Philosopher) {
        
        if !circularTable.contains(philosopher) {
            
            philosopher.position = circularTable.count
            circularTable.append(philosopher)
        }
        
    }
    
    public func beginMeal() {
        for philosopher in self.circularTable {
            philosopher.philosophize(at: self)
        }
    }
}

var table = RestaurantTable()

var socrates = Philosopher(withId: "SocratesⓈ")
var plato = Philosopher(withId: "Platoⓟ")
var aristotle = Philosopher(withId: "AristotleⒶ")
var descartes = Philosopher(withId: "DescartesⒹ")
var marx = Philosopher(withId: "Marxⓜ")

table.seat(philosopher: socrates)
table.seat(philosopher: plato)
table.seat(philosopher: aristotle)
table.seat(philosopher: descartes)
table.seat(philosopher: marx)

table.beginMeal()

PlaygroundPage.current.needsIndefiniteExecution = true
