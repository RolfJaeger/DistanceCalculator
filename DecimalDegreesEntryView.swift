//
//  DecimalDegreesEntryView_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/16/26.
//

import SwiftUI
import CoreLocation

struct DecimalDegreesEntryView: View {
    
    @ObservedObject var locObj: LocationObject
    
    @Binding var showView: Bool
    
    @State private var showDialog = false

    @State private var plusMinusTarget: DecimalDegrees_PlusMinusTarget = .TENTHOUSANDTH

    @State private var degrees: Int = 90
    @State private var decimalDegrees: Double = -179.001
    @State private var minutesForRaymarineView: Int = 59
    @State private var minutesForDMSView: Int = 59
    
    @State private var minutesInDecimalFormat:Double = 59.000
    @State private var degreeTenth: Int = 0
    @State private var degreeHundredth: Int = 0
    @State private var degreeThousandth: Int = 0
    @State private var degreeTenThousandth: Int = 0

    @State private var showDegreesPicker = false
    @State private var showTenthPicker = false
    @State private var showHundredthPicker = false
    @State private var showThousandthPicker = false
    @State private var showTenThousandthPicker = false
    
    @State private var isDegreesEditable = false
    @State private var isTenthEditable = false
    @State private var isHundredthEditable = false
    @State private var isThousandthEditable = false
    @State private var isTenThousandthEditable = true

    var locIndex: Int = 0
    
    init(locObj: LocationObject, locIndex: Int, showView: Binding<Bool>) {
        self.locObj = locObj
        self.locIndex = locIndex
        _showView = showView
        initializeDegreeValues()
    }
    
    fileprivate mutating func initializeDegreeValues() {
        var locDegrees: Double
        if locObj.latLong == .Latitude {
            locDegrees = locObj.locations[locIndex].coordinate.latitude
        } else {
            locDegrees = locObj.locations[locIndex].coordinate.longitude
        }
        if locObj.hemisphere == "S" || locObj.hemisphere == "W" {
            _degrees = State(initialValue: -Int(locDegrees))
            _decimalDegrees = State(initialValue: -Double(locDegrees))
        } else {
            _degrees = State(initialValue: Int(locDegrees))
            _decimalDegrees = State(initialValue: Double(locDegrees))
        }
        let fractionalDegrees = decimalDegrees - Double(degrees)
        let decimalMinutes = fractionalDegrees * 60
        _minutesInDecimalFormat = State(initialValue: Double(decimalMinutes))
        _minutesForDMSView = State(initialValue: Int(decimalMinutes.rounded(toPlaces: 3)))
        _minutesForRaymarineView = State(initialValue: Int(decimalMinutes.rounded(toPlaces: 3)))
        let decimalSeconds = Int(((minutesInDecimalFormat - Double(minutesForRaymarineView))*60).rounded())
        
        if let tryTenth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 1)) {
            _degreeTenth = State(initialValue: Int(tryTenth))
        }
        if let tryHundredth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 2)) {
            _degreeHundredth = State(initialValue: Int(tryHundredth))
        }
        if let tryThousandth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 3)) {
            _degreeThousandth = State(initialValue: Int(tryThousandth))
        }
        
        if let tryTenThousandth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 4)) {
            _degreeTenThousandth = State(initialValue: Int(tryTenThousandth))
        }
    }
    
    var body: some View {
        ZStack {
            if showDialog {
                UserDialog
            } else {
                VStack {
                    TitleBar
                    SwitchHemisphereButton
                    HStack {
                        DetailsView
                        PlusMinus
                    }
                    .font(isPad ? .system(size: 50.0) : .title3)
                    Instructions
                        .padding(.bottom,10)
                }
                .border(.primary, width: 2.0)
                .padding()
            }
        }
    }
    
    fileprivate var TitleBar: some View {
        HStack {
            Text("Location \(locIndex + 1)")
                .bold()
                .padding(.leading, 20)
            if locObj.latLong == .Latitude {
                Text(" - Latitude")
            } else {
                Text(" - Longitude")
            }
            Spacer()
            Button(action: {
                showView = false
            }, label: {
                Text("x")
            })
            .buttonStyle(.bordered)
            .padding(.trailing,10)
        }
        .font(isPad ? .system(size: 25.0) : .title3)
        .padding(.top, 10)
        .padding(.top, 10)
    }
    
    fileprivate var SwitchHemisphereButton: some View {
        VStack {
            Button(action: {
                showDialog = true
            }, label: {
                Text("Switch Hemisphere")
            })
            .buttonStyle(.bordered)
            .padding()
        }
        .font(isPad ? .system(size: 20.0) : .body)
    }
    
    fileprivate var Instructions: some View {
        VStack {
            Text("Tap and scroll")
            HStack {
                Text("or tap the")
                Image(systemName: "plus.square")
                Text("or the")
                Image(systemName: "minus.square")
                Text("button.")
            }
        }
        .font(isPad ? .system(size: 20.0) : .footnote)
    }
    
    fileprivate var DetailsView: some View {
        VStack {
            HStack {
                Text(locObj.hemisphere)
                if !showDegreesPicker {
                    Text("\(Int(decimalDegrees))")
                        .onTapGesture {
                            togglePickerVisibility(.Degrees)
                            plusMinusTarget = .DEGREES
                        }
                } else {
                    Picker("", selection: $degrees) {
                        ForEach(0...locObj.maxDegrees, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 50.0) : .title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(1.0)
                    .frame(width: 100, height: 100)
                    .onChange(of: degrees) {
                        updateDegreesValue()
                    }
                }
                
                Text(".")
                
                if !showTenthPicker {
                    Text("\(degreeTenth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Tenth)
                            plusMinusTarget = .TENTH
                        }
                } else {
                    Picker("", selection: $degreeTenth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 50.0) : .title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(1.0)
                    .frame(width: 50, height: 100)
                    .onAppear {
                        degreeTenth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 1))!
                    }
                    .onChange(of: degreeTenth) {
                        updateDegreesValueDecimalDegreesFormat()
                    }
                }
                
                if !showHundredthPicker {
                    Text("\(degreeHundredth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Hundredth)
                            plusMinusTarget = .HUNDREDTH
                        }
                } else {
                    Picker("", selection: $degreeHundredth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 50.0) : .title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(1.0)
                    .frame(width: 50, height: 100)
                    .onAppear {
                        degreeHundredth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 2))!
                    }
                    .onChange(of: degreeHundredth) {
                        updateDegreesValueDecimalDegreesFormat()
                    }
                }
                
                if !showThousandthPicker {
                    Text("\(degreeThousandth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Thousandth)
                            plusMinusTarget = .THOUSANDTH
                        }
                } else {
                    Picker("", selection: $degreeThousandth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 50.0) : .title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(1.0)
                    .frame(width: 50, height: 90)
                    .onAppear {
                        degreeThousandth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 3))!
                    }
                    .onChange(of: degreeThousandth) {
                        updateDegreesValueDecimalDegreesFormat()
                    }
                }
                
                if !showTenThousandthPicker {
                    Text("\(degreeTenThousandth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.TenThousandth)
                            plusMinusTarget = .TENTHOUSANDTH
                        }
                } else {
                    Picker("", selection: $degreeTenThousandth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 50.0) : .title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(1.0)
                    .frame(width: 50, height: 90)
                    .onAppear {
                        degreeTenThousandth = Int(extractDigitAtSpecifiedLocationAfterPeriod(degrees: decimalDegrees, position: 4))!
                    }
                    .onChange(of: degreeTenThousandth) {
                        updateDegreesValueDecimalDegreesFormat()
                    }
                }
                
                Text("°")
                
            }
            .padding(.top, 0)
            .padding(.bottom,5)
        }
    }
    
    fileprivate var UserDialog: some View {
        VStack {
            Text("Are you sure you want to switch hemisphere ?")
                .font(.title)
                .foregroundColor(.black)
                .bold()
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Button(action: {
                    showDialog = false
                    locObj.switchHemisphere(locIndex: locIndex)
                }) {
                    Text("Yes")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    // NO action
                    showDialog = false
                }) {
                    Text("No")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .bold()
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)

    }

    fileprivate func SwitchEdibility(target: DecimalDegrees_PlusMinusTarget) {
        
        togglePickerVisibility()
        
        isDegreesEditable = false
        isTenthEditable = false
        isHundredthEditable = false
        isThousandthEditable = false
        isTenThousandthEditable = false
        
        switch target {
        case .DEGREES:
            isDegreesEditable = true
        case .TENTH:
            isTenthEditable = true
        case .HUNDREDTH:
            isHundredthEditable = true
        case .THOUSANDTH:
            isThousandthEditable = true
        case .TENTHOUSANDTH:
            isTenThousandthEditable = true
        }
    }
    
    fileprivate func toggleViewOfSelectedPicker(_ pickerName: DecimalDegrees_PickerName, hideAll: Bool) {
        
        showDegreesPicker = false
        showTenthPicker = false
        showHundredthPicker = false
        showThousandthPicker = false
        showTenThousandthPicker = false
        
        if !hideAll {
            switch pickerName {
            case .Degrees:
                showDegreesPicker.toggle()
            case .Tenth:
                showTenthPicker.toggle()
            case .Hundredth:
                showHundredthPicker.toggle()
            case .Thousandth:
                showThousandthPicker.toggle()
            case .TenThousandth:
                showTenThousandthPicker.toggle()
            }
        }
    }
    
    fileprivate func togglePickerVisibility(_ selectedPicker: DecimalDegrees_PickerName? = nil) {
        
        showDegreesPicker = false
        showTenthPicker = false
        showHundredthPicker = false
        showThousandthPicker = false
        showTenThousandthPicker = false
        
        if selectedPicker != nil {
            switch selectedPicker {
            case .Degrees:
                showDegreesPicker.toggle()
            case .Tenth:
                showTenthPicker.toggle()
            case .Hundredth:
                showHundredthPicker.toggle()
            case .Thousandth:
                showThousandthPicker.toggle()
            case .TenThousandth:
                showTenThousandthPicker.toggle()
            default:
                _ = true
            }
        }
    }
    fileprivate var PlusMinus: some View {
        HStack {
            Button(action: {
                IncreaseValue()
            }, label: {
                Image(systemName: "plus.square")
            })
            //.buttonStyle(.bordered)
            Button(action: {
                DecreaseValue()
            }, label: {
                Image(systemName: "minus.square")
            })
            //.buttonStyle(.bordered)
        }
    }
    
    fileprivate func updateDegreesValue() {
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutesForRaymarineView)
        var newDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
        decimalDegrees = newDegrees
        if locObj.hemisphere == "S" || locObj.hemisphere == "W" {
            newDegrees = -newDegrees
        }
        if locObj.latLong == .Latitude {
            locObj.locations[locIndex].coordinate.latitude = newDegrees
        } else {
            locObj.locations[locIndex].coordinate.longitude = newDegrees
        }
        locObj.updateLocations(loc1: locObj.locations[0], loc2: locObj.locations[1])
    }
    
    fileprivate func updateDegreesValueDecimalDegreesFormat() {
        let degrees = Int(decimalDegrees)
        let strDecimalDegrees = String(degrees) + "." + String(degreeTenth) + String(degreeHundredth) + String(degreeThousandth) +
            String(degreeTenThousandth)
        if let newDegrees = Double(strDecimalDegrees) {
            var modDegrees = newDegrees
            if locObj.hemisphere == "S" ||  locObj.hemisphere == "W" {
                modDegrees = -modDegrees
            }
            if locObj.latLong == .Latitude {
                locObj.locations[locIndex].coordinate.latitude = modDegrees
            } else {
                locObj.locations[locIndex].coordinate.longitude = modDegrees
            }
            decimalDegrees = newDegrees
            locObj.updateLocations(loc1: locObj.locations[0], loc2: locObj.locations[1])
        }
    }
    
    fileprivate func CalcMinutesAndSecondsFromDecimalDegrees(degrees: Double) {
        let intDegrees = Int(degrees)
        let fractionalMinutes = (degrees - Double(intDegrees)) * 60
        let intMinutes = Int(fractionalMinutes)
        minutesForRaymarineView = intMinutes
        let dblSeconds = (fractionalMinutes - Double(intMinutes)) * 60
        let intSeconds = Int(dblSeconds)
        //seconds = intSeconds
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutesForRaymarineView)
    }
    
    fileprivate func CalculateDecimalDegrees(degrees: Int, decimalMinutes: Double) -> CLLocationDegrees {
        var decimalDegrees: Double
        decimalDegrees = Double(degrees) + decimalMinutes/60
        return CLLocationDegrees(decimalDegrees)
    }
    
    fileprivate func CalculateIntSecondsFromDecimalMinutes(minutesInDecimalFormat: Double) -> Int {
        
        let intMinute = Int(minutesInDecimalFormat)
        let seconds = (minutesInDecimalFormat - Double(intMinute)) * 60
        return Int(seconds)
    }
    
    fileprivate func CalculateDecimalMinutesFromMinutesAndSeconds(minutes: Int) -> Double {
        let totalSeconds = minutes * 60
        return Double(totalSeconds)/60.0
    }
    
    fileprivate func IncreaseValue() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < locObj.maxDegrees - 1 {
                decimalDegrees += 1
            }
        case .TENTH:
            if degreeTenth  < 9 {
                degreeTenth += 1
            }
        case .HUNDREDTH:
            if degreeHundredth < 9 {
                degreeHundredth += 1
            }
        case .THOUSANDTH:
            if degreeThousandth < 9 {
                degreeThousandth += 1
            }
        case .TENTHOUSANDTH:
            if degreeTenThousandth < 9 {
                degreeTenThousandth += 1
            }
            else {
                let fractionalMinute = Int(String("\(degreeTenth)\(degreeHundredth)\(degreeThousandth)\(degreeTenThousandth)"))
                if fractionalMinute == 9999 {
                    if Int(decimalDegrees.rounded()) < locObj.maxDegrees {
                        decimalDegrees += 1
                    }
                    degreeTenth = 0
                    degreeHundredth = 0
                    degreeThousandth = 0
                    degreeTenThousandth = 0
                } else {
                    if degreeThousandth < 9 {
                        degreeThousandth += 1
                        degreeTenThousandth = 0
                    }
                    else {
                        if degreeHundredth < 9 {
                            degreeHundredth += 1
                            degreeThousandth = 0
                            degreeTenThousandth = 0
                        } else {
                            if degreeTenth < 9 {
                                degreeTenth += 1
                                degreeHundredth = 0
                                degreeThousandth = 0
                                degreeTenThousandth = 0
                            } else {
                                if Int(decimalDegrees.rounded()) < locObj.maxDegrees - 1 {
                                    decimalDegrees += 1
                                    degreeTenth = 0
                                    degreeHundredth = 0
                                    degreeThousandth = 0
                                    degreeTenThousandth = 0
                                }
                            }
                        }
                    }
                }
            }
        }
        updateDegreesValueDecimalDegreesFormat()
    }
    
    fileprivate func DecreaseValue() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 {
                decimalDegrees -= 1
                
            }
        case .TENTH:
            if degreeTenth  > 0 {
                degreeTenth -= 1
            }
        case .HUNDREDTH:
            if degreeHundredth > 0 {
                degreeHundredth -= 1
            }
        case .THOUSANDTH:
            if degreeThousandth > 0 {
                degreeThousandth -= 1
            }
        case .TENTHOUSANDTH:
            if degreeTenThousandth > 0 {
                degreeTenThousandth -= 1
            } else {
                if degreeThousandth > 0 {
                    degreeThousandth -= 1
                    degreeTenThousandth = 9
                } else {
                    if degreeHundredth > 0 {
                        degreeHundredth -= 1
                        degreeThousandth = 9
                        degreeTenThousandth = 9
                    } else {
                        if degreeTenth > 0 {
                            degreeTenth -= 1
                            degreeHundredth = 9
                            degreeThousandth = 9
                            degreeTenThousandth = 9
                        } else {
                            if degrees > 0 {
                                decimalDegrees -= 1
                                degreeTenth = 9
                                degreeHundredth = 9
                                degreeThousandth = 9
                                degreeTenThousandth = 9
                            }
                        }
                    }
                }
                    
            }
        }
        updateDegreesValueDecimalDegreesFormat()
    }

}

#Preview {
    @Previewable @State var showView = true
    let locObj = LocationObject()
    DecimalDegreesEntryView(locObj: locObj, locIndex: 0, showView: $showView)
}
