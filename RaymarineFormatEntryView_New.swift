//
//  RaymarineFormatEntryView_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/17/26.
//

import SwiftUI
import CoreLocation

/*
This view supports the format:
 # Raymarine Format (DDD-MM.mmm), e.g. 37°23.367°
*/

struct RaymarineFormatEntryView_New: View {
 
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @ObservedObject var locObj: LocationObject
    @Binding var showView: Bool
    @State private var showDialog = false

    @State private var plusMinusTarget:  Raymarine_PlusMinusTarget = .THOUSANDTH

    @State private var path = NavigationPath()
    
    @State private var degrees: Int = -180
    @State private var decimalDegrees: Double = -179.001
    @State private var minutesForRaymarineView: Int = 59
    
    @State private var minutesInDecimalFormat:Double = 59.000
    @State private var degreeTenth: Int = 0
    @State private var degreeHundredth: Int = 0
    @State private var degreeThousandth: Int = 0

    @State private var minuteTenth: Int = 0
    @State private var minuteHundredth: Int = 0
    @State private var minuteThousandth: Int = 0
    
    //@State private var seconds: Int = 45
    
    @State private var showDecimal = false
    @State private var showDegreesMinSec = false
    
    @State private var showDegreesPicker = false
    @State private var showMinutesPicker = false
    @State private var showTenthPicker = false
    @State private var showHundredthPicker = false
    @State private var showThousandthPicker = false
    
    @State private var isDegreesEditable = false
    @State private var isMinutesEditable = false
    @State private var isTenthEditable = false
    @State private var isHundredthEditable = false
    @State private var isThousandthEditable = false
    
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
        _minutesForRaymarineView = State(initialValue: Int(decimalMinutes.rounded(toPlaces: 3)))
        let decimalSeconds = Int(((minutesInDecimalFormat - Double(minutesForRaymarineView))*60).rounded())
        
        if let tryTenth = Int(extractTenth(degrees: decimalDegrees)) {
            _degreeTenth = State(initialValue: Int(tryTenth))
        }
        if let tryHundredth = Int(extractHundredth(degrees: decimalDegrees)) {
            _degreeHundredth = State(initialValue: Int(tryHundredth))
        }
        if let tryThousandth = Int(extractThousandth(degrees: decimalDegrees)) {
            _degreeThousandth = State(initialValue: Int(tryThousandth))
        }
                
        if let tryTenth = Int(extractTenth(degrees: minutesInDecimalFormat)) {
            _minuteTenth = State(initialValue: Int(tryTenth))
        }
        if let tryHundredth = Int(extractHundredth(degrees: minutesInDecimalFormat)) {
            _minuteHundredth = State(initialValue: Int(tryHundredth))
        }
        if let tryThousandth = Int(extractThousandth(degrees: minutesInDecimalFormat)) {
            _minuteThousandth = State(initialValue: Int(tryThousandth))
        }
    }

    var body: some View {
        VStack {
            MainView
        }
        .ignoresSafeArea(.keyboard)
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
        .font(isPad ? .system(size: 25.0) : .body)
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
    
    fileprivate var Instructions_iPad: some View {
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
        .font(Font.system(size: hintFont, weight: .regular, design: .default))
    }

    fileprivate func SwitchEdibility(target: Raymarine_PlusMinusTarget) {
        
        togglePickerVisibility()
        
        isDegreesEditable = false
        isMinutesEditable = false
        isTenthEditable = false
        isHundredthEditable = false
        isThousandthEditable = false
        
        switch target {
        case .DEGREES:
            isDegreesEditable = true
        case .MINUTES:
            isMinutesEditable = true
        case .TENTH:
            isTenthEditable = true
        case .HUNDREDTH:
            isHundredthEditable = true
        case .THOUSANDTH:
            isThousandthEditable = true
        }
    }
    
    fileprivate func toggleViewOfSelectedPicker(_ pickerName: Raymarine_PickerName, hideAll: Bool) {
        
        showDegreesPicker = false
        showMinutesPicker = false
        showTenthPicker = false
        showHundredthPicker = false
        showThousandthPicker = false
        
        if !hideAll {
            switch pickerName {
            case .Degrees:
                showDegreesPicker.toggle()
            case .Minutes:
                showMinutesPicker.toggle()
            case .Tenth:
                showTenthPicker.toggle()
            case .Hundredth:
                showHundredthPicker.toggle()
            case .Thousandth:
                showThousandthPicker.toggle()
            }
        }
    }
    
    fileprivate func togglePickerVisibility(_ selectedPicker: Raymarine_PickerName? = nil) {
        showDegreesPicker = false
        showMinutesPicker = false
        showTenthPicker = false
        showHundredthPicker = false
        showThousandthPicker = false
        if selectedPicker != nil {
            switch selectedPicker {
            case .Degrees:
                showDegreesPicker.toggle()
            case .Minutes:
                showMinutesPicker.toggle()
            case .Tenth:
                showTenthPicker.toggle()
            case .Hundredth:
                showHundredthPicker.toggle()
            case .Thousandth:
                showThousandthPicker.toggle()
            default:
                _ = true
            }
        }
    }
    
    fileprivate var MainView: some View {
        ZStack {
            if showDialog {
                UserDialog
            } else {
                VStack {
                    if sizeClass == .regular {
                        TitleBar
                        SwitchHemisphereButton
                        HStack {
                            DetailsView_iPad
                            PlusMinus_iPad
                        }
                        .font(isPad ? .system(size: 50.0) : .title2)
                    } else {
                        TitleBar
                        SwitchHemisphereButton
                        HStack {
                            DetailsView
                            PlusMinus
                        }
                        .font(Font.system(size: 25, weight: .regular, design: .default))
                    }
                    Instructions
                        .padding(.bottom,10)
                }
                .border(.primary, width: 2.0)
                .padding()
            }
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
    

    fileprivate var DetailsView: some View {
        HStack {
            Text(locObj.hemisphere)
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        togglePickerVisibility(.Degrees)
                        plusMinusTarget = .DEGREES
                    }
            } else {
                Picker("", selection: $degrees) {
                    ForEach(0...locObj.maxDegrees, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 25, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 100, height: 100)
                .onChange(of: degrees) {
                    updateDegreesValueForRaymarineFormat()
                }
            }
            
            Text("\u{00B0}")
            
            if !showMinutesPicker {
                Text("\(minutesForRaymarineView)")
                    .padding(.leading,10)
                    .onTapGesture {
                        togglePickerVisibility(.Minutes)
                        plusMinusTarget = .MINUTES
                    }
            } else {
                Picker("", selection: $minutesForRaymarineView) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 25, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 70, height: 100)
                .onChange(of: minutesForRaymarineView) {
                    updateDegreesValueForRaymarineFormat()
                }
                
            }
            Text(".")
            
            if !showTenthPicker {
                Text("\(minuteTenth)")
                    .onTapGesture {
                        togglePickerVisibility(.Tenth)
                        plusMinusTarget = .TENTH
                    }
            } else {
                Picker("", selection: $minuteTenth) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 25, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 40, height: 100)
                .onChange(of: minuteTenth) {
                    updateDegreesValueForRaymarineFormat()
                }
            }
            
            if !showHundredthPicker {
                Text("\(minuteHundredth)")
                    .padding(.leading,-5)
                    .onTapGesture {
                        togglePickerVisibility(.Hundredth)
                        plusMinusTarget = .HUNDREDTH
                    }
            } else {
                Picker("", selection: $minuteHundredth) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 25, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 40, height: 100)
                .onChange(of: minuteHundredth) {
                    updateDegreesValueForRaymarineFormat()
                }
            }
            
            if !showThousandthPicker {
                Text("\(minuteThousandth)")
                    .padding(.leading,-5)
                    .onTapGesture {
                        togglePickerVisibility(.Thousandth)
                        plusMinusTarget = .THOUSANDTH
                    }
            } else {
                Picker("", selection: $minuteThousandth) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 25, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 40, height: 100)
                .onChange(of: minuteThousandth) {
                    updateDegreesValueForRaymarineFormat()
                }
            }
            Text("'")
        }
    }
    
    fileprivate var DetailsView_iPad: some View {
        HStack {
            Text(locObj.hemisphere)
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        togglePickerVisibility(.Degrees)
                        plusMinusTarget = .DEGREES
                    }
            } else {
                VStack {
                    Picker("", selection: $degrees) {
                        ForEach(0...locObj.maxDegrees, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 25.0) : .title2)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.top, 35)
                    .scaleEffect(2.0)
                    .frame(width: 120, height: 100)
                    .onChange(of: degrees) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                }
            }
            
            Text("\u{00B0}")

            if !showMinutesPicker {
                Text("\(minutesForRaymarineView)")
                    .padding(.leading,10)
                    .onTapGesture {
                        togglePickerVisibility(.Minutes)
                        plusMinusTarget = .MINUTES
                    }
            } else {
                VStack {
                    Picker("", selection: $minutesForRaymarineView) {
                        ForEach(0...59, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 25.0) : .title2)
                                .frame(width: 30, height: 100)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.top, 35)
                    .scaleEffect(2.0)
                    .frame(width: 30, height: 100)
                    .onChange(of: minutesForRaymarineView) {
                        updateDegreesValueForRaymarineFormat()
                    }
                }
            }
            
            Text(".")
            if !showTenthPicker {
                Text("\(minuteTenth)")
                    .onTapGesture {
                        togglePickerVisibility(.Tenth)
                        plusMinusTarget = .TENTH
                    }
            } else {
                VStack {
                    Picker("", selection: $minuteTenth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(isPad ? .system(size: 25.0) : .title2)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.top, 35)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onChange(of: minuteTenth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                }
            }
            
            if !showHundredthPicker {
                Text("\(minuteHundredth)")
                    .padding(.leading,-5)
                    .onTapGesture {
                        togglePickerVisibility(.Hundredth)
                        plusMinusTarget = .HUNDREDTH
                    }
            } else {
                VStack {
                    Picker("", selection: $minuteHundredth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 25.0, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.top, 35)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onChange(of: minuteHundredth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                }
            }
            
            if !showThousandthPicker {
                Text("\(minuteThousandth)")
                    .padding(.leading,-5)
                    .onTapGesture {
                        togglePickerVisibility(.Thousandth)
                        plusMinusTarget = .THOUSANDTH
                    }
            } else {
                VStack {
                    Picker("", selection: $minuteThousandth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 25.0, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.top, 25)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onChange(of: minuteThousandth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            Text("'")

        }
        .padding(.top, 0)
        .padding(.bottom,5)
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
    
    fileprivate var PlusMinus_iPad: some View {
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
    
    fileprivate func updateDegreesValueForRaymarineFormat() {
        let strDecimalMinutes = String(minutesForRaymarineView) + "." + String(minuteTenth) + String(minuteHundredth) + String(minuteThousandth)
        if let test = Double(strDecimalMinutes) {
            minutesInDecimalFormat = test
            var newDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
            locObj.updateLocation(newDegrees: newDegrees, locIndex: locIndex)
        }
    }
    
    fileprivate func CalculateDecimalDegrees(degrees: Int, decimalMinutes: Double) -> CLLocationDegrees {
        var decimalDegrees: Double
        decimalDegrees = Double(degrees) + decimalMinutes/60
        return CLLocationDegrees(decimalDegrees)
    }
    
    fileprivate func IncreaseValue() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < locObj.maxDegrees - 1 { degrees += 1 }
        case .MINUTES:
            if minutesForRaymarineView < 59 { minutesForRaymarineView += 1 }
        case .TENTH:
            if minuteTenth < 9 { minuteTenth += 1 }
        case .HUNDREDTH:
            if minuteHundredth < 9 { minuteHundredth += 1 }
        case .THOUSANDTH:
            if minuteThousandth < 9 {
                minuteThousandth += 1
            }
            else {
                let fractionalMinute = Int(String("\(minuteTenth)\(minuteHundredth)\(minuteThousandth)"))
                if fractionalMinute == 999 {
                    if minutesForRaymarineView < 59 {
                        minutesForRaymarineView += 1
                        minutesInDecimalFormat += 1
                    } else {
                        if degrees < locObj.maxDegrees - 1 {
                            degrees += 1
                            minutesForRaymarineView = 0
                            minutesInDecimalFormat = 0.0
                        }
                    }
                    minuteThousandth = 0
                    minuteHundredth = 0
                    minuteTenth = 0
                } else {
                    if minuteHundredth < 9 {
                        minuteHundredth += 1
                        minuteThousandth = 0
                    } else {
                        if minuteTenth < 9 {
                            minuteTenth += 1
                            minuteHundredth = 0
                        } else {
                            if minutesForRaymarineView < 59 {
                                minutesForRaymarineView += 1
                                minutesInDecimalFormat += 1
                                minuteTenth = 0
                            } else {
                                if degrees < locObj.maxDegrees - 1 {
                                    degrees += 1
                                    minutesInDecimalFormat = 0.0
                                    minuteTenth = 0
                                    minuteHundredth = 0
                                    minuteThousandth = 0
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
        updateDegreesValueForRaymarineFormat()
    }
    
    fileprivate func DecreaseValue() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 { degrees -= 1 }
        case .MINUTES:
            if minutesForRaymarineView > 0 { minutesForRaymarineView -= 1 }
        case .TENTH:
            if minuteTenth > 0 { minuteTenth -= 1 }
        case .HUNDREDTH:
            if minuteHundredth > 0 { minuteHundredth -= 1 }
        case .THOUSANDTH:
            if minuteThousandth > 0 { minuteThousandth -= 1 }
            else {
                if minuteHundredth > 0 {
                    minuteHundredth -= 1
                    minuteThousandth = 9
                } else {
                    if minuteTenth > 0 {
                        minuteTenth -= 1
                        minuteHundredth = 9
                        minuteThousandth = 9
                    } else {
                        if minutesForRaymarineView > 0 {
                            minutesForRaymarineView -= 1
                            minuteTenth = 9
                            minuteHundredth = 9
                            minuteThousandth = 9
                        } else {
                            if degrees > 0 {
                                degrees -= 1
                                minutesForRaymarineView = 59
                                minuteTenth = 9
                                minuteHundredth = 9
                                minuteThousandth = 9
                            }
                        }
                    }
                }
                
            }
        }
        updateDegreesValueForRaymarineFormat()
    }
    
    fileprivate func extractTenth(degrees: CLLocationDegrees) -> String {
        //print("Degrees in extractTenth: \(String(degrees))")
        let degreesRounded = Double(degrees).rounded(toPlaces: 3)
        let strDegrees = String(degreesRounded)
        let periodIndex = strDegrees.firstIndex(of: ".")
        //NOTE: CLLocationsDegrees values ALWAYS contain a period
        if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 1 {
            let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
            let tensIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 1, limitedBy: strDegrees.endIndex)
            return String(strDegrees[tensIndex!])
        } else {
            return "0"
        }
    }

    fileprivate func extractHundredth(degrees: CLLocationDegrees) -> String {
        let degreesRounded = Double(degrees).rounded(toPlaces: 3)
        let strDegrees = String(degreesRounded)
        let periodIndex = strDegrees.firstIndex(of: ".")
        //NOTE: CLLocationsDegrees values ALWAYS contain a period
        if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 2 {
            let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
            let hundredsIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 2, limitedBy: strDegrees.endIndex)
            return String(strDegrees[hundredsIndex!])
        } else {
            return "0"
        }
    }

    fileprivate func extractThousandth(degrees: CLLocationDegrees) -> String {
        let degreesRounded = Double(degrees).rounded(toPlaces: 3)
        let strDegrees = String(degreesRounded)
        let periodIndex = strDegrees.firstIndex(of: ".")
        //NOTE: CLLocationsDegrees values ALWAYS contain a period
        if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 3 {
            let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
            let thousandsIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 3, limitedBy: strDegrees.endIndex)
            return String(strDegrees[thousandsIndex!])
        } else {
            return "0"
        }
    }

}

#Preview {
    @Previewable @State var showView = true
    let locObj = LocationObject()
    RaymarineFormatEntryView_New(locObj: locObj, locIndex: 0, showView: $showView)
}
