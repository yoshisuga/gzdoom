//
//  MonsterKillWidget.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 10/27/24.
//

import WidgetKit
import SwiftUI
import Charts


struct MonsterKillEntry: TimelineEntry {
    let date: Date
    let dailyKills: [String: [Int: MonsterKillTracker.KillData]]
    let selectedDay: String
}

struct Provider: TimelineProvider {
    let tracker = MonsterKillTracker()
    
  func placeholder(in context: Context) -> MonsterKillEntry {
    let dummyData: [String: [Int: MonsterKillTracker.KillData]] = [
      "2024-10-20": [
        9: MonsterKillTracker.KillData(kills: ["Imp": 5, "Zombieman": 2, "Demon": 1]),
        10: MonsterKillTracker.KillData(kills: ["Shotgun Guy": 3, "Heavy Weapon Dude": 4, "Lost Soul": 2]),
        11: MonsterKillTracker.KillData(kills: ["Hell Knight": 6, "Revenant": 3, "Explosive Barrel": 2]),
        12: MonsterKillTracker.KillData(kills: ["Imp": 2, "Zombieman": 5, "Demon": 3]),
        13: MonsterKillTracker.KillData(kills: ["Shotgun Guy": 7, "Heavy Weapon Dude": 1, "Lost Soul": 4]),
        14: MonsterKillTracker.KillData(kills: ["Hell Knight": 4, "Revenant": 3, "Explosive Barrel": 2]),
        15: MonsterKillTracker.KillData(kills: ["Imp": 5, "Zombieman": 2, "Demon": 3]),
        16: MonsterKillTracker.KillData(kills: ["Shotgun Guy": 3, "Heavy Weapon Dude": 5, "Lost Soul": 1]),
        17: MonsterKillTracker.KillData(kills: ["Hell Knight": 6, "Revenant": 2, "Explosive Barrel": 3]),
        18: MonsterKillTracker.KillData(kills: ["Imp": 4, "Zombieman": 6, "Demon": 3])
      ]]
    return MonsterKillEntry(date: Date(), dailyKills: dummyData, selectedDay: "2024-10-20")
  }
  
  func getSnapshot(in context: Context, completion: @escaping (MonsterKillEntry) -> Void) {
    let dummyData: [String: [Int: MonsterKillTracker.KillData]] = [
      "2024-10-20": [
        9: MonsterKillTracker.KillData(kills: ["Imp": 5, "Zombieman": 2, "Demon": 1]),
        10: MonsterKillTracker.KillData(kills: ["Shotgun Guy": 3, "Heavy Weapon Dude": 4, "Lost Soul": 2]),
        11: MonsterKillTracker.KillData(kills: ["Hell Knight": 6, "Revenant": 3, "Explosive Barrel": 2]),
        12: MonsterKillTracker.KillData(kills: ["Imp": 2, "Zombieman": 5, "Demon": 3]),
        13: MonsterKillTracker.KillData(kills: ["Shotgun Guy": 7, "Heavy Weapon Dude": 1, "Lost Soul": 4]),
        14: MonsterKillTracker.KillData(kills: ["Hell Knight": 4, "Revenant": 3, "Explosive Barrel": 2]),
        15: MonsterKillTracker.KillData(kills: ["Imp": 5, "Zombieman": 2, "Demon": 3]),
        16: MonsterKillTracker.KillData(kills: ["Shotgun Guy": 3, "Heavy Weapon Dude": 5, "Lost Soul": 1]),
        17: MonsterKillTracker.KillData(kills: ["Hell Knight": 6, "Revenant": 2, "Explosive Barrel": 3]),
        18: MonsterKillTracker.KillData(kills: ["Imp": 4, "Zombieman": 6, "Demon": 3])
      ]]
    let entry = MonsterKillEntry(date: Date(), dailyKills: dummyData, selectedDay: "2024-10-20")
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<MonsterKillEntry>) -> Void) {
    var entries: [MonsterKillEntry] = []
    let currentDate = Date()
    
    for hourOffset in 0 ..< 24 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = MonsterKillEntry(date: entryDate, dailyKills: tracker.loadKills(), selectedDay: tracker.formatDate(Date()))
      entries.append(entry)
    }
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct MonsterKillWidgetEntryView: View {
  var entry: Provider.Entry
  
  var body: some View {
    VStack {
      Text("GenZD Monster Kills!").font(.custom("PerfectDOSVGA437", size: 16)).foregroundStyle(.red)
      MonsterKillChartView3(dailyKills: entry.dailyKills)
    }.containerBackground(for: .widget) {
      Color.black
    }
  }
}

struct MonsterKillWidget: Widget {
  let kind: String = "MonsterKillWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      MonsterKillWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Monster Kill Tracker")
    .description("Track your monster kills by the hour.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct MonsterKillChartView: View {
  let dailyKills: [String: [Int: MonsterKillTracker.KillData]]
  let selectedDay: String
  
  var body: some View {
    GeometryReader { geometry in
      VStack {

        Chart {
          ForEach(Array(dailyKills[selectedDay, default: [:]].sorted(by: { $0.key < $1.key })), id: \.key) { hour, killData in
            ForEach(Array(killData.kills.keys.sorted()), id: \.self) { monsterType in
              let count = killData.kills[monsterType] ?? 0
              BarMark(
                x: .value("Kills", count),
                y: .value("Hour", hour) )
              .foregroundStyle(color(for: monsterType))
            }
          }
        }.chartYAxis {
          AxisMarks(position: .leading, values: .automatic) {
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
          }
        }.chartXAxis {
          AxisMarks(values: .automatic) {
            AxisGridLine()
            AxisTick()
            AxisValueLabel()
          }
        }
        .padding()
        .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
        
//        Chart {
//          ForEach(Array(dailyKills[selectedDay, default: [:]].sorted(by: { $0.key < $1.key })), id: \.key) { hour, killData in
//            ForEach(Array(killData.kills.keys.sorted()), id: \.self) { monsterType in
//              let count = killData.kills[monsterType] ?? 0
//              
//              BarMark(
//                x: .value("Hour", hour),
//                y: .value("Kills", count)
//              )
//              .foregroundStyle(color(for: monsterType))
//            }
//          }
//        }
//        .chartYAxis {
//          AxisMarks(position: .leading, values: .automatic) {
//            //          AxisGridLine()
//            AxisTick()
//            AxisValueLabel()
//          }
//        }
//        .chartXAxis {
//          AxisMarks(values: .automatic) { value in
//            //              AxisGridLine()
//            AxisTick()
//            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
//          }
//        }
//        .padding()
//        .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
        
        HStack {
          legendItem(color: .doomImpBrown, text: "DoomImp", icon: Image("icon_imp2"))
            legendItem(color: .doomZombiemanGreen, text: "DoomZombieman")
            legendItem(color: .doomDemonPink, text: "DoomDemon")
            legendItem(color: .doomShotgunGuyBlue, text: "DoomShotgunGuy")
            legendItem(color: .doomHeavyWeaponDudeRed, text: "DoomHeavyWeaponDude")
            legendItem(color: .doomLostSoulWhite, text: "DoomLostSoul")
            legendItem(color: .doomHellKnightBeige, text: "DoomHellKnight")
            legendItem(color: .doomRevenantWhite, text: "DoomRevenant")
            legendItem(color: .gray, text: "DoomExplosiveBarrel")
        }
        .padding([.leading, .trailing, .bottom])
        .frame(width: geometry.size.width, height: geometry.size.height * 0.2)
      }
    }
  }
  
  private func color(for monsterType: String) -> Color {
    switch monsterType {
    case "Imp": return Color.doomImpBrown
    case "Zombieman": return Color.doomZombiemanGreen
    case "Demon": return Color.doomDemonPink
    case "Shotgun Guy": return Color.doomShotgunGuyBlue
    case "Heavy Weapon Dude": return Color.doomHeavyWeaponDudeRed
    case "Lost Soul": return Color.doomLostSoulWhite
    case "Hell Knight": return Color.doomHellKnightBeige
    case "Revenant": return Color.doomRevenantWhite
    case "Explosive Barrel": return .gray
    default: return .red
    }
  }

  private func legendItem(color: Color, text: String, icon: Image? = nil) -> some View {
    VStack {
      color.frame(width: 20, height: 20)
      if let icon {
        icon
      } else {
        Text(text)
      }
    }
  }
}

extension Color {
  static let doomDemonPink = Color(red: 255/255, green: 182/255, blue: 193/255) // Demon (Pinkie)
  static let doomZombiemanGreen = Color(red: 169/255, green: 183/255, blue: 157/255) // Zombieman
  static let doomImpBrown = Color(red: 139/255, green: 69/255, blue: 19/255) // Imp
  static let doomShotgunGuyBlue = Color(red: 0/255, green: 0/255, blue: 128/255) // Shotgun Guy
  static let doomHeavyWeaponDudeRed = Color(red: 139/255, green: 0/255, blue: 0/255) // Heavy Weapon Dude (Chaingunner)
  static let doomLostSoulWhite = Color(red: 255/255, green: 255/255, blue: 255/255) // Lost Soul
  static let doomCacodemonRed = Color(red: 255/255, green: 0/255, blue: 0/255) // Cacodemon
  static let doomHellKnightBeige = Color(red: 222/255, green: 184/255, blue: 135/255) // Hell Knight
  static let doomBaronOfHellPink = Color(red: 255/255, green: 105/255, blue: 180/255) // Baron of Hell
  static let doomArachnotronGreen = Color(red: 60/255, green: 179/255, blue: 113/255) // Arachnotron
  static let doomPainElementalBrown = Color(red: 139/255, green: 69/255, blue: 19/255) // Pain Elemental
  static let doomRevenantWhite = Color(red: 255/255, green: 255/255, blue: 255/255) // Revenant
  static let doomMancubusBrown = Color(red: 160/255, green: 82/255, blue: 45/255) // Mancubus
  static let doomArchvileYellow = Color(red: 255/255, green: 255/255, blue: 102/255) // Archvile
  static let doomSpiderMastermindGray = Color(red: 128/255, green: 128/255, blue: 128/255) // Spider Mastermind
  static let doomCyberdemonGray = Color(red: 112/255, green: 128/255, blue: 144/255) // Cyberdemon
}

struct MonsterKillChartView2: View {
    let dailyKills: [String: [Int: MonsterKillTracker.KillData]]
    let selectedDay: String

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Chart {
                    ForEach(Array(dailyKills[selectedDay, default: [:]].sorted(by: { $0.key < $1.key })), id: \.key) { hour, killData in
                        ForEach(Array(killData.kills.keys.sorted()), id: \.self) { monsterType in
                            let count = killData.kills[monsterType] ?? 0
                            
                            BarMark(
                                x: .value("Kills", count),
                                y: .value("Hour", hour)
                            )
                            .foregroundStyle(color(for: monsterType))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
                
                // Legend
                HStack {
                    legendItem(color: .doomImpBrown, text: "DoomImp")
                    legendItem(color: .doomZombiemanGreen, text: "DoomZombieman")
                    legendItem(color: .doomDemonPink, text: "DoomDemon")
                    legendItem(color: .doomShotgunGuyBlue, text: "DoomShotgunGuy")
                    legendItem(color: .doomHeavyWeaponDudeRed, text: "DoomHeavyWeaponDude")
                    legendItem(color: .doomLostSoulWhite, text: "DoomLostSoul")
                    legendItem(color: .doomHellKnightBeige, text: "DoomHellKnight")
                    legendItem(color: .doomRevenantWhite, text: "DoomRevenant")
                    legendItem(color: .gray, text: "DoomExplosiveBarrel")
                }
                .padding([.leading, .trailing, .bottom])
                .frame(width: geometry.size.width, height: geometry.size.height * 0.2)
            }
        }
    }

    private func color(for monsterType: String) -> Color {
        switch monsterType {
        case "DoomImp": return .doomImpBrown
        case "DoomZombieman": return .doomZombiemanGreen
        case "DoomDemon": return .doomDemonPink
        case "DoomShotgunGuy": return .doomShotgunGuyBlue
        case "DoomHeavyWeaponDude": return .doomHeavyWeaponDudeRed
        case "DoomLostSoul": return .doomLostSoulWhite
        case "DoomHellKnight": return .doomHellKnightBeige
        case "DoomRevenant": return .doomRevenantWhite
        case "DoomExplosiveBarrel": return .gray
        default: return .red
        }
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack {
            color.frame(width: 20, height: 20)
            Text(text)
                .font(.caption)
        }
    }
}

struct MonsterKillChartView3: View {
    let dailyKills: [String: [Int: MonsterKillTracker.KillData]]

    var body: some View {
        Chart {
            ForEach(Array(dailyKills.keys.sorted()), id: \.self) { day in
                if let killsForDay = dailyKills[day] {
                    ForEach(killsForDay.keys.sorted(), id: \.self) { hour in
                        if let killData = killsForDay[hour] {
                            ForEach(killData.kills.keys.sorted(), id: \.self) { monsterType in
                                let count = killData.kills[monsterType] ?? 0
                                
                                BarMark(
                                    x: .value("Total Kills", count),
                                    y: .value("Day", day)
                                )
                                .foregroundStyle(color(for: monsterType))
                                
                            }
                        }
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day().month().year())
            }
        }
        .padding()
    }

  private func color(for monsterType: String) -> Color {
    switch monsterType {
    case "Imp": return Color.doomImpBrown
    case "Zombieman": return Color.doomZombiemanGreen
    case "Demon": return Color.doomDemonPink
    case "Shotgun Guy": return Color.doomShotgunGuyBlue
    case "Heavy Weapon Dude": return Color.doomHeavyWeaponDudeRed
    case "Lost Soul": return Color.doomLostSoulWhite
    case "Hell Knight": return Color.doomHellKnightBeige
    case "Revenant": return Color.doomRevenantWhite
    case "Explosive Barrel": return .gray
    default: return .red
    }
  }
}


extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}
