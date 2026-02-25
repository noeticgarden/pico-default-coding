# DefaultCoding

The DefaultCoding module adds a few utilities to `Codable` types to let them specify a default format in which they would like to be encoded or decoded.

The main type in this package is the `DefaultCodable` protocol set. For example, the conformance here:

```swift
struct Greetings: Codable, DefaultCodable {
	var contents: [Greeting]
	struct Greeting: Codable {
		var text: String
		var language: String
	}
}
```

immediately inherits from the `DefaultCodable` protocol the ability to load and save its contents from and to disk:

```swift
var greetings = try Greetings(contentsOf: greetingsURL)
greetings.contents.append(
	.init(text: "Bonjour!", language: "French")
)
try greetings.encoded().write(to: greetingsURL)
```

The default format is JSON, with some default flags to ensure readability and some stability of the file format (for example, the `.prettyPrinted` and `.sortedKeys` options are enabled.)

The package only depends on `FoundationEssentials` where available.

