import Foundation
import PathKit
import Stencil
import xcodeproj

guard CommandLine.arguments.count == 2 else {
    let arg0 = Path(CommandLine.arguments[0]).lastComponent
    fputs("usage: \(arg0) <module name> \n examples: \n - mintgen Sample \n - mintgen Awesome/Sample\n", stderr)
    exit(1)
}

// MARK: - Load settings

print("Processing...")
let settingsFile = Path("mintgen.json")

if settingsFile.exists == false {
    print("file mintgen.json is not found")
    exit(1)
}

let data = try settingsFile.read()
guard let settings = try? JSONDecoder().decode(Settings.self, from: data) else {
    print("'mintgen.json' is not valid")
    exit(1)
}


// MARK: - Load project

let projectPath = Path(settings.xcodeprojPath)

if projectPath.exists == false {
    print("file .xcodeproj is not found")
    exit(1)
}

let proj = try XcodeProj(path: projectPath)

guard let project = proj.pbxproj.projects.first(where: { $0.name == settings.projectName }) else {
    print("Project with name \(settings.projectName) is not found")
    exit(1)
}

guard let xcodeTarget = proj.pbxproj.targets(named: settings.projectTarget).first else {
    print("Target with name \(settings.projectName) is not found")
    exit(1)
}

guard let sourcesBuildPhase = try? xcodeTarget.sourcesBuildPhase() else {
    print("Build phase cannot be obtained")
    exit(1)
}

// MARK: - Generate context

let components =  CommandLine.arguments[1].split(separator: "/")
let name = String(components.last ?? "")
let path = components.dropLast().joined(separator: "/")

var context = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
context?["name"] = name

// MARK: - Create folders

let templatesFolder = Path(settings.templatesPath)
let templatePathes = try templatesFolder.children()
let environment = Environment(loader: FileSystemLoader(paths: [templatesFolder]))

let targetPath = [settings.projectFilePath, path, name].joined(separator: "/")
let targetFolder = Path(targetPath)
try targetFolder.mkpath()

// MARK: - Create groups

var targetGroup = project.mainGroup
for folder in targetFolder.components {
    if let existed = targetGroup?.children.first(where: { $0.path == folder }) as? PBXGroup {
        targetGroup = existed
        continue
    }
    targetGroup = try targetGroup?.addGroup(named: folder).last
}

// MARK: - Code generation

for filePath in templatePathes where filePath.extension == "mint" {
    let fileName = filePath.lastComponent.split(separator: ".").dropLast().joined(separator: ".")
    let resultName = [settings.prefix, name, fileName].joined()
    let textData = try environment.renderTemplate(name: filePath.lastComponent, context: context)
    
    let filePath = Path("\(targetPath)/\(resultName)")
    try filePath.write(textData)
    print("\(resultName) was generated")
    
    if targetGroup?.children.contains(where: { $0.path == resultName }) == true {
        continue
    }
    let fileRef = try targetGroup?.addFile(at: filePath, sourceRoot: Path("."))
    let buildFile = PBXBuildFile(file: fileRef!)
    proj.pbxproj.add(object: buildFile)
    sourcesBuildPhase.files?.append(buildFile)
}

print("Updating project...")
try proj.write(path: projectPath)
print("Done")
