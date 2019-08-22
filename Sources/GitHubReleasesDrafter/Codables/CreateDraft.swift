//
//  CreateDraft.swift
//  GitHubReleasesDrafter
//
//  Created by WataruSuzuki on 2019/11/01.
//

import Foundation

// https://developer.github.com/v3/repos/releases/#create-a-release
struct CreateDraft : Codable {
    let tag_name: String
    let target_commitish: String
    let name: String
    let body: String
    let draft: Bool
    let prerelease: Bool
}
