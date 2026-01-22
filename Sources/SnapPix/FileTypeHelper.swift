//
//  FileTypeHelper.swift
//
//
//  Created by Pavel Kurzo on 22/01/2026.
//

import Foundation
import UniformTypeIdentifiers

public let defaultSupportedFileExtensions: [String] = [
    "jpg", "jpeg", "png", "pdf", "xls", "xlsx", "gdoc", "gsheet",
    "doc", "docx", "ppt", "pptx", "txt"
]

@available(iOS 14.0, *)
public struct FileTypeHelper {
    public static func utTypes(from extensions: [String]) -> [UTType] {
        var utTypes: [UTType] = []
        
        for ext in extensions {
            let lowercasedExt = ext.lowercased()
            
            if let utType = utType(for: lowercasedExt) {
                utTypes.append(utType)
            } else if let uti = UTType(filenameExtension: lowercasedExt) {
                utTypes.append(uti)
            }
        }
        
        return utTypes
    }
    
    private static func utType(for extension: String) -> UTType? {
        switch `extension` {
        case "jpg", "jpeg":
            return .jpeg
        case "png":
            return .png
        case "pdf":
            return .pdf
        case "txt":
            return .plainText
        case "xls":
            if let utType = UTType("com.microsoft.excel.xls") {
                return utType
            }
            return UTType(filenameExtension: "xls")
        case "xlsx":
            if let utType = UTType("org.openxmlformats.spreadsheetml.sheet") {
                return utType
            }
            return UTType(filenameExtension: "xlsx")
        case "gdoc":
            return UTType(filenameExtension: "gdoc")
        case "gsheet":
            return UTType(filenameExtension: "gsheet")
        case "doc":
            if let utType = UTType("com.microsoft.word.doc") {
                return utType
            }
            return UTType(filenameExtension: "doc")
        case "docx":
            if let utType = UTType("org.openxmlformats.wordprocessingml.document") {
                return utType
            }
            return UTType(filenameExtension: "docx")
        case "ppt":
            if let utType = UTType("com.microsoft.powerpoint.ppt") {
                return utType
            }
            return UTType(filenameExtension: "ppt")
        case "pptx":
            if let utType = UTType("org.openxmlformats.presentationml.presentation") {
                return utType
            }
            return UTType(filenameExtension: "pptx")
        default:
            return UTType(filenameExtension: `extension`)
        }
    }

    public static func mimeType(for pathExtension: String) -> String {
        let ext = pathExtension.lowercased()
        
        switch ext {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "pdf":
            return "application/pdf"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "gdoc":
            return "application/vnd.google-apps.document"
        case "gsheet":
            return "application/vnd.google-apps.spreadsheet"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "txt":
            return "text/plain"
        default:
            if let uti = UTType(filenameExtension: ext),
               let mimeType = uti.preferredMIMEType {
                return mimeType
            }
            return "application/octet-stream"
        }
    }
}
