//
//  ContentView.swift
//  Challenge1
//
//  Created by Edward Fitz Abucay on 9/18/24.
//

import SwiftUI

struct ContentView: View {
    @State private var inputUnit: UnitLength = .meters
    @State private var outputUnit: UnitLength = .kilometers
    @State private var inputValue: Double = 0.0
    
    var outputValue: String {
        let input = Measurement<UnitLength>(value: inputValue, unit: inputUnit)
        let output = input.converted(to: outputUnit)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter.string(from: output)
    }
    let units: [UnitLength] = [.meters, .kilometers, .feet, .yards, .miles]
    var body: some View {
        NavigationStack {
            Form {
                Section("From Unit") {
                    TextField("Value", value: $inputValue, format: .number)
                    Picker("Input", selection: $inputUnit) {
                        ForEach(units, id: \.self) {
                            Text($0.symbol)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("To Unit") {
                    Picker("Output", selection: $outputUnit) {
                        ForEach(units, id: \.self) {
                            Text($0.symbol)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(outputValue)
                }
            }
            .navigationTitle("Length Unit Converter")
        }
    }
}

#Preview {
    ContentView()
}
