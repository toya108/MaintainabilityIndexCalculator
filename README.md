# MaintainabilityIndexCalculator

MaintainabilityIndexCalculator is a SwiftPM command line tool for measuring MaintainabilityIndex in swift.

## Emvironment

- Xcode: 13.4.1
- swift: 5.6
- Mac: M1

## How to use

Please run below command on root of project.

```
swift run MaintainabilityIndexCalculator { path of swift file }
```

Example

```
swift run MaintainabilityIndexCalculator Sources/MaintainabilityIndexCalculator/main.swift

------------------------------------------------------------
source: Sources/MaintainabilityIndexCalculator/main.swift
halstead_volume: 3344.9685
cyclomatic_complexity: 12
line_of_code: 102
maitainability_index: 29.892593641638783
------------------------------------------------------------
```
