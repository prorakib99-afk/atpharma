//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import connectivity_plus
import geocoding_darwin
import geolocator_apple
import package_info_plus
import rive_native
import sqflite_darwin

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  ConnectivityPlusPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlusPlugin"))
  GeocodingDarwinPlugin.register(with: registry.registrar(forPlugin: "GeocodingDarwinPlugin"))
  GeolocatorPlugin.register(with: registry.registrar(forPlugin: "GeolocatorPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  RiveNativePlugin.register(with: registry.registrar(forPlugin: "RiveNativePlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
