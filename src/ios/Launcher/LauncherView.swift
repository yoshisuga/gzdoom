//
//  LauncherView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 2/19/23.
//

import Foundation
import SwiftUI

enum LauncherMode: String {
  case launcher = "Launcher", savedConfigs = "Saved Configurations"
}

enum SavedConfigSortMode {
  case name, lastRanAt
}

struct CreateLaunchConfigView: View {
  @Environment(\.dismiss) var dismiss
  @ObservedObject var viewModel: LauncherViewModel
  @State var isEditing = false
  
  var body: some View {
    VStack {
      ZStack {
        HStack {
          Spacer()
          Text("\(isEditing ? "Edit" : "Create") Launcher Configuration")
          Spacer()
        }.padding()
        HStack {
          Button("Cancel") {
            dismiss()
          }
          Spacer()
        }.padding()
      }
      HStack {
        VStack {
          if let selectedIWAD = viewModel.selectedIWAD {
            IWADSelectedView(viewModel: viewModel, selected: selectedIWAD)
          } else {
            SelectIWADView(viewModel: viewModel)
          }
        }.frame(maxWidth: .infinity)
        VStack {
          Text("External Files/Mods").foregroundColor(.cyan)
          List {
            ForEach(viewModel.externalFiles.sorted(by: {$0.displayName.lowercased() < $1.displayName.lowercased() }), id:\.self) { file in
              MultipleSelectionRow(file: file, isSelected: viewModel.selectedExternalFiles.contains(file)) {
                if viewModel.selectedExternalFiles.contains(file) {
                  viewModel.selectedExternalFiles.removeAll(where: { $0 == file })
                }
                else {
                  viewModel.selectedExternalFiles.append(file)
                }
              }
            }
          }.frame(maxHeight: .infinity).listStyle(PlainListStyle())
        }
      }
    }
  }
}

enum LaunchConfigSortOrder: String, CaseIterable, Identifiable {
  case recent = "Recent", alphabetical = "ABC"
  var id: Self { self }
}

struct LauncherView: View {
  @ObservedObject var viewModel: LauncherViewModel
  @State private var selections = [GZDoomFile]()
  @State private var launchConfigSortOrder: LaunchConfigSortOrder = .recent
  
  @State private var showToast = false
  
  @State private var activeSheet: ActiveSheet?
  
  enum ActiveSheet: Identifiable {
    case addLauncherConfig, showHelp
    var id: Int { hashValue }
  }
    
  var body: some View {
    VStack {
      HStack {
        ZStack {
          HStack {
            Spacer()
            Text("GZDoom").font(.largeTitle).foregroundColor(.red)
            Spacer()
          }
          HStack {
            Button("+") {
              activeSheet = .addLauncherConfig
            }.buttonStyle(.bordered).foregroundColor(.yellow).font(.actionButton)
            Spacer()
            Picker("Launch Config Order", selection: $launchConfigSortOrder) {
              ForEach(LaunchConfigSortOrder.allCases) {
                Text($0.rawValue)
              }
            }.pickerStyle(.segmented).frame(width: 200)
            Button("Help") {
              activeSheet = .showHelp
            }.buttonStyle(.bordered).foregroundColor(.yellow).font(.body)
          }
        }
      }
      LauncherConfigsView(viewModel: viewModel, showToast: $showToast, sortMode: $launchConfigSortOrder).padding(.bottom)
      ColoredText("Ported to ^[iOS](colored: 'green') by ^[@yoshisuga](colored: 'purple'), 2023. Powered by ^[SwiftUI](colored: 'indigo')").font(.small).foregroundColor(.gray)
    }.toast(isPresenting: $showToast) {
      AlertToast(type: .complete(.green), title: "Loaded Saved Configuration", style: AlertToast.AlertStyle.style(titleColor: .gray, titleFont: .small))
    }.padding([.bottom], 4)
      .sheet(item: $activeSheet) { item in
        switch item {
        case .addLauncherConfig:
          CreateLaunchConfigView(viewModel: viewModel)
        case .showHelp:
          HelpSheetView()
        }
    }.onAppear {
      viewModel.setup()
    }.font(.body)
  }
  
  init(viewModel: LauncherViewModel, selections: [GZDoomFile] = [GZDoomFile]()) {
    self.viewModel = viewModel
    self.selections = selections
    UISegmentedControl.appearance().setTitleTextAttributes([.font : UIFont(name: "PerfectDOSVGA437", size: 20)!], for: .normal)
  }
}

struct LauncherView_Previews: PreviewProvider {
  static var viewModel: LauncherViewModel {
    let vm = LauncherViewModel()
    vm.iWadFiles = [
      GZDoomFile(displayName: "doom.wad", fullPath: "doom.wad"),
      GZDoomFile(displayName: "doom2.wad", fullPath: "doom2.wad"),
      GZDoomFile(displayName: "finaldoom.wad", fullPath: "finaldoom.wad")
    ]
    vm.externalFiles = [
      GZDoomFile(displayName: "brutal.pk3", fullPath: "brutal.pk3"),
      GZDoomFile(displayName: "zelda.pk3", fullPath: "zelda.pk3"),
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
    print("PRINT FONTS")
    for family in UIFont.familyNames {
         print(family)
         for names in UIFont.fontNames(forFamilyName: family){
         print("== \(names)")
         }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.launchActionClosure = { [weak self] arguments in
      self?.startSDLMain(withArgs: arguments)
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
  }
}

@objc class LauncherViewControllerFactory: NSObject {
  @objc static func create() -> UIViewController {
    let viewModel = LauncherViewModel()
    let viewController = LauncherViewController(viewModel: viewModel)
    return viewController
  }
}
