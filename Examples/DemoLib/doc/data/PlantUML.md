# Plant UML Diagrams

Plant UML diagrams are really cool, if sometimes a pain to initially write. This is configured to allow for automatic parsing of your UML diagrams, either inlined directly in the code comments, or in separate user documentation:

@startuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: Another authentication Response
@enduml


The above was created using the following snippet:
```
@startuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: Another authentication Response
@enduml
```