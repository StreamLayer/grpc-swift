//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO


/// Usage: instantiate `Codegentest_FooClient`, then call methods of this protocol to make API calls.
internal protocol Codegentest_FooClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Codegentest_FooClientInterceptorFactoryProtocol? { get }

  func get(
    _ request: Codegentest_FooMessage,
    callOptions: CallOptions?
  ) -> UnaryCall<Codegentest_FooMessage, Codegentest_FooMessage>
}

extension Codegentest_FooClientProtocol {
  internal var serviceName: String {
    return "codegentest.Foo"
  }

  /// Unary call to Get
  ///
  /// - Parameters:
  ///   - request: Request to send to Get.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func get(
    _ request: Codegentest_FooMessage,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Codegentest_FooMessage, Codegentest_FooMessage> {
    return self.makeUnaryCall(
      path: "/codegentest.Foo/Get",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetInterceptors() ?? []
    )
  }
}

internal protocol Codegentest_FooClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'get'.
  func makeGetInterceptors() -> [ClientInterceptor<Codegentest_FooMessage, Codegentest_FooMessage>]
}

internal final class Codegentest_FooClient: Codegentest_FooClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Codegentest_FooClientInterceptorFactoryProtocol?

  /// Creates a client for the codegentest.Foo service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Codegentest_FooClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol Codegentest_FooProvider: CallHandlerProvider {
  var interceptors: Codegentest_FooServerInterceptorFactoryProtocol? { get }

  func get(request: Codegentest_FooMessage, context: StatusOnlyCallContext) -> EventLoopFuture<Codegentest_FooMessage>
}

extension Codegentest_FooProvider {
  internal var serviceName: Substring { return "codegentest.Foo" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Get":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Codegentest_FooMessage>(),
        responseSerializer: ProtobufSerializer<Codegentest_FooMessage>(),
        interceptors: self.interceptors?.makeGetInterceptors() ?? [],
        userFunction: self.get(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol Codegentest_FooServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'get'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetInterceptors() -> [ServerInterceptor<Codegentest_FooMessage, Codegentest_FooMessage>]
}
