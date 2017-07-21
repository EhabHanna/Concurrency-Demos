//: [Previous](@previous)
//This playground demonstrates the cigarette smoker's problem introduced by Patil S. S in 1971
//and a solution proposed by D. L. Parnas @CMU
import Foundation
import PlaygroundSupport

var str = "Hello, playground"
PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)

public enum CigaretteIngredient {
    case tobacco,paper,matches
}

public class SmokingTable {
    
    public let tobacco = DispatchSemaphore(value: 0)
    public let paper = DispatchSemaphore(value: 0)
    public let matches = DispatchSemaphore(value: 0)
    
    private let mutex = DispatchSemaphore(value: 1)
    //smoker semaphores should be keyed according to combinations of semaphore key values
    private let smokerSemaphores = [3:DispatchSemaphore(value:0),5:DispatchSemaphore(value:0),6:DispatchSemaphore(value:0)]
    
    private var smokers = [Smoker]()
    private var semaphoreKey = 0
    
    public let ashtray = DispatchSemaphore(value: 0)
    
    init() {
        
        smokers.append( Smoker(with: .tobacco))
        smokers[0].assign(semaphore: self.smokerSemaphores[3]!)
        smokers[0].table = self
        smokers.append( Smoker(with: .matches))
        smokers[1].assign(semaphore: self.smokerSemaphores[5]!)
        smokers[1].table = self
        smokers.append(Smoker(with: .paper))
        smokers[2].assign(semaphore: self.smokerSemaphores[6]!)
        smokers[2].table = self
        
        let tobaccoAssistant = AgentAssistant(with: .tobacco, table: self)
        let matchesAssistant = AgentAssistant(with: .matches, table: self)
        let paperAssistant = AgentAssistant(with: .paper, table: self)
        
        tobaccoAssistant.run()
        paperAssistant.run()
        matchesAssistant.run()
        
        for smoker in self.smokers {
            smoker.run()
        }
    }
    
    public func placeOntable(ingredient:CigaretteIngredient) {
        switch ingredient {
        case .tobacco:
            self.tobacco.signal()
        case .matches:
            self.matches.signal()
        case .paper:
            self.paper.signal()
        }
        
        print("\(ingredient) placed on table")
    }
    
    // semaphore key should be incremented according to series 1,2,4,8,... (f(0)=1, f(n) = 2*f(n-1))
    public func notifyParties(interestedIn ingredient:CigaretteIngredient) {
        
        switch ingredient {
        case .tobacco:
            semaphoreKey = semaphoreKey + 1
            self.smokerSemaphores[semaphoreKey]?.signal()
            break
        case .matches:
            semaphoreKey = semaphoreKey + 2
            self.smokerSemaphores[semaphoreKey]?.signal()
            break
        case .paper:
            semaphoreKey = semaphoreKey + 4
            self.smokerSemaphores[semaphoreKey]?.signal()
            break
            
        }
    }
    
    public func executeCritical(function:(()->Void)) {
        
        mutex.wait()
            function()
        mutex.signal()
    }
    
    public func putoutCigarette() {
        self.semaphoreKey = 0
        self.ashtray.signal()
    }
    
}

public class SmokingAgent {
    private let ingredients = [CigaretteIngredient.tobacco,.matches,.paper]
    private let dispatchQueue = DispatchQueue(label: "smokingAgent", qos: DispatchQoS.userInitiated)
    
    private func chooseIngredients() -> (CigaretteIngredient,CigaretteIngredient) {
        
        var (first,second):(CigaretteIngredient,CigaretteIngredient)
        
        first = ingredients[Int(arc4random_uniform(UInt32(ingredients.count)))]
        repeat{
            second = ingredients[Int(arc4random_uniform(UInt32(ingredients.count)))]
        }while (first == second)
        
        return(first,second)
    }
    
    public func run(at table:SmokingTable) {
        
        dispatchQueue.async {
            
            var count = 5
            var (first,second):(CigaretteIngredient,CigaretteIngredient)
            repeat{
                
                (first,second) = self.chooseIngredients()
                table.executeCritical {
                    table.placeOntable(ingredient: first)
                    table.placeOntable(ingredient: second)
                }
                table.ashtray.wait()
                
                count = count - 1
            }while(count > 0)
        }
        
    }
}

public class AgentAssistant {
    
    private weak var table:SmokingTable?
    private let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    private let ingredient:CigaretteIngredient
    
    init(with ingredient:CigaretteIngredient, table:SmokingTable) {
        self.ingredient = ingredient
        self.table = table
    }
    
    public func run () {
        
        dispatchQueue.async {
            
            while (true) {
                
                switch self.ingredient{
                case .tobacco:
                    self.table?.tobacco.wait()
                case .matches:
                    self.table?.matches.wait()
                case .paper:
                    self.table?.paper.wait()
                }
                
                self.table?.executeCritical {
                    self.table?.notifyParties(interestedIn: self.ingredient)
                }
            }
        }
        
    }
    
}


public class Smoker {
    public let ingredient:CigaretteIngredient
    public weak var table:SmokingTable?
    private let dispatchQueue:DispatchQueue
    private weak var semaphore:DispatchSemaphore?
    
    init(with ingredient:CigaretteIngredient) {
        self.ingredient = ingredient
        self.dispatchQueue = DispatchQueue(label: "\(ingredient)_smoker",qos: .userInitiated)
    }
    
    private func smoke() {
        print("\(ingredient)_smoker is smoking")
        table?.putoutCigarette()
    }
    
    public func assign(semaphore:DispatchSemaphore) {
        self.semaphore = semaphore
    }
    
    // problematic function that will cause deadlock
    private func getIngredientsBySelf() {
        
        print("\(ingredient)_smoker is trying to get ingredients")
        
        switch ingredient {
        case .tobacco:
            table?.paper.wait()
            table?.matches.wait()
        case .paper:
            table?.tobacco.wait()
            table?.matches.wait()
        case .matches:
            table?.paper.wait()
            table?.tobacco.wait()
        
        }
    }
    
    // correct function that will not cause deadlock
    private func waitForSomeoneElseToGetIngredients() {
        self.semaphore?.wait()
    }
    
    //someone else will notify you when to smoke
    public func lightUp() {
        self.semaphore?.signal()
    }
    
    public func run() {
        dispatchQueue.async {
            
            var count = 5
            
            repeat{
                
                self.waitForSomeoneElseToGetIngredients()
                self.smoke()
                count = count - 1
            }while(count > 0)
        }
    }
}

let table = SmokingTable()
let smith = SmokingAgent()

smith.run(at: table)

