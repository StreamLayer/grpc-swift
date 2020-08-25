/*
 * Copyright 2018, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import SwiftProtobufPluginLibrary

class Generator {
  internal var options: GeneratorOptions
  private var printer: CodePrinter

  internal var file: FileDescriptor
  internal var service: ServiceDescriptor! // context during generation
  internal var method: MethodDescriptor! // context during generation

  internal let protobufNamer: SwiftProtobufNamer

  init(_ file: FileDescriptor, options: GeneratorOptions) {
    self.file = file
    self.options = options
    self.printer = CodePrinter()
    self.protobufNamer = SwiftProtobufNamer(
      currentFile: file,
      protoFileToModuleMappings: options.protoToModuleMappings
    )
    self.printMain()
  }

  public var code: String {
    return self.printer.content
  }

  internal func println(_ text: String = "", newline: Bool = true) {
    self.printer.print(text)
    if newline {
      self.printer.print("\n")
    }
  }

  internal func indent() {
    self.printer.indent()
  }

  internal func outdent() {
    self.printer.outdent()
  }

  internal func withIndentation(body: () -> Void) {
    self.indent()
    body()
    self.outdent()
  }

  private func printMain() {
    self.printer.print("""
    //
    // DO NOT EDIT.
    //
    // Generated by the protocol buffer compiler.
    // Source: \(self.file.name)
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
    //\n
    """)

    let moduleNames = [
      self.options.gRPCModuleName,
      "NIO",
    ]

    for moduleName in (moduleNames + self.options.extraModuleImports).sorted() {
      self.println("import \(moduleName)")
    }
    // Add imports for required modules
    let moduleMappings = self.options.protoToModuleMappings
    for importedProtoModuleName in moduleMappings.neededModules(forFile: self.file) ?? [] {
      self.println("import \(importedProtoModuleName)")
    }
    self.println()

    // We defer the check for printing clients to `printClient()` since this could be the 'real'
    // client or the test client.
    for service in self.file.services {
      self.service = service
      self.printClient()
    }
    self.println()

    if self.options.generateServer {
      for service in self.file.services {
        self.service = service
        printServer()
      }
    }
  }
}
