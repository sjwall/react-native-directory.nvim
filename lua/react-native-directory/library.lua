---@class LicenseDetails
---@field key string
---@field name string
---@field spdxId string
---@field url string
---@field id string

---@class ReleaseDetails
---@field name string
---@field tagName string
---@field createdAt string
---@field publishedAt string
---@field isPrerelease boolean

---@class RepoStats
---@field hasIssues boolean
---@field hasWiki boolean
---@field hasSponsorships boolean
---@field hasTopics boolean?
---@field updatedAt string
---@field createdAt string
---@field pushedAt string
---@field issues number
---@field subscribers number
---@field stars number
---@field forks number

---@class RepoUrl
---@field repo string
---@field clone string
---@field homepage string?

---@class GitHubDetails
---@field name string
---@field isPackagePrivate boolean
---@field fullName string
---@field description string
---@field registry string?
---@field topics string[]?
---@field hasTypes boolean?
---@field newArchitecture boolean?
---@field isArchived boolean?
---@field urls RepoUrl
---@field stats RepoStats
---@field license LicenseDetails
---@field lastRelease ReleaseDetails?

---@class NpmStats
---@field downloads number?
---@field weekDownloads number?
---@field start string?
---@field end string?
---@field period string?

---@class RndLibraryItem
---@field githubUrl string
---@field ios boolean?
---@field android boolean?
---@field web boolean?
---@field windows boolean?
---@field macos boolean?
---@field tvos boolean?
---@field visionos boolean?
---@field fireos boolean?
---@field expoGo boolean?
---@field npmPkg string?
---@field dev boolean?
---@field unmaintained (boolean | string)?
---@field template boolean?
---@field newArchitecture (boolean | string)?
---@field newArchitectureNote string?
---@field alternatives string[]?
---@field github GitHubDetails
---@field npm NpmStats?
---@field score number
---@field matchingScoreModifiers string[]
---@field topicSearchString string
---@field examples string[]?
---@field images string[]?
---@field popularity number?
---@field matchScore number

---@alias RndLibrary RndLibraryItem[]

local M = {}

M.platforms = { "ios", "android", "windows", "macos", "tvos", "fireos", "expoGo" }

return M
