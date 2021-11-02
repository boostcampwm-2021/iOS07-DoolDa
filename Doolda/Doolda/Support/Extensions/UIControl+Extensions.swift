//
//  UIControl+Extensions.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/02.
//

import Combine
import UIKit

extension UIControl {
    class InteractionSubscription<S: Subscriber>: Subscription where S.Input == UIControl {
        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event
        
        init(subscriber: S, control: UIControl, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            
            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        func request(_ demand: Subscribers.Demand) { }
        func cancel() { }
        
        @objc func handleEvent(_ sender: UIControl) {
            _ = subscriber?.receive(sender)
        }
    }
    
    struct InteractionPublisher: Publisher {
        typealias Output = UIControl
        typealias Failure = Never
        
        private let control: UIControl
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, UIControl == S.Input {
            let subscription = InteractionSubscription(subscriber: subscriber, control: control, event: event)
            subscriber.receive(subscription: subscription)
        }
    }
    
    func publisher(for event: UIControl.Event) -> UIControl.InteractionPublisher {
        return InteractionPublisher(control: self, event: event)
    }
}
