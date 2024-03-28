//  WSSession.swift
//  Created by Alvaro Royo on 13/3/22.

import Combine
import Foundation

@available(iOS 13.0, *)
public class WSSession {
    public enum Status {
        case connected, disconnectad
    }

    private let session = URLSession.shared
    private var socket: URLSessionWebSocketTask?
    private let url: URL
    public private(set) var status = CurrentValueSubject<Status, Never>(.disconnectad)
    public private(set) var messages = PassthroughSubject<URLSessionWebSocketTask.Message, Error>()
    private var timer: Timer?

    public init(url: URL) {
        self.url = url
    }

    public convenience init?(url: String) {
        guard let url = URL(string: url) else { return nil }
        self.init(url: url)
    }

    public func connect() {
        socket = session.webSocketTask(with: url)
        listen()
        socket?.resume()
        sendPing()
    }

    public func disconnect() {
        socket?.cancel()
        status.send(.disconnectad)
        messages.send(completion: .finished)
    }

    private func sendPing() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] timer in
            guard self?.status.value == .connected else {
                timer.invalidate()
                self?.timer = nil
                self?.status.send(.disconnectad)
                return
            }
            self?.socket?.sendPing(pongReceiveHandler: { error in
                let currentStatus = self?.status.value ?? .disconnectad
                let newStatus: Status = error == nil ? .connected : .disconnectad
                if currentStatus != newStatus {
                    self?.status.send(newStatus)
                }
            })
        })
    }

    private func listen() {
        socket?.receive(completionHandler: { [weak self] result in
            switch result {
            case let .success(message):
                self?.messages.send(message)
                self?.listen()
            case let .failure(error):
                self?.status.send(.disconnectad)
                self?.messages.send(completion: .failure(error))
                print(error.localizedDescription)
            }
        })
    }

    public func send<T: Encodable>(object: T, _ completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let data = try? JSONEncoder().encode(object) else {
            completion?(.failure(WSSessionError.dataEncoderFails))
            return
        }
        send(data: data, completion)
    }

    public func send(data: Data? = nil, string: String? = nil, _ completion: ((Result<Void, Error>) -> Void)? = nil) {
        var message: URLSessionWebSocketTask.Message?
        if let data = data {
            message = .data(data)
        } else if let string = string {
            message = .string(string)
        }
        guard let message = message else {
            completion?(.failure(WSSessionError.emptyMessage))
            return
        }
        socket?.send(message, completionHandler: { error in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        })
    }
}

@available(iOS 13.0, *)
public extension WSSession {
    enum WSSessionError: Error {
        case emptyMessage
        case dataEncoderFails
    }
}
