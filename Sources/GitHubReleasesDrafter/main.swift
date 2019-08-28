import Commander

let main = command(
    Argument<String>("version"),
    Option("path", default: "", description: "Your releases path"),
    Option("token", default: "", description: "Your token"),
    Option("draft", default: "true", description: "Is draft?"),
    Option("prerelease", default: "false", description: "Is pre release?"),
    Option("assetFileName", default: "", description: "Your assetFileName")
) { version, path, token, draft, prerelease, assetFileName in
    if version.isEmpty || path.isEmpty {
        print("Cannot find required parameter⁉️")
    } else {
        print("tag: \(version)")
        print("path: \(version)")
    }
    if token.isEmpty {
        print("Missing value for `token`")
    }
    print("assetFileName: \(assetFileName)")

    let drafter = GitHubReleasesDrafter(
        tag: version,
        path: path,
        token: token,
        assetFileName: assetFileName,
        draft: draft.toBool(),
        prerelease: prerelease.toBool()
    )
    if assetFileName.isEmpty && draft.toBool() {
        print(drafter.🔓())
    } else {
        print(drafter.🚀())
    }
}

main.run()
