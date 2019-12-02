//
//  SingleRelease.swift
//  GitHubReleasesDrafter
//
//  Created by WataruSuzuki on 2019/11/01.
//

import Foundation

// https://developer.github.com/v3/repos/releases/#get-a-single-release
struct Release: Codable {
    let url: String
    let assets_url: String
    let upload_url: String
    let id: Int
    let node_id: String
    let tag_name: String
    let target_commitish: String
    let name: String
    let body: String
    let draft: Bool
    let prerelease: Bool

    let assets: [Assets]
}
