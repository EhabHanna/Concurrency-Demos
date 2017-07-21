//: [Previous](@previous)

import Foundation
import PlaygroundSupport

var str = "Hello, playground"

public struct Product{
    
}

public class Shop {
    
    public var shelf = [Product]()
    private let shelfSize:Int
    private let items = DispatchSemaphore(value: 0)
    private let spaces:DispatchSemaphore
    private let mutex = DispatchSemaphore(value: 1)
    
    init(withShelfSize size:Int) {
        shelfSize = size
        spaces = DispatchSemaphore(value: size)
    }
    
    
    public func getProductFromShelf() -> Product {
        
        items.wait()
        
        mutex.wait()
            let product = shelf.removeLast()
        mutex.signal()
        
        spaces.signal()
        
        return product
    }
    
    public func putOnShelf(product:Product) {
        
        spaces.wait()
        
        mutex.wait()
            shelf.append(product)
        mutex.signal()
        
        items.signal()
    }
}

public class Consumer {
    
    private let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    private func consume(product:Product) {
        print("consumed an Item")
    }
    
    public func run(at shop:Shop) {
        
        dispatchQueue.async {
            
            var counter = 0
        
            while counter < 100 {
            
                let product = shop.getProductFromShelf()
                self.consume(product: product)
                
                
                counter = counter + 1
                
            }
            
        }
    }
}

public class Producer {
    
    private let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    private let id:String
    
    init(named name:String) {
        id = name
    }
    
    public func produce() -> Product {
        print("Producer (\(id)) produced an item")
        return Product()
    }
    
    public func run(at shop:Shop) {
        
        dispatchQueue.async {
            
            var counter = 0
            
            while (counter < 10) {
                    shop.putOnShelf(product: self.produce())

                counter = counter + 1
                
            }
        }
        
    }
}

let carrefour = Shop(withShelfSize: 1)

var producers = [Producer]()

producers.append( Producer(named: "Arnott's") )
producers.append( Producer(named: "Ritz") )
producers.append( Producer(named: "Lindt"))
producers.append( Producer(named: "Cadbury's"))
producers.append( Producer(named: "Haribo"))
producers.append( Producer(named: "Kraft"))
producers.append( Producer(named: "Kellog's"))
producers.append( Producer(named: "Farmdale"))
producers.append( Producer(named: "Lyttos"))
producers.append( Producer(named: "Helga's"))

let consumer = Consumer()
consumer.run(at: carrefour)

for producer in producers {
    producer.run(at: carrefour)
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
