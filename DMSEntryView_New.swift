//
//  DMSEntryView_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/17/26.
//

import SwiftUI
import CoreLocation

/*
This view supports the format:
 # DMS: Degrees, Minutes, Seconds, e.g. 37° 23′ 22″
 */

struct DMSEntryView_New: View {
    
    @ObservedObject var locObj: LocationObject
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var plusMinusTarget: DMS_PlusMinusTarget = .SECONDS
    
    @State private var path = NavigationPath()
    
    @State private var degrees: Int = -180
    @State private var decimalDegrees: Double = -179.001
    @State private var minutesForRaymarineView: Int = 59
    @State private var minutesForDMSView: Int = 59
    
    @State private var minutesInDecimalFormat:Double = 59.000
    @State private var seconds: Int = 45
        
    @State private var showDegreesPicker = false
    @State private var showMinutesPicker = false
    @State private var showSecondsPicker = false
    
    @State private var isDegreesEditable = false
    @State private var isMinutesEditable = false
    @State private var isSecondsEditable = false

    var locIndex: Int = 0

    init(locObj: LocationObject, locIndex: Int) {
        self.locObj = locObj
        self.locIndex = locIndex
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
        .ignoresSafeArea(.keyboard)
    }
    
    fileprivate var EntryView: some View {
        VStack {
            MainView
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
    
    fileprivate var PlusMinus: some View {
        HStack {
            Button(action: {
                IncreaseValue()
            }, label: {
                Image(systemName: "plus.square")
                    .font(Font.system(size: 40, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
            Button(action: {
                DecreaseValue()
            }, label: {
                Image(systemName: "minus.square")
                    .font(Font.system(size: 40, weight: .regular, design: .default))
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
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
            Button(action: {
                DecreaseValue()
            }, label: {
                Image(systemName: "minus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
        }
    }
    
    fileprivate var MainView: some View {
        VStack(alignment: .center) {
            HStack {
                DetailsView//_iPad
                PlusMinus//_iPad
            }
            Instructions
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var MainView_iPad: some View {
        VStack(alignment: .center) {
            VStack {
                DetailsView_iPad
                PlusMinus_iPad
            }
            .font(Font.system(size: dataFont, weight: .regular, design: .default))
            .bold()
            Instructions_iPad
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var DetailsView: some View {
        HStack {
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
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.0)
                .frame(width: 100, height: 100)
                .onChange(of: degrees) {
                    updateDegreeValue()
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
                    updateDegreeValue()
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
                    updateDegreeValue()
                }
            }
            
            Text("\"")
            
        }
        .font(Font.system(size: 40, weight: .regular, design: .default))
        .padding(.top, 0)
        .padding(.bottom,5)
    }
    
    fileprivate var DetailsView_iPad: some View {
        HStack {
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
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(2.0)
                .frame(width: 120, height: 100)
                .onChange(of: degrees) {
                    updateDegreeValue()
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
                    updateDegreeValue()
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
                    updateDegreeValue()
                }
            }
            
            Text("\"")
            
        }
        .font(Font.system(size: 80, weight: .regular, design: .default))
        .padding(.top, 0)
        .padding(.bottom,5)
    }
    
    fileprivate func updateDegreeValue() {
        var currentDegrees: Double
        if locObj.latLong == .Latitude {
            currentDegrees = locObj.locations[locIndex].coordinate.latitude
        } else {
            currentDegrees = locObj.locations[locIndex].coordinate.longitude
        }
        var newDegrees = updateDegrees(originalDegrees: currentDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
        if locObj.hemisphere == "S" || locObj.hemisphere == "W" {
            newDegrees = -newDegrees
        }
        if locObj.latLong == .Latitude {
            locObj.locations[locIndex].coordinate.latitude = newDegrees
        } else {
            locObj.locations[locIndex].coordinate.longitude = newDegrees
        }

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

    fileprivate func updateDegrees(originalDegrees: CLLocationDegrees, degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
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
        if locObj.hemisphere == "S" || locObj.hemisphere == "W" {
            return -degreesAfterUpdate
        } else {
            return degreesAfterUpdate
        }
    }

    fileprivate func IncreaseValue() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < locObj.maxDegrees - 1 {
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
                    if degrees < locObj.maxDegrees - 1 {
                        degrees += 1
                        minutesForDMSView = 0
                        seconds = 0
                    }
                }
            }
        }
        var currentDegrees: Double
        if locObj.latLong == .Latitude {
            currentDegrees = locObj.locations[locIndex].coordinate.latitude
        } else {
            currentDegrees = locObj.locations[locIndex].coordinate.longitude
        }
        var newDegrees = updateDegrees(originalDegrees: currentDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
        if locObj.latLong == .Latitude {
            locObj.locations[locIndex].coordinate.latitude = newDegrees
        } else {
            locObj.locations[locIndex].coordinate.longitude = newDegrees
        }
    }
    
    fileprivate func DecreaseValue() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 { degrees -= 1 }
        case .MINUTES:
            if minutesForDMSView > 0 { minutesForDMSView -= 1 }
        case .SECONDS:
            if seconds > 0 {
                seconds -= 1
            } else {
                if minutesForDMSView > 0 {
                    minutesForDMSView -= 1
                    seconds = 59
                } else {
                    if degrees > 0 {
                        degrees -= 1
                        minutesForDMSView = 59
                        seconds = 59
                    }
                }
            }
        }
        var currentDegrees: Double
        if locObj.latLong == .Latitude {
            currentDegrees = locObj.locations[locIndex].coordinate.latitude
        } else {
            currentDegrees = locObj.locations[locIndex].coordinate.longitude
        }
        var newDegrees = updateDegrees(originalDegrees: currentDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
        if locObj.latLong == .Latitude {
            locObj.locations[locIndex].coordinate.latitude = newDegrees
        } else {
            locObj.locations[locIndex].coordinate.longitude = newDegrees
        }

    }
    
}

#Preview {
    let locObj = LocationObject()
    DMSEntryView_New(locObj: locObj, locIndex: 0)
}
