//
//  DMSEntryView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/14/26.
//

import SwiftUI
import CoreLocation

/*
This view supports the format:
 # DMS: Degrees, Minutes, Seconds, e.g. 37° 23′ 22″
 */

struct DMSEntryView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var orientation: String
    var maxDegrees: Int
    
    @Binding var locDegrees: CLLocationDegrees
    @Binding var viewFormat: ViewFormat
    
    @State private var plusMinusTarget: PlusMinusTarget = .SECONDS

    @State private var path = NavigationPath()
    
    @State var cllDegrees: CLLocationDegrees
    @State private var degrees: Int = -180
    @State private var decimalDegrees: Double = -179.001
    @State private var minutesForRaymarineView: Int = 59
    @State private var minutesForDMSView: Int = 59
    
    @State private var minutesInDecimalFormat:Double = 59.000
    @State private var degreeTenth: Int = 0
    @State private var degreeHundredth: Int = 0
    @State private var degreeThousandth: Int = 0
    @State private var degreeTenThousandth: Int = 0

    @State private var minuteTenth: Int = 0
    @State private var minuteHundredth: Int = 0
    @State private var minuteThousandth: Int = 0
    
    @State private var seconds: Int = 45
    
    @State private var showDecimal = false
    @State private var showDegreesMinSec = false
    
    @State private var showDegreesPicker = false
    @State private var showMinutesPicker = false
    @State private var showSecondsPicker = false
    @State private var showTenthPicker = false
    @State private var showHundredthPicker = false
    @State private var showThousandthPicker = false
    @State private var showTenThousandthPicker = false
    
    @State private var isDegreesEditable = false
    @State private var isMinutesEditable = false
    @State private var isSecondsEditable = false
    @State private var isTenthEditable = false
    @State private var isHundredthEditable = false
    @State private var isThousandthEditable = false
    @State private var isTenThousandthEditable = true
    
    @FocusState private var isDecimalDegreesFieldFocused: Bool
    @FocusState private var isDegreesFieldFocused: Bool
    @FocusState private var isDecimalMinutesFieldFocused: Bool
    @FocusState private var isMinutesFieldFocused: Bool
    @FocusState private var isSecondsFieldFocused: Bool
    
    init(orientation: String, locDegrees: Binding<CLLocationDegrees>, viewFormat: Binding<ViewFormat>) {
        self.orientation = orientation
        if orientation == "N" || orientation == "S" {
            maxDegrees = 90
        } else {
            maxDegrees = 180
        }
        
        
        _locDegrees = locDegrees // Initialize the @Binding
        _cllDegrees =  State(initialValue: locDegrees.wrappedValue)
        _degrees = State(initialValue: Int(locDegrees.wrappedValue))
        _decimalDegrees = State(initialValue: Double(locDegrees.wrappedValue))
        _viewFormat = viewFormat
        initializeDegreeValues()
    }
    
    fileprivate mutating func initializeDegreeValues() {
        let fractionalDegrees = decimalDegrees - Double(degrees)
        let decimalMinutes = fractionalDegrees * 60
        _minutesInDecimalFormat = State(initialValue: Double(decimalMinutes))
        _minutesForDMSView = State(initialValue: Int(decimalMinutes.rounded(toPlaces: 3)))
        _minutesForRaymarineView = State(initialValue: Int(decimalMinutes.rounded(toPlaces: 3)))
        let decimalSeconds = Int(((minutesInDecimalFormat - Double(minutesForRaymarineView))*60).rounded())
        _seconds = State(initialValue: decimalSeconds)
        if seconds == 60 {
            _minutesForDMSView = State(initialValue: Int(decimalMinutes.rounded()))
            _seconds = State(initialValue: 0)
        }
    }
    
    var body: some View {
        VStack {
            EntryView
        }
        .onAppear() {
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var EntryView: some View {
        VStack {
            if sizeClass == .regular {
                DMS_View_iPad
            } else {
                DMS_View
            }
            Spacer()
        }
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
        .font(.footnote)
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
    
    fileprivate func SwitchEdibility(target: DMS_PlusMinusTarget) {
        
        togglePickerVisibility()
        
        isDegreesEditable = false
        isMinutesEditable = false
        isSecondsEditable = false
        
        switch target {
        case .DEGREES:
            isDegreesEditable = true
        case .MINUTES:
            isMinutesEditable = true
        case .SECONDS:
            isSecondsEditable = true
        }
    }
    
    
    fileprivate func toggleViewOfSelectedPicker(_ pickerName: DMS_PickerName, hideAll: Bool) {
        
        showDegreesPicker = false
        showMinutesPicker = false
        showSecondsPicker = false
        
        if !hideAll {
            switch pickerName {
            case .Degrees:
                showDegreesPicker.toggle()
            case .Minutes:
                showMinutesPicker.toggle()
            case .Seconds:
                showSecondsPicker.toggle()
            }
        }
    }
    
    fileprivate func togglePickerVisibility(_ selectedPicker: DMS_PickerName? = nil) {
        
        showDegreesPicker = false
        showMinutesPicker = false
        showSecondsPicker = false
     
        if selectedPicker != nil {
            switch selectedPicker {
            case .Degrees:
                showDegreesPicker.toggle()
            case .Minutes:
                showMinutesPicker.toggle()
            case .Seconds:
                showSecondsPicker.toggle()
            default:
                _ = true
            }
        }
    }
    
    fileprivate var PlusMinusInDMSView: some View {
        HStack {
            Button(action: {
                PlusInDMSView()
            }, label: {
                Image(systemName: "plus.square")
                    .font(Font.system(size: 40, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
            Button(action: {
                MinusInDMSView()
            }, label: {
                Image(systemName: "minus.square")
                    .font(Font.system(size: 40, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
        }
    }
    
    fileprivate var PlusMinusInDMSView_iPad: some View {
        HStack {
            Button(action: {
                PlusInDMSView()
            }, label: {
                Image(systemName: "plus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
            Button(action: {
                MinusInDMSView()
            }, label: {
                Image(systemName: "minus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
        }
    }
    
    fileprivate var DMS_View: some View {
        VStack(alignment: .center) {
            if sizeClass == .regular {
                HStack {
                    DMSDetailsView
                    PlusMinusInDMSView
                }
                .font(.largeTitle)
                .bold()
            } else {
                VStack {
                    DMSDetailsView
                    PlusMinusInDMSView
                }
                .font(.largeTitle)
                .bold()
            }
            Instructions
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var DMS_View_iPad: some View {
        VStack(alignment: .center) {
            VStack {
                DMSDetailsView_iPad
                PlusMinusInDMSView_iPad
            }
            .font(Font.system(size: dataFont, weight: .regular, design: .default))
            .bold()
            Instructions_iPad
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var DMSDetailsView: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        togglePickerVisibility(.Degrees)
                        plusMinusTarget = .DEGREES
                    }
            } else {
                Picker("", selection: $degrees) {
                    ForEach(0...maxDegrees, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 100, height: 100)
                .onChange(of: degrees) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            
            Text("\u{00B0}")

            if !showMinutesPicker {
                Text("\(minutesForDMSView)")
                    .onTapGesture {
                        togglePickerVisibility(.Minutes)
                        plusMinusTarget = .MINUTES
                    }
            } else {
                Picker("", selection: $minutesForDMSView) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 70, height: 100)
                .onChange(of: minutesForDMSView) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }

            Text("'")
            
            if !showSecondsPicker {
                Text("\(seconds)")
                    .onTapGesture {
                        togglePickerVisibility(.Seconds)
                        plusMinusTarget = .SECONDS
                    }
            } else {
                Picker("", selection: $seconds) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 70, height: 100)
                .onChange(of: seconds) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }

            Text("\"")

        }
        .font(Font.system(size: 40, weight: .regular, design: .default))
        .padding(.top, 0)
        .padding(.bottom,5)
    }
    
    fileprivate var DMSDetailsView_iPad: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        togglePickerVisibility(.Degrees)
                        plusMinusTarget = .DEGREES
                    }
            } else {
                Picker("", selection: $degrees) {
                    ForEach(0...maxDegrees, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(2.0)
                .frame(width: 120, height: 100)
                .onChange(of: degrees) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            
            Text("\u{00B0}")

            if !showMinutesPicker {
                Text("\(minutesForDMSView)")
                    .onTapGesture {
                        togglePickerVisibility(.Minutes)
                        plusMinusTarget = .MINUTES
                    }
            } else {
                Picker("", selection: $minutesForDMSView) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(2.0)
                .frame(width: 120, height: 100)
                .onChange(of: minutesForDMSView) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            
            VStack {
                Text("'")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
            if !showSecondsPicker {
                Text("\(seconds)")
                    .onTapGesture {
                        togglePickerVisibility(.Seconds)
                        plusMinusTarget = .SECONDS
                    }
            } else {
                Picker("", selection: $seconds) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(2.0)
                .frame(width: 120, height: 100)
                
                .onChange(of: seconds) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            
            Text("\"")

        }
        .font(Font.system(size: 80, weight: .regular, design: .default))
        .padding(.top, 0)
        .padding(.bottom,5)
    }

    
    fileprivate func updateDegreesValue() {
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutesForRaymarineView, seconds: seconds)
        locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
    }
    
    fileprivate func updateDegreesFromDMS() {
        let decimalMinutes = Double(minutesForDMSView)/60
        let decimalSeconds = Double(seconds)/60/60
        locDegrees = CLLocationDegrees(Double(degrees) + decimalMinutes + decimalSeconds)
    }
    
    fileprivate func updateDegreesFromDMS(degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
        let decimalMinutes = Double(minutes)/60
        let decimalSeconds = Double(seconds)/60/60
        return CLLocationDegrees(Double(degrees) + decimalMinutes + decimalSeconds)
    }
    
    fileprivate func updateDegreesFromDMS(originalDegrees: CLLocationDegrees, degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
        //First calculate the original degrees in seconds
        let originalDegreesInSeconds = originalDegrees * 3600.0
        print("Original Degrees in Seconds: \(originalDegreesInSeconds)")
        //Now calculate the new degrees in seconds
        let newDegreesInSeconds = Double(degrees) * 3600.0
        let newMinutesInSeconds = Double(minutes) * 60.0
        let newTotalInSeconds = newDegreesInSeconds + newMinutesInSeconds + Double(seconds)
        print("New Degrees in Seconds: \(newTotalInSeconds)")
        //Now calculate the difference in seconds
        let secondsToAddOrSubtract = (newTotalInSeconds - originalDegreesInSeconds).rounded()
        print("Delta between Original and New: \(secondsToAddOrSubtract) sec")
        let degreesAfterUpdate = originalDegrees + secondsToAddOrSubtract/3600.0
        return degreesAfterUpdate
    }
    
    fileprivate func updateDegreesValueForRaymarineFormat() {
        let strDecimalMinutes = String(minutesForRaymarineView) + "." + String(minuteTenth) + String(minuteHundredth) + String(minuteThousandth)
        if let test = Double(strDecimalMinutes) {
            minutesInDecimalFormat = test
            locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
        }
    }
    
    fileprivate func updateDegreesValueDecimalDegreesFormat() {
        let degrees = Int(decimalDegrees)
        let strDecimalDegrees = String(degrees) + "." + String(degreeTenth) + String(degreeHundredth) + String(degreeThousandth) +
            String(degreeTenThousandth)
        if let test = Double(strDecimalDegrees) {
            locDegrees = test
            decimalDegrees = locDegrees
        }
    }
    
    fileprivate func CalcMinutesAndSecondsFromDecimalDegrees(degrees: Double) {
        let intDegrees = Int(degrees)
        let fractionalMinutes = (degrees - Double(intDegrees)) * 60
        let intMinutes = Int(fractionalMinutes)
        minutesForRaymarineView = intMinutes
        let dblSeconds = (fractionalMinutes - Double(intMinutes)) * 60
        let intSeconds = Int(dblSeconds)
        seconds = intSeconds
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutesForRaymarineView, seconds: seconds)
    }
    
    fileprivate func ConvertDegreesStringToCLLocationDegrees(degrees: String) -> CLLocationDegrees {
        return CLLocationDegrees(floatLiteral: 89.0)
    }
    
    fileprivate func CalculateDecimalDegrees(degrees: Int, decimalMinutes: Double) -> CLLocationDegrees {
        var decimalDegrees: Double
        decimalDegrees = Double(degrees) + decimalMinutes/60
        return CLLocationDegrees(decimalDegrees)
    }
    
    fileprivate func CalculateIntMinutesFromDecimalMinutes(strMinutesInDecimalFormat: String) -> String {
        
        guard let fltMinute = Float(strMinutesInDecimalFormat) else {
            return "0"
        }
        let intMinute = Int(fltMinute)
        return String(intMinute)
    }
    
    fileprivate func CalculateIntSecondsFromDecimalMinutes(minutesInDecimalFormat: Double) -> Int {
        
        let intMinute = Int(minutesInDecimalFormat)
        let seconds = (minutesInDecimalFormat - Double(intMinute)) * 60
        return Int(seconds)
    }
    
    fileprivate func CalculateDecimalMinutesFromMinutesAndSeconds(minutes: Int, seconds: Int) -> Double {
        let totalSeconds = minutes * 60 + seconds
        return Double(totalSeconds)/60.0
    }
    
    fileprivate func PlusInRaymarineView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < maxDegrees - 1 { degrees += 1 }
        case .MINUTES:
            if minutesForRaymarineView < 59 { minutesForRaymarineView += 1 }
        case .SECONDS:
            _ = true
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
                        if degrees < maxDegrees - 1 {
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
                                if degrees < maxDegrees - 1 {
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
        case .TENTHOUSANDTH:
            _ = true
        }
        
        updateDegreesValueForRaymarineFormat()
    }
    
    fileprivate func MinusInRaymarineView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 { degrees -= 1 }
        case .MINUTES:
            if minutesForRaymarineView > 0 { minutesForRaymarineView -= 1 }
        case .SECONDS:
            let unused = true
        case .TENTH:
            if minuteTenth > 0 { minuteTenth -= 1 }
        case .HUNDREDTH:
            if minuteHundredth > 0 { minuteHundredth -= 1 }
        case .THOUSANDTH:
            if minuteThousandth > 0 { minuteThousandth -= 1 }
        case .TENTHOUSANDTH:
            let unused = true
        }
        updateDegreesValueForRaymarineFormat()
    }
    
    
    fileprivate func PlusInDecimalDegreeView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < maxDegrees - 1 {
                decimalDegrees += 1
            }
        case .MINUTES:
            _ = true
        case .SECONDS:
            _ = true
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
                    if Int(decimalDegrees.rounded()) < maxDegrees {
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
                                if Int(decimalDegrees.rounded()) < maxDegrees - 1 {
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
    

    fileprivate func MinusInDecimalDegreeView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 {
                decimalDegrees -= 1
            }
        case .MINUTES:
            _ = 0
        case .SECONDS:
            _ = true
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

    fileprivate func PlusInDMSView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < maxDegrees - 1 {
                degrees += 1
            }
        case .MINUTES:
            if minutesForDMSView < 59 { minutesForDMSView += 1 }
        case .SECONDS:
            if seconds < 59 {
                seconds += 1
            } else {
                if minutesForDMSView < 59 {
                    minutesForDMSView += 1
                    seconds = 0
                } else {
                    if degrees < maxDegrees - 1 {
                        degrees += 1
                        minutesForDMSView = 0
                        seconds = 0
                    }
                }
            }
        case .TENTH:
            _ = true
        case .HUNDREDTH:
            _ = true
        case .THOUSANDTH:
            _ = true
        case .TENTHOUSANDTH:
            _ = true
        }
        locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
    }

    fileprivate func MinusInDMSView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 { degrees -= 1 }
        case .MINUTES:
            if minutesForDMSView > 0 { minutesForDMSView -= 1 }
        case .SECONDS:
            if seconds > 0 { seconds -= 1 }
        case .TENTH:
            _ = true
        case .HUNDREDTH:
            _ = true
        case .THOUSANDTH:
            _ = true
        case .TENTHOUSANDTH:
            _ = true
        }
        
        if seconds >= 1 {
            seconds -= 1
        } else {
             if minutesForDMSView > 1 {
                 minutesForDMSView -= 1
                 seconds = 59
             } else {
                 if degrees > 1 {
                     degrees -= 1
                     minutesForDMSView = 59
                     seconds = 59
                 }
             }
        }
        locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
    }

    
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

fileprivate func extractTenThousandth(degrees: CLLocationDegrees) -> String {
    let degreesRounded = Double(degrees).rounded(toPlaces: 4)
    let strDegrees = String(degreesRounded)
    let periodIndex = strDegrees.firstIndex(of: ".")
    //NOTE: CLLocationsDegrees values ALWAYS contain a period
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 4 {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        let tenthousandsIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 4, limitedBy: strDegrees.endIndex)
        return String(strDegrees[tenthousandsIndex!])
    } else {
        return "0"
    }
}

#Preview {
    @Previewable @State var viewFormat: ViewFormat = .DMS
    @Previewable @State var tmp = CLLocationDegrees(floatLiteral: 120.5890)
    @Previewable @State var orientation: String = "W"
    
    DMSEntryView(orientation: orientation, locDegrees: $tmp, viewFormat: $viewFormat)
}

