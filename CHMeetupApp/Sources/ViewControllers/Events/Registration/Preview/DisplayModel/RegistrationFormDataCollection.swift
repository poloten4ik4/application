//
//  RegistrationFormDataCollection.swift
//  CHMeetupApp
//
//  Created by Maxim Globak on 05.03.17.
//  Copyright © 2017 CocoaHeads Community. All rights reserved.
//

import UIKit

protocol FormDisplayCollectionDelegate: class {
  func formDisplayRequestTo(selectItemsAt selectionIndexPaths: [IndexPath],
                            deselectItemsAt deselectIndexPaths: [IndexPath])
}

class FormDisplayCollection: NSObject, DisplayCollection, DisplayCollectionAction {
  static var modelsForRegistration: [CellViewAnyModelType.Type] {
    return [OptionTableViewCellModel.self]
  }

  init(formData: FormData? = nil) {
    self.formData = formData
  }

  var formData: FormData!
  weak var delegate: FormDisplayCollectionDelegate?

  var numberOfSections: Int {
    return formData?.sections.count ?? 0
  }

  func numberOfRows(in section: Int) -> Int {
    return formData.sections[section].fieldAnswers.count
  }

  func model(for indexPath: IndexPath) -> CellViewAnyModelType {
    let cell = formData.sections[indexPath.section].fieldAnswers[indexPath.row]
    switch cell.type {
    case .checkbox:
      return OptionTableViewCellModel(id: cell.id, text: cell.value, type: .checkbox)
    case .radio:
      return OptionTableViewCellModel(id: cell.id, text: cell.value, type: .radio)
    case .string:
      fatalError("Not implemented")
    }
  }

  func headerHeight(for section: Int) -> CGFloat {
    return 40
  }

  func headerTitle(for section: Int) -> String {
    return formData.sections[section].name
  }

  func didSelect(indexPath: IndexPath) {
    let value = formData.sections[indexPath.section].fieldAnswers[indexPath.row]
    switch value.type {
    case .checkbox:
      let result = value.type.parse(answer: value.answer) as! Bool // swiftlint:disable:this force_cast
      value.answer = !result
      processCheckbox(at: indexPath, with: result)
    case .radio:
      let result = value.type.parse(answer: value.answer) as! Bool // swiftlint:disable:this force_cast
      value.answer = true
      processRadio(at: indexPath, with: result)
    case .string:
      fatalError("Not implemented")
    }
  }

  private func processCheckbox(at indexPath: IndexPath, with value: Bool) {
    if value {
      delegate?.formDisplayRequestTo(selectItemsAt: [], deselectItemsAt: [indexPath])
    } else {
      delegate?.formDisplayRequestTo(selectItemsAt: [indexPath], deselectItemsAt: [])
    }
  }

  private func processRadio(at indexPath: IndexPath, with value: Bool) {
    var deselectIndex: Int?

    for (index, value) in formData.sections[indexPath.section].fieldAnswers.enumerated() {
      if let result = value.answer as? Bool, result == true, index != indexPath.row {
        deselectIndex = index
      }
    }

    var deselectIndexPaths: [IndexPath] = []
    if let index = deselectIndex {
      deselectIndexPaths.append(IndexPath(row: index, section: indexPath.section))
    }

    delegate?.formDisplayRequestTo(selectItemsAt: [indexPath], deselectItemsAt: deselectIndexPaths)
  }
}