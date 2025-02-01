//
//  MonsterKillTracker.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 10/27/24.
//

import Foundation

@objc class MonsterKillTracker: NSObject {
  
  @objc static let shared = MonsterKillTracker()

  struct KillData: Codable {
    var kills: [String: Int]
    
    mutating func addKill(monsterType: String) {
      kills[monsterType, default: 0] += 1
    }
  }


  private let userDefaults: UserDefaults
  private let killsKey: String
  
  // Hardcoded app group identifier
  private let appGroup = "group.com.yoshisuga.genZD"
  
  override init() {
    self.userDefaults = UserDefaults(suiteName: appGroup)!
    self.killsKey = "monsterKills"
    
    super.init()
    
    if userDefaults.data(forKey: killsKey) == nil {
      let initialData = [String: [Int: KillData]]()
      let encodedData = try? JSONEncoder().encode(initialData)
      userDefaults.set(encodedData, forKey: killsKey)
    }
  }
  
  @objc func addKill(monsterType: String) {
    let queue = DispatchQueue.global(qos: .background)
    queue.async {
      var dailyKills = self.loadKills()
      let currentDay = self.formatDate(Date())
      let currentHour = Calendar.current.component(.hour, from: Date())
      
      var killsByDay = dailyKills[currentDay] ?? [:]
      var killData = killsByDay[currentHour] ?? KillData(kills: [:])
      
      killData.addKill(monsterType: monsterType)
      killsByDay[currentHour] = killData
      dailyKills[currentDay] = killsByDay
      
      self.saveKills(dailyKills)
      
      // Trim data to only store a week's worth
      let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
      let oldDay = self.formatDate(oneWeekAgo)
      dailyKills = dailyKills.filter { $0.key >= oldDay }
      
      self.saveKills(dailyKills)
      
      self.prettyPrintKills(dailyKills)
    }
  }
  
  @objc func getKillCount(monsterType: String, day: String, hour: Int) -> Int {
    let dailyKills = loadKills()
    return dailyKills[day]?[hour]?.kills[monsterType] ?? 0
  }
  
  @objc func getTotalKills() -> Int {
    let dailyKills = loadKills()
    return dailyKills.values.flatMap { $0.values.flatMap { $0.kills.values } }.reduce(0, +)
  }
  
  @objc func resetKills() {
    let initialData = [String: [Int: KillData]]()
    let encodedData = try? JSONEncoder().encode(initialData)
    userDefaults.set(encodedData, forKey: killsKey)
  }
  
  func loadKills() -> [String: [Int: KillData]] {
    if let data = userDefaults.data(forKey: killsKey),
       let kills = try? JSONDecoder().decode([String: [Int: KillData]].self, from: data) {
      return kills
    }
    return [:]
  }
  
  private func saveKills(_ kills: [String: [Int: KillData]]) {
    let encodedData = try? JSONEncoder().encode(kills)
    userDefaults.set(encodedData, forKey: killsKey)
  }
  
  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }

  private func prettyPrintKills(_ kills: [String: [Int: KillData]]) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    if let jsonData = try? encoder.encode(kills),
       let jsonString = String(data: jsonData, encoding: .utf8) {
      print(jsonString)
    }
  }
}
