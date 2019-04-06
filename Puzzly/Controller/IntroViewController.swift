//
//  IntroViewController.swift
//  Gridy
//
//  Created by Spencer Forrest on 17/03/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class IntroViewController: UIViewController {
  override func viewDidLoad() {
    let introView =  IntroView.init()
    introView.delegate = self
    introView.setup(parentView: self.view)
  }
}

extension IntroViewController: IntroViewDelegate {
  
  // Delegate method: IntroViewDelegate
  /// Select a random picture
  func randomButtonTouched() {
    let random = Int.random(min: 0, max: 4)
    if let image = UIImage(named: Constant.ImageName.image + "\(random)") {
      let editingViewController = EditViewController()
      editingViewController.image = image
      self.present(editingViewController, animated: true, completion: nil)
    }
  }
  
  // Delegate method: IntroViewDelegate
  /// Take a picture and use it
  func cameraButtonTouched() {
    let sourceType = UIImagePickerController.SourceType.camera
    displayMediaPicker(sourceType: sourceType)
  }
  
  // Delegate method: IntroViewDelegate
  /// Select a picture from photo library
  func photosButtonTouched() {
    let sourceType = UIImagePickerController.SourceType.photoLibrary
    displayMediaPicker(sourceType: sourceType)
  }
  
  /// Use the Image Picker for: camera or photo library
  ///
  /// - Parameter sourceType: camera or photo library
  func displayMediaPicker(sourceType: UIImagePickerController.SourceType) {
    
    let usingCamera = sourceType == .camera
    let media = usingCamera ? "Camera" : "Photos"
    
    if UIImagePickerController.isSourceTypeAvailable(sourceType) {
      let noPermissionTitle = "Access to your \'\(media)\' denied"
      let noPermissionMessage = "\nGo to \'Settings\' to allow the access."
      
      if usingCamera {
        actionAccordingTo(status: AVCaptureDevice.authorizationStatus(for: AVMediaType.video),
                          noPermissionTitle: noPermissionTitle,
                          noPermissionMessage: noPermissionMessage)
      } else {
        actionAccordingTo(status: PHPhotoLibrary.authorizationStatus(),
                          noPermissionTitle: noPermissionTitle,
                          noPermissionMessage: noPermissionMessage)
      }
    } else {
      let title = "\'\(media)\' unavailable"
      let message = "\(Constant.String.title) cannot have acces to your \'\(media)\' at this time."
      troubleAlert(title: title, message: message)
    }
  }
  
  /// Ask the user the authorization to use the camera.
  /// User can redirect to Settings if authorization not granted.
  /// Call Image Picker if authorization has already been granted
  ///
  /// - Parameters:
  ///   - status: Authorization status to use Camera
  ///   - noPermissionMessage: Message to display if authorization not granted
  func actionAccordingTo(status: AVAuthorizationStatus ,
                         noPermissionTitle: String?,
                         noPermissionMessage: String?) {
    let sourceType = UIImagePickerController.SourceType.camera
    switch status {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: AVMediaType.video) {
        self.checkAuthorizationAccess(granted: $0,
                                      sourceType: sourceType,
                                      noPermissionTitle: noPermissionTitle,
                                      noPermissionMessage: noPermissionMessage)
      }
    case .authorized:
      self.presentImagePicker(sourceType: sourceType)
    case .denied, .restricted:
      self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
    @unknown default:
      fatalError()
    }
  }
  
  /// Ask the user the authorization to use the photo library.
  /// User can redirect to Settings if authorization not granted.
  /// Call Image Picker if authorization has already been granted
  ///
  /// - Parameters:
  ///   - status: Authorization status to use PhotoLibrary
  ///   - noPermissionMessage: Message to display if authorization not granted
  func actionAccordingTo(status: PHAuthorizationStatus ,
                         noPermissionTitle: String?,
                         noPermissionMessage: String?) {
    let sourceType = UIImagePickerController.SourceType.photoLibrary
    switch status {
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization {
        self.checkAuthorizationAccess(granted: $0 == .authorized,
                                      sourceType: sourceType,
                                      noPermissionTitle: noPermissionTitle,
                                      noPermissionMessage: noPermissionMessage)
      }
    case .authorized:
      self.presentImagePicker(sourceType: sourceType)
    case .denied, .restricted:
      self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
    @unknown default:
      fatalError()
    }
  }
  
  /// Check if user has just granted or denied access to the ressource.
  /// If granted, call image picker
  /// If not granted, User can redirect to Settings
  ///
  /// - Parameters:
  ///   - granted: True if authorization has been granted
  ///   - sourceType: Camera or Photo library
  ///   - noPermissionMessage: Message to display if authorization not granted
  func checkAuthorizationAccess(granted: Bool,
                                sourceType: UIImagePickerController.SourceType,
                                noPermissionTitle: String?,
                                noPermissionMessage: String?) {
    if granted {
      self.presentImagePicker(sourceType: sourceType)
    } else {
      self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
    }
  }
  
  /// Present image picker
  ///
  /// - Parameter sourceType: Camera or photo library
  func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = sourceType
    present(imagePickerController, animated: true, completion: nil)
  }
  
  ///   User can go the Settings from here if wanted
  ///
  /// - Parameter message: Description about why user needs to go to Settings
  func openSettingsWithUIAlert(title: String?, message: String?) {
    let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let settingsAction = UIAlertAction.init(title: "Settings", style: .default) {
      _ in
      guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        else { return }
      if UIApplication.shared.canOpenURL(settingsUrl) {
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
      }
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  
  /// Popup an alert message
  ///
  /// - Parameter message: Description of the issue
  func troubleAlert(title: String, message: String?) {
    let alertController = UIAlertController(title: title, message: message , preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Got it", style: .cancel)
    alertController.addAction(alertAction)
    present(alertController, animated: true)
  }
}

extension IntroViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  // Delegate Function: UIImagePickerControllerDelegate
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Local variable inserted by Swift 4.2 migrator.
    let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
    
    picker.dismiss(animated: true, completion: nil)
    
    var image: UIImage?
    
    if picker.allowsEditing {
      image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
    } else {
      image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
    }
    
    if let image = image {
      let editingViewController = EditViewController()
      editingViewController.image = image
      self.present(editingViewController, animated: true, completion: nil)
    }
  }
  
  // Delegate Function: UIImagePickerControllerDelegate
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

extension UIImagePickerController {
  override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return .all
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
  return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
  return input.rawValue
}
