//
//  SearchApiServiceModel.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import Foundation

enum SearchRepositorySortType: String {
    case stars = "stars"
    case forks = "forks"
    case helpIssues = "help-wanted-issues"
    case updated = "updated"
}

enum SearchRepositoryOrderType: String {
    case asc = "asc"
    case desc = "desc"
}

struct SearchRepositoryParams: Codable {
    var q: String
    var sort: String?
    var order: String?
    var perPage: Int
    var page: Int
    
    enum CodingKeys: String, CodingKey {

        case q = "q"
        case sort = "sort"
        case order = "order"
        case perPage = "per_page"
        case page = "page"
    }
}

struct SearchRepositoryCodable: Codable {
    let totalCount : Int?
    let incompleteResults : Bool?
    let repositories : [SeachRepositoryItems]?

    enum CodingKeys: String, CodingKey {

        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case repositories = "items"
    }
}

struct SeachRepositoryItems: Codable {
    let id : Int?
    let nodeId : String?
    let name : String?
    let fullName : String?
    let owner : RepositoryOwner?
    let isPrivate : Bool?
    let htmlUrl : String?
    let description : String?
    let fork : Bool?
    let url : String?
    let createdAt : String?
    let updatedAt : String?
    let pushedAt : String?
    let homepage : String?
    let size : Int?
    let stargazersCount : Int?
    let watchersCount : Int?
    let language : String?
    let forksCount : Int?
    let openIssuesCount : Int?
    let masterBranch : String?
    let defaultBranch : String?
    let score : Int?
    let archiveUrl : String?
    let assigneesUrl : String?
    let blobsUrl : String?
    let branchesUrl : String?
    let collaboratorsUrl : String?
    let commentsUrl : String?
    let commitsUrl : String?
    let compareUrl : String?
    let contentsUrl : String?
    let contributorsUrl : String?
    let deploymentsUrl : String?
    let downloadsUrl : String?
    let eventsUrl : String?
    let forksUrl : String?
    let gitCommitsUrl : String?
    let gitRefsUrl : String?
    let gitTagsUrl : String?
    let gitUrl : String?
    let issueCommentUrl : String?
    let issueEventsUrl : String?
    let issuesUrl : String?
    let keysUrl : String?
    let labelsUrl : String?
    let languagesUrl : String?
    let mergesUrl : String?
    let milestonesUrl : String?
    let notificationsUrl : String?
    let pullsUrl : String?
    let releasesUrl : String?
    let sshUrl : String?
    let stargazersUrl : String?
    let statusesUrl : String?
    let subscribersUrl : String?
    let subscriptionUrl : String?
    let tagsUrl : String?
    let teamsUrl : String?
    let treesUrl : String?
    let cloneUrl : String?
    let mirrorUrl : String?
    let hooksUrl : String?
    let svnUrl : String?
    let forks : Int?
    let openIssues : Int?
    let watchers : Int?
    let hasIssues : Bool?
    let hasProjects : Bool?
    let hasPages : Bool?
    let hasWiki : Bool?
    let hasDownloads : Bool?
    let archived : Bool?
    let disabled : Bool?
    let visibility : String?
    let license : RepositoryLicense?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case nodeId = "node_id"
        case name = "name"
        case fullName = "full_name"
        case owner = "owner"
        case isPrivate = "private"
        case htmlUrl = "html_url"
        case description = "description"
        case fork = "fork"
        case url = "url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case homepage = "homepage"
        case size = "size"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case language = "language"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case masterBranch = "master_branch"
        case defaultBranch = "default_branch"
        case score = "score"
        case archiveUrl = "archive_url"
        case assigneesUrl = "assignees_url"
        case blobsUrl = "blobs_url"
        case branchesUrl = "branches_url"
        case collaboratorsUrl = "collaborators_url"
        case commentsUrl = "comments_url"
        case commitsUrl = "commits_url"
        case compareUrl = "compare_url"
        case contentsUrl = "contents_url"
        case contributorsUrl = "contributors_url"
        case deploymentsUrl = "deployments_url"
        case downloadsUrl = "downloads_url"
        case eventsUrl = "events_url"
        case forksUrl = "forks_url"
        case gitCommitsUrl = "git_commits_url"
        case gitRefsUrl = "git_refs_url"
        case gitTagsUrl = "git_tags_url"
        case gitUrl = "git_url"
        case issueCommentUrl = "issue_comment_url"
        case issueEventsUrl = "issue_events_url"
        case issuesUrl = "issues_url"
        case keysUrl = "keys_url"
        case labelsUrl = "labels_url"
        case languagesUrl = "languages_url"
        case mergesUrl = "merges_url"
        case milestonesUrl = "milestones_url"
        case notificationsUrl = "notifications_url"
        case pullsUrl = "pulls_url"
        case releasesUrl = "releases_url"
        case sshUrl = "ssh_url"
        case stargazersUrl = "stargazers_url"
        case statusesUrl = "statuses_url"
        case subscribersUrl = "subscribers_url"
        case subscriptionUrl = "subscription_url"
        case tagsUrl = "tags_url"
        case teamsUrl = "teams_url"
        case treesUrl = "trees_url"
        case cloneUrl = "clone_url"
        case mirrorUrl = "mirror_url"
        case hooksUrl = "hooks_url"
        case svnUrl = "svn_url"
        case forks = "forks"
        case openIssues = "open_issues"
        case watchers = "watchers"
        case hasIssues = "has_issues"
        case hasProjects = "has_projects"
        case hasPages = "has_pages"
        case hasWiki = "has_wiki"
        case hasDownloads = "has_downloads"
        case archived = "archived"
        case disabled = "disabled"
        case visibility = "visibility"
        case license = "license"
    }
}

struct RepositoryOwner : Codable {
    let login : String?
    let id : Int?
    let nodeId : String?
    let avatarUrl : String?
    let gravatarId : String?
    let url : String?
    let receivedEventsUrl : String?
    let type : String?
    let htmlUrl : String?
    let followersUrl : String?
    let followingUrl : String?
    let gistsUrl : String?
    let starredUrl : String?
    let subscriptionsUrl : String?
    let organizationsUrl : String?
    let reposUrl : String?
    let eventsUrl : String?
    let siteAdmin : Bool?

    enum CodingKeys: String, CodingKey {

        case login = "login"
        case id = "id"
        case nodeId = "node_id"
        case avatarUrl = "avatar_url"
        case gravatarId = "gravatar_id"
        case url = "url"
        case receivedEventsUrl = "received_events_url"
        case type = "type"
        case htmlUrl = "html_url"
        case followersUrl = "followers_url"
        case followingUrl = "following_url"
        case gistsUrl = "gists_url"
        case starredUrl = "starred_url"
        case subscriptionsUrl = "subscriptions_url"
        case organizationsUrl = "organizations_url"
        case reposUrl = "repos_url"
        case eventsUrl = "events_url"
        case siteAdmin = "site_admin"
    }
}


struct RepositoryLicense : Codable {
    let key : String?
    let name : String?
    let url : String?
    let spdxId : String?
    let nodeId : String?
    let htmlUrl : String?

    enum CodingKeys: String, CodingKey {

        case key = "key"
        case name = "name"
        case url = "url"
        case spdxId = "spdx_id"
        case nodeId = "node_id"
        case htmlUrl = "html_url"
    }
}

