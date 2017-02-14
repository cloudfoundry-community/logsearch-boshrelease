# Changelog

## [Unreleased]
### Changed
- Breaking: Move index templates from package `logsearch-config` to job `elasticsearch_config`. To upgrade, set `properties.elasticsearch_config.templates` according to `templates/logsearch-jobs.yml`.
