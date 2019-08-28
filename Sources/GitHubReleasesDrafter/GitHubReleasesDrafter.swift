//
//  GitHubReleasesDrafter.swift
//  GitHubReleasesDrafter
//
//  Created by WataruSuzuki on 2019/11/01.
//

import Foundation

class GitHubReleasesDrafter {

    private let semaphore = DispatchSemaphore(value: 0)
    private let token: String
    private let path: String
    private let tag: String
    private let assetFileName: String
    private let isDraft: Bool
    private let isPreRelease: Bool

    private var githubApiReleases: String {
        get {
            return "https://api.github.com/repos/\(path)/releases"
        }
    }
    
    private var url: URL {
        get {
            guard let url = URL(string: githubApiReleases) else {
                fatalError("💣🧨 Is your GitHub Releases path correct??")
            }
            return url
        }
    }
    
    init(tag: String, path: String, token: String, assetFileName: String, draft: Bool, prerelease: Bool) {
        self.tag = tag
        self.token = token
        self.path = path
        self.assetFileName = assetFileName
        self.isDraft = draft
        self.isPreRelease = prerelease
    }

    func 🚀() -> String {
        var draft = getListReleases(tag: tag)
        if let draft = draft {
            if let draftAsset = draft.assets.first {
                deletePreviousAsset(id: draftAsset.id)
            }
        } else {
            draft = createDraft()
        }
        
        if let assetDraft = draft {
            let _ = uploadAsset(draft: assetDraft)
        }
        
        return "(・∀・)b"
    }
    
    func 🔓() -> String {
        if let draft = getListReleases(tag: tag) {
            changePublish(draft)
            return "(・∀・)b"
        }
        return "(・A・)"
    }
    
    private func requestURL(str: String = "") -> URLRequest {
        var request = URLRequest(url: str.isEmpty
            ? url
            : URL(string: str)!
        )
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func getListReleases(tag: String) -> Release? {
        var draft: Release? = nil
        let task = URLSession.shared.dataTask(with: requestURL()) { (data, response, error) in
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let decoder = JSONDecoder()
                if let json = try? decoder.decode([Release].self, from: data) {
                    draft = json.filter({$0.tag_name == tag}).first
                }
            }
            self.semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        return draft
    }
    
    private func changePublish(_ draft: Release) {
        print(#function)
        
        var request = requestURL(str: githubApiReleases + "/\(draft.id)")
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(
            CreateDraft(
                tag_name: draft.tag_name,
                target_commitish: draft.target_commitish,
                name: draft.tag_name,
                body: draft.body,
                draft: isDraft,
                prerelease: draft.prerelease
            )
         ) {
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse,
                    response.statusCode == 201 {
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(Release.self, from: data) {
                        print(json.name)
                    }
                } else {
                    print(response?.description ?? "")
                }
                self.semaphore.signal()
            }
            task.resume()
            self.semaphore.wait()
        }
    }
    
    private func deletePreviousAsset(id: Int) {
        print(#function)
        
        var request = requestURL(str: githubApiReleases + "/assets/\(id)")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            self.semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    private func createDraft() -> Release? {
        print(#function)
        var draft: Release?
        
        var request = requestURL()
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(
            CreateDraft(
                tag_name: tag,
                target_commitish: "master",
                name: tag,
                body: "Created by GitHub-Releases-Drafter",
                draft: isDraft,
                prerelease: isPreRelease
            )
         ) {
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse,
                    response.statusCode == 201 {
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(Release.self, from: data) {
                        print(json.name)
                        draft = json
                    }
                } else {
                    print(response?.description ?? "")
                }
                self.semaphore.signal()
            }
            task.resume()
            self.semaphore.wait()
        }

        return draft
    }
    
    private func uploadAsset(draft: Release) -> Assets? {
        print(#function)
        var asset: Assets?
        guard !assetFileName.isEmpty else { return asset }
        
        var request = requestURL(str: draft.upload_url.replacingOccurrences(of: "{?name,label}", with: "?name=\(assetFileName)"))
        request.httpMethod = "POST"
        request.addValue("application/zip", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, fromFile: URL(fileURLWithPath: "./\(assetFileName)")) { (data, response, error) in
            if let data = data, let response = response as? HTTPURLResponse,
                response.statusCode == 201 {
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(Assets.self, from: data) {
                    print(json.name)
                    asset = json
                }
            } else {
                print(response?.description ?? "")
            }
            self.semaphore.signal()
        }
        task.resume()
        self.semaphore.wait()

        return asset
    }
}

extension String {
    func toBool() -> Bool {
        switch self {
        case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
            return true
        case "FALSE", "False", "false", "NO", "No", "no", "0":
            fallthrough
        default:
            return false
        }
    }
}
