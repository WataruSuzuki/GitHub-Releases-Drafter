//
//  Assets.swift
//  GitHubReleasesDrafter
//
//  Created by WataruSuzuki on 2019/11/01.
//

import Foundation

// https://developer.github.com/v3/repos/releases/#get-a-single-release-asset
struct Assets : Codable {
    let url: String
    let browser_download_url: String

    let id: Int
    let node_id: String
    let name: String
    let label: String
    let state: String
    let content_type: String
    let size: Int
}
