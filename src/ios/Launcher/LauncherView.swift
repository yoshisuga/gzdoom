//
//  LauncherView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 2/19/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum LauncherMode: String {
  case launcher = "Launcher", savedConfigs = "Saved Configurations"
}

enum SavedConfigSortMode {
  case name, lastRanAt
}

enum LaunchConfigAction {
  case created, none
}

enum ActiveSheet: Identifiable {
  case addLauncherConfig, showHelp, saveLaunchConfig, multiplayer, settings
#if ZERO
  case upgrade
#endif
  var id: Int { hashValue }
}
  

struct PresentationKey: EnvironmentKey {
    static let defaultValue: [Binding<ActiveSheet?>] = []
}

extension EnvironmentValues {
  var presentations: [Binding<ActiveSheet?>] {
    get { return self[PresentationKey.self] }
    set { self[PresentationKey.self] = newValue }
  }
}

class HighlightManager: ObservableObject {
  static let shared = HighlightManager()
  @Published var nameToHighlight: String?
}

enum FileSortBy: Codable, Hashable {
  case name
  case date

  var view: some View {
    HStack {
      switch self {
      case .date:
        Text("Date")
      case .name:
        Text("Name")
      }
    }
  }
  
  var label: String {
      switch self {
      case .date:
          return "Date"
      case .name:
          return "Name"
      }
  }
}
  

struct FileSortState: Codable {
  let sortBy: FileSortBy
  let isAscending: Bool
  static let userDefaultsKey = "lastFileSortState"
}

extension FileSortState {
  func saveToUserDefaults() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(self) {
      UserDefaults.standard.set(encoded, forKey: FileSortState.userDefaultsKey)
    }
  }
  
  static func loadFromUserDefaults() -> FileSortState {
    if let savedData = UserDefaults.standard.data(forKey: FileSortState.userDefaultsKey) {
      let decoder = JSONDecoder()
      if let decoded = try? decoder.decode(FileSortState.self, from: savedData) {
        return decoded
      }
    }
    return .init(sortBy: .name, isAscending: true)
  }
}

struct CreateLaunchConfigView: View {
  @Environment(\.dismiss) var dismiss
  @ObservedObject var viewModel: LauncherViewModel
  @State var isEditing = false
  @State private var showDocumentPicker = false
  
  @State private var dragOverCategory: FileCategory?
  
  #if ZERO
  @State private var showUpgradeView = false
  #endif
  
  @Namespace var namespace
  
  let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
  
  let zdFileType = UTType(exportedAs: "com.yoshisuga.genzd.data", conformingTo: .data)
  
  @State private var sortState: FileSortState = .init(sortBy: .name, isAscending: true)
  
  var body: some View {
    VStack {
      ZStack {
        HStack {
          Spacer()
          Text("\(isEditing ? "Edit" : "Create") Launch Configuration")
          Spacer()
        }.padding()
        HStack {
          Button("Cancel") {
            viewModel.selectedIWAD = nil
            viewModel.selectedExternalFiles = []
            dismiss()
          }.buttonStyle(.bordered).foregroundColor(.red).font(.body)
          Spacer()
#if !os(tvOS)
          Button("Import") {
            showDocumentPicker = true
          }.buttonStyle(.bordered).foregroundColor(.yellow).font(.body)
#endif
        }.padding()
      }
      if viewModel.iWadFiles.isEmpty {
        VStack(spacing: 24) {
          Spacer()
          Text("You do not have any valid base game files available.")
          
#if os(tvOS)
          if let webServer = viewModel.webServer {
            Spacer()
            Text("Upload files by navigating to one of the following URLs on another device:")
            if let bonjourServerUrl = webServer.bonjourServerURL {
              Text(bonjourServerUrl.absoluteString).foregroundStyle(.cyan)
            }
            if let serverUrl = webServer.serverURL {
              Text(serverUrl.absoluteString).foregroundStyle(.cyan)
            }
            Spacer()
          }
#else
          Button("Import Files") {
            showDocumentPicker = true
          }.buttonStyle(.bordered).foregroundColor(.yellow).font(.body)
#endif
          Spacer()
        }
      } else {
        HStack {
          VStack {
            if let selectedIWAD = viewModel.selectedIWAD {
              IWADSelectedView(viewModel: viewModel, selected: selectedIWAD, namespace: namespace)
            } else {
              SelectIWADView(viewModel: viewModel, namespace: namespace)
            }
          }.frame(maxWidth: .infinity)
          ZStack {
            VStack {
              HStack {
                Text("External Files/Mods").foregroundColor(.cyan)
                Menu {
                  Text("Sort By")
                    ForEach([FileSortBy.name, FileSortBy.date], id: \.self) { option in
                      Button(action: {
                        if sortState.sortBy == option {
                          sortState = FileSortState(sortBy: option, isAscending: !sortState.isAscending)
                        } else {
                          sortState = FileSortState(sortBy: option, isAscending: sortState.isAscending)
                        }
                        sortState.saveToUserDefaults()
                      }) {
                        HStack {
                          Text((sortState.sortBy == option ? "✓ " : "") + option.label)
                          if sortState.sortBy == option {
                            if sortState.isAscending {
                              Image(systemName: "arrow.up")
                            } else {
                              Image(systemName: "arrow.down")
                            }
                          }
                        }
                      }
                    }
                } label: {
                  Image(systemName: "ellipsis.circle")
                }
              }
              // Categories
              ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                  ForEach(FileCategory.allCases, id: \.self) { category in
                    Text(category.title)
                      .padding(.horizontal, 10)
                      .padding(.vertical, 5)
                      .background(viewModel.selectedCategory == category ? category.color : Color.darkGray)
                      .foregroundColor(viewModel.selectedCategory == category ? .white : category.color)
                      .cornerRadius(20)
                      .scaleEffect(dragOverCategory == category ? 1.2 : 1.0)
                      .animation(.easeInOut(duration: 0.2), value: dragOverCategory)
                      .onTapGesture {
                        if viewModel.selectedCategory != category {
                          viewModel.selectedCategory = category
                        }
                      }
                      .onDrop(of: [.text], isTargeted: Binding(
                        get: {
                          feedbackGenerator.impactOccurred()
                          return dragOverCategory == category
                        },
                        set: { newValue in
                          if newValue {
                            dragOverCategory = category
                          } else {
                            dragOverCategory = nil
                          }
                        }
                      )) { providers in
                        handleDrop(providers: providers, category: category)
                      }
                  }
                }
              }

              // List of Files
//              #if ZERO
//              if !PurchaseViewModel.shared.isPurchased && (viewModel.selectedCategory != .all) && filteredFiles().isEmpty {
//                VStack {
//                  Spacer()
//                  Text("Upgrade to categorize your external mod files!")
//                  Button {
//                    showUpgradeView = true
//                  } label: {
//                    Text("Upgrade Now").font(.actionButton)
//                  }
//                  Spacer()
//                }
//              }
//              #endif
              
              List {
                ForEach(filteredFiles().sorted(by: {
                  if sortState.sortBy == .name {
                    if sortState.isAscending {
                      return $0.displayName.lowercased() < $1.displayName.lowercased()
                    }
                    return $0.displayName.lowercased() > $1.displayName.lowercased()
                  } else {
                    if sortState.isAscending {
                      return $0.fileAddedDate < $1.fileAddedDate
                    } else {
                      return $0.fileAddedDate > $1.fileAddedDate
                    }
                  }
                  
                }), id:\.self) { file in
                  MultipleSelectionRow(
                    file: file,
                    isSelected: viewModel.selectedExternalFiles.contains(file)
                  ) {
                    if viewModel.selectedExternalFiles.contains(file) {
                      viewModel.selectedExternalFiles.removeAll(where: { $0 == file })
                    }
                    else {
                      viewModel.selectedExternalFiles.append(file)
                    }
                  }.environmentObject(viewModel)
                }
              }.frame(maxHeight: .infinity).listStyle(PlainListStyle())
              
            }
            VStack {
              // Bottom bar
              Spacer()
              if !viewModel.selectedExternalFiles.isEmpty {
                HStack {
                  Text("\(viewModel.selectedExternalFiles.count) file(s) selected")
                    .padding(.top, 10).font(.small)
                  
                  Menu {
                    ForEach(FileCategory.allCases.filter { $0 != .all }.reversed(), id: \.self) { category in
                      Button(action: {
                        viewModel.assignFilesToCategory(files: viewModel.selectedExternalFiles, category: category)
                        viewModel.selectedExternalFiles = []
                      }) {
                        Text(category.title).foregroundStyle(category.color)
                      }
                    }
                  } label: {
                    Text("Categorize")
                      .foregroundColor(.white)
                      .padding(6)
                      .background(Color.blue)
                      .cornerRadius(10)
                      .font(.small)
                  }
                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding(.horizontal)
                .shadow(radius: 5)
                .transition(.move(edge: .bottom).combined(with: .opacity)) // Add transition
                .animation(.easeInOut(duration: 0.3), value: viewModel.selectedExternalFiles.count) // Add animation
              }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedExternalFiles.count) // Add animation
          }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedExternalFiles.isEmpty) // Apply animation to the condition
      }
    }
    #if ZERO
    .sheet(isPresented: $showUpgradeView) {
      UpgradeView()
    }
    #endif
    .onAppear {
      viewModel.setup()
      sortState = FileSortState.loadFromUserDefaults()
    }
#if os(iOS)
    .fileImporter(isPresented: $showDocumentPicker, allowedContentTypes: [zdFileType], allowsMultipleSelection: true) { result in
      switch result {
      case .success(let files):
        let fm = FileManager.default
        let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for file in files {
          let access = file.startAccessingSecurityScopedResource()
          if access {
            do {
              let filename = file.lastPathComponent
              let destURL = documentsURL.appendingPathComponent(filename)
              try fm.copyItem(at: file, to: destURL)
            } catch {
              print("file import copy error: \(error)")
            }
            file.stopAccessingSecurityScopedResource()
          } else {
            print("Could not access file: \(file)")
          }
        }
        self.viewModel.setup()
      case .failure(let error):
        print("failure in import file: \(error)")
      }
    }
#endif
  }
  
  private func filteredFiles() -> [GZDoomFile] {
    if viewModel.selectedCategory == .all {
      return viewModel.externalFiles.filter { $0.originalDoomEngineGame == nil }
    }
    return viewModel.externalFiles.filter { file in
      file.originalDoomEngineGame == nil &&
      file.category == viewModel.selectedCategory
    }
  }
  
  private func handleDrop(providers: [NSItemProvider], category: FileCategory) -> Bool {
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    if let itemProvider = providers.first {
      itemProvider.loadObject(ofClass: NSString.self) { (object, error) in
        DispatchQueue.main.async {
          if let fileName = object as? String {
            if let file = viewModel.externalFiles.first(where: { $0.displayName == fileName }) {
              viewModel.assignFileToCategory(file: file, category: category)
              feedbackGenerator.impactOccurred()
            }
          }
          // Reset the dragOverCategory state
          dragOverCategory = nil
        }
      }
      return true
    }
    return false
  }
}

enum LaunchConfigSortOrder: String, CaseIterable, Identifiable {
  case recent = "Recent", alphabetical = "ABC"
  var id: Self { self }
  
  static let userDefaultsKey = "lastLaunchConfigSortOrder"
}

struct LauncherView: View {
  @ObservedObject var viewModel: LauncherViewModel
  @State private var selections = [GZDoomFile]()
  @State private var launchConfigSortOrder: LaunchConfigSortOrder = LaunchConfigSortOrder(
    rawValue: UserDefaults.standard.string(forKey: LaunchConfigSortOrder.userDefaultsKey
  ) ?? "Recent") ?? .recent
  
  @State private var showToast = false
  
  @Environment(\.presentations) private var presentations
  @State private var activeSheet: ActiveSheet?
  
  @State private var animateGradient: Bool = false
  
  #if ZERO
  @StateObject private var purchaseModel = PurchaseViewModel.shared
  #endif
  
  static let currentVersion = "2025.10.0"
  
  #if ZERO
  private var fadingTexts = [
    "^[Swipe left to reveal edit and delete options.](colored: 'yellow')",
    "Questions? Chat with the community on [Discord](https://discord.gg/S4tVTNEmsj)!"
  ]
  #else
  private var fadingTexts = [
    "^[Swipe left to reveal edit and delete options.](colored: 'yellow')",
    "Questions? Chat with the community on [Discord](https://discord.gg/S4tVTNEmsj)!",
    "^[Thank you](colored: 'green') ^[for your support](colored: 'white') ❤️"
  ]
  #endif
  
  var body: some View {
    VStack {
      HStack {
        ZStack {
          HStack {
            Spacer()
            #if ZERO
            Text(purchaseModel.isPurchased ? "GenZD" : "GenZD Zero").font(.largeTitle).foregroundColor(.red)
            #else
            Text("GenZD").font(.largeTitle).foregroundColor(.red)
            #endif
            Spacer()
          }
          HStack {
            Button {
              activeSheet = .addLauncherConfig
            } label: {
              Image(systemName: "plus")
            }.buttonStyle(.bordered)
            #if os(tvOS)
              .foregroundColor(.red)
            #else
              .foregroundColor(.yellow)
            #endif
              .font(.actionButton)
            Button {
              activeSheet = .settings
            } label: {
              Image(systemName: "gear")
            }.buttonStyle(.bordered).foregroundStyle(.yellow)
            Spacer()
            
            
            #if os(tvOS)
            Spacer()
            #endif

            #if !os(tvOS)

            #if ZERO
            if !purchaseModel.isPurchased {
              Button {
                activeSheet = .upgrade
              } label: {
                Text("Upgrade Now")
              }.buttonStyle(.bordered).foregroundStyle(.cyan).font(.body)
            }
            #endif

            Button("Help") {
              activeSheet = .showHelp
            }.buttonStyle(.bordered)
              .foregroundColor(.yellow)
              .font(.body)
            #endif
          }
        }
      }
      
      LauncherConfigsView(viewModel: viewModel, showToast: $showToast, sortMode: $launchConfigSortOrder).padding(.bottom)

      FadingTextView(texts: fadingTexts)
      
    }.toast(isPresenting: $showToast) {
      AlertToast(type: .complete(.green), title: "Loaded Saved Configuration", style: AlertToast.AlertStyle.style(titleColor: .gray, titleFont: .small))
    }.padding([.bottom], 4)
      .sheet(item: $activeSheet) { item in
        switch item {
        case .addLauncherConfig:
          #if ZERO
          if !PurchaseViewModel.shared.isPurchased && viewModel.savedConfigs.count > 2 {
            UpgradeView()
          } else {
            CreateLaunchConfigView(viewModel: viewModel).environment(\.presentations, presentations + [$activeSheet])
          }
          #else
          CreateLaunchConfigView(viewModel: viewModel).environment(\.presentations, presentations + [$activeSheet])
          #endif
        case .showHelp:
          HelpSheetView()
        case .settings:
          ControlOptionsView(dismissClosure: {
            activeSheet = nil
          }).environmentObject(viewModel)

        #if ZERO
        case .upgrade:
          UpgradeView()
        #endif

        default:
          EmptyView()
        }
      }.onAppear {
        viewModel.setup()
        let whatsNewVersionSeen = UserDefaults.standard.string(forKey: WhatsNewView.userDefaultsKey)
        #if os(tvOS)
        whatsNewAvailable = false
        #else
        whatsNewAvailable =
        (whatsNewVersionSeen == nil || (whatsNewVersionSeen != nil && whatsNewVersionSeen! != Self.currentVersion )) &&
        Bundle.main.url(forResource: "whats-new", withExtension: "md") != nil
        #endif
    }.font(.body)
      .background {
        LinearGradient(colors: [.red.opacity(0.2), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
          .edgesIgnoringSafeArea(.all)
          .hueRotation(.degrees(animateGradient ? 45 : 0))
          .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
              animateGradient.toggle()
            }
          }
      }.overlay {
        if whatsNewAvailable {
          ZStack {
            WhatsNewView(closeClosure: {
              whatsNewAvailable = false
            })
            .frame(width: 600, height: 330)
          }
        }
      }
  }
  
  @State private var whatsNewAvailable = false
  
  init(viewModel: LauncherViewModel, selections: [GZDoomFile] = [GZDoomFile]()) {
    self.viewModel = viewModel
    self.selections = selections
    #if os(tvOS)
    let segmentedControlFont = UIFont(name: "PerfectDOSVGA437", size: 40)!
    #else
    let segmentedControlFont = UIFont(name: "PerfectDOSVGA437", size: 20)!
    #endif
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.font : segmentedControlFont],
      for: .normal
    )
  }
}

struct LauncherView_Previews: PreviewProvider {
  static var viewModel: LauncherViewModel {
    let vm = LauncherViewModel()
    vm.iWadFiles = [
      GZDoomFile(fullPath: "doom.wad"),
      GZDoomFile(fullPath: "doom2.wad"),
      GZDoomFile(fullPath: "finaldoom.wad")
    ]
    vm.externalFiles = [
      GZDoomFile(fullPath: "brutal.pk3"),
      GZDoomFile(fullPath: "zelda.pk3"),
    ]
    return vm
  }
    static var previews: some View {
        LauncherView(viewModel: viewModel)
    }
}

@objc class LauncherViewController: UIViewController {
  let viewModel: LauncherViewModel
  
  init(viewModel: LauncherViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
//    print("PRINT FONTS")
//    for family in UIFont.familyNames {
//         print(family)
//         for names in UIFont.fontNames(forFamilyName: family){
//         print("== \(names)")
//         }
//    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.launchActionClosure = { [weak self] arguments in
      #if os(tvOS)
      self?.viewModel.webServer?.stop()
      #endif
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        #if !os(tvOS)
        if let vm = self?.viewModel {
          BonjourServicePublisher.shared.launcherVM = vm
          CentralRegistryClient.shared.launcherVM = vm
        }
        #endif
        ControlOptionsViewModel.shared.configureAudioSession()
        self?.startSDLMain(withArgs: arguments)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
              window.rootViewController = self
              window.makeKeyAndVisible()
            }
        }
      }
    }
    let launcherView = LauncherView(viewModel: viewModel)
    let hostingController = UIHostingController(rootView: launcherView)
    addChild(hostingController)
    hostingController.didMove(toParent: self)
    let hostingView = hostingController.view!
    view.addSubview(hostingView)
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingView.topAnchor.constraint(equalTo: view.topAnchor),
      hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    
    #if os(iOS)
    #if DEBUG
//    let debugToolbar = UIToolbar()
//    debugToolbar.translatesAutoresizingMaskIntoConstraints = false
//    let debug1 = UIBarButtonItem(
//      image: UIImage(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"),
//      style: .plain,
//      target: self,
//      action: #selector(debug1Tapped(_:))
//    )
//    debugToolbar.setItems([debug1], animated: false)
//    view.addSubview(debugToolbar)
//    NSLayoutConstraint.activate([
//      debugToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//      debugToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//      debugToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//    ])
    #endif
    #endif
  }
  
  #if DEBUG && os(iOS)
  @objc func debug1Tapped(_ sender: UIBarButtonItem) {
    let vc = ArrangeGamepadControlViewController()
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
  #endif
}

@objc class LauncherViewControllerFactory: NSObject {
  @objc static func create() -> UIViewController {
#if ZERO
    let _ = PurchaseViewModel.shared
#endif
    let viewModel = LauncherViewModel()
    let viewController = LauncherViewController(viewModel: viewModel)
    return viewController
  }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color {
  static var darkGray: Color { Color(red: 0.2, green: 0.2, blue: 0.2) }
}
